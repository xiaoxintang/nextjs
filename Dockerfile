# syntax=docker.io/docker/dockerfile:1

FROM node:20-alpine AS base

# Install dependencies only when needed
FROM base AS deps
RUN apk add --no-cache libc6-compat
WORKDIR /app

# 先复制 package.json 和 prisma 目录（关键！）
COPY package.json yarn.lock* package-lock.json* pnpm-lock.yaml* pnpm-workspace.yaml* .npmrc* ./
COPY prisma ./prisma/   # <--- 新增这一行，确保 prisma generate 能找到 schema.prisma

RUN \
  if [ -f yarn.lock ]; then yarn --frozen-lockfile; \
  elif [ -f package-lock.json ]; then npm ci; \
  elif [ -f pnpm-lock.yaml ]; then corepack enable pnpm && pnpm i --frozen-lockfile; \
  else echo "Lockfile not found." && exit 1; \
  fi


# Rebuild the source code only when needed
FROM base AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .

# 禁用 telemetry（可选）
ENV NEXT_TELEMETRY_DISABLED=1

RUN \
  if [ -f yarn.lock ]; then yarn run build; \
  elif [ -f package-lock.json ]; then npm run build; \
  elif [ -f pnpm-lock.yaml ]; then corepack enable pnpm && pnpm run build; \
  else echo "Lockfile not found." && exit 1; \
  fi


# Production image
FROM base AS runner
WORKDIR /app

ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

# 复制 standalone 输出和 static 文件
COPY --from=builder /app/public ./public
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

# 关键：复制 prisma 目录到 runtime，用于运行时执行 migrate deploy
COPY --from=builder /app/prisma ./prisma

# 创建启动脚本（推荐方式）
RUN echo '#!/bin/sh' > /entrypoint.sh && \
    echo 'set -e' >> /entrypoint.sh && \
    echo 'echo "Applying database migrations..."' >> /entrypoint.sh && \
    echo 'npx prisma migrate deploy' >> /entrypoint.sh && \
    echo 'echo "Starting Next.js application..."' >> /entrypoint.sh && \
    echo 'exec node server.js' >> /entrypoint.sh && \
    chmod +x /entrypoint.sh

USER nextjs

EXPOSE 3000
ENV PORT=3000
ENV HOSTNAME="0.0.0.0"

# 使用 entrypoint 脚本启动
CMD ["/entrypoint.sh"]