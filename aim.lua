--[[
    Universal Aimbot
    Created by Listic
    Optimized & Enhanced Version
]]

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Listic's Configuration System
local Config = {
    Aimbot = {
        Enabled = false,
        Aiming = false,
        FOV = 100,
        Smoothing = 0.95,
        Prediction = 0.065,
        Parts = {"Head"},
        WallCheck = true,
        StickyAim = false,
        TeamCheck = false,
        HealthCheck = false,
        MinHealth = 0,
        Target = nil,
        TargetPart = nil
    },
    
    Visuals = {
        FOV = {
            Visible = false,
            Color = Color3.fromRGB(255, 0, 0),
            TargetedColor = Color3.fromRGB(0, 255, 0),
            Rainbow = false,
            RainbowSpeed = 0.005,
            Hue = 0
        }
    },
    
    AntiAim = {
        Enabled = false,
        Method = "Reset Velo",
        Amount = Vector3.new(0, -100, 0),
        RandomRange = 100
    },
    
    Misc = {
        Spinbot = {
            Enabled = false,
            Speed = 20
        }
    }
}

-- Listic's Character Management
local Character = {
    Root = nil,
    Humanoid = nil
}

local function updateCharacter()
    if LocalPlayer.Character then
        Character.Root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        Character.Humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
    end
end

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    updateCharacter()
end)

updateCharacter()

-- Listic's Drawing System
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.Radius = Config.Aimbot.FOV
FOVCircle.Filled = false
FOVCircle.Color = Config.Visuals.FOV.Color
FOVCircle.Visible = false

-- Listic's Team Check
local function isEnemy(player)
    if player == LocalPlayer then return false end
    if Config.Aimbot.TeamCheck and player.Team == LocalPlayer.Team then
        return false
    end
    return true
end

-- Listic's Wall Check
local function isVisible(targetPart)
    if not Config.Aimbot.WallCheck then return true end
    if not targetPart then return false end
    
    local origin = Camera.CFrame.Position
    local direction = (targetPart.Position - origin).Unit * (targetPart.Position - origin).Magnitude
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    
    local result = Workspace:Raycast(origin, direction, raycastParams)
    return result == nil
end

-- Listic's Target Acquisition
local function getTarget()
    local mousePos = UserInputService:GetMouseLocation()
    local closestPlayer = nil
    local closestPart = nil
    local shortestDist = Config.Aimbot.FOV
    
    for _, player in ipairs(Players:GetPlayers()) do
        if isEnemy(player) and player.Character and player.Character:FindFirstChild("Humanoid") then
            local humanoid = player.Character.Humanoid
            if humanoid.Health > 0 and (humanoid.Health >= Config.Aimbot.MinHealth or not Config.Aimbot.HealthCheck) then
                
                for _, partName in ipairs(Config.Aimbot.Parts) do
                    local part = player.Character:FindFirstChild(partName)
                    if part then
                        local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                        if onScreen then
                            local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                            if dist < shortestDist and isVisible(part) then
                                shortestDist = dist
                                closestPlayer = player
                                closestPart = part
                            end
                        end
                    end
                end
            end
        end
    end
    
    return closestPlayer, closestPart
end

-- Listic's Prediction System
local function predictPosition(part)
    if not part or not part.Parent then return part.Position end
    
    local root = part.Parent:FindFirstChild("HumanoidRootPart")
    if root then
        return part.Position + (root.Velocity * Config.Aimbot.Prediction)
    end
    return part.Position
end

-- Listic's Smoothing System
local function smoothAim(from, to)
    return from:Lerp(to, Config.Aimbot.Smoothing)
end

-- Listic's Aimbot Logic
local function aimAt(target, targetPart)
    if not target or not targetPart then return end
    
    local predictedPos = predictPosition(targetPart)
    local targetCF = CFrame.lookAt(Camera.CFrame.Position, predictedPos)
    Camera.CFrame = smoothAim(Camera.CFrame, targetCF)
end

