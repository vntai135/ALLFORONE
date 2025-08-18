-- SKIDDED BY SIGMA @rizzify101

--== SERVICES ==--
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")
local StarterGui = game:GetService("StarterGui")
local Lighting = game:GetService("Lighting")
local task = task
local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

-- Load Spawner Module (Admin Tab)
--local Spawner = loadstring(game:HttpGet("https://gitlab.com/darkiedarkie/dark/-/raw/main/Spawner.lua"))()

-- UI Colors and Constants
local SIDEBAR_BG = Color3.fromRGB(36, 37, 43)
local SIDEBAR_SELECTED_BG = Color3.fromRGB(44, 47, 52)
local MAIN_BG = Color3.fromRGB(44, 47, 52)
local BUTTON_BG = Color3.fromRGB(36, 39, 45)
local BUTTON_SELECTED_BG = Color3.fromRGB(60, 60, 70)
local BUTTON_TEXT = Color3.fromRGB(255,255,255)
local HEADER_COLOR = Color3.fromRGB(255,255,255)
local CLASSY_FONT = Enum.Font.GothamBold
local ICONS = {
	"rbxassetid://6031075930", -- Egg
	"rbxassetid://6031068426", -- Duplicate
	"rbxassetid://6034996695", -- Trade
	"rbxassetid://6031094683", -- Steal
	"rbxassetid://6031068433", -- Size
	"rbxassetid://6031094674", -- Admin
	"rbxassetid://6031068431" -- MoonCat Aura icon, pick/change as you like
}
local TABNAMES = {
	"Eggs", "Dupes", "Trade", "Stealer", "Size", "Admin", "MoonCat Aura"
}
local TABBUTTONS = {
	{ -- Eggs Tab
		{Text="Enable ESP", Callback="espToggleBtn", Type="toggle"},
		{Text="Reroll Egg", Callback="rerollBtn", Type="button"},
		{Text="Set Priority", Callback="priorityInput", Type="textbox"},
	},
	{ -- Dupes Tab
		{Text="Duplicate Held Pet", Callback="dupeButton", Type="button"},
	},
	{ -- Trade Tab
		{Text="Freeze Trade", Callback="FreezeTrade", Type="toggle"},
		{Text="Auto Accept", Callback="LockInventory", Type="toggle"},
	},
	{ -- Stealer Tab
		{Text="Select Player", Callback="playersButton", Type="button"},
		{Text="Steal Pet", Callback="stealButton", Type="button"},
	},
	{ -- Size Tab
		{Text="Increase Size ×2", Callback="incBtn", Type="button"},
		{Text="Reset Size", Callback="resetBtn", Type="button"},
	},
	{ -- Admin Tab
		{Text="Run Command", Callback="adminCommand", Type="button"},
		{Text="Command Input", Callback="adminCommandInput", Type="textbox"}
	},
	{ -- MoonCat Aura Tab
		{Text="Toggle Aura", Callback="mooncatAuraToggle", Type="toggle"}
	}
}

local UIRefs = {}

-- Main ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BloxifiedMainUI"
screenGui.Parent = PlayerGui
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 350, 0, 350)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
mainFrame.BackgroundColor3 = MAIN_BG
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui
mainFrame.Active = true
mainFrame.ClipsDescendants = true
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)

-- Minimize button
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 32, 0, 32)
minimizeBtn.Position = UDim2.new(1, -38, 0, 8)
minimizeBtn.BackgroundTransparency = 1
minimizeBtn.Text = "-"
minimizeBtn.TextColor3 = Color3.fromRGB(200,200,200)
minimizeBtn.TextSize = 32
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.Parent = mainFrame
minimizeBtn.ZIndex = 20

-- Sidebar
local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 120, 1, -16)
sidebar.Position = UDim2.new(0, 0, 0, 32)
sidebar.BackgroundColor3 = SIDEBAR_BG
sidebar.BorderSizePixel = 0
sidebar.Parent = mainFrame
Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 12)

-- Sidebar header
local header = Instance.new("TextLabel")
header.Size = UDim2.new(1, 0, 0, 32)
header.Position = UDim2.new(0, 0, 0, 0)
header.BackgroundTransparency = 1
header.Text = "BLOXIFIED"
header.TextColor3 = HEADER_COLOR
header.Font = CLASSY_FONT
header.TextSize = 22
header.TextXAlignment = Enum.TextXAlignment.Center
header.Parent = mainFrame
header.ZIndex = 21

local sidebarLayout = Instance.new("UIListLayout", sidebar)
sidebarLayout.FillDirection = Enum.FillDirection.Vertical
sidebarLayout.Padding = UDim.new(0, 4)
sidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder

local sidebarButtons = {}
local selectedTabIdx = 1

-- Content Panel
local contentPanel = Instance.new("Frame")
contentPanel.Size = UDim2.new(1, -120, 1, -16)
contentPanel.Position = UDim2.new(0, 120, 0, 32)
contentPanel.BackgroundColor3 = MAIN_BG
contentPanel.BorderSizePixel = 0
contentPanel.Parent = mainFrame
Instance.new("UICorner", contentPanel).CornerRadius = UDim.new(0, 12)

local tabPanels = {}

