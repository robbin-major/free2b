import 'package:flutter/foundation.dart';

import '../api/exception/app_exception.dart';

extension Validator on String {
  bool isValidFirstName() {
    if (isEmpty) {
      showError("Please enter first name", true);
      return false;
    }
    return true;
  }

  bool isValidLastName() {
    if (isEmpty) {
      showError("Please enter last name", true);
      return false;
    }
    return true;
  }
}

void showError(String message, bool? error) {
  AppException(errorCode: 0, message: message, isError: error).show();
}
