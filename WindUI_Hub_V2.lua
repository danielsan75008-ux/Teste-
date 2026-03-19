--[[
    ╔══════════════════════════════════════════╗
    ║       UNIVERSAL HUB V2  |  WindUI        ║
    ║    ESP: Box 2D  |  PC & Mobile Ready     ║
    ╚══════════════════════════════════════════╝
]]

-- ════════════════════════════════
--  LOAD WindUI
-- ════════════════════════════════
local WindUI = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"
))()

-- ════════════════════════════════
--  SERVICES
-- ════════════════════════════════
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService      = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Camera      = workspace.CurrentCamera

-- ════════════════════════════════
--  ESTADO GLOBAL
-- ════════════════════════════════
local State = {
    -- Troll
    TouchFling   = false,
    AntiFling    = false,

    -- Player
    WalkSpeed    = 16,
    JumpPower    = 50,
    InfiniteJump = false,

    -- Aimbot
    AimbotEnabled = false,
    TeamCheck     = false,
    AimbotFOV    = 120,
    AimbotSmooth  = 5,

    -- ESP
    ESPEnabled   = false,
    ESPColor     = Color3.fromRGB(255, 50, 50),
    ESPFill      = false,
    ESPFillAlpha = 0.15,

    -- Hitbox
    HitboxEnabled = false,
    HitboxSize    = 5,
    HitboxAlpha   = 0.5,
}

-- ════════════════════════════════
--  HELPERS
-- ════════════════════════════════
local function getCharacter()
    return LocalPlayer.Character
end

local function getHumanoid()
    local c = getCharacter()
    return c and c:FindFirstChildOfClass("Humanoid")
end

local function isEnemy(player)
    if not State.TeamCheck then return true end
    return player.Team ~= LocalPlayer.Team
end

local function getClosestInFOV()
    local closest, closestDist = nil, math.huge
    local cx = Camera.ViewportSize.X / 2
    local cy = Camera.ViewportSize.Y / 2

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if not isEnemy(player) then continue end
        local char = player.Character
        if not char then continue end
        local head = char:FindFirstChild("Head")
        if not head then continue end

        local sp, onScreen = Camera:WorldToViewportPoint(head.Position)
        if not onScreen then continue end

        local dist = math.sqrt((sp.X - cx)^2 + (sp.Y - cy)^2)
        if dist < State.AimbotFOV and dist < closestDist then
            closest     = head
            closestDist = dist
        end
    end
    return closest
end

-- ════════════════════════════════
--  ESP  BOX 2D
-- ════════════════════════════════
--  Para cada player criamos 4 linhas (top, bottom, left, right)
--  + 1 label com o nome
--  + 1 quad fill (opcional)
-- ════════════════════════════════

local espObjects = {}   -- espObjects[player] = { lines={}, label, fill }

local function newLine()
    local l = Drawing.new("Line")
    l.Visible   = false
    l.Thickness = 1.5
    l.Color     = Color3.fromRGB(255, 50, 50)
    return l
end

local function newLabel()
    local t = Drawing.new("Text")
    t.Visible  = false
    t.Size     = 14
    t.Outline  = true
    t.Color    = Color3.fromRGB(255, 50, 50)
    t.Text     = ""
    return t
end

local function newQuad()
    local q = Drawing.new("Quad")
    q.Visible      = false
    q.Filled       = true
    q.Color        = Color3.fromRGB(255, 50, 50)
    q.Transparency = 1 - State.ESPFillAlpha
    return q
end

local function cleanESP(player)
    local obj = espObjects[player]
    if not obj then return end
    for _, l in ipairs(obj.lines) do
        l:Remove()
    end
    obj.label:Remove()
    obj.fill:Remove()
    espObjects[player] = nil
end

local function createESP(player)
    cleanESP(player)
    local lines = {}
    for _ = 1, 4 do
        table.insert(lines, newLine())
    end
    espObjects[player] = {
        lines = lines,
        label = newLabel(),
        fill  = newQuad(),
    }
