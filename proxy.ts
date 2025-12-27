// middleware.ts (Next.js App Router)
import { NextResponse } from "next/server";
import type { NextRequest } from "next/server";
import { auth } from "@/utils/auth"; // 你的 Better Auth 实例


export const config = {
  matcher: [
    // 匹配所有 /api/*，但排除 /api/auth/*
    "/api/((?!auth).*)",
    // 如果你还想保护页面路由（如 /dashboard/:path*），可以额外添加
    // "/dashboard/:path*",
  ],
};
export default async function proxy(request: NextRequest) {
    const session = await auth.api.getSession({
        headers: request.headers,
    });

    if (!session) {
        return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
        // 或对于页面路由：return NextResponse.redirect(new URL("/sign-in", request.url));
    }

    return NextResponse.next();
}
