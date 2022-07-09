import 'dart:io';

class ErrorMessage {
  final dynamic error;
  const ErrorMessage(this.error);

  String getMessage() {
    if (error == SocketException) {
      SocketException socketError = error;
      OSError? osError = socketError.osError;
      if (osError != null) {
        return osError.message;
      } else {
        return socketError.message;
      }
    }
    return error.toString();
  }
}
