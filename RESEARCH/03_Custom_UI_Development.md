# 📚 NOTEBOOK 3: Custom UI Library Development

## Creado por: Samir (16bitplayer)
**Fecha:** 2026-01-04  
**Objetivo:** Crear nuestra propia UI library profesional desde cero

---

## 🎨 FUNDAMENTOS DE ROBLOX UI

### A. Core Components

**Jerarquía básica:**
```
ScreenGui (Container)
└── Frame (Panel base)
    ├── TextLabel (Texto)
    ├── TextButton (Botón)
    ├── ImageLabel (Imágenes)
    └── ScrollingFrame (Contenido scroll)
```

### B. Sistema de Posicionamiento: UDim2

**Lo MÁS IMPORTANTE para UI responsive:**

```lua
-- UDim2.new(scaleX, offsetX, scaleY, offsetY)
-- Scale: 0-1 (porcentaje de pantalla)
-- Offset: píxeles fijos

-- ❌ MAL (solo offset, no responsive):
frame.Size = UDim2.new(0, 500, 0, 400) -- Tamaño fijo

-- ✅ BIEN (scale para responsive):
frame.Size = UDim2.new(0.4, 0, 0.5, 0) -- 40% ancho, 50% alto

-- 🎯 PROFESIONAL (mix scale + offset):
frame.Size = UDim2.new(0.3, 100, 0.4, 50) -- Base % + ajuste píxeles
```

### C. AnchorPoint (Centro de Transformación)

```lua
-- AnchorPoint define desde dónde se posiciona
frame.AnchorPoint = Vector2.new(0.5, 0.5) -- Centro del element
frame.Position = UDim2.new(0.5, 0, 0.5, 0) -- Centro de pantalla

-- Ahora el frame está PERFECTAMENTE CENTRADO
```

**Visual:**
```
AnchorPoint (0, 0):        AnchorPoint (0.5, 0.5):
┌──────────┐               ┌──────────┐
│ ●        │ Position      │          │
│          │ aquí          │     ●    │ Position aquí (centro)
│          │               │          │
└──────────┘               └──────────┘
```

---

## 🏗️ ARQUITECTURA DE NUESTRA UI LIBRARY

### Estructura de Archivos

```
CustomUILib/
├── Core/
│   ├── Theme.lua          -- Colores y estilos
│   ├── Utilities.lua      -- Funciones helper
│   └── Animations.lua     -- Sistema de tweens
├── Components/
│   ├── Window.lua         -- Ventana principal
│   ├── Tab.lua            -- Sistema de tabs
│   ├── Toggle.lua         -- Switch
│   ├── Slider.lua         -- Barra deslizante
│   ├── Button.lua         -- Botón
│   ├── Dropdown.lua       -- Menú desplegable
│   └── Input.lua          -- TextBox
└── Main.lua               -- Entry point
```

---

## 🎨 THEME SYSTEM

```lua
-- Theme.lua (Profesional)
local Theme = {
    Background = {
        Main = Color3.fromRGB(15, 15, 20),      -- #0F0F14
        Secondary = Color3.fromRGB(25, 25, 30), -- #19191E
        Tertiary = Color3.fromRGB(35, 35, 40),  -- #232328
    },
    Accent = {
        Primary = Color3.fromRGB(109, 112, 255),  -- Indigo
        Secondary = Color3.fromRGB(149, 102, 255), -- Purple
        Success = Color3.fromRGB(26, 195, 139),    -- Green
        Danger = Color3.fromRGB(249, 78, 78),      -- Red
    },
    Text = {
        Primary = Color3.fromRGB(255, 255, 255),  -- White
        Secondary = Color3.fromRGB(170, 170, 180), -- Gray
        Muted = Color3.fromRGB(120, 120, 130),     -- Darker gray
    },
    Border = Color3.fromRGB(50, 50, 55),
    
    -- Radios/Tamaños
    CornerRadius = UDim.new(0, 8),
    StrokeThickness = 1.5,
    
    -- Fonts
    FontHeader = Enum.Font.GothamBold,
    FontBody = Enum.Font.Gotham,
    FontMono = Enum.Font.Code,
}

return Theme
```

