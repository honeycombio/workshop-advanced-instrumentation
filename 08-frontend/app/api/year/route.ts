import { NextResponse } from "next/server";

export async function GET() {
  const host = process.env.NEXT_PUBLIC_HOST || "localhost";
  try {
    console.log("Fetching year data");
    const response = await fetch(`http://${host}:6001/year`);
    console.log(`Response: ${response}`);
    if (!response.ok) {
      throw new Error(`Error: ${response.statusText}`);
    }

    const data = await response.json();
    return NextResponse.json(data, { status: 200 });
  } catch (error) {
    return NextResponse.json({ error: "Failed to fetch data" }, { status: 500 });
  }
}
