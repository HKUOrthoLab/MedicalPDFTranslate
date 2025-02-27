import json
import os
from reportlab.pdfgen import canvas
from reportlab.lib.pagesizes import A4
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from PIL import Image
from reportlab.pdfbase.cidfonts import UnicodeCIDFont
from reportlab.lib.utils import ImageReader
from bs4 import BeautifulSoup
import html
import requests

# 注册中文字体
DEFAULT_FONT = 'SourceHanSerifCN-Regular'  # 首选字体
FALLBACK_FONT = 'STSong-Light'        # 备选字体

pdfmetrics.registerFont(TTFont(DEFAULT_FONT, './font/SourceHanSerifCN-Regular.ttf', subfontIndex=1, )) #本地调试
#pdfmetrics.registerFont(TTFont(DEFAULT_FONT, '/app/font/SourceHanSerifCN-Regular.ttf', subfontIndex=1, )) #docker 里边运行
pdfmetrics.registerFont(UnicodeCIDFont(FALLBACK_FONT))

def set_font(c, font_size):
    """统一处理字体设置，优先使用 DEFAULT_FONT，如果失败则使用 FALLBACK_FONT"""
    try:
        c.setFont(DEFAULT_FONT, font_size)
    except:
        c.setFont(FALLBACK_FONT, font_size)

def calculate_font_size(text, bbox, c, base_font_size=10):
    x1, y1, x2, y2 = bbox
    available_width = x2 - x1
    
    # 从基础字体大小开始测试
    font_size = base_font_size
    set_font(c, font_size)
    text_width = c.stringWidth(text)
    
    # 如果文本宽度超过可用宽度，逐步减小字体大小
    while text_width > available_width and font_size > 1:
        font_size -= 0.5
        set_font(c, font_size)
        text_width = c.stringWidth(text)
    
    return font_size

def clean_text_content(text):
    # 处理文本内容，确保空格正确显示
    # 将多个连续空格替换为单个空格
    text = ' '.join(text.split())
    # 处理特殊字符
    text = text.replace('\u3000', ' ')  # 处理全角空格
    text = text.encode('utf-8').decode('utf-8')  # 确保编码正确
    return text



# 添加翻译函数
def is_chinese(char):
    """判断字符是否是中文"""
    return '\u4e00' <= char <= '\u9fff'

def is_english_or_number(text):
    """判断文本是否只包含英文或数字"""
    # 移除空格、标点符号等
    import re
    text = re.sub(r'[.,\-°%\s]', '', text)
    if not text:  # 如果移除后为空，返回True
        return True
    # 检查剩余字符是否都是英文字母或数字
    return all(c.isascii() and (c.isalnum() or c in '/-_.') for c in text)

def has_chinese(text):
    """判断文本是否包含中文"""
    return any(is_chinese(char) for char in text)

# 在文件开头添加导入
from translation_db import TranslationDB

# 创建数据库实例
db = TranslationDB()

def translate_text(text, provider="ollama", api_key=None):
    """调用翻译服务"""
    # 如果是空文本，直接返回
    if not text.strip():
        return text
        
    # 如果只包含英文或数字，直接返回
    if is_english_or_number(text):
        print(f"[跳过] 纯英文或数字: {text}")
        return text
        
    # 如果不包含中文，直接返回
    if not has_chinese(text):
        print(f"[跳过] 不包含中文: {text}")
        return text
        
    # 查询已确认的翻译
    cached_translation = db.get_translation(text)
    if cached_translation:
        print(f"[缓存] 原文: {text}")
        print(f"[缓存] 译文: {cached_translation}")
        return cached_translation
        
    print(f"[翻译] 原文: {text}")
    try:
        response = requests.post(
            "http://host.docker.internal:8081/api/translate",
            json={
                "text": text,
                "provider": provider,
                "api_key": api_key
            }
        )
        if response.status_code == 200:
            result = response.json()["translated_text"]
            print(f"[翻译] 译文: {result}")
            # 保存翻译结果
            db.add_translation(text, result)
            return result
        print(f"[警告] 翻译请求失败: {response.status_code}")
        return text
    except Exception as e:
        print(f"[警告] 翻译失败: {str(e)}")
        return text

def get_table_dimensions(table_html):
    """计算表格的实际维度"""
    soup = BeautifulSoup(table_html, 'html.parser')
    rows = soup.find_all('tr')
    
    # 计算最大列数
    max_cols = 0
    for row in rows:
        cols = 0
        for cell in row.find_all(['td', 'th']):
            colspan = int(cell.get('colspan', 1))
            cols += colspan
        max_cols = max(max_cols, cols)
    
    return len(rows), max_cols

