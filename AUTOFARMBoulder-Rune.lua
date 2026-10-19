local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- CONFIG & AUTO-RESUME SYSTEM (UNTUK AUTO HOP)
-- ==========================================
local configFileName = "SimpleBouldersConfig.json"
local farmConfig = { autoStart = false }

local function loadConfig()
    pcall(function()
        if isfile and isfile(configFileName) then
            local decoded = HttpService:JSONDecode(readfile(configFileName))
            if decoded then farmConfig = decoded end
        end
    end)
end

local function saveConfig(autoStartStatus)
    farmConfig.autoStart = autoStartStatus
    pcall(function()
        if writefile then writefile(configFileName, HttpService:JSONEncode(farmConfig)) end
    end)
end
loadConfig()

pcall(function()
    if queue_on_teleport and farmConfig.autoStart then
        queue_on_teleport([[
            task.wait(5)
        ]])
    end
end)

-- ==========================================
-- INISIALISASI UI PANEL (SUPER SIMPEL)
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SimpleAutoFarmUI"
ScreenGui.ResetOnSpawn = false

local successCore, _ = pcall(function() ScreenGui.Parent = CoreGui end)
if not successCore then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 220, 0, 130)
MainFrame.Position = UDim2.new(0.5, -110, 0.1, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Text = "⚡ 1-Click Auto Farm"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.BorderSizePixel = 0
Title.Parent = MainFrame

local RuneInfoLabel = Instance.new("TextLabel")
RuneInfoLabel.Size = UDim2.new(1, 0, 0, 30)
RuneInfoLabel.Position = UDim2.new(0, 0, 0, 35)
RuneInfoLabel.BackgroundTransparency = 1
RuneInfoLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
RuneInfoLabel.Text = "🔮 Runes on Map: 0"
RuneInfoLabel.Font = Enum.Font.GothamBold
RuneInfoLabel.TextSize = 13
RuneInfoLabel.Parent = MainFrame

local StartBtn = Instance.new("TextButton")
StartBtn.Size = UDim2.new(0.9, 0, 0, 45)
StartBtn.Position = UDim2.new(0.05, 0, 0, 75)
StartBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
StartBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
StartBtn.Text = "▶ START FARMING"
StartBtn.Font = Enum.Font.GothamBold
StartBtn.TextSize = 14
StartBtn.Parent = MainFrame

-- ==========================================
-- UTILITY FUNCTIONS
-- ==========================================
_G.isFarming = false
local currentTarget = nil
local noclipConnection
local collectDistance = 50

local function getRuneCount()
    local droppedRunesFolder = Workspace:FindFirstChild("DroppedRunes")
    if droppedRunesFolder and droppedRunesFolder:IsA("Folder") then
        return #droppedRunesFolder:GetChildren()
    end
    return 0
end

task.spawn(function()
    while task.wait(0.5) do
        if MainFrame.Parent then
            RuneInfoLabel.Text = "🔮 Runes on Map: " .. getRuneCount()
        end
    end
end)

local function enableFlyNoclip()
    if not noclipConnection then
        noclipConnection = RunService.Stepped:Connect(function()
            if LocalPlayer.Character then
                for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
                    if v:IsA("BasePart") and v.CanCollide then v.CanCollide = false end
                end
            end
        end)
    end
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp and not hrp:FindFirstChild("FarmFly") then
        local bodyVel = Instance.new("BodyVelocity")
        bodyVel.Name = "FarmFly"
        bodyVel.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bodyVel.Velocity = Vector3.new(0, 0, 0)
        bodyVel.Parent = hrp
    end
end

local function disableFlyNoclip()
    if noclipConnection then noclipConnection:Disconnect(); noclipConnection = nil end
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        local bv = hrp:FindFirstChild("FarmFly")
        if bv then bv:Destroy() end
    end
end

local function getTool()
    local char = LocalPlayer.Character
    if not char then return nil end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local tool = char:FindFirstChildOfClass("Tool")
    if tool then return tool end

    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack and hum then
        for _, t in ipairs(backpack:GetChildren()) do
            if t:IsA("Tool") then
                local name = string.lower(t.Name)
                if string.find(name, "axe") or string.find(name, "pick") or string.find(name, "kapak") or string.find(name, "sword") then
                    hum:EquipTool(t)
                    return t
                end
            end
        end
    end
    return nil
end

local function isTargetAlive(obj)
    if not obj or not obj.Parent or not obj:IsDescendantOf(Workspace) then return false end
    local hum = obj:FindFirstChildOfClass("Humanoid")
    if hum and hum.Health <= 0 then return false end
    local hpAttr = obj:GetAttribute("Health") or obj:GetAttribute("HP") or obj:GetAttribute("health") or obj:GetAttribute("hp")
    if hpAttr and tonumber(hpAttr) <= 0 then return false end
    for _, child in ipairs(obj:GetChildren()) do
        local lName = string.lower(child.Name)
        if (lName == "health" or lName == "hp") and (child:IsA("IntValue") or child:IsA("NumberValue")) then 
            if child.Value <= 0 then return false end
        end
    end
    return true
end

-- ==========================================
-- AUTO RUNE & TP LOGIC
-- ==========================================
ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt)
    if _G.isFarming then fireproximityprompt(prompt) end
