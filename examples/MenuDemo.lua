--[[
	ErtyHub Menu Demo
	Full example showing tabs, widgets, and custom themes.

	── Executor (recommended) ──────────────────────────────────────────────
	Copy this file into your executor and run it. Make sure HttpGet is enabled.

	local Lib = loadstring(game:HttpGet(
		"https://raw.githubusercontent.com/ErtyHubCheats/ErtyHubLibNew/main/src/ErtyHub.lua"
	))()
	-- Then paste the rest of this script below the Lib line (skip the require block).

	── Roblox Studio ─────────────────────────────────────────────────────────
	1. Create a ScreenGui in StarterGui.
	2. Add a ModuleScript named "ErtyHub" — paste src/ErtyHub.lua into it.
	3. Add a ModuleScript named "MenuDemo" — paste this file into it.
	4. Add a LocalScript that runs: require(script.Parent.MenuDemo)
]]

-- ─── Load library ────────────────────────────────────────────────────────────

local Lib

if script and script.Parent then
	-- Studio: ModuleScript next to ErtyHub
	local libScript = script.Parent:WaitForChild("ErtyHub")
	Lib = require(libScript)
else
	-- Executor: load from GitHub
	Lib = loadstring(game:HttpGet(
		"https://raw.githubusercontent.com/ErtyHubCheats/ErtyHubLibNew/main/src/ErtyHub.lua"
	))()
end

-- ─── Create menu ─────────────────────────────────────────────────────────────

local menu = Lib:Create({
	title = "ErtyHub Demo",
	name = "ErtyHubDemo",
	version = "2.0.0",
	showVersion = true,
})

menu:AddTheme({
	name = "Neon",
	backgroundColor = Color3.fromRGB(8, 10, 28),
	backgroundColor2 = Color3.fromRGB(16, 12, 42),
	accentColor = Color3.fromRGB(0, 255, 220),
	accentColor2 = Color3.fromRGB(180, 60, 255),
	textColor = Color3.fromRGB(255, 255, 255),
})

-- ─── Main ────────────────────────────────────────────────────────────────────

local TMain = menu:AddTab("Main")

TMain:AddPageName({ text = "Main" })
TMain:AddSubtitle({ text = "Buttons, dropdowns and labels" })
TMain:AddSeparator({})

TMain:AddButton({
	text = "Button",
	callback = function()
		print("[ErtyHub] Clicked!")
	end,
})

TMain:AddButton({
	text = "Show Notify",
	callback = function()
		menu:Notify({
			title = "Hello",
			text = "This notification disappears in 3 seconds.",
			duration = 3,
		})
	end,
})

TMain:AddDropdown({
	text = "Choose option",
	list = { "A", "B", "C" },
	value = "A",
	callback = function(val)
		print("[ErtyHub] Selected:", val)
	end,
})

TMain:AddMultiDropdown({
	text = "Multi-select",
	list = { "X", "Y", "Z" },
	value = { "Y" },
	callback = function(val)
		print("[ErtyHub] Multi:", table.concat(val, ", "))
	end,
})

TMain:AddLabel({
	text = "This is an informational label.",
})

-- ─── Visual ──────────────────────────────────────────────────────────────────

local TVisual = menu:AddTab("Visual")

TVisual:AddPageName({ text = "Visual" })
TVisual:AddSubtitle({ text = "Toggles, sliders and inputs" })
TVisual:AddSeparator({})

TVisual:AddToggle({
	text = "Enable mode",
	state = false,
	callback = function(val)
		print("[ErtyHub] Enabled?", val)
	end,
})

TVisual:AddSlider({
	text = "Brightness",
	min = 0,
	max = 100,
	value = 50,
	callback = function(val)
		print("[ErtyHub] Brightness:", val)
	end,
})

TVisual:AddInput({
	text = "Name",
	placeholder = "Enter your name...",
	value = "",
	callback = function(val)
		print("[ErtyHub] Input:", val)
	end,
})

TVisual:AddKeybind({
	text = "Toggle key",
	key = Enum.KeyCode.RightShift,
	callback = function(keyCode)
		if keyCode then
			print("[ErtyHub] Keybind:", keyCode.Name)
		else
			print("[ErtyHub] Keybind cleared")
		end
	end,
})

TVisual:AddColorPicker({
	text = "Accent color",
	value = Color3.fromRGB(255, 80, 80),
	callback = function(color)
		print("[ErtyHub] Color:", color)
	end,
})

TVisual:AddTitle({ text = "Title Example" })
TVisual:AddSubtitle({ text = "Subtitle below the title" })

-- Settings tab + theme selectors (auto)
menu:Finish()
