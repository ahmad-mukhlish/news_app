import { NextRequest, NextResponse } from "next/server";
import { spawn, ChildProcessWithoutNullStreams } from "child_process";
import { access, mkdtemp, rm, writeFile } from "fs/promises";
import { tmpdir } from "os";
import path from "path";

const SCRIPT_RELATIVE_PATH = "../whitelabel.sh";

export async function POST(request: NextRequest) {
  let tempDir: string | undefined;
  let tempEnvFile: string | undefined;

  try {
    const body = await request.json();
    const envContent: unknown = body?.envContent;

    if (typeof envContent !== "string" || envContent.trim() === "") {
      return NextResponse.json(
        { success: false, error: "Env content is required" },
        { status: 400 },
      );
    }

    const nextProjectRoot = process.cwd();
    const scriptPath = path.resolve(nextProjectRoot, SCRIPT_RELATIVE_PATH);
    const scriptDir = path.dirname(scriptPath);

    try {
      await access(scriptPath);
    } catch {
      return NextResponse.json(
        { success: false, error: "whitelabel.sh not found" },
        { status: 500 },
      );
    }

    tempDir = await mkdtemp(path.join(tmpdir(), "whitelabel-form-"));
    tempEnvFile = path.join(tempDir, "client.env");
    await writeFile(tempEnvFile, envContent, "utf8");

    const encoder = new TextEncoder();
    let child: ChildProcessWithoutNullStreams | undefined;

    const cleanup = async () => {
      if (tempDir) {
        await rm(tempDir, { recursive: true, force: true }).catch(() => undefined);
      }
    };

    const stream = new ReadableStream<Uint8Array>({
      start(controller) {
        const scriptPathOnDisk = path.join(scriptDir, "whitelabel.sh");
        const send = (payload: unknown) => {
          controller.enqueue(encoder.encode(`${JSON.stringify(payload)}\n`));
        };

        child = spawn("bash", [scriptPathOnDisk, tempEnvFile as string], {
          cwd: scriptDir,
          env: process.env,
        });

        child.stdout.on("data", (chunk: Buffer) => {
          send({ type: "stdout", message: chunk.toString("utf8") });
        });

        child.stderr.on("data", (chunk: Buffer) => {
          send({ type: "stderr", message: chunk.toString("utf8") });
        });

        child.on("error", (error) => {
          send({ type: "error", message: error.message });
          cleanup()
            .catch(() => undefined)
            .finally(() => controller.close());
        });

        child.on("close", (code) => {
          send({ type: "exit", exitCode: code ?? 1 });
          cleanup()
            .catch(() => undefined)
            .finally(() => controller.close());
        });
      },
      cancel() {
        if (child) {
          child.kill("SIGTERM");
        }
        cleanup().catch(() => undefined);
      },
    });

    return new Response(stream, {
      headers: {
        "Content-Type": "application/x-ndjson",
        "Cache-Control": "no-cache",
      },
    });
  } catch (error) {
    console.error("whitelabel run failed", error);
    return NextResponse.json(
      { success: false, error: "Failed to run whitelabel script" },
      { status: 500 },
    );
  }
}
