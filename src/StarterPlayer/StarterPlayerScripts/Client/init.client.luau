--!strict
-- Client (laeuft bei jeder Spielerin)
-- Baut die komplette Bildschirm-Oberflaeche (GUI) selbst auf und reagiert auf
-- die Nachrichten vom Server: Phasenanzeige, Timer, Garderobe, Voting, Siegerehrung.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local GameConfig = require(Shared:WaitForChild("GameConfig"))
local Net = require(Shared:WaitForChild("Net"))

local StateChanged = Net.get("StateChanged")
local EquipItem = Net.get("EquipItem")
local SubmitVote = Net.get("SubmitVote")
local Spotlight = Net.get("Spotlight")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local C = GameConfig.Colors

-- ============================================================
-- Kleine Helfer zum Bauen der Oberflaeche
-- ============================================================
local function corner(parent: Instance, radius: number?)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or 12)
	c.Parent = parent
	return c
end

local function makeFrame(props: { [string]: any }): Frame
	local f = Instance.new("Frame")
	f.BorderSizePixel = 0
	f.BackgroundColor3 = props.BackgroundColor3 or C.Secondary
	for key, value in props do
		(f :: any)[key] = value
	end
	return f
end

local function makeLabel(props: { [string]: any }): TextLabel
	local l = Instance.new("TextLabel")
	l.BackgroundTransparency = 1
	l.Font = Enum.Font.GothamBold
	l.TextColor3 = C.Text
	l.TextScaled = true
	for key, value in props do
		(l :: any)[key] = value
	end
	return l
end

local function makeButton(props: { [string]: any }): TextButton
	local b = Instance.new("TextButton")
	b.BorderSizePixel = 0
	b.AutoButtonColor = true
	b.Font = Enum.Font.GothamBold
	b.TextColor3 = C.Text
	b.TextScaled = true
	b.BackgroundColor3 = C.Primary
	for key, value in props do
		(b :: any)[key] = value
	end
	corner(b, 10)
	return b
end

-- ============================================================
-- Haupt-GUI aufbauen
-- ============================================================
local gui = Instance.new("ScreenGui")
gui.Name = "StyleStarsGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

-- Oberer Balken: Phasenname + Timer.
local topBar = makeFrame({
	Name = "TopBar",
	Size = UDim2.new(0, 380, 0, 70),
	Position = UDim2.new(0.5, 0, 0, 12),
	AnchorPoint = Vector2.new(0.5, 0),
	BackgroundColor3 = C.Secondary,
	BackgroundTransparency = 0.1,
})
topBar.Parent = gui
corner(topBar, 16)

local phaseLabel = makeLabel({
	Name = "Phase",
	Size = UDim2.new(1, -20, 0.5, 0),
	Position = UDim2.new(0, 10, 0, 6),
	Text = GameConfig.GameName,
	TextXAlignment = Enum.TextXAlignment.Center,
})
phaseLabel.Parent = topBar

local timerLabel = makeLabel({
	Name = "Timer",
	Size = UDim2.new(1, -20, 0.5, -6),
	Position = UDim2.new(0, 10, 0.5, 0),
	Text = "",
	TextColor3 = C.Accent,
	TextXAlignment = Enum.TextXAlignment.Center,
})
timerLabel.Parent = topBar

-- Spotlight-Banner (Laufsteg).
local spotlightBanner = makeLabel({
	Name = "Spotlight",
	Size = UDim2.new(0, 500, 0, 60),
	Position = UDim2.new(0.5, 0, 0, 95),
	AnchorPoint = Vector2.new(0.5, 0),
	Text = "",
	TextColor3 = C.Accent,
	Visible = false,
})
spotlightBanner.Parent = gui

-- Behaelter fuer die wechselnden Inhalte (Garderobe / Voting / Ergebnisse).
local content = makeFrame({
	Name = "Content",
	Size = UDim2.new(0, 420, 0, 360),
	Position = UDim2.new(0.5, 0, 1, -20),
	AnchorPoint = Vector2.new(0.5, 1),
	BackgroundColor3 = C.Secondary,
	BackgroundTransparency = 0.15,
	Visible = false,
})
content.Parent = gui
corner(content, 16)

