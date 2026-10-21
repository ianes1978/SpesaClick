# Spesa Trento

App Flutter (Android + iOS) **per uso personale** che simula il self-scanning
dei supermercati di Trento: scansioni l'EAN di un prodotto e l'app chiede
subito alle API di DupliClick il prezzo del punto vendita scelto.

> Progetto personale e **non ufficiale**, non collegato a Poli né a DupliClick.
> Usa API non documentate che possono cambiare senza preavviso: i prezzi sono
> indicativi, fa fede lo scontrino.

## Funzioni

| | |
|---|---|
| **Carrello & scanner** | Fotocamera a schermo intero (EAN-13, EAN-8, UPC-A, UPC-E), antirimbalzo di 2,5 s, bip e vibrazione. Se il prodotto c'è già, aumenta la quantità. Inserimento manuale dell'EAN e "Simula scansione" per le prove. |
| **Etichette bilancia** | EAN-13 che inizia con `2`: `2` + articolo (6) + centesimi (5) + controllo. Il prodotto si cerca con i primi 7 caratteri + `000000`; il prezzo stampato è il totale della riga, peso = totale / prezzo al kg. |
| **Righe del carrello** | Foto, nome, marca, formato, prezzo unitario, badge della fonte (*prezzo PV* / *online* / *etichetta* / *offline · data*), quantità +/−, prezzo pieno barrato se in promo, bollini −30% / −50%, dialogo peso ↔ totale per il peso variabile. Scorri a sinistra per eliminare una riga. |
| **Riepilogo** | Totale, pezzi, risparmio (bollini + promo), totale nell'altro negozio e differenza. |
| **Cambio negozio e confronto** | Selettore del punto vendita in alto e confronto IperPoli ↔ Gardolo (vedi avvertenze sotto). |
| **Catalogo** | Ricerca istantanea (debounce di 300 ms) con paginazione infinita, filtri per categoria e la sezione "In evidenza" con prodotti trentini. Un tocco aggiunge il prodotto al carrello. |
| **Offline** | "Scarica listino" salva l'intero listino (8.400+ prodotti, una richiesta ogni 350 ms). Senza rete o senza sessione lo scanner usa questo listino. |
| **Tessera fedeltà** | 12 cifre → calcola la cifra di controllo; 13 → la verifica. Codice EAN-13 a tutto schermo con luminosità al massimo. |
| **Esporta** | Carrello e listino in CSV (separatore `;`) o JSON tramite il menu Condividi. |

## Avvio

Serve Flutter **3.47** o successivo (Dart 3.13).

```bash
flutter pub get
# I file generati (*.g.dart, *.freezed.dart) sono già nel repository.
# Se modifichi i modelli o il database, rigenerali con:
dart run build_runner build
flutter test
flutter run            # su un telefono collegato
```

Build manuali:

```bash
flutter build apk --release      # Android (firmato con la chiave di debug)
flutter build ios --release      # iOS: serve un Mac con Xcode e un team di firma
```

### APK da GitHub Actions

Il workflow `.github/workflows/build-apk.yml` parte a ogni push e ogni pull request: esegue
analisi e test, poi compila l'APK.

* **Scaricare l'APK:** apri GitHub → *Actions* → l'esecuzione più recente di
  *Build APK* → *Artifacts* → `spesa-trento-apk`. È uno zip che contiene l'APK.
* **Avviarlo a mano:** *Actions* → *Build APK* → *Run workflow*.
* **Pubblicare una release:** fai il push di un tag `v*`, per esempio
  `git tag v1.0.0 && git push origin v1.0.0`. L'APK viene allegato alla release di GitHub.

Per installarlo, abilita sul telefono "Installa app sconosciute" per il browser
o per il file manager. L'APK è firmato con la chiave di debug: va bene per uso
personale, non per il Play Store.

## Collegare DupliClick

1. Vai in **Altro → Collega DupliClick** (o tocca "collega" in alto nel carrello).
2. Nella pagina di DupliClick fai il login: il reCAPTCHA lo risolvi tu,
   l'app non lo automatizza. Poi scegli **Ritiro in negozio** e il punto vendita.
