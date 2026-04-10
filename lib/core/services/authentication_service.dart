// Dummy implementation for web compatibility
class AuthenticationService {
  static final AuthenticationService _instance = AuthenticationService._internal();

  factory AuthenticationService() {
    return _instance;
  }

  AuthenticationService._internal();

  void initialize() {
    // No-op for web
  }

  Future<void> signUpWithEmail(String email, String password) async {
    // Not implemented for web
  }

  Future<void> loginWithEmail(String email, String password) async {
    // Not implemented for web
  }

  Future<void> signInAnonymously() async {
    // Not implemented for web
  }

  Future<void> logout() async {
    // Not implemented for web
  }

  Future<void> sendEmailVerification() async {
    // Not implemented for web
  }

  Future<void> sendPasswordResetEmail(String email) async {
    // Not implemented for web
  }

  bool get isLoggedIn => false;

  String? get currentUserId => null;

  dynamic get currentUser => null; // Returns null for web

  Stream<dynamic> get authStateChanges => Stream.empty();
}
