# Pravila aplikacije

## Primjena pravila

- Ova pravila se uvijek primjenjuju, osim ako izričito nije naglašeno drugačije.
- Dokument se dopunjava po potrebi.

- Blok od 6 nivoa smatra se jednom cjelinom.
- Na nivou bloka definišu se:
  - pozadina,
  - boja podloge i plafona,
  - boja platformi,
  - padajuće zemlje.
- Lift se nalazi na kraju svakog posljednjeg nivoa bloka, odnosno na nivou 6 bloka.
- Svaki nivo ima početnu i krajnju podlogu; nivo se uvijek završava na ravnoj podlozi.
- Most koji se nalazi na nivou 1.5 ima standardan izgled mosta, bez obzira na to da li je stabilan ili nije.
- Čekić je uvijek isti. U scenu dolazi izvana, sa strane koja je definisana za taj nivo.
- Klavir ostaje kao do sada i pada kada je to definisano, na isti način kao do sada.
- Šiljci rade onako kako su definisani.
- Platforme imaju istu boju kao podloga nivoa. Kada se podižu, kreću odozdo do nivoa na kojem treba da budu, a zatim padaju dole. Platforme se ne vide prije podizanja niti nakon završetka tog događaja.
- Muha leti od jednog kraja ekrana do drugog neprekidno, u obliku broja 8. Tokom tog leta samo leti.
- U nasumičnim intervalima od 2 do 10 sekundi muha se zaustavi na pola sekunde, a zatim se zaleti u lika brzinom koja je pet puta veća od njene brzine leta.
- Zmaj je za sada jedini element koji ima dvije funkcije:
  - doleti, uzme lika i vrati ga na početak nivoa;
  - spali lika vatrom iz usta.
  - munja samo blicne, ne ostane 

# RAGEBOX — PRAVILA RAZVOJA

## 1. Postojeća arhitektura projekta

- Prije svake izmjene obavezno pregledati postojeći repozitorij i relevantni kod.
- Poštovati postojeću arhitekturu, strukturu direktorija, tehnologije i način organizacije projekta.
- Ne izmišljati nove direktorije, komponente ili sisteme bez opravdane potrebe.
- Maksimalno koristiti postojeće funkcije, komponente, resurse i konfiguracije.
- Ne raditi nepotreban refaktoring.
- Ne mijenjati funkcionalnosti koje već ispravno rade, osim ako je to izričito zatraženo.
- Svaku izmjenu ograničiti na najmanji potreban obim.

## 2. Standardizacija elemenata igre

Svaki element igre mora imati jasno definisanu funkcionalnost i mogućnost ponovne upotrebe.

Prije kreiranja ili izmjene elementa potrebno je:

1. Provjeriti postoji li element u projektu.
2. Pronaći njegovu trenutnu implementaciju.
3. Utvrditi njegov izgled, ponašanje i dostupne parametre.
4. Koristiti postojeću implementaciju kad god je moguće.
5. Sačuvati postojeće ponašanje osim ako korisnik izričito zatraži izmjenu.

Za svaki element potrebno je definisati, gdje je primjenjivo:

- Identitet i namjenu
- Vizuelni izgled
- Funkcionalnost i ponašanje
- Uslove aktivacije
- Podesive parametre
- Animacije
- Zvučne efekte
- Interakciju s igračem
- Interakciju s drugim elementima

Nije dozvoljeno praviti više nezavisnih implementacija istog elementa bez opravdanog razloga.

## 3. Razdvajanje izgleda i funkcionalnosti

**Tema određuje izgled. Element određuje ponašanje.**

- Vizuelni prikaz i funkcionalnost elementa moraju biti razdvojeni gdje god je to tehnički opravdano.
- Stabilna i propadajuća podloga unutar iste teme moraju izgledati identično prije aktivacije propadanja.
- Skrivena zamka ne smije se vizuelno razlikovati od običnog elementa, osim ako je to izričito zatraženo.
- Promjena teme ne smije nenamjerno promijeniti mehaniku elementa.
- Funkcionalnost elementa mora ostati dosljedna kroz različite teme.

Ne uvoditi vizuelne razlike koje igraču unaprijed otkrivaju skrivene zamke.