-- Listic's Render Loop
RunService.RenderStepped:Connect(function()
    -- Update FOV Circle
    if Config.Aimbot.Enabled then
        FOVCircle.Position = UserInputService:GetMouseLocation() + Vector2.new(0, 36)
        FOVCircle.Radius = Config.Aimbot.FOV
        FOVCircle.Visible = Config.Visuals.FOV.Visible
        
        -- Rainbow FOV
        if Config.Visuals.FOV.Rainbow then
            Config.Visuals.FOV.Hue = (Config.Visuals.FOV.Hue + Config.Visuals.FOV.RainbowSpeed) % 1
            FOVCircle.Color = Color3.fromHSV(Config.Visuals.FOV.Hue, 1, 1)
        elseif Config.Aimbot.Aiming and Config.Aimbot.Target then
            FOVCircle.Color = Config.Visuals.FOV.TargetedColor
        else
            FOVCircle.Color = Config.Visuals.FOV.Color
        end
        
        -- Aimbot Logic
        if Config.Aimbot.Aiming then
            if Config.Aimbot.StickyAim and Config.Aimbot.Target then
                -- Check if target is still valid
                if not Config.Aimbot.Target.Character or 
                   not Config.Aimbot.TargetPart or 
                   not Config.Aimbot.TargetPart.Parent then
                    Config.Aimbot.Target = nil
                    Config.Aimbot.TargetPart = nil
                end
            end
            
            -- Get new target if needed
            if not Config.Aimbot.StickyAim or not Config.Aimbot.Target then
                Config.Aimbot.Target, Config.Aimbot.TargetPart = getTarget()
            end
            
            -- Aim at target
            if Config.Aimbot.Target and Config.Aimbot.TargetPart then
                aimAt(Config.Aimbot.Target, Config.Aimbot.TargetPart)
            end
        else
            Config.Aimbot.Target = nil
            Config.Aimbot.TargetPart = nil
        end
    else
        FOVCircle.Visible = false
    end
end)

-- Listic's Input Handling
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.UserInputType == Enum.UserInputType.MouseButton2 and Config.Aimbot.Enabled then
        Config.Aimbot.Aiming = true
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.UserInputType == Enum.UserInputType.MouseButton2 and Config.Aimbot.Enabled then
        Config.Aimbot.Aiming = false
    end
end)

-- Listic's Anti-Aim System
RunService.Heartbeat:Connect(function()
    if Config.AntiAim.Enabled and Character.Root then
        local currentVelo = Character.Root.Velocity
        
        if Config.AntiAim.Method == "Reset Velo" then
            Character.Root.Velocity = Config.AntiAim.Amount
            task.wait()
            Character.Root.Velocity = currentVelo
            
        elseif Config.AntiAim.Method == "Random Velo" then
            local randomVelo = Vector3.new(
                math.random(-Config.AntiAim.RandomRange, Config.AntiAim.RandomRange),
                math.random(-Config.AntiAim.RandomRange, Config.AntiAim.RandomRange),
                math.random(-Config.AntiAim.RandomRange, Config.AntiAim.RandomRange)
            )
            Character.Root.Velocity = randomVelo
            task.wait()
            Character.Root.Velocity = currentVelo
        end
    end
end)

-- Listic's UI System
local Window = Rayfield:CreateWindow({
    Name = "Listic Hub",
    LoadingTitle = "Universal Aimbot",
    LoadingSubtitle = "Created by Listic",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "ListicHub",
        FileName = "Config"
    }
})

local AimbotTab = Window:CreateTab("Aimbot")
local AntiAimTab = Window:CreateTab("Anti-Aim")
local SettingsTab = Window:CreateTab("Settings")

-- Aimbot Tab Elements
AimbotTab:CreateToggle({
    Name = "Enable Aimbot",
    CurrentValue = false,
    Flag = "AimbotEnabled",
    Callback = function(value)
        Config.Aimbot.Enabled = value
        FOVCircle.Visible = value and Config.Visuals.FOV.Visible
    end
})

