# syntax=docker.io/docker/dockerfile:1

FROM node:20-alpine AS base
RUN apk add --no-cache libc6-compat
WORKDIR /app

# 1. 安装依赖阶段（最大化缓存）
FROM base AS deps
# 只复制包管理 + prisma 文件
COPY package.json pnpm-lock.yaml ./
COPY prisma ./prisma
COPY prisma.config.ts ./  # 如果有的话

RUN corepack enable pnpm && \
    corepack prepare pnpm@latest --activate && \
    pnpm i --frozen-lockfile

# 2. 构建阶段
FROM base AS builder
COPY --from=deps /app/node_modules ./node_modules
# 先复制必要配置
COPY package.json pnpm-lock.yaml next.config.js tsconfig.json ./
COPY prisma ./prisma
COPY prisma.config.ts ./  # 如果有
# 再复制源码
COPY . .

ENV NEXT_TELEMETRY_DISABLED=1

# 生成 Prisma Client + 构建
RUN corepack enable pnpm && \
    corepack prepare pnpm@latest --activate && \
    npx prisma generate && \
    pnpm run build

# 3. 生产运行阶段
FROM base AS runner
WORKDIR /app

ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1

# 创建用户
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

# 复制文件
COPY --from=builder /app/public ./public
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static
COPY --from=builder --chown=nextjs:nodejs /app/prisma ./prisma

USER nextjs

EXPOSE 3000
ENV PORT=3000
ENV HOSTNAME="0.0.0.0"

# 入口脚本（带 migrate）
RUN echo '#!/bin/sh' > /entrypoint.sh && \
    echo 'set -e' >> /entrypoint.sh && \
    echo 'echo "Applying database migrations..."' >> /entrypoint.sh && \
    echo 'npx prisma migrate deploy' >> /entrypoint.sh && \
    echo 'echo "Starting Next.js application..."' >> /entrypoint.sh && \
    echo 'exec node server.js' >> /entrypoint.sh && \
    chmod +x /entrypoint.sh

CMD ["/entrypoint.sh"]