## 4. Dosljednost vizuelnih tema

- Svaki nivo mora koristiti temu koja mu je dodijeljena.
- Koristiti postojeći sistem tema i grafičke resurse.
- Elementi unutar istog okruženja moraju imati usklađen vizuelni stil.
- Ne kreirati drugačiji izgled postojećeg elementa pri svakom korištenju.
- Promjena teme ne smije uticati na funkcionalnost igre.
- Ne mijenjati izgled drugih elemenata ako to nije dio zahtjeva.

## 5. Razvoj nivoa

Nivoi se moraju graditi korištenjem već definisanih elemenata i mehanika.

Kada korisnik zatraži dodavanje postojećeg elementa u određeni nivo:

1. Pronaći postojeću implementaciju elementa.
2. Zadržati njegovu definisanu funkcionalnost.
3. Dodati ga koristeći postojeći način implementacije.
4. Izmijeniti samo traženi nivo.
5. Provjeriti da ostali nivoi nisu nenamjerno promijenjeni.

**Primjer:**

Korisnik kaže: „Ubaci muhu u nivo 17.”

To znači koristiti postojeći element muhe sa svim njegovim definisanim funkcijama.

To ne znači kreirati novu muhu, mijenjati njeno ponašanje ili izmišljati drugačiji izgled.

Dozvoljeno je podešavati parametre za pojedinačni nivo ako element podržava takvu konfiguraciju, bez mijenjanja njegovih osnovnih funkcija.

## 6. Jedinstveni izvor definicija elemenata

Svaki element mora imati jednu glavnu implementaciju ili definiciju.

- Prvo provjeriti postoji li već odgovarajući mehanizam u repozitoriju.
- Ne uvoditi novi registar elemenata ako postojeća arhitektura već podržava njihovu organizaciju.
- Izbjegavati dupliciranje funkcionalnosti kroz različite nivoe.
- Podrazumijevani parametri elementa moraju biti dosljedni.
- Svaku promjenu zajedničke funkcionalnosti potrebno je analizirati zbog mogućeg uticaja na druge nivoe.

## 7. Animacije i zvukovi

- Animacije i zvukovi moraju biti povezani s odgovarajućim radnjama elemenata.
- Koristiti postojeće animacije i zvučne resurse gdje god je moguće.
- Ne duplicirati logiku animacija i zvukova kroz nivoe.
- Ne dodavati nepotrebne efekte koji nisu zatraženi.
- Zadržati postojeće vremenske intervale i način aktivacije, osim ako je promjena izričito zatražena.

## 8. Očuvanje postojećih funkcionalnosti

Prije izmjene zajedničkog koda potrebno je:

1. Utvrditi koji elementi i nivoi koriste taj kod.
2. Analizirati moguće posljedice izmjene.
3. Napraviti najmanju potrebnu promjenu.
4. Pokrenuti relevantne postojeće testove i provjere.
5. Potvrditi da ranije funkcionalnosti nisu narušene.

Nije dozvoljeno samostalno mijenjati utvrđena pravila igre.

## 9. Testiranje i validacija

Kada postojeća arhitektura podržava automatsko testiranje, koristiti ga i po potrebi proširiti.

Posebno provjeravati:

- Da isti element zadržava svoju funkcionalnost u različitim nivoima.
- Da promjena teme ne mijenja mehaniku igre.
- Da skrivene zamke ostaju vizuelno neprepoznatljive prije aktivacije kada je to zahtijevano.
- Da posebne postavke jednog nivoa ne mijenjaju globalno ponašanje elemenata.
- Da dodavanje elementa u jedan nivo ne mijenja nenamjerno druge nivoe.

Ne uvoditi novi sistem testiranja bez opravdanja i odobrenja.

Ne tvrditi da je testiranje uspješno ako testovi nisu stvarno izvršeni.

## 10. Postupak izvršavanja zadataka

Za svaki razvojni zahtjev potrebno je:

1. Pregledati relevantne postojeće datoteke.
2. Pronaći postojeće implementacije i zavisnosti.
3. Utvrditi najmanji potreban obim izmjena.
4. Implementirati traženu funkcionalnost.
5. Izvršiti dostupne provjere.
6. Ukratko navesti šta je promijenjeno i šta eventualno nije završeno.

