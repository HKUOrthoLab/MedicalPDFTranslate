import os
import time,requests
from fastapi import FastAPI, File, UploadFile, Query, Response
from fastapi.responses import FileResponse
from fastapi.middleware.cors import CORSMiddleware  # 添加这行
from tempfile import NamedTemporaryFile
from magic_pdf.data.data_reader_writer import FileBasedDataWriter, FileBasedDataReader
from magic_pdf.data.dataset import PymuDocDataset
from magic_pdf.model.doc_analyze_by_custom_model import doc_analyze
from magic_pdf.config.enums import SupportedPdfParseMethod
from rebuild_pdf import create_pdf_from_json
from typing import Optional, List
from pydantic import BaseModel
from translation_db import TranslationDB
import hashlib

# 修改 app 的创建
app = FastAPI(
    title="Medical Report Translation API",
    description="API for translating and managing medical reports",
    version="1.0.0",
    docs_url="/docs",   # Swagger UI 地址，默认就是 /docs
    redoc_url="/redoc"  # ReDoc 地址，默认就是 /redoc
)

# 添加 CORS 配置
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 添加响应模型
class TranslationRecord(BaseModel):
    id: int  # 添加这行
    source_text: str
    confirmed_translation: Optional[str]
    is_confirmed: bool
    return_original: bool
    total_frequency: int  # 添加总频次字段
    machine_translations: List[dict]

class TranslationResponse(BaseModel):
    total: int
    page: int
    page_size: int
    data: List[TranslationRecord]

# 添加请求模型纯文本翻译
class TranslateRequest(BaseModel):
    text: str
    model: str
    provider: str = None

# 添加请求模型
class TranslationUpdate(BaseModel):
    confirmed_translation: Optional[str] = None
    is_confirmed: Optional[bool] = None
    return_original: Optional[bool] = None

def log_time(start_time, step_name):
    elapsed_time = time.time() - start_time
    print(f"[耗时统计] {step_name}: {elapsed_time:.2f} 秒")
    return time.time()

def calculate_md5(file_path):
    # 创建一个 md5 哈希对象
    md5_hash = hashlib.md5()
    
    # 以二进制模式打开文件
    with open(file_path, "rb") as f:
        # 逐块读取文件内容并更新哈希对象
        for chunk in iter(lambda: f.read(4096), b""):
            md5_hash.update(chunk)
    
    # 返回十六进制格式的 MD5 哈希值
    return md5_hash.hexdigest()

# 添加新的函数用于检查缓存
def check_cached_files(md5_value, output_dir="/app/output"):
    """检查是否存在缓存的文件"""
    # MD5目录路径
    md5_dir = os.path.join(output_dir, md5_value)
    if not os.path.exists(md5_dir):
        print(f"[缓存] 未找到MD5目录: {md5_dir}")
        return None, None
        
    # auto目录路径
    auto_dir = os.path.join(md5_dir, "auto")
    if not os.path.exists(auto_dir):
        print(f"[缓存] 未找到auto目录: {auto_dir}")
        return None, None
        
    # 查找json文件
    json_files = [f for f in os.listdir(auto_dir) if f.endswith('_middle.json')]
    if not json_files:
        print(f"[缓存] 未找到json文件")
        return None, None
        
    # 使用找到的第一个json文件
    json_path = os.path.join(auto_dir, json_files[0])
    images_dir = os.path.join(auto_dir, "images")
    
    if os.path.exists(json_path) and os.path.exists(images_dir):
        print(f"[缓存] 找到缓存文件: {json_path}")
        return json_path, images_dir
        
    return None, None

