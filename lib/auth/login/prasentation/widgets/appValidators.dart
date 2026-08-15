class AppValidators {

  static String? userId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Enter User ID";
    }

    return null;
  }

  static String? requiredField(
      String? value,
      String fieldName,
      ) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? email(
      String? value,
      ) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter an email';
    }
    if(!value.contains('@')){
      return 'Please enter a valid email';
    }
    if(!value.contains('.')){
      return 'Please enter a valid email';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;

  }

  //Password
  static String? password(
      String? value,
      ) {
     if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

     final strongRegex = RegExp(
         r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');
    /* if (!strongRegex.hasMatch(value)) {
       return 'Include upper, lower, number & special character';
     }*/

     return null;
  }

  static String? confirmPassword(
      String? value,
      String password,
      ) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != password) {
      return 'Passwords do not match';
    }

    return null;
  }

  //Phone
  static String? phone(
      String? value,
      ) {
    if (value == null || value.trim().isEmpty) return 'Phone is required';
    final pattern = RegExp(r'^(?:\+?88)?01[3-9]\d{8}$');
    return pattern.hasMatch(value.trim()) ? null :
    'Enter valid Bangladesh phone';
  }

  //NID
  static String? Nid(String? value,){
  if (value == null || value.trim().isEmpty) {
  return 'NID is required';
  }
// Must be digits only and length between 10 and 17
  final pattern = RegExp(r'^[0-9]{10,17}$');

  if (!pattern.hasMatch(value.trim())) {
  return 'NID must be 10–17 digits long';
  }

  return null; // valid
}

static String? nominee(String? value){
  if (value == null || value.trim().isEmpty) {
    return 'Nominee Name is required';
  }
  return null; // valid
}

static String? nomineeRelation(String? value){
  if (value == null || value.trim().isEmpty) {
    return 'Nominee Relation is required';
  }
  return null; // valid
}







}