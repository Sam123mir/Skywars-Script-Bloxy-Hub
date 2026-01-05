--[[
    ╔════════════════════════════════════════════════════════════╗
    ║  🔑 SKYWARS ULTIMATE PRO - KEY SYSTEM                      ║
    ║  Created by: SAMIR (16bitplayer) - 2026                    ║
    ║  Professional key verification                             ║
    ╚════════════════════════════════════════════════════════════╝
]]

local KeySystem = {}

-- Valid keys (puedes agregar más)
local ValidKeys = {
    ["SAMIR-2026-SKYWARS"] = {
        owner = "SAMIR",
        expiry = "2027-12-31",
        tier = "Premium"
    },
    ["DEMO-KEY-123"] = {
        owner = "Demo User",
        expiry = "2026-12-31",
        tier = "Free"
    },
    ["16BITPLAY-PRO"] = {
        owner = "16bitplay Fan",
        expiry = "2026-06-30",
        tier = "Premium"
    }
}

-- UI Creation
local function CreateKeyUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "KeySystem"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Try protected GUI
    if gethui then
        ScreenGui.Parent = gethui()
    elseif syn and syn.protect_gui then
        syn.protect_gui(ScreenGui)
        ScreenGui.Parent = game:GetService("CoreGui")
    else
        ScreenGui.Parent = game:GetService("CoreGui")
    end
    
    -- Background blur
    local Blur = Instance.new("Frame")
    Blur.Size = UDim2.new(1, 0, 1, 0)
    Blur.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Blur.BackgroundTransparency = 0.4
    Blur.BorderSizePixel = 0
    Blur.Parent = ScreenGui
    
    -- Main Container
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(0, 450, 0, 300)
    Container.Position = UDim2.new(0.5, 0, 0.5, 0)
    Container.AnchorPoint = Vector2.new(0.5, 0.5)
    Container.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    Container.BorderSizePixel = 0
    Container.Parent = Blur
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 12)
    UICorner.Parent = Container
    
    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Color3.fromRGB(109, 112, 255)
    UIStroke.Thickness = 2
    UIStroke.Transparency = 0.5
    UIStroke.Parent = Container
    
    -- Title
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 60)
    Title.BackgroundTransparency = 1
    Title.Text = "⚔️ SKYWARS ULTIMATE PRO"
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 24
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.Parent = Container
    
    -- Subtitle
    local Subtitle = Instance.new("TextLabel")
    Subtitle.Size = UDim2.new(1, 0, 0, 20)
    Subtitle.Position = UDim2.new(0, 0, 0, 60)
    Subtitle.BackgroundTransparency = 1
    Subtitle.Text = "by SAMIR (16bitplayer) - 2026"
    Subtitle.Font = Enum.Font.Gotham
    Subtitle.TextSize = 14
    Subtitle.TextColor3 = Color3.fromRGB(170, 170, 180)
    Subtitle.Parent = Container
    
    -- Info Label
    local Info = Instance.new("TextLabel")
    Info.Size = UDim2.new(1, -40, 0, 40)
    Info.Position = UDim2.new(0, 20, 0, 100)
    Info.BackgroundTransparency = 1
    Info.Text = "🔑 Please enter your key to continue"
    Info.Font = Enum.Font.Gotham
    Info.TextSize = 16
    Info.TextColor3 = Color3.fromRGB(200, 200, 200)
    Info.TextWrapped = true
    Info.Parent = Container
    
    -- Key Input Box
    local KeyBox = Instance.new("TextBox")
    KeyBox.Size = UDim2.new(1, -40, 0, 50)
    KeyBox.Position = UDim2.new(0, 20, 0, 150)
    KeyBox.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    KeyBox.BorderSizePixel = 0
    KeyBox.Text = ""
    KeyBox.PlaceholderText = "Enter key here..."
    KeyBox.Font = Enum.Font.Code
    KeyBox.TextSize = 16
    KeyBox.TextColor3 = Color3.new(1, 1, 1)
    KeyBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 130)
    KeyBox.ClearTextOnFocus = false
    KeyBox.Parent = Container
    
    local KeyBoxCorner = Instance.new("UICorner")
    KeyBoxCorner.CornerRadius = UDim.new(0, 8)
    KeyBoxCorner.Parent = KeyBox
    
    local KeyBoxStroke = Instance.new("UIStroke")
    KeyBoxStroke.Color = Color3.fromRGB(50, 50, 55)
    KeyBoxStroke.Thickness = 1.5
    KeyBoxStroke.Parent = KeyBox
    
    -- Submit Button
    local SubmitBtn = Instance.new("TextButton")
    SubmitBtn.Size = UDim2.new(1, -40, 0, 50)
    SubmitBtn.Position = UDim2.new(0, 20, 0, 220)
    SubmitBtn.BackgroundColor3 = Color3.fromRGB(109, 112, 255)
    SubmitBtn.BorderSizePixel = 0
    SubmitBtn.Text = "✓ VERIFY KEY"
    SubmitBtn.Font = Enum.Font.GothamBold
    SubmitBtn.TextSize = 18
    SubmitBtn.TextColor3 = Color3.new(1, 1, 1)
    SubmitBtn.AutoButtonColor = false
    SubmitBtn.Parent = Container
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 8)
    BtnCorner.Parent = SubmitBtn
    
    local BtnGradient = Instance.new("UIGradient")
    BtnGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(109, 112, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(149, 102, 255))
    }
    BtnGradient.Rotation = 45
    BtnGradient.Parent = SubmitBtn
    
    -- Make window draggable
    local dragging = false
    local dragInput, dragStart, startPos
    local UserInputService = game:GetService("UserInputService")
    
    local function update(input)
        local delta = input.Position - dragStart
        Container.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
    
    Container.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Container.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    Container.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or
           input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            update(input)
        end
    end)
    
    return ScreenGui, KeyBox, SubmitBtn, Info, Container
