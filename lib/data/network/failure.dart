class Failure {
  final ApiInternalStatus status;
  final String message;

  Failure(this.status, this.message);
}

enum ApiInternalStatus {
  success,
  failure,
  noInternetConnection,
}