end

-- Calcula bounding box 2D do character
local function getCharBounds(char)
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum  = char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return nil end

    -- Usa HRP como centro, estima bounds com altura do humanoide
    local height  = hum.HipHeight * 2 + 1   -- aprox. altura em studs
    local topPos    = root.Position + Vector3.new(0, height * 0.5, 0)
    local bottomPos = root.Position - Vector3.new(0, height * 0.5, 0)

    local topSP,    onT = Camera:WorldToViewportPoint(topPos)
    local bottomSP, onB = Camera:WorldToViewportPoint(bottomPos)
    if not onT or not onB then return nil end

    local screenH = math.abs(topSP.Y - bottomSP.Y)
    local screenW = screenH * 0.55   -- proporção aproximada

    local cx = (topSP.X + bottomSP.X) / 2

    local x1 = cx - screenW / 2
    local x2 = cx + screenW / 2
    local y1 = topSP.Y
    local y2 = bottomSP.Y

    -- Cantos: TL, TR, BR, BL
    return {
        tl = Vector2.new(x1, y1),
        tr = Vector2.new(x2, y1),
        br = Vector2.new(x2, y2),
        bl = Vector2.new(x1, y2),
    }, Vector2.new(cx, y1 - 4)   -- label pos acima do box
end

-- ════════════════════════════════
--  FOV CIRCLE
-- ════════════════════════════════
local fovCircle         = Drawing.new("Circle")
fovCircle.Visible       = false
fovCircle.Radius        = State.AimbotFOV
fovCircle.Color         = Color3.fromRGB(255, 255, 255)
fovCircle.Thickness     = 1.5
fovCircle.Filled        = false
fovCircle.Position      = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

-- ════════════════════════════════
--  HITBOX
-- ════════════════════════════════
local hitboxParts = {}

local function removeHitbox(player)
    if hitboxParts[player] then
        pcall(function() hitboxParts[player]:Destroy() end)
        hitboxParts[player] = nil
    end
end

local function applyHitbox(player)
    removeHitbox(player)
    local char = player.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local part         = Instance.new("Part")
    part.Name          = "HitboxExpand"
    part.Size          = Vector3.new(State.HitboxSize, State.HitboxSize, State.HitboxSize)
    part.Anchored      = false
    part.CanCollide    = false
    part.Massless      = true
    part.Transparency  = State.HitboxAlpha
    part.BrickColor    = BrickColor.new("Bright red")
    part.Material      = Enum.Material.ForceField
    part.Parent        = char

    local weld  = Instance.new("WeldConstraint")
    weld.Part0  = root
    weld.Part1  = part
    weld.Parent = part
    hitboxParts[player] = part
end

local function refreshHitboxes()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if State.HitboxEnabled then applyHitbox(player)
            else removeHitbox(player) end
        end
    end
end

-- ════════════════════════════════
--  TOUCH FLING
-- ════════════════════════════════
local touchConn = nil

local function startFling()
    if touchConn then return end
    touchConn = RunService.Heartbeat:Connect(function()
        local char = getCharacter()
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        for _, p in ipairs(workspace:GetDescendants()) do
            if p:IsA("BasePart") and p ~= root and (p.Position - root.Position).Magnitude < 5 then
                local bv     = Instance.new("BodyVelocity")
                bv.Velocity  = (p.Position - root.Position).Unit * -500
                bv.MaxForce  = Vector3.new(1e9, 1e9, 1e9)
                bv.P         = 1e9
                bv.Parent    = p
                game:GetService("Debris"):AddItem(bv, 0.1)
            end
        end
    end)
end

local function stopFling()
    if touchConn then touchConn:Disconnect(); touchConn = nil end
end

-- ════════════════════════════════
--  ANTI-FLING
-- ════════════════════════════════
local antiFlingConn = nil

