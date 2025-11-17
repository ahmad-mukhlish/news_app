## Whitelabel form POC

A tiny local-only Next.js app that mimics the data you would normally collect via Google Forms. Enter all branding/config values and the page streams a `.env` preview that you can copy or download before running `whitelabel.sh`.

### Run locally

```bash
cd whitelabel_form
npm install    # only needed the first time
npm run dev
```

Visit [http://localhost:3000](http://localhost:3000) and fill out the form.

### Generate the `.env`

1. Type the branding values (app name, package id, Firebase project, etc).
2. Use **Copy to clipboard** or **Download .env** once you are ready.
3. Move the downloaded file anywhere in the repo (e.g. `.env.brand_new`) and pass it to `whitelabel.sh`:

   ```bash
   bash whitelabel.sh .env.brand_new
   ```

The preview window always shows the exact file contents, so you can verify what will be fed into the automation script before triggering it. This makes it a lightweight proof-of-concept replacement for the real Google Form hookup.
