# 👗 Style Stars – ein Roblox Fashion-Spiel

Ein Mode-Wettbewerb für Roblox: Die Spielerinnen bekommen **3 Minuten Zeit**, um
sich ein Outfit zusammenzustellen. Danach werden alle nacheinander auf dem
**Laufsteg** vorgestellt, alle stimmen ab, **wer den besten Style hat** – und es
gibt eine **Siegerehrung mit Platz 1, 2 und 3** und **Style-Punkten**. Dann geht
die nächste Runde los.

> **Wichtiger Hinweis:** Roblox kann das Geschlecht der Spieler technisch nicht
> prüfen. „Nur Mädchen, keine Jungs" lässt sich also nicht erzwingen. Das Spiel
> ist deshalb als Mädchen-Thema (Name, Farben, Design) gebaut – mitspielen kann
> technisch aber jeder.

---

## 🎮 So läuft eine Runde ab

| Phase | Was passiert | Dauer (einstellbar) |
|-------|--------------|---------------------|
| **Lobby** | Warten, bis genug Spielerinnen da sind | 15 Sek. |
| **Styling** | Outfit aus der Garderobe aussuchen | **3 Minuten** |
| **Laufsteg** | Jede wird einzeln vorgestellt | 8 Sek. pro Spielerin |
| **Voting** | Alle wählen den besten Style | 25 Sek. |
| **Ergebnis** | Platz 1/2/3 + Punkte | 15 Sek. |

Punkte: **10 pro Stimme** plus Bonus für die Plätze (**+100 / +60 / +30**).
Die Gesamtpunkte stehen oben rechts in der Roblox-Bestenliste.

---

## 🚀 So bekommst du das Spiel in Roblox Studio

Der Code hier wird mit dem Werkzeug **Rojo** in Roblox Studio geladen.

### Schritt 1 – Programme installieren
1. **Roblox Studio** installieren (kostenlos auf roblox.com).
2. **Rojo** installieren – am einfachsten als Plugin direkt in Studio:
   In Studio oben auf *Plugins → Manage Plugins → Marketplace* nach **„Rojo"**
   suchen und installieren.

### Schritt 2 – Code mit Studio verbinden
1. Dieses Projekt auf deinen Computer laden (Download/Clone).
2. Ein **Terminal** im Projektordner öffnen und den Rojo-Server starten:
   ```
   rojo serve
   ```
   (Hast du Rojo noch nicht als Programm? Dann `rokit install` ausführen –
   das installiert Rojo automatisch.)
3. In Roblox Studio das **Rojo-Plugin** öffnen und auf **„Connect"** klicken.

Jetzt erscheinen alle Skripte automatisch in Studio. Wenn du am Code etwas
änderst, wird es sofort übernommen.

### Schritt 3 – Spielen / Testen
In Studio oben auf **„Play"** drücken. Zum Testen mit mehreren Spielerinnen:
*Test → Clients and Servers →* z. B. 2 Spieler starten.

---

## ⚙️ Selbst anpassen (ganz einfach)

Fast alles stellst du in **einer Datei** ein:
`src/ReplicatedStorage/Shared/GameConfig.luau`

- **Zeiten** ändern (z. B. Styling kürzer/länger).
- **Punkte** ändern.
- **Garderobe** füllen: Die Beispiel-Kleidung hat noch keine echten Teile
  (`AssetId = 0`). Such im Roblox-Katalog ein Kleidungsstück, kopiere die Zahl
  aus der Webadresse und trag sie als `AssetId` ein. Dann tragen die
  Spielerinnen es wirklich.
- **Farben & Name** des Spiels ändern.

---

## 📁 Aufbau des Projekts

```
src/
├─ ReplicatedStorage/Shared/
│  ├─ GameConfig.luau   → Alle Einstellungen (Zeiten, Punkte, Garderobe, Farben)
│  └─ Net.luau          → Verbindung Server <-> Spielerinnen
├─ ServerScriptService/Server/
│  ├─ init.server.luau  → Hauptablauf (Lobby → Styling → Laufsteg → Voting → Ergebnis)
│  ├─ Scoring.luau      → Punkte zählen & Platzierungen
│  └─ Wardrobe.luau     → Kleidung anziehen
└─ StarterPlayer/StarterPlayerScripts/Client/
   └─ init.client.luau  → Die Bildschirm-Oberfläche (Menüs, Timer, Voting)
```

Viel Spaß beim Bauen! 💖
