# LinkUnity AI Coding Agent Instructions

## Project Overview

**LinkUnity** is a Flutter educational platform for managing student proposals and team collaborations. The app connects to a Node.js/Express backend (`https://leading-unity-backend.vercel.app/api`) and uses Provider for state management with secure token persistence.

## Architecture

### State Management (Provider Pattern)

- **AuthProvider** (`lib/auth_provider.dart`): Central state holder using `ChangeNotifier`
  - Manages authentication state: `_token`, `_user`, `isAuthenticated`
  - Handles login/registration/logout/token persistence via `flutter_secure_storage`
  - **Key pattern**: Wrap app in `ChangeNotifierProvider` in `main()`, use `Consumer<AuthProvider>` for navigation
  - Auto-login on startup via `tryAutoLogin()` retrieves stored credentials from secure storage

- **Models** (`lib/models/`):
  - `User`: Role-based (student/admin), parsed from backend `_id` field
  - `Proposal`: Student work submissions with status tracking
  - Both use `fromJson()` factory constructors for API response parsing

### API Layer

- **ApiService** (`lib/api services/api_services.dart`): HTTP client wrapper
  - Base URL: `https://leading-unity-backend.vercel.app/api`
  - Key endpoints:
    - `POST /auth/register/student` - 6 fields: name, email, password, studentId, batch, section
    - `POST /auth/login` - Returns token + user object
    - `GET /courses`, `GET /users` (supervisors)
  - Error handling: Throws exceptions with backend message or fallback text
  - **Note**: Token auth headers not yet consistently implemented; add `Authorization: Bearer $token` header when extending

### UI Navigation (Role-Based)

- **main.dart**: Entry point with Consumer routing
  - Route logic: `isAuthenticated` → `isStudent` → StudentDashboard (admin dashboard TODO)
  - Displays login/home selection screen for unauthenticated users

- **Student Flow**:
  - `home_page.dart`: Login/role selection screen
  - `student_dash.dart`: Main dashboard with nav buttons (submit proposal, request team, download template)
  - `student_login.dart`, `student_registration_screen.dart`: Auth screens
  - `submit_proposal.dart`: Proposal submission form

## Developer Workflows

### Running the App

```bash
flutter pub get                    # Install dependencies
flutter run -v                     # Run with verbose logging
flutter run --profile              # Release build for testing
```

### Common Development Tasks

- **Hot Reload**: `r` in terminal or Cmd+S in IDE (fast for UI changes)
- **Hot Restart**: `R` in terminal (required for Provider state changes, dependency updates)
- **Clean Build**: `flutter clean && flutter pub get && flutter run`
- **Analyze Code**: `flutter analyze` (uses `analysis_options.yaml` with flutter_lints)
- **Format Code**: `dart format lib/` (run before committing)

### Testing

- Widget tests in `test/widget_test.dart` (minimal coverage currently)
- Run: `flutter test` or `flutter test test/widget_test.dart`
- **No unit test framework** beyond flutter_test currently configured

### Building for Release

```bash
flutter build apk       # Android
flutter build ios       # iOS
flutter build windows   # Windows desktop
flutter build web       # Web (if enabled)
```

## Key Conventions & Patterns

### Imports & File Organization

- Use relative imports for local files: `import 'package:link_unity/models/user_model.dart';`
- Group imports: flutter imports, package imports, relative imports
- Screens in `/student`, `/admin` folders; models in `/models`; services in `/api services`

### Error Handling

- API methods throw exceptions with decoded JSON message or fallback
- UI catches with try/catch in async methods, shows SnackBar or AlertDialog
- **Gap**: No global error handling middleware; add error interceptor to ApiService for consistent UX

### Authentication Flow

1. App startup → `main()` calls `AuthProvider()..tryAutoLogin()`
2. Auto-login reads `token` and `user` from `flutter_secure_storage`
3. If credentials found, restores state and routes to dashboard; else shows login screen
4. On login/register, token stored securely; on logout, all data deleted

### JSON Serialization

- **Incoming**: Use `fromJson()` factory constructors (User, Proposal)
- **Outgoing**: Use `jsonEncode(<String, String>{...})` in ApiService
- **Backend ID field**: MongoDB returns `_id`, map to `id` in models

### Provider Usage

- **Read state**: `Provider.of<AuthProvider>(context, listen: false)` (one-time read)
- **Watch state**: `Consumer<AuthProvider>` in build tree (reactive)
- Call `notifyListeners()` after state mutations to trigger rebuilds

### UI Patterns

- Use `Scaffold` with `AppBar` + `FloatingActionButton` or action buttons
- Snackbars for toasts: `ScaffoldMessenger.of(context).showSnackBar(SnackBar(...))`
- TODO comments mark incomplete features: search for `// TODO:` to find gaps (e.g., admin dashboard)

## Integration Points & Dependencies

### External Services

- **Backend**: Node.js/Express at Vercel, REST API, no WebSocket or real-time features yet
- **Storage**: `flutter_secure_storage` (platform-specific: Keychain on iOS, Keystore on Android)
- **HTTP**: `package:http` for raw API calls (consider upgrading to `dio` for interceptors)

### Platform-Specific Code

- **Android**: `android/app/build.gradle` - no custom native code yet
- **iOS**: `ios/Runner/Info.plist` - no special permissions configured yet
- **Windows/Linux/macOS**: Generated Flutter boilerplate, not actively developed

## Common Pitfalls & Solutions

| Issue | Root Cause | Fix |
|-------|-----------|-----|
| State not updating after login | Forgot to call `notifyListeners()` in AuthProvider | Always call after `_token = ...` or `_user = ...` |
| Hot reload fails to show changes | Changed dependencies or Provider structure | Use hot restart (`R`) instead |
| Token not passed to API | ApiService headers don't include auth token | Add `'Authorization': 'Bearer ${token}'` header |
| User auto-login fails silently | Exception in `tryAutoLogin()` not logged | Add try/catch with print/logger in method |
| JSON deserialization errors | Backend field names differ from model (e.g., `student` vs `studentId`) | Check actual API response, update `fromJson()` mapping |

## TODOs & Known Gaps

- [ ] Admin dashboard UI (`AdminDashboardScreen` referenced but not implemented)
- [ ] Consistent auth token headers across all API endpoints
- [ ] Global error handling interceptor (currently per-method)
- [ ] Logging/debug infrastructure (uses `print()`, should add logger package)
- [ ] Unit tests for AuthProvider and ApiService
- [ ] API response status code checks (login endpoint checks 200, register checks 201; unify)
- [ ] Permission handling for Android/iOS (camera, storage, etc. if proposals include media)

## Quick Onboarding Checklist

When adding a new feature:

1. **Create model** in `lib/models/` with `fromJson()` factory
2. **Add API endpoint** in `lib/api services/api_services.dart`
3. **Add Provider method** in `lib/auth_provider.dart` (or create new provider if state is feature-specific)
4. **Create UI screen** in `lib/student/` or `lib/admin/`
5. **Update navigation** in `main.dart` or via `Navigator.push()`
6. **Test flow**: Register → Login → Navigate → Logout → Clean storage
7. **Run `flutter analyze`** and fix lints before commit
