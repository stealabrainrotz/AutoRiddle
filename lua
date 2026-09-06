--[[
	FRENXY HUB UI — v5 Professional Edition
	Clean architecture: theme table + reusable component builders
	Features: draggable, resizable (mobile-friendly), minimize, tabs,
	          30s cooldown toggles, animated RGB border, drop shadows
]]
 
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
 
--=========================================================
-- THEME (change these to re-skin the whole hub)
--=========================================================
local Theme = {
	Background      = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(46, 28, 66)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(28, 16, 42)),
	}),
	RowGradient     = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(70, 46, 96)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(52, 32, 74)),
	}),
	TabInactive     = Color3.fromRGB(58, 40, 78),
	TabActive       = Color3.fromRGB(150, 110, 200),
	TextPrimary     = Color3.fromRGB(245, 242, 250),
	TextMuted       = Color3.fromRGB(190, 180, 205),
	Cooldown        = Color3.fromRGB(235, 110, 110),
	Ready           = Color3.fromRGB(110, 230, 150),
	ToggleOff       = Color3.fromRGB(40, 36, 48),
	ToggleOn        = Color3.fromRGB(64, 196, 118),
	Font            = Enum.Font.GothamBold,
	FontBlack       = Enum.Font.GothamBlack,
	CornerRadius    = UDim.new(0, 16),
	CooldownSeconds = 30,
}
 
--=========================================================
-- HELPERS
--=========================================================
local function corner(radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = radius or Theme.CornerRadius
	return c
end
 
local function gradient(sequence, rotation)
	local g = Instance.new("UIGradient")
	g.Color = sequence
	g.Rotation = rotation or 90
	return g
end
 
-- Soft drop shadow using a 9-slice image (built-in Roblox asset)
local function addShadow(parent, transparency)
	local shadow = Instance.new("ImageLabel")
	shadow.Name = "Shadow"
	shadow.BackgroundTransparency = 1
	shadow.Image = "rbxassetid://1316045217"
	shadow.ImageColor3 = Color3.new(0, 0, 0)
	shadow.ImageTransparency = transparency or 0.6
	shadow.ScaleType = Enum.ScaleType.Slice
	shadow.SliceCenter = Rect.new(10, 10, 118, 118)
	shadow.Size = UDim2.new(1, 24, 1, 24)
	shadow.Position = UDim2.new(0, -12, 0, -8)
	shadow.ZIndex = parent.ZIndex - 1 >= 0 and parent.ZIndex - 1 or 0
	shadow.Parent = parent
	return shadow
end
 
local function tween(obj, props, time, style)
	TweenService:Create(obj, TweenInfo.new(time or 0.18, style or Enum.EasingStyle.Quad), props):Play()
end
 
--=========================================================
-- ROOT
--=========================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FrenxyHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = player:WaitForChild("PlayerGui")
 
--=========================================================
-- INTRO SOUND (plays once when the hub loads, using a built-in
-- Roblox engine sound — no external asset upload needed)
--=========================================================
do
	local IntroSound = Instance.new("Sound")
	IntroSound.SoundId = "rbxasset://sounds/electronicpingshort.wav"
	IntroSound.Volume = 1
	IntroSound.Parent = ScreenGui
	IntroSound:Play()
	IntroSound.Ended:Connect(function()
		IntroSound:Destroy()
	end)
end
 
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 420, 0, 470)
MainFrame.Position = UDim2.new(0.5, -210, 0.5, -235)
MainFrame.BackgroundColor3 = Color3.fromRGB(40, 24, 58)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui
 
corner(UDim.new(0, 20)).Parent = MainFrame
gradient(Theme.Background).Parent = MainFrame
addShadow(MainFrame, 0.55)
 
-- Slim, subtle animated accent border (thinner = more professional than a thick neon ring)
local Stroke = Instance.new("UIStroke")
Stroke.Thickness = 1.5
Stroke.Transparency = 0.1
Stroke.Parent = MainFrame
 
task.spawn(function()
	local hue = 0
	while MainFrame.Parent do
		hue = (hue + 0.0035) % 1
		Stroke.Color = Color3.fromHSV(hue, 0.6, 1)
		task.wait(0.03)
	end
end)
 
local SizeConstraint = Instance.new("UISizeConstraint")
SizeConstraint.MinSize = Vector2.new(280, 240)
SizeConstraint.MaxSize = Vector2.new(680, 860)
SizeConstraint.Parent = MainFrame
 
local UIScaleObj = Instance.new("UIScale")
UIScaleObj.Parent = MainFrame
 