3. Tocca **Collega**. L'app legge il cookie `JSESSIONID` (HttpOnly, tramite il
   `CookieManager` di `flutter_inappwebview`), `X-Ebsn-Session` da
   `sessionStorage` e `X-Ebsn-Account` da `localStorage`. Li salva in
   `flutter_secure_storage` e li verifica con `GET /cart/view`.
4. In alto compare il nome del negozio. Se il server risponde 419 (sessione
   scaduta) compare "Sessione scaduta · ricollegati".

Senza login l'app funziona lo stesso, con i prezzi del listino online generico.

## ⚠️ Parti non verificate con un account reale

Queste parti sono scritte seguendo il comportamento del sito, ma **non sono
state provate con un account DupliClick vero**:

* **Login / lettura della sessione** (usa `flutter_inappwebview` 6.2 beta: la 6.1.5 non compila con l'Android Gradle Plugin 9): i nomi delle chiavi (`X-Ebsn-Session`,
  `X-Ebsn-Account`, `JSESSIONID`) e l'invio di `X-Ebsn-Account` come header.
  Nei build di debug l'app scrive nel log quali valori ha trovato e il corpo
  delle risposte (`flutter run`, poi guarda la console).
* **`/cart/view`**: si legge `data.shippingAddress` o `data.cart.shippingAddress`
  (`addressId`, `addressName`, `addressType`, `deliveryServiceId`). Se manca, il log
  mostra le chiavi ricevute.
* **Cambio negozio** (`POST /user-address/select?address_type=work&…`) e
  **confronto prezzi**.
* **Elenco punti vendita** (`/address/delivery-service-list`): la struttura
  della risposta non è nota. Il parser cerca una lista in `data` e, se non la
  trova, usa i due negozi noti (1412 IperPoli Trento, 1103 Poli Gardolo).
* **Etichette della bilancia**: il formato (`2` + 6 + 5 + controllo) va
  verificato con un'etichetta vera.

Se un nome di campo è diverso, la correzione va fatta solo in
`lib/data/dupliclick_api.dart` (e nei metodi `fromApi` dei modelli in
`lib/domain/`).

### Confronto tra negozi: attenzione

Per leggere i prezzi dell'altro negozio, l'app **cambia il punto vendita del
tuo carrello DupliClick reale**, legge i prezzi e poi **ripristina sempre** il
negozio originale (con `try/finally`, poi lo verifica con `cart/view`). Prima di
procedere chiede conferma, perché il cambio può far perdere una fascia oraria
di ritiro già prenotata. I prezzi letti restano in cache per 6 ore: se sono
già tutti in cache, il negozio non viene cambiato.

## Uso responsabile delle API

* Un solo client HTTP con al massimo una richiesta ogni 300 ms, mai in
  parallelo, timeout di 20 s e un solo nuovo tentativo sugli errori di rete.
* Una chiamata per scansione. I prezzi stanno in cache per (negozio, EAN)
  per 6 ore.
* Il download del listino fa una richiesta ogni 350 ms e si può interrompere.

## Struttura

```
lib/
  data/      DupliclickApi (Dio + interceptor), repository, database drift,
             storage sicuro della sessione, export CSV/JSON
  domain/    Product, CartItem, Store, PriceQuote, EAN/etichette, calcolo totali
  ui/        schermate (carrello, scanner, catalogo, login, tessera, altro),
             provider Riverpod
test/        parsing di /products (fixture reale), client API con adapter finto,
             totali (bollini, promo, peso variabile, etichetta), EAN-13/UPC
```

Dettagli tecnici dell'API:

* Base URL `https://www.dupliclick.it/ebsn/api`. Gli header `X-Ebsn-Client` e
  `X-Ebsn-Client-Redirect` valgono `production`.
* Le risposte hanno `Content-Type: text/html` ma il corpo è JSON. Dio usa
  `ResponseType.plain` e poi `jsonDecode`.
* Per cercare un codice a barre si usa `barcode=<EAN>`, non `q=<EAN>`.
