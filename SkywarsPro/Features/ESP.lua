--[[
    ╔════════════════════════════════════════════════════════════╗
    ║  👁️ SK YWARS ULTIMATE PRO - ESP FEATURES                   ║
    ║  Created by: SAMIR (16bitplayer) - 2026                    ║
    ║  Player ESP with boxes and info                            ║
    ╚════════════════════════════════════════════════════════════╝
]]

local ESP = {}
ESP.Enabled = {
    Players = false,
    Health = false,
    Distance = false
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Player = Players.LocalPlayer

local espObjects = {}

-- Create ESP for a player
local function createESP(player)
    if player == Player then return end
    
    local esp = {
        Player = player,
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Health = Drawing.new("Text"),
        Distance = Drawing.new("Text")
    }
    
    -- Box settings
    esp.Box.Thickness = 2
    esp.Box.Filled = false
    esp.Box.Color = Color3.new(1, 0, 0)
    esp.Box.Transparency = 1
    esp.Box.Visible = false
    
    -- Name settings
    esp.Name.Size = 14
    esp.Name.Center = true
    esp.Name.Outline = true
    esp.Name.Color = Color3.new(1, 1, 1)
    esp.Name.Visible = false
    
    -- Health settings
    esp.Health.Size = 12
    esp.Health.Center = true
    esp.Health.Outline = true
    esp.Health.Color = Color3.new(0, 1, 0)
    esp.Health.Visible = false
    
    -- Distance settings
    esp.Distance.Size = 12
    esp.Distance.Center = true
    esp.Distance.Outline = true
    esp.Distance.Color = Color3.new(1, 1, 1)
    esp.Distance.Visible = false
    
    espObjects[player] = esp
end

-- Update ESP
local updateConnection
local function updateESP()
    for player, esp in pairs(espObjects) do
        if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") then
            local hrp = player.Character.HumanoidRootPart
            local humanoid = player.Character.Humanoid
            
            local vector, onScreen = workspace.CurrentCamera:WorldToViewportPoint(hrp.Position)
            
            if onScreen and ESP.Enabled.Players then
                -- Calculate size
                local distance = (Player.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
                local scaleFactor = 1 / (distance / 100)
                local size = Vector2.new(2000 / distance, 3000 / distance)
                
                -- Update box
                esp.Box.Size = size
                esp.Box.Position = Vector2.new(vector.X - size.X / 2, vector.Y - size.Y / 2)
                esp.Box.Visible = true
                
                -- Update name
                esp.Name.Text = player.Name
                esp.Name.Position = Vector2.new(vector.X, vector.Y - size.Y / 2 - 15)
                esp.Name.Visible = true
                
                -- Update health
                if ESP.Enabled.Health then
                    local healthPercent = math.floor((humanoid.Health / humanoid.MaxHealth) * 100)
                    esp.Health.Text = healthPercent .. "% HP"
                    esp.Health.Position = Vector2.new(vector.X, vector.Y + size.Y / 2 + 5)
                    esp.Health.Color = Color3.new(1 - (healthPercent / 100), healthPercent / 100, 0)
                    esp.Health.Visible = true
                else
                    esp.Health.Visible = false
                end
                
                -- Update distance
                if ESP.Enabled.Distance then
                    esp.Distance.Text = math.floor(distance) .. " studs"
                    esp.Distance.Position = Vector2.new(vector.X, vector.Y + size.Y / 2 + 20)
                    esp.Distance.Visible = true
                else
                    esp.Distance.Visible = false
                end
            else
                esp.Box.Visible = false
                esp.Name.Visible = false
                esp.Health.Visible = false
                esp.Distance.Visible = false
            end
        else
            esp.Box.Visible = false
            esp.Name.Visible = false
            esp.Health.Visible = false
            esp.Distance.Visible = false
        end
    end
end

-- Toggle ESP
function ESP:TogglePlayerESP(enabled)
    self.Enabled.Players = enabled
    
    if enabled then
        -- Create ESP for all players
        for _, player in ipairs(Players:GetPlayers()) do
            if not espObjects[player] then
                createESP(player)
            end
        end
        
        -- Update loop
        if not updateConnection then
            updateConnection = RunService.Heartbeat:Connect(updateESP)
        end
        
        print("✅ Player ESP: ENABLED")
    else
        -- Hide all ESP
        for _, esp in pairs(espObjects) do
            esp.Box.Visible = false
            esp.Name.Visible = false
            esp.Health.Visible = false
            esp.Distance.Visible = false
        end
        
        print("❌ Player ESP: DISABLED")
    end
end

function ESP:ToggleHealth(enabled)
    self.Enabled.Health = enabled
    print(enabled and "✅ Health Bars: ENABLED" or "❌ Health Bars: DISABLED")
end

function ESP:ToggleDistance(enabled)
    self.Enabled.Distance = enabled
    print(enabled and "✅ Distance: ENABLED" or "❌ Distance: DISABLED")
end

-- Handle player added/removed
Players.PlayerAdded:Connect(function(player)
    createESP(player)
end)

Players.PlayerRemoving:Connect(function(player)
    if espObjects[player] then
        for _, drawing in pairs(espObjects[player]) do
            if drawing.Remove then
                drawing:Remove()
            end
        end
        espObjects[player] = nil
    end
end)

-- Cleanup
function ESP:Cleanup()
    if updateConnection then
        updateConnection:Disconnect()
    end
    
    for _, esp in pairs(espObjects) do
        for _, drawing in pairs(esp) do
            if drawing.Remove then
                drawing:Remove()
            end
        end
    end
    
    espObjects = {}
end

return ESP
