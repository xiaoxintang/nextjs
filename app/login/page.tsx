"use client";
import { Button } from "@/components/ui/button";
import { Separator } from "@/components/ui/separator";
import { authClient } from "@/utils/authClient";
import { toast } from "sonner";

export default function Login() {
  return (
    <div>
      <div className="flex items-center h-5 gap-2">
        <Button
          onClick={async () => {
            await authClient.signOut();
          }}
        >
          登出
        </Button>
        <Separator orientation="vertical" />
        <Button
          onClick={async () => {
            const res = await authClient.signUp.email({
              name: "longan",
              email: "longan@163.com",
              password: "xxt123456",
            });
            if (res.error) {
              toast(res.error.message);
            }
            console.log("sign up ==>", res);
          }}
        >
          注册
        </Button>
        <Separator orientation="vertical" />
        <Button
          onClick={async () => {
            const res = await authClient.signIn.email({
              email: "longan@163.com",
              password: "xxt123456",
            });
            console.log("sign ==>", res);
          }}
        >
          登录
        </Button>
        <Separator orientation="vertical" />
        <Button
          onClick={async () => {
            const res = await authClient.signIn.username({
              username: "xiaoxt",
              password: "xxt123456",
            });
            console.log("sign ==>", res);
          }}
        >
          username登录
        </Button>
      </div>
    </div>
  );
}