---

## 🔧 UTILITIES MODULE

```lua
-- Utilities.lua
local TweenService = game:GetService("TweenService")
local Utilities = {}

-- Crear elemento con props
function Utilities:Create(className, properties)
    local instance = Instance.new(className)
    
    for prop, value in pairs(properties) do
        if prop ~= "Parent" then
            instance[prop] = value
        end
    end
    
    if properties.Parent then
        instance.Parent = properties.Parent
    end
    
    return instance
end

-- Tween suave
function Utilities:Tween(instance, goal, duration, easingStyle, callback)
    easingStyle = easingStyle or Enum.EasingStyle.Quad
    duration = duration or 0.3
    
    local tween = TweenService:Create(instance, 
        TweenInfo.new(duration, easingStyle, Enum.EasingDirection.Out),
        goal
    )
    
    if callback then
        tween.Completed:Connect(callback)
    end
    
    tween:Play()
    return tween
end

-- Añadir corner redondeado
function Utilities:AddCorner(parent, radius)
    return self:Create("UICorner", {
        CornerRadius = radius or UDim.new(0, 8),
        Parent = parent
    })
end

-- Añadir stroke (borde)
function Utilities:AddStroke(parent, color, thickness)
    return self:Create("UIStroke", {
        Color = color,
        Thickness = thickness or 1.5,
        Transparency = 0.5,
        Parent = parent
    })
end

return Utilities
```

---

## 🪟 WINDOW COMPONENT

