class IngressinhosException implements Exception {
  final String message;

  IngressinhosException(this.message);

  @override
  String toString() => message;
}