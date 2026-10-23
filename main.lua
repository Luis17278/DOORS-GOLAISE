-- [[ DOORS HUB - EDICÃO DEFINITIVA UNIVERSAL (PC & MOBILE) ]]
-- Sem travamentos de Acrylic Blur e com suporte a botão flutuante

local Fluent = loadstring(game:HttpGet("https://github.com"))()

local Window = Fluent:CreateWindow({
    Title = "DoorsGolaise // Definitivo",
    SubTitle = "Universal Edition",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false, -- OBRIGATÓRIO FALSO: Impede o travamento no Mobile (Celular)
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.F8
})

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")

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
-- BOTÃO FLUTUANTE ADAPTATIVO PARA CELULAR (MOBILE)
-- =========================================================================
local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "DoorsGolaiseToggle"
toggleBtn.Size = UDim2.fromOffset(60, 60)
toggleBtn.Position = UDim2.new(0, 10, 0.5, -30)
toggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Text = "MENU"
toggleBtn.TextSize = 14
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.BorderSizePixel = 2
toggleBtn.BorderColor3 = Color3.fromRGB(0, 150, 255)
toggleBtn.ZIndex = 999999
toggleBtn.Parent = CoreGui:FindFirstChild("RobloxGui") or player:WaitForChild("PlayerGui")

-- Transiciona o estado visível do Menu ao clicar no botão
toggleBtn.Activated:Connect(function()
    if CoreGui:FindFirstChild("Fluent") or player:WaitForChild("PlayerGui"):FindFirstChild("Fluent") then
        local ui = CoreGui:FindFirstChild("Fluent") or player.PlayerGui:FindFirstChild("Fluent")
        if ui:FindFirstChild("Main") then
            ui.Main.Visible = not ui.Main.Visible
        end
    end
end)

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
-- ESTRUTURA DE ABAS (TABS)
-- =========================================================================

local Tabs = {
    Main = Window:AddTab({ Title = "Jogador", Icon = "user" }),
    Mitigate = Window:AddTab({ Title = "Mitigar Monstros", Icon = "shield" }),
    Visuals = Window:AddTab({ Title = "Visuais / ESP", Icon = "eye" })
}

-- --- ABA JOGADOR ---
Tabs.Main:AddSlider("SliderWalkSpeed", {
    Title = "Velocidade (WalkSpeed)",
    Description = "Altera a velocidade nativa de studs do seu avatar",
    Min = 16,
    Max = 45,
    Default = 16,
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

-- --- ABA MITIGAR MONSTROS ---
Tabs.Mitigate:AddToggle("ToggleRush", {
    Title = "Ignorar Rush & Ambush",
    Default = false,
    Callback = function(Value) config.AntiRushAmbush = Value end
})

Tabs.Mitigate:AddToggle("ToggleScreech", {
    Title = "Anular Screech Instantaneamente",
    Default = false,
    Callback = function(Value) config.AntiScreech = Value end
})

Tabs.Mitigate:AddToggle("ToggleEyes", {
    Title = "Anti Eyes & Lookman (Desviar Olhar)",
    Default = false,
    Callback = function(Value) config.AntiEyesLookman = Value end
})

Tabs.Mitigate:AddToggle("ToggleSnare", {
    Title = "Ignorar Snare & Giggle (Mines/Floor 2)",
    Default = false,
    Callback = function(Value) config.AntiSnareGiggle = Value end
})

-- --- ABA VISUAIS ---
Tabs.Visuals:AddToggle("ToggleBright", {
    Title = "Fullbright (Remover Escuridão)",
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

Tabs.Visuals:AddToggle("ToggleEspMonsters", {
    Title = "Ver Monstros (ESP)",
    Default = false,
    Callback = function(Value)
        espEnabled["HubMonster"] = Value
        refreshESP("HubMonster")
    end
})

Tabs.Visuals:AddToggle("ToggleEspItems", {
    Title = "Ver Itens (ESP)",
    Default = false,
    Callback = function(Value)
        espEnabled["HubItem"] = Value
        refreshESP("HubItem")
    end
})

Tabs.Visuals:AddToggle("ToggleEspObjects", {
    Title = "Ver Objetos / Alavancas (ESP)",
    Default = false,
    Callback = function(Value)
        espEnabled["HubRoomObject"] = Value
        refreshESP("HubRoomObject")
    end
})

-- =========================================================================
-- MOTORES DE MONITORAMENTO EM TEMPO REAL (BYPASS LÓGICO)
-- =========================================================================

Workspace.ChildAdded:Connect(function(child)
    if config.AntiRushAmbush and (child.Name == "RushMoving" or child.Name == "AmbushMoving") then
        task.wait(0.05)
        local hitbox = child:FindFirstChild("RushNew") or child:FindFirstChild("Hitbox")
        if hitbox then hitbox:Destroy() end
        
        Fluent:Notify({
            Title = "🛡️ SEGURANÇA ATIVADA",
            Content = "A caixa de dano físico de " .. child.Name .. " foi anulada!",
            Duration = 4
        })
    end
end)

Workspace.CurrentCamera.ChildAdded:Connect(function(child)
    if config.AntiScreech and child.Name == "Screech" then
        child:Destroy()
        local remote = ReplicatedStorage:FindFirstChild("ScreechBanish", true) or ReplicatedStorage:FindFirstChild("Screech", true)
        if remote and remote:IsA("RemoteEvent") then remote:FireServer(true) end
        
        Fluent:Notify({
            Title = "🛡️ SCREECH EXPULSO",
            Content = "O Screech tentou atacar e foi deletado!",
            Duration = 3
        })
    end
end)

RunService.Heartbeat:Connect(function()
    local currentRooms = Workspace:FindFirstChild("CurrentRooms")
    if not currentRooms then return end
    
    for _, room in ipairs(currentRooms:GetChildren()) do
        if config.AntiEyesLookman and (room:FindFirstChild("Eyes") or room:FindFirstChild("Lookman")) then
            local char = player.Character
            local head = char and char:FindFirstChild("Head")
            if head then
                head.CFrame = head.CFrame * CFrame.Angles(0, math.rad(180), 0)
            end
        end
        
        if config.AntiSnareGiggle then
            local assets = room:FindFirstChild("Assets")
            if assets then
                for _, asset in ipairs(assets:GetChildren()) do
                    if asset.Name == "Snare" and asset:FindFirstChild("Hitbox") then asset.Hitbox:Destroy() end
                end
            end
            local entities = room:FindFirstChild("Entities")
            if entities then
                local giggle = entities:FindFirstChild("Giggle")
                if giggle and giggle:FindFirstChild("Hitbox") then giggle.Hitbox:Destroy() end
            end
        end
    end
end)

local tagsToMonitor = {"HubMonster", "HubItem", "HubRoomObject"}
for i = 1, #tagsToMonitor do
    local tag = tagsToMonitor[i]
    CollectionService:GetInstanceAddedSignal(tag):Connect(function(object)
        addESP(object, tag)
        if tag == "HubMonster" and object.Name ~= "SeekMoving" and object.Name ~= "Figure" then
            Fluent:Notify({