def create_empty_table(rows, cols):
    """创建一个空的表格矩阵"""
    return [[None for _ in range(cols)] for _ in range(rows)]

def fill_table_matrix(table_html):
    """填充表格矩阵，处理合并单元格，返回实际内容的矩阵"""
    soup = BeautifulSoup(html.unescape(table_html), 'html.parser')
    n_rows, n_cols = get_table_dimensions(table_html)
    matrix = create_empty_table(n_rows, n_cols)
    cell_positions = {}  # Track original positions of cells with content
    
    # Create a matrix to track cell occupancy
    occupied = set()
    
    # First pass: map cells to their positions
    rows = soup.find_all('tr')
    for i, row in enumerate(rows):
        col_idx = 0
        for cell in row.find_all(['td', 'th']):
            # Skip positions that are already occupied
            while (i, col_idx) in occupied:
                col_idx += 1
                
            # Get rowspan and colspan
            colspan = int(cell.get('colspan', 1))
            rowspan = int(cell.get('rowspan', 1))
            content = cell.text.strip()
            
            # Mark all positions this cell covers
            for r in range(i, i + rowspan):
                for c in range(col_idx, col_idx + colspan):
                    if r < n_rows and c < n_cols:
                        matrix[r][c] = content
                        occupied.add((r, c))
                        # Only store position for the top-left cell
                        if r == i and c == col_idx:
                            cell_positions[(r, c)] = (rowspan, colspan)
            
            col_idx += colspan
    
    # For cells that are merged, replicate content in all positions
    for (r, c), (rowspan, colspan) in cell_positions.items():
        if rowspan > 1 or colspan > 1:
            content = matrix[r][c]
            for dr in range(rowspan):
                for dc in range(colspan):
                    if r + dr < n_rows and c + dc < n_cols:
                        matrix[r + dr][c + dc] = content
    
    return matrix, cell_positions

def get_merged_cells(table_html):
    """获取合并单元格的信息，更准确地处理所有合并单元格"""
    soup = BeautifulSoup(html.unescape(table_html), 'html.parser')
    merged_cells = []
    cell_matrix = []
    
    # First pass: create a matrix to track all cell positions
    rows = soup.find_all('tr')
    for i, row in enumerate(rows):
        if i >= len(cell_matrix):
            cell_matrix.append([None] * 100)  # Large enough for any table
        
        j = 0
        for cell in row.find_all(['td', 'th']):
            # Skip positions that are already occupied by rowspan cells
            while j < len(cell_matrix[i]) and cell_matrix[i][j] is not None:
                j += 1
                
            colspan = int(cell.get('colspan', 1))
            rowspan = int(cell.get('rowspan', 1))
            
            # Mark the cell's coverage in the matrix
            for di in range(rowspan):
                if i + di >= len(cell_matrix):
                    cell_matrix.append([None] * 100)
                for dj in range(colspan):
                    cell_matrix[i + di][j + dj] = (i, j, rowspan, colspan)
            
            # Record merged cells
            if rowspan > 1 or colspan > 1:
                merged_cells.append((i, i + rowspan, j, j + colspan))
                
            j += colspan
    
    return merged_cells

def should_draw_line(i, j, direction, merged_cells):
    """判断是否应该绘制边框线
    direction: 'horizontal' or 'vertical'
    """
    for start_row, end_row, start_col, end_col in merged_cells:
        if direction == 'horizontal':
            # Check if this horizontal line is inside a merged cell
            if start_row < i < end_row and start_col <= j < end_col:
                return False
        else:  # vertical
            # Check if this vertical line is inside a merged cell
            if start_row <= i < end_row and start_col < j < end_col:
                return False
    return True

