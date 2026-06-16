# ErtyHub — Руководство пользователя

**ErtyHub** — библиотека для создания UI-меню в Roblox. Предназначена для использования через executor (с `HttpGet`) и в Roblox Studio (через `require`).

| | |
|---|---|
| Версия | 1.2.0 |
| Файл библиотеки | [`src/ErtyHub.lua`](../src/ErtyHub.lua) |
| Пример | [`examples/MenuDemo.lua`](../examples/MenuDemo.lua) |
| API (EN) | [API.md](API.md) |

---

## Содержание

1. [Установка](#установка)
2. [Быстрый старт](#быстрый-старт)
3. [Создание меню](#создание-меню)
4. [Вкладки](#вкладки)
5. [Виджеты](#виджеты)
6. [Темы оформления](#темы-оформления)
7. [Уведомления](#уведомления)
8. [Управление окном](#управление-окном)
9. [Работа с элементами в runtime](#работа-с-элементами-в-runtime)
10. [Roblox Studio vs Executor](#roblox-studio-vs-executor)
11. [Решение проблем](#решение-проблем)

---

## Установка

### Способ 1: Executor (рекомендуется)

Загрузите библиотеку напрямую с GitHub:

```lua
local Lib = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/ErtyHubCheats/ErtyHubLibNew/main/src/ErtyHub.lua"
))()
```

**Требования:**
- Executor должен поддерживать `game:HttpGet` (или аналог)
- `loadstring` должен быть доступен

### Способ 2: Roblox Studio

1. Создайте **ScreenGui** в `StarterGui`.
2. Добавьте **ModuleScript** с именем `ErtyHub`.
3. Вставьте содержимое файла `src/ErtyHub.lua`.
4. Создайте **LocalScript** и подключите библиотеку:

```lua
local Lib = require(script.Parent.ErtyHub)
```

### Способ 3: Локальный файл в executor

Если ваш executor поддерживает чтение файлов с диска — поместите `ErtyHub.lua` рядом со скриптом и используйте `require` или `readfile` + `loadstring`.

---

## Быстрый старт

Минимальный рабочий скрипт:

```lua
local Lib = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/ErtyHubCheats/ErtyHubLibNew/main/src/ErtyHub.lua"
))()

local menu = Lib:Create({
    title = "Мой скрипт",
    name = "MyMenu",
    version = "1.0.0",
    showVersion = true,
})

local tab = menu:AddTab("Главная")

tab:AddPageName({ text = "Главная" })
tab:AddButton({
    text = "Нажми меня",
    callback = function()
        print("Кнопка нажата!")
    end,
})

menu:Finish()
```

Полный пример со всеми виджетами — в файле [`examples/MenuDemo.lua`](../examples/MenuDemo.lua).

---

## Создание меню

### `Lib:Create(options)`

Создаёт новое меню и возвращает объект `menu`.

```lua
local menu = Lib:Create({
    title = "ErtyHub Demo",   -- заголовок в шапке окна
    name = "ErtyHubDemo",     -- имя ScreenGui
    parent = nil,             -- родитель (по умолчанию PlayerGui)
    displayOrder = 10,        -- порядок отображения ScreenGui
    version = "2.0.0",        -- версия вашего скрипта в бейдже
    showVersion = true,       -- false — скрыть бейдж версии
})
```

| Параметр | Тип | По умолчанию | Описание |
|----------|-----|--------------|----------|
| `title` | string | `"ErtyHub"` | Текст в заголовке |
| `name` | string | `"ErtyHubMenu"` | Имя экземпляра ScreenGui |
| `parent` | Instance | PlayerGui | Куда поместить GUI. Если игрока нет — CoreGui |
| `displayOrder` | number | 10 | Z-порядок ScreenGui |
| `version` | string | версия библиотеки | Текст в бейдже и на вкладке Settings |
| `showVersion` | boolean | `true` | `false` — скрыть бейдж версии |

### Устаревший синтаксис

```lua
local menu = Lib:Create({ "Main", "Visual" }, { title = "Legacy" })
```

Вкладки создаются сразу, `Finish()` вызывается автоматически. Для новых скриптов используйте `AddTab()`.

### `menu:Finish()` — обязательный вызов

В конце настройки меню **всегда** вызывайте:

```lua
menu:Finish()
```

Что делает `Finish()`:
- Создаёт вкладку **Settings** с выбором темы и размера окна
- Применяет текущую тему ко всем элементам
- Безопасен при повторном вызове

---

## Вкладки

### Создание вкладки

```lua
local tab = menu:AddTab("Main")
```

`AddTab` возвращает **прокси-объект** вкладки. Все виджеты добавляются через него:

```lua
tab:AddButton({ text = "OK", callback = function() end })
tab:AddToggle({ text = "ESP", state = false, callback = function(v) end })
```

### Важные правила

| Правило | Пояснение |
|---------|-----------|
| Не создавайте `Settings` вручную | Вкладка создаётся автоматически в `Finish()` |
| Имя не может быть пустым | `AddTab("")` вызовет ошибку |
| Первая вкладка активна сразу | При создании первой вкладки она становится активной |

### Прямой вызов через menu

Можно вызывать `Add*` на объекте `menu`, указав `tab`:

```lua
menu:AddButton({ tab = "Main", text = "Click", callback = function() end })
```

---

## Виджеты

### Заголовки и разделители

```lua
tab:AddPageName({ text = "Название страницы" })  -- крупный заголовок
tab:AddTitle({ text = "Заголовок секции" })      -- заголовок 18px
tab:AddSubtitle({ text = "Подзаголовок" })       -- подзаголовок, приглушённый
tab:AddSeparator({})                              -- горизонтальная линия
tab:AddLabel({ text = "Информационный текст" })  -- обычная метка
```

### Кнопка

```lua
tab:AddButton({
    text = "Выполнить",
    color = Color3.fromRGB(79, 139, 255),  -- необязательно
    callback = function()
        print("Нажато!")
    end,
})
```

### Переключатель (Toggle)

```lua
local toggle = tab:AddToggle({
    text = "Включить ESP",
    state = false,
    callback = function(enabled)
        print("ESP:", enabled)
    end,
})
```

### Поле ввода (Input)

```lua
tab:AddInput({
    text = "Имя",                        -- метка слева (необязательно)
    placeholder = "Введите имя...",
    value = "",
    callback = function(text)
        print("Ввод:", text)
    end,
})
```

Callback срабатывает при каждом изменении текста и при нажатии Enter.

### Слайдер

```lua
tab:AddSlider({
    text = "Яркость",
    min = 0,
    max = 100,
    value = 50,
    callback = function(val)
        print("Значение:", val)
    end,
})
```

Значения округляются до целых чисел.

### Выпадающий список (Dropdown)

```lua
tab:AddDropdown({
    text = "Режим",
    list = { "Legit", "Rage", "Silent" },
    value = "Legit",
    callback = function(selected)
        print("Выбрано:", selected)
    end,
})
```

### Множественный выбор (MultiDropdown)

```lua
tab:AddMultiDropdown({
    text = "Фильтры",
    list = { "Players", "NPCs", "Items" },
    value = { "Players" },
    callback = function(selected)
        print("Выбрано:", table.concat(selected, ", "))
    end,
})
```

Callback получает **копию** массива выбранных значений.

### Привязка клавиши (Keybind)

Только клавиатура (PC). Нажмите кнопку элемента, затем клавишу на клавиатуре.

```lua
tab:AddKeybind({
    text = "Переключить меню",
    key = Enum.KeyCode.RightShift,
    callback = function(keyCode)
        if keyCode then
            print("Клавиша:", keyCode.Name)
        else
            print("Сброшено")
        end
    end,
})
```

| Клавиша в режиме ожидания | Действие |
|---------------------------|----------|
| Любая клавиша | Назначить клавишу |
| `Backspace` / `Delete` | Сбросить в `None` |
| `Escape` | Отменить без изменений |
| Повторный клик по кнопке | Отменить режим ожидания |

### Выбор цвета (ColorPicker)

HSV-панель с квадратом насыщенности/яркости и полоской оттенка.

```lua
tab:AddColorPicker({
    text = "Цвет ESP",
    value = Color3.fromRGB(255, 80, 80),
    callback = function(color)
        print("Цвет:", color)
    end,
})
```

В строке отображается hex (`#FF5050`), в панели — `RGB(255, 80, 80)`. Перетаскивайте курсор по квадрату и полоске Hue для точной настройки.

---

## Темы оформления

### Встроенные темы

| Имя | Описание |
|-----|----------|
| `Dark` | Тёмная тема по умолчанию |
| `Light` | Светлая тема |
| `Neon` | Тёмная с неоновыми акцентами |

### Смена темы в коде

```lua
menu:SetTheme("Neon")
-- или
menu:ApplyTheme("Light")

print(menu:GetTheme())  -- "Light"
```

### Создание своей темы

```lua
menu:AddTheme({
    name = "Ocean",
    backgroundColor = Color3.fromRGB(5, 15, 30),
    backgroundColor2 = Color3.fromRGB(10, 25, 50),
    accentColor = Color3.fromRGB(0, 200, 255),
    accentColor2 = Color3.fromRGB(0, 120, 200),
    textColor = Color3.fromRGB(255, 255, 255),
})

menu:SetTheme("Ocean")
```

Неуказанные поля наследуются от текущей темы.

### Глобальная тема (для всех новых меню)

```lua
Lib:AddTheme({
    name = "GlobalRed",
    accentColor = Color3.fromRGB(255, 50, 50),
})
```

### Поля темы

| Поле | Назначение |
|------|------------|
| `backgroundColor` | Фон главного окна |
| `backgroundColor2` | Второй цвет градиента |
| `tabBarColor` | Шапка и панель вкладок |
| `contentColor` | Фон области контента |
| `accentColor` | Основной акцент |
| `accentColor2` | Второй акцент (градиенты) |
| `textColor` | Основной текст |
| `subTextColor` | Второстепенный текст |
| `strokeColor` | Границы и разделители |
| `elementColor` | Фон карточек и полей |
| `hoverColor` | Цвет при наведении в списках |
| `knobColor` | Ручка toggle/slider |
| `buttonTextColor` | Текст на кнопках |
| `cornerRadius` | Радиус скругления (px) |
| `elementHeight` | Высота строки (px) |

### Вкладка Settings

После `Finish()` появляется вкладка **Settings** с:
- **Theme** — выбор темы из всех зарегистрированных
- **Menu Type** — `Default` (560×440) или `Compact` (480×380)

---

## Уведомления

### `menu:Notify(opts)`

Показывает временное toast-уведомление в правом верхнем углу экрана. Уведомления остаются видимыми, даже когда меню свёрнуто.

```lua
menu:Notify({
    title = "Успех",
    text = "Настройки сохранены.",
    duration = 4,
})
```

| Параметр | Тип | По умолчанию | Описание |
|----------|-----|--------------|----------|
| `title` | string | `"Notification"` | Заголовок уведомления |
| `text` | string | `""` | Основной текст |
| `duration` | number | `3` | Время показа в секундах до авто-закрытия |

Метод возвращает handle с методом:

| Метод | Описание |
|-------|----------|
| `handle:Dismiss()` | Закрыть уведомление вручную до истечения таймера |

Несколько уведомлений складываются вертикально в стек. Цвета берутся из активной темы меню.

Пример в демо:

```lua
menu:Notify({
    title = "Привет",
    text = "Это уведомление исчезнет через 3 секунды.",
    duration = 3,
})
```

---

## Управление окном

| Метод | Действие |
|-------|----------|
| `menu:Show()` | Показать окно (аналог `Restore`) |
| `menu:Hide()` | Свернуть в плавающую кнопку |
| `menu:Minimize()` | Скрыть окно, показать кнопку восстановления |
| `menu:Restore()` | Вернуть окно на экран |
| `menu:Destroy()` | Удалить меню и отключить все события |

### Кнопки в шапке

- **− (Minimize)** — сворачивает меню в плавающую кнопку в углу экрана
- **× (Close)** — полностью скрывает GUI (`screenGui.Enabled = false`)

Плавающую кнопку можно перетаскивать. Нажатие без перетаскивания восстанавливает окно.

---

## Работа с элементами в runtime

Многие виджеты возвращают объект с методами для чтения и изменения значений:

```lua
local espToggle = tab:AddToggle({
    text = "ESP",
    state = false,
    callback = function(v) end,
})

-- Чтение
print(espToggle:GetValue())  -- false

-- Запись (вызовет callback)
espToggle:SetValue(true)

-- Кнопка и метка
local btn = tab:AddButton({ text = "Статус", callback = function() end })
btn:SetText("Готово!")

local lbl = tab:AddLabel({ text = "Загрузка..." })
lbl:SetText("Загружено!")
```

| Виджет | Методы |
|--------|--------|
| Button | `SetText(text)` |
| Toggle | `GetValue()`, `SetValue(bool)` |
| Input | `GetValue()`, `SetValue(text)` |
| Slider | `GetValue()`, `SetValue(number)` |
| Dropdown | `GetValue()`, `SetValue(item)`, `Close()` |
| MultiDropdown | `GetValue()`, `SetValue({...})`, `Close()` |
| Keybind | `GetValue()`, `SetValue(keyCode)`, `CancelListen()` |
| ColorPicker | `GetValue()`, `SetValue(color)`, `Close()` |
| Label | `SetText(text)` |

Получить все элементы: `menu:GetElements()`.

---

## Roblox Studio vs Executor

| | Executor | Studio |
|---|----------|--------|
| Загрузка | `loadstring(game:HttpGet(url))()` | `require(ModuleScript)` |
| Родитель GUI | PlayerGui / CoreGui | PlayerGui |
| HttpGet | Нужен для загрузки с GitHub | Не нужен при require |
| ResetOnSpawn | `false` (установлено в библиотеке) | Меню сохраняется при респавне |

Библиотека автоматически помещает ScreenGui в `Players.LocalPlayer.PlayerGui`. Если LocalPlayer недоступен — используется `CoreGui`.

---

## Решение проблем

### Меню не появляется

1. Убедитесь, что скрипт — **LocalScript** (в Studio) или executor запускает клиентский код.
2. Проверьте, что `HttpGet` не заблокирован и URL корректен.
3. Вызовите `menu:Finish()` в конце настройки.

### Ошибка: `Settings tab is created automatically`

Вы вызвали `menu:AddTab("Settings")`. Удалите эту строку — Settings создаётся в `Finish()`.

### Ошибка: `Create() expects a tabs array or options table`

Передайте таблицу в `Lib:Create({ ... })`, а не отдельные аргументы.

### Dropdown не закрывается

Клик вне списка закрывает его автоматически. Можно закрыть программно: `dropdown:Close()`.

### Тема не применяется к новым элементам

Добавляйте элементы **до** `Finish()`, либо вызывайте `menu:ApplyTheme(menu:GetTheme())` после добавления (обычно достаточно `Finish()`).

### HttpGet возвращает ошибку 404

Проверьте:
- Правильное имя репозитория: `ErtyHubLibNew`
- Ветка: `main`
- Путь: `src/ErtyHub.lua`
- Репозиторий публичный

---

## Ссылки

- [README (EN)](../README.md)
- [API Reference (EN)](API.md)
- [Пример MenuDemo.lua](../examples/MenuDemo.lua)
- [Исходный код библиотеки](../src/ErtyHub.lua)