end

-- Verify key function
function KeySystem:Verify(callback)
    local Gui, KeyBox, SubmitBtn, Info, Container = CreateKeyUI()
    
    -- Intro animation
    if Container then
        Container.Size = UDim2.new(0, 0, 0, 0)
        Container:TweenSize(UDim2.new(0, 450, 0, 300), Enum.EasingDirection.Out, Enum.EasingStyle.Back, 0.5, true)
    end
    
    local function checkKey()
        local key = KeyBox.Text
        
        if ValidKeys[key] then
            local keyData = ValidKeys[key]
            Info.Text = "✅ Key verified! Loading script..."
            Info.TextColor3 = Color3.fromRGB(26, 195, 139)
            
            task.wait(1)
            
            -- Destroy key UI
            Gui:Destroy()
            
            -- Call success callback
            if callback then
                callback(keyData)
            end
        else
            Info.Text = "❌ Invalid key! Please try again."
            Info.TextColor3 = Color3.fromRGB(249, 78, 78)
            
            -- Shake animation
            local originalPos = Container.Position
            for i = 1, 6 do
                Container.Position = UDim2.new(0.5, math.random(-10, 10), 0.5, 0)
                task.wait(0.05)
            end
            Container.Position = originalPos
        end
    end
    
    SubmitBtn.MouseButton1Click:Connect(checkKey)
    KeyBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            checkKey()
        end
    end)
    
    -- Hover effects
    SubmitBtn.MouseEnter:Connect(function()
        SubmitBtn:TweenSize(UDim2.new(1, -40, 0, 54), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
    end)
    
    SubmitBtn.MouseLeave:Connect(function()
        SubmitBtn:TweenSize(UDim2.new(1, -40, 0, 50), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
    end)
end

-- Get valid keys (for display/documentation)
function KeySystem:GetValidKeys()
    local keys = {}
    for key, data in pairs(ValidKeys) do
        table.insert(keys, {
            Key = key,
            Owner = data.owner,
            Tier = data.tier,
            Expiry = data.expiry
        })
    end
    return keys
end

return KeySystem