-- ========== EGG TAB LOGIC ==========
local petPools = {
	["PRIMAL EGG"] = {"PARASAUROLOPHUS", "IGUANODON", "PACHYCEPHALOSAURUS", "DILOPHOSAURUS", "ANKYLOSAURUS", "SPINOSAURUS"},
	["PREMIUM PRIMAL EGG"] = {"PARASAUROLOPHUS", "IGUANODON", "PACHYCEPHALOSAURUS", "DILOPHOSAURUS", "ANKYLOSAURUS", "SPINOSAURUS"},
	["DINOSAUR EGG"] = {"RAPTOR", "TRICERATOPS", "STEGOSAURUS", "PTERODACTYL", "BRONTOSAURUS", "T-REX"},
	["PARADISE EGG"] = {"OSTRICH", "PEACOCK", "CAPYBARA", "SCARLET MACAW", "MIMIC OCTOPUS"},
	["OASIS EGG"] = {"MEERKAT", "SAND SNAKE", "AXOLOTL", "HYACINTH MACAW", "FENNEC FOX"},
	["MYTHICAL EGG"] = {"RED FOX", "GREY MOUSE", "RED GIANT ANT", "SQUIRREL", "BROWN MOUSE"},
	["BUG EGG"] = {"CATERPILLAR", "PRAYING MANTIS", "GIANT ANT", "DRAGONFLY", "SNAIL"},
	["BEE EGG"] = {"BEE", "HONEY BEE", "BEAR BEE", "PETAL BEE", "QUEEN BEE"},
	["ANTI-BEE EGG"] = {"DISCO BEE", "BUTTERFLY", "MOTH", "WASP", "TARANTULA HAWK"},
	["NIGHT EGG"] = {"MOLE", "FROG", "RACCOON", "NIGHT OWL", "ECHO FROG", "HEDGEHOG"},
	["RARE EGG"] = {"ORANGE TABBY", "SPOTTED DEER", "ROOSTER", "MONKEY"},
	["UNCOMMON EGG"] = {"BLACK BUNNY", "CAT", "CHICKEN", "DEER"},
	["COMMON EGG"] = {"BUNNY", "GOLDEN LAB", "DOG"},
	["LEGENDARY EGG"] = {"COW", "SEA OTTER", "SILVER MONKEY", "TURTLE", "POLAR BEAR"},
	["ZEN EGG"] = {"SHIBA INU", "NIHONZARU", "TANUKI", "TANCHOZURU", "KAPPA", "KITSUNE"}
}
local function getFakePetForEgg(eggName)
	local pool = petPools[string.upper(eggName or "")]
	if pool and #pool > 0 then
		return pool[math.random(1, #pool)]
	end
	return "???"
end
local function getRandomKg()
	local kg = math.random(100, 1090) / 100
	return string.format("%.2f KG", kg)
end

local showESP = false
local espCache = {}
local activeEggs = {}
local eggPets = {}
local currentCamera = workspace.CurrentCamera
local function createEspLabel(egg, petName, petKg)
	if espCache[egg] then
		espCache[egg].Frame:Destroy()
		espCache[egg] = nil
	end
	local espFrame = Instance.new("Frame", screenGui)
	espFrame.Size = UDim2.new(0, 210, 0, 46)
	espFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	espFrame.BackgroundTransparency = 0.15
	Instance.new("UICorner", espFrame).CornerRadius = UDim.new(0, 10)
	local stroke = Instance.new("UIStroke", espFrame)
	stroke.Color = Color3.fromRGB(110, 170, 255)
	stroke.Thickness = 2

	local eggLabel = Instance.new("TextLabel", espFrame)
	eggLabel.Text = egg:GetAttribute("EggName") or "UNKNOWN"
	eggLabel.Size = UDim2.new(1, -20, 0, 26)
	eggLabel.Position = UDim2.new(0, 10, 0, 0)
	eggLabel.BackgroundTransparency = 1
	eggLabel.TextColor3 = Color3.fromRGB(255,255,255)
	eggLabel.Font = Enum.Font.GothamBold
	eggLabel.TextSize = 18
	eggLabel.ZIndex = 2
	eggLabel.TextXAlignment = Enum.TextXAlignment.Left

	local petLabel = Instance.new("TextLabel", espFrame)
	petLabel.Text = string.format("%s [%s]", petName, petKg or getRandomKg())
	petLabel.Size = UDim2.new(1, -20, 0, 18)
	petLabel.Position = UDim2.new(0, 10, 0, 28)
	petLabel.BackgroundTransparency = 1
	petLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
	petLabel.Font = Enum.Font.GothamBlack
	petLabel.TextSize = 16
	petLabel.ZIndex = 2
	petLabel.TextXAlignment = Enum.TextXAlignment.Left

	espFrame.Visible = showESP
	espCache[egg] = {Frame = espFrame, EggLabel = eggLabel, PetLabel = petLabel}
end
local function AddEsp(egg)
	if not egg:GetAttribute("EggName") then return end
	activeEggs[egg] = egg
	local petName = getFakePetForEgg(egg:GetAttribute("EggName"))
	local petKg = getRandomKg()
	eggPets[egg] = petName
	createEspLabel(egg, petName, petKg)
end
local function RemoveEsp(egg)
	if espCache[egg] and espCache[egg].Frame then
		espCache[egg].Frame:Destroy()
		espCache[egg] = nil
	end
	activeEggs[egg] = nil
	eggPets[egg] = nil
end
RunService.RenderStepped:Connect(function()
	for egg, cache in pairs(espCache) do
		if not egg or not egg:IsDescendantOf(workspace) then
			if cache and cache.Frame then cache.Frame.Visible = false end
			continue
		end
		local pos, onScreen = currentCamera:WorldToViewportPoint(egg:GetPivot().Position + Vector3.new(0, 3.5, 0))
		cache.Frame.Position = UDim2.new(0, pos.X - 105, 0, pos.Y - 46)
		cache.Frame.Visible = onScreen and showESP
	end
end)
for _, egg in ipairs(CollectionService:GetTagged("PetEggServer")) do
	AddEsp(egg)
end
CollectionService:GetInstanceAddedSignal("PetEggServer"):Connect(AddEsp)
CollectionService:GetInstanceRemovedSignal("PetEggServer"):Connect(RemoveEsp)

-- ========== DUPLICATE PET LOGIC ==========
local dupeEnabled = true
local function dupeHeldItem()
	if not dupeEnabled then return end
	local character = player.Character or player.CharacterAdded:Wait()
	local heldTool = character:FindFirstChildOfClass("Tool")
	local statusLabel = UIRefs.StatusLabel
	if heldTool then
		local dupe = heldTool:Clone()
		dupe.Name = heldTool.Name
		local backpack = player:FindFirstChild("Backpack") or player:WaitForChild("Backpack")
		if backpack then
			dupe.Parent = backpack
			if statusLabel then statusLabel.Text = "Successfully duplicated!" end
			task.delay(2, function()
				if statusLabel then
					statusLabel.Text = "Ready to duplicate"
				end
			end)
		else
			dupe:Destroy()
			if statusLabel then statusLabel.Text = "Failed - no backpack" end
		end
	else
		if statusLabel then statusLabel.Text = "No pet equipped!" end
		task.delay(2, function()
			if statusLabel then
				statusLabel.Text = "Ready to duplicate"
			end
		end)
	end
end

-- ========== TRADE TOOLS LOGIC ==========
local tradeStates = {FreezeTrade=false, LockInventory=false}
local function toggleTradeState(name)
	tradeStates[name] = not tradeStates[name]
	print(name .. " is", tradeStates[name] and "ON" or "OFF")
end

-- ========== PET STEALER LOGIC ==========
local selectedType = "Pet"
local selectedPlayer = nil
local function stealPet()
	local petName = UIRefs.PetNameInput and UIRefs.PetNameInput.Text or nil
	local targetPlayer = selectedPlayer or "anyone"
	print(string.format("Stealing %s from %s (Type: %s)", petName or "all", targetPlayer, selectedType))
end

-- ========== PET SIZE LOGIC ==========
local originalData = {}
local currentPet = nil
local function getHeldPet()
	local character = player.Character or player.CharacterAdded:Wait()
	for _, child in pairs(character:GetChildren()) do
		if (child:IsA("Tool") or child:IsA("Model")) and not child:FindFirstChild("Humanoid") then
			return child
		end
	end
	return nil
end
local function getAttachedPetModel()
	local character = player.Character or player.CharacterAdded:Wait()
	local rightHand = character:FindFirstChild("RightHand") or character:FindFirstChild("Right Arm")
	if not rightHand then return nil end
	for _, child in ipairs(rightHand:GetChildren()) do
		if child:IsA("Model") and not child:FindFirstChild("Humanoid") then
			return child
		end
	end
	return nil
end
local function saveOriginalData(pet)
	if not pet then return end
	if not originalData[pet] then
		originalData[pet] = {sizes = {}, meshes = {}, welds = {}, originalName = nil}
		for _, obj in ipairs(pet:GetDescendants()) do
			if obj:IsA("BasePart") then
				originalData[pet].sizes[obj] = obj.Size
			elseif obj:IsA("SpecialMesh") then
				originalData[pet].meshes[obj] = obj.Scale
			elseif obj:IsA("Motor6D") or obj:IsA("Weld") then
				originalData[pet].welds[obj] = {C0 = obj.C0, C1 = obj.C1}
			end
		end
		local nameLabel
		for _, descendant in ipairs(pet:GetDescendants()) do
			if descendant:IsA("TextLabel") and descendant.Text:match("%[.-kg%]") then
				nameLabel = descendant
				break
			end
		end
		if nameLabel then
			originalData[pet].originalName = nameLabel.Text
		else
			originalData[pet].originalName = pet.Name or "Unknown Pet"
		end
	end
end
local function scaleWeldOffsets(instance, multiplier)
	for _, weld in ipairs(instance:GetDescendants()) do
		if weld:IsA("Motor6D") or weld:IsA("Weld") then
			local c0pos = weld.C0.Position * multiplier
			local c1pos = weld.C1.Position * multiplier
			weld.C0 = CFrame.new(c0pos) * (weld.C0 - weld.C0.Position)
			weld.C1 = CFrame.new(c1pos) * (weld.C1 - weld.C1.Position)
		end
	end
end
local function updatePetNameKG(pet, multiplier)
	for _, label in ipairs(pet:GetDescendants()) do
		if label:IsA("TextLabel") and label.Text:match("%[.-kg%]") then
			local name, kg = label.Text:match("^(.-)%[(.-)kg%]$")
			if name and kg then
				local num = tonumber(kg)
				if num then
					label.Text = string.format("%s[%.2fkg]", name, num * multiplier)
				end
			end
		end
	end
end
local function resetPetName(pet)
	local data = originalData[pet]
	if not data or not data.originalName then return end
	for _, label in ipairs(pet:GetDescendants()) do
		if label:IsA("TextLabel") and label.Text:match("%[.-kg%]") then
			label.Text = data.originalName
		end
	end
end
local function scalePetModel(pet, multiplier)
	if not pet then return end
	for _, obj in ipairs(pet:GetDescendants()) do
		if obj:IsA("BasePart") then
			obj.Size = obj.Size * multiplier
		elseif obj:IsA("SpecialMesh") then
			obj.Scale = obj.Scale * multiplier
		end
	end
	scaleWeldOffsets(pet, multiplier)
	updatePetNameKG(pet, multiplier)
end
local function scaleHeldPet(multiplier)
	local pet = getHeldPet()
	local attachedPet = getAttachedPetModel()
	if not pet and not attachedPet then
		warn("No pet found in your hand or attached!")
		return
	end
	if pet then
		saveOriginalData(pet)
		scalePetModel(pet, multiplier)
	end
	if attachedPet and attachedPet ~= pet then
		saveOriginalData(attachedPet)
		scalePetModel(attachedPet, multiplier)
	end
	updatePetNameLabel(pet or attachedPet)
end
local function resetHeldPet(pet)
	if not pet then return end
	local data = originalData[pet]
	if not data then return end
	for obj, size in pairs(data.sizes) do
		if obj and obj.Parent then
			obj.Size = size
		end
	end
	for obj, scale in pairs(data.meshes) do
		if obj and obj.Parent then
			obj.Scale = scale
		end
	end
	for obj, weldData in pairs(data.welds) do
		if obj and obj.Parent then
			obj.C0 = weldData.C0
			obj.C1 = weldData.C1
		end
	end
	resetPetName(pet)
end
local function resetAllPets()
	local pet = getHeldPet()
	local attachedPet = getAttachedPetModel()
	if pet then resetHeldPet(pet) end
	if attachedPet and attachedPet ~= pet then
		resetHeldPet(attachedPet)
	end
	updatePetNameLabel(pet or attachedPet)
end
local function updatePetNameLabel(pet)
	local petLabel = UIRefs.petLabel
	if not petLabel then return end
	if not pet then
		petLabel.Text = "None"
		return
	end
	for _, label in ipairs(pet:GetDescendants()) do
		if label:IsA("TextLabel") and label.Text:match("%[.-kg%]") then
			petLabel.Text = label.Text
			return
		end
	end
	petLabel.Text = pet.Name or "Unknown Pet"
end
local function handlePetChange(newPet)
	if currentPet and currentPet ~= newPet then
		resetHeldPet(currentPet)
	end
	currentPet = newPet
	updatePetNameLabel(currentPet)
end
handlePetChange(getHeldPet())
spawn(function()
	while true do
		task.wait(0.5)
		local character = player.Character
		if character and character.Parent then
			local petNow = getHeldPet()
			if petNow ~= currentPet then
				handlePetChange(petNow)
			end
		else
			currentPet = nil
			updatePetNameLabel(nil)
		end
	end
end)

-- ========== ADMIN COMMAND LOGIC ==========
local commandLog = {}
local function addLog(message)
	local logLabel = Instance.new("TextLabel")
	logLabel.Size = UDim2.new(1, -5, 0, 20)
	logLabel.BackgroundTransparency = 1
	logLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
	logLabel.Font = Enum.Font.Code
	logLabel.TextSize = 12
	logLabel.TextXAlignment = Enum.TextXAlignment.Left
	logLabel.Text = "> " .. message
	if UIRefs.commandScroll then
		logLabel.Parent = UIRefs.commandScroll
		local logLayout = UIRefs.commandScroll:FindFirstChildOfClass("UIListLayout")
		if logLayout then
			UIRefs.commandScroll.CanvasSize = UDim2.new(0, 0, 0, logLayout.AbsoluteContentSize.Y)
			UIRefs.commandScroll.CanvasPosition = Vector2.new(0, UIRefs.commandScroll.CanvasSize.Y.Offset)
		end
	end
end
local function runAdminCommand(cmd)
	addLog(cmd)
	local args = string.split(cmd, " ")
	local command = string.lower(args[1])
	if command == "spawnpet" and args[2] then
		if Spawner then
			Spawner.SpawnPet(args[2], tonumber(args[3]) or 1, tonumber(args[4]) or 1)
			addLog("Spawned pet: " .. args[2])
		else
			addLog("Spawner module not loaded.")
		end
	elseif command == "spawnseed" and args[2] then
		if Spawner then
			Spawner.SpawnSeed(table.concat(args, " ", 2))
			addLog("Spawned seed: " .. table.concat(args, " ", 2))
		else
			addLog("Spawner module not loaded.")
		end
	elseif command == "spawnegg" and args[2] then
		if Spawner then
			Spawner.SpawnEgg(table.concat(args, " ", 2))
			addLog("Spawned egg: " .. table.concat(args, " ", 2))
		else
			addLog("Spawner module not loaded.")
		end
	elseif command == "spin" and args[2] then
		if Spawner then
			Spawner.Spin(table.concat(args, " ", 2))
			addLog("Spinning: " .. table.concat(args, " ", 2))
		else
			addLog("Spawner module not loaded.")
		end
	elseif command == "load" then
		if Spawner then
			Spawner.Load()
			addLog("Default UI loaded.")
		else
			addLog("Spawner module not loaded.")
		end
	else
		addLog("Unknown command.")
	end
end

-- ===== MOONCAT AURA FEATURE (Tab 7) =====
local mooncatAuraEnabled = false
local mooncatOriginalSizes = {}

local function mooncatAuraScan()
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("BasePart") 
			and obj.Color.G > 0.5  -- greenish
			and obj.Size.Y < 2     -- flat on ground
			and obj.Transparency > 0.1
		then
			if mooncatAuraEnabled then
				if not mooncatOriginalSizes[obj] then
					mooncatOriginalSizes[obj] = obj.Size
				end
				obj.Size = Vector3.new(100, obj.Size.Y, 100)
			else
				if mooncatOriginalSizes[obj] then
					obj.Size = mooncatOriginalSizes[obj]
				end
			end
		end
	end
end
RunService.RenderStepped:Connect(mooncatAuraScan)

-- ====== TAB PANEL CREATION (ALL TABS) ======
local function createToggleSwitch(parent, btnData, yOffset)
	local toggleBtn = Instance.new("TextButton", parent)
	toggleBtn.Size = UDim2.new(1, -24, 0, 44)
	toggleBtn.Position = UDim2.new(0, 12, 0, yOffset)
	toggleBtn.BackgroundColor3 = BUTTON_BG
	toggleBtn.Text = btnData.Text
	toggleBtn.TextColor3 = BUTTON_TEXT
	toggleBtn.Font = CLASSY_FONT
	toggleBtn.TextSize = 18
	toggleBtn.TextXAlignment = Enum.TextXAlignment.Left
	toggleBtn.AutoButtonColor = true
	toggleBtn.TextWrapped = true
	Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 8)
	UIRefs[btnData.Callback] = toggleBtn

	local arrow = Instance.new("TextLabel", toggleBtn)
	arrow.Text = ">"
	arrow.Size = UDim2.new(0, 22, 1, 0)
	arrow.Position = UDim2.new(1, -26, 0, 0)
	arrow.BackgroundTransparency = 1
	arrow.TextColor3 = Color3.fromRGB(150,150,150)
	arrow.Font = Enum.Font.GothamBold
	arrow.TextSize = 22
	arrow.TextXAlignment = Enum.TextXAlignment.Right

	
	local isOn = false
	-- initialize from backing feature states so toggle doesn't auto-enable visually
	if btnData.Callback == "espToggleBtn" then
		isOn = showESP
	elseif btnData.Callback == "FreezeTrade" then
		isOn = tradeStates and tradeStates.FreezeTrade or false
	elseif btnData.Callback == "LockInventory" then
		isOn = tradeStates and tradeStates.LockInventory or false
	elseif btnData.Callback == "mooncatAuraToggle" then
		isOn = mooncatAuraEnabled
	end
	-- set initial visuals
	toggleBtn.BackgroundColor3 = isOn and BUTTON_SELECTED_BG or BUTTON_BG
	if btnData.Callback == "mooncatAuraToggle" then
		toggleBtn.Text = isOn and "MoonCat Aura: ON" or "MoonCat Aura: OFF"
		toggleBtn.BackgroundColor3 = isOn and Color3.fromRGB(0, 200, 0) or BUTTON_BG
	end

	toggleBtn.MouseButton1Click:Connect(function()
		isOn = not isOn
		toggleBtn.BackgroundColor3 = isOn and BUTTON_SELECTED_BG or BUTTON_BG
		if btnData.Callback == "espToggleBtn" then
			showESP = isOn
			for _, cache in pairs(espCache) do
				if cache and cache.Frame then
					cache.Frame.Visible = showESP
				end
			end
		elseif btnData.Callback == "FreezeTrade" then
			toggleTradeState("FreezeTrade")
		elseif btnData.Callback == "LockInventory" then
			toggleTradeState("LockInventory")
		elseif btnData.Callback == "mooncatAuraToggle" then
			mooncatAuraEnabled = isOn
			toggleBtn.Text = isOn and "MoonCat Aura: ON" or "MoonCat Aura: OFF"
			toggleBtn.BackgroundColor3 = isOn and Color3.fromRGB(0, 200, 0) or BUTTON_BG
		end
	end)
end

local function createTabPanel(tabIdx)
	local panel = Instance.new("Frame")
	panel.Name = "TabPanel_" .. tabIdx
	panel.Size = UDim2.new(1, 0, 1, 0)
	panel.Position = UDim2.new(0, 0, 0, 0)
	panel.BackgroundTransparency = 0
	panel.BackgroundColor3 = MAIN_BG
	panel.BorderSizePixel = 0
	panel.Visible = false
	panel.Parent = contentPanel
	Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 12)

	local btns = TABBUTTONS[tabIdx]
	if not btns then return panel end

	local lastAdminInputYOffset = nil
	for i, btnData in ipairs(btns) do
		local yOffset = 16 + (i-1) * 52
		if btnData.Type == "textbox" then
			local txt = Instance.new("TextBox", panel)
			txt.Size = UDim2.new(1, -24, 0, 44)
			txt.Position = UDim2.new(0, 12, 0, yOffset)
			txt.BackgroundColor3 = BUTTON_BG
			txt.Text = ""
			txt.PlaceholderText = btnData.Text
			txt.TextColor3 = BUTTON_TEXT
			txt.Font = CLASSY_FONT
			txt.TextSize = 18
			txt.TextXAlignment = Enum.TextXAlignment.Left
			txt.TextWrapped = true
			Instance.new("UICorner", txt).CornerRadius = UDim.new(0, 8)
			UIRefs[btnData.Callback] = txt
			if btnData.Callback == "priorityInput" then
				local priorityView = Instance.new("TextLabel", panel)
				priorityView.Name = "PriorityView"
				priorityView.Size = UDim2.new(1, -24, 0, 22)
				priorityView.Position = UDim2.new(0, 12, 0, yOffset + 44)
				priorityView.BackgroundTransparency = 1
				priorityView.TextColor3 = Color3.fromRGB(110, 170, 255)
				priorityView.Font = CLASSY_FONT
				priorityView.TextSize = 12
				priorityView.TextXAlignment = Enum.TextXAlignment.Center
				priorityView.Text = "Bunny, Dog, Cat..."
				txt:GetPropertyChangedSignal("Text"):Connect(function()
					priorityView.Text = txt.Text ~= "" and txt.Text or "Bunny, Dog, Cat..."
				end)
			end
			if btnData.Callback == "adminCommandInput" then
				txt.FocusLost:Connect(function(enterPressed)
					if enterPressed then
						runAdminCommand(txt.Text)
						txt.Text = ""
					end
				end)
				if tabIdx == 6 then
					lastAdminInputYOffset = yOffset
				end
			end
		elseif btnData.Type == "toggle" then
			createToggleSwitch(panel, btnData, yOffset)
		else -- button
			local btn = Instance.new("TextButton", panel)
			btn.Size = UDim2.new(1, -24, 0, 44)
			btn.Position = UDim2.new(0, 12, 0, yOffset)
			btn.BackgroundColor3 = BUTTON_BG
			btn.Text = btnData.Text
			btn.TextColor3 = BUTTON_TEXT
			btn.Font = CLASSY_FONT
			btn.TextSize = 18
			btn.TextXAlignment = Enum.TextXAlignment.Left
			btn.AutoButtonColor = true
			btn.TextWrapped = true
			Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

			local arrow = Instance.new("TextLabel", btn)
			arrow.Text = ">"
			arrow.Size = UDim2.new(0, 22, 1, 0)
			arrow.Position = UDim2.new(1, -26, 0, 0)
			arrow.BackgroundTransparency = 1
			arrow.TextColor3 = Color3.fromRGB(150,150,150)
			arrow.Font = Enum.Font.GothamBold
			arrow.TextSize = 22
			arrow.TextXAlignment = Enum.TextXAlignment.Right

			UIRefs[btnData.Callback] = btn

			btn.MouseButton1Down:Connect(function()
				btn.BackgroundColor3 = BUTTON_SELECTED_BG
			end)
			btn.MouseButton1Up:Connect(function()
				btn.BackgroundColor3 = BUTTON_BG
			end)

			if btnData.Callback == "rerollBtn" then
				btn.MouseButton1Click:Connect(function()
					for egg, _ in pairs(activeEggs) do
						local eggName = egg:GetAttribute("EggName") or "UNKNOWN"
						local pool = petPools[string.upper(eggName or "")]
						local priority = {}
						if UIRefs.priorityInput and UIRefs.priorityInput.Text ~= "" then
							for pet in string.gmatch(UIRefs.priorityInput.Text, "[^,]+") do
								pet = pet:match("^%s*(.-)%s*$")
								if pool and table.find(pool, pet:upper()) then
									table.insert(priority, pet:upper())
								end
							end
						end
						local chosenPet = #priority > 0 and priority[math.random(1, #priority)] or getFakePetForEgg(eggName)
						local petKg = getRandomKg()
						eggPets[egg] = chosenPet
						createEspLabel(egg, chosenPet, petKg)
					end
				end)
			elseif btnData.Callback == "dupeButton" then
				btn.MouseButton1Click:Connect(dupeHeldItem)
				btn.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton2 then
						dupeEnabled = not dupeEnabled
						btn.Text = dupeEnabled and "Duplicate Held Pet" or "Dupe Disabled"
						if UIRefs.StatusLabel then
							UIRefs.StatusLabel.Text = dupeEnabled and "Ready to duplicate" or "Dupe Disabled"
						end
					end
				end)
				local statusLabel = Instance.new("TextLabel", panel)
				statusLabel.Name = "StatusLabel"
				statusLabel.Size = UDim2.new(1, -24, 0, 22)
				statusLabel.Position = UDim2.new(0, 12, 0, yOffset + 44)
				statusLabel.BackgroundTransparency = 1
				statusLabel.TextColor3 = Color3.fromRGB(170, 85, 255)
				statusLabel.Font = CLASSY_FONT
				statusLabel.TextSize = 14
				statusLabel.TextXAlignment = Enum.TextXAlignment.Center
				statusLabel.Text = "Ready to duplicate"
				UIRefs.StatusLabel = statusLabel
			elseif btnData.Callback == "playersButton" then
				btn.MouseButton1Click:Connect(function()
					local menu = Instance.new("Frame", panel)
					menu.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
					menu.Size = UDim2.new(0, 120, 0, 120)
					menu.Position = UDim2.new(0, btn.AbsolutePosition.X, 0, btn.AbsolutePosition.Y + 40)
					menu.ZIndex = 50
					menu.Visible = true
					Instance.new("UICorner", menu).CornerRadius = UDim.new(0, 8)
					local layout = Instance.new("UIListLayout", menu)
					layout.FillDirection = Enum.FillDirection.Vertical
					layout.Padding = UDim.new(0, 4)
					for _, plr in ipairs(Players:GetPlayers()) do
						if plr ~= player then
							local item = Instance.new("TextButton", menu)
							item.Size = UDim2.new(1, -8, 0, 28)
							item.BackgroundColor3 = Color3.fromRGB(50, 0, 100)
							item.TextColor3 = Color3.fromRGB(255, 255, 255)
							item.Font = CLASSY_FONT
							item.TextSize = 16
							item.Text = plr.Name
							item.ZIndex = 51
							Instance.new("UICorner", item).CornerRadius = UDim.new(0, 6)
							item.MouseButton1Click:Connect(function()
								selectedPlayer = plr.Name
								btn.Text = plr.Name
								menu:Destroy()
							end)
						end
					end
					menu.MouseLeave:Connect(function()
						menu:Destroy()
					end)
				end)
				local petNameInput = Instance.new("TextBox", panel)
				petNameInput.Name = "PetNameInput"
				petNameInput.Size = UDim2.new(1, -24, 0, 32)
				petNameInput.Position = UDim2.new(0, 12, 0, yOffset + 44)
				petNameInput.BackgroundColor3 = BUTTON_BG
				petNameInput.Text = ""
				petNameInput.PlaceholderText = "Pet Name (leave empty for all)"
				petNameInput.Font = CLASSY_FONT
				petNameInput.TextColor3 = Color3.fromRGB(180, 180, 180)
				petNameInput.TextSize = 14
				petNameInput.TextXAlignment = Enum.TextXAlignment.Left
				Instance.new("UICorner", petNameInput).CornerRadius = UDim.new(0, 8)
				UIRefs.PetNameInput = petNameInput
			elseif btnData.Callback == "stealButton" then
				btn.MouseButton1Click:Connect(stealPet)
			elseif btnData.Callback == "incBtn" then
				btn.MouseButton1Click:Connect(function() scaleHeldPet(2) end)
			elseif btnData.Callback == "resetBtn" then
				btn.MouseButton1Click:Connect(resetAllPets)
			elseif btnData.Callback == "adminCommand" then
				btn.MouseButton1Click:Connect(function()
					if UIRefs.adminCommandInput and UIRefs.adminCommandInput.Text ~= "" then
						runAdminCommand(UIRefs.adminCommandInput.Text)
						UIRefs.adminCommandInput.Text = ""
					end
				end)
			end
		end
	end

	if tabIdx == 6 and lastAdminInputYOffset ~= nil then
		local commandScroll = Instance.new("ScrollingFrame", panel)
		commandScroll.Name = "commandScroll"
		commandScroll.Size = UDim2.new(1, -24, 0, 70)
		commandScroll.Position = UDim2.new(0, 12, 0, lastAdminInputYOffset + 44 + 8)
		commandScroll.BackgroundTransparency = 0.3
		commandScroll.BackgroundColor3 = Color3.fromRGB(20, 40, 20)
		commandScroll.ScrollBarThickness = 6
		commandScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
		Instance.new("UICorner", commandScroll).CornerRadius = UDim.new(0, 8)
		local logLayout = Instance.new("UIListLayout", commandScroll)
		logLayout.SortOrder = Enum.SortOrder.LayoutOrder
		UIRefs.commandScroll = commandScroll
	end

	return panel
