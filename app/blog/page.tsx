import { auth } from "@/utils/auth";
import { headers } from "next/headers";

export default async function Blog() {
  const session = await auth.api.getSession({
    headers: await headers(), // you need to pass the headers object.
  });
  console.log("session==>", session);
  return <div>{session ? "已登录" : "未登录"}</div>;
}
