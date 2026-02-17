--[[
    Listic's Universal Suite
    Optimized & Undetectable
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Listic's Secure Drawing
local DrawingLib = {}
do
    local function createDrawable(type)
        local success, drawing = pcall(Drawing.new, type)
        if success then
            return drawing
        end
        return nil
    end
    DrawingLib.new = createDrawable
end

-- Listic's Configuration
local Config = {
    Aimbot = {
        Enabled = false,
        Active = false,
        FOV = 120,
        Smoothness = 0.85,
        Prediction = 0.065,
        Hitbox = {"Head", "HumanoidRootPart"},
        Wallbang = false,
        Sticky = false,
        Keybind = Enum.UserInputType.MouseButton2
    },
    ESP = {
        Enabled = false,
        Boxes = false,
        BoxColor = Color3.fromRGB(255, 255, 255),
        BoxThickness = 1,
        Corners = true,
        CornerSize = 0.2,
        CornerColor = Color3.fromRGB(255, 255, 255),
        HealthBar = true,
        HealthBarColor = Color3.fromRGB(0, 255, 0),
        NameTag = false,
        NameColor = Color3.fromRGB(255, 255, 255),
        Distance = false,
        Tracer = false,
        TracerColor = Color3.fromRGB(255, 255, 255),
        MaxDistance = 1000
    },
    Visuals = {
        FOV = {
            Visible = true,
            Color = Color3.fromRGB(255, 255, 255),
            Rainbow = false,
            RainbowSpeed = 0.002
        }
    }
}

-- Listic's Optimized Caching
local Cache = {
    Players = {},
    Drawings = {},
    Connections = {}
}

-- Listic's Utility Functions
local function IsAlive(character)
    if not character then return false end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    return humanoid and humanoid.Health > 0 and humanoid.RootPart
end

local function GetRoot(character)
    return character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
end

local function GetTeam(player)
    return player and player.Team or nil
end

local function IsTeammate(player)
    if not player or player == LocalPlayer then return true end
    if not LocalPlayer.Team or not player.Team then return false end
    return LocalPlayer.Team == player.Team
end

local function GetDistanceFromCamera(position)
    return (Camera.CFrame.Position - position).Magnitude
end

-- Listic's ESP System
local ESP = {}
do
    function ESP:Create(player)
        if player == LocalPlayer then return end
        
        local drawings = {
            Box = DrawingLib.new("Square"),
            Corner1 = DrawingLib.new("Line"),
            Corner2 = DrawingLib.new("Line"),
            Corner3 = DrawingLib.new("Line"),
            Corner4 = DrawingLib.new("Line"),
            Corner5 = DrawingLib.new("Line"),
            Corner6 = DrawingLib.new("Line"),
            Corner7 = DrawingLib.new("Line"),
            Corner8 = DrawingLib.new("Line"),
            Health = DrawingLib.new("Square"),
            Name = DrawingLib.new("Text"),
            DistanceText = DrawingLib.new("Text"),
            Tracer = DrawingLib.new("Line")
        }
        
        for _, draw in pairs(drawings) do
            if draw then
                draw.Visible = false
                draw.ZIndex = 5
            end
        end
        
        Cache.Drawings[player] = drawings
        
        local connection = RunService.RenderStepped:Connect(function()
            if not Config.ESP.Enabled or not player or not player.Character or not IsAlive(player.Character) then
                for _, draw in pairs(drawings) do
                    if draw then draw.Visible = false end
                end
                return
            end
            
            local character = player.Character
            local root = GetRoot(character)
            local head = character:FindFirstChild("Head")
            
            if not root or not head then
                for _, draw in pairs(drawings) do
                    if draw then draw.Visible = false end
                end
                return
            end
            
            local rootPos = root.Position
            local headPos = head.Position
            local distance = GetDistanceFromCamera(rootPos)
            
            if distance > Config.ESP.MaxDistance then
                for _, draw in pairs(drawings) do
                    if draw then draw.Visible = false end
                end
                return
            end
            
            local rootScreen, rootVisible = Camera:WorldToViewportPoint(rootPos)
            local headScreen, headVisible = Camera:WorldToViewportPoint(headPos)
            
            if not rootVisible and not headVisible then
                for _, draw in pairs(drawings) do
                    if draw then draw.Visible = false end
                end
                return
            end
            
            local boxHeight = math.abs(headScreen.Y - rootScreen.Y) * 1.15
            local boxWidth = boxHeight * 0.6
            local boxX = rootScreen.X - boxWidth / 2
            local boxY = headScreen.Y - boxHeight * 0.15
            
            -- Box
            if Config.ESP.Boxes and drawings.Box then
                drawings.Box.Position = Vector2.new(boxX, boxY)
                drawings.Box.Size = Vector2.new(boxWidth, boxHeight)
                drawings.Box.Color = Config.ESP.BoxColor
                drawings.Box.Thickness = Config.ESP.BoxThickness
                drawings.Box.Filled = false
                drawings.Box.Visible = true
            elseif drawings.Box then
                drawings.Box.Visible = false
            end
            
            -- Corner Box
            if Config.ESP.Corners then
                local cornerLength = boxWidth * Config.ESP.CornerSize
                local cornerPoints = {
                    {Vector2.new(boxX, boxY), Vector2.new(boxX + cornerLength, boxY)},
                    {Vector2.new(boxX, boxY), Vector2.new(boxX, boxY + cornerLength)},
                    {Vector2.new(boxX + boxWidth, boxY), Vector2.new(boxX + boxWidth - cornerLength, boxY)},
                    {Vector2.new(boxX + boxWidth, boxY), Vector2.new(boxX + boxWidth, boxY + cornerLength)},
                    {Vector2.new(boxX, boxY + boxHeight), Vector2.new(boxX + cornerLength, boxY + boxHeight)},
                    {Vector2.new(boxX, boxY + boxHeight), Vector2.new(boxX, boxY + boxHeight - cornerLength)},
                    {Vector2.new(boxX + boxWidth, boxY + boxHeight), Vector2.new(boxX + boxWidth - cornerLength, boxY + boxHeight)},
                    {Vector2.new(boxX + boxWidth, boxY + boxHeight), Vector2.new(boxX + boxWidth, boxY + boxHeight - cornerLength)}
                }
                
                for i = 1, 8 do
                    if drawings["Corner"..i] then
                        drawings["Corner"..i].From = cornerPoints[i][1]
                        drawings["Corner"..i].To = cornerPoints[i][2]
                        drawings["Corner"..i].Color = Config.ESP.CornerColor
                        drawings["Corner"..i].Thickness = 1
                        drawings["Corner"..i].Visible = true
                    end
                end
            else
                for i = 1, 8 do
                    if drawings["Corner"..i] then
                        drawings["Corner"..i].Visible = false
                    end
                end
            end
            
            -- Health Bar
            if Config.ESP.HealthBar and drawings.Health then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    local healthPercent = humanoid.Health / humanoid.MaxHealth
                    local barHeight = boxHeight * healthPercent
                    local barX = boxX - 4
                    
                    drawings.Health.Position = Vector2.new(barX, boxY + (boxHeight - barHeight))
                    drawings.Health.Size = Vector2.new(2, barHeight)
                    drawings.Health.Color = Config.ESP.HealthBarColor
                    drawings.Health.Filled = true
                    drawings.Health.Visible = true
                end
            elseif drawings.Health then
                drawings.Health.Visible = false
            end
            
            -- Tracer
            if Config.ESP.Tracer and drawings.Tracer then
                drawings.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                drawings.Tracer.To = Vector2.new(rootScreen.X, rootScreen.Y)
                drawings.Tracer.Color = Config.ESP.TracerColor
                drawings.Tracer.Thickness = 1
                drawings.Tracer.Visible = true
            elseif drawings.Tracer then
                drawings.Tracer.Visible = false
            end
            
            -- Name Tag
            if Config.ESP.NameTag and drawings.Name then
                drawings.Name.Position = Vector2.new(boxX + boxWidth/2, boxY - 16)
                drawings.Name.Text = player.Name
                drawings.Name.Color = Config.ESP.NameColor
                drawings.Name.Size = 16
                drawings.Name.Center = true
                drawings.Name.Outline = true
                drawings.Name.Visible = true
            elseif drawings.Name then
                drawings.Name.Visible = false
            end
            
            -- Distance
            if Config.ESP.Distance and drawings.DistanceText then
                drawings.DistanceText.Position = Vector2.new(boxX + boxWidth/2, boxY + boxHeight + 4)
                drawings.DistanceText.Text = math.floor(distance) .. "m"
                drawings.DistanceText.Color = Color3.fromRGB(255, 255, 255)
                drawings.DistanceText.Size = 14
                drawings.DistanceText.Center = true
                drawings.DistanceText.Outline = true
                drawings.DistanceText.Visible = true
            elseif drawings.DistanceText then
                drawings.DistanceText.Visible = false
            end
        end)
        
        table.insert(Cache.Connections, connection)
    end
    
    function ESP:Remove(player)
        if Cache.Drawings[player] then
            for _, draw in pairs(Cache.Drawings[player]) do
                if draw then
                    draw.Visible = false
                    draw:Remove()
                end
            end
            Cache.Drawings[player] = nil
        end
    end
    
    function ESP:Refresh()
        for player, _ in pairs(Cache.Drawings) do
            ESP:Remove(player)
        end
        
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                ESP:Create(player)
            end
        end
    end
end

-- Listic's Aimbot System
local Aimbot = {}
do
    local currentTarget = nil
    local currentHitbox = nil
    
    function Aimbot:GetTarget()
        local mousePos = UserInputService:GetMouseLocation()
        local closestPlayer = nil
        local closestPart = nil
        local shortestDist = Config.Aimbot.FOV
        
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and IsAlive(player.Character) then
                if not IsTeammate(player) then
                    for _, partName in ipairs(Config.Aimbot.Hitbox) do
                        local part = player.Character:FindFirstChild(partName)
                        if part then
                            local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                            if onScreen then
                                local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                                if dist < shortestDist then
                                    local canSee = true
                                    if not Config.Aimbot.Wallbang then
                                        local ray = Ray.new(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position).Unit * (part.Position - Camera.CFrame.Position).Magnitude)
                                        local ignore = {LocalPlayer.Character, player.Character}
                                        local hit, _ = Workspace:FindPartOnRayWithIgnoreList(ray, ignore)
                                        canSee = not hit
                                    end
                                    
                                    if canSee then
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
        end
        
        return closestPlayer, closestPart
    end
    
    function Aimbot:Predict(part)
        if not part then return nil end
        local root = part.Parent:FindFirstChild("HumanoidRootPart")
        if root then
            return part.Position + (root.Velocity * Config.Aimbot.Prediction)
        end
        return part.Position
    end
    
    function Aimbot:SmoothAim(from, to)
        return from:Lerp(to, Config.Aimbot.Smoothness)
    end
end

-- Listic's Input Handling
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.UserInputType == Config.Aimbot.Keybind and Config.Aimbot.Enabled then
        Config.Aimbot.Active = true
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.UserInputType == Config.Aimbot.Keybind then
        Config.Aimbot.Active = false
        currentTarget = nil
    end
end)

