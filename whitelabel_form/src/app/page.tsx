"use client";

import Image from "next/image";
import { useMemo, useState } from "react";
import styles from "./page.module.css";

type FieldType = "text" | "color";

type FieldConfig = {
  key: string;
  label: string;
  placeholder?: string;
  helper?: string;
  required?: boolean;
  defaultValue?: string;
  type?: FieldType;
};

const FIELD_CONFIG: FieldConfig[] = [
  { key: "APP_NAME", label: "App Name", placeholder: "News Flash", required: true },
  {
    key: "PRIMARY_COLOR",
    label: "Primary Color",
    placeholder: "0xFFE9465F",
    defaultValue: "0xFFE9465F",
    type: "color",
  },
  {
    key: "SECONDARY_COLOR",
    label: "Secondary Color",
    placeholder: "0xFFFFC27A",
    defaultValue: "0xFFFFC27A",
    type: "color",
  },
  {
    key: "NEWS_API_KEY",
    label: "News API Key",
    placeholder: "e5b8d7516ad4439595ce42c4ce8477d3",
    required: true,
  },
  {
    key: "NEWS_API_BASE_URL",
    label: "News API Base URL",
    placeholder: "https://newsapi.org/v2",
    defaultValue: "https://newsapi.org/v2",
  },
  { key: "PACKAGE_NAME", label: "Package Name", placeholder: "com.example.app", required: true },
  {
    key: "SEARCH_PAGE_LOTTIE_ANIMATION",
    label: "Search Animation URL",
    placeholder: "https://lottie.host/...",
  },
  {
    key: "EMPTY_NEWS_ANIMATION",
    label: "Empty State Animation URL",
    placeholder: "https://lottie.host/...",
  },
  {
    key: "ERROR_ANIMATION",
    label: "Error Animation URL",
    placeholder: "https://lottie.host/...",
  },
  {
    key: "COMING_SOON_ANIMATION",
    label: "Coming Soon Animation URL",
    placeholder: "https://lottie.host/...",
  },
  {
    key: "APP_ICON_PATH",
    label: "App Icon Path or URL",
    placeholder: "../assets/icon/icon.png",
  },
  { key: "FIREBASE_PROJECT", label: "Firebase Project ID", placeholder: "project-id", required: true },
  { key: "DROPBOX_API_KEY", label: "Dropbox API Key", helper: "Optional" },
  {
    key: "WHITELABEL_WA_NUMBER",
    label: "WhatsApp Number",
    placeholder: "+628123456789",
    helper: "Optional, include country code",
  },
];

const initialValues = FIELD_CONFIG.reduce<Record<string, string>>((acc, field) => {
  acc[field.key] = field.defaultValue ?? "";
  return acc;
}, {});

const initialColorInputs = FIELD_CONFIG.reduce<Record<string, string>>((acc, field) => {
  if (field.type === "color") {
    const envValue = initialValues[field.key];
    const displayValue = envColorToText(envValue);
    if (displayValue) {
      acc[field.key] = displayValue;
    }
  }
  return acc;
}, {});

type RunStatus = "idle" | "running" | "success" | "error";
type LoadStatus = "idle" | "loading" | "success" | "error";

