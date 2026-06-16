# ErtyHub API Reference

Version **1.2.0**

## Table of Contents

- [Module (Lib)](#module-lib)
- [Creating a Menu](#creating-a-menu)
- [Tabs](#tabs)
- [UI Elements](#ui-elements)
- [Themes](#themes)
- [Notifications](#notifications)
- [Window Control](#window-control)
- [Element Runtime API](#element-runtime-api)
- [Common Options](#common-options)

---

## Module (Lib)

Load the library:

```lua
-- Executor
local Lib = loadstring(game:HttpGet(URL))()

-- Studio
local Lib = require(path.To.ErtyHub)
```

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `Lib.Version` | `string` | Library version (`"1.2.0"`) |
| `Lib.Themes` | `table` | Built-in theme definitions (`Dark`, `Light`, `Neon`) |

### `Lib:Create(arg1, arg2?)`

Creates a new menu instance.

**Signature A — options table (recommended):**

```lua
local menu = Lib:Create({
    title = "My Menu",
    name = "MyMenuGui",
    parent = nil,
    displayOrder = 10,
    version = "1.0.0",
    showVersion = true,
})
```

**Signature B — legacy tab array + options:**

```lua
local menu = Lib:Create({ "Main", "Visual" }, { title = "Legacy" })
```

When using signature B, tabs are pre-registered and `Finish()` is called automatically.

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `title` | `string` | `"ErtyHub"` | Title bar text |
| `name` | `string` | `"ErtyHubMenu"` | `ScreenGui` instance name |
| `parent` | `Instance?` | `PlayerGui` | Parent for the ScreenGui. Falls back to `CoreGui` if no player |
| `displayOrder` | `number` | `10` | ScreenGui display order |
| `version` | `string` | `Lib.Version` | Version text shown in title badge and Settings tab |
| `showVersion` | `boolean` | `true` | Set `false` to hide the version badge |

### `Lib:AddTheme(opts)`

Registers a global theme copied into every **new** menu. Does not affect existing menus.

```lua
Lib:AddTheme({
    name = "Custom",
    accentColor = Color3.fromRGB(255, 100, 50),
})
```

---

## Creating a Menu

### Recommended flow

```lua
local menu = Lib:Create({ title = "Script" })

local tab = menu:AddTab("Combat")
tab:AddToggle({ text = "Aimbot", state = false, callback = function(v) end })

menu:Finish()
```

### `menu:Finish()`

**Required** when using `AddTab()` workflow.

- Creates the **Settings** tab (if not already present)
- Adds theme selector and menu size (Default / Compact) dropdowns
- Applies the current theme to all elements

Safe to call multiple times — subsequent calls are no-ops.

---

## Tabs

### `menu:AddTab(tabName)`

Creates a new tab and returns a **tab proxy** object.

```lua
local tab = menu:AddTab("Main")
```

The proxy exposes the same `Add*` methods as the menu, with `tab` pre-filled:

```lua
tab:AddButton({ text = "Click me", callback = function() end })
```

| Rule | Detail |
|------|--------|
| Tab name | Must be a non-empty string |
| Reserved name | `"Settings"` — created automatically by `Finish()`. Manual creation throws an error |

### Tab proxy methods

All methods accept an options table. The `tab` field is set automatically.

- `AddButton`
- `AddToggle`
- `AddInput`
- `AddSlider`
- `AddDropdown`
- `AddMultiDropdown`
- `AddKeybind`
- `AddColorPicker`
- `AddLabel`
- `AddSeparator`
- `AddPageName`
- `AddTitle`
- `AddSubtitle`

---

## UI Elements

All `Add*` methods return an **element handle** with optional runtime methods (see [Element Runtime API](#element-runtime-api)).

Unless noted, every element accepts the [common options](#common-options).

### `AddPageName(opts)`

Large bold page heading.

| Option | Type | Default |
|--------|------|---------|
| `text` | `string` | `"Page"` |

### `AddTitle(opts)`

Section title (18px bold).

| Option | Type | Default |
|--------|------|---------|
| `text` | `string` | `"Title"` |

### `AddSubtitle(opts)`

Section subtitle (14px, muted color).

| Option | Type | Default |
|--------|------|---------|
| `text` | `string` | `"Subtitle"` |

### `AddSeparator(opts)`

Horizontal divider line. No extra options.

### `AddLabel(opts)`

Informational text label.

| Option | Type | Default |
|--------|------|---------|
| `text` | `string` | `""` |
| `textSize` | `number` | `13` |
| `color` | `Color3?` | theme `subTextColor` |
| `height` | `number` | `24` |

### `AddButton(opts)`

Gradient accent button with click animation.

| Option | Type | Default |
|--------|------|---------|
| `text` | `string` | `"Button"` |
| `color` | `Color3?` | theme `accentColor` |
| `callback` | `function()` | — |

### `AddToggle(opts)`

Switch toggle with animated knob.

| Option | Type | Default |
|--------|------|---------|
| `text` | `string` | `"Toggle"` |
| `state` | `boolean` | `false` |
| `callback` | `function(boolean)` | — |

### `AddInput(opts)`

Text input field. Callback fires on every text change and on Enter (focus lost).

| Option | Type | Default |
|--------|------|---------|
| `text` | `string?` | — (label on the left) |
| `value` | `string` | `""` |
| `placeholder` | `string` | `"Enter text..."` |
| `callback` | `function(string)` | — |

### `AddSlider(opts)`

Draggable numeric slider. Values are rounded to integers.

| Option | Type | Default |
|--------|------|---------|
| `text` | `string` | `"Slider"` |
| `min` | `number` | `0` |
| `max` | `number` | `100` |
| `value` | `number` | `min` |
| `callback` | `function(number)` | — |

### `AddDropdown(opts)`

Single-select dropdown with animated list overlay.

| Option | Type | Default |
|--------|------|---------|
| `text` | `string` | `"Select"` |
| `list` | `{string}` | `{}` |
| `value` | `string?` | first list item |
| `callback` | `function(string)` | — |

### `AddMultiDropdown(opts)`

Multi-select dropdown. Callback receives a new array copy.

| Option | Type | Default |
|--------|------|---------|
| `text` | `string` | `"Select"` |
| `list` | `{string}` | `{}` |
| `value` | `{string}` | `{}` |
| `callback` | `function({string})` | — |

### `AddKeybind(opts)`

Keyboard key capture element (PC keyboard only). Click the button to enter listen mode, then press a key.

| Option | Type | Default |
|--------|------|---------|
| `text` | `string` | `"Keybind"` |
| `key` | `Enum.KeyCode?` | `nil` (None) |
| `callback` | `function(Enum.KeyCode?)` | — |

**Listen mode controls:**
- Any keyboard key — assigns the key
- `Backspace` / `Delete` — clears to `None`
- `Escape` — cancels without changing
- Click the button again — cancels listen mode

### `AddColorPicker(opts)`

HSV color picker with popup panel (saturation/value square + hue bar).

| Option | Type | Default |
|--------|------|---------|
| `text` | `string` | `"Color"` |
| `value` | `Color3` | `Color3.new(1, 1, 1)` |
| `callback` | `function(Color3)` | — |

Popup includes live preview, `#RRGGBB` hex on the row button, and `RGB(r, g, b)` label inside the panel.

---

## Themes

### Built-in themes

Access via `Lib.Themes.Dark`, `Lib.Themes.Light`, `Lib.Themes.Neon`.

### Theme fields

| Field | Type | Description |
|-------|------|-------------|
| `name` | `string` | Theme identifier |
| `backgroundColor` | `Color3` | Main frame background |
| `backgroundColor2` | `Color3` | Gradient end color |
| `tabBarColor` | `Color3` | Title bar and tab bar |
| `contentColor` | `Color3` | Content area background |
| `accentColor` | `Color3` | Primary accent |
| `accentColor2` | `Color3` | Secondary accent (gradients) |
| `textColor` | `Color3` | Primary text |
| `subTextColor` | `Color3` | Muted / secondary text |
| `strokeColor` | `Color3` | Borders and dividers |
| `elementColor` | `Color3` | Card / input backgrounds |
| `hoverColor` | `Color3` | Dropdown item hover |
| `knobColor` | `Color3` | Toggle / slider knob |
| `buttonTextColor` | `Color3` | Button label color |
| `cornerRadius` | `number` | Element corner radius (px) |
| `elementHeight` | `number` | Default row height (px) |

### `menu:AddTheme(opts)`

Adds a custom theme to this menu. Unspecified fields inherit from the current theme.

```lua
menu:AddTheme({
    name = "Ocean",
    accentColor = Color3.fromRGB(0, 180, 255),
    accentColor2 = Color3.fromRGB(0, 100, 200),
})
```

### Theme methods

| Method | Description |
|--------|-------------|
| `menu:SetTheme(name)` | Alias for `ApplyTheme` |
| `menu:GetTheme()` | Returns current theme name (`string`) |
| `menu:ApplyTheme(name)` | Switches theme and updates all elements |

### Settings tab (auto)

After `Finish()`, the Settings tab includes:

- **Theme** dropdown — lists all registered themes
- **Menu Type** dropdown — `Default` (560×440) or `Compact` (480×380)

---

## Notifications

### `menu:Notify(opts)`

Shows a temporary toast notification in the top-right corner. Notifications remain visible when the menu is minimized.

```lua
menu:Notify({
    title = "Success",
    text = "Settings saved.",
    duration = 4,
})
```

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `title` | `string` | `"Notification"` | Notification title |
| `text` | `string` | `""` | Body text |
| `duration` | `number` | `3` | Display time in seconds before auto-dismiss |

Returns a handle with:

| Method | Description |
|--------|-------------|
| `handle:Dismiss()` | Manually close the notification early |

Multiple notifications stack vertically. Colors follow the menu's active theme.

---

## Window Control

| Method | Description |
|--------|-------------|
| `menu:Show()` | Alias for `Restore()` — show main window |
| `menu:Hide()` | Alias for `Minimize()` — hide to floating button |
| `menu:Minimize()` | Hide main frame, show draggable restore button |
| `menu:Restore()` | Show main frame, hide restore button |
| `menu:Destroy()` | Disconnect all events and destroy ScreenGui |
| `menu:GetElements()` | Returns array of all registered element handles |

### Window buttons

- **Minimize (−)** — collapses to floating restore button (tap to restore, drag to reposition)
- **Close (×)** — hides ScreenGui entirely (`screenGui.Enabled = false`)

---

## Element Runtime API

Element handles support method-style calls (colon syntax):

```lua
local toggle = tab:AddToggle({ text = "ESP", state = false })
print(toggle:GetValue())   -- false
toggle:SetValue(true)      -- fires callback
```

| Element | Methods |
|---------|---------|
| **Button** | `SetText(text)` |
| **Toggle** | `GetValue()` → `boolean`, `SetValue(bool)` |
| **Input** | `GetValue()` → `string`, `SetValue(text)` |
| **Slider** | `GetValue()` → `number`, `SetValue(number)` |
| **Dropdown** | `GetValue()` → `string`, `SetValue(item)`, `Close()` |
| **MultiDropdown** | `GetValue()` → `{string}`, `SetValue(array)`, `Close()` |
| **Keybind** | `GetValue()` → `Enum.KeyCode?`, `SetValue(keyCode)`, `CancelListen()` |
| **ColorPicker** | `GetValue()` → `Color3`, `SetValue(color)`, `Close()` |
| **Label** | `SetText(text)` |
| **Separator, PageName, Title, Subtitle** | — (no runtime methods) |

`SetValue` on toggles, sliders, and dropdowns fires the element's `callback` unless internally suppressed.

---

## Common Options

These fields can be passed to any `Add*` method:

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `tab` | `string` | first tab | Target tab name (auto-set on tab proxy) |

When calling methods directly on `menu` (not via tab proxy), you must specify `tab`:

```lua
menu:AddButton({ tab = "Main", text = "OK", callback = function() end })
```

---

## Errors

| Error | Cause |
|-------|-------|
| `Create() expects a tabs array or options table` | Invalid argument to `Lib:Create` |
| `AddTab() requires a non-empty tab name` | Empty or non-string tab name |
| `Settings tab is created automatically` | Manual `AddTab("Settings")` — use `Finish()` instead |

---

## Type Reference (Menu Object)

```lua
-- menu object (returned by Lib:Create)
menu:AddTab(name: string) -> tabProxy
menu:Finish() -> menu
menu:SetTheme(name: string)
menu:GetTheme() -> string
menu:ApplyTheme(name: string)
menu:AddTheme(opts: table) -> themeTable
menu:Notify(opts: table) -> notifyHandle
menu:Show() / menu:Hide() / menu:Minimize() / menu:Restore()
menu:Destroy()
menu:GetElements() -> { elementHandle }

-- tabProxy
tabProxy:AddButton(opts) -> elementHandle
-- ... all other Add* methods
```
