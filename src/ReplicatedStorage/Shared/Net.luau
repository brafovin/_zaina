--!strict
-- Net
-- Kleine Hilfe fuer die Kommunikation zwischen Server und Spielerinnen (Clients).
-- Der Server erstellt hier die "RemoteEvents" (Funknachrichten), der Client findet sie.
--
-- Welche Nachrichten gibt es?
--   StateChanged : Server -> alle     "Die Phase hat gewechselt" (+ Dauer + Daten)
--   EquipItem    : Client -> Server   "Ich moechte dieses Kleidungsstueck anziehen"
--   SubmitVote   : Client -> Server   "Ich stimme fuer diese Spielerin ab"
--   Spotlight    : Server -> alle     "Diese Spielerin ist gerade auf dem Laufsteg"
--   ScoreUpdate  : Server -> alle     "Hier ist die aktuelle Bestenliste"

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Net = {}

local EVENT_NAMES = {
	"StateChanged",
	"EquipItem",
	"SubmitVote",
	"Spotlight",
	"ScoreUpdate",
}

local FOLDER_NAME = "StyleStarsRemotes"

-- Wird vom Server aufgerufen: erstellt den Ordner mit allen RemoteEvents.
function Net.setupServer(): Folder
	assert(RunService:IsServer(), "Net.setupServer darf nur auf dem Server laufen")

	local folder = ReplicatedStorage:FindFirstChild(FOLDER_NAME)
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = FOLDER_NAME
		folder.Parent = ReplicatedStorage
	end

	for _, name in EVENT_NAMES do
		if not folder:FindFirstChild(name) then
			local event = Instance.new("RemoteEvent")
			event.Name = name
			event.Parent = folder
		end
	end

	return folder
end

-- Liefert ein RemoteEvent nach Namen (funktioniert auf Server und Client).
function Net.get(name: string): RemoteEvent
	local folder = ReplicatedStorage:WaitForChild(FOLDER_NAME, 30)
	assert(folder, "StyleStarsRemotes-Ordner wurde nicht gefunden")
	local event = folder:WaitForChild(name, 30)
	assert(event and event:IsA("RemoteEvent"), "RemoteEvent '" .. name .. "' wurde nicht gefunden")
	return event :: RemoteEvent
end

return Net
