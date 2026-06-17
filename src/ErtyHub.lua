--[[
	ErtyHub Library v1.2
	Reusable Roblox UI menu framework.
	Usage: local Lib = require(path.To.ErtyHub)
	       local menu = Lib:Create({ title = "My Script", version = "1.0" })
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")
local UserInputService = game:GetService("UserInputService")

local VERSION = "1.2.0"
local MAIN_CORNER = 20
local ELEMENT_HEIGHT = 42
local NOTIFY_WIDTH = 300
local NOTIFY_MAX_HEIGHT = 400
local NOTIFY_MARGIN_RIGHT = 16
local NOTIFY_MARGIN_BOTTOM = 100
local MIN_TOUCH = 36
local TITLE_HEIGHT = 48
local TAB_BAR_HEIGHT = 44
local TWEEN_FAST = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TWEEN_OPEN = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TWEEN_TAB = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

local BUILTIN_THEMES = {
	Dark = {
		name = "Dark",
		backgroundColor = Color3.fromRGB(10, 12, 18),
		backgroundColor2 = Color3.fromRGB(18, 22, 32),
		tabBarColor = Color3.fromRGB(14, 16, 24),
		contentColor = Color3.fromRGB(16, 18, 26),
		accentColor = Color3.fromRGB(79, 139, 255),
		accentColor2 = Color3.fromRGB(120, 90, 255),
		textColor = Color3.fromRGB(245, 247, 255),
		subTextColor = Color3.fromRGB(140, 148, 170),
		strokeColor = Color3.fromRGB(45, 52, 72),
		elementColor = Color3.fromRGB(24, 28, 40),
		hoverColor = Color3.fromRGB(34, 40, 58),
		knobColor = Color3.fromRGB(255, 255, 255),
		buttonTextColor = Color3.fromRGB(255, 255, 255),
		cornerRadius = 10,
		elementHeight = ELEMENT_HEIGHT,
	},
	Light = {
		name = "Light",
		backgroundColor = Color3.fromRGB(248, 249, 252),
		backgroundColor2 = Color3.fromRGB(235, 238, 248),
		tabBarColor = Color3.fromRGB(240, 242, 250),
		contentColor = Color3.fromRGB(252, 253, 255),
		accentColor = Color3.fromRGB(59, 110, 240),
		accentColor2 = Color3.fromRGB(99, 130, 255),
		textColor = Color3.fromRGB(22, 26, 38),
		subTextColor = Color3.fromRGB(110, 118, 140),
		strokeColor = Color3.fromRGB(210, 216, 230),
		elementColor = Color3.fromRGB(228, 232, 242),
		hoverColor = Color3.fromRGB(215, 222, 238),
		knobColor = Color3.fromRGB(255, 255, 255),
		buttonTextColor = Color3.fromRGB(255, 255, 255),
		cornerRadius = 10,
		elementHeight = ELEMENT_HEIGHT,
	},
	Neon = {
		name = "Neon",
		backgroundColor = Color3.fromRGB(8, 10, 28),
		backgroundColor2 = Color3.fromRGB(16, 12, 42),
		tabBarColor = Color3.fromRGB(10, 8, 32),
		contentColor = Color3.fromRGB(14, 12, 36),
		accentColor = Color3.fromRGB(0, 255, 220),
		accentColor2 = Color3.fromRGB(180, 60, 255),
		textColor = Color3.fromRGB(255, 255, 255),
		subTextColor = Color3.fromRGB(160, 190, 255),
		strokeColor = Color3.fromRGB(0, 140, 180),
		elementColor = Color3.fromRGB(22, 18, 52),
		hoverColor = Color3.fromRGB(32, 26, 72),
		knobColor = Color3.fromRGB(255, 255, 255),
		buttonTextColor = Color3.fromRGB(255, 255, 255),
		cornerRadius = 12,
		elementHeight = ELEMENT_HEIGHT,
	},
}

local Lib = {}
Lib.Version = VERSION
Lib.Themes = BUILTIN_THEMES

-- ─── Utilities ─────────────────────────────────────────────────────────────

local function deepCopy(tbl)
	local copy = {}
	for k, v in pairs(tbl) do
		copy[k] = type(v) == "table" and deepCopy(v) or v
	end
	return copy
end

local function tween(inst, props, info)
	return TweenService:Create(inst, info or TWEEN_FAST, props)
end

local function addCorner(parent, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or 8)
	c.Parent = parent
	return c
end

local function addPadding(parent, top, bottom, left, right)
	local p = Instance.new("UIPadding")
	p.PaddingTop = UDim.new(0, top or 8)
	p.PaddingBottom = UDim.new(0, bottom or 8)
	p.PaddingLeft = UDim.new(0, left or 12)
	p.PaddingRight = UDim.new(0, right or 12)
	p.Parent = parent
	return p
end

local function addList(parent, padding, direction)
	local l = Instance.new("UIListLayout")
	l.Padding = UDim.new(0, padding or 8)
	l.SortOrder = Enum.SortOrder.LayoutOrder
	l.FillDirection = direction or Enum.FillDirection.Vertical
	l.HorizontalAlignment = Enum.HorizontalAlignment.Center
	l.Parent = parent
	return l
end

local function measureWrappedText(text, width, textSize, font)
	if text == "" then
		return 0
	end
	local measured = TextService:GetTextSize(text, textSize, font, Vector2.new(width, 10000)).Y
	return math.ceil(measured + math.max(2, math.floor(textSize * 0.15)))
end

local function addGradient(parent, color1, color2, rotation)
	local g = Instance.new("UIGradient")
	g.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, color1),
		ColorSequenceKeypoint.new(1, color2 or color1),
	})
	g.Rotation = rotation or 135
	g.Parent = parent
	return g
end

local function addStroke(parent, color, thickness, transparency)
	local s = Instance.new("UIStroke")
	s.Color = color
	s.Thickness = thickness or 1
	s.Transparency = transparency or 0
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.LineJoinMode = Enum.LineJoinMode.Round
	s.Parent = parent
	return s
end

local function wrapElement(el)
	return setmetatable(el, {
		__index = function(tbl, key)
			local value = rawget(tbl, key)
			if type(value) == "function" then
				return function(_, ...)
					return value(tbl, ...)
				end
			end
			return value
		end,
	})
end

local function normalizeDropdownValue(value, list)
	if #list == 0 then
		return ""
	end
	if value ~= nil then
		for _, item in ipairs(list) do
			if item == value then
				return value
			end
		end
	end
	return list[1]
end

local function addThemedCard(parent, theme, height)
	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, 0, 0, height)
	card.BackgroundColor3 = theme.elementColor
	card.BackgroundTransparency = 0
	card.BorderSizePixel = 0
	card.ClipsDescendants = true
	card.Parent = parent
	addCorner(card, theme.cornerRadius)
	return card
end

local function isPointInside(guiObj, x, y)
	if not guiObj or not guiObj.Visible then return false end
	local pos = guiObj.AbsolutePosition
	local size = guiObj.AbsoluteSize
	return x >= pos.X and x <= pos.X + size.X and y >= pos.Y and y <= pos.Y + size.Y
end

local function formatKeyName(keyCode)
	if not keyCode then
		return "None"
	end
	local name = keyCode.Name
	name = name:gsub("^Left", "L"):gsub("^Right", "R")
	return name
end

local function colorToHex(color)
	return string.format(
		"#%02X%02X%02X",
		math.floor(color.R * 255 + 0.5),
		math.floor(color.G * 255 + 0.5),
		math.floor(color.B * 255 + 0.5)
	)
end

local function colorToRgbText(color)
	return string.format(
		"RGB(%d, %d, %d)",
		math.floor(color.R * 255 + 0.5),
		math.floor(color.G * 255 + 0.5),
		math.floor(color.B * 255 + 0.5)
	)
end

local HUE_GRADIENT = ColorSequence.new({
	ColorSequenceKeypoint.new(0.00, Color3.fromHSV(0, 1, 1)),
	ColorSequenceKeypoint.new(0.17, Color3.fromHSV(0.17, 1, 1)),
	ColorSequenceKeypoint.new(0.33, Color3.fromHSV(0.33, 1, 1)),
	ColorSequenceKeypoint.new(0.50, Color3.fromHSV(0.50, 1, 1)),
	ColorSequenceKeypoint.new(0.67, Color3.fromHSV(0.67, 1, 1)),
	ColorSequenceKeypoint.new(0.83, Color3.fromHSV(0.83, 1, 1)),
	ColorSequenceKeypoint.new(1.00, Color3.fromHSV(1, 1, 1)),
})


-- ─── Menu constructor ────────────────────────────────────────────────────────

