/// Catene supportate. Entrambe usano la piattaforma "ebsn" di Digitelematica.
enum Chain {
  /// Poli / DupliClick: prezzi del punto vendita con login.
  poli,

  /// Coop Trentino / Click&Coop: un unico listino online pubblico.
  coop;

  String get label => switch (this) {
        Chain.poli => 'Poli',
        Chain.coop => 'Coop',
      };

  String get serviceName => switch (this) {
        Chain.poli => 'DupliClick',
        Chain.coop => 'Click&Coop',
      };

  Chain get other => this == Chain.poli ? Chain.coop : Chain.poli;
}