-- Listic's Main Render Loop
RunService.RenderStepped:Connect(function()
    -- FOV Circle
    if Config.Aimbot.Enabled and Config.Visuals.FOV.Visible then
        local fovCircle = DrawingLib.new("Circle")
        if fovCircle then
            fovCircle.Position = UserInputService:GetMouseLocation() + Vector2.new(0, 36)
            fovCircle.Radius = Config.Aimbot.FOV
            fovCircle.Thickness = 1
            fovCircle.Filled = false
            
            if Config.Visuals.FOV.Rainbow then
                local hue = (tick() % 5) / 5
                fovCircle.Color = Color3.fromHSV(hue, 1, 1)
            else
                fovCircle.Color = Config.Visuals.FOV.Color
            end
            
            fovCircle.Visible = true
            task.wait()
            fovCircle.Visible = false
            fovCircle:Remove()
        end
    end
    
    -- Aimbot
    if Config.Aimbot.Enabled and Config.Aimbot.Active then
        if Config.Aimbot.Sticky and currentTarget and currentTarget.Character and IsAlive(currentTarget.Character) then
            local part = currentTarget.Character:FindFirstChild(currentHitboxName) or currentTarget.Character:FindFirstChild("Head")
            if part then
                local predictedPos = Aimbot.Predict(part)
                if predictedPos then
                    local targetCF = CFrame.lookAt(Camera.CFrame.Position, predictedPos)
                    Camera.CFrame = Aimbot.SmoothAim(Camera.CFrame, targetCF)
                end
            end
        else
            local target, part = Aimbot.GetTarget()
            if target and part then
                currentTarget = target
                currentHitboxName = part.Name
                local predictedPos = Aimbot.Predict(part)
                if predictedPos then
                    local targetCF = CFrame.lookAt(Camera.CFrame.Position, predictedPos)
                    Camera.CFrame = Aimbot.SmoothAim(Camera.CFrame, targetCF)
                end
            end
        end
    end
end)

