# syntax=docker.io/docker/dockerfile:1

FROM node:20-alpine AS base
RUN apk add --no-cache libc6-compat
WORKDIR /app

# 1. 安装依赖阶段（最大化缓存）
FROM base AS deps
COPY package.json pnpm-lock.yaml ./
COPY prisma ./prisma
COPY prisma.config.ts ./

RUN corepack enable pnpm && \
    corepack prepare pnpm@latest --activate && \
    pnpm i --frozen-lockfile

# 2. 构建阶段
FROM base AS builder
COPY --from=deps /app/node_modules ./node_modules
COPY package.json pnpm-lock.yaml next.config.* tsconfig.json ./
COPY prisma ./prisma
COPY prisma.config.ts ./
COPY . .

ENV NEXT_TELEMETRY_DISABLED=1

RUN corepack enable pnpm && \
    corepack prepare pnpm@latest --activate && \
    npx prisma generate && \
    pnpm run build

# 3. 生产运行阶段
FROM base AS runner
WORKDIR /app

ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1

# 创建非 root 用户
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

# 复制构建产物
COPY --from=builder /app/public ./public
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static
COPY --from=builder --chown=nextjs:nodejs /app/prisma ./prisma

# 在切换用户之前创建 entrypoint 脚本
RUN echo '#!/bin/sh' > /entrypoint.sh && \
    echo 'set -e' >> /entrypoint.sh && \
    echo 'echo "Applying database migrations..."' >> /entrypoint.sh && \
    echo 'DATABASE_URL=${DATABASE_URL} npx prisma migrate deploy' >> /entrypoint.sh && \
    echo 'echo "Starting Next.js application..."' >> /entrypoint.sh && \
    echo 'exec node server.js' >> /entrypoint.sh && \
    chmod +x /entrypoint.sh && \
    chown nextjs:nodejs /entrypoint.sh

# 现在才切换到非 root 用户
USER nextjs

EXPOSE 3000
ENV PORT=3000
ENV HOSTNAME="0.0.0.0"

CMD ["/entrypoint.sh"]