# 修改 process_pdf 函数
# 修改 process_pdf 函数的定义
async def process_pdf(input_pdf_path, output_dir="/app/output", provider="ollama", api_key=None):
    """处理PDF文件：先检查缓存，如果没有缓存才执行推理
    Args:
        input_pdf_path: 输入PDF路径
        output_dir: 输出目录
        provider: 翻译服务提供商，可选值：ollama, tencent
        api_key: 腾讯云 API Key（当 provider 为 tencent 时必需）
    """
    total_start_time = time.time()
    start_time = time.time()
    
    # 计算 MD5 值
    folder_name = calculate_md5(input_pdf_path)
    print(f"[信息] PDF文件的MD5值: {folder_name}")
    
    # 获取PDF文件名（不包含扩展名）
    pdf_name = os.path.splitext(os.path.basename(input_pdf_path))[0]
    
    # 设置工作目录和输出路径
    work_dir = os.path.join(output_dir, folder_name, "auto")
    os.makedirs(work_dir, exist_ok=True)  # 确保工作目录存在
    
    # 设置输出PDF路径
    output_pdf_path = os.path.join(work_dir, f"{pdf_name}_rebuilt.pdf")
    print(f"[output_pdf_path]: {output_pdf_path}")
    # 检查缓存
    cached_json, cached_images = check_cached_files(folder_name, output_dir)
    
    if cached_json:
        print("[缓存] 使用已有的处理结果")
        create_pdf_from_json(cached_json, output_pdf_path, cached_images, provider=provider, api_key=api_key)
        print(f"[缓存] PDF重建完成: {output_pdf_path}")
        return output_pdf_path
    
    # 如果没有缓存，执行完整的处理流程
    print("[信息] 未发现缓存，开始完整处理流程")
    images_dir = os.path.join(work_dir, "images")
    os.makedirs(images_dir, exist_ok=True)
    
    # 设置文件写入器
    image_writer = FileBasedDataWriter(images_dir)
    md_writer = FileBasedDataWriter(work_dir)
    
    # 读取PDF文件
    reader = FileBasedDataReader("")
    pdf_bytes = reader.read(input_pdf_path)
    start_time = log_time(start_time, "读取PDF文件")
    
    # 创建数据集实例
    start_time = time.time()
    ds = PymuDocDataset(pdf_bytes)
    start_time = log_time(start_time, "创建数据集实例")
    
    # 推理处理
    start_time = time.time()
    is_ocr = ds.classify() == SupportedPdfParseMethod.OCR
    mode = "OCR" if is_ocr else "TXT"
    print(f"[信息] 使用{mode}模式处理")
    
    if is_ocr:
        infer_result = ds.apply(doc_analyze, ocr=True)
        pipe_result = infer_result.pipe_ocr_mode(image_writer)
    else:
        infer_result = ds.apply(doc_analyze, ocr=False)
        pipe_result = infer_result.pipe_txt_mode(image_writer)
    start_time = log_time(start_time, f"{mode}模式推理")
    
    # 生成中间JSON文件
    start_time = time.time()
    middle_json_path = os.path.join(work_dir, f"{pdf_name}_middle.json")
    pipe_result.dump_middle_json(md_writer, f"{pdf_name}_middle.json")
    start_time = log_time(start_time, "生成中间JSON文件")
    
    # 重建PDF
    start_time = time.time()
    output_pdf_path = os.path.join(work_dir, f"{pdf_name}_rebuilt.pdf")
    print(f"[信息] PDF输出路径: {os.path.abspath(output_pdf_path)}")
    create_pdf_from_json(middle_json_path, output_pdf_path, images_dir, provider=provider, api_key=api_key)
    log_time(start_time, "重建PDF文件")
    
    # 输出总耗时
    log_time(total_start_time, "总计")
    
    return output_pdf_path

def cleanup_old_directories(output_dir, max_dirs=10):
    """清理旧的输出目录，保留最新的 N 个目录"""
    try:
        # 获取所有子目录及其创建时间
        dirs = []
        for name in os.listdir(output_dir):
            dir_path = os.path.join(output_dir, name)
            if os.path.isdir(dir_path):
                # 获取目录的最后修改时间
                mtime = os.path.getmtime(dir_path)
                dirs.append((dir_path, mtime))
        
        # 按修改时间排序，最新的在后面
        dirs.sort(key=lambda x: x[1])
        
        # 如果目录数超过限制，删除最旧的目录
        while len(dirs) > max_dirs:
            old_dir = dirs.pop(0)[0]
            # 递归删除目录及其内容
            for root, subdirs, files in os.walk(old_dir, topdown=False):
                for name in files:
                    file_path = os.path.join(root, name)
                    os.unlink(file_path)
                    print(f"[清理] 删除旧文件: {file_path}")
                for name in subdirs:
                    dir_path = os.path.join(root, name)
                    os.rmdir(dir_path)
                    print(f"[清理] 删除旧目录: {dir_path}")
            os.rmdir(old_dir)
            print(f"[清理] 删除旧的MD5目录: {old_dir}")
            
    except Exception as e:
        print(f"[警告] 清理旧目录失败: {str(e)}")

