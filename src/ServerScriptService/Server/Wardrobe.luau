--!strict
-- Wardrobe (Garderobe)
-- Zieht den Spielerinnen Kleidung an, wenn sie waehrend der Styling-Phase
-- in ihrem Menue etwas auswaehlen. Greift sicherheitshalber nur, wenn gerade
-- wirklich die Styling-Phase laeuft (Schutz vor Schummeln).

local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local GameConfig = require(Shared:WaitForChild("GameConfig"))

local Wardrobe = {}

-- Wird von aussen (GameManager) gesetzt: erlaubt das Umziehen nur in der Styling-Phase.
local stylingAllowed = false

function Wardrobe.setStylingAllowed(allowed: boolean)
	stylingAllowed = allowed
end

-- Sucht ein Garderoben-Teil nach Kategorie und AssetId. Gibt nil zurueck, wenn
-- es das Teil nicht in der erlaubten Liste gibt (Schutz vor erfundenen IDs).
local function findItem(category: string, assetId: number): boolean
	local list = (GameConfig.Wardrobe :: any)[category]
	if not list then
		return false
	end
	for _, item in list do
		if item.AssetId == assetId then
			return true
		end
	end
	return false
end

-- Wendet ein Kleidungsstueck auf den Avatar der Spielerin an.
function Wardrobe.equip(player: Player, category: string, assetId: number)
	if not stylingAllowed then
		return
	end
	-- AssetId 0 = "kein Teil hinterlegt" (Platzhalter aus der Beispiel-Garderobe).
	if assetId == 0 then
		return
	end
	if not findItem(category, assetId) then
		return
	end

	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end

	-- HumanoidDescription ist der sichere Weg, Aussehen zu aendern.
	local ok, description = pcall(function()
		return humanoid:GetAppliedDescription()
	end)
	if not ok or not description then
		return
	end

	if category == "Shirts" then
		description.Shirt = assetId
	elseif category == "Pants" then
		description.Pants = assetId
	elseif category == "Hats" then
		description.HatAccessory = tostring(assetId)
	end

	pcall(function()
		humanoid:ApplyDescription(description)
	end)
end

return Wardrobe