local function startAntiFling()
    if antiFlingConn then return end
    antiFlingConn = RunService.Heartbeat:Connect(function()
        local char = getCharacter()
        if not char then return end
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") and p.AssemblyLinearVelocity.Magnitude > 200 then
                p.AssemblyLinearVelocity = Vector3.zero
            end
        end
    end)
end

local function stopAntiFling()
    if antiFlingConn then antiFlingConn:Disconnect(); antiFlingConn = nil end
end

-- ════════════════════════════════
--  INFINITE JUMP
-- ════════════════════════════════
UserInputService.JumpRequest:Connect(function()
    if State.InfiniteJump then
        local hum = getHumanoid()
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- ════════════════════════════════
--  RENDER LOOP
-- ════════════════════════════════
RunService.RenderStepped:Connect(function()
    -- FOV circle
    fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    fovCircle.Radius   = State.AimbotFOV
    fovCircle.Visible  = State.AimbotEnabled

    -- Aimbot
    if State.AimbotEnabled then
        local target = getClosestInFOV()
        if target then
            local alpha   = 1 / (State.AimbotSmooth + 1)
            local current = Camera.CFrame
            local lookAt  = CFrame.lookAt(current.Position, target.Position)
            Camera.CFrame = current:Lerp(lookAt, alpha)
        end
    end

    -- ESP Box 2D
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end

        local obj = espObjects[player]
        if not obj then continue end

        local char = player.Character
        if not char or not State.ESPEnabled then
            for _, l in ipairs(obj.lines) do l.Visible = false end
            obj.label.Visible = false
            obj.fill.Visible  = false
            continue
        end

        local bounds, labelPos = getCharBounds(char)
        if not bounds then
            for _, l in ipairs(obj.lines) do l.Visible = false end
            obj.label.Visible = false
            obj.fill.Visible  = false
            continue
        end

        local c = State.ESPColor

        -- Linhas: top, right, bottom, left
        local corners = { bounds.tl, bounds.tr, bounds.br, bounds.bl }
        for i = 1, 4 do
            local l  = obj.lines[i]
            local a  = corners[i]
            local b  = corners[(i % 4) + 1]
            l.From    = a
            l.To      = b
            l.Color   = c
            l.Visible = true
        end

        -- Fill
        obj.fill.PointA      = bounds.tl
        obj.fill.PointB      = bounds.tr
        obj.fill.PointC      = bounds.br
        obj.fill.PointD      = bounds.bl
        obj.fill.Color       = c
        obj.fill.Transparency = 1 - State.ESPFillAlpha
        obj.fill.Visible     = State.ESPFill

        -- Label
        obj.label.Text     = player.Name
        obj.label.Color    = c
        obj.label.Position = labelPos
        obj.label.Visible  = true
    end
end)

-- ════════════════════════════════
--  PLAYER EVENTS
-- ════════════════════════════════
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then createESP(player) end
end

Players.PlayerAdded:Connect(function(player)
    createESP(player)
    player.CharacterAdded:Connect(function()
        if State.HitboxEnabled then
            task.wait(1); applyHitbox(player)
        end
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    cleanESP(player)
    removeHitbox(player)
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = State.WalkSpeed
        hum.JumpPower = State.JumpPower
    end
    if State.HitboxEnabled then refreshHitboxes() end
end)

-- ════════════════════════════════
--  WINDOW
-- ════════════════════════════════
local Window = WindUI:CreateWindow({
    Title       = "Universal Hub  V2",
    Folder      = "UniversalHubV2",
    Icon        = "solar:planet-bold",
    NewElements = true,
    HideSearchBar = false,
    OpenButton  = {
        Title           = "Hub",
        CornerRadius    = UDim.new(1, 0),
        StrokeThickness = 2,
        Enabled         = true,
        Draggable       = true,
        OnlyMobile      = false,
        Color = ColorSequence.new(
            Color3.fromHex("#7B2FFF"),
            Color3.fromHex("#FF2FA0")
        ),
    },
    Topbar = { Height = 44, ButtonsType = "Mac" },
})

WindUI:Notify({
    Title    = "Universal Hub V2",
    Content  = "Carregado! ESP Box 2D ativo.",
    Icon     = "solar:planet-bold",
    Duration = 4,
})

-- ════════════════════════════════
--  TABS
-- ════════════════════════════════
local TabTroll    = Window:Tab({ Title = "Troll",    Icon = "solar:bomb-bold",          IconColor = Color3.fromHex("#FF4444") })
local TabScripts  = Window:Tab({ Title = "Scripts",  Icon = "solar:code-square-bold",   IconColor = Color3.fromHex("#44AAFF") })
local TabPlayer   = Window:Tab({ Title = "Player",   Icon = "solar:running-round-bold", IconColor = Color3.fromHex("#44FF88") })
local TabCombat   = Window:Tab({ Title = "Combat",   Icon = "solar:target-bold",        IconColor = Color3.fromHex("#FFAA44") })
local TabSettings = Window:Tab({ Title = "Settings", Icon = "solar:settings-bold",      IconColor = Color3.fromHex("#AAAAFF") })

-- ══════════════════════════════════════════
--  TROLL / USEFUL
-- ══════════════════════════════════════════
do
    TabTroll:Section({ Title = "Fling" }):Toggle({
        Title    = "Touch Fling",
        Desc     = "Aplica força em objetos próximos",
        Value    = false,
        Callback = function(v)
            State.TouchFling = v
            if v then startFling() else stopFling() end
        end
    })

    TabTroll:Space()

    local secProt = TabTroll:Section({ Title = "Proteção" })
    secProt:Button({
        Title    = "Anti-Fling  (toggle)",
        Icon     = "shield",
        Justify  = "Center",
        Callback = function()
            State.AntiFling = not State.AntiFling
            if State.AntiFling then
                startAntiFling()
                WindUI:Notify({ Title = "Anti-Fling", Content = "ATIVADO", Icon = "shield", Duration = 3 })
            else
                stopAntiFling()
                WindUI:Notify({ Title = "Anti-Fling", Content = "DESATIVADO", Icon = "shield-off", Duration = 3 })
            end
        end
    })

    TabTroll:Space()

    local secTools = TabTroll:Section({ Title = "Tools" })

    local tools = {
        { "Instant Interact", "zap",    "https://pastefy.app/vg1Ap8MO/raw" },
        { "Destroy Tool",     "trash-2","https://rawscripts.net/raw/Universal-Script-destroy-tool-31432" },
        { "Fly Tool",         "wind",   "https://raw.githubusercontent.com/CoiledTom/Fly-tween-CoiledTom-/refs/heads/main/fly%20tween" },
        { "F3X Tool",         "box",    "https://rawscripts.net/raw/Universal-Script-F3X-Tool-44387" },
        { "Shift Lock",       "lock",   "https://raw.githubusercontent.com/CoiledTom/Shift-Lock-CoiledTom-/refs/heads/main/shift%20Lock%20CoiledTom" },
    }

    for i, t in ipairs(tools) do
        local title, icon, url = t[1], t[2], t[3]
        secTools:Button({
            Title    = title,
            Icon     = icon,
            Justify  = "Center",
            Callback = function()
                loadstring(game:HttpGet(url))()
            end
        })
        if i < #tools then TabTroll:Space() end
    end
end

-- ══════════════════════════════════════════
--  SCRIPTS
-- ══════════════════════════════════════════
do
    local sec = TabScripts:Section({ Title = "GUIs Externas" })

    local guis = {
        { "Fly GUI",      "airplay",  'https://raw.githubusercontent.com/CoiledTom/Fly-gui/refs/heads/main/%25' },
        { "Refast GUI",   "activity", 'https://raw.githubusercontent.com/CoiledTom/Refast-CoiledTom-/refs/heads/main/refast%20CoiledTom' },
        { "Speed GUI",    "zap",      'https://raw.githubusercontent.com/CoiledTom/Speed-CoiledTom-/refs/heads/main/speed%20CoiledTom' },
        { "Waypoint GUI", "map-pin",  'https://raw.githubusercontent.com/CoiledTom/Way-point-universal-/refs/heads/main/Teleport%2Btween' },
        { "Speed X Hub",  "rocket",   'https://raw.githubusercontent.com/AhmadV99/Speed-Hub-X/main/Speed%20Hub%20X.lua' },
    }

    for i, g in ipairs(guis) do
        local title, icon, url = g[1], g[2], g[3]
        sec:Button({
            Title    = title,
            Icon     = icon,
            Justify  = "Center",
            Callback = function()
                loadstring(game:HttpGet(url))()
            end
        })
        if i < #guis then TabScripts:Space() end
    end
end

-- ══════════════════════════════════════════
--  PLAYER
-- ══════════════════════════════════════════
do
    local sec = TabPlayer:Section({ Title = "Movimento" })

    sec:Slider({
        Flag     = "WalkSpeed",
        Title    = "WalkSpeed",
        Step     = 1,
        Value    = { Min = 0, Max = 500, Default = 16 },
        Callback = function(v)
            State.WalkSpeed = v
            local hum = getHumanoid()
            if hum then hum.WalkSpeed = v end
        end
    })

    TabPlayer:Space()

    sec:Slider({
        Flag     = "JumpPower",
        Title    = "JumpPower",
        Step     = 1,
        Value    = { Min = 0, Max = 500, Default = 50 },
        Callback = function(v)
            State.JumpPower = v
            local hum = getHumanoid()
            if hum then hum.JumpPower = v end
        end
    })

    TabPlayer:Space()

    TabPlayer:Section({ Title = "Pulo" }):Toggle({
        Flag     = "InfiniteJump",
        Title    = "Infinite Jump",
        Value    = false,
        Callback = function(v) State.InfiniteJump = v end
    })
end

-- ══════════════════════════════════════════
--  COMBAT
-- ══════════════════════════════════════════
do
    -- ── AIMBOT ──────────────────────────
    local secAim = TabCombat:Section({ Title = "Aimbot" })

    secAim:Toggle({
        Flag     = "AimbotEnabled",
        Title    = "Aimbot",
        Desc     = "Mira automática no alvo mais próximo do centro",
        Value    = false,
        Callback = function(v) State.AimbotEnabled = v end
    })

    TabCombat:Space()

    secAim:Toggle({
        Flag     = "TeamCheck",
        Title    = "Team Check",
        Desc     = "Ignora aliados",
        Value    = false,
        Callback = function(v) State.TeamCheck = v end
    })

    TabCombat:Space()

    secAim:Slider({
        Flag     = "AimbotFOV",
        Title    = "FOV  (px)",
        Step     = 1,
        Value    = { Min = 10, Max = 600, Default = 120 },
        Callback = function(v)
            State.AimbotFOV    = v
            fovCircle.Radius   = v
        end
    })

    TabCombat:Space()

    secAim:Slider({
        Flag     = "AimbotSmooth",
        Title    = "Smooth",
        Desc     = "Maior = mais suave / lento",
        Step     = 1,
        Value    = { Min = 1, Max = 30, Default = 5 },
        Callback = function(v) State.AimbotSmooth = v end
    })

    TabCombat:Space()

    -- ── ESP ─────────────────────────────
    local secESP = TabCombat:Section({ Title = "ESP  —  Box 2D" })

    secESP:Toggle({
        Flag     = "ESPEnabled",
        Title    = "ESP Box",
        Desc     = "Retângulo 2D em volta do corpo",
        Value    = false,
        Callback = function(v)
            State.ESPEnabled = v
            if not v then
                for _, obj in pairs(espObjects) do
                    for _, l in ipairs(obj.lines) do l.Visible = false end
                    obj.label.Visible = false
                    obj.fill.Visible  = false
                end
            end
        end
    })

    TabCombat:Space()

    secESP:Toggle({
        Flag     = "ESPFill",
        Title    = "Fill (preenchimento)",
        Value    = false,
        Callback = function(v) State.ESPFill = v end
    })

    TabCombat:Space()

    secESP:Colorpicker({
        Flag     = "ESPColor",
        Title    = "Cor do ESP",
        Default  = Color3.fromRGB(255, 50, 50),
        Callback = function(c) State.ESPColor = c end
    })

    TabCombat:Space()

    secESP:Slider({
        Flag     = "ESPFillAlpha",
        Title    = "Opacidade do Fill",
        Step     = 0.05,
        Value    = { Min = 0.05, Max = 1, Default = 0.15 },
        Callback = function(v) State.ESPFillAlpha = v end
    })

    TabCombat:Space()

    -- ── HITBOX ──────────────────────────
    local secHB = TabCombat:Section({ Title = "Hitbox Expander" })

    secHB:Toggle({
        Flag     = "HitboxEnabled",
        Title    = "Hitbox Expander",
        Value    = false,
        Callback = function(v)
            State.HitboxEnabled = v
            refreshHitboxes()
        end
    })

    TabCombat:Space()

    secHB:Slider({
        Flag     = "HitboxSize",
        Title    = "Tamanho",
        Step     = 0.5,
        Value    = { Min = 1, Max = 30, Default = 5 },
        Callback = function(v)
            State.HitboxSize = v
            if State.HitboxEnabled then refreshHitboxes() end
        end
    })

    TabCombat:Space()

    secHB:Slider({
        Flag     = "HitboxAlpha",
        Title    = "Transparência",
        Step     = 0.05,
        Value    = { Min = 0, Max = 1, Default = 0.5 },
        Callback = function(v)
            State.HitboxAlpha = v
            for _, p in pairs(hitboxParts) do
                p.Transparency = v
            end
        end
    })
end

-- ══════════════════════════════════════════
--  SETTINGS
-- ══════════════════════════════════════════
do
    local sec = TabSettings:Section({ Title = "Configuração" })

    sec:Button({
        Title    = "Salvar Config",
        Icon     = "save",
        Justify  = "Center",
        Callback = function()
            local ok, err = pcall(function()
                local data = {
                    WalkSpeed     = State.WalkSpeed,
                    JumpPower     = State.JumpPower,
                    InfiniteJump  = State.InfiniteJump,
                    AimbotEnabled = State.AimbotEnabled,
                    TeamCheck     = State.TeamCheck,
                    AimbotFOV    = State.AimbotFOV,
                    AimbotSmooth  = State.AimbotSmooth,
                    ESPEnabled   = State.ESPEnabled,
                    ESPFill      = State.ESPFill,
                    ESPFillAlpha = State.ESPFillAlpha,
                    HitboxEnabled = State.HitboxEnabled,
                    HitboxSize    = State.HitboxSize,
                    HitboxAlpha   = State.HitboxAlpha,
                    ESPColor = { State.ESPColor.R, State.ESPColor.G, State.ESPColor.B },
                }
                writefile("UniversalHubV2_Config.json", HttpService:JSONEncode(data))
            end)

            if ok then
                WindUI:Notify({ Title = "Salvo!", Content = "UniversalHubV2_Config.json", Icon = "check-circle", Duration = 4 })
            else
                WindUI:Notify({ Title = "Erro", Content = tostring(err), Icon = "alert-triangle", Duration = 5 })
            end
        end
    })

    TabSettings:Space()

    TabSettings:Section({ Title = "Atalhos" }):Keybind({
        Flag     = "ToggleUI",
        Title    = "Toggle UI",
        Desc     = "Abre/fecha o hub",
        Value    = "RightShift",
        Callback = function(v)
            pcall(function()
                Window:SetToggleKey(Enum.KeyCode[v])
            end)
        end
    })
end
