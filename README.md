# ExpenseManager

Flutter classroom expense app using GetX and the Express/TypeScript API at
`/Users/zigron/Downloads/finance_api`. The active entry point is `lib/main.dart`
→ `LoginScreen`. Register, login, list, add, edit, date/location filtering and
logout use the real API. Filters run locally on freshly fetched expenses;
refresh clears the filter. Session state is in memory and resets on restart.

## Start the backend

```sh
cd /Users/zigron/Downloads/finance_api
npm install
# Configure the backend-only .env with DB_HOST, DB_PORT, DB_USER,
# DB_PASSWORD, DB_NAME, DB_SSL=true and PORT=3000.
# For the Aiven CA, set DB_SSL_CA_FILE=/absolute/path/to/ca.pem.
npm run build
npm start
```

`npm start` runs `dist/server.js`: rebuild after TypeScript changes.
Alternatively `npm run dev` watches the TypeScript source. The server binds to
`HOST` or `0.0.0.0`, with port from `PORT` or 3000. `0.0.0.0` is never an app URL.
A server already running on port 3000 was left untouched during integration;
restart it yourself after rebuilding to use the backend fixes.

Backend changes catch rejected database queries (Express 4), return sanitized
JSON failures, retain MySQL DATE fields as `YYYY-MM-DD`, and verify database TLS
certificates. Supply the trusted provider CA using `DB_SSL_CA_FILE` if the system
trust store does not trust the database certificate. Do not bypass verification.
The async error wrapper follows the [Express 4 error-handling guidance](https://expressjs.com/en/4x/guide/error-handling/).

## Run Flutter

Set the backend URL directly in `lib/network/api_client.dart`:

```dart
const String apiBaseUrl = 'http://localhost:3000/api';
```

Use `localhost` for the iOS simulator on the backend Mac, `10.0.2.2` for the
Android emulator, or your Mac's reachable LAN IP/hostname for a physical phone.
For a hosted backend, use its HTTPS URL ending in `/api`.

```sh
flutter pub get
flutter run
```

Restart the app after changing the URL. No `--dart-define` is needed.

Android already has INTERNET permission; HTTP cleartext is allowed only in the
debug manifest. Use HTTPS for release builds. iOS permits local networking only
through `NSAllowsLocalNetworking`, and includes a local-network usage description;
there is no global ATS bypass. On a physical iPhone use a reachable Mac `.local`
hostname or HTTPS if numeric-IP HTTP is rejected by ATS. Native device flows
have not been executed here. For phones, check the server's listening interface
(`lsof -nP -iTCP:3000 -sTCP:LISTEN`) and allow the backend process through the Mac
firewall for the trusted local network; do not broadly disable the firewall.

The current backend uses `cors()`, which permits the development origin above.
Use a suitable explicit origin policy before any deployment. An HTTPS web app
must use an HTTPS API to avoid mixed-content blocking. The existing Places/Maps
feature still needs its platform-specific Maps configuration and permissions.

## Verified source contract

All routes return JSON `{ "success": boolean, "message": string, "data": ... }`.
Errors omit `data`. No successful route currently has an empty response body.

| Request | Body/query | Success data / status |
|---|---|---|
| POST `/api/register` | `{name,email,password}` | `{id,name,email}` / 201 |
| POST `/api/login` | `{email,password}` | `{id,name,email}` / 200 |
| GET `/api/expenses?userId=<returned-user-id>` | Query user ID | SQL row array / 200 |
| POST `/api/expenses` | `{userId,title,amount,location,expenseDate}` | CamelCase object including inserted `id` / 201 |
| PUT `/api/expenses/<selected-expense-id>` | Same as create, including userId | CamelCase object including `id` / 200 |

Missing required fields return 400, invalid login 401, duplicate email 409,
and update with no matching expense/user 404. Database errors now return 500
without exposing SQL or credentials. The UI maps errors to safe actionable
messages, uses a shared owned HTTP client and a 15-second timeout, and never
retries a save automatically. After a timeout, refresh before repeating the save.

Example list response (illustrative IDs, not actual test results):

```json
{"success":true,"message":"Expenses fetched successfully","data":[
  {"id":7,"user_id":42,"title":"Lunch","amount":"12.30","location":null,
   "expense_date":"2026-10-26","created_at":"2026-10-26T10:00:00.000Z"}
]}
```

Example create/update body (use the actual login user ID):

```json
{"userId":42,"title":"Lunch","amount":12.30,"location":"Campus",
 "expenseDate":"2026-10-26"}
```

Login example: `{"email":"student@example.test","password":"<test-password>"}`.
Register adds `"name":"Student"`. Passwords are sent only for these requests
and are never persisted by the Flutter client. The returned user populates
GetX session state; logout clears the user and expense controller. List parsing
accepts decimal strings or JSON numbers, treats null location as empty display
text, and requires calendar dates. `created_at` is unused metadata. The existing
double amount representation is preserved; it is not an exact-money ledger.

DATE serialization is explicitly fixed in the backend with `dateStrings: ['DATE']`.
The UI sends the selected calendar components without UTC conversion. List row
fields/nullability and statuses were confirmed in source; a successful live
response remains unverified because the database TLS handshake currently fails.

## Classroom limitations

The backend compares/stores plaintext passwords and issues no token or session.
A local user ID is **not server authentication**; callers can submit another
user's ID, so this demo does not provide secure authentication or user isolation.
Do not use real credentials or production financial data. Authentication redesign
is outside this integration. Rotate the Aiven password exposed in the earlier
screenshot/history; no cloud account was accessed or changed.

There is no DELETE route. The unused mock-only delete repository/controller
methods were removed; the current UI had no delete action. No deletion endpoint
was invented and no database data was deleted. Mock fixtures and the older
unrouted `lib/login.dart` teaching screen remain unrelated examples, not the
active session or storage path. Flutter no longer depends on mysql_client or
contains its database connection configuration.

## Verification

```sh
flutter analyze
flutter test
flutter build web

# Only against an explicitly approved disposable test database:
python3 scripts/verify_api.py --allow-test-writes --base-url http://localhost:3000/api
```

The Python script creates a uniquely named test user and one test expense, checks
register/login/failed login/malformed input/empty list/create/edit/list-after-edit,
and prints actual returned IDs. It retains records because no cleanup route exists.
Never run it against a production database.

Executed during integration:

- `dart format` on changed Dart files.
- `flutter test`: seven tests passed, covering parsing, request user/expense IDs,
  error envelopes, non-JSON/empty bodies, timeout without retry, offline behavior,
  stale-response/session clearing, login form validation and registration navigation.
- `flutter build web`: succeeded (including Wasm dry run).
- `flutter analyze`: five pre-existing diagnostics in legacy `lib/login.dart`
  (unused imports/locals and print); no integration diagnostics remain.
- Backend `npm run build`: passed.
- Rebuilt server tested on port 3001, leaving the existing port 3000 server alone.
  Missing login fields and malformed JSON returned 400; root returned 200 after
  a database-backed registration returned a handled 500. Direct `SELECT 1`
  diagnosed `HANDSHAKE_SSL_ERROR`; no sensitive diagnostic body was printed.
- Live register/login/list/add/edit assertions did not complete. No user or expense
  IDs were returned. Supply a trusted database CA and rerun the approved script.
- No native target build or device flow was claimed. Nothing was committed,
  pushed, published or deployed.
