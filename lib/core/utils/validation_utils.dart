class ValidationUtils {
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  static bool isStrongPassword(String password) {
    return password.length >= 8 &&
        RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'[a-z]').hasMatch(password) &&
        RegExp(r'[0-9]').hasMatch(password);
  }

  static bool isValidPhoneNumber(String phone) {
    final phoneRegex = RegExp(r'^[+]?[(]?[0-9]{3}[)]?[-\s]?[0-9]{3}[-\s]?[0-9]{4,6}$');
    return phoneRegex.hasMatch(phone);
  }

  static bool isValidURL(String url) {
    final urlRegex = RegExp(
      r'^(http|https):\/\/[^\s/$.?#].[^\s]*$',
      caseSensitive: false,
    );
    return urlRegex.hasMatch(url);
  }

  static String? validateEmail(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Email is required';
    }
    if (!isValidEmail(value!)) {
      return 'Invalid email format';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Password is required';
    }
    if (value!.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!isStrongPassword(value)) {
      return 'Password must contain uppercase, lowercase, and numbers';
    }
    return null;
  }
}
