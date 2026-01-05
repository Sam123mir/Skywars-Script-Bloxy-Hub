--[[
    ╔════════════════════════════════════════════════════════════╗
    ║  🏃 SKYWARS ULTIMATE PRO - MOVEMENT (FIXED)                ║
    ║  Created by: SAMIR (16bitplayer) - 2026                    ║
    ║  Flight sin fall damage + Speed                            ║
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

-- Flight (FIXED - No más fall damage!)
local flightBodyVelocity, flightBodyGyro
local flightConnection
local originalGravity

function Movement:ToggleFlight(enabled)
    self.Enabled.Flight = enabled
    
    if enabled then
        task.spawn(function()
            local char = Player.Character
            if not char then
                Player.CharacterAdded:Wait()
                char = Player.Character
            end
            
            local hrp = char:WaitForChild("HumanoidRootPart", 5)
            local humanoid = char:WaitForChild("Humanoid", 5)
            
            if not hrp or not humanoid then
                warn("❌ Cannot enable Flight - Character not ready")
                return
            end
            
            -- IMPORTANTE: Guardar y desactivar fall damage
            if humanoid:FindFirstChild("FallDamageScript") then
                humanoid.FallDamageScript:Destroy()
            end
            
            -- Crear BodyVelocity
            flightBodyVelocity = Instance.new("BodyVelocity")
            flightBodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            flightBodyVelocity.Velocity = Vector3.new(0, 0, 0)
            flightBodyVelocity.Parent = hrp
            
            -- Crear BodyGyro
            flightBodyGyro = Instance.new("BodyGyro")
            flightBodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
            flightBodyGyro.P = 10000
            flightBodyGyro.Parent = hrp
            
            -- Controles de vuelo
            if flightConnection then flightConnection:Disconnect() end
            
            flightConnection = RunService.Heartbeat:Connect(function()
                if not self.Enabled.Flight or not char or not char.Parent or not hrp or not hrp.Parent then
                    return
                end
                
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
                
                if flightBodyVelocity and flightBodyVelocity.Parent then
                    if direction.Magnitude > 0 then
                        flightBodyVelocity.Velocity = direction.Unit * self.Settings.FlightSpeed
                    else
                        flightBodyVelocity.Velocity = Vector3.new(0, 0, 0)
                    end
                end
                
                if flightBodyGyro and flightBodyGyro.Parent then
                    flightBodyGyro.CFrame = camera.CFrame
                end
            end)
            
            print("✅ Flight: ENABLED")
            print("💡 Controls: WASD + Space (up) + Shift (down)")
            print("🛡️ Fall damage: DISABLED")
        end)
    else
        -- Cleanup flight (FIXED - no más warnings!)
        if flightBodyVelocity and flightBodyVelocity.Parent then
            flightBodyVelocity.Parent = nil
            task.wait()
            flightBodyVelocity:Destroy()
            flightBodyVelocity = nil
        end
        if flightBodyGyro and flightBodyGyro.Parent then
            flightBodyGyro.Parent = nil
            task.wait()
            flightBodyGyro:Destroy()
            flightBodyGyro = nil
        end
        if flightConnection then
            flightConnection:Disconnect()
            flightConnection = nil
        end
        
        print("❌ Flight: DISABLED")
    end
end

-- Speed (Ya funcionaba bien)
local normalSpeed = 16
function Movement:ToggleSpeed(enabled)
    self.Enabled.Speed = enabled
    
    task.spawn(function()
        local char = Player.Character
        if not char then
            Player.CharacterAdded:Wait()
            char = Player.Character
        end
        
        local humanoid = char:WaitForChild("Humanoid", 5)
        if not humanoid then
            warn("❌ Cannot enable Speed - Humanoid not found")
            return
        end
        
        if enabled then
            humanoid.WalkSpeed = normalSpeed * self.Settings.SpeedMultiplier
            print("✅ Speed Boost: ENABLED (" .. humanoid.WalkSpeed .. ")")
        else
            humanoid.WalkSpeed = normalSpeed
            print("❌ Speed Boost: DISABLED")
        end
    end)
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