AimbotTab:CreateDropdown({
    Name = "Aim Parts",
    Options = {"Head", "HumanoidRootPart", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"},
    CurrentOption = {"Head"},
    MultipleOptions = true,
    Flag = "AimParts",
    Callback = function(options)
        Config.Aimbot.Parts = options
    end
})

AimbotTab:CreateSlider({
    Name = "FOV Size",
    Range = {0, 500},
    Increment = 1,
    CurrentValue = 100,
    Flag = "FOVSize",
    Callback = function(value)
        Config.Aimbot.FOV = value
    end
})

AimbotTab:CreateSlider({
    Name = "Smoothing",
    Range = {0, 100},
    Increment = 1,
    CurrentValue = 95,
    Flag = "Smoothing",
    Callback = function(value)
        Config.Aimbot.Smoothing = value / 100
    end
})

AimbotTab:CreateSlider({
    Name = "Prediction",
    Range = {0, 20},
    Increment = 1,
    CurrentValue = 6,
    Flag = "Prediction",
    Callback = function(value)
        Config.Aimbot.Prediction = value / 100
    end
})

AimbotTab:CreateToggle({
    Name = "Wall Check",
    CurrentValue = true,
    Flag = "WallCheck",
    Callback = function(value)
        Config.Aimbot.WallCheck = value
    end
})

AimbotTab:CreateToggle({
    Name = "Sticky Aim",
    CurrentValue = false,
    Flag = "StickyAim",
    Callback = function(value)
        Config.Aimbot.StickyAim = value
    end
})

AimbotTab:CreateToggle({
    Name = "Team Check",
    CurrentValue = false,
    Flag = "TeamCheck",
    Callback = function(value)
        Config.Aimbot.TeamCheck = value
    end
})

AimbotTab:CreateToggle({
    Name = "Health Check",
    CurrentValue = false,
    Flag = "HealthCheck",
    Callback = function(value)
        Config.Aimbot.HealthCheck = value
    end
})

AimbotTab:CreateSlider({
    Name = "Minimum Health",
    Range = {0, 100},
    Increment = 1,
    CurrentValue = 0,
    Flag = "MinHealth",
    Callback = function(value)
        Config.Aimbot.MinHealth = value
    end
})

-- Visual Settings
AimbotTab:CreateToggle({
    Name = "Show FOV Circle",
    CurrentValue = true,
    Flag = "ShowFOV",
    Callback = function(value)
        Config.Visuals.FOV.Visible = value
        FOVCircle.Visible = value and Config.Aimbot.Enabled
    end
})

AimbotTab:CreateColorPicker({
    Name = "FOV Color",
    Color = Color3.fromRGB(255, 0, 0),
    Flag = "FOVColor",
    Callback = function(color)
        Config.Visuals.FOV.Color = color
    end
})

AimbotTab:CreateColorPicker({
    Name = "Targeted FOV Color",
    Color = Color3.fromRGB(0, 255, 0),
    Flag = "TargetedFOVColor",
    Callback = function(color)
        Config.Visuals.FOV.TargetedColor = color
    end
})

AimbotTab:CreateToggle({
    Name = "Rainbow FOV",
    CurrentValue = false,
    Flag = "RainbowFOV",
    Callback = function(value)
        Config.Visuals.FOV.Rainbow = value
    end
})

-- Anti-Aim Tab
AntiAimTab:CreateToggle({
    Name = "Enable Anti-Aim",
    CurrentValue = false,
    Flag = "AntiAimEnabled",
    Callback = function(value)
        Config.AntiAim.Enabled = value
    end
})

AntiAimTab:CreateDropdown({
    Name = "Anti-Aim Method",
    Options = {"Reset Velo", "Random Velo"},
    CurrentOption = "Reset Velo",
    Flag = "AntiAimMethod",
    Callback = function(option)
        Config.AntiAim.Method = option
    end
})

AntiAimTab:CreateSlider({
    Name = "X Amount",
    Range = {-1000, 1000},
    Increment = 10,
    CurrentValue = 0,
    Flag = "AntiAimX",
    Callback = function(value)
        Config.AntiAim.Amount = Vector3.new(value, Config.AntiAim.Amount.Y, Config.AntiAim.Amount.Z)
    end
})

AntiAimTab:CreateSlider({
    Name = "Y Amount",
    Range = {-1000, 1000},
    Increment = 10,
    CurrentValue = -100,
    Flag = "AntiAimY",
    Callback = function(value)
        Config.AntiAim.Amount = Vector3.new(Config.AntiAim.Amount.X, value, Config.AntiAim.Amount.Z)
    end
})

AntiAimTab:CreateSlider({
    Name = "Z Amount",
    Range = {-1000, 1000},
    Increment = 10,
    CurrentValue = 0,
    Flag = "AntiAimZ",
    Callback = function(value)
        Config.AntiAim.Amount = Vector3.new(Config.AntiAim.Amount.X, Config.AntiAim.Amount.Y, value)
    end
})

AntiAimTab:CreateSlider({
    Name = "Random Range",
    Range = {0, 500},
    Increment = 10,
    CurrentValue = 100,
    Flag = "RandomRange",
    Callback = function(value)
        Config.AntiAim.RandomRange = value
    end
})

-- Welcome Message
Rayfield:Notify({
    Title = "Listic Hub",
    Content = "Universal Aimbot Loaded Successfully!",
    Duration = 3
})

print("Listic Hub - Universal Aimbot loaded successfully")
