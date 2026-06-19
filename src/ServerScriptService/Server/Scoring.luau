--!strict
-- Scoring
-- Verwaltet die Punkte: zaehlt Stimmen aus, vergibt Platz 1/2/3 und fuehrt
-- eine dauerhafte Bestenliste (Gesamtpunkte ueber alle Runden).

local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local GameConfig = require(Shared:WaitForChild("GameConfig"))

local Scoring = {}

-- Gesamtpunkte pro Spielerin ueber die ganze Sitzung: { [userId] = punkte }
local totalScores: { [number]: number } = {}

-- Stimmen der aktuellen Runde: { [userId der Bewerteten] = anzahlStimmen }
local roundVotes: { [number]: number } = {}

-- Merkt sich, wer schon abgestimmt hat (damit niemand doppelt waehlt).
local hasVoted: { [number]: boolean } = {}

-- Setzt das "Leaderboard"-Objekt fuer eine Spielerin auf (Roblox-Bestenliste oben rechts).
function Scoring.setupPlayer(player: Player)
	totalScores[player.UserId] = totalScores[player.UserId] or 0

	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"

	local points = Instance.new("IntValue")
	points.Name = "Style-Punkte"
	points.Value = totalScores[player.UserId]
	points.Parent = leaderstats

	leaderstats.Parent = player
end

function Scoring.removePlayer(player: Player)
	-- Punkte bleiben fuer die Sitzung erhalten, falls die Spielerin wiederkommt.
	hasVoted[player.UserId] = nil
end

-- Startet eine neue Voting-Runde: alle Zwischenstaende zuruecksetzen.
function Scoring.beginRound()
	roundVotes = {}
	hasVoted = {}
end

-- Nimmt eine Stimme entgegen. Gibt true zurueck, wenn die Stimme gueltig war.
function Scoring.registerVote(voter: Player, targetUserId: number): boolean
	-- Niemand darf doppelt abstimmen.
	if hasVoted[voter.UserId] then
		return false
	end
	-- Man darf nicht fuer sich selbst stimmen.
	if voter.UserId == targetUserId then
		return false
	end
	-- Das Ziel muss eine echte, anwesende Spielerin sein.
	if not Players:GetPlayerByUserId(targetUserId) then
		return false
	end

	hasVoted[voter.UserId] = true
	roundVotes[targetUserId] = (roundVotes[targetUserId] or 0) + 1
	return true
end

-- Wertet die Runde aus und vergibt Punkte. Liefert die Rangliste zurueck.
-- Rueckgabe: sortierte Liste { { userId, name, votes, gained, total, place } }
function Scoring.finishRound(): { any }
	local results = {}

	for _, player in Players:GetPlayers() do
		local votes = roundVotes[player.UserId] or 0
		table.insert(results, {
			userId = player.UserId,
			name = player.DisplayName,
			votes = votes,
			gained = votes * GameConfig.PointsPerVote,
			total = 0, -- wird unten gefuellt
			place = 0, -- wird unten gefuellt
		})
	end

	-- Sortieren: meiste Stimmen zuerst.
	table.sort(results, function(a, b)
		return a.votes > b.votes
	end)

	-- Platz-Bonus vergeben (nur wenn die Spielerin ueberhaupt eine Stimme hat).
	for index, entry in ipairs(results) do
		entry.place = index
		if entry.votes > 0 then
			if index == 1 then
				entry.gained += GameConfig.BonusFirst
			elseif index == 2 then
				entry.gained += GameConfig.BonusSecond
			elseif index == 3 then
				entry.gained += GameConfig.BonusThird
			end
		end

		-- Gesamtpunkte aktualisieren.
		totalScores[entry.userId] = (totalScores[entry.userId] or 0) + entry.gained
		entry.total = totalScores[entry.userId]

		-- Bestenliste oben rechts aktualisieren.
		local player = Players:GetPlayerByUserId(entry.userId)
		if player then
			local leaderstats = player:FindFirstChild("leaderstats")
			local points = leaderstats and leaderstats:FindFirstChild("Style-Punkte")
			if points and points:IsA("IntValue") then
				points.Value = entry.total
			end
		end
	end

	return results
end

-- Liefert die aktuelle Kandidatinnen-Liste fuer das Voting-Menue.
function Scoring.getCandidates(): { any }
	local list = {}
	for _, player in Players:GetPlayers() do
		table.insert(list, { userId = player.UserId, name = player.DisplayName })
	end
	return list
end

return Scoring