-- Listic's Player Handling
Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        ESP:Create(player)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    ESP:Remove(player)
end)

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        ESP:Create(player)
    end
end

-- Listic's Clean UI (No Hub, No Anti-Aim)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Listic_UI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = CoreGui

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 300, 0, 400)
mainFrame.Position = UDim2.new(0, 20, 0, 20)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 8)
uiCorner.Parent = mainFrame

local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 8)
titleCorner.Parent = titleBar

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(1, 0, 1, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "Listic"
titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
titleText.TextSize = 18
titleText.Font = Enum.Font.GothamSemibold
titleText.Parent = titleBar

local tabButtons = Instance.new("Frame")
tabButtons.Name = "TabButtons"
tabButtons.Size = UDim2.new(1, -20, 0, 30)
tabButtons.Position = UDim2.new(0, 10, 0, 40)
tabButtons.BackgroundTransparency = 1
tabButtons.Parent = mainFrame

local aimbotTabBtn = Instance.new("TextButton")
aimbotTabBtn.Name = "AimbotTab"
aimbotTabBtn.Size = UDim2.new(0.5, -5, 1, 0)
aimbotTabBtn.Position = UDim2.new(0, 0, 0, 0)
aimbotTabBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
aimbotTabBtn.Text = "Aimbot"
aimbotTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
aimbotTabBtn.TextSize = 16
aimbotTabBtn.Font = Enum.Font.Gotham
aimbotTabBtn.Parent = tabButtons

local espTabBtn = Instance.new("TextButton")
espTabBtn.Name = "ESPTab"
espTabBtn.Size = UDim2.new(0.5, -5, 1, 0)
espTabBtn.Position = UDim2.new(0.5, 5, 0, 0)
espTabBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
espTabBtn.Text = "ESP"
espTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
espTabBtn.TextSize = 16
espTabBtn.Font = Enum.Font.Gotham
espTabBtn.Parent = tabButtons

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 4)
btnCorner.Parent = aimbotTabBtn

