# 使用官方的 Go 语言镜像作为构建环境
FROM golang:1.22-alpine AS builder

# 设置工作目录
WORKDIR /app

# 复制 go.mod 和 go.sum 文件，并下载依赖项
# 这样可以利用 Docker 的层缓存，只有在依赖变化时才重新下载
COPY go.mod go.sum ./
RUN go mod download

# 复制所有源代码到工作目录
COPY . .

# 编译 Go 应用。
# -o claude2api 指定输出的可执行文件名
# CGO_ENABLED=0 和 -ldflags="-s -w" 是为了生成一个更小的静态可执行文件
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o claude2api .


# --- 创建最终的运行环境 ---
# 使用一个非常小的基础镜像来减小最终镜像的体积
FROM alpine:latest

# 设置工作目录
WORKDIR /app

# 从构建环境中复制编译好的可执行文件
COPY --from=builder /app/claude2api .

# 暴露 Hugging Face Spaces 默认的端口 7860
EXPOSE 7860

# 设置容器启动时要执行的命令
# 1. 设置 GIN_MODE 为 release 模式
# 2. 设置 ADDRESS 让服务监听在所有网络接口的 7860 端口上
# 3. 运行应用
CMD sh -c 'export GIN_MODE=release && export ADDRESS="0.0.0.0:7860" && ./claude2api'
