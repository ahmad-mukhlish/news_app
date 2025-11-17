"use client";

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
    helper: "ARGB (0xFFrrggbb)",
  },
  {
    key: "SECONDARY_COLOR",
    label: "Secondary Color",
    placeholder: "0xFFFFC27A",
    defaultValue: "0xFFFFC27A",
    type: "color",
    helper: "ARGB (0xFFrrggbb)",
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
    placeholder: "assets/icon/icon.png or https://...",
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

export default function Home() {
  const [values, setValues] = useState<Record<string, string>>(initialValues);
  const [copied, setCopied] = useState(false);

  const envContent = useMemo(() => {
    return FIELD_CONFIG.map(({ key }) => `${key}=${formatValue(values[key] ?? "")}`).join("\n");
  }, [values]);

  const handleChange = (key: string, value: string) => {
    setValues((prev) => ({ ...prev, [key]: value }));
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

  const handleDownload = () => {
    const blob = new Blob([envContent], { type: "text/plain" });
    const url = URL.createObjectURL(blob);
    const anchor = document.createElement("a");
    anchor.href = url;
    anchor.download = `${values.APP_NAME?.replace(/\s+/g, "-").toLowerCase() || "app"}.env`;
    anchor.click();
    URL.revokeObjectURL(url);
  };

  const handleReset = () => {
    setValues(initialValues);
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
                const colorHex = isColor ? envColorToHex(values[field.key]) : undefined;
                return (
                  <label key={field.key} className={styles.field}>
                    <span className={styles.label}>
                      {field.label}
                      {field.required && <span className={styles.required}>*</span>}
                    </span>
                    <div className={isColor ? styles.colorControl : undefined}>
                      <input
                        type={isColor ? "color" : "text"}
                        name={field.key}
                        required={field.required}
                        placeholder={isColor ? undefined : field.placeholder}
                        value={isColor ? colorHex : values[field.key] ?? ""}
                        onChange={(event) => {
                          const nextValue = isColor
                            ? hexToEnvColor(event.target.value, values[field.key])
                            : event.target.value;
                          handleChange(field.key, nextValue);
                        }}
                      />
                      {isColor && (
                        <span className={styles.colorPreview}>
                          <span
                            className={styles.colorSwatch}
                            style={{ backgroundColor: colorHex }}
                          />
                          <span className={styles.colorValue}>
                            {values[field.key] || field.placeholder}
                          </span>
                        </span>
                      )}
                    </div>
                    <span className={styles.helper}>{field.helper ?? field.key}</span>
                  </label>
                );
              })}
            </form>
            <div className={styles.actions}>
              <button type="button" onClick={handleReset} className={styles.secondaryButton}>
                Reset
              </button>
            </div>
          </section>

          <section className={styles.outputSection}>
            <div className={styles.outputHeader}>
              <h2>Preview .env</h2>
              <span className={styles.outputCaption}>Updates live as you type</span>
            </div>
            <textarea readOnly value={envContent} className={styles.output} />
            <div className={styles.actions}>
              <button type="button" onClick={handleCopy} className={styles.primaryButton}>
                {copied ? "Copied!" : "Copy to clipboard"}
              </button>
              <button type="button" onClick={handleDownload} className={styles.secondaryButton}>
                Download .env
              </button>
            </div>
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

function envColorToHex(value?: string): string {
  if (value && /^0x[0-9a-fA-F]{8}$/.test(value)) {
    return `#${value.slice(-6)}`;
  }
  return "#000000";
}

function hexToEnvColor(hex: string, previous?: string): string {
  if (/^#[0-9a-fA-F]{6}$/.test(hex)) {
    const alpha = previous && /^0x([0-9a-fA-F]{2})[0-9a-fA-F]{6}$/.test(previous) ? previous.slice(2, 4) : "FF";
    return `0x${alpha}${hex.replace("#", "").toUpperCase()}`;
  }
  return previous ?? "";
}
