# Setup Instructions

## Fix for "Android v1 embedding" Error

The example app is now configured for Flutter's Android v2 embedding. Follow these steps:

### 1. Clean the project
```bash
cd /Users/ebrahimqaashah/D_/SD/TSensor/SMTsensor/example
flutter clean
```

### 2. Get dependencies
```bash
flutter pub get
```

### 3. Run the app
```bash
flutter run
```

## If you still get errors:

### Option A: In Android Studio
1. File → Invalidate Caches / Restart
2. Tools → Flutter → Flutter Clean
3. Build → Clean Project
4. Build → Rebuild Project

### Option B: Command line
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

## Key Files Updated:
- ✅ `android/app/build.gradle` - Modern Gradle plugin configuration
- ✅ `android/build.gradle` - Root build configuration
- ✅ `android/settings.gradle` - Plugin management
- ✅ `android/gradle.properties` - AndroidX enabled
- ✅ `android/app/src/main/kotlin/MainActivity.kt` - FlutterActivity v2
- ✅ `AndroidManifest.xml` - Proper package name and embedding metadata

## Minimum Requirements:
- Flutter SDK: 3.0.0+
- Android minSdkVersion: 21 (Android 5.0)
- Gradle: 8.7
- Android Gradle Plugin: 8.3.0
- Kotlin: 2.1.0

## Versions Updated (May 12, 2026):
- ✅ Gradle: 8.3 → 8.7 (meets Flutter minimum requirement)
- ✅ Android Gradle Plugin: 8.1.0 → 8.3.0 (meets Flutter minimum 8.1.1+)
- ✅ Kotlin: 1.9.0 → 2.1.0 (meets Flutter minimum requirement)
- ✅ Added `android.newDsl=false` to gradle.properties to opt-out of new DSL migration
- ✅ Fixed null safety issues for device VID/PID properties