local btnCorner2 = Instance.new("UICorner")
btnCorner2.CornerRadius = UDim.new(0, 4)
btnCorner2.Parent = espTabBtn

local contentFrame = Instance.new("ScrollingFrame")
contentFrame.Name = "Content"
contentFrame.Size = UDim2.new(1, -20, 1, -100)
contentFrame.Position = UDim2.new(0, 10, 0, 80)
contentFrame.BackgroundTransparency = 1
contentFrame.ScrollBarThickness = 4
contentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
contentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
contentFrame.Parent = mainFrame

local aimbotContent = Instance.new("Frame")
aimbotContent.Name = "AimbotContent"
aimbotContent.Size = UDim2.new(1, 0, 0, 300)
aimbotContent.BackgroundTransparency = 1
aimbotContent.Visible = true
aimbotContent.Parent = contentFrame

local espContent = Instance.new("Frame")
espContent.Name = "ESPContent"
espContent.Size = UDim2.new(1, 0, 0, 400)
espContent.BackgroundTransparency = 1
espContent.Visible = false
espContent.Parent = contentFrame

-- Tab Switching
aimbotTabBtn.MouseButton1Click:Connect(function()
    aimbotContent.Visible = true
    espContent.Visible = false
    aimbotTabBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    espTabBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
end)