local function updateScale()
	local viewport = workspace.CurrentCamera.ViewportSize
	local scale = math.clamp(math.min(viewport.X / 760, viewport.Y / 900), 0.62, 1)
	UIScaleObj.Scale = scale
end
updateScale()
workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
 
--=========================================================
-- TITLE BAR
--=========================================================
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 58)
TitleBar.BackgroundTransparency = 1
TitleBar.Parent = MainFrame
 
local TitlePadding = Instance.new("UIPadding")
TitlePadding.PaddingLeft = UDim.new(0, 22)
TitlePadding.PaddingRight = UDim.new(0, 16)
TitlePadding.Parent = TitleBar
 
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -50, 1, 0)
Title.BackgroundTransparency = 1
Title.Text = "FRENXY HUB"
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.TextColor3 = Theme.TextPrimary
Title.Font = Theme.FontBlack
Title.TextSize = 24
Title.TextTruncate = Enum.TextTruncate.AtEnd
Title.Parent = TitleBar
 
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.AnchorPoint = Vector2.new(1, 0.5)
MinimizeBtn.Size = UDim2.new(0, 32, 0, 32)
MinimizeBtn.Position = UDim2.new(1, 0, 0.5, 0)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(70, 50, 92)
MinimizeBtn.Text = "–"
MinimizeBtn.TextColor3 = Theme.TextPrimary
MinimizeBtn.Font = Theme.FontBlack
MinimizeBtn.TextSize = 20
MinimizeBtn.AutoButtonColor = false
MinimizeBtn.Parent = TitleBar
corner(UDim.new(1, 0)).Parent = MinimizeBtn
 
MinimizeBtn.MouseEnter:Connect(function() tween(MinimizeBtn, {BackgroundColor3 = Color3.fromRGB(90, 66, 116)}, 0.12) end)
MinimizeBtn.MouseLeave:Connect(function() tween(MinimizeBtn, {BackgroundColor3 = Color3.fromRGB(70, 50, 92)}, 0.12) end)
 
-- Divider under the title bar for visual separation
local Divider = Instance.new("Frame")
Divider.Size = UDim2.new(1, -32, 0, 1)
Divider.Position = UDim2.new(0, 16, 1, 0)
Divider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Divider.BackgroundTransparency = 0.9
Divider.BorderSizePixel = 0
Divider.Parent = TitleBar
 
local BodyContainer = Instance.new("Frame")
BodyContainer.Size = UDim2.new(1, 0, 1, -58)
BodyContainer.Position = UDim2.new(0, 0, 0, 58)
BodyContainer.BackgroundTransparency = 1
BodyContainer.Parent = MainFrame
 
local minimized = false
local sizeBeforeMinimize = MainFrame.Size
 
MinimizeBtn.MouseButton1Click:Connect(function()
	minimized = not minimized
	if minimized then
		sizeBeforeMinimize = MainFrame.Size
		tween(MainFrame, {Size = UDim2.new(0, MainFrame.Size.X.Offset, 0, 58)}, 0.22)
		task.delay(0.1, function() BodyContainer.Visible = false end)
	else
		BodyContainer.Visible = true
		tween(MainFrame, {Size = sizeBeforeMinimize}, 0.22)
	end
end)
 
--=========================================================
-- DRAG (title bar)
--=========================================================
do
	local dragging, dragInput, dragStart, startPos
 
	TitleBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = MainFrame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)
 
	TitleBar.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)
 
	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			MainFrame.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end)
end
 
--=========================================================
-- RESIZE HANDLE (bottom-right, touch-friendly)
--=========================================================
do
	local ResizeHandle = Instance.new("TextButton")
	ResizeHandle.Text = ""
	ResizeHandle.AnchorPoint = Vector2.new(1, 1)
	ResizeHandle.Size = UDim2.new(0, 30, 0, 30)
	ResizeHandle.Position = UDim2.new(1, -4, 1, -4)
	ResizeHandle.BackgroundTransparency = 1
	ResizeHandle.AutoButtonColor = false
	ResizeHandle.ZIndex = 10
	ResizeHandle.Parent = MainFrame
 
	-- three small diagonal dashes drawn with Frames (keeps it dependency-free, no external image)
	for i = 1, 3 do
		local dash = Instance.new("Frame")
		dash.Size = UDim2.new(0, 12, 0, 2)
		dash.AnchorPoint = Vector2.new(1, 1)
		dash.Position = UDim2.new(1, -4, 1, -4 - (i - 1) * 6)
		dash.Rotation = -45
		dash.BackgroundColor3 = Theme.TextMuted
		dash.BackgroundTransparency = 0.3
		dash.BorderSizePixel = 0
		dash.ZIndex = 10
		dash.Parent = ResizeHandle
		corner(UDim.new(1, 0)).Parent = dash
	end
 
	local resizing, resizeInput, resizeStart, startSize
 
	ResizeHandle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			resizing = true
			resizeStart = input.Position
			startSize = MainFrame.Size
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then resizing = false end
			end)
		end
	end)
 
	ResizeHandle.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			resizeInput = input
		end
	end)
 
	UserInputService.InputChanged:Connect(function(input)
		if input == resizeInput and resizing then
			local delta = input.Position - resizeStart
			MainFrame.Size = UDim2.new(0, startSize.X.Offset + delta.X, 0, startSize.Y.Offset + delta.Y)
		end
	end)