```lua
-- Window.lua (Completo con minimize/maximize/close)
local Theme = require(script.Parent.Core.Theme)
local Utils = require(script.Parent.Core.Utilities)

local Window = {}
Window.__index = Window

function Window.new(config)
    local self = setmetatable({}, Window)
    
    -- ScreenGui principal
    self.ScreenGui = Utils:Create("ScreenGui", {
        Name = "CustomUI_" .. (config.Title or "Window"),
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = game:GetService("CoreGui")
    })
    
    -- Main Container
    self.Main = Utils:Create("Frame", {
        Size = UDim2.new(0, 700, 0, 500),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Theme.Background.Main,
        BorderSizePixel = 0,
        Parent = self.ScreenGui
    })
    Utils:AddCorner(self.Main)
    Utils:AddStroke(self.Main, Theme.Border)
    
    -- TopBar (draggable)
    self.TopBar = Utils:Create("Frame", {
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundColor3 = Theme.Background.Secondary,
        BorderSizePixel = 0,
        Parent = self.Main
    })
    Utils:AddCorner(self.TopBar)
    
    -- Title
    self.Title = Utils:Create("TextLabel", {
        Size = UDim2.new(0, 200, 1, 0),
        Position = UDim2.new(0, 20, 0, 0),
        BackgroundTransparency = 1,
        Text = config.Title or "Window",
        TextColor3 = Theme.Text.Primary,
        Font = Theme.FontHeader,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = self.TopBar
    })
    
    --
 Window Controls (Minimize, Maximize, Close)
    self:CreateWindowControls()
    
    -- Make draggable
    self:MakeDraggable()
    
    -- Content Area
    self.Content = Utils:Create("Frame", {
        Size = UDim2.new(1, -20, 1, -70),
        Position = UDim2.new(0, 10, 0, 60),
        BackgroundTransparency = 1,
        Parent = self.Main
    })
    
    self.Tabs = {}
    self.IsMinimized = false
    self.IsMaximized = false
    
    return self
end

function Window:CreateWindowControls()
    local buttonSize = 35
    local spacing = 5
    local rightPadding = 10
    
    -- Close Button
    local closeBtn = Utils:Create("TextButton", {
        Size = UDim2.new(0, buttonSize, 0, buttonSize),
        Position = UDim2.new(1, -(rightPadding + buttonSize), 0.5, -buttonSize/2),
        AnchorPoint = Vector2.new(0, 0),
        BackgroundColor3 = Theme.Accent.Danger,
        Text = "✕",
        TextColor3 = Color3.new(1, 1, 1),
        Font = Theme.FontHeader,
        TextSize = 18,
        Parent = self.TopBar
    })
    Utils:AddCorner(closeBtn)
    
    closeBtn.MouseButton1Click:Connect(function()
        self:Destroy()
    end)
    
    -- Maximize Button
    local maxBtn = Utils:Create("TextButton", {
        Size = UDim2.new(0, buttonSize, 0, buttonSize),
        Position = UDim2.new(1, -(rightPadding + (buttonSize + spacing) * 2), 0.5, -buttonSize/2),
        BackgroundColor3 = Theme.Background.Tertiary,
        Text = "▢",
        TextColor3 = Theme.Text.Primary,
        Font = Theme.FontHeader,
        TextSize = 16,
        Parent = self.TopBar
    })
    Utils:AddCorner(maxBtn)
    
    maxBtn.MouseButton1Click:Connect(function()
        self:ToggleMaximize()
    end)
    
    -- Minimize Button
    local minBtn = Utils:Create("TextButton", {
        Size = UDim2.new(0, buttonSize, 0, buttonSize),
        Position = UDim2.new(1, -(rightPadding + (buttonSize + spacing)), 0.5, -buttonSize/2),
        BackgroundColor3 = Theme.Background.Tertiary,
        Text = "−",
        TextColor3 = Theme.Text.Primary,
        Font = Theme.FontHeader,
        TextSize = 18,
        Parent = self.TopBar
    })
    Utils:AddCorner(minBtn)
    
    minBtn.MouseButton1Click:Connect(function()
        self:ToggleMinimize()
    end)
end

function Window:MakeDraggable()
    local UserInputService = game:GetService("UserInputService")
    local dragging, dragInput, dragStart, startPos
    
    local function update(input)
        local delta = input.Position - dragStart
        Utils:Tween(self.Main, {
            Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        }, 0.1)
    end
    
    self.TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = self.Main.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            update(input)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

function Window:ToggleMinimize()
    self.IsMinimized = not self.IsMinimized
    
    if self.IsMinimized then
        Utils:Tween(self.Main, {Size = UDim2.new(0, 700, 0, 50)}, 0.3)
        self.Content.Visible = false
    else
        Utils:Tween(self.Main, {Size = UDim2.new(0, 700, 0, 500)}, 0.3)
        self.Content.Visible = true
    end
end

function Window:ToggleMaximize()
    self.IsMaximized = not self.IsMaximized
    
    if self.IsMaximized then
        Utils:Tween(self.Main, {
            Size = UDim2.new(1, -100, 1, -100),
            Position = UDim2.new(0.5, 0, 0.5, 0)
        }, 0.3)
    else
        Utils:Tween(self.Main, {
            Size = UDim2.new(0, 700, 0, 500),
            Position = UDim2.new(0.5, 0, 0.5, 0)
        }, 0.3)
    end
end

function Window:Destroy()
    Utils:Tween(self.Main, {Size = UDim2.new(0, 0, 0, 0)}, 0.2, nil, function()
        self.ScreenGui:Destroy()
    end)
end

return Window
```

---

## 🎓 CONCLUSIÓN

**Hemos aprendido:**
- ✅ UDim2 para responsive design
- ✅ AnchorPoint para posicionamiento
- ✅ Sistemas de themes profesionales
- ✅ Utilities reutilizables
- ✅ Window con todos los controles

**Nuestra UI será:**
- 100% Custom (no dependencias externas)
- Responsive en todas las pantallas
- Themed (fácil cambiar colores)
- Profesional (minimize/maximize/close)
- Animada (tweens suaves)

---

**FIN DE LA INVESTIGACIÓN - LISTO PARA IMPLEMENTAR** 🚀