end

-- Create all tab panels (now 7 tabs)
for i = 1, #TABNAMES do
	tabPanels[i] = createTabPanel(i)
end

-- Sidebar buttons/tabs
for i, tabName in ipairs(TABNAMES) do
	local sidebarBtn = Instance.new("TextButton")
	sidebarBtn.Size = UDim2.new(1, -12, 0, 40)
	sidebarBtn.BackgroundColor3 = i == 1 and SIDEBAR_SELECTED_BG or SIDEBAR_BG
	sidebarBtn.Text = ""
	sidebarBtn.BorderSizePixel = 0
	sidebarBtn.Parent = sidebar
	sidebarBtn.AutoButtonColor = false
	Instance.new("UICorner", sidebarBtn).CornerRadius = UDim.new(0, 8)

	local icon = Instance.new("ImageLabel", sidebarBtn)
	icon.Size = UDim2.new(0, 22, 0, 22)
	icon.Position = UDim2.new(0, 10, 0.5, -11)
	icon.Image = ICONS[i] or "rbxassetid://6031094678"
	icon.BackgroundTransparency = 1

	local label = Instance.new("TextLabel", sidebarBtn)
	label.Size = UDim2.new(1, -44, 1, 0)
	label.Position = UDim2.new(0, 36, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = tabName
	label.TextColor3 = Color3.fromRGB(210, 210, 210)
	label.Font = CLASSY_FONT
	label.TextSize = 16
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextTruncate = Enum.TextTruncate.None
	label.TextWrapped = true

	sidebarBtn.MouseButton1Click:Connect(function()
		local prevBtn = sidebarButtons[selectedTabIdx]
		TweenService:Create(prevBtn, TweenInfo.new(0.23, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = SIDEBAR_BG}):Play()
		TweenService:Create(sidebarBtn, TweenInfo.new(0.23, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = SIDEBAR_SELECTED_BG}):Play()
		local prevPanel = tabPanels[selectedTabIdx]
		local newPanel = tabPanels[i]
		if prevPanel ~= newPanel then
			if prevPanel then
				TweenService:Create(prevPanel, TweenInfo.new(0.19, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency = 1}):Play()
				task.delay(0.19, function()
					prevPanel.Visible = false
					prevPanel.BackgroundTransparency = 0
				end)
			end
			newPanel.Visible = true
			newPanel.BackgroundTransparency = 1
			TweenService:Create(newPanel, TweenInfo.new(0.23, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0}):Play()
		end
		selectedTabIdx = i
	end)
	sidebarButtons[i] = sidebarBtn
end

tabPanels[1].Visible = true

-- Minimize logic
local floatingLogo = nil
local function minimizeUI()
	local fade = TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Position = UDim2.new(0.5, -200, 0.5, -120), BackgroundTransparency = 1})
	fade:Play()
	fade.Completed:Wait()
	mainFrame.Visible = false
	if floatingLogo then floatingLogo.Visible = true end