end)

task.spawn(function()
    while task.wait(0.1) do
        if _G.isFarming then
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local droppedRunesFolder = Workspace:FindFirstChild("DroppedRunes")
                if droppedRunesFolder then
                    for _, rune in pairs(droppedRunesFolder:GetChildren()) do
                        local prompt = rune:FindFirstChildWhichIsA("ProximityPrompt", true)
                        local part = rune:IsA("BasePart") and rune or rune:FindFirstChildWhichIsA("BasePart", true)
                        if prompt and part and prompt.Enabled then
                            if (hrp.Position - part.Position).Magnitude <= collectDistance then
                                fireproximityprompt(prompt)
                            end
                        end
                    end
                end
            end
        end
    end
end)

local function executeTPToRune(hrp)
    local droppedRunesFolder = Workspace:FindFirstChild("DroppedRunes")
    if droppedRunesFolder then
        for _, rune in pairs(droppedRunesFolder:GetChildren()) do
            local part = rune:IsA("BasePart") and rune or rune:FindFirstChildWhichIsA("BasePart", true)
            if part then
                hrp.CFrame = part.CFrame
                hrp.Velocity = Vector3.new(0,0,0)
                return true
            end
        end
    end
    return false
end

-- ==========================================
-- SERVER HOP
-- ==========================================
local function doServerHop()
    StartBtn.Text = "🔄 HOPPING SERVER..."
    StartBtn.BackgroundColor3 = Color3.fromRGB(150, 100, 255)
    saveConfig(true) 
    
    local success, _ = pcall(function()
        local url = "https://games.roblox.com/v1/games/" .. tostring(game.PlaceId) .. "/servers/Public?sortOrder=Asc&limit=100"
        local decoded = HttpService:JSONDecode(game:HttpGet(url))
        local validServers = {}
        
        if decoded and decoded.data then
            for _, v in ipairs(decoded.data) do
                if v.playing and v.maxPlayers and v.id and v.playing < v.maxPlayers - 1 and v.id ~= game.JobId then
                    table.insert(validServers, v.id)
                end
            end
        end
        
        if #validServers > 0 then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, validServers[math.random(1, #validServers)], LocalPlayer)
        else
            error("No servers")
        end
    end)

    if not success then
        pcall(function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end)
    end
end

