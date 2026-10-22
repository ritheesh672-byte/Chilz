-- LocalScript — StarterPlayerScripts
-- One Tap Script | Made by Chilz 🗿

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ============================================================
-- CLEANUP
-- ============================================================
if getgenv().AoidConnection then getgenv().AoidConnection:Disconnect() end
if getgenv().AoidNoclipConnection then getgenv().AoidNoclipConnection:Disconnect() end
if CoreGui:FindFirstChild("AoidRawESP") then CoreGui.AoidRawESP:Destroy() end
if CoreGui:FindFirstChild("AoidFOV") then CoreGui.AoidFOV:Destroy() end
if CoreGui:FindFirstChild("AoidHighlightFolder") then CoreGui.AoidHighlightFolder:Destroy() end

-- ============================================================
-- RAYFIELD UI
-- ============================================================
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "One Tap Script | Made by Chilz 🗿",
    LoadingTitle = "One Tap Script",
    LoadingSubtitle = "Made by Chilz",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false,
})

local CombatTab = Window:CreateTab("Combat", 4483362458)
local VisualsTab = Window:CreateTab("Visuals", 4483362458)
local LocalPlayerTab = Window:CreateTab("Local Player", 4483362458)
local ConfigTab = Window:CreateTab("Config", 4483362458)

-- ============================================================
-- SETTINGS
-- ============================================================
local Settings = {
    Aimbot = false,
    Aimlock = false,
    AimSmoothness = 0.2,
    TeamCheck = false,
    WallCheck = false,
    TargetPart = "Head",

    ESP = false,
    ESPColor = Color3.fromRGB(0, 255, 0),
    ESPName = false,
    ESPDistance = false,
    ESPBox = false,
    HighlightESP = false,
    Tracker = false,
    ShowFOV = false,
    FOVRadius = 170,

    SpeedEnabled = false,
    WalkSpeed = 50,
    JumpEnabled = false,
    JumpPower = 100,
    Noclip = false,
}

-- ============================================================
-- GUI SETUP
-- ============================================================
local ESPGui = Instance.new("ScreenGui")
ESPGui.Name = "AoidRawESP"
ESPGui.ResetOnSpawn = false
ESPGui.IgnoreGuiInset = true
ESPGui.DisplayOrder = 9999
ESPGui.Parent = CoreGui

local container = Instance.new("Frame")
container.Size = UDim2.fromScale(1, 1)
container.BackgroundTransparency = 1
container.ZIndex = 1
container.Parent = ESPGui

local HighlightFolder = Instance.new("Folder")
HighlightFolder.Name = "AoidHighlightFolder"
HighlightFolder.Parent = CoreGui

local boxes = {}
local highlights = {}

local FOVGui = Instance.new("ScreenGui")
FOVGui.Name = "AoidFOV"
FOVGui.ResetOnSpawn = false
FOVGui.IgnoreGuiInset = true
FOVGui.Parent = CoreGui

local Circle = Instance.new("Frame")
Circle.Name = "FOVCircle"
Circle.AnchorPoint = Vector2.new(0.5, 0.5)
Circle.BackgroundTransparency = 1
Circle.BorderSizePixel = 0
Circle.Visible = false
Circle.ZIndex = 1
Circle.Parent = FOVGui
Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)
local CircleStroke = Instance.new("UIStroke")
CircleStroke.Color = Color3.fromRGB(255, 255, 255)
CircleStroke.Thickness = 1.5
CircleStroke.Transparency = 0.3
CircleStroke.Parent = Circle

-- ============================================================
-- HELPERS
-- ============================================================
local function isTeammate(obj)
    if not Settings.TeamCheck then return false end
    if not LocalPlayer.Team then return false end
    local plr = Players:FindFirstChild(obj.Name) or Players:GetPlayerFromCharacter(obj)
    return plr and plr.Team == LocalPlayer.Team
end

local function updateLocalPlayer()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = Settings.SpeedEnabled and Settings.WalkSpeed or 16
        hum.UseJumpPower = true
        hum.JumpPower = Settings.JumpEnabled and Settings.JumpPower or 50
    end
end

workspace.ChildRemoved:Connect(function(child)
    if boxes[child] then
        if boxes[child].box then boxes[child].box:Destroy() end
        if boxes[child].tracker then boxes[child].tracker:Destroy() end
        boxes[child] = nil
    end
    if highlights[child] then
        if highlights[child] then highlights[child]:Destroy() end
        highlights[child] = nil
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    updateLocalPlayer()
end)

