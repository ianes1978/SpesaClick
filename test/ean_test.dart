import 'package:flutter_test/flutter_test.dart';
import 'package:spesa_trento/domain/ean.dart';

void main() {
  group('cifra di controllo EAN-13', () {
    test('codici reali', () {
      expect(gs1CheckDigit('800704992013'), 1);
      expect(isValidEan13('8007049920131'), isTrue);
      expect(isValidEan13('8007049920132'), isFalse);
      expect(isValidEan13('4006381333931'), isTrue);
    });

    test('completa 12 cifre, verifica 13', () {
      expect(completeEan13('800704992013'), '8007049920131');
      expect(completeEan13('8007049920131'), '8007049920131');
      expect(completeEan13('8007049920139'), isNull);
      expect(completeEan13('1234'), isNull);
      expect(completeEan13('abcdefghijkl'), isNull);
    });

    test('EAN-8', () {
      expect(isValidEan8('96385074'), isTrue);
      expect(isValidEan8('96385075'), isFalse);
    });
  });

  group('UPC', () {
    test('UPC-E → UPC-A', () {
      expect(expandUpcE('04252614'), '042100005264');
      expect(hasValidCheckDigit(expandUpcE('04252614')!), isTrue);
    });

    test('candidati di ricerca', () {
      expect(barcodeCandidates('036000291452'),
          ['036000291452', '0036000291452']);
      expect(barcodeCandidates('8007049920131'), ['8007049920131']);
    });
  });

  group('etichetta bilancia', () {
    test('2 + articolo + centesimi + controllo', () {
      final l = ScaleLabel.tryParse('2060120012343')!;
      expect(l.lookupBarcode, '2060120000000');
      expect(l.articleCode, '060120');
      expect(l.total, 12.34);
    });

    test('codice di listino (prezzo zero) non è un\'etichetta', () {
      expect(ScaleLabel.tryParse('2060120000000'), isNull);
    });

    test('EAN normali non sono etichette', () {
      expect(ScaleLabel.tryParse('8007049920131'), isNull);
      expect(ScaleLabel.tryParse('20601200123'), isNull);
    });
  });
}
