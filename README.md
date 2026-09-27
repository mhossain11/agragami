# Agragami — Al-Falah Somiti Management App

A Flutter application for running an **Al-Falah Somiti (savings society)** — admins
collect monthly savings from members, track who paid and who didn't, generate
reports/PDFs, and print **monthly money receipts on a Bluetooth thermal printer**.

Built with **Flutter + GetX + Firebase** (Auth, Firestore, Storage), green Material
theme (`#2E7D32`), responsive via `flutter_screenutil` (design size `360 × 690`).

| | |
|---|---|
| **Dart package name** | `Agragami` (capital **A** — import as `package:Agragami/...`) |
| **Android applicationId** | `com.faysal.agragami` |
| **Dart SDK** | `^3.10.1` |
| **Min orientation** | Portrait (locked in `main.dart`) |

---

## Features

### Authentication
- **Login** by member **ID / Email** (IDs look like `AG26M001`, `AG26U001`)
- **Registration** with full member profile (ID, name, parents, phone, birth date,
  NID, address, blood group, nominee, …)
- **Forgot password** (email reset)
- **Role gate** — `admin` → `/adminHome`, `user` → `/home` (from cached `isRole`)
- Session restored from `CacheHelper` / `CacheService`

### Admin
Dashboard tiles on **Admin Home**:

| Feature | Description |
|---|---|
| Saving Money | Search member → add money (amount, method, date, received-by), edit entry |
| Members List | All members with balances |
| Monthly Report | All transactions of a selected month/year |
| Paid & Unpaid Report | Monthly paid/unpaid status per member (`payment_status`) |
| Money Receipt **(new)** | Member + month → receipt preview → **Bluetooth thermal print** |
| Admin Log | Per-member activity log (`users/{id}/Log`) |
| Notice Board | Send notices/notifications |
| User Id Create / Id List | Create & manage ID registry entries |
| Delete Record / Delete All Money Records | Money cleanup tools |
| Generate a Pdf | Member money statement PDF |
| Profile, Notifications, Logout, Contact, About Developer | App bar actions |

Payment methods: `Nogod`, `Bkash`, `Cash Money`, `cheque`, `Upay`, `Bank`.

### Member (User)
- Home dashboard (balance, menu)
- **Transaction Report** — own money record history
- Members List, Profile, About us
- Notification bell (unread count)

### Monthly Money Receipt + Thermal Printing
```
Admin Home → Money Receipt → Search Member ID → Select Month (e.g. September 2026)
   → View Receipt → preview with transactions + total
   → Select Bluetooth Printer → Connect → Test Print → Print Receipt
```
- Real **ESC/POS** bytes (not a screenshot): bold title/total, centered header,
  separators, feed + cut
- Paper sizes: **58 mm (32 chars, default)** and **80 mm (48 chars)**
- Printers: **58 mm / 80 mm Bluetooth thermal printers** (pair in phone settings first)
- Graceful states: no data, permission denied, Bluetooth off, connect/print failure
- **Web:** printer section is hidden automatically (conditional import — the
  Bluetooth plugin is never compiled into web builds)

---

## Tech stack

| Layer | Packages |
|---|---|
| State / navigation | `get` (GetX: routes, bindings, `Obx`, controllers) |
| Backend | `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage` |
| UI | `flutter_screenutil`, `fluttertoast`, `cached_network_image`, `badges` |
| Documents | `pdf`, `printing` (PDF generation) |
| Thermal printing | `print_bluetooth_thermal` (ESC/POS over Bluetooth) |
| Misc | `intl`, `uuid`, `shared_preferences`, `image_picker`, `url_launcher`, `http` |
| Tests | `flutter_test`, `mocktail` |

---

## Project structure