-- ==========================================
-- MAIN FARMING LOOP
-- ==========================================
local function toggleFarm(state)
    _G.isFarming = state
    if _G.isFarming then
        StartBtn.Text = "⏹ STOP FARMING"
        StartBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        enableFlyNoclip()
        getTool()
        
        task.spawn(function()
            while _G.isFarming do
                task.wait()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if not hrp then continue end

                -- 1. FASE 1: Hancurkan Boulder terlebih dahulu sampai habis (SKIP HALLOWITE)
                if currentTarget and currentTarget.Model and isTargetAlive(currentTarget.Model) then
                    hrp.CFrame = currentTarget.LockCFrame
                    hrp.Velocity = Vector3.new(0,0,0)
                    local tool = getTool()
                    if tool then tool:Activate() end
                    continue
                end

                if currentTarget ~= nil then
                    currentTarget = nil
                    task.wait(0.2) 
                end

                local bestTarget = nil
                local bestTargetModel = nil
                local shortestDist = math.huge

                for _, folder in ipairs(Workspace:GetDescendants()) do
                    if folder:IsA("Folder") and folder.Name == "Boulders" then
                        for _, item in ipairs(folder:GetChildren()) do
                            if item.Name == "Hallowite" then continue end
                            
                            if isTargetAlive(item) then
                                local part = item:IsA("BasePart") and item or item:FindFirstChildWhichIsA("BasePart", true)
                                if part then
                                    local dist = (hrp.Position - part.Position).Magnitude
                                    if dist < shortestDist then
                                        shortestDist = dist
                                        bestTarget = part
                                        bestTargetModel = item
                                    end
                                end
                            end
                        end
                    end
                end

                if bestTarget then
                    -- Kunci posisi CFrame statis agar karakter tidak goyang/mengikuti boulder
                    currentTarget = { 
                        Part = bestTarget, 
                        Model = bestTargetModel,
                        LockCFrame = bestTarget.CFrame
                    }
                    StartBtn.Text = "⏹ FARMING BOULDERS"
                else
                    -- 2. FASE 2: Jika Boulders Habis, Baru Ambil/TP ke Rune
                    if getRuneCount() > 0 then
                        StartBtn.Text = "💎 COLLECTING RUNES..."
                        executeTPToRune(hrp)
                        task.wait(0.3)
                    else
                        -- 3. FASE 3: Jika Rune Sudah 0, Tunggu 10 Detik Lalu Server Hop
                        StartBtn.Text = "⏳ WAITING TO HOP (10s)..."
                        
                        local waited = 0
                        while waited < 10 and _G.isFarming do
                            task.wait(1)
                            waited = waited + 1
                            -- Jika tiba-tiba ada boulder atau rune baru muncul saat menunggu, batalkan timer
                            if getRuneCount() > 0 then break end
                            
                            -- Cek apakah ada boulder baru yang muncul
                            local hasNewBoulder = false
                            for _, folder in ipairs(Workspace:GetDescendants()) do
                                if folder:IsA("Folder") and folder.Name == "Boulders" then
                                    for _, item in ipairs(folder:GetChildren()) do
                                        if item.Name ~= "Hallowite" and isTargetAlive(item) then
                                            hasNewBoulder = true
                                            break
                                        end
                                    end
                                end
                                if hasNewBoulder then break end
                            end
                            if hasNewBoulder then break end
                        end
                        
                        -- Jika setelah 10 detik rune tetap 0 dan tidak ada boulder baru, lakukan hop
                        if _G.isFarming and getRuneCount() == 0 then
                            _G.isFarming = false
                            doServerHop()
                            break
                        end
                    end
                end
            end
        end)
    else
        StartBtn.Text = "▶ START FARMING"
        StartBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        disableFlyNoclip()
        currentTarget = nil
        saveConfig(false) 
    end
end

StartBtn.MouseButton1Click:Connect(function()
    toggleFarm(not _G.isFarming)
end)

-- ==========================================
-- AUTO RESUME TRIGGER PADA SAAT JOIN / REJOIN
-- ==========================================
if farmConfig.autoStart then
    task.spawn(function()
        task.wait(4) -- Beri waktu sebentar untuk game & folder ter-load
        
        -- Cek apakah ada boulder aktif di map
        local hasBoulder = false
        for _, folder in ipairs(Workspace:GetDescendants()) do
            if folder:IsA("Folder") and folder.Name == "Boulders" then
                for _, item in ipairs(folder:GetChildren()) do
                    if item.Name ~= "Hallowite" and isTargetAlive(item) then
                        hasBoulder = true
                        break
                    end
                end
            end
            if hasBoulder then break end
        end

        -- Jika dari awal join rune sudah 0 dan tidak ada boulder, langsung hop tanpa tunggu 10 detik
        if getRuneCount() == 0 and not hasBoulder then
            doServerHop()
        else
            toggleFarm(true)
        end
    end)
end
