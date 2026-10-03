# Agragami — Somiti Management App

A Flutter application for running an **Al-Falah Somiti (savings society)** — admins
collect monthly savings from members, track who paid and who didn't, generate
reports/PDFs, send notices, keep an audit trail, and print **monthly money
receipts on a Bluetooth thermal printer**. Members can follow their own
transactions, download/share a personal statement PDF, and read notices.

Built with **Flutter + GetX + Firebase** (Auth, Firestore, Storage), green Material
theme (`#2E7D32`) for the admin side / red accent for the member side, responsive
via `flutter_screenutil` (design size `360 × 690`).

| | |
|---|---|
| **Dart package name** | `Agragami` (capital **A** — import as `package:Agragami/...`) |
| **Android applicationId** | `com.faysal.agragami` |
| **Dart SDK** | `^3.10.1` |
| **Orientation** | Portrait (locked in `main.dart`) |
| **State / navigation** | GetX (`get ^4.7.3`) — controllers, bindings, `Obx`, routes |
| **Backend** | Firebase Auth + Cloud Firestore + Firebase Storage |

---

## Table of contents

- [Features at a glance](#features-at-a-glance)
- [Authentication & session](#authentication--session)
- [Admin features](#admin-features)
- [Member (user) features](#member-user-features)
- [Hidden developer feature (3-tap unlock)](#hidden-developer-feature-3-tap-unlock)
- [Documents: PDF & printing](#documents-pdf--printing)
- [Tech stack](#tech-stack)
- [Project structure](#project-structure)
- [Routes & navigation](#routes--navigation)
- [Firestore data model](#firestore-data-model)
- [Security rules & indexes](#security-rules--indexes)
- [Bluetooth thermal printing](#bluetooth-thermal-printing)
- [Getting started](#getting-started)
- [Testing](#testing)
- [Notes & known limitations](#notes--known-limitations)

---

## Features at a glance

| Area | Highlights |
|---|---|
| **Auth** | Login by member **ID or Email**, registration with full profile + photo, forgot password, admin/user role gate |
| **Session** | Cold start **always** lands on Login (stale role can never auto-enter); backgrounding never logs out; login ID prefilled from cache |
| **Admin dashboard** | Greeting, live **Total Members** count, live **Balance** (Tk) card, 12 menu tiles, notification bell with unread badge |
| **Money collection** | Search member → add money (amount / payment method / date / received-by) → edit entry; running month total + `payment_status` updated |
| **Reports** | Monthly Report (transaction table), Paid & Unpaid Report (summary cards + tabs + **WhatsApp reminders**) |
| **Receipts** | Member + month → receipt preview → **Bluetooth thermal print** (ESC/POS, 58 mm / 80 mm) |
| **Documents** | Admin financial report PDF (print/share); member **My Transactions** PDF (view / download / share) with empty-list guard |
| **Notice board** | Admin posts notices → all members get them with unread badge, tap-to-read |
| **Audit log** | Real-time `users/{adminId}/Log` — who did what, old vs new values |
| **ID registry** | Create / edit / list / delete user-ID entries (`auth/.../user`), copy-to-clipboard |
| **Member side** | Home balance, transaction report, members list, profile, about us, notifications from every admin |
| **Hidden** | Developer screen **3-tap secret** unlocks “Delete All Money Records” on Admin Home (admin-only) |

---

## Authentication & session

### Login (`lib/auth/prasentation/screen/login_screen.dart`)
- **One “ID/Email” field** + password:
  - contains `@` → validated as an email
  - otherwise validated as a member ID: `^AG\d{2}[MA]\d{3}$` (e.g. `AG26M001`, `AG26A001`)
- **ID → email resolution:** logging in with an ID first looks up `users` by
  `user_id`, then performs the Firebase Auth sign-in with the resolved email.
- **Role gate after login:** `admin` → `/adminHome`, `user` → `/home`
  (`Get.offAllNamed`), anything else → “Login Failed”.
- The ID field is **prefilled** from the cached `userId` key.
- **Forgot Password?** → dedicated screen: verifies the email exists in `users`
  first (“No account found with this email.”), then sends the Firebase reset
  link and shows a human-readable result (invalid email, etc.).

### Registration (two-stage)
1. **Find ID** — enter the member ID the admin issued; the app checks the
   `auth` registry (collection-group lookup over `auth/admin` + `auth/user`).
   Unknown ID → “User ID not found”. Known ID → the form opens with the ID
   locked and the entry’s role adopted.
2. **Form** — profile photo (required), name, email, mother/father name,
   phone (Bangladesh validator `^(?:\+?88)?01[3-9]\d{8}$`), birth date,
   NID (10–17 digits), address, blood group, nominee name + relation,
   password (≥ 8) + confirm.
3. On success: Firebase Auth account + Storage image
   (`profile_images/{userId}.jpg`) + `users/{uid}` document are created,
   with **full rollback** (deletes the Firestore doc and the Auth user) if any
   step fails; the registry entry is marked `user: 'done'`. The login field is
   then prefilled with the new ID.

Validators live in one place: `lib/auth/prasentation/widgets/appValidators.dart`.

### Session behaviour (`lib/core/session/session_guard.dart`)
- **Cold start always → Login.** `AppPages.getInitialRoute()` returns the login
  route unconditionally and `SessionGuard.invalidatePreviousSession()` (run once
  from `main()`) drops the cached session + best-effort Firebase sign-out.
  A stale `isRole` is deliberately never consulted for routing.
- **Background / foreground / app-switcher never logs out** — same process, the
  user stays exactly where they were.
- Process death (swipe-away, OOM kill, crash, reboot) → next launch is a new
  process → Login. `clearSession()` keeps `userId` + `userDocId` (login prefill,
  doc rewrites on next login) and removes `isLoggedIn` + `isRole`.

**Cache keys in use** (`CacheHelper`, SharedPreferences):
`userId`, `userDocId`, `isRole`, `isLoggedIn`, `names`, `email`, `adminId`
(= `user_id`, needed by admin screens’ `getName()` and the audit log),
`moneyDocID`, `noteDocRef`, `logDocRef`.
`CacheService.saveUserData()` writes `isRole`, `names`, `email`, `adminId`,
`userDocId` at every login — only non-empty values, so a missing Firestore
field can never crash the login.

---

## Admin features

**Admin Home** (`lib/admin/home/`) — green dashboard:

- Greeting with cached **name + user ID**
- Stat row: **Total Members** (live count) and **Balance `… Tk`** card fed by a
  single real-time `collectionGroup('Money')` sum across all members
- App bar: avatar → Profile · bell → **notification inbox** (unread badge) ·
  actions menu → Logout / Profile / Contact / About Developer

### Dashboard tiles

| Tile | What it does |
|---|---|
| **Saving Money** | Search a member by ID → member card → **Add Money**: amount, **payment method** (`Nogod`, `Bkash`, `Cash Money`, `cheque`, `Upay`, `Bank`), date picker, “Received By / In Name”. Writes `users/{id}/Money`, stamps `payment_status.{yyyy-MM} = true` and `total_amount` on the user doc, computes the **running month total**, then writes an audit-log entry. An **Edit Money** button appears after saving → Edit screen (amount, date **+ time**, method, received-by). |
| **Members List** | Live list of every `role == 'user'` member (avatar tap = full-screen photo) → tap opens **User transaction history**: full profile, streamed money list, live **Balance Tk**, copy Money ID. |
| **Monthly Report** | Pick **Year + Month** → one server-side `collectionGroup('Money')` query over `date&time` in the month range. DataTable: SL, User ID, Name, Money ID, Date, Amount (`৳`), Payment Method, Received By, Total Amount. Pull-to-refresh, loading/empty/error states, per-month request dedup. Also ships a `backfillUserFields()` maintenance helper that stamps `user_id`/`user_name` onto legacy Money docs. |
| **Paid & Unpaid Report** | Year + Month → **summary cards** (Total Members, Paid, Unpaid, **Total Collection ৳**) + tabs. **Paid** = same transaction table. **Unpaid** = card list (name, ID, phone) with a **WhatsApp reminder** button: normalises the BD phone to `880…`, builds a Bengali month-specific reminder, and opens `wa.me/{phone}?text=…`; already-notified members are marked in-session. Data source: each user’s `payment_status['yyyy-MM']`. |
| **Money Receipt** | Member ID → search card, Year + Month, **View Receipt** preview (transaction rows + totals + receipt no. `RC-YYMM-SSS`), then **Select Printer → Connect → Test Print → Print Receipt** (see [Bluetooth thermal printing](#bluetooth-thermal-printing)). |
| **Admin Log** | Real-time audit trail of **this admin’s** folder `users/{adminDocId}/Log`: Admin Name, Admin Email, Target User, Old, New, Action, Time — loading/error/empty/pending-timestamp states. Written by: Add Money, Money Delete, Edit Data, Create/Edit ID, Delete All Money, Notice Board. |
| **Delete Record** | User ID + Money ID → deletes that one money document (with audit log). |
| **Notice Board** | Title + message → writes to `users/{adminDocId}/notification` (`seen: false`) for every member + audit log. The bell inbox can read / **edit** / delete notices. |
| **User Id Create** | User_ID + role (member registry) → creates an `auth/{doc}/{role}` entry with duplicate check + audit log; an **Edit Create Id** dialog follows for ID/role changes. |
| **User Id List** | Merged live streams of `auth/admin` + `auth/user`, sectioned **ADMIN LIST / USER LIST**, sorted by ID, with **copy-to-clipboard** and delete (confirm dialog). |
| **Generate a Pdf** | “Agragami Financial Report”: enter **User Document ID** → verify → user info card + streamed transactions → **Generate PDF / Print PDF** (A4: logo header, user information box, transaction history table, totals, signature space) via `Printing.layoutPdf` / `Printing.sharePdf`. |
| **Delete All Money Records** ⭐ | **Hidden** — see [3-tap unlock](#hidden-developer-feature-3-tap-unlock). Enter User ID → confirm → deletes **every** money document of that member + audit log. Inside the screen a **“Hide Delete All Money Records”** button hides the tile again (and re-arms the secret). |
| **Profile** (app bar) | Edit name, email, parents, phone, NID, address, DOB, blood group, nominee; upload/replace photo (`profile_images/{userId}.jpg`); logout with confirm dialog. |

---

## Member (user) features

**Home** (`lib/user/home/`) — red-accent dashboard:

- Greeting with name + user ID; avatar → **Profile**
- **Balance card** — shows `… Tk` with its **own small spinner**
  (`isBalanceLoading`): the balance loads **in parallel**, never waits for the
  profile/cache, and a Firebase error can’t break the rest of the home screen
  (source: one `collectionGroup('Money')` sum).
- Bell → **Notifications** (unread badge across *all* admins) · popup menu →
  **My Transactions, Logout, Contact, About Developer**

| Tile | What it does |
|---|---|
| **Transaction Report** | “Total Balance” gradient banner (`৳` sum) + DataTable (SL, Amount, Method, Date & Time, Received By, Money ID with copy) + monthly cumulative totals; empty state included. |
| **Members List** | Live list of all members with avatars (full-screen photo on tap). |
| **Profile** | Same editable profile as admin (own fields, photo, updated_at), logout with confirm. |
| **About us** | “আমাদের সম্পর্কে” / “আমাদের লক্ষ্য” — mission & goals content. |
| **My Transactions** | Self statement PDF: **Generate PDF** → if there are no transactions it shows *“No Transactions Yet — You don't have any transactions yet. A PDF report can be generated once a transaction is available.”* and **never** generates an empty PDF; otherwise **View** (in-app preview) / **Download** (`Downloads/Agragami/Agragami_Transactions_yyyyMMdd_HHmm.pdf` via MediaStore) / **Share** (share sheet). No user-ID input — always the signed-in member. |

**Notifications** — grouped by “Admin: {id}”, newest first, unread blue /
seen grey; tap = read dialog + mark-as-seen; empty state included.

---

## Hidden developer feature (3-tap unlock)

Admin-only secret on the **About Developer** screen:

1. Admin Home → menu → **About Developer** → `DeveloperScreen`
2. Tap **“Developer Info!”** heading **3 times**:
   - tap 1 → snackbar `click 1`
   - tap 2 → `click 2`
   - tap 3 → `delete button open` — and a **“Delete All Money Records”**
     tile appears at the end of the Admin Home dashboard
3. The tile opens `DeleteUserScreen`; its **“Hide Delete All Money Records”**
   button hides the tile again and re-arms the secret (tap ×3 to reopen).

Why it’s admin-only: the tap handler runs only when `AdminHomeController` is
registered — member sessions simply no-op. The delete operation itself is a
separate, explicit confirm-then-delete flow.

---

## Documents: PDF & printing

| Feature | Output | Packages |
|---|---|---|
| **Generate a Pdf** (admin) | A4 financial report of one member — logo header, user info, transaction table, totals, signature | `pdf` + `printing` (layout/share) |
| **My Transactions** (member) | A4 member statement — red-bordered header, member box, table, summary, signature; view / download / share | `pdf`, `printing`, `media_store_plus`, `share_plus` |
| **Money Receipt** (admin) | Real **ESC/POS bytes** to a Bluetooth thermal printer (58 mm / 80 mm) | `print_bluetooth_thermal` |

---

## Tech stack

| Layer | Packages |
|---|---|
| State / navigation | `get` (GetX: routes, bindings, `Obx`, controllers) |
| Backend | `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage` |
| UI | `flutter_screenutil`, `fluttertoast`, `cached_network_image`, `badges`, `flutter_native_splash`, `flutter_launcher_icons` |
| Documents | `pdf`, `printing`, `share_plus`, `media_store_plus`, `path_provider` |
| Thermal printing | `print_bluetooth_thermal` (raw ESC/POS) |
| Misc | `intl`, `uuid`, `shared_preferences`, `image_picker`, `url_launcher`, `http`, `package_info_plus` |
| Tests | `flutter_test`, `mocktail` |

---

## Project structure

```
lib/
├── main.dart                  # Firebase + CacheHelper + SessionGuard + ScreenUtilInit + GetMaterialApp
├── auth/                      # Login / Register (binding, data, domain, prasentation)
│   ├── binding/               #   AuthBinding (fenix controllers)
│   ├── data/                  #   AuthRepositoryImpl, remote datasource, register rollback
│   ├── domain/                #   repository interface, LoginResult, RegisterRequest
│   └── prasentation/          #   login/register screens, controllers, validators, image picker
├── admin/
│   ├── home/                  #   AdminHomeScreen (dashboard tiles), binding, controller
│   ├── save_money/            #   add money (service, screen) → Edit Money
│   ├── edit_data/             #   edit an existing money entry
│   ├── delete_record/         #   delete one money record (User ID + Money ID)
│   ├── delete_All_Money_records/  # DeleteUserScreen: wipe a member's money + hide button
│   ├── receipt/               #   ★ Monthly Money Receipt + Bluetooth printing
│   │   ├── model/             #     ReceiptData, ReceiptPaperSize (mm58/mm80)
│   │   ├── service/           #     ThermalPrinterService (+ io/stub/factory), ReceiptPrintService (ESC/POS)
│   │   ├── controller/        #     AdminMonthlyReceiptController
│   │   ├── binding/           #     AdminMonthlyReceiptBinding
│   │   └── screen/            #     AdminMonthlyReceiptScreen
│   ├── monthly_report/        #   monthly transactions report (collectionGroup query + backfill)
│   ├── monthly_paid&unpaid_report/  # summary + paid table + unpaid WhatsApp reminders
│   ├── userlist/ id_list/ id_create/
│   ├── log/                   #   Audit log (service, model, real-time screen)
│   ├── notification/          #   Notice Board + admin notification inbox
│   ├── pdf/                   #   "Agragami Financial Report" generator
│   └── profile/
├── user/
│   ├── home/                  #   member dashboard (balance race, tiles, bell, popup menu)
│   ├── money record/          #   Transaction Report (note: folder name has a space)
│   ├── transactions/          #   My Transactions PDF (generate/view/download/share + empty guard)
│   ├── userlist/ profile/ notification/ about_us/
├── core/
│   ├── routes/                #   app_routes.dart, app_pages.dart (GetPage + bindings)
│   ├── session/               #   SessionGuard (cold-start invalidation)
│   ├── services/              #   FirestoreService, FirebaseAuthService, CacheService
│   ├── cachehelper/           #   CacheHelper, theme (somitiTheme), toast
│   └── widgets/               #   CustomTextField, CustomTextFieldPassword
├── contact/  developer/       #   Contact image screen; Developer info + 3-tap secret
├── forgot_password/           #   email reset flow
├── res/                       #   AppColors, AppSize, AppSpacing, AppTextStyles
└── widgets/
```

**Conventions**
- **GetX only** — controllers/services own all Firestore and Bluetooth logic;
  widgets never touch Firebase.
- Repository pattern for data (`domain/…Repository` + `data/…RepositoryImpl`)
  and focused services (`SavingMoneyService`, `MonthlyService`, `LogService`, …).
- New dependencies are wired in **bindings** (or `Get.put` in the screen) and
  injected into controllers — no service locators inside widgets.
- Screens push sub-screens with `Get.to(...)`; feature dashboards use named
  routes with their own `GetPage` bindings.

---

## Routes & navigation

`lib/core/routes/app_routes.dart` + `app_pages.dart` (all `Transition.fadeIn`):

| Route | Page | Binding |
|---|---|---|
| `/login` | `LoginScreen` | `AuthBinding` |
| `/adminHome` | `AdminHomeScreen` | `AdminHomeBinding` |
| `/home` | `HomeScreen` | `HomeBinding` |
| `/moneyRecord` | `UserMoneyRecordScreen` | `MoneyRecordBinding` |
| `/monthlyReport` | `MonthlyReportPage` | `MonthlyReportBinding` |
| `/monthlyPaidUnpaidReport` | `MonthlyPaidUnpaidReportPage` | `MonthlyPaidUnpaidReportBinding` |
| `/adminMonthlyReceipt` | `AdminMonthlyReceiptScreen` | `AdminMonthlyReceiptBinding` |
| `/myTransactions` | `MyTransactionsScreen` | `MyTransactionsBinding` |

- `AppPages.getInitialRoute()` **always returns `/login`** (see
  [Authentication & session](#authentication--session)).
- Register, Forgot Password and most admin sub-screens are pushed with
  `Get.to(...)`; member screens (Profile, Notifications, About us, Contact,
  Developer) use `Navigator.push`.
- `AppRoutes` also declares a few unused legacy constants (`/skills`,
  `/projects`, …) with no registered page.

---

## Firestore data model

```
users/{userDocId}
  uid, name, email, fatherName, motherName, role ('admin' | 'user'),
  user_id (AG26M001), phone, address, birthdate, blood, nid,
  nomineeName, nomineeRelation, profileImage, created_at, updated_at,
  payment_status: { "2026-09": true, … },     # month key = yyyy-MM
  total_amount
  │
  ├── Money/{moneyDocId}
  │     user (DocumentReference), user_id, user_name, amount (double),
  │     payment_method, 'date&time' (transaction date), create_time,
  │     received_by, total_amount (running month total), collection_date (legacy)
  │
  ├── Log/{logId}                          # audit trail (admin-only)
  │     name, email, user_id (TARGET of the action),
  │     oldData, newData, notification (the action note), datetime
  │
  └── notification/{id}
        title, message, datetime, seen (bool)

auth/{authDocId}
  ├── admin/{entryId}     # ID registry: user_id, user ('done' after signup), role
  └── user/{entryId}

Storage: profile_images/{userId}.jpg
```

**Identity convention in the audit log:** `users/{adminDocId}/Log` — the folder
is always **the admin who acted** (from the cached `userDocId`), while the
`user_id` field inside the document is the **target** the action affected.

**Source of truth for money:** the per-transaction `users/{docId}/Money`
documents. Monthly report, paid/unpaid, receipt, PDFs and both balance cards
all read those same docs (via `collectionGroup('Money')` where a cross-member
view is needed) — there is no duplicate collection.

---

## Security rules & indexes

Committed at the repo root (deploy them — they are **not** live until deployed):

| File | Purpose |
|---|---|
| `firestore.rules` | Role-based rules (see below) |
| `firestore.indexes.json` | `Money` **collection-group** index on `date&time` DESC (required by the Monthly Report query) |
| `firebase.json` | Wires the two files for the Firebase CLI |
| `.firebaserc` | Default project `agragamiapp` |

`firestore.rules` summary:

- `users/{userId}` — public `get/list` (pre-login ID/email lookup + members
  list), create/delete owner-or-admin, update admin-or-owner with a
  **safe-field diff** (self-changes to `role|uid|user_id` are blocked).
- `users/{id}/Money` — **read owner|admin, write admin only** (the
  security-critical rule).
- `users/{id}/Log` — **admin only**.
- `users/{id}/notification` — owner/admin read-write, `ownerIsAdmin` helper.
- `auth/...` — reads open (registry has no secrets), writes admin-only, except
  a member may flip **only their own** entry’s `user` field to `'done'`.
- `delete_users/...` — reserved admin-only.
- Catch-all `match /{document=**}` → deny.

Deploy:

```bash
firebase login
firebase deploy --only firestore:rules
firebase deploy --only firestore:indexes
```

> The CLI account must have **owner/access** to project `agragamiapp`,
> otherwise use the console “create index” links Firestore prints on
> `failed-precondition`.

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

- **Flow:** Member ID → Search → Year/Month → **View Receipt** → **Select
  Printer** (paired devices) → **Connect** → **Test Print** → **Print Receipt**
- **Permissions (Android)**
  - `BLUETOOTH`, `BLUETOOTH_ADMIN` → `maxSdkVersion="30"`
  - `BLUETOOTH_SCAN` (`neverForLocation`) + `BLUETOOTH_CONNECT` → Android 12+;
    the runtime dialog is triggered by the plugin on first *Select Printer* /
    *Connect*
  - iOS: `NSBluetoothAlwaysUsageDescription` + `NSBluetoothPeripheralUsageDescription`
- **Pairing:** the printer must already be paired in the phone’s Bluetooth
  settings — *Select Printer* lists paired devices (no location permission used).
- **Formatting helpers** (single source of truth in `ReceiptPrintService`):
  `centerText`, `leftRightText`, `keyValueText`, `separator`, `formatAmount`
  (`1000 → 1,000`, `125000.5 → 125,000.50`), `formatDate` (`dd-MM-yyyy`),
  `transactionRow`, `buildReceipt`, `buildTestPrint`
- **Receipt organisation name:** `appOrganizationName = 'Agragami'` in
  `lib/admin/receipt/model/receipt_data.dart` — change it there if the printed
  header should differ.
- **Paper width:** default `ReceiptPaperSize.mm58` (32 chars/line);
  every line is guaranteed to fit (covered by tests). `mm80` = 48 chars.
- **Web:** the printer section auto-hides (conditional import — the Bluetooth
  plugin is never compiled into web builds).

---

## Getting started

### Prerequisites
- Recent Flutter (Dart `^3.10.1`), Android SDK
- A Firebase project — this repo already ships
  `android/app/google-services.json` for `com.faysal.agragami`

### Firebase setup (fresh backend)
1. Create a Firebase project → add an **Android app** with package
   `com.faysal.agragami`
2. Download `google-services.json` → `android/app/google-services.json`
3. Enable **Authentication → Email/Password**
4. Create **Cloud Firestore** and **Storage** (profile images)
5. Deploy the committed rules + indexes (see
   [Security rules & indexes](#security-rules--indexes))

### Run

```bash
flutter pub get
flutter run
```

### Verify

```bash
flutter analyze        # 0 errors (infos/warnings are pre-existing)
flutter test           # 127 tests
flutter build apk --debug
```

---

## Testing

```bash
flutter test                                             # whole suite
flutter test test/admin/receipt_print_service_test.dart
flutter test --plain-name "No Transactions"
```

| File | Covers |
|---|---|
| `test/widget_test.dart` | Real `LoginScreen` (ScreenUtil + GetMaterialApp + `FakeAuthRepository`): prefill, validation, valid ID/email login, failed-login snackbar |
| `test/auth/fake_auth_repository.dart` | In-memory repository helper — **no Firebase in tests** |
| `test/auth/app_validators_test.dart` | Every validator (userId, email, password, BD phone, NID, nominee…) |
| `test/auth/auth_repository_test.dart` | Email/ID login, ID→email resolution, missing doc/fields resilience, register duplicate/success/**rollback**, logout; **session keys incl. `email`/`adminId`** |
| `test/auth/auth_controller_test.dart` | Login flow, session cache, admin→admin-home redirect, error snackbars, logout |
| `test/auth/register_controller_test.dart` | Find-ID flows, signup with image, duplicate-ID, ID prefill after register |
| `test/session/session_persistence_test.dart` | Cold start → Login always; **no auto-logout** on background/detached for all three controllers |
| `test/admin/admin_home_controller_test.dart` | **3-tap secret**: messages, unlock, flag persistence, hide/re-arm |
| `test/admin/receipt_print_service_test.dart` | ESC/POS bytes, amount/date formatting, 58 mm & 80 mm line fitting, init/feed/cut framing, test print |
| `test/admin/monthly_money_model_test.dart` | `MonthlyMoneyModel` parsing edge cases |
| `test/admin/log_model_test.dart` | Audit-log parsing (missing keys, pending `serverTimestamp`, junk types) |
| `test/user/home_controller_test.dart` | Balance loads in parallel, dedup, error containment, `isBalanceLoading` |
| `test/user/my_transactions_test.dart` | Sorting/totals, **empty-list guard** (no PDF generated), Generate → View/Download/Share |

Helpers: `FakeAuthRepository`, `expectSnackbar(...)`, RenderFlex overflow filter
(test-font artifact). No real Firebase or Bluetooth calls anywhere.

---

## Notes & known limitations

- ✅ `flutter analyze` → **0 errors** (remaining messages are pre-existing
  infos/warnings: `withOpacity`, `print(...)`, `use_build_context_synchronously`, …)
- ✅ `flutter test` → **127 passing**
- ⚠️ The `Money` collection-group index must be deployed before the **Monthly
  Report** query works (`failed-precondition` otherwise); same for rules —
  deploy them from the root files or the console.
- ⚠️ **Physical Bluetooth printing is not yet verified on a real printer** —
  bytes/logic are unit-tested; run *Test Print → Print Receipt* on a device
  with a paired 58 mm printer for final validation.
- ⚠️ Log entries written **before** the audit-log rewrite may show `-` for
  email/target; new entries are complete (session caches `email` + `adminId`
  at login).
- ⚠️ Notice Board / Notification logs intentionally have **no target user**
  (`Target User = -`).
- ⚠️ Flutter **Web** target is not fully configured (`web/index.html` missing);
  Bluetooth printing auto-hides on unsupported platforms.
- ⚠️ First Android build after adding the printer plugin takes a few minutes
  (Gradle); Kotlin may print harmless incremental-compilation warnings.

---

*Agragami — manage the Somiti, from membership to printed receipt.*