-- Leert den Inhaltsbereich.
local function clearContent()
	for _, child in content:GetChildren() do
		if not child:IsA("UICorner") then
			child:Destroy()
		end
	end
end

-- ============================================================
-- Timer-Logik (zaehlt jede Sekunde runter)
-- ============================================================
local timerEnd = 0
local timerActive = false

local function startTimer(duration: number)
	if duration <= 0 then
		timerActive = false
		timerLabel.Text = ""
		return
	end
	timerEnd = os.clock() + duration
	timerActive = true
end

RunService.Heartbeat:Connect(function()
	if not timerActive then
		return
	end
	local remaining = math.max(0, math.floor(timerEnd - os.clock() + 0.5))
	local minutes = math.floor(remaining / 60)
	local seconds = remaining % 60
	timerLabel.Text = string.format("%d:%02d", minutes, seconds)
	if remaining <= 0 then
		timerActive = false
	end
end)

-- ============================================================
-- Ansicht: GARDEROBE (Styling-Phase)
-- ============================================================
local function showWardrobe(wardrobe: any)
	clearContent()
	content.Visible = true

	local title = makeLabel({
		Size = UDim2.new(1, -20, 0, 36),
		Position = UDim2.new(0, 10, 0, 8),
		Text = "Such dir dein Outfit aus!",
		TextXAlignment = Enum.TextXAlignment.Center,
	})
	title.Parent = content

	local scroll = Instance.new("ScrollingFrame")
	scroll.Size = UDim2.new(1, -20, 1, -56)
	scroll.Position = UDim2.new(0, 10, 0, 48)
	scroll.BackgroundTransparency = 1
	scroll.BorderSizePixel = 0
	scroll.ScrollBarThickness = 6
	scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroll.Parent = content

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 8)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = scroll

	-- Pro Kategorie (Shirts/Pants/Hats) eine kleine Ueberschrift + Knoepfe.
	local categories = { { "Shirts", "Oberteile" }, { "Pants", "Hosen & Roecke" }, { "Hats", "Accessoires" } }
	for _, pair in categories do
		local key, displayName = pair[1], pair[2]
		local items = wardrobe[key]
		if items then
			local heading = makeLabel({
				Size = UDim2.new(1, 0, 0, 26),
				Text = displayName,
				TextColor3 = C.Accent,
				TextXAlignment = Enum.TextXAlignment.Left,
			})
			heading.Parent = scroll

			for _, item in items do
				local btn = makeButton({
					Size = UDim2.new(1, 0, 0, 38),
					Text = item.Name,
				})
				btn.Parent = scroll
				btn.MouseButton1Click:Connect(function()
					EquipItem:FireServer(key, item.AssetId)
				end)
			end
		end
	end
end

-- ============================================================
-- Ansicht: VOTING
-- ============================================================
local function showVoting(candidates: { any })
	clearContent()
	content.Visible = true

	local title = makeLabel({
		Size = UDim2.new(1, -20, 0, 36),
		Position = UDim2.new(0, 10, 0, 8),
		Text = "Wer hat den besten Style?",
		TextXAlignment = Enum.TextXAlignment.Center,
	})
	title.Parent = content

	local scroll = Instance.new("ScrollingFrame")
	scroll.Size = UDim2.new(1, -20, 1, -56)
	scroll.Position = UDim2.new(0, 10, 0, 48)
	scroll.BackgroundTransparency = 1
	scroll.BorderSizePixel = 0
	scroll.ScrollBarThickness = 6
	scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroll.Parent = content

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 8)
	layout.Parent = scroll

	local voted = false
	for _, candidate in candidates do
		-- Man selbst steht nicht zur Wahl.
		if candidate.userId ~= player.UserId then
			local btn = makeButton({
				Size = UDim2.new(1, 0, 0, 44),
				Text = candidate.name,
			})
			btn.Parent = scroll
			btn.MouseButton1Click:Connect(function()
				if voted then
					return
				end
				voted = true
				SubmitVote:FireServer(candidate.userId)
				title.Text = "Stimme fuer " .. candidate.name .. " gezaehlt!"
				for _, other in scroll:GetChildren() do
					if other:IsA("TextButton") then
						other.AutoButtonColor = false
						other.BackgroundColor3 = (other == btn) and C.Accent or Color3.fromRGB(90, 90, 90)
					end
				end
			end)
		end
	end
