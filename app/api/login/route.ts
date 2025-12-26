import { NextResponse } from "next/server";

export const POST = async (req: Request) => {
  return NextResponse.json({ message: "Hello" });
};

export const GET = async (req: Request) => {
  return NextResponse.json({ message: "Hello" });
};
