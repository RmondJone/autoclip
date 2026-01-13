# AutoClip Dockerfile
# 多阶段构建，优化镜像大小
# 第二阶段：构建后端
FROM python:3.9-slim AS backend-builder

# 设置环境变量
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1
ENV PIP_NO_CACHE_DIR=1
ENV PIP_DISABLE_PIP_VERSION_CHECK=1

WORKDIR /app

# 安装系统依赖
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    ffmpeg \
    && rm -rf /var/lib/apt/lists/*

# 复制Python依赖文件
COPY requirements.txt ./

# 安装Python依赖
RUN pip install --no-cache-dir -r requirements.txt

# 第三阶段：最终镜像
FROM python:3.9-slim

# 设置环境变量
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONPATH=/app

# 创建非root用户
RUN groupadd -r autoclip && useradd -r -g autoclip autoclip

# 安装运行时依赖
RUN apt-get update && apt-get install -y \
    ffmpeg \
    curl \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# 设置工作目录
WORKDIR /app

# 从构建阶段复制文件
COPY --from=backend-builder /usr/local/lib/python3.9/site-packages /usr/local/lib/python3.9/site-packages
COPY --from=backend-builder /usr/local/bin /usr/local/bin

# 复制项目文件
COPY backend/ ./backend/
COPY scripts/ ./scripts/
COPY *.sh ./
#COPY docker-entrypoint.sh ./
COPY env.example .env

# 创建必要的目录
RUN mkdir -p data/projects data/uploads data/temp data/output logs

# 设置权限
RUN chown -R autoclip:autoclip /app
RUN chmod +x *.sh
RUN chmod +x ./scripts/docker-entrypoint.sh
RUN chmod -R 755 data logs

# 暴露端口
EXPOSE 8000

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/api/v1/health/ || exit 1

# 启动命令
ENTRYPOINT ["./scripts/docker-entrypoint.sh"]
