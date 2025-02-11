import redis
import psycopg2
from psycopg2.extras import Json
from datetime import datetime
from typing import Optional, Dict, Any  # Add this import line

class TranslationDB:
    def __init__(self):
        # Redis 连接
        self.redis = redis.Redis(
            host='redis',
            port=6379,
            decode_responses=True
        )
        
        # PostgreSQL 连接
        self.pg_conn = psycopg2.connect(
            host='postgres',
            database='translations',
            user='translator',
            password='translator123'
        )
        
        # 创建表
        self._create_tables()
    
    def _create_tables(self):
        with self.pg_conn.cursor() as cur:
            # 创建翻译记录表
            cur.execute("""
                CREATE TABLE IF NOT EXISTS translations (
                    id SERIAL PRIMARY KEY,
                    source_text TEXT NOT NULL UNIQUE, 
                    confirmed_translation TEXT,
                    is_confirmed BOOLEAN DEFAULT FALSE,
                    return_original BOOLEAN DEFAULT FALSE,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                );
                
                CREATE TABLE IF NOT EXISTS machine_translations (
                    id SERIAL PRIMARY KEY,
                    translation_id INTEGER REFERENCES translations(id),
                    translated_text TEXT NOT NULL,
                    frequency INTEGER DEFAULT 1,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    UNIQUE(translation_id, translated_text)
                );
            """)
            self.pg_conn.commit()
    
    def get_translation(self, text):
        """获取翻译，优先从 Redis 获取已确认的翻译"""
        # 先从 Redis 查询
        cached = self.redis.get(f"trans:{text}")
        if cached:
            return cached
            
        # 从 PostgreSQL 查询已确认的翻译
        with self.pg_conn.cursor() as cur:
            cur.execute("""
                SELECT confirmed_translation, return_original, source_text
                FROM translations 
                WHERE source_text = %s AND is_confirmed = TRUE
                LIMIT 1
            """, (text,))
            result = cur.fetchone()
            if result:
                if result[1]:  # 如果 return_original 为 True
                    return result[2]  # 返回原文
                elif result[0]:  # 如果有确认的翻译
                    # 缓存到 Redis
                    self.redis.set(f"trans:{text}", result[0])
                    return result[0]
        return None
    
    def add_translation(self, source_text, machine_translation):
        """添加新的翻译记录"""
        try:
            with self.pg_conn.cursor() as cur:
                # 先检查是否存在记录
                cur.execute("""
                    SELECT id FROM translations WHERE source_text = %s
                """, (source_text,))
                result = cur.fetchone()
                
                if result:
                    # 如果存在，使用现有的 translation_id
                    translation_id = result[0]
                else:
                    # 如果不存在，插入新记录
                    cur.execute("""
                        INSERT INTO translations (source_text)
                        VALUES (%s)
                        RETURNING id
                    """, (source_text,))
                    translation_id = cur.fetchone()[0]
                
                # 更新机器翻译结果
                cur.execute("""
                    INSERT INTO machine_translations (translation_id, translated_text)
                    VALUES (%s, %s)
                    ON CONFLICT (translation_id, translated_text) 
                    DO UPDATE SET frequency = machine_translations.frequency + 1
                """, (translation_id, machine_translation))
                
                self.pg_conn.commit()
        except Exception as e:
            self.pg_conn.rollback()  # 发生错误时回滚事务
            print(f"[数据库] 保存翻译记录失败: {str(e)}")
    
    def get_translations(self, page: int = 1, page_size: int = 100, 
                        is_confirmed: Optional[bool] = None,
                        return_original: Optional[bool] = None,
                        sort_by: str = "time"):
        """获取翻译记录列表"""
        try:
            with self.pg_conn.cursor() as cur:
                # 构建查询条件
                conditions = []
                params = []
                
                if is_confirmed is not None:
                    conditions.append("is_confirmed = %s")
                    params.append(is_confirmed)
                
                if return_original is not None:
                    conditions.append("return_original = %s")
                    params.append(return_original)
                
                where_clause = " AND ".join(conditions)
                if where_clause:
                    where_clause = "WHERE " + where_clause
                
                # 获取总记录数
                cur.execute(f"""
                    SELECT COUNT(*) FROM translations {where_clause}
                """, params)
                total = cur.fetchone()[0]
                
                # 修改排序方式
                order_by = "t.created_at DESC" if sort_by == "time" else "total_frequency DESC"
                
                # 获取分页数据
                query = f"""
                    SELECT t.id, t.source_text, t.confirmed_translation, 
                           t.is_confirmed, t.return_original,
                           json_agg(json_build_object(
                               'text', mt.translated_text,
                               'frequency', mt.frequency
                           )) as machine_translations,
                           COALESCE(SUM(mt.frequency), 0) as total_frequency
                    FROM translations t
                    LEFT JOIN machine_translations mt ON t.id = mt.translation_id
                    {where_clause}
                    GROUP BY t.id, t.created_at
                    ORDER BY {order_by}
                    LIMIT %s OFFSET %s
                """
                
                cur.execute(query, params + [page_size, (page - 1) * page_size])
                records = cur.fetchall()
                
                # 构建返回数据时增加 total_frequency
                data = []
                for record in records:
                    data.append({
                        "id": record[0],
                        "source_text": record[1],
                        "confirmed_translation": record[2],
                        "is_confirmed": record[3],
                        "return_original": record[4],
                        "machine_translations": record[5] if record[5] else [],
                        "total_frequency": record[6]  # 添加总频次
                    })
                
                return {
                    "total": total,
                    "page": page,
                    "page_size": page_size,
                    "data": data
                }
        except Exception as e:
            print(f"[数据库] 查询翻译记录失败: {str(e)}")
            return None
