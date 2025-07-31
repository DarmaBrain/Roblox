--// UI & Service Setup
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local backpack = player:WaitForChild("Backpack")
local character = player.Character or player.CharacterAdded:Wait()
local attributeName = "PET_UUID"

-- Remove existing UI if exists
local existing = player:WaitForChild("PlayerGui"):FindFirstChild("AutoGiftUI")
if existing then existing:Destroy() end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoGiftUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local main = Instance.new("Frame", screenGui)
main.Size = UDim2.new(0, 250, 0, 350)
main.Position = UDim2.new(0.5, -125, 0.5, -175)
main.BackgroundColor3 = Color3.fromRGB(255, 225, 250)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true

-- Top Bar
local topBar = Instance.new("Frame", main)
topBar.Size = UDim2.new(1, 0, 0, 30)
topBar.BackgroundTransparency = 1

local title = Instance.new("TextLabel", topBar)
title.Size = UDim2.new(1, -60, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.Text = "🎁 Elbin Auto Gift"
title.TextColor3 = Color3.fromRGB(255, 105, 180)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left

local minimizeBtn = Instance.new("TextButton", topBar)
minimizeBtn.Size = UDim2.new(0, 20, 1, 0)
minimizeBtn.Position = UDim2.new(1, -45, 0, 0)
minimizeBtn.Text = "🔽"
minimizeBtn.BackgroundTransparency = 1
minimizeBtn.TextColor3 = Color3.fromRGB(100, 100, 100)
minimizeBtn.Font = Enum.Font.Gotham
minimizeBtn.TextSize = 14

local closeBtn = Instance.new("TextButton", topBar)
closeBtn.Size = UDim2.new(0, 20, 1, 0)
closeBtn.Position = UDim2.new(1, -25, 0, 0)
closeBtn.Text = "❌"
closeBtn.BackgroundTransparency = 1
closeBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
closeBtn.Font = Enum.Font.Gotham
closeBtn.TextSize = 14

-- Player List
local playerListFrame = Instance.new("ScrollingFrame", main)
playerListFrame.Size = UDim2.new(1, -20, 0, 60)
playerListFrame.Position = UDim2.new(0, 10, 0, 35)
playerListFrame.BackgroundColor3 = Color3.fromRGB(240, 240, 255)
playerListFrame.BorderSizePixel = 0
playerListFrame.ScrollBarThickness = 4
playerListFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
playerListFrame.VerticalScrollBarInset = Enum.ScrollBarInset.Always
playerListFrame.ClipsDescendants = true

local UIListLayout = Instance.new("UIListLayout", playerListFrame)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 2)

-- Pet Search Box
local petSearchBox = Instance.new("TextBox")
petSearchBox.Size = UDim2.new(1, -50, 0, 25)
petSearchBox.Position = UDim2.new(0, 10, 0, 100)
petSearchBox.PlaceholderText = "🔍 Search Pet..."
petSearchBox.BackgroundColor3 = Color3.fromRGB(255, 240, 255)
petSearchBox.TextColor3 = Color3.fromRGB(0, 0, 0)
petSearchBox.Font = Enum.Font.Gotham
petSearchBox.TextSize = 14
petSearchBox.ClearTextOnFocus = false
petSearchBox.Parent = main

local selectAllBtn = Instance.new("TextButton")
selectAllBtn.Size = UDim2.new(0, 30, 0, 25)
selectAllBtn.Position = UDim2.new(1, -35, 0, 100)
selectAllBtn.Text = "☑️"
selectAllBtn.BackgroundColor3 = Color3.fromRGB(200, 220, 255)
selectAllBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
selectAllBtn.Font = Enum.Font.Gotham
selectAllBtn.TextSize = 14
selectAllBtn.Visible = false
selectAllBtn.Parent = main

-- Pet List
local petListFrame = Instance.new("ScrollingFrame", main)
petListFrame.Size = UDim2.new(1, -20, 0, 100)
petListFrame.Position = UDim2.new(0, 10, 0, 130)
petListFrame.BackgroundColor3 = Color3.fromRGB(255, 245, 230)
petListFrame.BorderSizePixel = 0
petListFrame.ScrollBarThickness = 4
petListFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
petListFrame.VerticalScrollBarInset = Enum.ScrollBarInset.Always
petListFrame.ClipsDescendants = true