export default function Home() {
  const [values, setValues] = useState<Record<string, string>>(initialValues);
  const [copied, setCopied] = useState(false);
  const [runStatus, setRunStatus] = useState<RunStatus>("idle");
  const [runMessage, setRunMessage] = useState("");
  const [runOutput, setRunOutput] = useState("");
  const [colorInputs, setColorInputs] = useState<Record<string, string>>({ ...initialColorInputs });
  const [loadStatus, setLoadStatus] = useState<LoadStatus>("idle");
  const [loadMessage, setLoadMessage] = useState("");
  const [iconPreview, setIconPreview] = useState<string | null>(null);
  const [iconUploadStatus, setIconUploadStatus] = useState<LoadStatus>("idle");
  const [iconUploadMessage, setIconUploadMessage] = useState("");

  const envContent = useMemo(() => {
    return FIELD_CONFIG.map(({ key }) => `${key}=${formatValue(values[key] ?? "")}`).join("\n");
  }, [values]);

  const hasRequiredValues = useMemo(() => {
    return FIELD_CONFIG.every((field) => {
      if (!field.required) {
        return true;
      }
      const value = values[field.key];
      return typeof value === "string" && value.trim() !== "";
    });
  }, [values]);

  const whatsappLink = useMemo(() => {
    const rawNumber = values.WHITELABEL_WA_NUMBER?.trim();
    if (!rawNumber) {
      return null;
    }
    const digits = rawNumber.replace(/[^0-9]/g, "");
    if (!digits) {
      return null;
    }
    const appName = values.APP_NAME?.trim() || "our app";
    const message = `Hi! The white-label assets for ${appName} are ready.`;
    return {
      url: `https://wa.me/${digits}?text=${encodeURIComponent(message)}`,
      displayNumber: rawNumber,
    };
  }, [values]);

  const handleChange = (key: string, value: string) => {
    setValues((prev) => ({ ...prev, [key]: value }));
  };

  const applyEnvValues = (envValues: Record<string, string>) => {
    setValues((prev) => {
      const next = { ...prev };
      FIELD_CONFIG.forEach(({ key }) => {
        if (Object.prototype.hasOwnProperty.call(envValues, key)) {
          next[key] = envValues[key] ?? "";
        }
      });
      return next;
    });

    setColorInputs((prev) => {
      const next = { ...prev };
      FIELD_CONFIG.forEach((field) => {
        if (field.type !== "color") {
          return;
        }
        if (Object.prototype.hasOwnProperty.call(envValues, field.key)) {
          next[field.key] = envColorToText(envValues[field.key]) || "";
        }
      });
      return next;
    });
  };

  const handleColorTextChange = (key: string, rawValue: string) => {
    const sanitized = sanitizeColorInput(rawValue);
    setColorInputs((prev) => ({ ...prev, [key]: sanitized }));

    if (sanitized === "") {
      handleChange(key, "");
      return;
    }

    if (isCompleteHexValue(sanitized)) {
      const nextValue = hexToEnvColor(sanitized, values[key]);
      handleChange(key, nextValue);
    }
  };

  const handleCopy = async () => {
    try {
      await navigator.clipboard.writeText(envContent);
      setCopied(true);
      setTimeout(() => setCopied(false), 2000);
    } catch (error) {
      console.error("Clipboard copy failed", error);
    }
  };

  const handleRunScript = async () => {
    setRunStatus("running");
    setRunMessage("Running whitelabel.sh...");
    setRunOutput("");

    try {
      const response = await fetch("/api/run-whitelabel", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ envContent }),
      });

      const contentType = response.headers.get("content-type") ?? "";
      if (!contentType.includes("application/x-ndjson")) {
        const data = await response.json().catch(() => null);
        setRunStatus("error");
        setRunMessage(data?.error ?? "Failed to run whitelabel.sh.");
        setRunOutput(typeof data?.output === "string" ? data.output : "");
        return;
      }

      if (!response.body) {
        setRunStatus("error");
        setRunMessage("Streaming response missing body.");
        return;
      }

      const reader = response.body.getReader();
      const decoder = new TextDecoder();
      let buffer = "";
      let exitCode: number | null = null;

      const processLine = (line: string) => {
        if (!line.trim()) {
          return;
        }
        try {
          const event = JSON.parse(line);
          if (event.type === "stdout" || event.type === "stderr") {
            const prefix = event.type === "stderr" ? "[stderr] " : "";
            const chunk = typeof event.message === "string" ? event.message : "";
            setRunOutput((prev) => prev + prefix + chunk);
          } else if (event.type === "error") {
            setRunStatus("error");
            setRunMessage(event.message ?? "whitelabel.sh failed with an unknown error.");
          } else if (event.type === "exit") {
            exitCode = typeof event.exitCode === "number" ? event.exitCode : null;
            if (exitCode === 0) {
              setRunStatus("success");
              setRunMessage("whitelabel.sh ran successfully.");
            } else {
              setRunStatus("error");
              setRunMessage("whitelabel.sh exited with an error.");
            }
          }
        } catch (error) {
          console.error("Failed parsing run-whitelabel stream", error);
        }
      };

      while (true) {
        const { value, done } = await reader.read();
        if (done) {
          break;
        }
        buffer += decoder.decode(value, { stream: true });
        const lines = buffer.split("\n");
        buffer = lines.pop() ?? "";
        lines.forEach(processLine);
      }

      if (buffer.trim().length > 0) {
        processLine(buffer);
      }

      if (exitCode === null) {
        setRunStatus("error");
        setRunMessage("whitelabel.sh finished without reporting status.");
      }
    } catch (error) {
      console.error("Failed to run whitelabel.sh", error);
      setRunStatus("error");
      setRunMessage("Unexpected error while running whitelabel.sh.");
    }
  };

  const handleReset = () => {
    setValues(initialValues);
    setColorInputs({ ...initialColorInputs });
    setRunStatus("idle");
    setRunMessage("");
    setRunOutput("");
    setLoadStatus("idle");
    setLoadMessage("");
    setIconPreview(null);
    setIconUploadStatus("idle");
    setIconUploadMessage("");
  };

  const handleLoadFromEnv = async () => {
    setLoadStatus("loading");
    setLoadMessage("");

    try {
      const response = await fetch("/api/load-env");
      const data = await response.json();

      if (!response.ok || !data?.success || typeof data.values !== "object" || data.values === null) {
        setLoadStatus("error");
        setLoadMessage(data?.error ?? "Failed to read ../.env");
        return;
      }

      applyEnvValues(data.values as Record<string, string>);
      setLoadStatus("success");
      setLoadMessage("Loaded values from ../.env");
    } catch (error) {
      console.error("Failed to load ../.env", error);
      setLoadStatus("error");
      setLoadMessage("Unexpected error while loading ../.env");
    }
  };

  const handleIconUpload = async (file: File | null) => {
    if (!file) {
      return;
    }

    setIconUploadStatus("loading");
    setIconUploadMessage("");

    try {
      const formData = new FormData();
      formData.append("icon", file);

      const response = await fetch("/api/upload-icon", {
        method: "POST",
        body: formData,
      });

      const data = await response.json();
      if (!response.ok || !data?.success) {
        setIconUploadStatus("error");
        setIconUploadMessage(data?.error ?? "Failed to upload icon");
        return;
      }

      if (typeof data.iconPath === "string") {
        handleChange("APP_ICON_PATH", data.iconPath);
      }
      setIconPreview(typeof data.previewDataUrl === "string" ? data.previewDataUrl : null);
      setIconUploadStatus("success");
      setIconUploadMessage("Icon uploaded to ../assets/icon/icon.png");
    } catch (error) {
      console.error("Icon upload failed", error);
      setIconUploadStatus("error");
      setIconUploadMessage("Unexpected error while uploading icon");
    }
  };

  return (
    <div className={styles.page}>
      <main className={styles.main}>
        <header className={styles.header}>
          <p className={styles.badge}>Proof of Concept</p>
          <h1>Whitelabel Env Builder</h1>
          <p>
            Enter the branding and infrastructure details for a client. The generated content can be
            saved as a <code>.env</code> file and passed to <code>whitelabel.sh</code>.
          </p>
        </header>

        <div className={styles.layout}>
          <section className={styles.formSection}>
            <h2>App Details</h2>
            <form className={styles.form} onSubmit={(e) => e.preventDefault()}>
              {FIELD_CONFIG.map((field) => {
                const isColor = field.type === "color";
                const isIconField = field.key === "APP_ICON_PATH";
                const colorDisplayValue = isColor
                  ? colorInputs[field.key] ?? envColorToText(values[field.key]) ?? ""
                  : undefined;
                const colorTextValue = colorDisplayValue ?? "";
                const colorHex = isColor
                  ? isCompleteHexValue(colorTextValue)
                    ? colorTextValue
                    : envColorToHex(values[field.key])
                  : undefined;
                const colorPlaceholder = isColor
                  ? envColorToText(field.placeholder) || "#RRGGBB"
                  : undefined;
                const helperText = field.helper ?? (isColor ? undefined : field.key);
                return (
                  <label key={field.key} className={styles.field}>
                    <span className={styles.label}>
                      {field.label}
                      {field.required && <span className={styles.required}>*</span>}
                    </span>
                    <div className={isColor ? styles.colorControl : undefined}>
                      {isColor ? (
                        <>
                          <input
                            type="text"
                            name={field.key}
                            required={field.required}
                            placeholder={colorPlaceholder}
                            value={colorTextValue}
                            maxLength={7}
                            onChange={(event) => handleColorTextChange(field.key, event.target.value)}
                          />
                          <input
                            type="color"
                            aria-label={`${field.label} color picker`}
                            value={colorHex}
                            onChange={(event) => {
                              const nextValue = event.target.value;
                              const upperHex = nextValue.toUpperCase();
                              setColorInputs((prev) => ({ ...prev, [field.key]: upperHex }));
                              handleChange(field.key, hexToEnvColor(nextValue, values[field.key]));
                            }}
                          />
                        </>
                      ) : (
                        <input
                          type="text"
                          name={field.key}
                          required={field.required}
                          placeholder={field.placeholder}
                          value={values[field.key] ?? ""}
                          onChange={(event) => handleChange(field.key, event.target.value)}
                        />
                      )}
                    </div>
                    {isIconField && (
                      <div className={styles.iconUpload}>
                        <label className={styles.iconUploadLabel}>
                          <input
                            type="file"
                            accept="image/png"
                            className={styles.iconUploadInput}
                            onChange={async (event) => {
                              const file = event.target.files?.[0] ?? null;
                              await handleIconUpload(file);
                              event.target.value = "";
                            }}
                          />
                          <span>
                            {iconUploadStatus === "loading" ? "Uploading icon..." : "Upload PNG"}
                          </span>
                        </label>
                        {iconUploadMessage && (
                          <p
                            className={`${styles.iconUploadMessage} ${
                              iconUploadStatus === "error"
                                ? styles.runStatusError
                                : iconUploadStatus === "success"
                                ? styles.runStatusSuccess
                                : ""
                            }`}
                          >
                            {iconUploadMessage}
                          </p>
                        )}
                        {iconPreview && (
                          <div className={styles.iconPreview}>
                            <Image
                              src={iconPreview}
                              alt="App icon preview"
                              width={64}
                              height={64}
                              className={styles.iconPreviewImage}
                            />
                          </div>
                        )}
                      </div>
                    )}
                    {helperText && <span className={styles.helper}>{helperText}</span>}
                  </label>
                );
              })}
            </form>
            <div className={styles.actions}>
              <button
                type="button"
                onClick={handleLoadFromEnv}
                className={styles.secondaryButton}
                disabled={loadStatus === "loading"}
              >
                {loadStatus === "loading" ? "Loading..." : "Load ../.env"}
              </button>
              <button type="button" onClick={handleReset} className={styles.secondaryButton}>
                Reset
              </button>
            </div>
            {loadMessage && (
              <p
                className={`${styles.loadStatus} ${
                  loadStatus === "error"
                    ? styles.runStatusError
                    : loadStatus === "success"
                    ? styles.runStatusSuccess
                    : ""
                }`}
              >
                {loadMessage}
              </p>
            )}
          </section>

          <section className={styles.outputSection}>
            <div className={styles.outputHeader}>
              <h2>Preview .env</h2>
              <span className={styles.outputCaption}>Updates live as you type</span>
            </div>
            <textarea readOnly value={envContent} className={styles.output} wrap="off" />
            <div className={styles.actions}>
              <button type="button" onClick={handleCopy} className={styles.secondaryButton}>
                {copied ? "Copied!" : "Copy to clipboard"}
              </button>
              <button
                type="button"
                onClick={handleRunScript}
                className={styles.primaryButton}
                disabled={!hasRequiredValues || runStatus === "running"}
              >
                {runStatus === "running" ? "Running..." : "Run whitelabel.sh"}
              </button>
            </div>
            {runStatus !== "idle" && (
              <div className={styles.runStatusBlock}>
                <p
                  className={`${styles.runStatus} ${
                    runStatus === "success"
                      ? styles.runStatusSuccess
                      : runStatus === "error"
                      ? styles.runStatusError
                      : ""
                  }`}
                >
                  {runMessage}
                </p>
                {runOutput && <pre className={styles.runLog}>{runOutput}</pre>}
              </div>
            )}
          </section>
        </div>
      </main>
    </div>
  );
}

