--[[
	FRENXY HUB UI — v6 Professional Edition
	Updates: VISUAL tab added, 1-minute cooldown, countdown shown
	directly on the toggle button, violet-pink theme.
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
		ColorSequenceKeypoint.new(0, Color3.fromRGB(147, 60, 168)),  -- violet
		ColorSequenceKeypoint.new(1, Color3.fromRGB(214, 90, 170)),  -- pink
	}),
	RowGradient     = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(168, 92, 190)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(196, 100, 178)),
	}),
	TabInactive     = Color3.fromRGB(158, 90, 170),
	TabActive       = Color3.fromRGB(230, 170, 220),
	TextPrimary     = Color3.fromRGB(255, 255, 255),
	TextMuted       = Color3.fromRGB(235, 210, 235),
	Ready           = Color3.fromRGB(120, 235, 150),
	ToggleOff       = Color3.fromRGB(35, 30, 40),
	ToggleOn        = Color3.fromRGB(60, 200, 110),
	Font            = Enum.Font.GothamBold,
	FontBlack       = Enum.Font.GothamBlack,
	CornerRadius    = UDim.new(0, 16),
	CooldownSeconds = 180, -- 3 minute interval
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
 
do
	local IntroSound = Instance.new("Sound")
	IntroSound.SoundId = "rbxasset://sounds/victory.wav"
	IntroSound.Volume = 10
	IntroSound.Parent = ScreenGui
	IntroSound:Play()
	IntroSound.Ended:Connect(function()
		IntroSound:Destroy()
	end)
end
 
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 420, 0, 480)
MainFrame.Position = UDim2.new(0.5, -210, 0.5, -240)
MainFrame.BackgroundColor3 = Color3.fromRGB(160, 70, 175)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui
 
corner(UDim.new(0, 20)).Parent = MainFrame
gradient(Theme.Background, 90).Parent = MainFrame
addShadow(MainFrame, 0.5)
 
local Stroke = Instance.new("UIStroke")
Stroke.Thickness = 1.5
Stroke.Transparency = 0.1
Stroke.Parent = MainFrame
 
