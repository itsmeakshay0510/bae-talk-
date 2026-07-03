class AppRuntime {
  static bool firebaseReady = false;

  static bool get isDemoMode => !firebaseReady;
}
