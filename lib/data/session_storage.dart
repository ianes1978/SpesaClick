import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'dupliclick_api.dart';

/// Conserva la sessione DupliClick nello storage sicuro del sistema.
class SessionStorage {
  SessionStorage([FlutterSecureStorage? storage])
      : _s = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _s;

  static const _kJs = 'dc_jsessionid';
  static const _kSession = 'dc_x_ebsn_session';
  static const _kAccount = 'dc_x_ebsn_account';
  static const _kCard = 'loyalty_card';

  Future<EbsnSession> load() async => EbsnSession(
        jsessionId: await _s.read(key: _kJs),
        ebsnSession: await _s.read(key: _kSession),
        ebsnAccount: await _s.read(key: _kAccount),
      );

  Future<void> save(EbsnSession s) async {
    await _write(_kJs, s.jsessionId);
    await _write(_kSession, s.ebsnSession);
    await _write(_kAccount, s.ebsnAccount);
  }

  Future<void> clear() => save(const EbsnSession());

  Future<String?> loyaltyCard() => _s.read(key: _kCard);
  Future<void> setLoyaltyCard(String? v) => _write(_kCard, v);

  Future<void> _write(String k, String? v) =>
      (v == null || v.isEmpty) ? _s.delete(key: k) : _s.write(key: k, value: v);
}