# 在 TranslationDB 类中添加以下方法

    def update_translation(self, id: int, confirmed_translation: Optional[str] = None, 
                        is_confirmed: Optional[bool] = None, return_original: Optional[bool] = None):
        """更新翻译记录"""
        try:
            with self.pg_conn.cursor() as cur:
                # 构建更新字段
                update_fields = []
                params = []
                
                if confirmed_translation is not None:
                    update_fields.append("confirmed_translation = %s")
                    params.append(confirmed_translation)
                
                if is_confirmed is not None:
                    update_fields.append("is_confirmed = %s")
                    params.append(is_confirmed)
                
                if return_original is not None:
                    update_fields.append("return_original = %s")
                    params.append(return_original)
                
                if not update_fields:
                    return False
                    
                update_fields.append("updated_at = CURRENT_TIMESTAMP")
                
                # 执行更新
                query = f"""
                    UPDATE translations 
                    SET {", ".join(update_fields)}
                    WHERE id = %s
                    RETURNING source_text
                """
                params.append(id)
                
                cur.execute(query, params)
                result = cur.fetchone()
                self.pg_conn.commit()
                
                # 如果更新成功且确认了翻译，更新Redis缓存
                if result and is_confirmed and confirmed_translation:
                    self.redis.set(f"trans:{result[0]}", confirmed_translation)
                
                return result is not None
                
        except Exception as e:
            self.pg_conn.rollback()
            print(f"[数据库] 更新翻译记录失败: {str(e)}")
            return False

    def delete_translation(self, id: int):
        """删除翻译记录"""
        try:
            with self.pg_conn.cursor() as cur:
                # 获取 source_text 用于删除缓存
                cur.execute("SELECT source_text FROM translations WHERE id = %s", (id,))
                result = cur.fetchone()
                if not result:
                    return False
                source_text = result[0]
                
                # 先删除关联的机器翻译记录
                cur.execute("DELETE FROM machine_translations WHERE translation_id = %s", (id,))
                
                # 再删除主记录
                cur.execute("DELETE FROM translations WHERE id = %s", (id,))
                
                self.pg_conn.commit()
                
                # 删除Redis缓存
                self.redis.delete(f"trans:{source_text}")
                
                return True
                
        except Exception as e:
            self.pg_conn.rollback()
            print(f"[数据库] 删除翻译记录失败: {str(e)}")
            return False



