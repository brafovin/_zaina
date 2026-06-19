--!strict
-- GameConfig
-- Zentrale Einstellungen fuer das Fashion-Spiel "Style Stars".
-- Hier kannst du fast alles anpassen, ohne den restlichen Code zu veraendern:
-- Zeiten, Punkte und die Garderobe (welche Kleidung es gibt).

local GameConfig = {}

-- ============================================================
-- SPIELER
-- ============================================================
GameConfig.MinPlayers = 2 -- So viele Spielerinnen werden gebraucht, damit eine Runde startet.

-- ============================================================
-- ZEITEN (in Sekunden)
-- ============================================================
GameConfig.IntermissionTime = 15 -- Wartephase in der Lobby zwischen zwei Runden.
GameConfig.StylingTime = 180 -- 3 Minuten Outfit aussuchen.
GameConfig.RunwayTimePerPlayer = 8 -- So lange wird jede Spielerin einzeln auf dem Laufsteg gezeigt.
GameConfig.VotingTime = 25 -- Zeit zum Abstimmen, wer den besten Style hat.
GameConfig.ResultsTime = 15 -- So lange wird die Siegerehrung (Platz 1/2/3) gezeigt.

-- ============================================================
-- PUNKTE
-- ============================================================
GameConfig.PointsPerVote = 10 -- Punkte fuer jede Stimme, die eine Spielerin bekommt.
GameConfig.BonusFirst = 100 -- Extra-Punkte fuer Platz 1.
GameConfig.BonusSecond = 60 -- Extra-Punkte fuer Platz 2.
GameConfig.BonusThird = 30 -- Extra-Punkte fuer Platz 3.

-- ============================================================
-- GARDEROBE
-- Das sind Beispiel-Klamotten. Du kannst eigene aus dem Roblox-Katalog
-- eintragen: Suche im Katalog ein Kleidungsstueck, kopiere die Zahl aus der
-- Webadresse (z. B. catalog/1234567/...) und trage sie als "AssetId" ein.
-- Lass die Liste ruhig erstmal so - das Spiel laeuft auch damit.
-- ============================================================
GameConfig.Wardrobe = {
	Shirts = {
		{ Name = "Rosa Top", AssetId = 0 },
		{ Name = "Glitzer-Shirt", AssetId = 0 },
		{ Name = "Lila Pulli", AssetId = 0 },
	},
	Pants = {
		{ Name = "Jeans", AssetId = 0 },
		{ Name = "Rock", AssetId = 0 },
		{ Name = "Leggings", AssetId = 0 },
	},
	Hats = {
		{ Name = "Schleife", AssetId = 0 },
		{ Name = "Krone", AssetId = 0 },
		{ Name = "Sonnenbrille", AssetId = 0 },
	},
}

-- ============================================================
-- THEME / DESIGN
-- ============================================================
GameConfig.GameName = "Style Stars"
GameConfig.Colors = {
	Primary = Color3.fromRGB(255, 105, 180), -- Pink
	Secondary = Color3.fromRGB(186, 85, 211), -- Lila
	Accent = Color3.fromRGB(255, 215, 0), -- Gold
	Text = Color3.fromRGB(255, 255, 255),
}

-- ============================================================
-- SPIEL-ZUSTAENDE (Phasen). Nicht aendern - das ist nur eine Liste der Namen.
-- ============================================================
GameConfig.States = {
	Intermission = "Intermission",
	Styling = "Styling",
	Runway = "Runway",
	Voting = "Voting",
	Results = "Results",
}

return GameConfig
