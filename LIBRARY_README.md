# 🎨 **BLOXYHUB UI LIBRARY v2.0**

<div align="center">

![Version](https://img.shields.io/badge/Version-2.0-6366F1?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-Stable-10B981?style=for-the-badge)
![Platform](https://img.shields.io/badge/Platform-Roblox-EF4444?style=for-the-badge)

**La librería UI más profesional y moderna para scripts de Roblox**

[📦 Instalación](#-instalación) • [🎯 Características](#-características) • [💻 Ejemplos](#-ejemplos) • [📚 Documentación](#-documentación)

</div>

---

## 📖 **ÍNDICE**

- [Características](#-características)
- [Instalación](#-instalación)
- [Inicio Rápido](#-inicio-rápido)
- [Componentes](#-componentes)
- [Temas y Colores](#-temas-y-colores)
- [API Completa](#-api-completa)
- [Ejemplos Avanzados](#-ejemplos-avanzados)

---

## ✨ **CARACTERÍSTICAS**

### **🎨 Diseño Moderno**
- ✅ Tema oscuro profesional inspirado en React + WindUI
- ✅ Paleta de colores Indigo/Purple (#6366F1, #8B5CF6)
- ✅ Animaciones suaves con TweenService
- ✅ Bordes redondeados y efectos glassmorphism
- ✅ Responsive y adaptable

### **🔔 Sistema de Notificaciones Avanzado**
- ✅ 4 tipos: `primary`, `success`, `warning`, `error`
- ✅ Progress bar animada
- ✅ Iconos personalizados por tipo
- ✅ Botón de cerrar
- ✅ Auto-posicionamiento y auto-eliminación
- ✅ Stack de múltiples notificaciones

### **🪟 Ventana Profesional**
- ✅ Tamaño: 700x500px (perfecta para cualquier pantalla)
- ✅ Draggable desde TopBar
- ✅ Botón minimizar con logo flotante
- ✅ Sidebar con iconos emoji
- ✅ Contenido scrollable
- ✅ Keybind para toggle (opcional)

### **📦 Componentes Premium**
- ✅ **Toggle** - Switch animado con descripción opcional
- ✅ **Slider** - Draggable con valor editable
- ✅ **Button** - Hover effect y animación onClick
- ✅ **Dropdown** - Scrollable con selección
- ✅ **Input** - TextBox con placeholder
- ✅ **Label** - Texto informativo

---

## 📦 **INSTALACIÓN**

### **Método 1: LoadString (Recomendado)**

```lua
local BloxyHub = loadstring(game:HttpGet("https://raw.githubusercontent.com/Sam123mir/Skywars-Script-Bloxy-Hub/main/Library.lua"))()
```

### **Método 2: Archivo Local**

1. Descarga `Library.lua`
2. Guárdalo en tu executor
3. Cárgalo con `loadfile("Library.lua")()`

---

## 🚀 **INICIO RÁPIDO**

```lua
-- Cargar librería
local BloxyHub = loadstring(game:HttpGet("YOUR_GITHUB_URL"))()

-- Crear ventana
local Window = BloxyHub:CreateWindow({
    Title = "MI SCRIPT PREMIUM",
    Icon = "⚔️",  -- Emoji opcional
    UserInfo = "VIP User",  -- Badge opcional
    Keybind = Enum.KeyCode.RightShift  -- Toggle UI
})

-- Crear tab
local CombatTab = Window:CreateTab("Combat", "⚔️")

-- Añadir toggle
CombatTab:CreateToggle({
    Name = "Auto Kill",
    Description = "Mata enemigos automáticamente",
    Default = false,
    Callback = function(value)
        print("Auto Kill:", value)
        -- Tu código aquí
    end
})

-- Notificación
BloxyHub:Notify("Script Loaded", "Todos los sistemas listos", 3, "success")
```

---

## 🎨 **COMPONENTES**

### **1️⃣ TOGGLE (Switch)**

```ascii
┌──────────────────────────────────────────────┐
│  ⚡ Auto Kill                      [●====== ] │
│  Mata enemigos automáticamente                │
└──────────────────────────────────────────────┘
```

```lua
Tab:CreateToggle({
    Name = "Auto Kill",
    Description = "Descripción opcional",  -- Opcional
    Default = false,
    Callback = function(value)
        print(value)  -- true/false
    end
})
```

**Métodos:**
- `toggle.SetValue(true/false)` - Cambiar valor programáticamente

---

### **2️⃣ SLIDER (Barra deslizante)**

```ascii
┌──────────────────────────────────────────────┐
│  🎯 Reach                           [ 18 ]    │
│  [●================───────────────────]       │
└──────────────────────────────────────────────┘
```

```lua
Tab:CreateSlider({
    Name = "Reach",
    Min = 10,
    Max = 30,
    Default = 18,
    Callback = function(value)
        print(value)  -- Número entero
    end
})
```

**Métodos:**
- `slider.SetValue(25)` - Cambiar valor programáticamente

---

### **3️⃣ BUTTON (Botón)**

```ascii
┌──────────────────────────────────────────────┐
│              🔥 EXECUTE ATTACK                │
└──────────────────────────────────────────────┘
```

```lua
Tab:CreateButton({
    Name = "Execute Attack",
    Callback = function()
        print("Button clicked!")
    end
})
```

---

### **4️⃣ DROPDOWN (Menú desplegable)**

```ascii
┌──────────────────────────────────────────────┐
│  Target Mode                                  │
│  [ Nearest                          ▼ ]      │
│  ┌────────────────────────────────┐          │
│  │ Nearest         ✓               │          │
│  │ Lowest HP                       │          │
│  │ Highest HP                      │          │
│  └────────────────────────────────┘          │
└──────────────────────────────────────────────┘
```

```lua
Tab:CreateDropdown({
    Name = "Target Mode",
    Options = {"Nearest", "Lowest HP", "Highest HP"},
    Default = "Nearest",
    Callback = function(value)
        print(value)  -- String seleccionada
    end
})
```

**Métodos:**
- `dropdown.SetValue("Lowest HP")` - Cambiar selección

---

### **5️⃣ INPUT (Caja de texto)**

```ascii
┌──────────────────────────────────────────────┐
│  Player Name                                  │
│  [ Enter player name...                  ]   │
└──────────────────────────────────────────────┘
```

```lua
Tab:CreateInput({
    Name = "Player Name",
    Placeholder = "Enter player name...",
    Default = "",  -- Opcional
    Callback = function(text)
        print(text)  -- String
    end
})
```

**Métodos:**
- `input.SetValue("Nuevo texto")` - Cambiar texto

---

### **6️⃣ LABEL (Etiqueta)**

```ascii
┌──────────────────────────────────────────────┐
│  ℹ️ Este es un mensaje informativo            │
└──────────────────────────────────────────────┘
```

```lua
local label = Tab:CreateLabel("Script v1.0 - By Dev")

-- Actualizar texto
label.SetText("Script v1.1 - Updated!")
```

---

## 🔔 **NOTIFICACIONES**

### **Visual de Notificación:**

```ascii
┌────────────────────────────────────────┐
│  ✓  Script Loaded                 ✕    │
│     Todos los sistemas listos          │
│  [████████████████░░░]                 │
└────────────────────────────────────────┘
```

### **4 Tipos:**

| Tipo | Color | Icono | Uso |
|------|-------|-------|-----|
| `primary` | Indigo (#6366F1) | ℹ | Información general |
| `success` | Verde (#10B981) | ✓ | Operación exitosa |
| `warning` | Naranja (#F59E0B) | ⚠ | Advertencia |
| `error` | Rojo (#EF4444) | ✕ | Error |

```lua
-- Usar notificación
BloxyHub:Notify("Título", "Mensaje", 3, "success")

-- Desde Window
Window:Notify("Título", "Mensaje", 3, "error")
```

---

## 🎨 **TEMAS Y COLORES**

### **Paleta de Colores:**

```lua
THEME = {
    Background = {
        Primary   = #0B0B0B  -- Negro profundo
        Secondary = #151515  -- Gris muy oscuro
        Elevated  = #1A1A1A  -- Gris oscuro (tarjetas)
        Hover     = #202020  -- Gris hover
    },
    Accent = {
        Primary   = #6366F1  -- Indigo (principal)
        Secondary = #8B5CF6  -- Purple (secundario)
        Success   = #10B981  -- Verde
        Warning   = #F59E0B  -- Naranja
        Danger    = #EF4444  -- Rojo
    },
    Text = {
        Primary   = #FFFFFF  -- Blanco
        Secondary = #9CA3AF  -- Gris claro
        Muted     = #6B7280  -- Gris medio
    },
    Border = #252525
}
```

---

## 📐 **ESTRUCTURA DE VENTANA**

```ascii
┌────────────────────────────────────────────────────────────────┐
│  ⚔️ MI SCRIPT PREMIUM           [ VIP User ]        [ — ]     │  ← TopBar (50px)
├──────────────┬─────────────────────────────────────────────────┤
│              │                                                  │
│  ⚔️ Combat   │  ┌──────────────────────────────────────────┐  │
│  🎯 Macros   │  │ ⚡ Auto Kill                [●══════]    │  │
│  🗡️ Weapons  │  └──────────────────────────────────────────┘  │
│  🏃 Movement │  ┌──────────────────────────────────────────┐  │
│  👁️ Visual   │  │ 🎯 Reach                     [ 18 ]      │  │
│  👥 Allies   │  │ [●══════════════────────────────]        │  │
│  🛡️ Safety   │  └──────────────────────────────────────────┘  │
│  ℹ️ Info     │  ┌──────────────────────────────────────────┐  │
│              │  │         🔥 EXECUTE ATTACK                │  │
│              │  └──────────────────────────────────────────┘  │
│   Sidebar    │                  Content Area                  │
│   180px      │                  490px                          │
└──────────────┴─────────────────────────────────────────────────┘
     700px total × 500px height
```

---

## 💻 **EJEMPLO COMPLETO: SCRIPT DE COMBAT**

```lua
-- Cargar librería
local BloxyHub = loadstring(game:HttpGet("YOUR_URL_HERE"))()

-- Configuración
local Config = {
    autoKill = false,
    reach = 18,
    targetMode = "Nearest",
    speed = 23,
}

-- Crear ventana
local Window = BloxyHub:CreateWindow({
    Title = "⚔️ COMBAT PRO",
    Icon = "⚔️",
    UserInfo = "Premium",
    Keybind = Enum.KeyCode.RightShift
})

-- ========== TAB: COMBAT ==========
local CombatTab = Window:CreateTab("Combat", "⚔️")

CombatTab:CreateToggle({
    Name = "Auto Kill",
    Description = "Ataca enemigos automáticamente",
    Default = false,
    Callback = function(value)
        Config.autoKill = value
        Window:Notify("Combat", value and "Activado" or "Desactivado", 2, value and "success" or "warning")
    end
})

CombatTab:CreateSlider({
    Name = "Reach",
    Min = 10,
    Max = 30,
    Default = 18,
    Callback = function(value)
        Config.reach = value
    end
})

CombatTab:CreateDropdown({
    Name = "Target Mode",
    Options = {"Nearest", "Lowest HP", "Highest HP"},
    Default = "Nearest",
    Callback = function(value)
        Config.targetMode = value
        Window:Notify("Target", "Modo: " .. value, 2, "primary")
    end
})

-- ========== TAB: MOVEMENT ==========
local MovementTab = Window:CreateTab("Movement", "🏃")

MovementTab:CreateSlider({
    Name = "Walk Speed",
    Min = 16,
    Max = 50,
    Default = 23,
    Callback = function(value)
        Config.speed = value
        local player = game.Players.LocalPlayer
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.WalkSpeed = value
        end
    end
})

MovementTab:CreateButton({
    Name = "Teleport to Spawn",
    Callback = function()
        -- Tu código de teleport
        Window:Notify("Teleport", "Teleportado al spawn", 2, "success")
    end
})

-- ========== TAB: INFO ==========
local InfoTab = Window:CreateTab("Info", "ℹ️")

InfoTab:CreateLabel("Script Version: 1.0")
InfoTab:CreateLabel("Author: 16bitplayer")
InfoTab:CreateLabel("Last Update: 2026-01-03")

InfoTab:CreateButton({
    Name = "Join Discord",
    Callback = function()
        setclipboard("discord.gg/example")
        Window:Notify("Discord", "Link copiado al portapapeles", 3, "success")
    end
})

-- Notificación inicial
Window:Notify("Script Loaded", "Combat Pro v1.0 iniciado!", 4, "success")
```

---

## 🎯 **CARACTERÍSTICAS AVANZADAS**

### **1. Minimizar con Logo Flotante**

```lua
-- El botón minimizar (—) oculta la ventana y muestra un logo flotante
-- Click en el logo para volver a abrir
```

```ascii
Ventana Abierta:          Ventana Minimizada:
┌───────────────┐         
│  SCRIPT  [—]  │         ┌─────┐
│               │    →    │  ⚔️  │  ← Logo flotante (click para abrir)
│   Content     │         └─────┘
└───────────────┘
```

### **2. Keybind Toggle**

```lua
local Window = BloxyHub:CreateWindow({
    Title = "Mi Script",
    Keybind = Enum.KeyCode.RightShift  -- Presiona RightShift para toggle
})
```

### **3. User Info Badge**

```lua
local Window = BloxyHub:CreateWindow({
    Title = "Mi Script",
    UserInfo = "VIP Member"  -- Badge en TopBar
})
```

---

## 📊 **COMPARATIVA CON OTRAS LIBRERÍAS**

| Característica | BloxyHub v2.0 | Rayfield | Fluent | Orion |
|----------------|---------------|----------|--------|-------|
| Tema Moderno | ✅ | ✅ | ✅ | ❌ |
| Notificaciones | ✅ Progress Bar | ✅ | ✅ | ✅ |
| Animaciones | ✅ Smooth | ✅ | ✅ | ⚠️ |
| Logo Minimizar | ✅ | ❌ | ❌ | ❌ |
| Keybind Toggle | ✅ | ✅ | ✅ | ✅ |
| Mobile Support | ✅ | ✅ | ⚠️ | ⚠️ |
| Personalizable | ✅ | ⚠️ | ⚠️ | ⚠️ |

---

## 🐛 **TROUBLESHOOTING**

### **La UI no aparece**
```lua
-- Solución: Verificar que gethui() o CoreGui sea accesible
if gethui then
    print("✅ gethui disponible")
else
    print("⚠️ Usando CoreGui")
end
```

### **Notificaciones no se ven**
```lua
-- Las notificaciones usan ZIndex 100, verificar conflictos
-- Se posicionan en la esquina superior derecha
```

### **Drag no funciona**
```lua
-- Asegúrate de que no hay otro GUI bloqueando el TopBar
-- El drag solo funciona desde el TopBar (primeros 50px)
```

---

## 📱 **SOPORTE MÓVIL**

La librería está **100% optimizada para móvil**:
- ✅ Tamaño de botones touch-friendly (≥ 45px)
- ✅ Scrolling suave en tabs
- ✅ Textos legibles (≥ 11px)
- ✅ Drag funciona con touch

---

## 🔐 **SEGURIDAD**

```lua
-- Todos los callbacks usan pcall para evitar crashes
if config.Callback then
    pcall(function() config.Callback(value) end)
end

-- La UI se protege con gethui() o syn.protect_gui()
if gethui then
    ScreenGui.Parent = gethui()
elseif syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = game:GetService("CoreGui")
else
    ScreenGui.Parent = game:GetService("CoreGui")
end
```

---

## 📜 **CHANGELOG**

### **v2.0 (2026-01-03)**
- ✨ Nuevo sistema de notificaciones con progress bar
- ✨ Logo flotante al minimizar
- ✨ Keybind toggle opcional
- ✨ User info badge
- 🎨 Tema oscuro moderno (#0B0B0B)
- 🐛 Fixes en drag system
- 🐛 Fixes en ZIndex de componentes

### **v1.0 (2025-12-XX)**
- 🎉 Release inicial

---

## 👨‍💻 **CRÉDITOS**

- **Autor:** 16bitplayer
- **Diseño:** Inspirado en React + WindUI + Fluent
- **Librería:** BloxyHub UI v2.0

---

## 📄 **LICENCIA**

MIT License - Uso libre para scripts de Roblox

---

## 🔗 **ENLACES**

- [GitHub Repository](https://github.com/Sam123mir/Skywars-Script-Bloxy-Hub)
- [Discord](discord.gg/example)
- [Documentación](https://github.com/Sam123mir/Skywars-Script-Bloxy-Hub/wiki)

---

<div align="center">

**Hecho con ❤️ por 16bitplayer**

![Footer](https://img.shields.io/badge/BloxyHub-v2.0-6366F1?style=for-the-badge&logo=lua)

</div>
