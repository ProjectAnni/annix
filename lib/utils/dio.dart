bool validateStatusCode(int? status) {
  return status != null && status >= 200 && status < 300 || status == 304;
}
