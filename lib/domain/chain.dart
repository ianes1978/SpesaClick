/// Catene supportate.
///
/// Poli e Coop usano la piattaforma "ebsn" di Digitelematica e si cercano per
/// EAN. Lidl e MD si leggono da Everli, che non espone codici a barre: lì si
/// cercano prodotti equivalenti per nome.
enum Chain {
  /// Poli / DupliClick: prezzi del punto vendita con login.
  poli,

  /// Coop Trentino / Click&Coop: un unico listino online pubblico.
  coop,

  /// Lidl tramite Everli.
  lidl,

  /// MD tramite Everli.
  md;

  String get label => switch (this) {
    Chain.poli => 'Poli',
    Chain.coop => 'Coop',
    Chain.lidl => 'Lidl',
    Chain.md => 'MD',
  };

  String get serviceName => switch (this) {
    Chain.poli => 'DupliClick',
    Chain.coop => 'Click&Coop',
    Chain.lidl || Chain.md => 'Everli',
  };

  /// La catena si legge da Everli (niente EAN, solo ricerca per nome).
  bool get isEverli => this == Chain.lidl || this == Chain.md;

  /// `brand_details.slug` di Everli.
  String? get everliSlug => switch (this) {
    Chain.lidl => 'lidl',
    Chain.md => 'md',
    _ => null,
  };
}
