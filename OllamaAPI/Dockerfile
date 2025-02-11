FROM python:3.11-alpine
WORKDIR /app

# 安装依赖
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 复制应用代码
COPY OllamaApiBackend.py .

# 暴露端口
EXPOSE 8000

# 启动应用
# 使用 uvicorn 启动应用
CMD ["uvicorn", "OllamaApiBackend:app", "--host", "0.0.0.0", "--port", "8000"]