```
lib/
├── main.dart                  # Firebase + CacheHelper + ScreenUtilInit + GetMaterialApp
├── auth/                      # Login / Register / forgot password (data → domain → presentation)
│   ├── binding/               #   AuthBinding (fenix controllers)
│   ├── data/                  #   AuthRepositoryImpl, auth remote datasource, rollback
│   ├── domain/                #   repository interface, entities
│   └── prasentation/          #   login/register screens + controllers
├── admin/
│   ├── home/                  #   AdminHomeScreen (dashboard tiles), binding, controller
│   ├── save_money/            #   add money (service, user model, screen)
│   ├── receipt/               #   ★ Monthly Money Receipt + Bluetooth printing
│   │   ├── model/             #     ReceiptData, ReceiptPaperSize (mm58/mm80)
│   │   ├── service/           #     ThermalPrinterService (+ io/stub/factory), ReceiptPrintService (ESC/POS)
│   │   ├── controller/        #     AdminMonthlyReceiptController
│   │   ├── binding/           #     AdminMonthlyReceiptBinding
│   │   └── screen/            #     AdminMonthlyReceiptScreen
│   ├── monthly_report/        #   monthly transactions report
│   ├── monthly_paid&unpaid_report/
│   ├── userlist/  id_list/  id_create/  delete_User/  edit_data/
│   ├── moneydelete/  log/  notification/  pdf/  profile/
├── user/
│   ├── home/                  #   member dashboard
│   ├── money record/          #   MoneyRecord model, repository, user transactions screen
│   ├── userlist/  profile/  notification/  about_us/
├── core/
│   ├── routes/                #   app_routes.dart, app_pages.dart (GetPage + bindings)
│   ├── services/              #   FirestoreService, FirebaseAuthService, CacheService
│   ├── cachehelper/           #   CacheHelper, theme (somitiTheme), toast
│   └── widgets/               #   CustomTextField, CustomTextFieldPassword
├── contact/  developer/  forgot_password/  res/ (text styles & sizes)
```

**Conventions**
- GetX only — controllers own all Firestore and Bluetooth logic; **widgets never do**
- Repository pattern for data (`domain/…Repository` + `data/…RepositoryImpl`)
- Services for focused operations (`SavingMoneyService`, `MonthlyService`, …)
- New dependencies are wired in **bindings**, injected into controllers

---

## Getting started

### Prerequisites
- Recent Flutter (Dart `^3.10.1`), Android SDK
- A Firebase project (this repo already contains `android/app/google-services.json`
  for `com.faysal.agragami`)

### Firebase setup (when creating a fresh backend)
1. Create a Firebase project → add an **Android app** with package
   `com.faysal.agragami`
2. Download `google-services.json` → `android/app/google-services.json`
3. Enable **Authentication → Email/Password**
4. Create **Cloud Firestore** and **Storage** (profile images)
5. Deploy security rules from the Firebase Console (see below)

### Run

```bash
flutter pub get
flutter run
```

### Verify

```bash
flutter analyze        # 0 errors
flutter test           # 74 tests (auth + widget + receipt formatter)
flutter build apk --debug
```

---

## Routes & navigation

`lib/core/routes/app_routes.dart` + `app_pages.dart`:

| Route | Page | Binding |
|---|---|---|
| `/login` | `LoginScreen` | `AuthBinding` |
| `/adminHome` | `AdminHomeScreen` | `AdminHomeBinding` |
| `/home` | `HomeScreen` | `HomeBinding` |
| `/moneyRecord` | `UserMoneyRecordScreen` | `MoneyRecordBinding` |
| `/monthlyReport` | `MonthlyReportPage` | `MonthlyReportBinding` |
| `/monthlyPaidUnpaidReport` | `MonthlyPaidUnpaidReportPage` | `MonthlyPaidUnpaidReportBinding` |
| `/adminMonthlyReceipt` | `AdminMonthlyReceiptScreen` | `AdminMonthlyReceiptBinding` |

- `AppPages.getInitialRoute()` picks the start route by login + role.
- Some admin sub-screens are pushed with `Get.to(...)` (project convention);
  the receipt screen uses `Get.toNamed(...)` with its own `GetPage` binding.

---

## Firestore data model

```
users/{userDocId}
  name, email, role ('admin' | 'user'), user_id (AG26M001), phone,
  profileImage, blood group, address, nominee …
  payment_status: { "2026-09": true, … }      # month key = yyyy-MM
  total_amount
  │
  ├── Money/{moneyDocId}
  │     amount (double), payment_method, date&time (transaction date),
  │     create_time (Timestamp), received_by, total_amount (running month total)
  │
  ├── Log/{logId}
  │     name, email, userid, oldData, newData, note, timestamp
  │
  └── notification/{id}
        seen (bool), datetime, …

auth/{authId}
  ├── admin/{userId}        # ID registry entries
  └── user/{userId}
```

