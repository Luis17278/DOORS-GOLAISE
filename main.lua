-- [[ DOORS HUB - EDICÃO DEFINITIVA VYNIXIUS ]]
-- Compatível com Doors 1 (Hotel) e Doors 2 (Mines)

-- URL Oficial e Funcional da Orion Library:
local OrionLib = loadstring(game:HttpGet('https://githubusercontent.com'))()
local Window = OrionLib:MakeWindow({Name = "DoorsGolaise // Vynixius Edition", HidePremium = false, SaveConfig = true, ConfigFolder = "DoorsGolaiseConfig"})

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

-- Estados globais das trapaças
local config = {
    Speed = 16,
    Fullbright = false,
    AntiRushAmbush = false,
    AntiScreech = false,
    AntiEyesLookman = false,
    AntiSnareGiggle = false
}

local espEnabled = { HubRoomObject = false, HubItem = false, HubMonster = false }
local espObjects = {}

local oldBrightness = Lighting.Brightness
local oldClockTime = Lighting.ClockTime
local oldShadows = Lighting.GlobalShadows

-- =========================================================================
-- SISTEMA DE VISUAIS (ESP HIGHLIGHTS)
-- =========================================================================

local function clearESP(tag)
    for object, highlight in pairs(espObjects) do
        if not tag or CollectionService:HasTag(object, tag) then
            if highlight and highlight.Parent then highlight:Destroy() end
            espObjects[object] = nil
        end
    end
end

local function addESP(object, tag)
    if not espEnabled[tag] or espObjects[object] then return end
    if not object:IsA("Model") and not object:IsA("BasePart") then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = "DoorsHubESP"
    highlight.Adornee = object
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillTransparency = 0.6
    highlight.OutlineTransparency = 0
    
    if tag == "HubMonster" then
        highlight.FillColor = Color3.fromRGB(242, 38, 19)
        highlight.OutlineColor = Color3.fromRGB(150, 0, 0)
    elseif tag == "HubItem" then
        highlight.FillColor = Color3.fromRGB(46, 204, 113)
        highlight.OutlineColor = Color3.fromRGB(30, 130, 76)
    else
        highlight.FillColor = Color3.fromRGB(41, 128, 185)
        highlight.OutlineColor = Color3.fromRGB(31, 58, 147)
    end
    
    highlight.Parent = workspace
    espObjects[object] = highlight
end

local function refreshESP(tag)
    clearESP(tag)
    if espEnabled[tag] then
        for _, object in ipairs(CollectionService:GetTagged(tag)) do addESP(object, tag) end
    end
end

-- =========================================================================
-- LÓGICAS DAS ABAS (TABS & INTERFACE)
-- =========================================================================

