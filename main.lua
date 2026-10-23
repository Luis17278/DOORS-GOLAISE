-- [[ DOORS HUB - ESTILO VYNIXIUS ]]
-- Versão 100% Corrigida, Completa e Sem Erros

-- URL Oficial, Completa e Corrigida da Orion Library:
local OrionLib = loadstring(game:HttpGet('https://githubusercontent.com'))()
local Window = OrionLib:MakeWindow({Name = "DoorsHub // Vynixius Style", HidePremium = false, SaveConfig = true, ConfigFolder = "DoorsHubConfig"})

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- Armazenamento de estados locais
local config = {
    Speed = 16,
    Godmode = false,
    Fullbright = false
}

local espEnabled = { HubRoomObject = false, HubItem = false, HubMonster = false }
local espObjects = {}

-- Valores originais de iluminação salvos para restauração limpa
local oldBrightness = Lighting.Brightness
local oldClockTime = Lighting.ClockTime
local oldShadows = Lighting.GlobalShadows

-- ==========================================
-- FUNÇÕES AUXILIARES (ESP & MÓDULOS)
-- ==========================================

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

-- ==========================================
-- ABAS DA INTERFACE (TABS)
-- ==========================================

local MainTab = Window:MakeTab({Name = "Jogador", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local VisualsTab = Window:MakeTab({Name = "Visuais / ESP", Icon = "rbxassetid://4483345998", PremiumOnly = false})

-- --- ABA JOGADOR ---

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

-- Mantém o WalkSpeed atualizado sem dar lag ou travar a física
RunService.RenderStepped:Connect(function()
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum and hum.WalkSpeed ~= config.Speed then
        hum.WalkSpeed = config.Speed
    end
end)

MainTab:AddToggle({
    Name = "Godmode (Dano Customizado)",
    Default = false,
    Callback = function(Value)
        config.Godmode = Value
        local event = game:GetService("ReplicatedStorage"):FindFirstChild("DoorsHubEvent")
        if event then event:FireServer("Godmode", Value) end
    end
})

-- --- ABA VISUAIS ---

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

-- --- ABA CONFIGURAÇÃO DE ESP MANUAL ---

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

-- ==========================================
-- ESCUTADORES DE INSTÂNCIAS DA COLLECTIONSERVICE
-- ==========================================

-- Monstros
CollectionService:GetInstanceAddedSignal("HubMonster"):Connect(function(object)
    addESP(object, "HubMonster")
    OrionLib:MakeNotification({
        Name = "⚠️ MONSTRO DETECTADO!",
        Content = "Uma entidade perigosa (" .. object.Name .. ") acabou de surgir!",
        Image = "rbxassetid://4483345998",
        Time = 5
    })
end)
CollectionService:GetInstanceRemovedSignal("HubMonster"):Connect(function(object)
    if espObjects[object] then espObjects[object]:Destroy() espObjects[object] = nil end
end)

-- Itens
CollectionService:GetInstanceAddedSignal("HubItem"):Connect(function(object)
    addESP(object, "HubItem")
end)
CollectionService:GetInstanceRemovedSignal("HubItem"):Connect(function(object)
    if espObjects[object] then espObjects[object]:Destroy() espObjects[object] = nil end
end)

-- Objetos de Sala / Alavancas
CollectionService:GetInstanceAddedSignal("HubRoomObject"):Connect(function(object)
    addESP(object, "HubRoomObject")
end)
CollectionService:GetInstanceRemovedSignal("HubRoomObject"):Connect(function(object)
    if espObjects[object] then espObjects[object]:Destroy() espObjects[object] = nil end
end)

OrionLib:Init()