def create_pdf_from_json(json_path, output_path, images_dir, provider="ollama", api_key=None):
    """从JSON文件创建PDF
    Args:
        json_path: JSON文件路径
        output_path: 输出PDF路径
        image_dir: 图片目录
        provider: 翻译服务提供商，可选值：ollama, tencent
        api_key: 腾讯云 API Key（当 provider 为 tencent 时必需）
    """
    # 读取 JSON 文件
    with open(json_path, 'r', encoding='utf-8') as f:
        data = json.load(f)

    # 创建 PDF 文件
    c = canvas.Canvas(output_path, pagesize=A4)  # 这里使用 output_path 而不是 output_pdf_path
    
    # 遍历每一页
    for page_info in data['pdf_info']:
        # 设置默认字体和编码
        set_font(c, 10)
        
        # 获取页面尺寸
        page_width, page_height = page_info.get('page_size', [595.0, 842.0])
        
        # 处理段落块
        if 'para_blocks' in page_info:
            for block in page_info['para_blocks']:
                if block['type'] in ['text', 'title', 'list']:  # 添加更多类型的支持
                    for line in block['lines']:
                        for span in line['spans']:
                            if span['type'] == 'text':
                                text = clean_text_content(span['content'])
                                # 调用翻译服务
                                translated_text = translate_text(text)
                                x1, y1, x2, y2 = span['bbox']
                                y = page_height - y1
                                
                                # 根据不同类型设置不同的基础字体大小
                                base_size = 10
                                if block['type'] == 'title':
                                    if 'level' in block and block['level'] == 2:
                                        base_size = 14
                                    elif 'level' in block and block['level'] == 3:
                                        base_size = 12
                                font_size = calculate_font_size(translated_text, span['bbox'], c, base_font_size=base_size)
                                set_font(c, font_size)
                                c.drawString(x1, y, translated_text)
                
        
        # 处理 images 部分的图片
        if 'images' in page_info:
            for image_block in page_info['images']:
                if image_block['type'] == 'image':
                    for block in image_block['blocks']:
                        if block['type'] == 'image_body':
                            for line in block['lines']:
                                for span in line['spans']:
                                    if span['type'] == 'image':
                                        # 获取图片路径和位置信息
                                        image_path = os.path.join(images_dir, span['image_path'])
                                        if os.path.exists(image_path):
                                            # 获取 bbox 坐标
                                            x1, y1, x2, y2 = span['bbox']
                                            bbox_width = x2 - x1
                                            bbox_height = y2 - y1
                                            
                                            # 读取原始图片并获取尺寸
                                            img = Image.open(image_path)
                                            img_width, img_height = img.size
                                            
                                            # 计算缩放比例
                                            width_ratio = bbox_width / img_width
                                            height_ratio = bbox_height / img_height
                                            # 使用较小的缩放比例，确保图片完全适应 bbox
                                            scale = min(width_ratio, height_ratio)
                                            
                                            # 计算缩放后的尺寸
                                            new_width = img_width * scale
                                            new_height = img_height * scale
                                            
                                            # 计算居中位置
                                            x_offset = x1 + (bbox_width - new_width) / 2
                                            y_offset = page_height - y2 + (bbox_height - new_height) / 2
                                            
                                            # 绘制图片
                                            c.drawImage(image_path, x_offset, y_offset, new_width, new_height)

        # 处理表格
        if 'tables' in page_info:
            for table in page_info['tables']:
                # 处理表格标题
                for block in table['blocks']:
                    if block['type'] == 'table_body':
                        for line in block['lines']:
                            for span in line['spans']:
                                # 在处理表格的代码部分替换为:
                                if span['type'] == 'table' and 'html' in span:
                                    # 解析HTML表格
                                    table_html = html.unescape(span['html'])
                                    table_matrix, cell_positions = fill_table_matrix(table_html)
                                    merged_cells = get_merged_cells(table_html)
                                    x_start, y_start, x_end, y_end = span['bbox']
                                    
                                    # 确保表格不超出页面边界
                                    x_start = max(0, x_start)
                                    x_end = min(page_width, x_end)
                                    y_start = max(0, y_start)
                                    y_end = min(page_height, y_end)
                                    
                                    # 计算单元格尺寸
                                    n_rows = len(table_matrix)
                                    n_cols = len(table_matrix[0]) if table_matrix else 0
                                    cell_width = (x_end - x_start) / n_cols if n_cols > 0 else 0
                                    row_height = min((y_end - y_start) / n_rows, 20) if n_rows > 0 else 0
                                    
                                    # 绘制表格线和内容
                                    c.setStrokeColorRGB(0, 0, 0)
                                    c.setLineWidth(0.5)
                                    
                                    # 绘制横线
                                    for i in range(n_rows + 1):
                                        y = page_height - (y_start + i * row_height)
                                        if 0 <= y <= page_height:
                                            for j in range(n_cols):
                                                if should_draw_line(i, j, 'horizontal', merged_cells):
                                                    x1 = x_start + j * cell_width
                                                    x2 = x_start + (j + 1) * cell_width
                                                    c.line(x1, y, x2, y)
                                    
                                    # 绘制竖线
                                    for j in range(n_cols + 1):
                                        x = x_start + j * cell_width
                                        if 0 <= x <= page_width:
                                            for i in range(n_rows):
                                                if should_draw_line(i, j, 'vertical', merged_cells):
                                                    y1 = page_height - (y_start + i * row_height)
                                                    y2 = page_height - (y_start + (i + 1) * row_height)
                                                    c.line(x, y1, x, y2)
                                    
                                    # 绘制单元格内容
                                    for i in range(n_rows):
                                        for j in range(n_cols):
                                            content = table_matrix[i][j]
                                            if content and (i, j) in cell_positions:
                                                # 这是一个合并单元格的起始位置
                                                rowspan, colspan = cell_positions[(i, j)]
                                                # 计算合并单元格的中心位置
                                                merged_width = colspan * cell_width
                                                merged_height = rowspan * row_height
                                                x = x_start + j * cell_width + 2
                                                y = page_height - (y_start + (i + rowspan/2) * row_height)
                                                
                                                # 计算合并单元格的bbox
                                                cell_bbox = [
                                                    x,
                                                    page_height - (y_start + (i + rowspan) * row_height),
                                                    x_start + (j + colspan) * cell_width - 4,
                                                    page_height - (y_start + i * row_height)
                                                ]
                                                
                                                # 翻译内容
                                                translated_content = translate_text(content)
                                                
                                                # 计算并设置字体大小
                                                font_size = calculate_font_size(translated_content, cell_bbox, c, base_font_size=8)
                                                set_font(c, font_size)
                                                
                                                # 只在合并单元格的第一个位置绘制内容
                                                c.drawString(x, y, translated_content)
                                            elif content and (i, j) not in cell_positions:
                                                # 普通单元格或者是合并单元格的非起始位置
                                                # 检查是否已经处理过（作为合并单元格一部分）
                                                is_part_of_merged = False
                                                for (start_i, start_j), (rowspan, colspan) in cell_positions.items():
                                                    if start_i <= i < start_i + rowspan and start_j <= j < start_j + colspan:
                                                        is_part_of_merged = True
                                                        break
                                                
                                                if not is_part_of_merged:
                                                    # 普通单元格，直接绘制内容
                                                    x = x_start + j * cell_width + 2
                                                    y = page_height - (y_start + (i + 0.7) * row_height)
                                                    
                                                    # 计算单元格的bbox
                                                    cell_bbox = [
                                                        x,
                                                        page_height - (y_start + (i + 1) * row_height),
                                                        x + cell_width - 4,
                                                        page_height - (y_start + i * row_height)
                                                    ]
                                                    
                                                    # 翻译内容
                                                    translated_content = translate_text(content)
                                                    
                                                    # 计算并设置字体大小
                                                    font_size = calculate_font_size(translated_content, cell_bbox, c, base_font_size=6)
                                                    set_font(c, font_size)
                                                    c.drawString(x, y, translated_content)


                    # 处理表格标题
                    elif block['type'] == 'table_caption':
                        for line in block['lines']:
                            for span in line['spans']:
                                if span['type'] == 'text':
                                    x, y, _, _ = span['bbox']
                                    y = page_height - y
                                    c.drawString(x, y, span['content'])

                    # 处理表格脚注
                    elif block['type'] == 'table_footnote':
                        for line in block['lines']:
                            for span in line['spans']:
                                if span['type'] == 'text':
                                    x, y, _, _ = span['bbox']
                                    y = page_height - y
                                    c.drawString(x, y, span['content'])

        # 处理 discarded_blocks
        if 'discarded_blocks' in page_info:
            for block in page_info['discarded_blocks']:
                if 'lines' in block:
                    for line in block['lines']:
                        for span in line['spans']:
                            if span['type'] == 'text':
                                text = clean_text_content(span['content'])
                                # 调用翻译服务
                                translated_text = translate_text(text)
                                x1, y1, x2, y2 = span['bbox']
                                y = page_height - y1
                                
                                font_size = calculate_font_size(translated_text, span['bbox'], c, base_font_size=6)
                                set_font(c, font_size)
                                c.drawString(x1, y, translated_text)


        # 结束当前页
        c.showPage()

    # 保存 PDF
    c.save()

if __name__ == '__main__':
    # 设置路径
    json_path = './output/ef5472cf29d5102d6209ce9c98fb2dab/auto/page5_middle.json'
    output_pdf_path = './output/ef5472cf29d5102d6209ce9c98fb2dab/auto/page5_rebuild.pdf'
    images_dir = './output/ef5472cf29d5102d6209ce9c98fb2dab/auto/images'

    # 创建 PDF
    create_pdf_from_json(json_path, output_pdf_path, images_dir)