local function createMenu(LibRef, tabs, options)
	options = options or {}

	local menu = {}
	menu._connections = {}
	menu._elements = {}
	menu._themes = deepCopy(BUILTIN_THEMES)
	menu._currentTheme = "Dark"
	menu._menuType = "Default"
	menu._openDropdown = nil
	menu._openColorPicker = nil
	menu._activeKeybind = nil
	menu._version = options.version or VERSION
	menu._tabNames = {}
	menu._tabMeta = {}
	menu._tabContents = {}
	menu._activeTab = nil
	menu._destroyed = false

	local mainWidth = 560
	local mainHeight = 440

	menu._tabNames = {}
	menu._settingsBuilt = false
	menu._finished = false

	-- ScreenGui
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = options.name or "ErtyHubMenu"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.DisplayOrder = options.displayOrder or 10

	local player = Players.LocalPlayer
	local parent = options.parent
	if parent then
		screenGui.Parent = parent
	elseif player then
		screenGui.Parent = player:WaitForChild("PlayerGui")
	else
		screenGui.Parent = game:GetService("CoreGui")
	end

	-- Main frame
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.new(0, mainWidth, 0, mainHeight)
	mainFrame.Position = UDim2.new(0.5, -mainWidth / 2, 0.5, -mainHeight / 2)
	mainFrame.BackgroundColor3 = BUILTIN_THEMES.Dark.backgroundColor
	mainFrame.BorderSizePixel = 0
	mainFrame.ClipsDescendants = true
	mainFrame.Parent = screenGui
	local mainCorner = addCorner(mainFrame, MAIN_CORNER)

	local mainGradient = addGradient(
		mainFrame,
		BUILTIN_THEMES.Dark.backgroundColor,
		BUILTIN_THEMES.Dark.backgroundColor2,
		145
	)

	local borderFrame = Instance.new("Frame")
	borderFrame.Name = "Border"
	borderFrame.Size = UDim2.new(1, 0, 1, 0)
	borderFrame.BackgroundTransparency = 1
	borderFrame.BorderSizePixel = 0
	borderFrame.ZIndex = 20
	borderFrame.Parent = mainFrame
	addCorner(borderFrame, MAIN_CORNER)
	local stroke = addStroke(borderFrame, BUILTIN_THEMES.Dark.strokeColor, 1, 0.35)

	-- Title bar (draggable)
	local titleBar = Instance.new("Frame")
	titleBar.Name = "TitleBar"
	titleBar.Size = UDim2.new(1, 0, 0, TITLE_HEIGHT)
	titleBar.BackgroundColor3 = BUILTIN_THEMES.Dark.tabBarColor
	titleBar.BorderSizePixel = 0
	titleBar.ClipsDescendants = true
	titleBar.Parent = mainFrame
	local titleCorner = addCorner(titleBar, MAIN_CORNER)

	local titleGradient = addGradient(
		titleBar,
		BUILTIN_THEMES.Dark.tabBarColor,
		BUILTIN_THEMES.Dark.backgroundColor2,
		90
	)

	local accentDot = Instance.new("Frame")
	accentDot.Name = "AccentDot"
	accentDot.Size = UDim2.new(0, 8, 0, 8)
	accentDot.Position = UDim2.new(0, 16, 0.5, -4)
	accentDot.BackgroundColor3 = BUILTIN_THEMES.Dark.accentColor
	accentDot.BorderSizePixel = 0
	accentDot.Parent = titleBar
	addCorner(accentDot, 4)
	addGradient(accentDot, BUILTIN_THEMES.Dark.accentColor, BUILTIN_THEMES.Dark.accentColor2, 45)

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "Title"
	titleLabel.Size = UDim2.new(1, -100, 1, 0)
	titleLabel.Position = UDim2.new(0, 32, 0, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = options.title or "ErtyHub"
	titleLabel.TextColor3 = BUILTIN_THEMES.Dark.textColor
	titleLabel.TextSize = 17
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Parent = titleBar

	local versionBadge = Instance.new("TextLabel")
	versionBadge.Name = "Version"
	versionBadge.Size = UDim2.new(0, 40, 0, 18)
	versionBadge.Position = UDim2.new(0, 32, 1, -20)
	versionBadge.BackgroundTransparency = 1
	local showVersion = options.showVersion ~= false
	versionBadge.Text = showVersion and ("v" .. menu._version) or ""
	versionBadge.Visible = showVersion
	versionBadge.TextColor3 = BUILTIN_THEMES.Dark.subTextColor
	versionBadge.TextSize = 10
	versionBadge.Font = Enum.Font.GothamMedium
	versionBadge.TextXAlignment = Enum.TextXAlignment.Left
	versionBadge.Parent = titleBar

	local controls = Instance.new("Frame")
	controls.Name = "Controls"
	controls.Size = UDim2.new(0, 72, 0, 32)
	controls.Position = UDim2.new(1, -80, 0.5, -16)
	controls.BackgroundTransparency = 1
	controls.Parent = titleBar

	local controlsList = Instance.new("UIListLayout")
	controlsList.FillDirection = Enum.FillDirection.Horizontal
	controlsList.Padding = UDim.new(0, 8)
	controlsList.HorizontalAlignment = Enum.HorizontalAlignment.Right
	controlsList.VerticalAlignment = Enum.VerticalAlignment.Center
	controlsList.SortOrder = Enum.SortOrder.LayoutOrder
	controlsList.Parent = controls

	local function makeWindowButton(name, symbol, layoutOrder)
		local btn = Instance.new("TextButton")
		btn.Name = name
		btn.Size = UDim2.new(0, 28, 0, 28)
		btn.BackgroundColor3 = BUILTIN_THEMES.Dark.elementColor
		btn.BackgroundTransparency = 0.2
		btn.Text = ""
		btn.BorderSizePixel = 0
		btn.AutoButtonColor = false
		btn.Active = true
		btn.LayoutOrder = layoutOrder
		btn.Parent = controls
		addCorner(btn, 14)
		addStroke(btn, BUILTIN_THEMES.Dark.strokeColor, 1, 0.5)

		local icon = Instance.new("TextLabel")
		icon.Name = "Icon"
		icon.Size = UDim2.new(1, 0, 1, 0)
		icon.BackgroundTransparency = 1
		icon.Text = symbol
		icon.TextColor3 = BUILTIN_THEMES.Dark.subTextColor
		icon.TextSize = name == "Minimize" and 18 or 16
		icon.Font = Enum.Font.GothamBold
		icon.Parent = btn

		return btn, icon
	end

	local minimizeBtn, minimizeIcon = makeWindowButton("Minimize", "−", 1)
	local closeBtn, closeIcon = makeWindowButton("Close", "×", 2)

	-- Floating restore button (PC + touch)
	local restoreBtn = Instance.new("TextButton")
	restoreBtn.Name = "Restore"
	restoreBtn.Size = UDim2.new(0, 56, 0, 56)
	restoreBtn.Position = UDim2.new(1, -72, 1, -88)
	restoreBtn.AnchorPoint = Vector2.new(0, 0)
	restoreBtn.BackgroundColor3 = BUILTIN_THEMES.Dark.elementColor
	restoreBtn.BackgroundTransparency = 0.05
	restoreBtn.Text = ""
	restoreBtn.BorderSizePixel = 0
	restoreBtn.AutoButtonColor = false
	restoreBtn.Active = true
	restoreBtn.Visible = false
	restoreBtn.ZIndex = 50
	restoreBtn.Parent = screenGui
	addCorner(restoreBtn, 16)
	addStroke(restoreBtn, BUILTIN_THEMES.Dark.accentColor, 1.5, 0.4)
	addGradient(restoreBtn, BUILTIN_THEMES.Dark.accentColor, BUILTIN_THEMES.Dark.accentColor2, 45)

	local restoreIcon = Instance.new("TextLabel")
	restoreIcon.Name = "Icon"
	restoreIcon.Size = UDim2.new(1, 0, 0, 22)
	restoreIcon.Position = UDim2.new(0, 0, 0, 8)
	restoreIcon.BackgroundTransparency = 1
	restoreIcon.Text = "☰"
	restoreIcon.TextColor3 = Color3.new(1, 1, 1)
	restoreIcon.TextSize = 16
	restoreIcon.Font = Enum.Font.GothamBold
	restoreIcon.Parent = restoreBtn

	local restoreLabel = Instance.new("TextLabel")
	restoreLabel.Name = "Label"
	restoreLabel.Size = UDim2.new(1, -4, 0, 14)
	restoreLabel.Position = UDim2.new(0, 2, 1, -18)
	restoreLabel.BackgroundTransparency = 1
	restoreLabel.Text = options.title or "Menu"
	restoreLabel.TextColor3 = Color3.new(1, 1, 1)
	restoreLabel.TextSize = 10
	restoreLabel.Font = Enum.Font.GothamMedium
	restoreLabel.TextTruncate = Enum.TextTruncate.AtEnd
	restoreLabel.Parent = restoreBtn

	local restoreScale = Instance.new("UIScale")
	restoreScale.Scale = 1
	restoreScale.Parent = restoreBtn

	-- Notification layer (visible even when menu is minimized)
	local notificationLayer = Instance.new("Frame")
	notificationLayer.Name = "NotificationLayer"
	notificationLayer.Size = UDim2.new(1, 0, 1, 0)
	notificationLayer.BackgroundTransparency = 1
	notificationLayer.ZIndex = 200
	notificationLayer.Parent = screenGui

	local notifyStack = Instance.new("Frame")
	notifyStack.Name = "NotifyStack"
	notifyStack.Size = UDim2.fromOffset(NOTIFY_WIDTH, 0)
	notifyStack.AutomaticSize = Enum.AutomaticSize.Y
	notifyStack.Position = UDim2.new(1, -NOTIFY_MARGIN_RIGHT, 1, -NOTIFY_MARGIN_BOTTOM)
	notifyStack.AnchorPoint = Vector2.new(1, 1)
	notifyStack.BackgroundTransparency = 1
	notifyStack.Parent = notificationLayer
	addList(notifyStack, 8)

	menu._notifications = {}

	-- Top tab bar
	local tabBar = Instance.new("Frame")
	tabBar.Name = "TabBar"
	tabBar.Size = UDim2.new(1, 0, 0, TAB_BAR_HEIGHT)
	tabBar.Position = UDim2.new(0, 0, 0, TITLE_HEIGHT)
	tabBar.BackgroundColor3 = BUILTIN_THEMES.Dark.tabBarColor
	tabBar.BorderSizePixel = 0
	tabBar.ClipsDescendants = false
	tabBar.Parent = mainFrame

	local tabBarLine = Instance.new("Frame")
	tabBarLine.Name = "Divider"
	tabBarLine.Size = UDim2.new(1, 0, 0, 1)
	tabBarLine.Position = UDim2.new(0, 0, 1, -1)
	tabBarLine.BackgroundColor3 = BUILTIN_THEMES.Dark.strokeColor
	tabBarLine.BackgroundTransparency = 0.5
	tabBarLine.BorderSizePixel = 0
	tabBarLine.Parent = tabBar

	local tabScroll = Instance.new("ScrollingFrame")
	tabScroll.Name = "TabScroll"
	tabScroll.Size = UDim2.new(1, -16, 1, 0)
	tabScroll.Position = UDim2.new(0, 8, 0, 0)
	tabScroll.BackgroundTransparency = 1
	tabScroll.BorderSizePixel = 0
	tabScroll.ScrollBarThickness = 0
	tabScroll.ScrollingDirection = Enum.ScrollingDirection.X
	tabScroll.AutomaticCanvasSize = Enum.AutomaticSize.X
	tabScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	tabScroll.Parent = tabBar

	local tabList = Instance.new("UIListLayout")
	tabList.FillDirection = Enum.FillDirection.Horizontal
	tabList.Padding = UDim.new(0, 4)
	tabList.SortOrder = Enum.SortOrder.LayoutOrder
	tabList.VerticalAlignment = Enum.VerticalAlignment.Center
	tabList.Parent = tabScroll
	addPadding(tabScroll, 6, 6, 4, 4)

	local tabIndicator = Instance.new("Frame")
	tabIndicator.Name = "Indicator"
	tabIndicator.Size = UDim2.new(0, 60, 0, 3)
	tabIndicator.Position = UDim2.new(0, 8, 1, -4)
	tabIndicator.BackgroundColor3 = BUILTIN_THEMES.Dark.accentColor
	tabIndicator.BorderSizePixel = 0
	tabIndicator.ZIndex = 2
	tabIndicator.Parent = tabBar
	addCorner(tabIndicator, 2)
	addGradient(tabIndicator, BUILTIN_THEMES.Dark.accentColor, BUILTIN_THEMES.Dark.accentColor2, 0)

	-- Content area
	local contentArea = Instance.new("Frame")
	contentArea.Name = "Content"
	contentArea.Size = UDim2.new(1, 0, 1, -(TITLE_HEIGHT + TAB_BAR_HEIGHT))
	contentArea.Position = UDim2.new(0, 0, 0, TITLE_HEIGHT + TAB_BAR_HEIGHT)
	contentArea.BackgroundColor3 = BUILTIN_THEMES.Dark.contentColor
	contentArea.BackgroundTransparency = 0
	contentArea.BorderSizePixel = 0
	contentArea.ClipsDescendants = true
	contentArea.Parent = mainFrame
	local contentCorner = addCorner(contentArea, MAIN_CORNER)

	local contentGradient = addGradient(
		contentArea,
		BUILTIN_THEMES.Dark.contentColor,
		BUILTIN_THEMES.Dark.backgroundColor,
		180
	)
	contentGradient.Transparency = NumberSequence.new(0.1)

	local dropdownOverlay = Instance.new("Frame")
	dropdownOverlay.Name = "DropdownOverlay"
	dropdownOverlay.Size = UDim2.new(1, 0, 1, 0)
	dropdownOverlay.BackgroundTransparency = 1
	dropdownOverlay.ZIndex = 100
	dropdownOverlay.ClipsDescendants = false
	dropdownOverlay.Parent = mainFrame

	menu._gui = {
		screenGui = screenGui,
		mainFrame = mainFrame,
		mainCorner = mainCorner,
		mainGradient = mainGradient,
		titleBar = titleBar,
		titleCorner = titleCorner,
		titleGradient = titleGradient,
		titleLabel = titleLabel,
		versionBadge = versionBadge,
		accentDot = accentDot,
		controls = controls,
		minimizeBtn = minimizeBtn,
		minimizeIcon = minimizeIcon,
		closeBtn = closeBtn,
		closeIcon = closeIcon,
		restoreBtn = restoreBtn,
		restoreIcon = restoreIcon,
		restoreLabel = restoreLabel,
		restoreScale = restoreScale,
		tabBar = tabBar,
		tabBarLine = tabBarLine,
		tabScroll = tabScroll,
		tabIndicator = tabIndicator,
		contentArea = contentArea,
		contentCorner = contentCorner,
		contentGradient = contentGradient,
		dropdownOverlay = dropdownOverlay,
		borderFrame = borderFrame,
		stroke = stroke,
		notificationLayer = notificationLayer,
		notifyStack = notifyStack,
	}
	menu._mainWidth = mainWidth
	menu._mainHeight = mainHeight
	menu._minimized = false

	-- Drag logic
	local dragging = false
	local dragStart, frameStart
	local restoreDragging = false
	local restoreDragStart, restoreBtnStart
	local restoreMoved = false

	local function conn(signal, fn)
		local c = signal:Connect(fn)
		table.insert(menu._connections, c)
		return c
	end

	local dragHandle = Instance.new("Frame")
	dragHandle.Name = "DragHandle"
	dragHandle.Size = UDim2.new(1, -88, 1, 0)
	dragHandle.BackgroundTransparency = 1
	dragHandle.Parent = titleBar

	conn(dragHandle.InputBegan, function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		dragging = true
		dragStart = input.Position
		frameStart = mainFrame.Position
	end)

	conn(UserInputService.InputChanged, function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			mainFrame.Position = UDim2.new(
				frameStart.X.Scale, frameStart.X.Offset + delta.X,
				frameStart.Y.Scale, frameStart.Y.Offset + delta.Y
			)
		elseif restoreDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			if (input.Position - restoreDragStart).Magnitude > 6 then
				restoreMoved = true
			end
			local delta = input.Position - restoreDragStart
			restoreBtn.Position = UDim2.new(
				restoreBtnStart.X.Scale, restoreBtnStart.X.Offset + delta.X,
				restoreBtnStart.Y.Scale, restoreBtnStart.Y.Offset + delta.Y
			)
		end
	end)

	conn(UserInputService.InputEnded, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
			restoreDragging = false
		end
	end)

	local function placeRestoreNearMenu()
		local absPos = mainFrame.AbsolutePosition
		local absSize = mainFrame.AbsoluteSize
		local x = absPos.X + absSize.X - 56
		local y = absPos.Y + 8
		local camera = workspace.CurrentCamera
		if camera then
			local vp = camera.ViewportSize
			x = math.clamp(x, 8, vp.X - 64)
			y = math.clamp(y, 8, vp.Y - 64)
		end
		restoreBtn.Position = UDim2.fromOffset(x, y)
	end

	function menu:Minimize()
		if self._destroyed then return end
		if self._openDropdown then self._openDropdown:Close() end
		if self._openColorPicker then self._openColorPicker:Close() end
		if self._activeKeybind then self._activeKeybind:CancelListen() end
		placeRestoreNearMenu()
		mainFrame.Visible = false
		restoreBtn.Visible = true
		self._minimized = true
		restoreScale.Scale = 0.85
		tween(restoreScale, { Scale = 1 }, TWEEN_OPEN):Play()
	end

	function menu:Restore()
		if self._destroyed then return end
		screenGui.Enabled = true
		mainFrame.Visible = true
		restoreBtn.Visible = false
		self._minimized = false
	end

	conn(minimizeBtn.MouseButton1Click, function()
		menu:Minimize()
	end)

	conn(restoreBtn.InputBegan, function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		restoreDragging = true
		restoreMoved = false
		restoreDragStart = input.Position
		restoreBtnStart = restoreBtn.Position
	end)

	conn(restoreBtn.InputEnded, function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		if restoreDragging and not restoreMoved then
			menu:Restore()
		end
		restoreDragging = false
	end)

	conn(minimizeBtn.MouseEnter, function()
		tween(minimizeBtn, { BackgroundColor3 = menu:_getTheme().accentColor, BackgroundTransparency = 0 }):Play()
		tween(minimizeIcon, { TextColor3 = Color3.new(1, 1, 1) }):Play()
	end)
	conn(minimizeBtn.MouseLeave, function()
		tween(minimizeBtn, { BackgroundColor3 = menu:_getTheme().elementColor, BackgroundTransparency = 0.2 }):Play()
		tween(minimizeIcon, { TextColor3 = menu:_getTheme().subTextColor }):Play()
	end)

	conn(closeBtn.MouseEnter, function()
		tween(closeBtn, { BackgroundColor3 = Color3.fromRGB(255, 82, 82), BackgroundTransparency = 0 }):Play()
		tween(closeIcon, { TextColor3 = Color3.new(1, 1, 1) }):Play()
	end)
	conn(closeBtn.MouseLeave, function()
		tween(closeBtn, { BackgroundColor3 = menu:_getTheme().elementColor, BackgroundTransparency = 0.2 }):Play()
		tween(closeIcon, { TextColor3 = menu:_getTheme().subTextColor }):Play()
	end)

	conn(closeBtn.MouseButton1Click, function()
		if menu._openDropdown then menu._openDropdown:Close() end
		if menu._openColorPicker then menu._openColorPicker:Close() end
		if menu._activeKeybind then menu._activeKeybind:CancelListen() end
		mainFrame.Visible = false
		restoreBtn.Visible = false
		screenGui.Enabled = false
		menu._minimized = false
	end)

	conn(restoreBtn.MouseEnter, function()
		tween(restoreScale, { Scale = 1.06 }):Play()
	end)
	conn(restoreBtn.MouseLeave, function()
		tween(restoreScale, { Scale = 1 }):Play()
	end)

	-- Global input: keybind capture + click-outside overlays
	conn(UserInputService.InputBegan, function(input)
		if menu._destroyed then return end

		if menu._activeKeybind and input.UserInputType == Enum.UserInputType.Keyboard then
			local kb = menu._activeKeybind
			if input.KeyCode == Enum.KeyCode.Escape then
				kb:CancelListen()
			elseif input.KeyCode == Enum.KeyCode.Backspace or input.KeyCode == Enum.KeyCode.Delete then
				kb:SetKey(nil)
				kb:CancelListen()
			else
				kb:SetKey(input.KeyCode)
				kb:CancelListen()
			end
			return
		end

		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end

		local pos = input.Position

		if menu._openColorPicker then
			local cp = menu._openColorPicker
			local inside = isPointInside(cp._container, pos.X, pos.Y)
				or isPointInside(cp._panel, pos.X, pos.Y)
			if not inside and cp.Close then
				cp:Close()
			end
		end

		if menu._openDropdown then
			local dd = menu._openDropdown
			local inside = isPointInside(dd._container, pos.X, pos.Y)
				or isPointInside(dd._listFrame, pos.X, pos.Y)
			if not inside and dd.Close then
				dd:Close()
			end
		end
	end)

	-- ─── Internal helpers ────────────────────────────────────────────────────

	function menu:_getTheme()
		return self._themes[self._currentTheme] or BUILTIN_THEMES.Dark
	end

	function menu:_nextLayoutOrder(tab)
		local content = self._tabContents[tab]
		if not content then return 1 end
		content._order = (content._order or 0) + 1
		return content._order
	end

	function menu:_getTabScroll(tab)
		local content = self._tabContents[tab]
		return content and content.scroll
	end

	function menu:_registerElement(el)
		table.insert(self._elements, el)
		return wrapElement(el)
	end

	function menu:_closeOpenDropdown(except)
		if self._openDropdown and self._openDropdown ~= except then
			self._openDropdown:Close()
		end
	end

	function menu:_closeOpenColorPicker(except)
		if self._openColorPicker and self._openColorPicker ~= except then
			self._openColorPicker:Close()
		end
	end

	function menu:_cancelActiveKeybind(except)
		if self._activeKeybind and self._activeKeybind ~= except then
			self._activeKeybind:CancelListen()
		end
	end

	function menu:_makeRow(tab, height)
		local theme = self:_getTheme()
		local scroll = self:_getTabScroll(tab)
		if not scroll then return nil end

		local row = Instance.new("Frame")
		row.Name = "Row"
		row.Size = UDim2.new(1, -8, 0, height or theme.elementHeight)
		row.BackgroundTransparency = 1
		row.LayoutOrder = self:_nextLayoutOrder(tab)
		row.ClipsDescendants = false
		row.Parent = scroll

		return row
	end

	function menu:_makeLabel(parent, text, size, color, bold)
		local theme = self:_getTheme()
		local lbl = Instance.new("TextLabel")
		lbl.BackgroundTransparency = 1
		lbl.Text = text or ""
		lbl.TextColor3 = color or theme.textColor
		lbl.TextSize = size or 14
		lbl.Font = bold and Enum.Font.GothamBold or Enum.Font.GothamMedium
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.TextTruncate = Enum.TextTruncate.AtEnd
		lbl.Parent = parent
		return lbl
	end

	function menu:_applyThemeToElement(el)
		local theme = self:_getTheme()
		if el._bg then
			el._bg.BackgroundColor3 = theme.elementColor
		end
		if el._label then
			el._label.TextColor3 = theme.textColor
		end
		if el._subLabel then
			el._subLabel.TextColor3 = theme.subTextColor
		end
		if el._stroke then
			el._stroke.Color = theme.strokeColor
		end
	end

	function menu:_updateTabIndicator(tabName)
		local meta = self._tabMeta[tabName]
		if not meta or not meta.wrap then return end
		task.defer(function()
			if not meta.wrap.Parent then return end
			local x = meta.wrap.AbsolutePosition.X - self._gui.tabBar.AbsolutePosition.X
			local w = meta.wrap.AbsoluteSize.X
			tween(self._gui.tabIndicator, {
				Position = UDim2.new(0, x, 1, -4),
				Size = UDim2.new(0, math.max(w, 40), 0, 3),
			}, TWEEN_TAB):Play()
		end)
	end

	function menu:ApplyTheme(themeName)
		if not self._themes[themeName] then return end
		self._currentTheme = themeName
		local theme = self:_getTheme()
		local g = self._gui

		g.mainFrame.BackgroundColor3 = theme.backgroundColor
		g.mainGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, theme.backgroundColor),
			ColorSequenceKeypoint.new(1, theme.backgroundColor2 or theme.backgroundColor),
		})
		g.titleBar.BackgroundColor3 = theme.tabBarColor
		g.titleGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, theme.tabBarColor),
			ColorSequenceKeypoint.new(1, theme.backgroundColor2 or theme.tabBarColor),
		})
		g.titleLabel.TextColor3 = theme.textColor
		g.versionBadge.TextColor3 = theme.subTextColor
		g.accentDot.BackgroundColor3 = theme.accentColor
		g.tabBar.BackgroundColor3 = theme.tabBarColor
		g.tabBarLine.BackgroundColor3 = theme.strokeColor
		g.contentArea.BackgroundColor3 = theme.contentColor
		g.contentGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, theme.contentColor),
			ColorSequenceKeypoint.new(1, theme.backgroundColor),
		})
		g.stroke.Color = theme.strokeColor
		g.tabIndicator.BackgroundColor3 = theme.accentColor

		for _, content in pairs(self._tabContents) do
			if content.scroll then
				content.scroll.ScrollBarImageColor3 = theme.accentColor
			end
		end

		if not self._minimized then
			g.minimizeBtn.BackgroundColor3 = theme.elementColor
			g.closeBtn.BackgroundColor3 = theme.elementColor
			g.minimizeIcon.TextColor3 = theme.subTextColor
			g.closeIcon.TextColor3 = theme.subTextColor
		end
		local minStroke = g.minimizeBtn:FindFirstChildOfClass("UIStroke")
		local closeStroke = g.closeBtn:FindFirstChildOfClass("UIStroke")
		if minStroke then minStroke.Color = theme.strokeColor end
		if closeStroke then closeStroke.Color = theme.strokeColor end
		local restoreStroke = g.restoreBtn:FindFirstChildOfClass("UIStroke")
		if restoreStroke then restoreStroke.Color = theme.accentColor end
		local restoreGrad = g.restoreBtn:FindFirstChildOfClass("UIGradient")
		if restoreGrad then
			restoreGrad.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, theme.accentColor),
				ColorSequenceKeypoint.new(1, theme.accentColor2 or theme.accentColor),
			})
		end

		for name, meta in pairs(self._tabMeta) do
			if meta.active then
				meta.button.TextColor3 = theme.accentColor
				meta.button.Font = Enum.Font.GothamBold
			else
				meta.button.TextColor3 = theme.subTextColor
				meta.button.Font = Enum.Font.GothamMedium
			end
		end

		if self._activeTab then
			self:_updateTabIndicator(self._activeTab)
		end

		for _, el in ipairs(self._elements) do
			if el._applyTheme then
				el:_applyTheme(theme)
			else
				self:_applyThemeToElement(el)
			end
		end
	end

	function menu:SetTheme(name)
		self:ApplyTheme(name)
	end

	function menu:GetTheme()
		return self._currentTheme
	end

	-- ─── Tab switching ───────────────────────────────────────────────────────

	function menu:_switchTab(tabName)
		if self._activeTab == tabName then return end
		local theme = self:_getTheme()

		for name, content in pairs(self._tabContents) do
			content.frame.Visible = (name == tabName)
		end

		for name, meta in pairs(self._tabMeta) do
			meta.active = (name == tabName)
			if meta.active then
				meta.button.TextColor3 = theme.accentColor
				meta.button.Font = Enum.Font.GothamBold
				tween(meta.wrap, { BackgroundTransparency = 0.85 }):Play()
			else
				meta.button.TextColor3 = theme.subTextColor
				meta.button.Font = Enum.Font.GothamMedium
				tween(meta.wrap, { BackgroundTransparency = 1 }):Play()
			end
		end

		self._activeTab = tabName
		self:_updateTabIndicator(tabName)
	end

	function menu:_registerTabUI(tabName)
		if self._tabContents[tabName] then
			return self._tabContents[tabName]
		end

		local layoutOrder = #self._tabNames
		table.insert(self._tabNames, tabName)

		local tabWrap = Instance.new("Frame")
		tabWrap.Name = tabName .. "_Wrap"
		tabWrap.Size = UDim2.new(0, 0, 0, 32)
		tabWrap.AutomaticSize = Enum.AutomaticSize.X
		tabWrap.BackgroundTransparency = 1
		tabWrap.BorderSizePixel = 0
		tabWrap.LayoutOrder = layoutOrder
		tabWrap.Parent = tabScroll
		addCorner(tabWrap, 8)

		local tabBtn = Instance.new("TextButton")
		tabBtn.Name = tabName
		tabBtn.Size = UDim2.new(0, 0, 1, 0)
		tabBtn.AutomaticSize = Enum.AutomaticSize.X
		tabBtn.BackgroundTransparency = 1
		tabBtn.Text = "  " .. tabName .. "  "
		tabBtn.TextColor3 = BUILTIN_THEMES.Dark.subTextColor
		tabBtn.TextSize = 14
		tabBtn.Font = Enum.Font.GothamMedium
		tabBtn.BorderSizePixel = 0
		tabBtn.AutoButtonColor = false
		tabBtn.Active = true
		tabBtn.Parent = tabWrap

		self._tabMeta[tabName] = {
			wrap = tabWrap,
			button = tabBtn,
			active = false,
		}

		conn(tabBtn.MouseButton1Click, function()
			menu:_switchTab(tabName)
		end)

		conn(tabBtn.MouseEnter, function()
			local meta = menu._tabMeta[tabName]
			if meta and not meta.active then
				tween(tabBtn, { TextColor3 = menu:_getTheme().textColor }):Play()
			end
		end)

		conn(tabBtn.MouseLeave, function()
			local meta = menu._tabMeta[tabName]
			if meta and not meta.active then
				tween(tabBtn, { TextColor3 = menu:_getTheme().subTextColor }):Play()
			end
		end)

		local tabFrame = Instance.new("Frame")
		tabFrame.Name = "Tab_" .. tabName
		tabFrame.Size = UDim2.new(1, 0, 1, 0)
		tabFrame.BackgroundTransparency = 1
		tabFrame.Visible = false
		tabFrame.ClipsDescendants = true
		tabFrame.Parent = contentArea

		local scroll = Instance.new("ScrollingFrame")
		scroll.Name = "Scroll"
		scroll.Size = UDim2.new(1, 0, 1, 0)
		scroll.BackgroundTransparency = 1
		scroll.BorderSizePixel = 0
		scroll.ScrollBarThickness = 4
		scroll.ScrollBarImageColor3 = BUILTIN_THEMES.Dark.accentColor
		scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
		scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
		scroll.ClipsDescendants = false
		scroll.Parent = tabFrame

		local scrollList = addList(scroll, 8)
		addPadding(scroll, 12, 12, 12, 12)

		self._tabContents[tabName] = {
			frame = tabFrame,
			scroll = scroll,
			list = scrollList,
			_order = 0,
		}

		if not self._activeTab then
			self:_switchTab(tabName)
		end

		return self._tabContents[tabName]
	end

	local function makeTabProxy(tabName)
		local tab = { Name = tabName }

		local function bind(methodName)
			tab[methodName] = function(_, opts)
				opts = opts or {}
				opts.tab = tabName
				return menu[methodName](menu, opts)
			end
		end

		bind("AddButton")
		bind("AddToggle")
		bind("AddInput")
		bind("AddPageName")
		bind("AddTitle")
		bind("AddSubtitle")
		bind("AddDropdown")
		bind("AddMultiDropdown")
		bind("AddSlider")
		bind("AddLabel")
		bind("AddSeparator")
		bind("AddKeybind")
		bind("AddColorPicker")

		return tab
	end

	function menu:AddTab(tabName)
		if type(tabName) ~= "string" or tabName == "" then
			error("ErtyHub: AddTab() requires a non-empty tab name", 2)
		end
		if tabName == "Settings" then
			error("ErtyHub: Settings tab is created automatically — use menu:Finish()", 2)
		end
		self:_registerTabUI(tabName)
		return makeTabProxy(tabName)
	end

	-- Legacy: pre-declared tabs from Create({ "Main", ... })
	for _, tabName in ipairs(tabs or {}) do
		if tabName ~= "Settings" then
			menu:_registerTabUI(tabName)
		end
	end

	-- ─── AddLabel ────────────────────────────────────────────────────────────

	function menu:AddLabel(opts)
		opts = opts or {}
		local tab = opts.tab or self._tabNames[1]
		local theme = self:_getTheme()

		local row = self:_makeRow(tab, opts.height or 24)
		local lbl = self:_makeLabel(row, opts.text or "", opts.textSize or 13, opts.color or theme.subTextColor, false)
		lbl.Size = UDim2.new(1, 0, 1, 0)

		local el = {
			type = "Label",
			tab = tab,
			instance = row,
			_label = lbl,
			SetText = function(_, text)
				lbl.Text = text
			end,
			_applyTheme = function(_, t)
				lbl.TextColor3 = opts.color or t.subTextColor
			end,
		}
		return self:_registerElement(el)
	end

	-- ─── AddSeparator ────────────────────────────────────────────────────────

	function menu:AddSeparator(opts)
		opts = opts or {}
		local tab = opts.tab or self._tabNames[1]
		local theme = self:_getTheme()

		local row = self:_makeRow(tab, 12)
		local line = Instance.new("Frame")
		line.Size = UDim2.new(1, 0, 0, 1)
		line.Position = UDim2.new(0, 0, 0.5, 0)
		line.BackgroundColor3 = theme.strokeColor
		line.BorderSizePixel = 0
		line.Parent = row

		local el = {
			type = "Separator",
			tab = tab,
			instance = row,
			_applyTheme = function(_, t)
				line.BackgroundColor3 = t.strokeColor
			end,
		}
		return self:_registerElement(el)
	end

	-- ─── AddPageName ─────────────────────────────────────────────────────────

	function menu:AddPageName(opts)
		opts = opts or {}
		local tab = opts.tab or self._tabNames[1]
		local theme = self:_getTheme()

		local row = self:_makeRow(tab, 36)
		local lbl = self:_makeLabel(row, opts.text or "Page", 20, theme.textColor, true)
		lbl.Size = UDim2.new(1, 0, 1, 0)

		local el = {
			type = "PageName", tab = tab, instance = row, _label = lbl,
			_applyTheme = function(_, t) lbl.TextColor3 = t.textColor end,
		}
		return self:_registerElement(el)
	end

	-- ─── AddTitle ────────────────────────────────────────────────────────────

	function menu:AddTitle(opts)
		opts = opts or {}
		local tab = opts.tab or self._tabNames[1]
		local theme = self:_getTheme()

		local row = self:_makeRow(tab, 28)
		local lbl = self:_makeLabel(row, opts.text or "Title", 18, theme.textColor, true)
		lbl.Size = UDim2.new(1, 0, 1, 0)

		local el = {
			type = "Title", tab = tab, instance = row, _label = lbl,
			_applyTheme = function(_, t) lbl.TextColor3 = t.textColor end,
		}
		return self:_registerElement(el)
	end

	-- ─── AddSubtitle ─────────────────────────────────────────────────────────

	function menu:AddSubtitle(opts)
		opts = opts or {}
		local tab = opts.tab or self._tabNames[1]
		local theme = self:_getTheme()

		local row = self:_makeRow(tab, 22)
		local lbl = self:_makeLabel(row, opts.text or "Subtitle", 14, theme.subTextColor, false)
		lbl.Size = UDim2.new(1, 0, 1, 0)

		local el = {
			type = "Subtitle", tab = tab, instance = row, _label = lbl, _subLabel = lbl,
			_applyTheme = function(_, t) lbl.TextColor3 = t.subTextColor end,
		}
		return self:_registerElement(el)
	end

	-- ─── AddButton ───────────────────────────────────────────────────────────

	function menu:AddButton(opts)
		opts = opts or {}
		local tab = opts.tab or self._tabNames[1]
		local theme = self:_getTheme()
		local h = math.max(MIN_TOUCH, theme.elementHeight)

		local row = self:_makeRow(tab, h)
		local accent = opts.color or theme.accentColor

		local btn = Instance.new("TextButton")
		btn.Name = "Button"
		btn.Size = UDim2.new(1, 0, 1, 0)
		btn.BackgroundTransparency = 1
		btn.Text = ""
		btn.BorderSizePixel = 0
		btn.AutoButtonColor = false
		btn.Active = true
		btn.ClipsDescendants = true
		btn.Parent = row
		addCorner(btn, theme.cornerRadius)

		local btnBg = Instance.new("Frame")
		btnBg.Name = "Background"
		btnBg.Size = UDim2.new(1, 0, 1, 0)
		btnBg.BackgroundColor3 = accent
		btnBg.BorderSizePixel = 0
		btnBg.ZIndex = 1
		btnBg.Parent = btn
		addCorner(btnBg, theme.cornerRadius)
		local btnGradient = addGradient(btnBg, accent, theme.accentColor2 or accent, 45)

		local btnText = Instance.new("TextLabel")
		btnText.Name = "Label"
		btnText.Size = UDim2.new(1, 0, 1, 0)
		btnText.BackgroundTransparency = 1
		btnText.Text = opts.text or "Button"
		btnText.TextColor3 = theme.buttonTextColor
		btnText.TextSize = 14
		btnText.Font = Enum.Font.GothamBold
		btnText.ZIndex = 2
		btnText.Active = false
		btnText.Parent = btn

		local scale = Instance.new("UIScale")
		scale.Scale = 1
		scale.Parent = btn

		local function brighten(color)
			return Color3.new(
				math.min(color.R + 0.08, 1),
				math.min(color.G + 0.08, 1),
				math.min(color.B + 0.08, 1)
			)
		end

		conn(btn.MouseButton1Click, function()
			tween(scale, { Scale = 0.97 }, TweenInfo.new(0.08)):Play()
			task.delay(0.08, function()
				if scale.Parent then tween(scale, { Scale = 1 }):Play() end
			end)
			if opts.callback then opts.callback() end
		end)

		conn(btn.MouseEnter, function()
			local t = self:_getTheme()
			local base = opts.color or t.accentColor
			tween(btnBg, { BackgroundColor3 = brighten(base) }):Play()
		end)

		conn(btn.MouseLeave, function()
			local t = self:_getTheme()
			tween(btnBg, { BackgroundColor3 = opts.color or t.accentColor }):Play()
		end)

		local el = {
			type = "Button",
			tab = tab,
			instance = row,
			_bg = btnBg,
			_gradient = btnGradient,
			_text = btnText,
			SetText = function(_, t) btnText.Text = t end,
			_applyTheme = function(_, t)
				local col = opts.color or t.accentColor
				btnBg.BackgroundColor3 = col
				btnText.TextColor3 = t.buttonTextColor
				if btnGradient then
					btnGradient.Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, col),
						ColorSequenceKeypoint.new(1, t.accentColor2 or col),
					})
				end
			end,
		}
		return self:_registerElement(el)
	end

	-- ─── AddToggle ───────────────────────────────────────────────────────────

	function menu:AddToggle(opts)
		opts = opts or {}
		local tab = opts.tab or self._tabNames[1]
		local theme = self:_getTheme()
		local h = math.max(MIN_TOUCH, theme.elementHeight)
		local state = opts.state or false

		local row = self:_makeRow(tab, h)
		local card = addThemedCard(row, theme, h)

		local lbl = self:_makeLabel(card, opts.text or "Toggle", 14, theme.textColor, false)
		lbl.Size = UDim2.new(1, -56, 1, 0)
		lbl.Position = UDim2.new(0, 12, 0, 0)

		local track = Instance.new("Frame")
		track.Name = "Track"
		track.Size = UDim2.new(0, 44, 0, 24)
		track.Position = UDim2.new(1, -52, 0.5, -12)
		track.BackgroundColor3 = state and theme.accentColor or theme.strokeColor
		track.BorderSizePixel = 0
		track.Parent = card
		addCorner(track, 12)

		local knob = Instance.new("Frame")
		knob.Name = "Knob"
		knob.Size = UDim2.new(0, 20, 0, 20)
		knob.Position = state and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
		knob.BackgroundColor3 = theme.knobColor
		knob.BorderSizePixel = 0
		knob.Parent = track
		addCorner(knob, 10)

		local hit = Instance.new("TextButton")
		hit.Size = UDim2.new(1, 0, 1, 0)
		hit.BackgroundTransparency = 1
		hit.Text = ""
		hit.Parent = card

		local function setState(val, fireCb)
			local t = self:_getTheme()
			state = val
			tween(track, { BackgroundColor3 = state and t.accentColor or t.strokeColor }):Play()
			tween(knob, {
				Position = state and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10),
			}):Play()
			if fireCb ~= false and opts.callback then opts.callback(state) end
		end

		conn(hit.MouseButton1Click, function()
			setState(not state)
		end)

		local el = {
			type = "Toggle",
			tab = tab,
			instance = row,
			_bg = card,
			_label = lbl,
			GetValue = function() return state end,
			SetValue = function(_, v) setState(v) end,
			_applyTheme = function(_, t)
				card.BackgroundColor3 = t.elementColor
				lbl.TextColor3 = t.textColor
				track.BackgroundColor3 = state and t.accentColor or t.strokeColor
				knob.BackgroundColor3 = t.knobColor
			end,
		}
		return self:_registerElement(el)
	end

	-- ─── AddInput ────────────────────────────────────────────────────────────

	function menu:AddInput(opts)
		opts = opts or {}
		local tab = opts.tab or self._tabNames[1]
		local theme = self:_getTheme()
		local h = math.max(MIN_TOUCH, theme.elementHeight)

		local row = self:_makeRow(tab, h)
		local fieldLabel

		if opts.text then
			fieldLabel = self:_makeLabel(row, opts.text, 13, theme.textColor, false)
			fieldLabel.Size = UDim2.new(0.35, 0, 1, 0)
		end

		local box = Instance.new("TextBox")
		box.Name = "Input"
		box.Size = UDim2.new(opts.text and 0.62 or 1, opts.text and -4 or 0, 1, 0)
		box.Position = UDim2.new(opts.text and 0.38 or 0, 0, 0, 0)
		box.BackgroundColor3 = theme.elementColor
		box.Text = opts.value or ""
		box.PlaceholderText = opts.placeholder or "Enter text..."
		box.PlaceholderColor3 = theme.subTextColor
		box.TextColor3 = theme.textColor
		box.TextSize = 14
		box.Font = Enum.Font.GothamMedium
		box.ClearTextOnFocus = false
		box.BorderSizePixel = 0
		box.ClipsDescendants = true
		box.Parent = row
		addCorner(box, theme.cornerRadius)
		addPadding(box, 0, 0, 10, 10)

		conn(box.FocusLost, function(enter)
			if enter and opts.callback then opts.callback(box.Text) end
		end)

		if opts.callback then
			conn(box:GetPropertyChangedSignal("Text"), function()
				opts.callback(box.Text)
			end)
		end

		local el = {
			type = "Input",
			tab = tab,
			instance = row,
			_bg = box,
			_label = fieldLabel,
			GetValue = function() return box.Text end,
			SetValue = function(_, v) box.Text = v end,
			_applyTheme = function(_, t)
				box.BackgroundColor3 = t.elementColor
				box.TextColor3 = t.textColor
				box.PlaceholderColor3 = t.subTextColor
				if fieldLabel then fieldLabel.TextColor3 = t.textColor end
			end,
		}
		return self:_registerElement(el)
	end

	-- ─── AddSlider ───────────────────────────────────────────────────────────

	function menu:AddSlider(opts)
		opts = opts or {}
		local tab = opts.tab or self._tabNames[1]
		local theme = self:_getTheme()
		local minVal = opts.min or 0
		local maxVal = opts.max or 100
		local value = math.clamp(opts.value or minVal, minVal, maxVal)
		local h = math.max(MIN_TOUCH, theme.elementHeight + 8)

		local row = self:_makeRow(tab, h)
		local card = addThemedCard(row, theme, h)

		local lbl = self:_makeLabel(card, opts.text or "Slider", 13, theme.textColor, false)
		lbl.Size = UDim2.new(0.6, 0, 0, 20)
		lbl.Position = UDim2.new(0, 12, 0, 6)

		local valLbl = self:_makeLabel(card, tostring(value), 13, theme.accentColor, true)
		valLbl.Size = UDim2.new(0.3, 0, 0, 20)
		valLbl.Position = UDim2.new(0.7, -12, 0, 6)
		valLbl.TextXAlignment = Enum.TextXAlignment.Right

		local track = Instance.new("Frame")
		track.Name = "Track"
		track.Size = UDim2.new(1, -24, 0, 6)
		track.Position = UDim2.new(0, 12, 1, -16)
		track.BackgroundColor3 = theme.strokeColor
		track.BorderSizePixel = 0
		track.Parent = card
		addCorner(track, 3)

		local fill = Instance.new("Frame")
		fill.Name = "Fill"
		fill.Size = UDim2.new((value - minVal) / (maxVal - minVal), 0, 1, 0)
		fill.BackgroundColor3 = theme.accentColor
		fill.BorderSizePixel = 0
		fill.Parent = track
		addCorner(fill, 3)

		local knob = Instance.new("Frame")
		knob.Name = "Knob"
		knob.Size = UDim2.new(0, 16, 0, 16)
		knob.AnchorPoint = Vector2.new(0.5, 0.5)
		knob.Position = UDim2.new((value - minVal) / (maxVal - minVal), 0, 0.5, 0)
		knob.BackgroundColor3 = theme.knobColor
		knob.BorderSizePixel = 0
		knob.ZIndex = 2
		knob.Parent = track
		addCorner(knob, 8)

		local dragging = false

		local function setValue(v, fireCb)
			value = math.clamp(math.floor(v + 0.5), minVal, maxVal)
			local pct = (value - minVal) / (maxVal - minVal)
			fill.Size = UDim2.new(pct, 0, 1, 0)
			knob.Position = UDim2.new(pct, 0, 0.5, 0)
			valLbl.Text = tostring(value)
			if fireCb ~= false and opts.callback then opts.callback(value) end
		end

		local function updateFromInput(input)
			local trackPos = track.AbsolutePosition.X
			local trackSize = track.AbsoluteSize.X
			local pct = math.clamp((input.Position.X - trackPos) / trackSize, 0, 1)
			setValue(minVal + pct * (maxVal - minVal))
		end

		conn(track.InputBegan, function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				updateFromInput(input)
			end
		end)

		conn(knob.InputBegan, function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
			end
		end)

		conn(UserInputService.InputChanged, function(input)
			if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				updateFromInput(input)
			end
		end)

		conn(UserInputService.InputEnded, function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = false
			end
		end)

		local el = {
			type = "Slider",
			tab = tab,
			instance = row,
			_bg = card,
			_label = lbl,
			_valLabel = valLbl,
			_track = track,
			_fill = fill,
			_knob = knob,
			GetValue = function() return value end,
			SetValue = function(_, v) setValue(v) end,
			_applyTheme = function(_, t)
				card.BackgroundColor3 = t.elementColor
				lbl.TextColor3 = t.textColor
				valLbl.TextColor3 = t.accentColor
				track.BackgroundColor3 = t.strokeColor
				fill.BackgroundColor3 = t.accentColor
				knob.BackgroundColor3 = t.knobColor
			end,
		}
		return self:_registerElement(el)
	end

	-- ─── Dropdown core ───────────────────────────────────────────────────────

	local function createDropdown(menu, opts, isMulti)
		opts = opts or {}
		local tab = opts.tab or menu._tabNames[1]
		local theme = menu:_getTheme()
		local h = math.max(MIN_TOUCH, theme.elementHeight)
		local list = opts.list or {}
		local selected
		if isMulti then
			selected = {}
			if type(opts.value) == "table" then
				for _, v in ipairs(opts.value) do
					for _, item in ipairs(list) do
						if item == v then
							table.insert(selected, v)
							break
						end
					end
				end
			end
		else
			selected = normalizeDropdownValue(opts.value, list)
		end

		local row = menu:_makeRow(tab, h)
		row.ClipsDescendants = false

		local container = Instance.new("Frame")
		container.Name = isMulti and "MultiDropdown" or "Dropdown"
		container.Size = UDim2.new(1, 0, 1, 0)
		container.BackgroundColor3 = theme.elementColor
		container.BackgroundTransparency = 0
		container.BorderSizePixel = 0
		container.ClipsDescendants = true
		container.ZIndex = 1
		container.Parent = row
		addCorner(container, theme.cornerRadius)

		local lbl = menu:_makeLabel(container, opts.text or "Select", 13, theme.textColor, false)
		lbl.Size = UDim2.new(0.4, 0, 1, 0)
		lbl.Position = UDim2.new(0, 12, 0, 0)
		lbl.ZIndex = 2

		local displayBtn = Instance.new("TextButton")
		displayBtn.Name = "Display"
		displayBtn.Size = UDim2.new(0.55, -8, 0, math.max(28, h - 8))
		displayBtn.Position = UDim2.new(0.43, 0, 0.5, 0)
		displayBtn.AnchorPoint = Vector2.new(0, 0.5)
		displayBtn.BackgroundColor3 = theme.contentColor
		displayBtn.TextColor3 = theme.textColor
		displayBtn.TextSize = 13
		displayBtn.Font = Enum.Font.GothamMedium
		displayBtn.BorderSizePixel = 0
		displayBtn.AutoButtonColor = false
		displayBtn.Active = true
		displayBtn.ZIndex = 2
		displayBtn.ClipsDescendants = true
		displayBtn.Parent = container
		addCorner(displayBtn, 6)

		local arrow = menu:_makeLabel(displayBtn, "▼", 10, theme.subTextColor, false)
		arrow.Size = UDim2.new(0, 16, 1, 0)
		arrow.Position = UDim2.new(1, -18, 0, 0)
		arrow.TextXAlignment = Enum.TextXAlignment.Center
		arrow.ZIndex = 3

		local listFrame = Instance.new("Frame")
		listFrame.Name = "List"
		listFrame.Size = UDim2.new(0, 0, 0, 0)
		listFrame.BackgroundColor3 = theme.contentColor
		listFrame.BorderSizePixel = 0
		listFrame.ClipsDescendants = true
		listFrame.Visible = false
		listFrame.ZIndex = 50
		listFrame.Parent = menu._gui.dropdownOverlay
		addCorner(listFrame, 8)
		addPadding(listFrame, 4, 4, 4, 4)

		local listScroll = Instance.new("ScrollingFrame")
		listScroll.Name = "ListScroll"
		listScroll.Size = UDim2.new(1, 0, 1, 0)
		listScroll.BackgroundTransparency = 1
		listScroll.BorderSizePixel = 0
		listScroll.ScrollBarThickness = 4
		listScroll.ScrollBarImageColor3 = theme.accentColor
		listScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
		listScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
		listScroll.ScrollingDirection = Enum.ScrollingDirection.Y
		listScroll.ClipsDescendants = true
		listScroll.ZIndex = 51
		listScroll.Parent = listFrame

		local listLayout = addList(listScroll, 2)

		local itemButtons = {}
		local isOpen = false
		local maxListHeight = math.min(#list * 34 + 8, 180)

		local listWidth = 0

		local dd = {
			_container = container,
			_listFrame = listFrame,
			_displayBtn = displayBtn,
			_isOpen = false,
		}

		local function positionList()
			local btnPos = displayBtn.AbsolutePosition
			local btnSize = displayBtn.AbsoluteSize
			local overlayPos = menu._gui.dropdownOverlay.AbsolutePosition
			listWidth = btnSize.X
			listFrame.Position = UDim2.new(0, btnPos.X - overlayPos.X, 0, btnPos.Y - overlayPos.Y + btnSize.Y + 4)
		end

		local function updateDisplay()
			if isMulti then
				if #selected == 0 then
					displayBtn.Text = "None"
				else
					displayBtn.Text = table.concat(selected, ", ")
				end
			else
				if selected == nil or selected == "" then
					displayBtn.Text = list[1] ~= nil and tostring(list[1]) or "—"
				else
					displayBtn.Text = tostring(selected)
				end
			end
		end

		local function refreshChecks()
			for item, btn in pairs(itemButtons) do
				local checked = false
				if isMulti then
					for _, s in ipairs(selected) do
						if s == item then checked = true break end
					end
				else
					checked = (item == selected)
				end
				local check = btn:FindFirstChild("Check")
				if check then
					check.Text = checked and "✓" or ""
					check.TextColor3 = menu:_getTheme().accentColor
				end
			end
		end

		function dd:Close()
			if not isOpen then return end
			isOpen = false
			self._isOpen = false
			if menu._openDropdown == self then
				menu._openDropdown = nil
			end
			tween(listFrame, { Size = UDim2.new(0, listWidth, 0, 0) }, TWEEN_OPEN):Play()
			task.delay(0.2, function()
				if listFrame.Parent then
					listFrame.Visible = false
				end
			end)
			arrow.Text = "▼"
		end

		function dd:Open()
			menu:_closeOpenDropdown(self)
			menu:_closeOpenColorPicker()
			menu:_cancelActiveKeybind()
			isOpen = true
			self._isOpen = true
			menu._openDropdown = self
			positionList()
			listFrame.Visible = true
			listFrame.Size = UDim2.new(0, listWidth, 0, 0)
			tween(listFrame, { Size = UDim2.new(0, listWidth, 0, maxListHeight) }, TWEEN_OPEN):Play()
			arrow.Text = "▲"
			refreshChecks()
		end

		function dd:Toggle()
			if isOpen then self:Close() else self:Open() end
		end

		for _, item in ipairs(list) do
			local itemBtn = Instance.new("TextButton")
			itemBtn.Name = tostring(item)
			itemBtn.Size = UDim2.new(1, -4, 0, 30)
			itemBtn.BackgroundColor3 = theme.elementColor
			itemBtn.Text = "  " .. tostring(item)
			itemBtn.TextColor3 = theme.textColor
			itemBtn.TextSize = 13
			itemBtn.Font = Enum.Font.GothamMedium
			itemBtn.TextXAlignment = Enum.TextXAlignment.Left
			itemBtn.BorderSizePixel = 0
			itemBtn.AutoButtonColor = false
			itemBtn.Active = true
			itemBtn.ZIndex = 51
			itemBtn.Parent = listScroll
			addCorner(itemBtn, 4)

			local check = Instance.new("TextLabel")
			check.Name = "Check"
			check.Size = UDim2.new(0, 20, 1, 0)
			check.Position = UDim2.new(1, -22, 0, 0)
			check.BackgroundTransparency = 1
			check.Text = ""
			check.TextColor3 = theme.accentColor
			check.TextSize = 14
			check.Font = Enum.Font.GothamBold
			check.ZIndex = 52
			check.Parent = itemBtn

			itemButtons[item] = itemBtn

			conn(itemBtn.MouseButton1Click, function()
				if isMulti then
					local found = false
					for i, s in ipairs(selected) do
						if s == item then
							table.remove(selected, i)
							found = true
							break
						end
					end
					if not found then
						table.insert(selected, item)
					end
					updateDisplay()
					refreshChecks()
					if opts.callback then
						local copy = {}
						for _, v in ipairs(selected) do table.insert(copy, v) end
						opts.callback(copy)
					end
				else
					selected = item
					updateDisplay()
					refreshChecks()
					dd:Close()
					if opts.callback then opts.callback(selected) end
				end
			end)

			conn(itemBtn.MouseEnter, function()
				tween(itemBtn, { BackgroundColor3 = menu:_getTheme().hoverColor }):Play()
			end)
			conn(itemBtn.MouseLeave, function()
				tween(itemBtn, { BackgroundColor3 = menu:_getTheme().elementColor }):Play()
			end)
		end

		updateDisplay()
		refreshChecks()

		conn(displayBtn.MouseButton1Click, function()
			dd:Toggle()
		end)

		local el = {
			type = isMulti and "MultiDropdown" or "Dropdown",
			tab = tab,
			instance = row,
			_bg = container,
			_label = lbl,
			_dropdown = dd,
			GetValue = function()
				if isMulti then
					local copy = {}
					for _, v in ipairs(selected) do table.insert(copy, v) end
					return copy
				end
				if selected == nil then
					return normalizeDropdownValue(nil, list)
				end
				return selected
			end,
			SetValue = function(_, v)
				if isMulti then
					selected = {}
					if type(v) == "table" then
						for _, item in ipairs(v) do
							for _, allowed in ipairs(list) do
								if allowed == item then
									table.insert(selected, item)
									break
								end
							end
						end
					end
				else
					selected = normalizeDropdownValue(v, list)
				end
				updateDisplay()
				refreshChecks()
				if opts.callback then
					if isMulti then
						local copy = {}
						for _, item in ipairs(selected) do table.insert(copy, item) end
						opts.callback(copy)
					else
						opts.callback(selected)
					end
				end
			end,
			Close = function() dd:Close() end,
			_applyTheme = function(_, t)
				container.BackgroundColor3 = t.elementColor
				lbl.TextColor3 = t.textColor
				displayBtn.BackgroundColor3 = t.contentColor
				displayBtn.TextColor3 = t.textColor
				arrow.TextColor3 = t.subTextColor
				listFrame.BackgroundColor3 = t.contentColor
				listScroll.ScrollBarImageColor3 = t.accentColor
				for _, btn in pairs(itemButtons) do
					btn.BackgroundColor3 = t.elementColor
					btn.TextColor3 = t.textColor
					local check = btn:FindFirstChild("Check")
					if check then check.TextColor3 = t.accentColor end
				end
				refreshChecks()
			end,
		}
		return menu:_registerElement(el)
	end

	function menu:AddDropdown(opts)
		return createDropdown(self, opts, false)
	end

	function menu:AddMultiDropdown(opts)
		return createDropdown(self, opts, true)
	end

	-- ─── AddKeybind ──────────────────────────────────────────────────────────

	function menu:AddKeybind(opts)
		opts = opts or {}
		local tab = opts.tab or self._tabNames[1]
		local theme = self:_getTheme()
		local h = math.max(MIN_TOUCH, theme.elementHeight)
		local currentKey = opts.key

		local row = self:_makeRow(tab, h)
		local card = addThemedCard(row, theme, h)

		local lbl = self:_makeLabel(card, opts.text or "Keybind", 14, theme.textColor, false)
		lbl.Size = UDim2.new(1, -100, 1, 0)
		lbl.Position = UDim2.new(0, 12, 0, 0)

		local keyBtn = Instance.new("TextButton")
		keyBtn.Name = "KeyButton"
		keyBtn.Size = UDim2.new(0, 84, 0, 28)
		keyBtn.Position = UDim2.new(1, -92, 0.5, -14)
		keyBtn.BackgroundColor3 = theme.contentColor
		keyBtn.Text = formatKeyName(currentKey)
		keyBtn.TextColor3 = theme.textColor
		keyBtn.TextSize = 12
		keyBtn.Font = Enum.Font.GothamBold
		keyBtn.BorderSizePixel = 0
		keyBtn.AutoButtonColor = false
		keyBtn.Active = true
		keyBtn.ClipsDescendants = true
		keyBtn.Parent = card
		addCorner(keyBtn, 6)
		local keyStroke = addStroke(keyBtn, theme.strokeColor, 1, 0.3)

		local listening = false

		local kb = {
			_listening = false,
		}

		local function updateDisplay()
			keyBtn.Text = listening and "..." or formatKeyName(currentKey)
		end

		local function setListenState(active)
			listening = active
			kb._listening = active
			local t = self:_getTheme()
			if active then
				self:_cancelActiveKeybind(kb)
				self._activeKeybind = kb
				self:_closeOpenDropdown()
				self:_closeOpenColorPicker()
				keyStroke.Color = t.accentColor
				tween(keyBtn, { BackgroundColor3 = t.hoverColor }):Play()
			else
				if self._activeKeybind == kb then
					self._activeKeybind = nil
				end
				keyStroke.Color = t.strokeColor
				tween(keyBtn, { BackgroundColor3 = t.contentColor }):Play()
			end
			updateDisplay()
		end

		local function setKey(keyCode, fireCb)
			currentKey = keyCode
			updateDisplay()
			if fireCb ~= false and opts.callback then
				opts.callback(currentKey)
			end
		end

		function kb:SetKey(keyCode)
			setKey(keyCode)
		end

		function kb:CancelListen()
			setListenState(false)
		end

		function kb:StartListen()
			setListenState(true)
		end

		conn(keyBtn.MouseButton1Click, function()
			if listening then
				kb:CancelListen()
			else
				kb:StartListen()
			end
		end)

		local el = {
			type = "Keybind",
			tab = tab,
			instance = row,
			_bg = card,
			_label = lbl,
			_keybind = kb,
			GetValue = function() return currentKey end,
			SetValue = function(_, keyCode) setKey(keyCode) end,
			CancelListen = function() kb:CancelListen() end,
			_applyTheme = function(_, t)
				card.BackgroundColor3 = t.elementColor
				lbl.TextColor3 = t.textColor
				if not listening then
					keyBtn.BackgroundColor3 = t.contentColor
					keyStroke.Color = t.strokeColor
				else
					keyStroke.Color = t.accentColor
				end
				keyBtn.TextColor3 = t.textColor
			end,
		}
		return self:_registerElement(el)
	end

	-- ─── AddColorPicker ──────────────────────────────────────────────────────

	function menu:AddColorPicker(opts)
		opts = opts or {}
		local tab = opts.tab or self._tabNames[1]
		local theme = self:_getTheme()
		local h = math.max(MIN_TOUCH, theme.elementHeight)
		local color = opts.value or Color3.fromRGB(255, 255, 255)
		local hue, sat, val = color:ToHSV()

		local row = self:_makeRow(tab, h)
		row.ClipsDescendants = false

		local container = Instance.new("Frame")
		container.Name = "ColorPicker"
		container.Size = UDim2.new(1, 0, 1, 0)
		container.BackgroundColor3 = theme.elementColor
		container.BorderSizePixel = 0
		container.ClipsDescendants = true
		container.ZIndex = 1
		container.Parent = row
		addCorner(container, theme.cornerRadius)

		local lbl = self:_makeLabel(container, opts.text or "Color", 13, theme.textColor, false)
		lbl.Size = UDim2.new(0.42, 0, 1, 0)
		lbl.Position = UDim2.new(0, 12, 0, 0)
		lbl.ZIndex = 2

		local previewBtn = Instance.new("TextButton")
		previewBtn.Name = "Preview"
		previewBtn.Size = UDim2.new(0.52, -8, 0, math.max(28, h - 8))
		previewBtn.Position = UDim2.new(0.46, 0, 0.5, 0)
		previewBtn.AnchorPoint = Vector2.new(0, 0.5)
		previewBtn.BackgroundColor3 = color
		previewBtn.Text = colorToHex(color)
		previewBtn.TextColor3 = (color.R * 0.299 + color.G * 0.587 + color.B * 0.114) > 0.55
			and Color3.new(0, 0, 0) or Color3.new(1, 1, 1)
		previewBtn.TextSize = 12
		previewBtn.Font = Enum.Font.GothamBold
		previewBtn.BorderSizePixel = 0
		previewBtn.AutoButtonColor = false
		previewBtn.Active = true
		previewBtn.ZIndex = 2
		previewBtn.ClipsDescendants = true
		previewBtn.Parent = container
		addCorner(previewBtn, 6)
		addStroke(previewBtn, theme.strokeColor, 1, 0.35)

		local panel = Instance.new("Frame")
		panel.Name = "Panel"
		panel.Size = UDim2.new(0, 220, 0, 0)
		panel.BackgroundColor3 = theme.contentColor
		panel.BorderSizePixel = 0
		panel.ClipsDescendants = true
		panel.Visible = false
		panel.ZIndex = 60
		panel.Parent = menu._gui.dropdownOverlay
		addCorner(panel, 10)
		local panelStroke = addStroke(panel, theme.strokeColor, 1, 0.2)

		local panelList = addList(panel, 8)
		addPadding(panel, 10, 10, 10, 10)

		local previewBar = Instance.new("Frame")
		previewBar.Name = "PreviewBar"
		previewBar.Size = UDim2.new(1, 0, 0, 24)
		previewBar.BackgroundColor3 = color
		previewBar.BorderSizePixel = 0
		previewBar.LayoutOrder = 1
		previewBar.ZIndex = 61
		previewBar.Parent = panel
		addCorner(previewBar, 6)

		local sbArea = Instance.new("Frame")
		sbArea.Name = "SBArea"
		sbArea.Size = UDim2.new(1, 0, 0, 100)
		sbArea.BackgroundTransparency = 1
		sbArea.LayoutOrder = 2
		sbArea.ZIndex = 61
		sbArea.Parent = panel

		local sbBg = Instance.new("Frame")
		sbBg.Name = "HueBase"
		sbBg.Size = UDim2.new(1, 0, 1, 0)
		sbBg.BorderSizePixel = 0
		sbBg.ZIndex = 61
		sbBg.Parent = sbArea
		addCorner(sbBg, 6)

		local satOverlay = Instance.new("Frame")
		satOverlay.Size = UDim2.new(1, 0, 1, 0)
		satOverlay.BackgroundColor3 = Color3.new(1, 1, 1)
		satOverlay.BorderSizePixel = 0
		satOverlay.ZIndex = 62
		satOverlay.Parent = sbBg
		addCorner(satOverlay, 6)
		local satGrad = Instance.new("UIGradient")
		satGrad.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(1, 1),
		})
		satGrad.Parent = satOverlay

		local valOverlay = Instance.new("Frame")
		valOverlay.Size = UDim2.new(1, 0, 1, 0)
		valOverlay.BackgroundColor3 = Color3.new(0, 0, 0)
		valOverlay.BorderSizePixel = 0
		valOverlay.ZIndex = 63
		valOverlay.Parent = sbBg
		addCorner(valOverlay, 6)
		local valGrad = Instance.new("UIGradient")
		valGrad.Rotation = 90
		valGrad.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(1, 0),
		})
		valGrad.Parent = valOverlay

		local sbCursor = Instance.new("Frame")
		sbCursor.Name = "SBCursor"
		sbCursor.Size = UDim2.new(0, 12, 0, 12)
		sbCursor.AnchorPoint = Vector2.new(0.5, 0.5)
		sbCursor.BackgroundColor3 = Color3.new(1, 1, 1)
		sbCursor.BorderSizePixel = 0
		sbCursor.ZIndex = 64
		sbCursor.Parent = sbBg
		addCorner(sbCursor, 6)
		addStroke(sbCursor, Color3.new(0, 0, 0), 1, 0.4)

		local hueTrack = Instance.new("Frame")
		hueTrack.Name = "HueTrack"
		hueTrack.Size = UDim2.new(1, 0, 0, 12)
		hueTrack.BackgroundColor3 = Color3.new(1, 1, 1)
		hueTrack.BorderSizePixel = 0
		hueTrack.LayoutOrder = 3
		hueTrack.ZIndex = 61
		hueTrack.Parent = panel
		addCorner(hueTrack, 6)
		local hueGrad = Instance.new("UIGradient")
		hueGrad.Color = HUE_GRADIENT
		hueGrad.Parent = hueTrack

		local hueCursor = Instance.new("Frame")
		hueCursor.Name = "HueCursor"
		hueCursor.Size = UDim2.new(0, 4, 1, 4)
		hueCursor.AnchorPoint = Vector2.new(0.5, 0.5)
		hueCursor.Position = UDim2.new(hue, 0, 0.5, 0)
		hueCursor.BackgroundColor3 = Color3.new(1, 1, 1)
		hueCursor.BorderSizePixel = 0
		hueCursor.ZIndex = 62
		hueCursor.Parent = hueTrack
		addCorner(hueCursor, 2)
		addStroke(hueCursor, Color3.new(0, 0, 0), 1, 0.3)

		local infoLbl = self:_makeLabel(panel, colorToRgbText(color), 11, theme.subTextColor, false)
		infoLbl.Size = UDim2.new(1, 0, 0, 16)
		infoLbl.LayoutOrder = 4
		infoLbl.TextXAlignment = Enum.TextXAlignment.Center
		infoLbl.ZIndex = 61

		local isOpen = false
		local draggingSB = false
		local draggingHue = false
		local panelHeight = 188

		local cp = {
			_container = container,
			_panel = panel,
			_isOpen = false,
		}

		local function updateFromHsv(fireCb)
			color = Color3.fromHSV(hue, sat, val)
			sbBg.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
			sbCursor.Position = UDim2.new(sat, 0, 1 - val, 0)
			hueCursor.Position = UDim2.new(hue, 0, 0.5, 0)
			previewBar.BackgroundColor3 = color
			previewBtn.BackgroundColor3 = color
			previewBtn.Text = colorToHex(color)
			previewBtn.TextColor3 = (color.R * 0.299 + color.G * 0.587 + color.B * 0.114) > 0.55
				and Color3.new(0, 0, 0) or Color3.new(1, 1, 1)
			infoLbl.Text = colorToRgbText(color)
			if fireCb ~= false and opts.callback then
				opts.callback(color)
			end
		end

		local function positionPanel()
			local btnPos = previewBtn.AbsolutePosition
			local btnSize = previewBtn.AbsoluteSize
			local overlayPos = menu._gui.dropdownOverlay.AbsolutePosition
			panel.Position = UDim2.new(
				0,
				btnPos.X - overlayPos.X,
				0,
				btnPos.Y - overlayPos.Y + btnSize.Y + 4
			)
		end

		function cp:Close()
			if not isOpen then return end
			isOpen = false
			self._isOpen = false
			if menu._openColorPicker == self then
				menu._openColorPicker = nil
			end
			tween(panel, { Size = UDim2.new(0, 220, 0, 0) }, TWEEN_OPEN):Play()
			task.delay(0.2, function()
				if panel.Parent then
					panel.Visible = false
				end
			end)
		end

		function cp:Open()
			menu:_closeOpenColorPicker(self)
			menu:_closeOpenDropdown()
			menu:_cancelActiveKeybind()
			isOpen = true
			self._isOpen = true
			menu._openColorPicker = self
			positionPanel()
			panel.Visible = true
			panel.Size = UDim2.new(0, 220, 0, 0)
			updateFromHsv(false)
			tween(panel, { Size = UDim2.new(0, 220, 0, panelHeight) }, TWEEN_OPEN):Play()
		end

		function cp:Toggle()
			if isOpen then self:Close() else self:Open() end
		end

		local function updateSBFromInput(input)
			local pos = sbBg.AbsolutePosition
			local size = sbBg.AbsoluteSize
			sat = math.clamp((input.Position.X - pos.X) / size.X, 0, 1)
			val = 1 - math.clamp((input.Position.Y - pos.Y) / size.Y, 0, 1)
			updateFromHsv()
		end

		local function updateHueFromInput(input)
			local pos = hueTrack.AbsolutePosition
			local size = hueTrack.AbsoluteSize
			hue = math.clamp((input.Position.X - pos.X) / size.X, 0, 1)
			updateFromHsv()
		end

		conn(sbBg.InputBegan, function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				draggingSB = true
				updateSBFromInput(input)
			end
		end)

		conn(hueTrack.InputBegan, function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				draggingHue = true
				updateHueFromInput(input)
			end
		end)

		conn(UserInputService.InputChanged, function(input)
			if draggingSB and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				updateSBFromInput(input)
			elseif draggingHue and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				updateHueFromInput(input)
			end
		end)

		conn(UserInputService.InputEnded, function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				draggingSB = false
				draggingHue = false
			end
		end)

		conn(previewBtn.MouseButton1Click, function()
			cp:Toggle()
		end)

		updateFromHsv(false)

		local el = {
			type = "ColorPicker",
			tab = tab,
			instance = row,
			_bg = container,
			_label = lbl,
			_picker = cp,
			GetValue = function() return color end,
			SetValue = function(_, newColor)
				if typeof(newColor) ~= "Color3" then return end
				color = newColor
				hue, sat, val = color:ToHSV()
				updateFromHsv(false)
			end,
			Close = function() cp:Close() end,
			_applyTheme = function(_, t)
				container.BackgroundColor3 = t.elementColor
				lbl.TextColor3 = t.textColor
				panel.BackgroundColor3 = t.contentColor
				panelStroke.Color = t.strokeColor
				infoLbl.TextColor3 = t.subTextColor
			end,
		}
		return self:_registerElement(el)
	end

	-- ─── AddTheme ────────────────────────────────────────────────────────────

	function menu:AddTheme(opts)
		opts = opts or {}
		local name = opts.name
		if not name then return end
		local base = deepCopy(self:_getTheme())
		for k, v in pairs(opts) do
			base[k] = v
		end
		base.name = name
		self._themes[name] = base
		return base
	end

	-- ─── Notify ──────────────────────────────────────────────────────────────

	function menu:Notify(opts)
		opts = opts or {}
		if self._destroyed then return end

		local title = opts.title or "Notification"
		local text = opts.text or ""
		local duration = opts.duration or 3
		local theme = self:_getTheme()
		local stack = self._gui.notifyStack

		local padTop, padBottom, padLeft, padRight = 10, 10, 10, 14
		local rowGap = 8
		local accentWidth = 4
		local textGap = 4
		local textWidth = NOTIFY_WIDTH - padLeft - padRight - accentWidth - rowGap
		local contentLeft = padLeft + accentWidth + rowGap

		local function computeHeights()
			local titleHeight = measureWrappedText(title, textWidth, 15, Enum.Font.GothamBold)
			local textHeight = text ~= "" and measureWrappedText(text, textWidth, 13, Enum.Font.GothamMedium) or 0
			local contentHeight = titleHeight + (text ~= "" and (textGap + textHeight) or 0)
			local cardHeight = padTop + padBottom + contentHeight
			return titleHeight, textHeight, contentHeight, cardHeight
		end

		local titleHeight, textHeight, contentHeight, cardHeight = computeHeights()

		local wrapper = Instance.new("Frame")
		wrapper.Name = "NotifyWrapper"
		wrapper.Size = UDim2.fromOffset(NOTIFY_WIDTH, cardHeight)
		wrapper.BackgroundTransparency = 1
		wrapper.ClipsDescendants = true
		wrapper.Parent = stack

		local card = Instance.new("Frame")
		card.Name = "NotifyCard"
		card.Size = UDim2.fromOffset(NOTIFY_WIDTH, cardHeight)
		card.BackgroundColor3 = theme.elementColor
		card.BackgroundTransparency = 1
		card.BorderSizePixel = 0
		card.Position = UDim2.new(0, 0, 0, 16)
		card.ClipsDescendants = true
		card.Parent = wrapper
		addCorner(card, theme.cornerRadius or 10)
		addGradient(card, theme.elementColor, theme.backgroundColor2, 145)
		addStroke(card, theme.strokeColor, 1, 0.35)

		local sizeConstraint = Instance.new("UISizeConstraint")
		sizeConstraint.MaxSize = Vector2.new(NOTIFY_WIDTH, NOTIFY_MAX_HEIGHT)
		sizeConstraint.Parent = card

		local accentBar = Instance.new("Frame")
		accentBar.Name = "Accent"
		accentBar.Size = UDim2.new(0, accentWidth, 1, -(padTop + padBottom))
		accentBar.Position = UDim2.fromOffset(padLeft, padTop)
		accentBar.BackgroundColor3 = theme.accentColor
		accentBar.BorderSizePixel = 0
		accentBar.ZIndex = 2
		accentBar.Parent = card
		addCorner(accentBar, 2)
		addGradient(accentBar, theme.accentColor, theme.accentColor2, 90)

		local content = Instance.new("Frame")
		content.Name = "Content"
		content.Size = UDim2.fromOffset(textWidth, contentHeight)
		content.Position = UDim2.fromOffset(contentLeft, padTop)
		content.BackgroundTransparency = 1
		content.ZIndex = 2
		content.Parent = card
		addList(content, textGap)

		local titleLbl = Instance.new("TextLabel")
		titleLbl.Name = "Title"
		titleLbl.Size = UDim2.fromOffset(textWidth, titleHeight)
		titleLbl.BackgroundTransparency = 1
		titleLbl.Text = title
		titleLbl.TextColor3 = theme.textColor
		titleLbl.TextSize = 15
		titleLbl.Font = Enum.Font.GothamBold
		titleLbl.TextXAlignment = Enum.TextXAlignment.Left
		titleLbl.TextYAlignment = Enum.TextYAlignment.Top
		titleLbl.TextWrapped = true
		titleLbl.TextTransparency = 1
		titleLbl.LayoutOrder = 1
		titleLbl.Parent = content

		local textLbl = Instance.new("TextLabel")
		textLbl.Name = "Text"
		textLbl.Size = UDim2.fromOffset(textWidth, textHeight)
		textLbl.BackgroundTransparency = 1
		textLbl.Text = text
		textLbl.TextColor3 = theme.subTextColor
		textLbl.TextSize = 13
		textLbl.Font = Enum.Font.GothamMedium
		textLbl.TextXAlignment = Enum.TextXAlignment.Left
		textLbl.TextYAlignment = Enum.TextYAlignment.Top
		textLbl.TextWrapped = true
		textLbl.TextTransparency = 1
		textLbl.LayoutOrder = 2
		textLbl.Visible = text ~= ""
		textLbl.Parent = content

		local function applyNotifySizes()
			if not wrapper.Parent then
				return
			end
			local newTitleHeight, newTextHeight, newContentHeight, newCardHeight = computeHeights()
			wrapper.Size = UDim2.fromOffset(NOTIFY_WIDTH, newCardHeight)
			card.Size = UDim2.fromOffset(NOTIFY_WIDTH, newCardHeight)
			content.Size = UDim2.fromOffset(textWidth, newContentHeight)
			content.Position = UDim2.fromOffset(contentLeft, padTop)
			titleLbl.Size = UDim2.fromOffset(textWidth, newTitleHeight)
			if text ~= "" then
				textLbl.Size = UDim2.fromOffset(textWidth, newTextHeight)
			end
		end

		task.defer(applyNotifySizes)

		local handle = {
			_dismissed = false,
			_wrapper = wrapper,
			_card = card,
			_titleLbl = titleLbl,
			_textLbl = textLbl,
		}

		local menuRef = menu

		local function removeFromList()
			for i, h in ipairs(menuRef._notifications) do
				if h == handle then
					table.remove(menuRef._notifications, i)
					break
				end
			end
		end

		function handle:Dismiss()
			if self._dismissed or not self._wrapper.Parent then return end
			self._dismissed = true
			local outTween = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
			tween(self._card, { BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 16) }, outTween):Play()
			tween(self._titleLbl, { TextTransparency = 1 }, outTween):Play()
			if self._textLbl.Visible then
				tween(self._textLbl, { TextTransparency = 1 }, outTween):Play()
			end
			task.delay(0.2, function()
				if self._wrapper and self._wrapper.Parent then
					self._wrapper:Destroy()
				end
			end)
			removeFromList()
		end

		table.insert(menuRef._notifications, handle)

		tween(card, { BackgroundTransparency = 0.05, Position = UDim2.new(0, 0, 0, 0) }, TWEEN_OPEN):Play()
		tween(titleLbl, { TextTransparency = 0 }, TWEEN_OPEN):Play()
		if text ~= "" then
			tween(textLbl, { TextTransparency = 0 }, TWEEN_OPEN):Play()
		end

		task.delay(duration, function()
			if not handle._dismissed and not menuRef._destroyed then
				handle:Dismiss()
			end
		end)

		return handle
	end

	-- ─── GetElements / Destroy ───────────────────────────────────────────────

	function menu:GetElements()
		return self._elements
	end

	function menu:Destroy()
		if self._destroyed then return end
		self._destroyed = true
		if self._notifications then
			for _, h in ipairs(self._notifications) do
				h._dismissed = true
			end
			self._notifications = {}
		end
		if self._openDropdown then
			self._openDropdown:Close()
		end
		if self._openColorPicker then
			self._openColorPicker:Close()
		end
		if self._activeKeybind then
			self._activeKeybind:CancelListen()
		end
		for _, c in ipairs(self._connections) do
			c:Disconnect()
		end
		self._connections = {}
		if self._gui.screenGui then
			self._gui.screenGui:Destroy()
		end
		self._gui = nil
	end

	function menu:Show()
		self:Restore()
	end

	function menu:Hide()
		self:Minimize()
	end

	-- ─── Settings tab defaults ───────────────────────────────────────────────

	function menu:_buildSettingsTab()
		if self._settingsBuilt then return end
		self._settingsBuilt = true

		local themeNames = {}
		for name in pairs(self._themes) do
			table.insert(themeNames, name)
		end
		table.sort(themeNames)

		self:AddPageName({ tab = "Settings", text = "Settings" })
		self:AddSubtitle({ tab = "Settings", text = "Appearance & preferences" })
		self:AddSeparator({ tab = "Settings" })

		self:AddDropdown({
			tab = "Settings",
			text = "Theme",
			list = themeNames,
			value = self._currentTheme,
			callback = function(val)
				self:ApplyTheme(val)
			end,
		})

		self:AddDropdown({
			tab = "Settings",
			text = "Menu Type",
			list = { "Default", "Compact" },
			value = self._menuType,
			callback = function(val)
				self._menuType = val
				local mw = val == "Compact" and 480 or 560
				local mh = val == "Compact" and 380 or 440
				self._mainWidth = mw
				self._mainHeight = mh
				tween(self._gui.mainFrame, {
					Size = UDim2.new(0, mw, 0, mh),
					Position = UDim2.new(0.5, -mw / 2, 0.5, -mh / 2),
				}):Play()
				if self._activeTab then
					task.delay(0.25, function()
						self:_updateTabIndicator(self._activeTab)
					end)
				end
			end,
		})

		self:AddLabel({
			tab = "Settings",
			text = "ErtyHub v" .. self._version,
		})
	end

	function menu:Finish()
		if self._finished then return self end
		self._finished = true
		if not self._tabContents["Settings"] then
			self:_registerTabUI("Settings")
		end
		self:_buildSettingsTab()
		self:ApplyTheme(self._currentTheme)
		return self
	end

	if tabs and #tabs > 0 then
		menu:Finish()
	end

	return menu
end

-- ─── Lib public API ──────────────────────────────────────────────────────────

function Lib:Create(arg1, arg2)
	local initialTabs = {}
	local options = {}

	if type(arg1) == "table" then
		if type(arg1[1]) == "string" then
			initialTabs = arg1
			options = arg2 or {}
		else
			options = arg1
		end
	else
		error("ErtyHub: Create() expects a tabs array or options table", 2)
	end

	return createMenu(self, initialTabs, options)
end

function Lib:AddTheme(opts)
	-- Global theme registration (copied into each new menu)
	local name = opts and opts.name
	if name then
		local base = deepCopy(BUILTIN_THEMES.Dark)
		for k, v in pairs(opts) do base[k] = v end
		base.name = name
		BUILTIN_THEMES[name] = base
	end
end

return Lib
