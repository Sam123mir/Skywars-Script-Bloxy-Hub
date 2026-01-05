--[[
    ╔════════════════════════════════════════════════════════════╗
    ║  🏃 SKYWARS ULTIMATE PRO - MOVEMENT FEATURES               ║
    ║  Created by: SAMIR (16bitplayer) - 2026                    ║
    ║  Flight, Speed, and more                                   ║
    ╚════════════════════════════════════════════════════════════╝
]]

local Movement = {}
Movement.Enabled = {
    Flight = false,
    Speed = false
}
Movement.Settings = {
    FlightSpeed = 100,
    SpeedMultiplier = 1.5
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Player = Players.LocalPlayer

-- Flight
local flightBodyVelocity, flightBodyGyro
local flightConnection

function Movement:ToggleFlight(enabled)
    self.Enabled.Flight = enabled
    
    if enabled then
        local char = Player.Character
        if not char then return end
        
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        -- Create BodyVelocity and BodyGyro
        flightBodyVelocity = Instance.new("BodyVelocity")
        flightBodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
        flightBodyVelocity.Velocity = Vector3.new(0, 0, 0)
        flightBodyVelocity.Parent = hrp
        
        flightBodyGyro = Instance.new("BodyGyro")
        flightBodyGyro.MaxTorque = Vector3.new(4000, 4000, 4000)
        flightBodyGyro.P = 1000
        flightBodyGyro.Parent = hrp
        
        -- Flight controls
        if flightConnection then flightConnection:Disconnect() end
        
        flightConnection = RunService.Heartbeat:Connect(function()
            if not self.Enabled.Flight or not char or not hrp then return end
            
            local camera = workspace.CurrentCamera
            local direction = Vector3.new(0, 0, 0)
            
            -- WASD controls
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                direction = direction + (camera.CFrame.LookVector)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                direction = direction - (camera.CFrame.LookVector)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                direction = direction - (camera.CFrame.RightVector)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                direction = direction + (camera.CFrame.RightVector)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                direction = direction + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                direction = direction - Vector3.new(0, 1, 0)
            end
            
            if flightBodyVelocity then
                flightBodyVelocity.Velocity = direction.Unit * self.Settings.FlightSpeed
            end
            if flightBodyGyro then
                flightBodyGyro.CFrame = camera.CFrame
            end
        end)
        
        print("✅ Flight: ENABLED (WASD + Space/Shift)")
    else
        if flightBodyVelocity then flightBodyVelocity:Destroy() end
        if flightBodyGyro then flightBodyGyro:Destroy() end
        if flightConnection then flightConnection:Disconnect() end
        
        flightBodyVelocity, flightBodyGyro, flightConnection = nil, nil, nil
        print("❌ Flight: DISABLED")
    end
end

-- Speed
local normalSpeed = 16
function Movement:ToggleSpeed(enabled)
    self.Enabled.Speed = enabled
    
    local char = Player.Character
    if not char then return end
    
    local humanoid = char:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    if enabled then
        humanoid.WalkSpeed = normalSpeed * self.Settings.SpeedMultiplier
        print("✅ Speed Boost: ENABLED (" .. humanoid.WalkSpeed .. ")")
    else
        humanoid.WalkSpeed = normalSpeed
        print("❌ Speed Boost: DISABLED")
    end
end

-- Set flight speed
function Movement:SetFlightSpeed(speed)
    self.Settings.FlightSpeed = speed
    print("✈️ Flight Speed:", speed)
end

-- Cleanup
function Movement:Cleanup()
    self:ToggleFlight(false)
    self:ToggleSpeed(false)
end

return Movement