Ne dodavati nove funkcionalnosti koje korisnik nije tražio.

Ako je zahtjev nejasan i može značajno uticati na ponašanje igre, zatražiti pojašnjenje prije donošenja odluke.

## 11. Postojeći sadržaj igre

Svi postojeći nivoi, elementi, mehanike i grafički resursi predstavljaju dio postojećeg projekta.

- Ne brisati postojeći sadržaj bez izričitog odobrenja.
- Ne redizajnirati nivoe koji nisu predmet zahtjeva.
- Ne zamjenjivati postojeće elemente novim verzijama bez potrebe.
- Sačuvati postojeće kontrole i interakcije igrača.
- Ne mijenjati sistem napredovanja kroz nivoe bez zahtjeva.

## 12. Osnovni princip razvoja

**Napravi jednom. Definiši jednom. Koristi svugdje.**

Svaki element igre mora imati predvidljivo, stabilno i dosljedno ponašanje bez obzira na nivo u kojem se koristi.

Cilj je da razvoj novih nivoa prvenstveno predstavlja kombinovanje i podešavanje postojećih elemenata, a ne ponovno programiranje istih funkcionalnosti.

**Prioriteti: stabilnost, ponovna upotreba, dosljednost, jednostavno održavanje i kvalitet gameplaya.**

## 13. Dodatna definicija postojećih elemenata

Ove definicije imaju prednost kada se određeni element koristi u nivou. Koristiti postojeće implementacije i ne praviti duple sisteme.

### Čekić

- Smjer dolaska definiše se posebno za svaki nivo.
- Aktivira se kada igrač dođe do definisane tačke na nivou.
- Prije napada se pojavi munja/bljesak.
- Nakon bljeska čeka tačno 0,6 sekundi.
- Zatim leti veoma brzo, pravo u definisanom smjeru.
- Ako dodirne lika, lik umire i igra nastavlja po postojećim pravilima smrti.
- Ako promaši lika, nastavlja pravo i izlazi iz scene.
- Ne vraća se samostalno.
- Aktivira se jednom po svakom pozivu. Za novi napad mora se ponovo pozvati.
- Čekić uvijek koristi isti postojeći izgled.
- Munja/bljesak se ne smije zadržati na ekranu.

### Šiljci

- Jedna grupa uvijek ima 3 šiljka.
- Šiljci se ne vide prije aktivacije.
- Aktiviraju se kada igrač stane na njih.
- Kada se aktivira jedan šiljak, aktiviraju se svi šiljci u grupi.
- Igrač odmah umire.
- Razmak između šiljaka ostaje kao u postojećoj implementaciji.
- Ne dodavati vizuelne oznake koje bi igraču unaprijed otkrile skrivene šiljke.

### Muha

- Muha leti od jednog kraja ekrana do drugog u obliku broja 8.
- Tokom normalnog leta samo leti.
- Nasumično se zaustavlja u intervalu između 2 i 8 sekundi.
- Nakon toga miruje tačno 1 sekundu.
- Pri završetku mirovanja pamti smjer prema kojem se lik tada nalazi.
- Zatim se zalijeće pravo u tom smjeru.
- Brzina zalijetanja je 5 puta veća od normalne brzine leta.
- Ako pogodi lika, ne ubija ga, nego ga odbaci 8% dalje od muhe.
- Odbacivanje se dešava samo tokom zalijetanja.
- Nakon pogotka nastavlja pravo i izlazi iz scene.
- Ako promaši, takođe nastavlja pravo i izlazi iz scene.
- Nakon izlaska ponovo nastavlja normalno letenje.
- Ne smije mijenjati osnovni postojeći izgled muhe.

### Zmaj

- Aktivira se kada se igrač nalazi u zoni definisanoj za taj nivo, npr. između 30% i 80% širine scene.
- Zmaj uvijek dolazi lagano iza lika, s lijeve strane scene, i dolijeće direktno prema njemu.
- Funkcija zmaja definiše se posebno za svaki nivo.

#### Funkcija hvatanja

