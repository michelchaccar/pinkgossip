class Success {
  int code;
  Object response;
  String msg;
  bool success;

  Success({
    required this.code,
    required this.response,
    required this.msg,
    required this.success,
  });
}

class Failure {
  int code;
  String msg;
  bool success;
  Failure({
    required this.code,
    required this.msg,
    required this.success,
  });
}

class ErrorResponse {
  bool success;
  String msg;
  ErrorResponse({
    required this.success,
    required this.msg,
  });
}
