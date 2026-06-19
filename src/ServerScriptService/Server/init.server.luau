--!strict
-- GameManager (Hauptscript auf dem Server)
-- Steuert den kompletten Ablauf der Fashion-Show in einer Endlosschleife:
--   Lobby -> 3 Min Styling -> Laufsteg -> Voting -> Siegerehrung -> von vorne.

local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local GameConfig = require(Shared:WaitForChild("GameConfig"))
local Net = require(Shared:WaitForChild("Net"))

local Scoring = require(script:WaitForChild("Scoring"))
local Wardrobe = require(script:WaitForChild("Wardrobe"))

-- Funknachrichten aufbauen.
Net.setupServer()
local StateChanged = Net.get("StateChanged")
local EquipItem = Net.get("EquipItem")
local SubmitVote = Net.get("SubmitVote")
local Spotlight = Net.get("Spotlight")
local ScoreUpdate = Net.get("ScoreUpdate")

-- ============================================================
-- Spieler beitreten / verlassen
-- ============================================================
Players.PlayerAdded:Connect(function(player)
	Scoring.setupPlayer(player)
end)

Players.PlayerRemoving:Connect(function(player)
	Scoring.removePlayer(player)
end)

-- ============================================================
-- Nachrichten von den Spielerinnen entgegennehmen
-- ============================================================
EquipItem.OnServerEvent:Connect(function(player, category, assetId)
	-- Eingaben pruefen (kommen vom Client, also nie blind vertrauen).
	if typeof(category) ~= "string" or typeof(assetId) ~= "number" then
		return
	end
	Wardrobe.equip(player, category, assetId)
end)

local votingOpen = false
SubmitVote.OnServerEvent:Connect(function(player, targetUserId)
	if not votingOpen then
		return
	end
	if typeof(targetUserId) ~= "number" then
		return
	end
	Scoring.registerVote(player, targetUserId)
end)

-- ============================================================
-- Hilfsfunktionen
-- ============================================================

-- Sagt allen Clients, welche Phase laeuft, wie lange, und schickt Zusatzdaten mit.
local function broadcastState(state: string, duration: number, data: any?)
	StateChanged:FireAllClients(state, duration, data)
end

-- Wartet die angegebene Zeit, bricht aber ab, wenn zu wenige Spielerinnen da sind.
-- Gibt true zurueck, wenn die Zeit normal abgelaufen ist.
local function waitPhase(duration: number): boolean
	local elapsed = 0
	while elapsed < duration do
		if #Players:GetPlayers() < GameConfig.MinPlayers then
			return false
		end
		task.wait(1)
		elapsed += 1
	end
	return true
end

-- Wartet, bis genug Spielerinnen da sind.
local function waitForPlayers()
	while #Players:GetPlayers() < GameConfig.MinPlayers do
		broadcastState(GameConfig.States.Intermission, 0, {
			waiting = true,
			needed = GameConfig.MinPlayers,
			current = #Players:GetPlayers(),
		})
		task.wait(2)
	end
end

-- ============================================================
-- Die einzelnen Phasen
-- ============================================================

local function phaseIntermission()
	broadcastState(GameConfig.States.Intermission, GameConfig.IntermissionTime, { waiting = false })
	waitPhase(GameConfig.IntermissionTime)
end

local function phaseStyling()
	Wardrobe.setStylingAllowed(true)
	broadcastState(GameConfig.States.Styling, GameConfig.StylingTime, {
		wardrobe = GameConfig.Wardrobe,
	})
	waitPhase(GameConfig.StylingTime)
	Wardrobe.setStylingAllowed(false)
end

local function phaseRunway()
	-- Jede Spielerin wird einzeln im Rampenlicht gezeigt.
	local players = Players:GetPlayers()
	local total = #players * GameConfig.RunwayTimePerPlayer
	broadcastState(GameConfig.States.Runway, total, { count = #players })

	for _, player in players do
		if #Players:GetPlayers() < GameConfig.MinPlayers then
			break
		end
		Spotlight:FireAllClients(player.UserId, player.DisplayName, GameConfig.RunwayTimePerPlayer)
		task.wait(GameConfig.RunwayTimePerPlayer)
	end
end

local function phaseVoting()
	Scoring.beginRound()
	votingOpen = true
	broadcastState(GameConfig.States.Voting, GameConfig.VotingTime, {
		candidates = Scoring.getCandidates(),
	})
	waitPhase(GameConfig.VotingTime)
	votingOpen = false
end

local function phaseResults()
	local results = Scoring.finishRound()
	ScoreUpdate:FireAllClients(results)
	broadcastState(GameConfig.States.Results, GameConfig.ResultsTime, {
		results = results,
	})
	waitPhase(GameConfig.ResultsTime)
end

-- ============================================================
-- Endlosschleife: das Herzstueck des Spiels
-- ============================================================
task.spawn(function()
	while true do
		waitForPlayers()
		phaseIntermission()

		-- Sicherheitscheck: Sind nach der Lobby noch genug Spielerinnen da?
		if #Players:GetPlayers() < GameConfig.MinPlayers then
			continue
		end

		phaseStyling()
		phaseRunway()
		phaseVoting()
		phaseResults()
	end
end)

print("[Style Stars] Server gestartet. Warte auf Spielerinnen...")