- Zmaj uhvati lika i odnese ga na početak scene.
- Hvatanje je neizbježno kada se aktivira.
- Funkcija hvatanja može se desiti samo jednom po nivou.
- Zmaj ostavi lika na početku scene.
- Nakon toga zmaj izlazi iz scene na desnu stranu.

#### Funkcija vatre

- Zmaj dolazi lagano iza lika s lijeve strane.
- Ispali jednu vatru iz usta.
- Lik može izbjeći vatru skakanjem ili kretanjem.
- Ako vatra pogodi lika, lik umire.
- Zmaj prati lika ograničeno, približno 10%, i dovoljno polako da igrač može umaći.
- Nakon napada još kratko prati lika, zatim izlazi iz scene na desnu stranu.
- Vatreni napad može se ponoviti više puta u istom nivou ako se zmaj ponovo pozove.

### Platforme

#### Fiksna stabilna platforma

- Vidljiva je i aktivna od početka nivoa.
- Ima istu boju kao podloga tog nivoa.

#### Stabilna platforma koja dolazi odozdo

- Prije aktivacije se ne vidi.
- Aktivira se kada igrač stane na prekidač.
- Dolazi odozdo srednjom brzinom.
- Zaustavlja se na visini definisanoj u nivou.
- Ostaje na toj visini do kraja nivoa.
- Ima istu boju kao podloga tog nivoa.

#### Stabilna platforma koja pada odozgo

- Koristi ista pravila kao stabilna platforma koja dolazi odozdo.
- Aktivira se prekidačem.
- Prije aktivacije se ne vidi.
- Spušta se odozgo srednjom brzinom.
- Zaustavlja se na visini definisanoj u nivou.
- Ostaje na toj visini do kraja nivoa.
- Ima istu boju kao podloga tog nivoa.

#### Platforma koja propada

- Aktivira se kada igrač stane na nju.
- Čeka 0,5 sekundi prije propadanja.
- Odgoda mora omogućiti igraču da skoči.
- Zatim pada pravo dole i izlazi iz scene.
- Ne vraća se do kraja nivoa.
- Izgled prije aktivacije mora biti isti kao izgled stabilne platforme u istoj temi.

#### Pokretna platforma

- Vidljiva je i aktivna od početka nivoa.
- Svaka platforma posebno definiše da li se kreće:
  - lijevo-desno između dvije tačke;
  - gore-dole između dvije tačke.
- Kreće se polako.
- Na krajnjoj tački odmah mijenja smjer.
- Ima istu boju kao podloga tog nivoa.

### Most

- Stabilni i propadajući most uvijek imaju standardni izgled mosta kao most na nivou 1.5.
- Izgled mosta ne zavisi od toga da li je most stabilan ili propadajući.

#### Stabilni most

- Fiksan je i aktivan od početka nivoa.

#### Propadajući kameni most

- Svaki kamen se aktivira posebno kada igrač stane na njega.
- Kamen počinje padati nakon 0,3 sekunde.
- Pada samo kamen na kojem je igrač stao.
- Ostali kamenovi ostaju stabilni.
- Pali kamen izlazi iz scene i ne vraća se do kraja nivoa.

### Lift

- Lift se aktivira kada igrač stane na njega.
- Podigne igrača na sljedeći nivo.
- Postavlja se samo na kraju 6. nivoa svakog bloka.
- Uvijek koristi postojeći standardni izgled lifta.
- Podiže igrača srednjom brzinom.

### Munja/bljesak

- Munja je samo kratki vizuelni bljesak i upozorenje za čekić.
- Bljesne jednom i traje približno 0,5 sekundi.
- Ne smije ostati vidljiva nakon bljeska.
- Ima zvučni efekat kada zvuk bude naknadno dodat.
- Ne nanosi štetu i nema drugu funkciju.

## 14. Prednost novijih definicija

- Dodatne definicije iz ovog dokumenta imaju prednost nad ranijim opštim opisima kada se razlikuju.
- Posebno, za muhu važe interval mirovanja od 2 do 8 sekundi i trajanje mirovanja od 1 sekunde.
- Sve ostale ranije definicije ostaju važeće kada nisu u suprotnosti s ovim dodatnim definicijama.
  