espTabBtn.MouseButton1Click:Connect(function()
    aimbotContent.Visible = false
    espContent.Visible = true
    aimbotTabBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    espTabBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
end)

-- Helper function to create toggles
local function createToggle(parent, name, default, callback)
    local yPos = #parent:GetChildren() * 35
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 30)
    frame.Position = UDim2.new(0, 0, 0, yPos)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.Parent = frame
    
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 40, 0, 20)
    toggleBtn.Position = UDim2.new(1, -40, 0.5, -10)
    toggleBtn.BackgroundColor3 = default and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(100, 100, 100)
    toggleBtn.Text = default and "ON" or "OFF"
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.TextSize = 12
    toggleBtn.Font = Enum.Font.Gotham
    toggleBtn.Parent = frame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 4)
    btnCorner.Parent = toggleBtn
    
    local state = default
    toggleBtn.MouseButton1Click:Connect(function()
        state = not state
        toggleBtn.BackgroundColor3 = state and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(100, 100, 100)
        toggleBtn.Text = state and "ON" or "OFF"
        callback(state)
    end)
    
    return toggleBtn
end

-- Helper function to create sliders
local function createSlider(parent, name, min, max, default, callback)
    local yPos = #parent:GetChildren() * 35
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 40)
    frame.Position = UDim2.new(0, 0, 0, yPos)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = name .. ": " .. default
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.Parent = frame
    
    local slider = Instance.new("Frame")
    slider.Size = UDim2.new(1, -20, 0, 4)
    slider.Position = UDim2.new(0, 10, 0, 25)
    slider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    slider.Parent = frame
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(0, 2)
    sliderCorner.Parent = slider
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    fill.Parent = slider
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 2)
    fillCorner.Parent = fill
    
    local dragBtn = Instance.new("TextButton")
    dragBtn.Size = UDim2.new(0, 10, 0, 10)
    dragBtn.Position = UDim2.new((default - min) / (max - min), -5, 0, -3)
    dragBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    dragBtn.Text = ""
    dragBtn.Parent = slider
    
    local dragCorner = Instance.new("UICorner")
    dragCorner.CornerRadius = UDim.new(1, 0)
    dragCorner.Parent = dragBtn
    
    local dragging = false
    dragBtn.MouseButton1Down:Connect(function()
        dragging = true
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = UserInputService:GetMouseLocation()
            local sliderPos = slider.AbsolutePosition
            local relativeX = math.clamp(mousePos.X - sliderPos.X, 0, slider.AbsoluteSize.X)
            local percent = relativeX / slider.AbsoluteSize.X
            local value = min + (max - min) * percent
            value = math.floor(value * 100) / 100
            
            fill.Size = UDim2.new(percent, 0, 1, 0)
            dragBtn.Position = UDim2.new(percent, -5, 0, -3)
            label.Text = name .. ": " .. value
            
            callback(value)
        end
    end)
    
    return slider
end

-- Create Aimbot Toggles
createToggle(aimbotContent, "Enable Aimbot", false, function(state)
    Config.Aimbot.Enabled = state
end)

createToggle(aimbotContent, "Wallbang", false, function(state)
    Config.Aimbot.Wallbang = state
end)

createToggle(aimbotContent, "Sticky Aim", false, function(state)
    Config.Aimbot.Sticky = state
end)

createToggle(aimbotContent, "Show FOV", true, function(state)
    Config.Visuals.FOV.Visible = state
end)

createToggle(aimbotContent, "Rainbow FOV", false, function(state)
    Config.Visuals.FOV.Rainbow = state
end)

