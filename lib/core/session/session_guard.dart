import 'package:firebase_auth/firebase_auth.dart';

import '../cachehelper/chechehelper.dart';

/// Launch-time session validation.
///
/// Android **never delivers a reliable callback** when the app is killed —
/// most importantly when the user swipes it away from Recent Apps. The
/// process is simply SIGKILL'd: `onDestroy` is not guaranteed and Flutter's
/// `AppLifecycleState.detached` is *not* a reliable "app destroyed" signal
/// (it often never arrives, and it can also arrive in other situations).
/// There is no portable way to tell "swiped away" apart from "system killed
/// us for memory".
///
/// The only platform-independent, reliable signal is **process start**:
/// `main()` runs exactly once per fresh process. So instead of guessing *why*
/// the previous process died, this guard treats every cold start as a new,
/// unauthenticated launch:
///
/// ```text
///  background / foreground (paused, inactive, hidden, resumed)
///      -> same process, guard never runs  -> session kept, no logout
///
///  process death (swipe-away, OOM kill, crash, force stop, reboot)
///      -> next launch runs main() again  -> guard invalidates session
///      -> AppPages.getInitialRoute() returns the Login screen
/// ```
///
/// Because the guard only runs from `main()`, a plain Home-button press or
/// app-switch can **never** log the user out.
class SessionGuard {
  SessionGuard._();

  /// Drops the previous run's session so the app cold-starts into Login.
  ///
  /// * clears `isLoggedIn` + `isRole` via [CacheHelper.clearSession]
  ///   (`userId` / `userDocId` are intentionally kept: `userId` prefills
  ///   the login form, `userDocId` is rewritten by the next login anyway);
  /// * best-effort Firebase sign-out so the old Firebase Auth session does
  ///   not outlive the app session. Wrapped in try/catch: when there is no
  ///   session (or Firebase is not reachable yet) this is a safe no-op and
  ///   must never block app startup.
  static Future<void> invalidatePreviousSession() async {
    try {
      await CacheHelper().clearSession();
    } catch (_) {
      // Best-effort: never block startup.
    }

    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {
      // No Firebase session / platform not ready — nothing to invalidate.
    }
  }
}
