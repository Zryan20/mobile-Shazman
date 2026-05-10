# Social Authentication Setup Guide

To make Google and Apple Sign-In work, you need to perform several manual configuration steps.

## 1. Google Sign-In Setup

### Firebase Console
1. Go to your [Firebase Console](https://console.firebase.google.com/).
2. Select your project.
3. Go to **Project Settings** (gear icon).
4. Under **General**, scroll down to your Android app.
5. You must add your **SHA-1 fingerprint**. 
   - To get it, run `./gradlew signingReport` in the `android` folder of your project.
   - Copy the SHA1 from the `debug` variant.
6. Enable **Google** as a Sign-in provider in **Authentication > Sign-in method**.

### Android Configuration
1. Download the updated `google-services.json` from Firebase.
2. Place it in `android/app/google-services.json`.

### iOS Configuration
1. Download the updated `GoogleService-Info.plist` from Firebase.
2. Place it in `ios/Runner/GoogleService-Info.plist`.
3. Open `ios/Runner/Info.plist` and add the `CFBundleURLTypes` for Google (the `REVERSED_CLIENT_ID` from `GoogleService-Info.plist`).

## 2. Apple Sign-In Setup

### Apple Developer Portal
1. Go to the [Apple Developer Portal](https://developer.apple.com/).
2. In **Certificates, Identifiers & Profiles**, select your App ID.
3. Enable the **Sign In with Apple** capability.
4. If you need it for Android/Web, create a **Services ID** and a **Key**.

### Xcode Configuration
1. Open the project in Xcode (`ios/Runner.xcworkspace`).
2. Go to the **Runner** target.
3. Select the **Signing & Capabilities** tab.
4. Click **+ Capability** and add **Sign in with Apple**.

### Firebase Console
1. Enable **Apple** as a Sign-in provider in **Authentication > Sign-in method**.

## 3. Post-Configuration
Once these steps are completed, run the app on a physical device (especially for Apple Sign-In) or an emulator with Google Play Services to test.
