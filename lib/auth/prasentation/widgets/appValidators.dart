/// Central validators shared by the auth forms.
///
/// Every validator returns `null` when the value is valid, otherwise the
/// exact error message to show under the field.
class AppValidators {

  static String? userId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter User ID';
    }
    return null;
  }

  /// Required-field check reused by the specific validators below so the
  /// "'<field>' is required" wording only exists in one place.
  static String? requiredField(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter an email';
    }
    if (!value.contains('@')) {
      return 'Please enter a valid email';
    }
    if (!value.contains('.')) {
      return 'Please enter a valid email';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  static String? phone(String? value) {
    final required = requiredField(value, 'Phone');
    if (required != null) {
      return required;
    }
    final pattern = RegExp(r'^(?:\+?88)?01[3-9]\d{8}$');
    return pattern.hasMatch(value!.trim())
        ? null
        : 'Enter valid Bangladesh phone';
  }

  static String? nid(String? value) {
    final required = requiredField(value, 'NID');
    if (required != null) {
      return required;
    }
    // Digits only, length between 10 and 17.
    final pattern = RegExp(r'^[0-9]{10,17}$');
    if (!pattern.hasMatch(value!.trim())) {
      return 'NID must be 10–17 digits long';
    }
    return null;
  }

  static String? nominee(String? value) =>
      requiredField(value, 'Nominee Name');

  static String? nomineeRelation(String? value) =>
      requiredField(value, 'Nominee Relation');
}