local petListLayout = Instance.new("UIListLayout", petListFrame)
petListLayout.SortOrder = Enum.SortOrder.LayoutOrder
petListLayout.Padding = UDim.new(0, 2)

-- Buttons
local refreshBtn = Instance.new("TextButton", main)
refreshBtn.Size = UDim2.new(1, -20, 0, 30)
refreshBtn.Position = UDim2.new(0, 10, 0, 235)
refreshBtn.Text = "🔄 Refresh"
refreshBtn.BackgroundColor3 = Color3.fromRGB(240, 200, 255)
refreshBtn.Font = Enum.Font.Gotham
refreshBtn.TextSize = 14

local toggleBtn = Instance.new("TextButton", main)
toggleBtn.Size = UDim2.new(1, -20, 0, 30)
toggleBtn.Position = UDim2.new(0, 10, 0, 275)
toggleBtn.Text = "🔘 OFF"
toggleBtn.BackgroundColor3 = Color3.fromRGB(255, 180, 180)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 14

local modeBtn = Instance.new("TextButton", main)
modeBtn.Size = UDim2.new(1, -20, 0, 30)
modeBtn.Position = UDim2.new(0, 10, 0, 315)
modeBtn.Text = "🧠 Mode: Single"
modeBtn.BackgroundColor3 = Color3.fromRGB(200, 220, 255)
modeBtn.Font = Enum.Font.Gotham
modeBtn.TextSize = 14

-- Variables
local targetPlayer = nil
local multiSelectMode = false
local selectedPets = {}
local running = false
local giftingThread = nil
local skipUUIDs = {}
local nameToTools = {}
local nameToButtons = {}
local selectAllState = false

-- Gift Logic
local function giftPet(tool)
	local uuid = tool:GetAttribute(attributeName)
	if skipUUIDs[uuid] then return end
	tool.Parent = character
	task.wait(0.5)

	local gaveError = false
	local connection

	connection = player.PlayerGui.ChildAdded:Connect(function(child)
		if child:IsA("TextLabel") or child:IsA("TextButton") then
			local text = tostring(child.Text or ""):lower()
			if string.find(text, "cannot give") and string.find(text, "favorited") then
				gaveError = true
				skipUUIDs[uuid] = true
				print("⛔ Favorited pet detected, skipping:", tool.Name)
			end
		end
	end)

	ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("PetGiftingService"):FireServer("GivePet", Players:FindFirstChild(targetPlayer))
	task.wait(1)

	if connection then connection:Disconnect() end
	if gaveError then tool.Parent = backpack end
end

-- Toggle Gift
local function toggleGifting()
	if not targetPlayer then return end
	running = not running
	toggleBtn.Text = running and "✅ ON" or "🔘 OFF"
	toggleBtn.BackgroundColor3 = running and Color3.fromRGB(200, 255, 200) or Color3.fromRGB(255, 180, 180)

	if running then
		giftingThread = task.spawn(function()
			while running do
				character = player.Character or player.CharacterAdded:Wait()
				for _, tool in ipairs(character:GetChildren()) do
					if tool:IsA("Tool") and tool:GetAttribute(attributeName) then
						tool.Parent = backpack
						task.wait(0.2)
					end
				end

				if multiSelectMode then
					for _, tools in pairs(selectedPets) do
						for _, tool in ipairs(tools) do
							if tool and tool.Parent == backpack and tool:GetAttribute(attributeName) then
								giftPet(tool)
								task.wait(1)
							end
						end
					end
				else
					local tool = selectedPets[1]
					if tool and tool.Parent == backpack and tool:GetAttribute(attributeName) then
						giftPet(tool)
					end
				end
				task.wait(1)
			end
		end)
	end
end

-- Update Player List
local function updatePlayerList()
	for _, child in ipairs(playerListFrame:GetChildren()) do
		if not child:IsA("UIListLayout") then child:Destroy() end
	end

	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= player then
			local option = Instance.new("TextButton")
			option.Size = UDim2.new(1, 0, 0, 25)
			option.BackgroundColor3 = Color3.fromRGB(220, 240, 255)
			option.TextColor3 = Color3.fromRGB(0, 0, 0)
			option.Font = Enum.Font.Gotham
			option.TextSize = 14
			option.Text = ((targetPlayer == p.Name and "✅ " or "🎯 ") .. p.Name)
			option.Parent = playerListFrame
			option.AutoButtonColor = true
			option.TextWrapped = true
			option.MouseButton1Click:Connect(function()
				targetPlayer = p.Name
				updatePlayerList()
			end)
		end
	end
