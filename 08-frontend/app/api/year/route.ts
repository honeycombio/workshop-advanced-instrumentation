import { NextResponse } from "next/server";
import { logger } from "@/instrumentation";

export async function GET() {
  const host = process.env.NEXT_PUBLIC_HOST || "localhost";
  try {
    console.log("Fetching year data");
    logger.info("Fetching year data");
    const response = await fetch(`http://${host}:6001/year`);
    if (!response.ok) {
      logger.error(`Error: ${response.statusText}`);
      throw new Error(`Error: ${response.statusText}`);
    }

    const data = await response.json();
    console.log(`Response: ${JSON.stringify(data, null, 2)}`);
    logger.debug(`Response: ${JSON.stringify(data, null, 2)}`);
    return NextResponse.json(data, { status: 200 });
  } catch (error) {
    logger.error("Failed to fetch data", { error });
    return NextResponse.json({ error: "Failed to fetch data" }, { status: 500 });
  }
}
