# news_app

A news flutter App

## White label support 🏳️

Quick demo commands (env presets are committed for this showcase):

```bash
./whitelabel.sh .env.brand_globe
```

or

```bash
./whitelabel.sh .env.brand_newsflash
```


Each run copies the bundled Firebase configs from `assets/config/`, syncs the icon, and renames the app/package for the selected brand.

## Fully Automated Test By Maestro 🎉

[![Watch the video](https://img.youtube.com/vi/NYMoQf19x_I/maxresdefault.jpg)](https://youtu.be/NYMoQf19x_I)
### [Watch full automation demo at youtube](https://youtu.be/NYMoQf19x_I)

This is included the phase 1 features : 
home (headlines), search with combo-box, category and profile (with coming soon)

How to run the automation testing :
1. Download maestro first to try this automation testing [here](https://docs.maestro.dev/getting-started/installing-maestro)
2. Then run this App
3. Then use this command at terminal : 
   ```
   maestro test maestro/all-tests.yaml
   ```
## Firebase 

[![Watch the video](https://img.youtube.com/vi/lSIsPcEIJzQ/maxresdefault.jpg)](https://youtu.be/lSIsPcEIJzQ)

### [Watch notification demo on YouTube](https://youtu.be/lSIsPcEIJzQ)

Added firebase to handling :
1. Foreground state
2. Background state
3. Terminated state

## Unit and Widget Testing with 90%+ Coverage 🎉

This could be checked by these commands :

```
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html      
```

https://github.com/user-attachments/assets/594bdce1-53c1-48de-a969-1d2c788db954

## White Label Detail

Package renaming (via [`package_rename_plus`](https://pub.dev/packages/package_rename_plus)), launcher icon generation ([`flutter_launcher_icons`](https://pub.dev/packages/flutter_launcher_icons)), and Maestro `appId` updates are bundled inside `./whitelabel.sh`.

### Provided environment presets

- `.env.brand_newsflash` & `.env.brand_globe` contain sample values for `APP_NAME`, `PACKAGE_NAME`, API keys, colors, etc. Copy one of them (or duplicate it) and tweak the values for your brand.
- Keep sensitive values (real API keys) out of git by copying the preset into an untracked file, e.g. `cp .env.brand_newsflash .env.client_a`.

### Icon location

- Every branding pass generates icons from `assets/icon/icon.png` (vector PNG, 1024×1024 recommended by `flutter_launcher_icons`).
- To avoid manual copying, point `APP_ICON_PATH` at either a local path (relative/absolute) or an `http(s)` URL. `whitelabel.sh` downloads the file into `assets/icon/icon.png` and validates that it is a PNG image (public, no auth/confirmation screens).

### Firebase configuration files

- Keep per-brand Firebase artifacts under `assets/config/`:
  - `assets/config/google-services.json`
  - `assets/config/GoogleService-Info.plist`
  - `assets/config/firebase_options.dart`
- During a run `whitelabel.sh` copies those files to `android/app/google-services.json`, `ios/Runner/GoogleService-Info.plist`, and `lib/firebase_options.dart`.
- If a brand uses different filenames or directories, point the env vars `GOOGLE_SERVICES_JSON_PATH`, `IOS_GOOGLE_SERVICE_INFO_PATH`, and `FIREBASE_OPTIONS_PATH` at the desired sources; the defaults above are used when those vars are omitted.

### Running the script

1. Place the correct icon at `assets/icon/icon.png` (or set `APP_ICON_PATH` to a local path / `http(s)` URL).
2. Drop the Firebase config files into `assets/config/` (or set the env vars described above).
3. Run `./whitelabel.sh path/to/env-file` (for the default `.env` just run `./whitelabel.sh`).
3. The script will:
   - copy the Firebase JSON/Plist/Dart options into the platform targets
   - run `flutter pub get`
   - update Android app name + package using `package_rename_plus`
   - regenerate launcher icons
   - rewrite every Maestro flow’s `appId` to the new package name

If anything fails (missing env var, icon, etc.) the script exits with an error so you can fix the input and re-run.
