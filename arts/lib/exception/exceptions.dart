class ConnectionErrorException implements Exception {
 late  String cause;
 ConnectionErrorException(this.cause);
}

class QrException implements Exception{
 late  String cause;
 QrException(this.cause);
}