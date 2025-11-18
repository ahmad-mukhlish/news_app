import { NextRequest, NextResponse } from "next/server";
import { mkdir, writeFile } from "fs/promises";
import path from "path";

const ICON_RELATIVE_DIR = "../assets/icon";
const ICON_FILENAME = "icon.png";

function validatePng(buffer: Buffer): void {
  const signature = Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]);
  if (buffer.length < signature.length || !buffer.slice(0, 8).equals(signature)) {
    throw new Error("Icon must be a PNG file");
  }
}

export async function POST(request: NextRequest) {
  try {
    const formData = await request.formData();
    const file = formData.get("icon");

    if (!(file instanceof File)) {
      return NextResponse.json({ success: false, error: "Missing icon file" }, { status: 400 });
    }

    const arrayBuffer = await file.arrayBuffer();
    const buffer = Buffer.from(arrayBuffer);
    validatePng(buffer);

    const nextRoot = process.cwd();
    const iconDir = path.resolve(nextRoot, ICON_RELATIVE_DIR);
    await mkdir(iconDir, { recursive: true });
    const targetPath = path.join(iconDir, ICON_FILENAME);
    await writeFile(targetPath, buffer);

    const base64 = buffer.toString("base64");
    const mimeType = file.type || "image/png";
    const previewDataUrl = `data:${mimeType};base64,${base64}`;

    return NextResponse.json({
      success: true,
      iconPath: targetPath,
      previewDataUrl,
    });
  } catch (error) {
    console.error("Icon upload failed", error);
    return NextResponse.json(
      { success: false, error: error instanceof Error ? error.message : "Failed to upload icon" },
      { status: 400 },
    );
  }
}
