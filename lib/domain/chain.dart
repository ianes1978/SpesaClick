/// Catene supportate.
///
/// Poli e Coop usano la piattaforma "ebsn" di Digitelematica e si cercano per
/// EAN. Lidl, MD e Pam si leggono da Everli, che non espone codici a barre: lì si
/// cercano prodotti equivalenti per nome.
enum Chain {
  /// Poli / DupliClick: prezzi del punto vendita con login.
  poli,

  /// Coop Trentino / Click&Coop: un unico listino online pubblico.
  coop,

  /// Lidl tramite Everli.
  lidl,

  /// MD tramite Everli.
  md,

  /// Pam tramite Everli.
  pam,

  /// Aldi: nessuna fonte online, prezzi inseriti a mano dall'utente.
  aldi;

  String get label => switch (this) {
    Chain.poli => 'Poli',
    Chain.coop => 'Coop',
    Chain.lidl => 'Lidl',
    Chain.md => 'MD',
    Chain.pam => 'Pam',
    Chain.aldi => 'Aldi',
  };

  String get serviceName => switch (this) {
    Chain.poli => 'DupliClick',
    Chain.coop => 'Click&Coop',
    Chain.lidl || Chain.md || Chain.pam => 'Everli',
    Chain.aldi => 'prezzi a mano',
  };

  /// La catena si legge da Everli (niente EAN, solo ricerca per nome).
  bool get isEverli =>
      this == Chain.lidl || this == Chain.md || this == Chain.pam;

  /// I prezzi li inserisce l'utente (niente API, niente ricerca).
  bool get isManual => this == Chain.aldi;

  /// `brand_details.slug` di Everli.
  String? get everliSlug => switch (this) {
    Chain.lidl => 'lidl',
    Chain.md => 'md',
    Chain.pam => 'pam',
    _ => null,
  };
}
