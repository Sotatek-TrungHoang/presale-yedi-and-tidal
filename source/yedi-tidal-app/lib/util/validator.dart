import 'package:email_validator/email_validator.dart';
import 'package:yedi_app/util/strings.dart';

class Validator {
  final List<String> _messages = [];

  Validator isNumeric(String s, {String message = "Value must be numeric"}) {
    if (!s.isNumeric()) {
      _messages.add(message);
    }
    return this;
  }

  Validator isValidEmail(String s,
      {String message = "You must enter a valid email"}) {
    if (!EmailValidator.validate(s)) {
      _messages.add(message);
    }
    return this;
  }

  Validator notEmpty(String? s, {String message = "A value is required"}) {
    if (s == null || s.trim().isEmpty) {
      _messages.add(message);
    }
    return this;
  }

  Validator minLength(String s, int minLength, {String? message}) {
    if (s.length < minLength) {
      _messages.add(message ?? "Value must be at least $minLength characters");
    }
    return this;
  }

  Validator sameAs(String s, String shouldEqual,
      {String message = "Values do not match"}) {
    if (s != shouldEqual) {
      _messages.add(message);
    }
    return this;
  }

  Validator inList(String s, List<String> inList,
      {String message = "Invalid value"}) {
    if (!inList.contains(s)) {
      _messages.add(message);
    }
    return this;
  }

  String? validate() {
    return _messages.isEmpty ? null : _messages.first;
  }
}