**Source of truth for monthly money:** the per-transaction
`users/{userDocId}/Money` documents (filtered by `date&time` inside the month).
There is **no separate `monthly_collection` collection** — the receipt feature
reads the same `Money` docs the rest of the app writes.

**Security rules** live in the Firebase Console (no `.rules` file in this repo).
Requirements: authenticated admin read/write on `users` (+ `Money`, `Log`,
`notification`); members read only their own data. Keep rules role-based —
never ship `allow read, write: if true`.

---

## Bluetooth thermal printing

- **Package:** [`print_bluetooth_thermal`](https://pub.dev/packages/print_bluetooth_thermal) `^1.2.4`
  (raw ESC/POS bytes → `writeBytes`)
- **Architecture** (UI stays clean):

  ```
  ThermalPrinterService (abstract)
        ↑ io impl / web stub (conditional import)
  ReceiptPrintService  → builds ESC/POS bytes from ReceiptData
        ↑
  AdminMonthlyReceiptController
        ↑
  AdminMonthlyReceiptScreen
  ```

- **Permissions (Android)**
  - `BLUETOOTH`, `BLUETOOTH_ADMIN` → `maxSdkVersion="30"`
  - `BLUETOOTH_SCAN` (`neverForLocation`) + `BLUETOOTH_CONNECT` → Android 12+;
    runtime dialog is triggered by the plugin on first *Select Printer* / *Connect*
  - iOS: `NSBluetoothAlwaysUsageDescription` + `NSBluetoothPeripheralUsageDescription`
- **Pairing:** the printer must already be paired in the phone's Bluetooth
  settings — *Select Printer* lists paired devices (no location permission used).
- **Formatting helpers** (single source of truth in `ReceiptPrintService`):
  `centerText`, `leftRightText`, `keyValueText`, `separator`, `formatAmount`
  (`1000 → 1,000`, `125000.5 → 125,000.50`), `formatDate` (`dd-MM-yyyy`),
  `transactionRow`, `buildReceipt`, `buildTestPrint`
- **Receipt organisation name:** `appOrganizationName = 'Agragami'` in
  `lib/admin/receipt/model/receipt_data.dart` — change it there if the printed
  header should differ.
- **Paper width:** default `ReceiptPaperSize.mm58` (32 chars/line);
  every line is guaranteed to fit (covered by tests).

---

## Testing

```bash
flutter test                                    # all tests
flutter test test/admin/receipt_print_service_test.dart
flutter test --plain-name "Registration Successful"
```

- `test/auth/` — repository (mocktail), controllers, register/login widget tests
- `test/widget_test.dart` — real `LoginScreen` inside `ScreenUtilInit` + `GetMaterialApp`
- `test/admin/receipt_print_service_test.dart` — 18 tests for amount/date
  formatting, 58 mm/80 mm line widths, ESC/POS framing (init / feed / cut),
  bold & centered lines, test print
- Helpers: `FakeAuthRepository`, `expectSnackbar(...)`, RenderFlex overflow filter
  (test-font artifact), no real Firebase calls anywhere

---

## Notes & known limitations

- ✅ `flutter analyze` → **0 errors** (remaining messages are pre-existing
  warnings/infos: `print(...)`, `withOpacity`, `DropdownButtonFormField.value`, …)
- ✅ `flutter build apk --debug` succeeds (manifest merge + printer plugin compile)
- ⚠️ **Physical Bluetooth printing is not yet verified on a real printer** —
  bytes/logic are unit-tested; run *Test Print → Print Receipt* on a device with
  a paired 58 mm printer for final validation
- ⚠️ Flutter **Web** target is not fully configured in this repo (`web/index.html`
  missing); Bluetooth printing auto-hides on unsupported platforms
- ⚠️ First Android build after adding the printer plugin takes a few minutes
  (Gradle); Kotlin may print harmless incremental-compilation warnings

---

*Agragami — manage the Somiti, from membership to printed receipt.*
