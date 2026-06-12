# ErtyHub

**ErtyHub** is a lightweight, reusable UI menu framework for Roblox executors and Studio. Build tabbed menus with buttons, toggles, sliders, dropdowns, and more — with built-in themes, drag support, and touch-friendly controls.

| | |
|---|---|
| **Version** | 1.1.0 |
| **Language** | Luau |
| **License** | [MIT](LICENSE) |

## Features

- Tabbed interface with animated indicator and horizontal scroll
- 10+ UI widgets: buttons, toggles, sliders, inputs, dropdowns, labels, separators, titles
- 3 built-in themes: **Dark**, **Light**, **Neon** — plus custom theme support
- Draggable title bar, minimize/restore floating button, close button
- Auto-generated **Settings** tab (theme picker + compact mode)
- Touch and mouse input support
- Runtime API: `GetValue`, `SetValue`, `SetText` on elements
- Single-file library — load via `HttpGet` or `require`

## Quick Start (Executor)

```lua
local Lib = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/ErtyHubCheats/ErtyHubLibNew/main/src/ErtyHub.lua"
))()

local menu = Lib:Create({
    title = "My Script",
    name = "MyScriptMenu",
})

local tab = menu:AddTab("Main")

tab:AddPageName({ text = "Main" })
tab:AddButton({
    text = "Hello",
    callback = function()
        print("Button clicked!")
    end,
})

menu:Finish()
```

Raw URL points to [ErtyHubCheats/ErtyHubLibNew](https://github.com/ErtyHubCheats/ErtyHubLibNew).

> **Important:** Always call `menu:Finish()` at the end. It creates the Settings tab and applies the current theme.

## Roblox Studio Setup

1. Create a **ScreenGui** in `StarterGui`.
2. Add a **ModuleScript** named `ErtyHub` — paste the contents of [`src/ErtyHub.lua`](src/ErtyHub.lua).
3. Add a **LocalScript**:

```lua
local Lib = require(script.Parent.ErtyHub)

local menu = Lib:Create({ title = "My Menu" })
local tab = menu:AddTab("Home")
tab:AddLabel({ text = "Hello from Studio!" })
menu:Finish()
```

## Full Example

See [`examples/MenuDemo.lua`](examples/MenuDemo.lua) for a complete demo with two tabs, all widget types, and a custom Neon theme.

## Documentation

| Document | Description |
|----------|-------------|
| [API Reference](docs/API.md) | Full English API documentation |
| [Руководство (RU)](docs/README.ru.md) | Complete Russian user guide |

## Project Structure

```
ErtyHubLibNew/
├── src/
│   └── ErtyHub.lua       # Main library module
├── examples/
│   └── MenuDemo.lua      # Demo script
├── docs/
│   ├── API.md            # API reference (EN)
│   └── README.ru.md      # User guide (RU)
├── LICENSE
└── README.md
```

## Minimal Workflow

```
Lib:Create(options)
  → menu:AddTab("TabName")
    → tab:AddButton / AddToggle / AddSlider / ...
  → menu:AddTheme({ ... })        -- optional
  → menu:Finish()                 -- required
```

## Built-in Themes

| Name | Style |
|------|-------|
| `Dark` | Default dark blue theme |
| `Light` | Light background, dark text |
| `Neon` | Dark background with cyan/purple accents |

Switch themes at runtime via the Settings tab, or programmatically with `menu:SetTheme("Neon")`.

## License

MIT — see [LICENSE](LICENSE).