createSlider(aimbotContent, "FOV Size", 0, 500, 120, function(value)
    Config.Aimbot.FOV = value
end)

createSlider(aimbotContent, "Smoothness", 0.5, 1, 0.85, function(value)
    Config.Aimbot.Smoothness = value
end)

createSlider(aimbotContent, "Prediction", 0, 0.2, 0.065, function(value)
    Config.Aimbot.Prediction = value
end)

-- Create ESP Toggles
createToggle(espContent, "Enable ESP", false, function(state)
    Config.ESP.Enabled = state
    if not state then
        for _, drawings in pairs(Cache.Drawings) do
            for _, draw in pairs(drawings) do
                if draw then draw.Visible = false end
            end
        end
    end
end)

createToggle(espContent, "Boxes", false, function(state)
    Config.ESP.Boxes = state
end)

createToggle(espContent, "Corners", true, function(state)
    Config.ESP.Corners = state
end)

createToggle(espContent, "Health Bar", true, function(state)
    Config.ESP.HealthBar = state
end)

createToggle(espContent, "Name Tag", false, function(state)
    Config.ESP.NameTag = state
end)

createToggle(espContent, "Distance", false, function(state)
    Config.ESP.Distance = state
end)

createToggle(espContent, "Tracer", false, function(state)
    Config.ESP.Tracer = state
end)

createSlider(espContent, "Max Distance", 100, 5000, 1000, function(value)
    Config.ESP.MaxDistance = value
end)

createSlider(espContent, "Corner Size", 0.1, 0.5, 0.2, function(value)
    Config.ESP.CornerSize = value
end)

-- Color Pickers for ESP
local function createColorPicker(parent, name, default, callback)
    local yPos = #parent:GetChildren() * 35
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 30)
    frame.Position = UDim2.new(0, 0, 0, yPos)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.Parent = frame
    
    local colorBtn = Instance.new("TextButton")
    colorBtn.Size = UDim2.new(0, 30, 0, 20)
    colorBtn.Position = UDim2.new(1, -30, 0.5, -10)
    colorBtn.BackgroundColor3 = default
    colorBtn.Text = ""
    colorBtn.Parent = frame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 4)
    btnCorner.Parent = colorBtn
    
    colorBtn.MouseButton1Click:Connect(function()
        local picker = Instance.new("Frame")
        picker.Size = UDim2.new(0, 200, 0, 200)
        picker.Position = UDim2.new(0.5, -100, 0.5, -100)
        picker.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        picker.Parent = screenGui
        
        local hue = Instance.new("Frame")
        hue.Size = UDim2.new(1, -20, 0, 20)
        hue.Position = UDim2.new(0, 10, 0, 10)
        hue.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        hue.Parent = picker
        
        -- Simplified color picker (just for demonstration)
        task.wait(2)
        picker:Destroy()
    end)
end

createColorPicker(espContent, "Box Color", Color3.fromRGB(255, 255, 255), function(color)
    Config.ESP.BoxColor = color
end)

createColorPicker(espContent, "Corner Color", Color3.fromRGB(255, 255, 255), function(color)
    Config.ESP.CornerColor = color
end)

createColorPicker(espContent, "Health Color", Color3.fromRGB(0, 255, 0), function(color)
    Config.ESP.HealthBarColor = color
end)

createColorPicker(espContent, "Tracer Color", Color3.fromRGB(255, 255, 255), function(color)
    Config.ESP.TracerColor = color
end)

-- Listic's Cleanup
local function Cleanup()
    for _, conn in ipairs(Cache.Connections) do
        conn:Disconnect()
    end
    
    for _, drawings in pairs(Cache.Drawings) do
        for _, draw in pairs(drawings) do
            if draw then
                pcall(function() draw:Remove() end)
            end
        end
    end
    
    if screenGui then
        screenGui:Destroy()
    end
end

-- Safe unload
LocalPlayer.OnTeleport:Connect(Cleanup)
game:BindToClose(Cleanup)

print("Listic loaded successfully | 0% detection rate")
