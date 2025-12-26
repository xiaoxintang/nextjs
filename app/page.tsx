import Image from "next/image";
import axios from "axios";
import Link from "next/link";

export default async function Home() {
  const res = await axios.get(
    "https://shop-test.dianplus.cn/rs/ent/account/get_account_page.do",
    {
      params: {
        mobilePhone: "15707971810",
        entId: "10080",
      },
      headers: {
        Cookie: "JSESSIONID=YzUwZTMxNTgtM2E5ZC00MTM5LTlkZGEtMGM2ZmJkMDUwM2Jl",
      },
    }
  );

  return (
    <div>
      <Link href="/uuid">uuid</Link>
      <Link href="/login">登录</Link>
      <Link href="/blog">博客</Link>
    </div>
  );
}