-- ============================================================
-- COMBAT TAB
-- ============================================================
CombatTab:CreateSection("Aim Settings")
CombatTab:CreateToggle({ Name = "Aimbot (Smooth)", CurrentValue = Settings.Aimbot, Flag = "Aimbot", Callback = function(v) Settings.Aimbot = v end })
CombatTab:CreateToggle({ Name = "Aimlock (Instant)", CurrentValue = Settings.Aimlock, Flag = "Aimlock", Callback = function(v) Settings.Aimlock = v end })
CombatTab:CreateSlider({ Name = "Aimbot Smoothness", Range = {0.01, 1}, Increment = 0.01, CurrentValue = Settings.AimSmoothness, Flag = "AimSmoothness", Callback = function(v) Settings.AimSmoothness = v end })
CombatTab:CreateInput({
    Name = "Type Exact Smoothness",
    CurrentValue = tostring(Settings.AimSmoothness),
    PlaceholderText = "e.g. 0.15",
    RemoveTextAfterFocusLost = false,
    Flag = "SmoothInput",
    Callback = function(Text)
        local num = tonumber(Text)
        if num then Settings.AimSmoothness = math.clamp(num, 0.01, 1) end
    end,
})

CombatTab:CreateSection("Targeting")
CombatTab:CreateDropdown({ Name = "Target Part", Options = {"Head", "HumanoidRootPart", "UpperTorso", "Torso"}, CurrentOption = {Settings.TargetPart}, Flag = "TargetPart", Callback = function(opt) Settings.TargetPart = opt[1] end })
CombatTab:CreateToggle({ Name = "Team Check", CurrentValue = Settings.TeamCheck, Flag = "TeamCheck", Callback = function(v) Settings.TeamCheck = v end })
CombatTab:CreateToggle({ Name = "Wall Check", CurrentValue = Settings.WallCheck, Flag = "WallCheck", Callback = function(v) Settings.WallCheck = v end })

-- ============================================================
-- VISUALS TAB
-- ============================================================
VisualsTab:CreateSection("Master Toggle")
VisualsTab:CreateToggle({ Name = "Enable ESP", CurrentValue = Settings.ESP, Flag = "ESP", Callback = function(v) Settings.ESP = v end })

VisualsTab:CreateSection("ESP Modules")
VisualsTab:CreateToggle({ Name = "Highlight ESP", CurrentValue = Settings.HighlightESP, Flag = "HighlightESP", Callback = function(v) Settings.HighlightESP = v end })
VisualsTab:CreateToggle({ Name = "Box ESP", CurrentValue = Settings.ESPBox, Flag = "ESPBox", Callback = function(v) Settings.ESPBox = v end })
VisualsTab:CreateToggle({ Name = "Tracker Lines", CurrentValue = Settings.Tracker, Flag = "Tracker", Callback = function(v) Settings.Tracker = v end })
VisualsTab:CreateToggle({ Name = "Name ESP", CurrentValue = Settings.ESPName, Flag = "ESPName", Callback = function(v) Settings.ESPName = v end })
VisualsTab:CreateToggle({ Name = "Distance ESP", CurrentValue = Settings.ESPDistance, Flag = "ESPDistance", Callback = function(v) Settings.ESPDistance = v end })
VisualsTab:CreateColorPicker({ Name = "ESP Color", Color = Settings.ESPColor, Flag = "ESPColor", Callback = function(c) Settings.ESPColor = c end })

VisualsTab:CreateSection("FOV Display")
VisualsTab:CreateToggle({ Name = "Show FOV Circle", CurrentValue = Settings.ShowFOV, Flag = "ShowFOV", Callback = function(v) Settings.ShowFOV = v end })
VisualsTab:CreateSlider({ Name = "FOV Radius", Range = {10, 1000}, Increment = 1, Suffix = "px", CurrentValue = Settings.FOVRadius, Flag = "FOVRadius", Callback = function(v) Settings.FOVRadius = v end })
VisualsTab:CreateInput({
    Name = "Type Exact FOV",
    CurrentValue = tostring(Settings.FOVRadius),
    PlaceholderText = "Type & press Enter",
    RemoveTextAfterFocusLost = false,
    Flag = "FOVInput",
    Callback = function(Text)
        local num = tonumber(Text)
        if num then Settings.FOVRadius = math.clamp(num, 10, 1000) end
    end,
})

-- ============================================================
-- LOCAL PLAYER TAB
-- ============================================================
LocalPlayerTab:CreateSection("Movement")
LocalPlayerTab:CreateToggle({ Name = "Enable Custom Speed", CurrentValue = Settings.SpeedEnabled, Flag = "SpeedToggle", Callback = function(v) Settings.SpeedEnabled = v; updateLocalPlayer() end })
LocalPlayerTab:CreateSlider({ Name = "Walk Speed", Range = {16, 500}, Increment = 1, Suffix = " speed", CurrentValue = Settings.WalkSpeed, Flag = "WalkSpeed", Callback = function(v) Settings.WalkSpeed = v; updateLocalPlayer() end })
LocalPlayerTab:CreateInput({
    Name = "Type Exact Speed",
    CurrentValue = tostring(Settings.WalkSpeed),
    PlaceholderText = "e.g. 150",
    RemoveTextAfterFocusLost = false,
    Flag = "SpeedInput",
    Callback = function(Text)
        local num = tonumber(Text)
        if num then Settings.WalkSpeed = math.clamp(num, 16, 1000); updateLocalPlayer() end
    end,
})

