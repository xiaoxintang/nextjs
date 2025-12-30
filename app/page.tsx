import Link from "next/link";
import { Separator } from "@/components/ui/separator";

export default async function Home() {
  return (
    <div>
      <div className="flex items-center h-5 gap-2">
        <Link href="/uuid">uuid</Link>
        <Separator orientation="vertical" />
        <Link href="/login">登录</Link>
        <Separator orientation="vertical" />
        <Link href="/blog">博客</Link>
      </div>
    </div>
  );
}