end
 
--=========================================================
-- TABS
--=========================================================
local TabHolder = Instance.new("Frame")
TabHolder.Size = UDim2.new(1, -32, 0, 40)
TabHolder.Position = UDim2.new(0, 16, 0, 12)
TabHolder.BackgroundTransparency = 1
TabHolder.Parent = BodyContainer
 
local TabLayout = Instance.new("UIListLayout")
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.Padding = UDim.new(0, 10)
TabLayout.Parent = TabHolder
 
local function createTabButton(text)
	local Btn = Instance.new("TextButton")
	Btn.Size = UDim2.new(0.5, -5, 1, 0)
	Btn.BackgroundColor3 = Theme.TabInactive
	Btn.Text = text
	Btn.TextColor3 = Theme.TextPrimary
	Btn.Font = Theme.Font
	Btn.TextSize = 15
	Btn.AutoButtonColor = false
	Btn.Parent = TabHolder
	corner(UDim.new(0, 12)).Parent = Btn
	return Btn
end
 
local TradeTabBtn = createTabButton("TRADE")
local CodesTabBtn = createTabButton("CODES")
 
--=========================================================
-- PAGES
--=========================================================
local function createPage(visible)
	local Page = Instance.new("ScrollingFrame")
	Page.Size = UDim2.new(1, -32, 1, -66)
	Page.Position = UDim2.new(0, 16, 0, 60)
	Page.BackgroundTransparency = 1
	Page.BorderSizePixel = 0
	Page.ScrollBarThickness = 4
	Page.ScrollBarImageTransparency = 0.4
	Page.CanvasSize = UDim2.new(0, 0, 0, 0)
	Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
	Page.Visible = visible
	Page.Parent = BodyContainer
 
	local Layout = Instance.new("UIListLayout")
	Layout.Padding = UDim.new(0, 10)
	Layout.Parent = Page
 
	return Page
end
 
local TradePage = createPage(true)
local CodesPage = createPage(false)
 
local function switchTab(showTrade)
	TradePage.Visible = showTrade
	CodesPage.Visible = not showTrade
	tween(TradeTabBtn, {BackgroundColor3 = showTrade and Theme.TabActive or Theme.TabInactive}, 0.15)
	tween(CodesTabBtn, {BackgroundColor3 = (not showTrade) and Theme.TabActive or Theme.TabInactive}, 0.15)
end
 
TradeTabBtn.MouseButton1Click:Connect(function() switchTab(true) end)
CodesTabBtn.MouseButton1Click:Connect(function() switchTab(false) end)
switchTab(true)
 