local MainTab = Window:MakeTab({Name = "Jogador", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local MitigateTab = Window:MakeTab({Name = "Mitigar Monstros", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local VisualsTab = Window:MakeTab({Name = "Visuais / ESP", Icon = "rbxassetid://4483345998", PremiumOnly = false})

-- ABA JOGADOR
MainTab:AddSlider({
    Name = "Velocidade (WalkSpeed)",
    Min = 16,
    Max = 45,
    Default = 16,
    Color = Color3.fromRGB(255,255,255),
    Increment = 1,
    ValueName = "studs/s",
    Callback = function(Value)
        config.Speed = Value
    end
})

RunService.RenderStepped:Connect(function()
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum and hum.WalkSpeed ~= config.Speed then
        hum.WalkSpeed = config.Speed
    end
end)

-- ABA MITIGAR MONSTROS (GODMODE ADAPTATIVO POR ENTIDADE)
MitigateTab:AddToggle({
    Name = "Ignorar Rush & Ambush",
    Default = false,
    Callback = function(Value)
        config.AntiRushAmbush = Value
    end
})

MitigateTab:AddToggle({
    Name = "Anular Screech Instantaneamente",
    Default = false,
    Callback = function(Value)
        config.AntiScreech = Value
    end
})

MitigateTab:AddToggle({
    Name = "Anti Eyes & Lookman (Desviar Olhar)",
    Default = false,
    Callback = function(Value)
        config.AntiEyesLookman = Value
    end
})

MitigateTab:AddToggle({
    Name = "Ignorar Snare & Giggle (Mines/Floor 2)",
    Default = false,
    Callback = function(Value)
        config.AntiSnareGiggle = Value
    end
})

-- ABA VISUAIS
VisualsTab:AddToggle({
    Name = "Fullbright (Remover Escuridão)",
    Default = false,
    Callback = function(Value)
        config.Fullbright = Value
        if not Value then
            Lighting.Brightness = oldBrightness
            Lighting.ClockTime = oldClockTime
            Lighting.GlobalShadows = oldShadows
        end
    end
})

Lighting.Changed:Connect(function()
    if config.Fullbright then
        Lighting.Brightness = 3
        Lighting.ClockTime = 14
        Lighting.GlobalShadows = false
    end
end)

VisualsTab:AddToggle({
    Name = "Ver Monstros (ESP)",
    Default = false,
    Callback = function(Value)
        espEnabled["HubMonster"] = Value
        refreshESP("HubMonster")
    end
})

VisualsTab:AddToggle({
    Name = "Ver Itens (ESP)",
    Default = false,
    Callback = function(Value)
        espEnabled["HubItem"] = Value
        refreshESP("HubItem")
    end
})

VisualsTab:AddToggle({
    Name = "Ver Objetos / Alavancas (ESP)",
    Default = false,
    Callback = function(Value)
        espEnabled["HubRoomObject"] = Value
        refreshESP("HubRoomObject")
    end
})

-- =========================================================================
-- MOTORES DE MONITORAMENTO EM TEMPO REAL (BYPASS LÓGICO)
-- =========================================================================

-- Interceptador para anular Rush e Ambush do mapa local
Workspace.ChildAdded:Connect(function(child)
    if config.AntiRushAmbush and (child.Name == "RushMoving" or child.Name == "AmbushMoving") then
        task.wait(0.05)
        local hitbox = child:FindFirstChild("RushNew") or child:FindFirstChild("Hitbox")
        if hitbox then
            hitbox:Destroy() 
        end
        OrionLib:MakeNotification({
            Name = "🛡️ SEGURANÇA ATIVADA",
            Content = "A caixa de dano físico de " .. child.Name .. " foi destruída com sucesso!",
            Time = 4
        })
    end
end)

-- Interceptador para retirar o Screech preso à câmera do jogador
Workspace.CurrentCamera.ChildAdded:Connect(function(child)
    if config.AntiScreech and child.Name == "Screech" then
        child:Destroy()
        local remote = ReplicatedStorage:FindFirstChild("ScreechBanish", true) or ReplicatedStorage:FindFirstChild("Screech", true)
        if remote and remote:IsA("RemoteEvent") then
            remote:FireServer(true)
        end
        OrionLib:MakeNotification({
            Name = "🛡️ SCREECH EXPULSO",
            Content = "O Screech tentou se prender à sua cabeça e foi deletado!",
            Time = 3
        })
    end
end)

-- Manipulador de Vetor de Ângulo de Câmera (Bypass Eyes, Lookman, Giggle no teto)
RunService.Heartbeat:Connect(function()
    local currentRooms = Workspace:FindFirstChild("CurrentRooms")
    if not currentRooms then return end
    
    for _, room in ipairs(currentRooms:GetChildren()) do
        -- Proteção Contra Eyes / Lookman (Bypass de Raycast de Olhar direto)
        if config.AntiEyesLookman and (room:FindFirstChild("Eyes") or room:FindFirstChild("Lookman")) then
            local eyesEntity = room:FindFirstChild("Eyes") or room:FindFirstChild("Lookman")
            local core = eyesEntity:FindFirstChild("Core") or eyesEntity:FindFirstChild("Look")
            if core then
                local char = player.Character
                local head = char and char:FindFirstChild("Head")
                if head then
                    head.CFrame = head.CFrame * CFrame.Angles(0, math.rad(180), 0)
                end
            end
        end
        
        -- Proteção Contra Snare (Chão) e Giggle (Teto) - Floor 2
        if config.AntiSnareGiggle then
            local assets = room:FindFirstChild("Assets")
            if assets then
                for _, asset in ipairs(assets:GetChildren()) do
                    if asset.Name == "Snare" and asset:FindFirstChild("Hitbox") then
                        asset.Hitbox:Destroy()
                    end
                end
            end
            local entities = room:FindFirstChild("Entities")
            if entities then
                local giggle = entities:FindFirstChild("Giggle")
                if giggle and giggle:FindFirstChild("Hitbox") then
                    giggle.Hitbox:Destroy()
                end
            end
        end
    end
end)

-- Sinalizadores Automáticos para a CollectionService do Script
local tagsToMonitor = {"HubMonster", "HubItem", "HubRoomObject"}
for i = 1, #tagsToMonitor do
    local tag = tagsToMonitor[i]
    CollectionService:GetInstanceAddedSignal(tag):Connect(function(object)
        addESP(object, tag)
        if tag == "HubMonster" and object.Name ~= "SeekMoving" and object.Name ~= "Figure" then
            OrionLib:MakeNotification({
                Name = "⚠️ ENTIDADE DETECTADA!",
                Content = "A entidade (" .. object.Name .. ") acabou de surgir no mapa!",
                Time = 5
            })
        end
    end)
    CollectionService:GetInstanceRemovedSignal(tag):Connect(function(object)
        if espObjects[object] then espObjects[object]:Destroy() espObjects[object] = nil end
    end)
end

OrionLib:Init()
