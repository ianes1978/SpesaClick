/// Errori dell'API DupliClick, con messaggi in italiano per l'interfaccia.
sealed class ApiException implements Exception {
  const ApiException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// HTTP 419: sessione mancante o scaduta.
class SessionExpiredException extends ApiException {
  const SessionExpiredException()
      : super('Sessione DupliClick scaduta: ricollegati.');
}

/// Nessuna rete, timeout, DNS…
class NetworkException extends ApiException {
  NetworkException([String detail = ''])
      : super('Rete non disponibile${detail.isEmpty ? '' : ' ($detail)'}');
}

/// La risposta non ha la struttura attesa: probabilmente l'API è cambiata.
class ApiFormatException extends ApiException {
  const ApiFormatException(String detail)
      : super('Risposta DupliClick inattesa: $detail. '
            "L'API potrebbe essere cambiata.");
}

/// Il server ha risposto con `response.status != 0` o un codice HTTP d'errore.
class ApiServerException extends ApiException {
  const ApiServerException(super.message, {this.statusCode});
  final int? statusCode;
}
