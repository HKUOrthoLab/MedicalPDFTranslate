# template_loader.py
import json
import os
import logging
from table_template import TableTemplate

logger = logging.getLogger(__name__)

def load_templates(config_path):
    """从配置文件加载表格模板"""
    try:
        with open(config_path, 'r', encoding='utf-8') as f:
            config = json.load(f)
        
        templates = {}
        for template_name, template_data in config.get('templates', {}).items():
            template = TableTemplate(
                template_data.get('name', ''),
                template_data.get('identifier_text', '')
            )
            
            # 添加结构
            for cell in template_data.get('structure', []):
                template.add_cell(
                    cell.get('row', 0),
                    cell.get('col', 0),
                    cell.get('rowspan', 1),
                    cell.get('colspan', 1),
                    cell.get('content_key', None)
                )
            
            templates[template_name] = template
            logger.info(f"已加载模板: {template_name}")
        
        return templates
    except Exception as e:
        logger.error(f"加载模板配置失败: {str(e)}")
        return {}

def get_template_by_name(templates, name):
    """根据名称获取模板"""
    return templates.get(name)

def get_matching_template(templates, table_text):
    """查找匹配的模板"""
    # 首先检查是否包含标准识别文本
    for template in templates.values():
        if template.match_table(table_text):
            logger.info(f"通过标识符匹配到模板: {template.name}")
            return template
    
    # 如果没有直接匹配，检查健康评估表的特征
    health_assessment_indicators = ["PHQ-2", "ESS", "IPSS", "尿失禁评估", "AMT", "体温", "身高", "体重", "BMI", "腰围", "血压", "脉搏", "视力"]
    matched_indicators = [indicator for indicator in health_assessment_indicators if indicator in table_text]
    
    # 如果匹配到至少3个健康评估表特征，认为是健康评估表
    if len(matched_indicators) >= 3:
        logger.info(f"通过内容特征识别为健康评估表，匹配项: {', '.join(matched_indicators)}")
        for template in templates.values():
            if template.name == "健康评估表":
                return template
    
    logger.warning("未能匹配到任何模板")
    return None