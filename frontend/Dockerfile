# 第一阶段：构建前端
FROM node:18-slim AS frontend-builder

WORKDIR /app/frontend

# 安装必要的系统依赖
RUN apt-get update && apt-get install -y \
    python3 \
    make \
    g++ \
    && rm -rf /var/lib/apt/lists/*

# 复制前端依赖文件
COPY ./package*.json ./

# 安装前端依赖（使用完整安装，包括devDependencies）
RUN npm ci

# 复制前端源代码
COPY . .

# 构建前端
RUN npm run build

# 暴露端口
EXPOSE 3000

CMD npm run dev