end
local function restoreUI()
	mainFrame.Visible = true
	TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Position = UDim2.new(0.5, -200, 0.5, -150), BackgroundTransparency = 0}):Play()
	if floatingLogo then floatingLogo.Visible = false end
end
minimizeBtn.MouseButton1Click:Connect(minimizeUI)

-- Improved Dragging Logic

local dragging = false
local dragStart, startPos
local dragInput

local function onInputBegan(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = mainFrame.Position

		if input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end

		local connection
		connection = input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
				connection:Disconnect()
			end
		end)

		return true
	end
end

local function onInputChanged(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end

local function onMovement(input)
	if dragging and (input == dragInput or input.UserInputType == Enum.UserInputType.MouseMovement) then
		local delta = input.Position - dragStart
		mainFrame.Position = UDim2.new(
			startPos.X.Scale, 
			startPos.X.Offset + delta.X, 
			startPos.Y.Scale, 
			startPos.Y.Offset + delta.Y
		)
	end
end

mainFrame.InputBegan:Connect(onInputBegan)
mainFrame.InputChanged:Connect(onInputChanged)
UserInputService.InputChanged:Connect(onMovement)

mainFrame.Active = true
mainFrame.Selectable = true

-- Floating logo (for restoration/minimized state)
local logoFrame = Instance.new("Frame")
logoFrame.Name = "FloatingLogoUI"
logoFrame.Size = UDim2.new(0, 120, 0, 50)
logoFrame.Position = UDim2.new(1, -220, 1, -100)
logoFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
logoFrame.BackgroundTransparency = 0.2
logoFrame.Parent = screenGui
logoFrame.ZIndex = 10
logoFrame.Visible = false
floatingLogo = logoFrame

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = logoFrame

local border = Instance.new("UIStroke")
border.Color = Color3.fromRGB(100, 100, 120)
border.Thickness = 2
border.Transparency = 0.7
border.Parent = logoFrame

local logoImage = Instance.new("ImageLabel")
logoImage.Size = UDim2.new(0, 32, 0, 32)
logoImage.Position = UDim2.new(0, 8, 0.5, -16)
logoImage.BackgroundTransparency = 1
logoImage.Image = "rbxassetid://YOUR_IMAGE_ID_HERE"  -- Replace with your logo
logoImage.Parent = logoFrame
logoImage.ZIndex = 11

local logoText = Instance.new("TextLabel")
logoText.Size = UDim2.new(0, 80, 0, 30)
logoText.Position = UDim2.new(0, 20, 0.5, -15)
logoText.BackgroundTransparency = 1
logoText.Text = "BLOXIFIED"
logoText.TextColor3 = Color3.fromRGB(255,255,255)
logoText.Font = Enum.Font.GothamBold
logoText.TextSize = 14
logoText.TextXAlignment = Enum.TextXAlignment.Left
logoText.Parent = logoFrame
logoText.ZIndex = 11

local expandButton = Instance.new("TextButton")
expandButton.Size = UDim2.new(0, 24, 0, 24)
expandButton.Position = UDim2.new(1, -28, 0.5, -12)
expandButton.BackgroundTransparency = 1
expandButton.Text = "[  ]"
expandButton.TextColor3 = Color3.fromRGB(180, 180, 180)
expandButton.Font = Enum.Font.GothamBold
expandButton.TextSize = 16
expandButton.ZIndex = 12
expandButton.Parent = logoFrame

expandButton.MouseEnter:Connect(function()
	TweenService:Create(expandButton, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
end)
expandButton.MouseLeave:Connect(function()
	TweenService:Create(expandButton, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(180, 180, 180)}):Play()
end)
expandButton.MouseButton1Down:Connect(function()
	expandButton.Text = "[•]"
end)
expandButton.MouseButton1Up:Connect(function()
	expandButton.Text = "[  ]"
end)
expandButton.MouseButton1Click:Connect(function()
	restoreUI()
end)

local glow = Instance.new("ImageLabel")
glow.Size = UDim2.new(1, 20, 1, 20)
glow.Position = UDim2.new(0, -10, 0, -10)
glow.BackgroundTransparency = 1
glow.Image = "rbxassetid://4996891970"
glow.ImageColor3 = Color3.fromRGB(50, 100, 200)
glow.ScaleType = Enum.ScaleType.Slice
glow.SliceCenter = Rect.new(49, 49, 51, 51)
glow.ImageTransparency = 0.8
glow.Parent = logoFrame
glow.ZIndex = 9

local draggingLogo, dragInputLogo, dragStartLogo, startPosLogo
local function updateLogoInput(input)
	local delta = input.Position - dragStartLogo
	logoFrame.Position = UDim2.new(
		startPosLogo.X.Scale, 
		startPosLogo.X.Offset + delta.X,
		startPosLogo.Y.Scale, 
		startPosLogo.Y.Offset + delta.Y
	)
end
local function isOverExpandButton(input)
	local mousePos = input.Position
	local buttonPos = expandButton.AbsolutePosition
	local buttonSize = expandButton.AbsoluteSize
	return mousePos.X >= buttonPos.X and mousePos.X <= buttonPos.X + buttonSize.X and
		mousePos.Y >= buttonPos.Y and mousePos.Y <= buttonPos.Y + buttonSize.Y
end
logoFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 and not isOverExpandButton(input) then
		draggingLogo = true
		dragStartLogo = input.Position
		startPosLogo = logoFrame.Position
		TweenService:Create(logoFrame, TweenInfo.new(0.1), {BackgroundTransparency = 0.1}):Play()
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				draggingLogo = false
				TweenService:Create(logoFrame, TweenInfo.new(0.2), {BackgroundTransparency = 0.2}):Play()
			end
		end)
	end
end)
logoFrame.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		dragInputLogo = input
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if input == dragInputLogo and draggingLogo then
		updateLogoInput(input)
	end
end)

logoFrame.BackgroundTransparency = 1
logoText.TextTransparency = 1
logoImage.ImageTransparency = 1
glow.ImageTransparency = 1
expandButton.TextTransparency = 1
local fadeInLogo = TweenService:Create(logoFrame, TweenInfo.new(0.5), {BackgroundTransparency = 0.2})
local fadeInText = TweenService:Create(logoText, TweenInfo.new(0.5), {TextTransparency = 0})
local fadeInImage = TweenService:Create(logoImage, TweenInfo.new(0.5), {ImageTransparency = 0})
local fadeInGlow = TweenService:Create(glow, TweenInfo.new(0.5), {ImageTransparency = 0.8})
local fadeInButton = TweenService:Create(expandButton, TweenInfo.new(0.5), {TextTransparency = 0})
fadeInLogo:Play()
fadeInText:Play()
fadeInImage:Play()
fadeInGlow:Play()
fadeInButton:Play()