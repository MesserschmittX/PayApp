import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_translate/flutter_translate.dart';

enum AuthStatus {
  successful,
  wrongPassword,
  invalidCredential,
  emailAlreadyExists,
  invalidEmail,
  weakPassword,
  unknown,
  differentPassword,
  failedReAuth,
  timeOut
}

class AuthExceptionHandler {
  static handleAuthException(FirebaseAuthException e) {
    AuthStatus status;
    switch (e.code) {
      case "invalid-email":
        status = AuthStatus.invalidEmail;
        break;
      case "wrong-password":
        status = AuthStatus.wrongPassword;
        break;
      case "invalid-credential":
        status = AuthStatus.invalidCredential;
        break;
      case "weak-password":
        status = AuthStatus.weakPassword;
        break;
      case "email-already-in-use":
        status = AuthStatus.emailAlreadyExists;
        break;
      case "internal-error":
        status = AuthStatus.failedReAuth;
      case "too-many-requests":
        status = AuthStatus.timeOut;
      default:
        status = AuthStatus.unknown;
    }
    return status;
  }

  static String generateErrorMessage(error) {
    String errorMessage;
    switch (error) {
      case AuthStatus.invalidEmail:
        errorMessage = translate('firebase_exception.invalid_email');
        break;
      case AuthStatus.weakPassword:
        errorMessage = translate('firebase_exception.weak_password');
        break;
      case AuthStatus.wrongPassword:
        errorMessage = translate('firebase_exception.wrong_password');
        break;
      case AuthStatus.invalidCredential:
        errorMessage = translate('firebase_exception.invalid_credential');
        break;
      case AuthStatus.emailAlreadyExists:
        errorMessage = translate('firebase_exception.email_already_exists');
        break;
      case AuthStatus.differentPassword:
        errorMessage = translate('firebase_exception.different_password');
        break;
      case AuthStatus.failedReAuth:
        errorMessage = translate('firebase_exception.failed_re_auth');
      case AuthStatus.timeOut:
        errorMessage = translate('firebase_exception.time_out');
      default:
        errorMessage = translate('firebase_exception.default');
    }
    return errorMessage;
  }
}
