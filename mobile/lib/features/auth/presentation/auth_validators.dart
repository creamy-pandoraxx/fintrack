class AuthValidators {
  const AuthValidators._();

  static String? requiredName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required.';
    }

    return null;
  }

  static String? requiredEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required.';
    }

    final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailPattern.hasMatch(value.trim())) {
      return 'Enter a valid email address.';
    }

    return null;
  }

  static String? requiredPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required.';
    }

    return null;
  }

  static String? strongPassword(String? value) {
    final requiredError = requiredPassword(value);
    if (requiredError != null) {
      return requiredError;
    }

    if (value!.length < 8) {
      return 'Password must be at least 8 characters.';
    }

    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Confirm your password.';
    }

    if (value != password) {
      return 'Passwords do not match.';
    }

    return null;
  }
}