end

-- Update Pet List
local function updatePetList()
	for _, child in ipairs(petListFrame:GetChildren()) do
		if not child:IsA("UIListLayout") then child:Destroy() end
	end

	nameToTools = {}
	nameToButtons = {}
	local searchText = string.lower(petSearchBox.Text or "")

	for _, tool in ipairs(backpack:GetChildren()) do
		if tool:IsA("Tool") and tool:GetAttribute(attributeName) and not skipUUIDs[tool:GetAttribute(attributeName)] then
			local name = tool.Name
			if not nameToTools[name] then nameToTools[name] = {} end
			table.insert(nameToTools[name], tool)
		end
	end

	for name, tools in pairs(nameToTools) do
		if searchText == "" or string.find(string.lower(name), searchText) then
			local option = Instance.new("TextButton")
			option.Size = UDim2.new(1, 0, 0, 25)
			option.BackgroundColor3 = Color3.fromRGB(255, 230, 220)
			option.Font = Enum.Font.Gotham
			option.TextSize = 14
			option.Text = "🐾 " .. name
			option.Parent = petListFrame
			nameToButtons[name] = option

			option.MouseButton1Click:Connect(function()
				if multiSelectMode then
					if selectedPets[name] then
						selectedPets[name] = nil
					else
						selectedPets[name] = tools
					end
				else
					selectedPets = {tools[1]}
				end

				for n, btn in pairs(nameToButtons) do
					local isSelected = multiSelectMode and selectedPets[n] or (selectedPets[1] == nameToTools[n][1])
					btn.Text = (isSelected and "✅ " or "🐾 ") .. n
				end
			end)
		end
	end
end

-- Events
toggleBtn.MouseButton1Click:Connect(toggleGifting)
refreshBtn.MouseButton1Click:Connect(function()
	updatePlayerList()
	updatePetList()
end)
modeBtn.MouseButton1Click:Connect(function()
	multiSelectMode = not multiSelectMode
	modeBtn.Text = multiSelectMode and "🧠 Mode: Multi" or "🧠 Mode: Single"
	selectAllBtn.Visible = multiSelectMode
	selectAllState = false
	selectedPets = {}
	selectAllBtn.BackgroundColor3 = Color3.fromRGB(200, 220, 255)
	updatePetList()
end)
petSearchBox:GetPropertyChangedSignal("Text"):Connect(updatePetList)

selectAllBtn.MouseButton1Click:Connect(function()
	if not multiSelectMode then return end
	selectAllState = not selectAllState

	if selectAllState then
		selectedPets = {}
		for _, child in ipairs(petListFrame:GetChildren()) do
			if child:IsA("TextButton") then
				local name = child.Text:gsub("✅ ", ""):gsub("🐾 ", "")
				if name ~= "" and nameToTools[name] then
					selectedPets[name] = nameToTools[name]
				end
			end
		end
		selectAllBtn.BackgroundColor3 = Color3.fromRGB(200, 255, 200)
	else
		selectedPets = {}
		selectAllBtn.BackgroundColor3 = Color3.fromRGB(200, 220, 255)
	end

	for name, btn in pairs(nameToButtons) do
		local isSelected = selectedPets[name] ~= nil
		btn.Text = (isSelected and "✅ " or "🐾 ") .. name
	end
end)

-- Minimize / Close
local content = {playerListFrame, petSearchBox, selectAllBtn, petListFrame, refreshBtn, toggleBtn, modeBtn}
local minimized = false

minimizeBtn.MouseButton1Click:Connect(function()
	minimized = not minimized
	for _, el in ipairs(content) do el.Visible = not minimized end
	minimizeBtn.Text = minimized and "🔼" or "🔽"
	main.Size = minimized and UDim2.new(0, 120, 0, 35) or UDim2.new(0, 250, 0, 350)
	title.Text = minimized and "🎁 Gift" or "🎁 Elbin Auto Gift"
end)

closeBtn.MouseButton1Click:Connect(function()
	running = false
	screenGui:Destroy()
end)

-- Start
updatePlayerList()
updatePetList()