# 修改 rebuild_pdf 函数中的清理部分
@app.post("/rebuild_pdf")
async def rebuild_pdf(
    file: UploadFile = File(...),
    provider: Optional[str] = "ollama",
    api_key: Optional[str] = None
):
    """
    接收PDF文件并返回重建后的PDF
    - provider: 翻译服务提供商，可选值：ollama, tencent
    - api_key: 腾讯云 API Key（当 provider 为 tencent 时必需）
    """
    temp_pdf_path = None
    try:
        # 创建临时文件保存上传的PDF
        with NamedTemporaryFile(delete=False, suffix='.pdf', dir="/app/input") as temp_pdf:
            content = await file.read()
            temp_pdf.write(content)
            temp_pdf_path = temp_pdf.name
            print(f"[信息] 临时文件路径: {temp_pdf_path}")

        # 处理PDF时传入翻译参数
        output_pdf_path = await process_pdf(temp_pdf_path, provider=provider, api_key=api_key)
        
        print(f"[信息] 准备返回PDF文件: {output_pdf_path}")
        
        # 确保输出文件存在
        if not os.path.exists(output_pdf_path):
            print(f"[错误] PDF文件不存在: {output_pdf_path}")
            return {"error": "PDF generation failed"}
            
        # 读取生成的PDF文件
        with open(output_pdf_path, 'rb') as pdf_file:
            pdf_content = pdf_file.read()
            print(f"[信息] PDF文件大小: {len(pdf_content)} 字节")

        # 返回处理后的PDF文件
        return Response(
            content=pdf_content,
            media_type="application/pdf",
            headers={
                'Content-Disposition': f'attachment; filename="{os.path.basename(output_pdf_path)}"'
            }
        )

    except Exception as e:
        print(f"[错误] 处理失败: {str(e)}")
        return {"error": str(e)}

    finally:
        # 清理临时文件
        try:
            # 删除临时PDF文件
            if temp_pdf_path and os.path.exists(temp_pdf_path):
                os.unlink(temp_pdf_path)
                print(f"[信息] 已删除临时文件: {temp_pdf_path}")
            
            # 清理旧目录，保留最新的10个
            output_dir = "/app/output"
            if os.path.exists(output_dir):
                cleanup_old_directories(output_dir, max_dirs=10)
                
        except Exception as e:
            print(f"[警告] 清理文件失败: {str(e)}")

# 添加查询接口
@app.get("/translations", response_model=TranslationResponse)
async def get_translations(
    page: int = Query(1, gt=0, description="页码"),
    page_size: int = Query(100, gt=0, le=1000, description="每页记录数"),
    is_confirmed: Optional[bool] = Query(None, description="是否已人工确认"),
    return_original: Optional[bool] = Query(None, description="是否返回原文"),
    sort_by: str = Query("time", description="排序方式: time(创建时间) 或 frequency(使用频率)")
):
    """
    查询翻译记录
    - page: 页码，从1开始
    - page_size: 每页记录数，最大100
    - is_confirmed: 是否已人工确认
    - return_original: 是否返回原文
    - sort_by: 排序方式，time(按时间) 或 frequency(按频率)
    """
    db = TranslationDB()
    result = db.get_translations(
        page=page,
        page_size=page_size,
        is_confirmed=is_confirmed,
        return_original=return_original,
        sort_by=sort_by
    )
    
    if result is None:
        return {"error": "查询失败"}
    
    return result


# 修改更新接口
@app.put("/translations/{id}")
async def update_translation(
    id: int,
    update_data: TranslationUpdate
):
    """
    更新翻译记录
    """
    # 根据 confirmed_translation 自动设置 is_confirmed
    if update_data.confirmed_translation:
        update_data.is_confirmed = True
    else:
        update_data.is_confirmed = False
    
    if update_data.return_original:
        update_data.is_confirmed = True

    db = TranslationDB()
    success = db.update_translation(
        id=id,
        confirmed_translation=update_data.confirmed_translation,
        is_confirmed=update_data.is_confirmed,
        return_original=update_data.return_original
    )
    
    if not success:
        return {"error": "更新失败"}
    
    return {"message": "更新成功"}

# 修改删除接口
@app.delete("/translations/{id}")
async def delete_translation(id: int):
    """
    删除翻译记录
    - id: 记录ID
    """
    db = TranslationDB()
    success = db.delete_translation(id)
    
    if not success:
        return {"error": "删除失败"}
    
    return {"message": "删除成功"}


# 添加新的翻译接口
@app.post("/translate")
async def translate(request: TranslateRequest):
    """
    翻译文本接口
    - text: 需要翻译的文本
    - model: 模型ID
    - provider: 服务提供商（可选）
    """
    try:
        # 调用翻译服务
        response = requests.post(
            "http://host.docker.internal:8081/api/translate",
            json={"text": request.text}
        )
        
        if response.status_code == 200:
            result = response.json()["translated_text"]
            print(f"[翻译] 原文: {request.text}")
            print(f"[翻译] 译文: {result}")
            
            # 保存翻译结果到数据库
            db = TranslationDB()
            db.add_translation(request.text, result)
            
            return {"translated_text": result}
            
        print(f"[警告] 翻译请求失败: {response.status_code}")
        return {"error": "翻译服务出错"}
        
    except Exception as e:
        print(f"[警告] 翻译失败: {str(e)}")
        return {"error": str(e)}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)