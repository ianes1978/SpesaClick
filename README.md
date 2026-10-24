# Spesa Trento

App Flutter (Android + iOS) **per uso personale** che simula il self-scanning
dei supermercati di Trento: scansioni l'EAN di un prodotto e l'app chiede
subito il prezzo a **DupliClick** (Poli, prezzo del punto vendita scelto) o a
**Click&Coop** (Coop Trentino, listino online), e lo confronta con l'altra catena.

> Progetto personale e **non ufficiale**, non collegato a Poli, DupliClick,
> Coop Trentino o Click&Coop.
> Usa API non documentate che possono cambiare senza preavviso: i prezzi sono
> indicativi, fa fede lo scontrino.

## Funzioni

| | |
|---|---|
| **Carrello & scanner** | Fotocamera a schermo intero (EAN-13, EAN-8, UPC-A, UPC-E), antirimbalzo di 2,5 s, bip e vibrazione. Se il prodotto c'è già, aumenta la quantità. Inserimento manuale dell'EAN e "Simula scansione" per le prove. |
| **Etichette bilancia** | EAN-13 che inizia con `2`: `2` + articolo (6) + centesimi (5) + controllo. Il prodotto si cerca con i primi 7 caratteri + `000000`; il prezzo stampato è il totale della riga, peso = totale / prezzo al kg. |
| **Righe del carrello** | Foto, nome, marca, formato, prezzo unitario, badge della fonte (*prezzo PV* / *online* / *etichetta* / *offline · data*), quantità +/−, prezzo pieno barrato se in promo, bollini −30% / −50%, dialogo peso ↔ totale per il peso variabile. Scorri a sinistra per eliminare una riga. |
| **Riepilogo** | Totale, pezzi, risparmio (bollini + promo), totale nell'altro negozio e differenza. |
| **Negozi nel confronto** | In **Negozi** (in alto nel carrello) scegli una lista di negozi fra le catene disponibili: listino online DupliClick, i punti vendita Poli di Trento, listino online Click&Coop. Una catena senza negozi selezionati resta fuori dal confronto. L'ordine conta: il primo è quello proposto per primo. |
| **Scansione multi-negozio** | Il codice viene cercato in tutti i negozi selezionati; se il prodotto c'è in più negozi l'app chiede quale prezzo usare (si può disattivare: allora vale il primo della lista). Ogni riga mostra il prezzo negli altri negozi e il riepilogo il totale in ognuno, con il più conveniente evidenziato. |
| **Lista per negozio** | Ogni riga ha il negozio dove comprarla (📍). In alto filtri la lista per negozio: entrando in un negozio vedi solo cosa prendere lì. "Compra qui" nella scheda della riga la sposta in un altro negozio; dal menu "Assegna ogni articolo al negozio più conveniente" lo fa per tutte. |
| **Aldi a mano** | Aggiungi "Aldi" in Negozi. Tocca una riga → Aldi → **Inserisci** il prezzo: l'app chiede se comprarla da Aldi e ricorda il prezzo per le prossime spese (tocca di nuovo per modificarlo o toglierlo). Nessuna ricerca nel catalogo per Aldi. |
| **Spunta "preso"** | Casella su ogni riga: gli articoli presi vanno in fondo e la barra mostra "presi 3/7 · da prendere X €". "Togli tutte le spunte" dal menu. |
| **Equivalenti Lidl/MD/Pam** | Tocca una riga del carrello: prezzi per EAN negli altri negozi e prodotti equivalenti Lidl/MD/Pam da Everli, con "È lo stesso prodotto" per abbinarli. |
| **Ricerca multi-negozio** | Il catalogo cerca in tutti i negozi selezionati e raggruppa per EAN; i filtri in alto mostrano un negozio alla volta. |
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

## Negozi e prezzi in diretta

| Negozio | Da dove arriva il prezzo |
|---|---|
| Poli · listino online | DupliClick **senza** sessione (client separato), anche quando sei collegato |
| Poli · punto vendita attivo nel carrello DupliClick | In diretta, con login |
| Poli · altri punti vendita | Solo dalla cache (6 ore): "Aggiorna prezzi dei negozi Poli" nel riepilogo sposta il carrello DupliClick reale su ogni negozio, legge i prezzi e **ripristina** quello originale (con conferma). Nella ricerca testuale non sono interrogabili. |
| Coop · listino online | Click&Coop, uguale per tutti i punti di ritiro |

| Lidl / MD / Pam · negozio Everli | Everli (`spesa.everli.com`), sessione anonima con un indirizzo fisso di Trento. Prezzi Everli: in negozio possono differire, consegna esclusa |
| Aldi · prezzi inseriti a mano | Nessuna fonte online (non è su Everli e non pubblica un listino): il prezzo lo scrivi tu, letto a scaffale o sullo scontrino, e l'app lo ricorda (badge "a mano · data") |

## Lidl, MD e Pam tramite Everli

Everli **non espone codici a barre**, quindi lo scanner non può trovare per
EAN un prodotto Lidl o MD. L'app fa così:

1. ricava nome e marca dall'EAN tramite Poli o Coop;
2. cerca su Everli le prime parole significative del nome nei negozi Lidl/MD/Pam;
3. calcola una somiglianza (parole in comune, marca, formato e unità
   compatibili) e propone i 3 migliori come **equivalenti**, mai come lo
   stesso articolo;
4. tocca una riga del carrello per vedere gli equivalenti e premi
   **"È lo stesso prodotto"**: l'abbinamento (EAN → prodotto Everli) viene
   salvato e da lì in poi conta nei totali. Pressione lunga per toglierlo.

Nel riepilogo il totale Lidl/MD/Pam è calcolato **solo sugli articoli abbinati**
e indica quanti mancano. La ricerca testuale funziona anche su Everli, ma
mostra solo i risultati che contengono tutte le parole cercate (la ricerca
di Everli è "fuzzy" e restituisce sempre qualcosa). Non esiste un listino
offline Everli. Una richiesta ogni 600 ms, cache di 12 ore.

## Click&Coop (Coop Trentino)

* Nessun login: tutti gli endpoint usati sono pubblici.
* I prezzi **non dipendono dal punto di ritiro**: c'è un unico listino online
  (`priceListName` = "Listino clickcoop", o "… - Localismi" per una quarantina
  di prodotti locali). L'app lo dice: *"Prezzi del listino online Click&Coop,
  in negozio possono differire"*.
* Il server sbaglia a intermittenza (circa 1 richiesta su 10 risponde
  `status: 1` senza dati): ogni richiesta viene ripetuta fino a 5 volte con
  attesa crescente (0,5 s, 1,5 s, 2,5 s…), con almeno 450 ms tra due richieste.
* Ricerca testuale e reparti (`/category`). Il listino offline si scarica
  reparto per reparto (circa 11.800 prodotti), saltando le raccolte
  Promozioni / Cashback / Sempre giù, 80 per pagina con ripiego su 40.
* Sfusi: hanno codici interni brevi (es. `2877992`), a volte condivisi da più
  articoli; il listino offline usa quindi `productId` come chiave. Quando
  aggiungi uno sfuso l'app chiede peso o totale.
* Etichette della bilancia Coop **non verificate**: il prezzo non viene
  decodificato dal codice. Se un codice che inizia con 2 non è a listino,
  l'app chiede il totale (o peso e prezzo al kg) e aggiunge una riga
  "Articolo a peso".

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
`lib/data/ebsn_api.dart` / `lib/data/ebsn_config.dart` (e nei metodi
`fromApi` dei modelli in `lib/domain/`).

### Confronto tra negozi: attenzione

Per leggere i prezzi dell'altro negozio, l'app **cambia il punto vendita del
tuo carrello DupliClick reale**, legge i prezzi e poi **ripristina sempre** il
negozio originale (con `try/finally`, poi lo verifica con `cart/view`). Prima di
procedere chiede conferma, perché il cambio può far perdere una fascia oraria
di ritiro già prenotata. I prezzi letti restano in cache per 6 ore: se sono
già tutti in cache, il negozio non viene cambiato.

## Uso responsabile delle API

* Un client HTTP per catena, richieste mai in parallelo: DupliClick una ogni
  300 ms con un solo nuovo tentativo sugli errori di rete; Click&Coop una
  ogni 450 ms con fino a 5 nuovi tentativi. Timeout di 20 s.
* Una chiamata per scansione. I prezzi stanno in cache per (negozio, EAN)
  per 6 ore.
* Il download del listino fa una richiesta ogni 350 ms e si può interrompere.

## Struttura

```
lib/
  data/      EbsnApi + EbsnConfig per catena (Dio + interceptor), repository,
             database drift,
             storage sicuro della sessione, export CSV/JSON
  domain/    Product, CartItem, Store, PriceQuote, EAN/etichette, calcolo totali
  ui/        schermate (carrello, scanner, catalogo, login, tessera, altro),
             provider Riverpod
test/        parsing di /products (fixture reali DupliClick e Click&Coop),
             client API con adapter finto (header, tentativi, 419),
             totali (bollini, promo, peso variabile, etichetta), EAN-13/UPC
```

Dettagli tecnici dell'API:

* Entrambe le catene usano la piattaforma "ebsn" di Digitelematica:
  `https://www.dupliclick.it/ebsn/api` e `https://www.clickcoop.it/ebsn/api`.
  `X-Ebsn-Client: production` sempre; `X-Ebsn-Client-Redirect` solo per
  DupliClick, `User-Agent` dichiarato per Click&Coop.
* Prezzi normalizzati: `priceDisplay` è il prezzo di vendita; il prezzo pieno
  è `priceStandardDisplay` (DupliClick) o `price` (Click&Coop) se maggiore.
* Le risposte hanno `Content-Type: text/html` ma il corpo è JSON. Dio usa
  `ResponseType.plain` e poi `jsonDecode`.
* Per cercare un codice a barre si usa `barcode=<EAN>`, non `q=<EAN>`.