LocalPlayerTab:CreateToggle({ Name = "Enable Custom Jump", CurrentValue = Settings.JumpEnabled, Flag = "JumpToggle", Callback = function(v) Settings.JumpEnabled = v; updateLocalPlayer() end })
LocalPlayerTab:CreateSlider({ Name = "Jump Power", Range = {50, 500}, Increment = 1, Suffix = " power", CurrentValue = Settings.JumpPower, Flag = "JumpPower", Callback = function(v) Settings.JumpPower = v; updateLocalPlayer() end })
LocalPlayerTab:CreateInput({
    Name = "Type Exact Jump",
    CurrentValue = tostring(Settings.JumpPower),
    PlaceholderText = "e.g. 200",
    RemoveTextAfterFocusLost = false,
    Flag = "JumpInput",
    Callback = function(Text)
        local num = tonumber(Text)
        if num then Settings.JumpPower = math.clamp(num, 50, 1000); updateLocalPlayer() end
    end,
})

LocalPlayerTab:CreateSection("Noclip")
LocalPlayerTab:CreateToggle({
    Name = "Enable Noclip",
    CurrentValue = false,
    Flag = "Noclip",
    Callback = function(v)
        Settings.Noclip = v
        if v then
            if getgenv().AoidNoclipConnection then getgenv().AoidNoclipConnection:Disconnect() end
            getgenv().AoidNoclipConnection = RunService.Stepped:Connect(function()
                local char = LocalPlayer.Character
                if char then
                    for _, part in ipairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then part.CanCollide = false end
                    end
                end
            end)
        else
            if getgenv().AoidNoclipConnection then getgenv().AoidNoclipConnection:Disconnect() end
            local char = LocalPlayer.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then part.CanCollide = true end
                end
            end
        end
    end,
})

-- ============================================================
-- CONFIG TAB
-- ============================================================
ConfigTab:CreateSection("Save Configuration")
local ConfigNameInput = ""
ConfigTab:CreateInput({
    Name = "Config Name",
    CurrentValue = "",
    PlaceholderText = "Type name here...",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text) ConfigNameInput = Text end,
})

ConfigTab:CreateButton({
    Name = "Save Current Settings",
    Callback = function()
        if ConfigNameInput == "" then
            Rayfield:Notify({Title = "Error", Content = "Type a name first!", Duration = 2})
            return
        end

        local saveData = {}
        for key, value in pairs(Settings) do
            if typeof(value) == "Color3" then
                saveData[key] = {R = value.R, G = value.G, B = value.B, IsColor = true}
            else
                saveData[key] = value
            end
        end

        if writefile then
            writefile("Aoid_Config_" .. ConfigNameInput .. ".json", HttpService:JSONEncode(saveData))
            Rayfield:Notify({Title = "Config Saved", Content = "Saved: " .. ConfigNameInput, Duration = 2})
            Rayfield:Notify({Title = "Action Required", Content = "Click 'Refresh Slots' to load it.", Duration = 3})
        end
    end,
})

ConfigTab:CreateSection("Load Configuration")
ConfigTab:CreateButton({
    Name = "Refresh Slots",
    Callback = function()
        if listfiles then
            local files = listfiles("")
            for _, file in ipairs(files) do
                if file:match("Aoid_Config_") and file:match("%.json$") then
                    local slotName = file:gsub("Aoid_Config_", ""):gsub("%.json", "")

                    ConfigTab:CreateButton({
                        Name = "Load Slot: " .. slotName,
                        Callback = function()
                            local loadData = HttpService:JSONDecode(readfile(file))
                            for key, value in pairs(loadData) do
                                if type(value) == "table" and value.IsColor then
                                    Settings[key] = Color3.new(value.R, value.G, value.B)
                                else
                                    Settings[key] = value
                                end
                            end
                            updateLocalPlayer()
                            Rayfield:Notify({Title = "Config Loaded", Content = "Loaded: " .. slotName, Duration = 2})
                        end,
                    })
                end
            end
        else
            Rayfield:Notify({Title = "Error", Content = "Executor lacks listfiles.", Duration = 2})
        end
    end,
})