function formatValue(rawValue: string): string {
  const value = rawValue ?? "";
  if (value.trim() === "") {
    return "";
  }

  const escaped = value.replace(/\\/g, "\\\\").replace(/"/g, '\\"');
  const needsQuotes = /[\s#"']/u.test(value) || value.includes("=");
  return needsQuotes ? `"${escaped}"` : escaped;
}

function envColorToText(value?: string): string {
  if (value && /^0x[0-9a-fA-F]{8}$/.test(value)) {
    return `#${value.slice(-6).toUpperCase()}`;
  }
  return "";
}

function envColorToHex(value?: string): string {
  const text = envColorToText(value);
  return text || "#000000";
}

function sanitizeColorInput(value: string): string {
  if (!value) {
    return "";
  }

  let nextValue = value.trim();
  if (!nextValue) {
    return "";
  }

  if (!nextValue.startsWith("#")) {
    nextValue = `#${nextValue}`;
  }

  const body = nextValue
    .slice(1)
    .replace(/[^0-9a-fA-F]/g, "")
    .toUpperCase()
    .slice(0, 6);

  return body.length === 0 ? "#" : `#${body}`;
}

function isCompleteHexValue(value: string): boolean {
  return /^#[0-9A-F]{6}$/.test(value);
}

function hexToEnvColor(hex: string, previous?: string): string {
  if (/^#[0-9a-fA-F]{6}$/.test(hex)) {
    const alpha = previous && /^0x([0-9a-fA-F]{2})[0-9a-fA-F]{6}$/.test(previous) ? previous.slice(2, 4) : "FF";
    return `0x${alpha}${hex.replace("#", "").toUpperCase()}`;
  }
  return previous ?? "";
}
