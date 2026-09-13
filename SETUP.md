# Setup

This machine is RAM-constrained (11 GB total). **Do not use the Android emulator** — it needs 2–4 GB you don't have. Use one of the two paths below.

---

## Path 1 — Local dev + physical Android phone (recommended)

Develop and build locally, deploy over USB to a real phone. This is also the device your Shipaton demo video should show. No emulator, minimal RAM overhead.

### 1. Install Flutter (Fedora, no snap/apt)

```bash
# Download the Flutter SDK (Linux tarball) into ~/dev
mkdir -p ~/dev && cd ~/dev
# Get the latest stable Linux tarball URL from https://docs.flutter.dev/get-started/install/linux
# then:
tar xf flutter_linux_*-stable.tar.xz
echo 'export PATH="$HOME/dev/flutter/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
flutter --version
```

### 2. Install ONLY the command-line Android SDK (no emulator image)

```bash
# Android command-line tools: https://developer.android.com/studio#command-line-tools-only
mkdir -p ~/Android/cmdline-tools
cd ~/Android/cmdline-tools
unzip ~/Downloads/commandlinetools-linux-*.zip
mv cmdline-tools latest
export ANDROID_HOME="$HOME/Android"
echo 'export ANDROID_HOME="$HOME/Android"' >> ~/.bashrc
echo 'export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH"' >> ~/.bashrc
source ~/.bashrc

# Install ONLY what a phone build needs — NOT the emulator/system-images
sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0"
flutter config --android-sdk "$ANDROID_HOME"
yes | flutter doctor --android-licenses
```

Java is already installed (OpenJDK 25). If Gradle complains about the JDK version, install a JDK 17 and point Gradle at it via `org.gradle.java.home` — note this in a follow-up if it happens.

### 3. Connect the phone

- On the phone: Settings → About → tap Build Number 7× to enable Developer Options.
- Developer Options → enable **USB debugging**.
- Plug in via USB, accept the debugging prompt.

```bash
flutter devices        # should list your phone
flutter pub get
flutter run             # deploys to the phone
```

### Disk/RAM budget (Path 1)
- Flutter SDK ~2–3 GB, Android SDK (no emulator) ~3–4 GB, Gradle caches ~2–3 GB → **~8–11 GB total**, safe against 24 GB free.
- Build RAM ~2–4 GB, no emulator → fits in 11 GB.

---

## Path 2 — Codemagic cloud build (fallback, free via Ship Kit)

If local disk/RAM gets tight, or you have no phone handy: develop locally (you can even skip the Android SDK), push to a Git remote, and let Codemagic build the APK in the cloud. Codemagic is a Shipaton sponsor — unlock the perk via Ship Kit.

1. Push this repo to GitHub/GitLab.
2. Sign in to Codemagic, add the app, pick the Flutter workflow.
3. It runs `flutter build apk` in the cloud and gives you an installable APK artifact.
4. Sideload the APK onto any Android phone to test / record the demo.

Tradeoff: slower iteration than a local device (each change = push + cloud build). Best as a fallback or for producing the final release APK.

---

## RevenueCat setup (either path)

1. Create a RevenueCat project (also unlocks Ship Kit milestones).
2. Create products/offerings: site-tool consumables, `architect_pass` subscription, `remove_ads` non-consumable.
3. Put the Android API key somewhere untracked (`lib/economy/secrets.dart`, gitignored) — never commit it.
4. Sandbox / test purchases are sufficient for Next Gen judging. No store publish, no real charges.

See the 2026 Flutter codelab: https://revenuecat.github.io/codelabs/flutter.html
