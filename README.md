# 👗 Famous Fashion – das Mode-Spiel

Ein Mode-Wettbewerb als Browser-Spiel. Du spielst gegen **11 Mitspielerinnen**
(vom Computer gesteuert), also **12 Teilnehmerinnen** pro Runde. Es läuft komplett
im Browser – perfekt für **Vercel**, kein Server nötig.

## 🎮 So läuft eine Runde

1. **Lobby** – 30 Sekunden warten, bis 12 Teilnehmerinnen da sind.
2. **Thema** – ein Motto wird verkündet (z. B. „Sommer am Strand", „Elegante Gala").
3. **Umkleide** – stell dein Outfit zusammen: **Haare, Make-up, Oberteil
   (T-Shirt/Pullover), Kleid/Hose/Rock, Schuhe, Tasche**. Dein Püppchen ändert
   sich live mit.
4. **Voting** – alle bewerten sich gegenseitig mit **bis zu 5 Sternen**.
5. **Siegerehrung** – wer die meisten Sterne hat, kommt aufs Podest. Die
   **Top 3** bekommen Platz 1, 2 und 3.

**Tipp zum Gewinnen:** Wähle Kleidung, die zum **Thema** passt – dafür gibt es
die meisten Sterne!

## 🚀 Auf Vercel veröffentlichen

Das ist eine ganz normale statische Webseite (`index.html`, `styles.css`,
`game.js`). Du musst in Vercel **nichts** einstellen:

- Framework Preset: **Other** (kein Framework)
- Build Command: *(leer lassen)*
- Output Directory: *(leer lassen)*

Sobald dieser Code auf deinem Vercel-Branch liegt, deployt Vercel automatisch und
zeigt das Spiel an. Der 404-Fehler ist damit weg.

## 💻 Lokal testen

Einfach die Datei `index.html` im Browser öffnen. Oder mit einem kleinen Server:

```
python3 -m http.server
```
… und dann `http://localhost:8000` im Browser aufrufen.

## ⚙️ Selbst anpassen

Alles steckt in `game.js` ganz oben:

- **`CONFIG`** – Zeiten (Lobby 30 Sek., Styling-Zeit) und Anzahl Teilnehmerinnen.
- **`THEMES`** – die Motto-Themen.
- **`CATALOG`** – die Garderobe. Neue Kleidung hinzufügen: Eintrag mit `name`,
  Farbe/Emoji und `tags` (zu welchen Themen das Teil passt) ergänzen.
- **`NAMES`** – die Namen der Mitspielerinnen.

## 📁 Dateien

```
index.html   → Aufbau der Bildschirme (Lobby, Thema, Umkleide, Voting, Ergebnis)
styles.css   → Aussehen (Pink/Lila/Gold, das Mode-Püppchen)
game.js      → Spiel-Logik (Runden, Garderobe, Bewertung, Platzierung)
```

## ℹ️ Hinweise

- **„Nur Mädchen":** Eine Webseite kann das Geschlecht der Besucher nicht prüfen.
  Das Spiel ist als Mädchen-Thema (Name, Farben, Design) gebaut.
- **Echtes Online-Multiplayer** mit 12 echten Menschen gleichzeitig bräuchte
  einen Server (z. B. mit Logins und Live-Verbindung). Diese Version spielst du
  gegen vom Computer gesteuerte Mitspielerinnen – das fühlt sich genauso an und
  läuft sofort ohne Server. Online-Multiplayer können wir später ergänzen.

Viel Spaß! 💖
