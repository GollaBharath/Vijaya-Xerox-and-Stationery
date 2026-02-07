/// Validators for form input
class Validators {
  /// Validate email
  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(email)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  /// Validate password
  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }
    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'Password must contain at least one digit';
    }
    return null;
  }

  /// Validate confirm password
  static String? validateConfirmPassword(
    String? password,
    String? confirmPassword,
  ) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'Confirm password is required';
    }
    if (password != confirmPassword) {
      return 'Passwords do not match';
    }
    return null;
  }

  /// Validate phone number
  static String? validatePhone(String? phone) {
    if (phone == null || phone.isEmpty) {
      return 'Phone number is required';
    }
    final phoneRegex = RegExp(r'^[0-9]{10,15}$');
    final cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (!phoneRegex.hasMatch(cleaned)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  /// Validate name
  static String? validateName(String? name) {
    if (name == null || name.isEmpty) {
      return 'Name is required';
    }
    if (name.length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (name.length > 50) {
      return 'Name must not exceed 50 characters';
    }
    return null;
  }

  /// Validate not empty
  static String? validateNotEmpty(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validate minimum length
  static String? validateMinLength(String? value, int minLength) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    if (value.length < minLength) {
      return 'Must be at least $minLength characters';
    }
    return null;
  }

  /// Validate maximum length
  static String? validateMaxLength(String? value, int maxLength) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    if (value.length > maxLength) {
      return 'Must not exceed $maxLength characters';
    }
    return null;
  }

  /// Validate URL
  static String? validateUrl(String? url) {
    if (url == null || url.isEmpty) {
      return 'URL is required';
    }
    try {
      Uri.parse(url);
      return null;
    } catch (e) {
      return 'Please enter a valid URL';
    }
  }

  /// Validate number
  static String? validateNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Number is required';
    }
    if (double.tryParse(value) == null) {
      return 'Please enter a valid number';
    }
    return null;
  }
}