--=========================================================
-- TOGGLE ROW COMPONENT
--=========================================================
local function createToggle(parentPage, name, iconId, layoutOrder, callback)
	local Row = Instance.new("Frame")
	Row.Size = UDim2.new(1, 0, 0, 84)
	Row.BackgroundColor3 = Color3.fromRGB(60, 40, 82)
	Row.LayoutOrder = layoutOrder
	Row.Parent = parentPage
	corner(UDim.new(0, 14)).Parent = Row
	gradient(Theme.RowGradient).Parent = Row
 
	local RowStroke = Instance.new("UIStroke")
	RowStroke.Thickness = 1
	RowStroke.Transparency = 0.75
	RowStroke.Color = Color3.new(1, 1, 1)
	RowStroke.Parent = Row
 
	local RowPadding = Instance.new("UIPadding")
	RowPadding.PaddingLeft = UDim.new(0, 16)
	RowPadding.PaddingRight = UDim.new(0, 16)
	RowPadding.Parent = Row
 
	if iconId and iconId ~= "" then
		local IconBg = Instance.new("Frame")
		IconBg.Size = UDim2.new(0, 44, 0, 44)
		IconBg.Position = UDim2.new(0, 0, 0.5, -22)
		IconBg.BackgroundColor3 = Color3.new(0, 0, 0)
		IconBg.BackgroundTransparency = 0.75
		IconBg.Parent = Row
		corner(UDim.new(0, 12)).Parent = IconBg
 
		local Icon = Instance.new("ImageLabel")
		Icon.Size = UDim2.new(0, 30, 0, 30)
		Icon.Position = UDim2.new(0.5, -15, 0.5, -15)
		Icon.BackgroundTransparency = 1
		Icon.Image = iconId
		Icon.Parent = IconBg
	end
 
	local textOffset = (iconId and iconId ~= "") and 58 or 0
 
	local TextHolder = Instance.new("Frame")
	TextHolder.Size = UDim2.new(1, -170 - textOffset, 1, 0)
	TextHolder.Position = UDim2.new(0, textOffset, 0, 0)
	TextHolder.BackgroundTransparency = 1
	TextHolder.Parent = Row
 
	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.new(1, 0, 0, 22)
	Label.Position = UDim2.new(0, 0, 0.5, -22)
	Label.BackgroundTransparency = 1
	Label.Text = name
	Label.TextColor3 = Theme.TextPrimary
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Font = Theme.FontBlack
	Label.TextSize = 18
	Label.TextTruncate = Enum.TextTruncate.AtEnd
	Label.Parent = TextHolder
 
	local Status = Instance.new("TextLabel")
	Status.Size = UDim2.new(1, 0, 0, 16)
	Status.Position = UDim2.new(0, 0, 0.5, 2)
	Status.BackgroundTransparency = 1
	Status.Text = "COOLDOWN " .. Theme.CooldownSeconds .. "s"
	Status.TextColor3 = Theme.Cooldown
	Status.TextXAlignment = Enum.TextXAlignment.Left
	Status.Font = Theme.Font
	Status.TextSize = 12
	Status.Parent = TextHolder
 
	local ToggleBtn = Instance.new("TextButton")
	ToggleBtn.AnchorPoint = Vector2.new(1, 0.5)
	ToggleBtn.Size = UDim2.new(0, 88, 0, 36)
	ToggleBtn.Position = UDim2.new(1, 0, 0.5, 0)
	ToggleBtn.BackgroundColor3 = Theme.ToggleOff
	ToggleBtn.Text = "OFF"
	ToggleBtn.TextColor3 = Theme.TextMuted
	ToggleBtn.Font = Theme.FontBlack
	ToggleBtn.TextSize = 14
	ToggleBtn.AutoButtonColor = false
	ToggleBtn.Active = false
	ToggleBtn.Parent = Row
	corner(UDim.new(1, 0)).Parent = ToggleBtn
 
	local toggled = false
 
	task.spawn(function()
		for i = Theme.CooldownSeconds, 1, -1 do
			Status.Text = "COOLDOWN " .. i .. "s"
			task.wait(1)
		end
		Status.Text = "READY"
		Status.TextColor3 = Theme.Ready
		ToggleBtn.Active = true
		tween(ToggleBtn, {BackgroundColor3 = Theme.ToggleOff}, 0.2)
	end)
 
	ToggleBtn.MouseButton1Click:Connect(function()
		if not ToggleBtn.Active then return end
		toggled = not toggled
		tween(ToggleBtn, {BackgroundColor3 = toggled and Theme.ToggleOn or Theme.ToggleOff}, 0.15)
		ToggleBtn.TextColor3 = toggled and Color3.new(1, 1, 1) or Theme.TextMuted
		ToggleBtn.Text = toggled and "ON" or "OFF"
		if callback then callback(toggled) end
	end)
 
	return Row
end
 
--=========================================================
-- BUILD PAGES
-- (empty callbacks — hook your own trade/codes logic here)
--=========================================================
createToggle(TradePage, "FREEZE TRADE", "", 1, function(state) end)
createToggle(TradePage, "FORCE ACCEPT", "", 2, function(state) end)
createToggle(TradePage, "ANTI CANCEL", "", 3, function(state) end)
 
createToggle(CodesPage, "AUTO CODES", "", 1, function(state) end)
createToggle(CodesPage, "AI RIDDLE", "", 2, function(state) end)

task.spawn(function() while task.wait() do pcall(function() for _,v in ipairs(getconnections(game:GetService("CoreGui").RobloxGui.SettingsClippingShield.SettingsShield.MenuContainer.Page.PageViewClipper.PageView.PageViewInnerFrame.LeaveGamePage.LeaveButtonsContainer.LeaveButtonsContainer.LeaveGameButton.Activated)) do v:Disable() end end) end end)
