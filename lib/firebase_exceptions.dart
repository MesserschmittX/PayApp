import 'package:firebase_auth/firebase_auth.dart';

enum AuthStatus {
  successful,
  wrongPassword,
  emailAlreadyExists,
  invalidEmail,
  weakPassword,
  unknown,
  differentPassword,
  failedReauth,
  timeOut
}

class AuthExceptionHandler {
  static handleAuthException(FirebaseAuthException e) {
    print(e);
    print(e.code);
    AuthStatus status;
    switch (e.code) {
      case "invalid-email":
        status = AuthStatus.invalidEmail;
        break;
      case "wrong-password":
        status = AuthStatus.wrongPassword;
        break;
      case "weak-password":
        status = AuthStatus.weakPassword;
        break;
      case "email-already-in-use":
        status = AuthStatus.emailAlreadyExists;
        break;
      case "internal-error":
        status = AuthStatus.failedReauth;
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
        errorMessage = "Your email address appears to be malformed.";
        break;
      case AuthStatus.weakPassword:
        errorMessage = "Your password should be at least 6 characters.";
        break;
      case AuthStatus.wrongPassword:
        errorMessage = "Your email or password is wrong.";
        break;
      case AuthStatus.emailAlreadyExists:
        errorMessage =
            "The email address is already in use by another account.";
        break;
      case AuthStatus.differentPassword:
        errorMessage = "The new passwords do not match.";
        break;
      case AuthStatus.failedReauth:
        errorMessage = "Failed authentication with current credentials.";
      case AuthStatus.timeOut:
        errorMessage =
            "Too many requests. Try again later or press forgot password.";
      default:
        errorMessage = "An error occured. Please try again later.";
    }
    return errorMessage;
  }
}