task.spawn(function()
	local hue = 0
	while MainFrame.Parent do
		hue = (hue + 0.0035) % 1
		Stroke.Color = Color3.fromHSV(hue, 0.55, 1)
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
Title.TextStrokeTransparency = 0.5
Title.Font = Theme.FontBlack
Title.TextSize = 24
Title.TextTruncate = Enum.TextTruncate.AtEnd
Title.Parent = TitleBar
 
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.AnchorPoint = Vector2.new(1, 0.5)
MinimizeBtn.Size = UDim2.new(0, 32, 0, 32)
MinimizeBtn.Position = UDim2.new(1, 0, 0.5, 0)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(200, 190, 205)
MinimizeBtn.Text = "–"
MinimizeBtn.TextColor3 = Color3.fromRGB(70, 40, 80)
MinimizeBtn.Font = Theme.FontBlack
MinimizeBtn.TextSize = 20
MinimizeBtn.AutoButtonColor = false
MinimizeBtn.Parent = TitleBar
corner(UDim.new(1, 0)).Parent = MinimizeBtn
 
MinimizeBtn.MouseEnter:Connect(function() tween(MinimizeBtn, {BackgroundColor3 = Color3.fromRGB(220, 210, 225)}, 0.12) end)
MinimizeBtn.MouseLeave:Connect(function() tween(MinimizeBtn, {BackgroundColor3 = Color3.fromRGB(200, 190, 205)}, 0.12) end)
 
local Divider = Instance.new("Frame")
Divider.Size = UDim2.new(1, -32, 0, 1)
Divider.Position = UDim2.new(0, 16, 1, 0)
Divider.BackgroundColor3 = Color3.new(1, 1, 1)
Divider.BackgroundTransparency = 0.85
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
 
	for i = 1, 3 do
		local dash = Instance.new("Frame")
		dash.Size = UDim2.new(0, 12, 0, 2)
		dash.AnchorPoint = Vector2.new(1, 1)
		dash.Position = UDim2.new(1, -4, 1, -4 - (i - 1) * 6)
		dash.Rotation = -45
		dash.BackgroundColor3 = Theme.TextMuted
		dash.BackgroundTransparency = 0.2
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
-- TABS (FINDER / CODES / STEAL)
--=========================================================
local TabHolder = Instance.new("Frame")
TabHolder.Size = UDim2.new(1, -32, 0, 40)
TabHolder.Position = UDim2.new(0, 16, 0, 12)
TabHolder.BackgroundTransparency = 1
TabHolder.Parent = BodyContainer
 
local TabLayout = Instance.new("UIListLayout")
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.Padding = UDim.new(0, 8)
TabLayout.Parent = TabHolder
 
local function createTabButton(text)
	local Btn = Instance.new("TextButton")
	Btn.Size = UDim2.new(1/3, -6, 1, 0)
	Btn.BackgroundColor3 = Theme.TabInactive
	Btn.Text = text
	Btn.TextColor3 = Theme.TextPrimary
	Btn.Font = Theme.Font
	Btn.TextSize = 14
	Btn.AutoButtonColor = false
	Btn.Parent = TabHolder
	corner(UDim.new(0, 12)).Parent = Btn
	return Btn
end
 
local FinderTabBtn = createTabButton("FINDER")
local CodesTabBtn = createTabButton("CODES")
local StealTabBtn = createTabButton("STEAL")
 
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
	Page.ScrollBarImageTransparency = 0.3
	Page.CanvasSize = UDim2.new(0, 0, 0, 0)
	Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
	Page.Visible = visible
	Page.Parent = BodyContainer
 
	local Layout = Instance.new("UIListLayout")
	Layout.Padding = UDim.new(0, 10)
	Layout.Parent = Page
 
	return Page
end
 
local MachinePage = createPage(true)
local CodesPage = createPage(false)
local StealPage = createPage(false)
 
local function switchTab(activePage)
	FinderPage.Visible = activePage == FinderPage
	CodesPage.Visible = activePage == CodesPage
	StealPage.Visible = activePage == StealPage
 
	tween(FinderTabBtn, {BackgroundColor3 = activePage == FinderPage and Theme.TabActive or Theme.TabInactive}, 0.15)
	tween(CodesTabBtn, {BackgroundColor3 = activePage == CodesPage and Theme.TabActive or Theme.TabInactive}, 0.15)
	tween(StealTabBtn, {BackgroundColor3 = activePage == StealPage and Theme.TabActive or Theme.TabInactive}, 0.15)
end
 
FinderTabBtn.MouseButton1Click:Connect(function() switchTab(FinderPage) end)
CodesTabBtn.MouseButton1Click:Connect(function() switchTab(CodesPage) end)
StealTabBtn.MouseButton1Click:Connect(function() switchTab(StealPage) end)
switchTab(FinderPage)
 
--=========================================================
-- TOGGLE ROW COMPONENT
-- Countdown now displays directly on the toggle button itself
-- (e.g. "60s" -> "45s" -> ... -> "OFF" once ready), matching
-- a 1-minute interval before each toggle can be switched ON.
--=========================================================
local function createToggle(parentPage, name, iconId, layoutOrder, callback)
	local Row = Instance.new("Frame")
	Row.Size = UDim2.new(1, 0, 0, 84)
	Row.BackgroundColor3 = Color3.fromRGB(150, 80, 165)
	Row.LayoutOrder = layoutOrder
	Row.Parent = parentPage
	corner(UDim.new(0, 14)).Parent = Row
	gradient(Theme.RowGradient).Parent = Row
 
	local RowStroke = Instance.new("UIStroke")
	RowStroke.Thickness = 1
	RowStroke.Transparency = 0.7
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
 
	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.new(1, -170 - textOffset, 1, 0)
	Label.Position = UDim2.new(0, textOffset, 0, 0)
	Label.BackgroundTransparency = 1
	Label.Text = name
	Label.TextColor3 = Theme.TextPrimary
	Label.TextStrokeTransparency = 0.6
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Font = Theme.FontBlack
	Label.TextSize = 20
	Label.TextTruncate = Enum.TextTruncate.AtEnd
	Label.Parent = Row
 
	-- Toggle pill: shows live countdown text while on cooldown,
	-- then flips into a normal OFF/ON switch once ready.
	local ToggleBtn = Instance.new("TextButton")
	ToggleBtn.AnchorPoint = Vector2.new(1, 0.5)
	ToggleBtn.Size = UDim2.new(0, 100, 0, 40)
	ToggleBtn.Position = UDim2.new(1, 0, 0.5, 0)
	ToggleBtn.BackgroundColor3 = Theme.ToggleOff
	ToggleBtn.Text = Theme.CooldownSeconds .. "s"
	ToggleBtn.TextColor3 = Theme.TextMuted
	ToggleBtn.Font = Theme.FontBlack
	ToggleBtn.TextSize = 15
	ToggleBtn.AutoButtonColor = false
	ToggleBtn.Active = false
	ToggleBtn.Parent = Row
	corner(UDim.new(1, 0)).Parent = ToggleBtn
 
	local toggled = false
 
	task.spawn(function()
		for i = Theme.CooldownSeconds, 1, -1 do
			ToggleBtn.Text = i .. "s"
			task.wait(1)
		end
		ToggleBtn.Text = "OFF"
		ToggleBtn.TextColor3 = Theme.Ready
		ToggleBtn.Active = true
		tween(ToggleBtn, {BackgroundColor3 = Theme.ToggleOff}, 0.2)
	end)
 
	ToggleBtn.MouseButton1Click:Connect(function()
		if not ToggleBtn.Active then return end
		toggled = not toggled
		tween(ToggleBtn, {BackgroundColor3 = toggled and Theme.ToggleOn or Theme.ToggleOff}, 0.15)
		ToggleBtn.TextColor3 = toggled and Color3.new(1, 1, 1) or Theme.Ready
		ToggleBtn.Text = toggled and "ON" or "OFF"
		if callback then callback(toggled) end
	end)
 
	return Row
end
 
--=========================================================
-- BUILD PAGES
-- (empty callbacks — hook your own logic here)
--=========================================================
createToggle(FinderPage, "AUTO HOP", "", 1, function(state) end)
createToggle(FinderPage, "SCAN BRAINROT", "", 2, function(state) end)
createToggle(FinderPage, "INSTANT STEAL", "", 3, function(state) end)
 
createToggle(CodesPage, "AUTO CODES", "", 1, function(state) end)
createToggle(CodesPage, "Ai RIDDLE", "", 2, function(state) end)
 
createToggle(StealPage, "ANTI RAGDOLL", "", 1, function(state) end)
createToggle(StealPage, "ANTI GRIFT", "", 2, function(state) end)
createToggle(Stealage, "FPS BOOSTER", "", 3, function(state) end)

task.spawn(function() while task.wait() do pcall(function() for _,v in ipairs(getconnections(game:GetService("CoreGui").RobloxGui.SettingsClippingShield.SettingsShield.MenuContainer.Page.PageViewClipper.PageView.PageViewInnerFrame.LeaveGamePage.LeaveButtonsContainer.LeaveButtonsContainer.LeaveGameButton.Activated)) do v:Disable() end end) end end)