-- ============================================================
-- MAIN RENDER LOOP
-- ============================================================
getgenv().AoidConnection = RunService.RenderStepped:Connect(function()
    local myChar = LocalPlayer.Character
    local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
    if not myHum or myHum.Health <= 0 then return end

    local cam = Camera
    if not cam then return end

    local vpSize = cam.ViewportSize
    local screenCenter = Vector2.new(vpSize.X / 2, vpSize.Y / 2)
    local tracerStart = Vector2.new(vpSize.X / 2, vpSize.Y - 50)

    if Settings.ShowFOV then
        Circle.Visible = true
        local r = Settings.FOVRadius
        Circle.Size = UDim2.fromOffset(r * 2, r * 2)
        Circle.Position = UDim2.fromOffset(screenCenter.X, screenCenter.Y)
        CircleStroke.Color = Settings.ESPColor
    else
        Circle.Visible = false
    end

    if not Settings.ESP then
        for _, d in pairs(boxes) do
            if d.box then d.box.Visible = false end
            if d.tracker then d.tracker.Visible = false end
        end
        for _, hl in pairs(highlights) do
            if hl then hl.Enabled = false end
        end
    else
        for _, obj in ipairs(workspace:GetChildren()) do
            if obj:IsA("Model") and obj.Name ~= LocalPlayer.Name and not isTeammate(obj) then
                local hum = obj:FindFirstChildOfClass("Humanoid")
                local head = obj:FindFirstChild("Head")

                if hum and head and hum.Health > 0 then
                    if Settings.HighlightESP then
                        if not highlights[obj] then
                            local hl = Instance.new("Highlight")
                            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                            hl.Parent = HighlightFolder
                            highlights[obj] = hl
                        end
                        highlights[obj].Adornee = obj
                        highlights[obj].Enabled = true
                        highlights[obj].FillColor = Settings.ESPColor
                        highlights[obj].FillTransparency = 0.5
                        highlights[obj].OutlineColor = Settings.ESPColor
                    else
                        if highlights[obj] then highlights[obj].Enabled = false end
                    end

                    if not boxes[obj] then
                        local box = Instance.new("Frame")
                        box.BackgroundTransparency = 1
                        box.BorderSizePixel = 0
                        box.Visible = false
                        box.ZIndex = 2
                        box.Parent = container

                        local stroke = Instance.new("UIStroke")
                        stroke.Color = Settings.ESPColor
                        stroke.Thickness = 1.5
                        stroke.Parent = box

                        local name = Instance.new("TextLabel")
                        name.Name = "NameLabel"
                        name.Size = UDim2.new(1, 0, 0, 14)
                        name.Position = UDim2.new(0, 0, 0, -16)
                        name.BackgroundTransparency = 1
                        name.Font = Enum.Font.GothamBold
                        name.TextSize = 12
                        name.TextColor3 = Color3.new(1, 1, 1)
                        name.TextStrokeTransparency = 0
                        name.ZIndex = 3
                        name.Text = obj.Name
                        name.Parent = box

                        local dist = Instance.new("TextLabel")
                        dist.Name = "DistLabel"
                        dist.Size = UDim2.new(1, 0, 0, 12)
                        dist.Position = UDim2.new(0, 0, 1, 2)
                        dist.BackgroundTransparency = 1
                        dist.Font = Enum.Font.Gotham
                        dist.TextSize = 11
                        dist.TextColor3 = Color3.fromRGB(200, 200, 200)
                        dist.TextStrokeTransparency = 0
                        dist.ZIndex = 3
                        dist.Parent = box

                        local tracker = Instance.new("Frame")
                        tracker.BackgroundColor3 = Settings.ESPColor
                        tracker.BorderSizePixel = 0
                        tracker.AnchorPoint = Vector2.new(0.5, 0.5)
                        tracker.Visible = false
                        tracker.ZIndex = 1
                        tracker.Parent = container

                        boxes[obj] = {box = box, tracker = tracker}
                    end

                    local d = boxes[obj]

                    local sp, onScreen = cam:WorldToViewportPoint(head.Position)
                    if onScreen and sp.Z > 0 then
                        local height = math.clamp(2000 / math.max(sp.Z, 1), 30, 800)
                        local width = height / 2

                        d.box.Visible = Settings.ESPBox
                        local stroke = d.box:FindFirstChildOfClass("UIStroke")
                        if stroke then stroke.Color = Settings.ESPColor end

                        d.box.Size = UDim2.fromOffset(width, height)
                        d.box.Position = UDim2.fromOffset(sp.X - width/2, sp.Y - (height/2))

                        d.box.NameLabel.Visible = Settings.ESPName
                        d.box.DistLabel.Visible = Settings.ESPDistance

                        if Settings.ESPDistance then
                            local distVal = math.floor((cam.CFrame.Position - head.Position).Magnitude)
                            d.box.DistLabel.Text = distVal .. " studs"
                        end
                    else
                        d.box.Visible = false
                    end

                    if Settings.Tracker then
                        local target
