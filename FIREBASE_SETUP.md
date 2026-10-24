# Firebase Setup Guide for Kerala Gold Rate Monitor

This application includes a complete **Firebase Analytics** architecture with safe fallback support.

---

### Registered Application / Package ID
- **Android Package / Application ID:** `com.ker.goldratemonitor`

---

### Step 1: Create or Open Project in Firebase Console
1. Open the [Firebase Console](https://console.firebase.google.com/).
2. Click **Add project** (or select your existing project).
3. Ensure **Google Analytics for Firebase** is enabled for your project.

---

### Step 2: Register Android App
1. In Project Overview, click the **Android** icon to add an Android app.
2. In **Android package name**, enter:
   ```text
   com.ker.goldratemonitor
   ```
3. Enter App nickname (e.g. `Kerala Gold Rate Monitor`).
4. (Optional) Enter your SHA-1 fingerprint if needed for App Check or Auth.
5. Click **Register app**.

---

### Step 3: Download & Place `google-services.json`
1. Download `google-services.json` from the Firebase Console.
2. Place the downloaded file into the `android/app/` folder:
   ```text
   android/app/google-services.json
   ```
   > ℹ️ **Security Note:** `google-services.json` is automatically ignored in `.gitignore` to prevent leaking keys to public repositories. A template file [android/app/google-services.json.example](file:///c:/Users/thanv/gold%20rate%20app/android/app/google-services.json.example) is provided for reference.
   >
   > ℹ️ **Automatic Plugin Activation:** `android/app/build.gradle.kts` is pre-configured to detect and apply `com.google.gms.google-services` automatically as soon as `google-services.json` is placed in `android/app/`!

---

### Step 4: Verification & Testing
1. Connect an Android device or start an emulator.
2. Run debug build:
   ```bash
   flutter run
   ```
3. You will see the initialization log in the debug console:
   ```text
   [AnalyticsService] ✅ Firebase Analytics successfully initialized.
   ```
4. To view real-time events in the **Firebase Console > Analytics > DebugView**:
   ```bash
   adb shell setprop debug.firebase.analytics.app com.ker.goldratemonitor
   ```

---

### Tracked Analytics Events

| Event Name | Trigger | Parameters |
|------------|---------|------------|
| `app_open` | App launch | None |
| `screen_view` | Screen changes (`HomeScreen`, `GoldCalculatorSheet`) | `screen_name`, `screen_class` |
| `unit_toggled` | User toggles Pavan (8g) ↔ Gram (1g) | `unit` (`pavan` / `gram`), `unit_grams` (8 / 1) |
| `rates_refreshed` | Auto-load or manual pull-to-refresh | `refresh_type` (`manual_pull` / `initial_load`), `success`, `pavan_price`, `gram_price`, `trend`, `duration_ms` |
| `calculator_opened` | User opens jewellery estimate modal | `current_gram_rate` |
| `calculator_computed` | User interacts with weight, making charges, GST | `weight_grams`, `making_charge_pct`, `include_gst`, `grand_total` |
| `chart_period_selected` | User selects chart timeframe (7D, 14D, Month) | `period` (`7D`, `14D`, `Month`) |
| `test_notification_triggered` | User triggers test notification alert | None |
| `background_check_executed` | Background rate monitor or manual check | `rate_changed`, `new_price`, `old_price`, `price_difference` |
