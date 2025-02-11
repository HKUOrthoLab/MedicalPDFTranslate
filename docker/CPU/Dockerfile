# 使用 Ubuntu 作为基础镜像
FROM ubuntu:22.04

# 设置环境变量为非交互模式
ENV DEBIAN_FRONTEND=noninteractive

# 替换为阿里云镜像源
RUN sed -i 's/archive.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list && \
    sed -i 's/security.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list

# 安装系统依赖
RUN apt-get update && \
    apt-get install -y \
        software-properties-common \
        wget \
        git \
        libgl1 \
        libglib2.0-0 \
        libreoffice \
    && add-apt-repository ppa:deadsnakes/ppa \
    && apt-get update \
    && apt-get install -y \
        python3.10 \
        python3.10-venv \
        python3.10-distutils \
        python3-pip \
    && rm -rf /var/lib/apt/lists/*

# 设置 Python 3.10 为默认版本
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1 && \
    update-alternatives --install /usr/bin/python python /usr/bin/python3.10 1

# 设置工作目录
WORKDIR /app


# 创建必要的目录
RUN mkdir -p /app/input /app/output /app/.cache /root/.paddleocr /app/font /root/config

# 复制所需文件和目录
# COPY .cache/ /app/.cache/
# COPY .paddleocr/ /root/.paddleocr/
COPY config/magic-pdf.json /root/magic-pdf.json
COPY font/ /app/font/
COPY input/ /app/input/
# 复制 requirements.txt
COPY requirements.txt .
COPY MinerUApi.py rebuild_pdf.py pdf_process.py translation_db.py /app/

# 安装依赖
RUN pip3 install -r requirements.txt --extra-index-url https://wheels.myhloli.com -i https://mirrors.aliyun.com/pypi/simple --timeout 600 --retries 3

# 设置默认命令，运行 API 服务
CMD ["uvicorn", "pdf_process:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]
#ENTRYPOINT ["/bin/bash", "-c", "tail -f /dev/null"]