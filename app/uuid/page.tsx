"use client";

import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";

import { useRef } from "react";
import { toast } from "sonner";

export default function UUID() {
  const ref = useRef<HTMLInputElement>(null);
  return (
    <div>
      <Input ref={ref} />
      <Button
        onClick={() => {
          const uuid = crypto.randomUUID();
          ref.current!.value = uuid;
          toast("生成成功");
        }}
      >
        生成uuid
      </Button>
    </div>
  );
}
