import { NextResponse } from "next/server";
import { readFile } from "fs/promises";
import path from "path";

const RELATIVE_ENV_PATH = "../.env";

type EnvValues = Record<string, string>;

function parseEnv(content: string): EnvValues {
  const values: EnvValues = {};
  const lines = content.split(/\r?\n/);

  for (const rawLine of lines) {
    const line = rawLine.trim();
    if (!line || line.startsWith("#")) {
      continue;
    }

    const equalsIndex = line.indexOf("=");
    if (equalsIndex === -1) {
      continue;
    }

    const key = line.slice(0, equalsIndex).trim();
    let value = line.slice(equalsIndex + 1).trim();

    if (!key) {
      continue;
    }

    const isDoubleQuoted = value.startsWith('"') && value.endsWith('"') && value.length >= 2;
    const isSingleQuoted = value.startsWith("'") && value.endsWith("'") && value.length >= 2;

    if (isDoubleQuoted || isSingleQuoted) {
      value = value.slice(1, -1);
      if (isDoubleQuoted) {
        value = value.replace(/\\\\/g, "\\").replace(/\\\"/g, '"');
      }
    }

    values[key] = value;
  }

  return values;
}

export async function GET() {
  try {
    const nextRoot = process.cwd();
    const envPath = path.resolve(nextRoot, RELATIVE_ENV_PATH);
    const fileContent = await readFile(envPath, "utf8");
    const values = parseEnv(fileContent);

    return NextResponse.json({ success: true, values });
  } catch (error) {
    console.error("Failed to load .env", error);
    return NextResponse.json(
      { success: false, error: "Unable to read ../.env" },
      { status: 404 },
    );
  }
}
