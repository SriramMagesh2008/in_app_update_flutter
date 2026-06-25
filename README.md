# in_app_update_flutter

A Flutter plugin for unified in-app updates on Android (Google Play) and iOS (App Store), allowing users to update without leaving the app.

On iOS, it displays the App Store product page using SKStoreProductViewController while keeping users inside the app. On Android, it integrates with Google Play’s In-App Updates API to support both immediate (blocking) and flexible (background) update flows.

---

## Screenshots

| iOS | Android Immediate | Android Flexible |
|-----|------------------|-----------------|
| ![iOS in-app update](https://raw.githubusercontent.com/axions-org/in_app_update_flutter/production/assets/screenshots/ios-in-app-update.png) | ![Android immediate update](https://raw.githubusercontent.com/axions-org/in_app_update_flutter/production/assets/screenshots/android-immediate-update.png) | ![Android flexible update](https://raw.githubusercontent.com/axions-org/in_app_update_flutter/production/assets/screenshots/android-flexible-update.png) |

---

## Why `in_app_update_flutter`?

This package provides a **single unified API for both Android and iOS in-app updates**, unlike platform-specific or partial solutions.

| Feature | in_app_update_flutter | in_app_update | upgrader |
|--------|----------------------|--------------|-----------|
| Android Play Core updates | ✅ | ✅ | ❌ |
| iOS App Store in-app prompt | ✅ | ❌ | ⚠️ (redirect only) |
| Immediate update support | ✅ | ❌ | ❌ |
| Flexible update support | ✅ | ❌ | ❌ |
| Unified API for both platforms | ✅ | ❌ | ❌ |

## Features

- iOS: Show App Store update prompt using SKStoreProductViewController
- iOS: Native Swift implementation with zero AppDelegate configuration
- iOS: Supports CocoaPods and Swift Package Manager (SPM)
- Android: Check update availability via Google Play Core API
- Android: Immediate update flow (blocking full-screen update)
- Android: Flexible update flow (background download)
- Android: Install state stream for update progress tracking
- Unified Flutter API across both platforms

---

## Installation

Add the dependency:

```yaml
dependencies:
  in_app_update_flutter: ^2.0.3
  in_app_update_flutter: ^3.0.0
```

Then

flutter pub get


---

## iOS Usage

Pass your numeric App Store ID to `showUpdateForIos`. The ID can be found in your App Store Connect URL or the app's public App Store link.

```dart
import 'package:in_app_update_flutter/in_app_update_flutter.dart';

await InAppUpdateFlutter().showUpdateForIos(appStoreId: '1234567890');
```

**How to find your App Store ID:**

1. Open your app's App Store URL — for example: `https://apps.apple.com/app/id1234567890`
2. The numeric portion after `id` is your App Store ID.

**iOS notes:**
- Requires iOS 13.0 or later
- Does not work on simulators
- Not supported in TestFlight builds — test on a real device using a development or App Store build

---

## Android Usage

Android uses Google Play's In-App Updates API. The typical flow is:

1. Call `checkUpdateAndroid()` to retrieve update availability and metadata.
2. Based on the result, start either an immediate or flexible update.

### Immediate Update

An immediate update presents a full-screen prompt that the user must complete before continuing. Use this for critical updates.

```dart
import 'package:in_app_update_flutter/in_app_update_flutter.dart';

final plugin = InAppUpdateFlutter();

final info = await plugin.checkUpdateAndroid();

if (info.updateAvailability == UpdateAvailabilityAndroid.updateAvailable &&
    info.isImmediateUpdateAllowed) {
  final result = await plugin.startImmediateUpdateAndroid();
  // result is UpdateResultAndroid.success or UpdateResultAndroid.userCanceled
}
```

### Flexible Update

A flexible update downloads in the background while the user continues using the app. When the download completes, call `completeUpdateAndroid()` to apply the update.

```dart
import 'package:in_app_update_flutter/in_app_update_flutter.dart';

final plugin = InAppUpdateFlutter();

final info = await plugin.checkUpdateAndroid();

if (info.updateAvailability == UpdateAvailabilityAndroid.updateAvailable &&
    info.isFlexibleUpdateAllowed) {
  await plugin.startFlexibleUpdateAndroid();

  plugin.installStateStreamAndroid.listen((state) {
    if (state.installStatus == InstallStatusAndroid.downloaded) {
      plugin.completeUpdateAndroid();
    }
  });
}
```

### AppUpdateInfoAndroid fields

| Field | Type | Description |
|---|---|---|
| `updateAvailability` | `UpdateAvailabilityAndroid` | Whether an update is available |
| `availableVersionCode` | `int?` | Version code of the available update |
| `updatePriority` | `int` | Developer-assigned priority (0–5) |
| `clientVersionStalenessDays` | `int?` | Days since the update became available |
| `isImmediateUpdateAllowed` | `bool` | Whether immediate update is allowed |
| `isFlexibleUpdateAllowed` | `bool` | Whether flexible update is allowed |
| `installStatus` | `InstallStatusAndroid` | Current install status |

---

## Example

A complete working example is available in the [`example/`](example) directory.

```bash
cd example
flutter run
```

---

## FAQ

### 1. Does this work on iOS?

Yes, but iOS only supports showing the App Store product page inside the app. It does not support forced updates like Android.

### 2. Does it work on Android outside Google Play?

No. Android in-app updates require the app to be installed from Google Play.

### 3. Can I use it on simulators?

No. iOS update flow requires a real device.

### 4. Does this require native setup?

No. iOS requires no AppDelegate configuration. Android works via Play Core integration internally.

## License

[MIT License](LICENSE)

---

## Contributing

Contributions are welcome. Please open issues or pull requests for improvements.

⭐ If you find this package useful, please star the repository — it helps others discover it.
