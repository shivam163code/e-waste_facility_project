/// Authentication service — stores users in memory only.
/// No network calls, no Firebase Auth. Just local validation.
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  // In-memory user store: email → {password, name, phone, city}
  final Map<String, Map<String, String>> _users = {};

  // Currently logged-in user
  Map<String, String>? _currentUser;

  bool get isLoggedIn => _currentUser != null;
  Map<String, String>? get currentUser => _currentUser;

  /// Register a new user. Returns null on success, error message on failure.
  String? signUp({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? city,
  }) {
    final key = email.trim().toLowerCase();
    if (_users.containsKey(key)) {
      return 'An account with this email already exists.';
    }
    _users[key] = {
      'name': name.trim(),
      'email': key,
      'password': password,
      'phone': phone?.trim() ?? '',
      'city': city?.trim() ?? '',
    };
    _currentUser = _users[key];
    return null; // success
  }

  /// Login existing user. Returns null on success, error message on failure.
  String? login({required String email, required String password}) {
    final key = email.trim().toLowerCase();
    final user = _users[key];
    if (user == null) {
      return 'No account found with this email. Please sign up.';
    }
    if (user['password'] != password) {
      return 'Incorrect password. Please try again.';
    }
    _currentUser = user;
    return null; // success
  }

  void logout() {
    _currentUser = null;
  }
}
