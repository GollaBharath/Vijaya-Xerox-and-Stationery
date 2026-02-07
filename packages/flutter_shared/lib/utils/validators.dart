/// Validators for form inputs and file uploads
class Validators {
  /// Validate email format
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }

    return null;
  }

  /// Validate password (min 8 chars, at least 1 uppercase, 1 number)
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }

    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }

    return null;
  }

  /// Validate phone number (accepts common formats)
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    // Remove common formatting
    final cleanPhone = value.replaceAll(RegExp(r'[^\d]'), '');

    if (cleanPhone.length < 10) {
      return 'Phone number must be at least 10 digits';
    }

    if (cleanPhone.length > 15) {
      return 'Phone number is too long';
    }

    return null;
  }

  /// Validate name (not empty, at least 2 characters)
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }

    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }

    return null;
  }

  /// Validate product quantity
  static String? validateQuantity(String? value) {
    if (value == null || value.isEmpty) {
      return 'Quantity is required';
    }

    try {
      final quantity = int.parse(value);
      if (quantity <= 0) {
        return 'Quantity must be greater than 0';
      }
      if (quantity > 999) {
        return 'Quantity cannot exceed 999';
      }
      return null;
    } catch (e) {
      return 'Please enter a valid number';
    }
  }

  /// Validate image file (JPEG, PNG, WebP max 5MB)
  static String? validateImageFile({
    required String filename,
    required int fileSizeBytes,
  }) {
    final validExtensions = ['jpg', 'jpeg', 'png', 'webp'];
    final ext = filename.split('.').last.toLowerCase();

    if (!validExtensions.contains(ext)) {
      return 'Image must be JPEG, PNG, or WebP format';
    }

    const maxSizeMB = 5;
    const maxSizeBytes = maxSizeMB * 1024 * 1024;

    if (fileSizeBytes > maxSizeBytes) {
      return 'Image must be less than $maxSizeMB MB (Current: ${(fileSizeBytes / 1024 / 1024).toStringAsFixed(2)} MB)';
    }

    return null;
  }

  /// Validate PDF file (PDF format, max 10MB)
  static String? validatePdfFile({
    required String filename,
    required int fileSizeBytes,
  }) {
    if (!filename.toLowerCase().endsWith('.pdf')) {
      return 'File must be in PDF format';
    }

    const maxSizeMB = 10;
    const maxSizeBytes = maxSizeMB * 1024 * 1024;

    if (fileSizeBytes > maxSizeBytes) {
      return 'PDF must be less than $maxSizeMB MB (Current: ${(fileSizeBytes / 1024 / 1024).toStringAsFixed(2)} MB)';
    }

    return null;
  }

  /// Validate address (street address)
  static String? validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Address is required';
    }

    if (value.length < 5) {
      return 'Please enter a valid address';
    }

    return null;
  }

  /// Validate city
  static String? validateCity(String? value) {
    if (value == null || value.isEmpty) {
      return 'City is required';
    }

    return null;
  }

  /// Validate postal code
  static String? validatePostalCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Postal code is required';
    }

    if (value.length < 3) {
      return 'Please enter a valid postal code';
    }

    return null;
  }

  /// Check if email is valid format (without error message)
  static bool isValidEmail(String email) {
    return validateEmail(email) == null;
  }

  /// Check if password is strong
  static bool isStrongPassword(String password) {
    return validatePassword(password) == null;
  }

  /// Check if phone is valid format
  static bool isValidPhone(String phone) {
    return validatePhone(phone) == null;
  }
}
