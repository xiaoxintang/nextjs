"use client";
import { Button } from "@/components/ui/button";
import { authClient } from "@/utils/authClient";
import { toast } from "sonner";

export default function Login() {
  return (
    <div>
      Login
      <Button
        onClick={async () => {
          await authClient.signOut();
        }}
      >
        登出
      </Button>
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
  );
}