end

-- ============================================================
-- Ansicht: SIEGEREHRUNG (Platz 1/2/3)
-- ============================================================
local function showResults(results: { any })
	clearContent()
	content.Visible = true

	local title = makeLabel({
		Size = UDim2.new(1, -20, 0, 40),
		Position = UDim2.new(0, 10, 0, 8),
		Text = "Siegerehrung",
		TextColor3 = C.Accent,
		TextXAlignment = Enum.TextXAlignment.Center,
	})
	title.Parent = content

	local scroll = Instance.new("ScrollingFrame")
	scroll.Size = UDim2.new(1, -20, 1, -56)
	scroll.Position = UDim2.new(0, 10, 0, 52)
	scroll.BackgroundTransparency = 1
	scroll.BorderSizePixel = 0
	scroll.ScrollBarThickness = 6
	scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroll.Parent = content

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 8)
	layout.Parent = scroll

	local medals = { "🥇", "🥈", "🥉" }
	for index, entry in ipairs(results) do
		local prefix = medals[index] or (tostring(index) .. ".")
		local row = makeFrame({
			Size = UDim2.new(1, 0, 0, 48),
			BackgroundColor3 = (index <= 3) and C.Primary or Color3.fromRGB(80, 80, 80),
			BackgroundTransparency = 0.1,
		})
		row.Parent = scroll
		corner(row, 10)

		local text = makeLabel({
			Size = UDim2.new(1, -20, 1, 0),
			Position = UDim2.new(0, 10, 0, 0),
			Text = string.format("%s %s  -  %d Stimmen  (+%d)", prefix, entry.name, entry.votes, entry.gained),
			TextXAlignment = Enum.TextXAlignment.Left,
		})
		text.Parent = row
	end
end

-- ============================================================
-- Auf Server-Nachrichten reagieren
-- ============================================================
local phaseNames = {
	[GameConfig.States.Intermission] = "Lobby",
	[GameConfig.States.Styling] = "Styling – 3 Minuten!",
	[GameConfig.States.Runway] = "Laufsteg",
	[GameConfig.States.Voting] = "Voting",
	[GameConfig.States.Results] = "Ergebnis",
}

StateChanged.OnClientEvent:Connect(function(state: string, duration: number, data: any)
	phaseLabel.Text = phaseNames[state] or state
	startTimer(duration)
	spotlightBanner.Visible = false
	content.Visible = false

	if state == GameConfig.States.Intermission then
		if data and data.waiting then
			phaseLabel.Text = string.format("Warte auf Spielerinnen (%d/%d)", data.current, data.needed)
		end
	elseif state == GameConfig.States.Styling then
		showWardrobe(data.wardrobe)
	elseif state == GameConfig.States.Voting then
		showVoting(data.candidates)
	elseif state == GameConfig.States.Results then
		showResults(data.results)
	end
end)

-- Laufsteg: zeigt, wer gerade praesentiert wird.
Spotlight.OnClientEvent:Connect(function(userId: number, name: string, duration: number)
	spotlightBanner.Visible = true
	spotlightBanner.TextTransparency = 0
	if userId == player.UserId then
		spotlightBanner.Text = "✨ DU bist dran! Zeig deinen Style! ✨"
	else
		spotlightBanner.Text = "Auf dem Laufsteg: " .. name
	end

	-- Sanft einblenden.
	spotlightBanner.TextSize = 28
	local tween = TweenService:Create(
		spotlightBanner,
		TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{ TextTransparency = 0 }
	)
	tween:Play()
end)

print("[Style Stars] Oberflaeche geladen.")
