--[[
╔═══════════════════════════════════════════════════════╗
║           CoiledTom Hub  |  WindUI                   ║
║   ESP Box2D + Chams + Tracers + Distance + Health     ║
║   Anti-AFK · Anti-Kick · Anti-Void · Performance     ║
║              PC & Mobile Ready                        ║
╚═══════════════════════════════════════════════════════╝
]]

-- ═══════════════════════════════════
--  LOAD WindUI
-- ═══════════════════════════════════
local WindUI = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"
))()

-- ═══════════════════════════════════
--  SERVICES
-- ═══════════════════════════════════
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService      = game:GetService("HttpService")
local TeleportService  = game:GetService("TeleportService")
local StarterGui       = game:GetService("StarterGui")
local Lighting         = game:GetService("Lighting")
local GuiService       = game:GetService("GuiService")

local LocalPlayer = Players.LocalPlayer
local Camera      = workspace.CurrentCamera

-- ═══════════════════════════════════
--  ESTADO GLOBAL
-- ═══════════════════════════════════
local State = {
    -- Troll / Useful
    TouchFling    = false,
    AntiFling     = false,
    GodMode       = false,
    _godConn      = nil,
    AntiVoid      = false,
    AntiStun      = false,
    DeleteRagdoll = false,
    AutoRejoin    = false,
    ServerHopper  = false,

    -- Anti Protections
    AntiAFK       = false,
    AntiKick      = false,

    -- Player
    WalkSpeed     = 16,
    JumpPower     = 50,
    InfiniteJump  = false,

    -- Aimbot
    AimbotEnabled = false,
    TeamCheck     = false,
    AimbotFOV     = 120,
    AimbotSmooth  = 5,

    -- ESP
    ESPEnabled    = false,
    ESPColor      = Color3.fromRGB(255, 50, 50),
    ESPFill       = false,
    ESPFillAlpha  = 0.15,
    ChamEnabled   = false,
    ChamColor     = Color3.fromRGB(255, 100, 0),
    TracerEnabled = false,
    TracerColor   = Color3.fromRGB(0, 255, 128),
    DistESP       = false,
    HealthESP     = false,

    -- Hitbox
    HitboxEnabled = false,
    HitboxSize    = 5,
    HitboxAlpha   = 0.5,

    -- Performance
    AntiLag       = false,
    FPSBoost      = false,
    DisableParticles = false,
    TextureLow    = false,
    RemoveDecals  = false,
    DynRender     = false,
    EntityLimiter = false,
    LightingClean = false,
    LowPoly       = false,

    -- UI Accent
    AccentColor   = Color3.fromHex("#7B2FFF"),
}

-- ═══════════════════════════════════
--  HELPERS
-- ═══════════════════════════════════
local function getChar()  return LocalPlayer.Character end
local function getHum()
    local c = getChar(); return c and c:FindFirstChildOfClass("Humanoid")
end
local function getRoot()
    local c = getChar(); return c and c:FindFirstChild("HumanoidRootPart")
end
local function isEnemy(p)
    if not State.TeamCheck then return true end
    return p.Team ~= LocalPlayer.Team
end

-- ═══════════════════════════════════
--  THEME (WindUI)
-- ═══════════════════════════════════
WindUI:AddTheme({
    Name       = "HubTheme",
    Accent     = Color3.fromHex("#7B2FFF"),
    Background = Color3.fromHex("#0d0d0f"),
    Outline    = Color3.fromHex("#2a2a35"),
    Text       = Color3.fromHex("#f0f0ff"),
    Placeholder= Color3.fromHex("#666680"),
    Button     = Color3.fromHex("#1e1e2e"),
    Icon       = Color3.fromHex("#a080ff"),
})
WindUI:SetTheme("HubTheme")

-- ═══════════════════════════════════
--  WINDOW
-- ═══════════════════════════════════
local Window = WindUI:CreateWindow({
    Title         = "CoiledTom Hub",
    Author        = "by CoiledTom",
    Folder        = "CoiledTomHub",
    Icon          = "solar:planet-bold",
    NewElements   = true,
    HideSearchBar = false,
    OpenButton    = {
        Title           = "Hub  V3",
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

-- Tag de versão
Window:Tag({
    Title  = "v3.0",
    Icon   = "star",
    Color  = Color3.fromHex("#7B2FFF"),
    Border = true,
})

-- ═══════════════════════════════════
--  TABS
-- ═══════════════════════════════════
local TabLogs    = Window:Tab({ Title = "Logs",        Icon = "solar:document-text-bold",   IconColor = Color3.fromHex("#FFD700") })
local TabTroll   = Window:Tab({ Title = "Useful",      Icon = "solar:bomb-bold",            IconColor = Color3.fromHex("#FF4444") })
local TabScripts = Window:Tab({ Title = "Scripts",     Icon = "solar:code-square-bold",     IconColor = Color3.fromHex("#44AAFF") })
local TabPlayer  = Window:Tab({ Title = "Player",      Icon = "solar:running-round-bold",   IconColor = Color3.fromHex("#44FF88") })
local TabCombat  = Window:Tab({ Title = "Combat",      Icon = "solar:target-bold",          IconColor = Color3.fromHex("#FFAA44") })
local TabPerf    = Window:Tab({ Title = "Desempenho",  Icon = "solar:cpu-bolt-bold",        IconColor = Color3.fromHex("#00FFCC") })
local TabSettings= Window:Tab({ Title = "Settings",    Icon = "solar:settings-bold",        IconColor = Color3.fromHex("#AAAAFF") })

-- ═══════════════════════════════════════════════════
--  ABA: LOGS  (Changelog)
-- ═══════════════════════════════════════════════════
do
    local changelog = {
        {
            version = "v3.0  —  Mega Update",
            date    = "2025",
            items   = {
                "[NOVO] Aba Logs com changelog completo",
                "[NOVO] Anti-AFK integrado",
                "[NOVO] Anti-Kick / Anti-Ban básico",
                "[NOVO] Mudar cor do Accent da UI em Settings",
                "[NOVO] Chams (highlight colorido no corpo)",
                "[NOVO] Tracers (linha do centro até players)",
                "[NOVO] Distance ESP (distância em studs)",
                "[NOVO] Health ESP (barra de vida)",
                "[NOVO] Anti-Void (salva da morte por void)",
                "[NOVO] Anti-Stun",
                "[NOVO] Delete Ragdoll",
                "[NOVO] Auto Rejoin (caiu? volta sozinho)",
                "[NOVO] Server Hopper inteligente",
                "[NOVO] Aba Desempenho completa (9 funções)",
                "[MELHORIA] ESP Box 2D mais preciso",
                "[MELHORIA] Tema dark customizável",
                "[MELHORIA] Compatibilidade mobile melhorada",
            }
        },
        {
            version = "v2.0",
            date    = "2025",
            items   = {
                "[NOVO] ESP Box 2D com Drawing API",
                "[NOVO] Aimbot com FOV Circle",
                "[NOVO] Hitbox Expander",
                "[NOVO] Fill no ESP",
                "[MELHORIA] Performance do loop principal",
            }
        },
        {
            version = "v1.0",
            date    = "2025",
            items   = {
                "[LANÇAMENTO] Hub base com WindUI",
                "[NOVO] 5 abas principais",
                "[NOVO] WalkSpeed / JumpPower / InfiniteJump",
                "[NOVO] Tools via loadstring",
                "[NOVO] Salvar config em arquivo",
            }
        },
    }

    -- ── Discord ──────────────────────────────────────────
    local discSec = TabLogs:Section({ Title = "💬 Suporte" })

    discSec:Section({
        Title        = "Aqui está o Discord caso ache um bug ou erro:",
        TextSize     = 14,
        TextTransparency = 0.2,
    })

    discSec:Button({
        Title    = "Copiar link do Discord",
        Icon     = "link",
        Justify  = "Center",
        Color    = Color3.fromHex("#5865F2"),
        Callback = function()
            setclipboard("https://discord.gg/xzHe9QeqVv")
            WindUI:Notify({
                Title   = "Discord",
                Content = "Link copiado! discord.gg/xzHe9QeqVv",
                Icon    = "check-circle",
                Duration = 3,
            })
        end
    })

    TabLogs:Space()

    -- ── Changelog ────────────────────────────────────────
    local logSec = TabLogs:Section({ Title = "📋 Histórico de Atualizações" })

    for _, entry in ipairs(changelog) do
        logSec:Section({
            Title        = entry.version .. "  ·  " .. entry.date,
            TextSize     = 15,
            FontWeight   = Enum.FontWeight.Bold,
        })
        local text = ""
        for _, item in ipairs(entry.items) do
            text = text .. item .. "\n"
        end
        logSec:Section({
            Title           = text,
            TextSize        = 13,
            TextTransparency = 0.3,
        })
        TabLogs:Space()
    end
end

-- ═══════════════════════════════════════════════════
--  DRAWING OBJECTS — ESP
-- ═══════════════════════════════════════════════════
local espObjects = {}   -- [player] = { lines, label, fill, tracer, distLabel, healthBg, healthBar, chams={} }

local function newLine(col, thick)
    local l = Drawing.new("Line")
    l.Visible   = false
    l.Color     = col or Color3.fromRGB(255,50,50)
    l.Thickness = thick or 1.5
    return l
end

local function newText(size, col)
    local t = Drawing.new("Text")
    t.Visible  = false
    t.Size     = size or 14
    t.Outline  = true
    t.Color    = col or Color3.fromRGB(255,255,255)
    t.Text     = ""
    return t
end

local function newQuad(col, alpha)
    local q = Drawing.new("Quad")
    q.Visible      = false
    q.Filled       = true
    q.Color        = col or Color3.fromRGB(255,50,50)
    q.Transparency = alpha or 0.85
    return q
end

local function cleanESP(player)
    local obj = espObjects[player]
    if not obj then return end
    for _, l in ipairs(obj.lines) do l:Remove() end
    obj.label:Remove()
    obj.fill:Remove()
    obj.tracer:Remove()
    obj.distLabel:Remove()
    obj.healthBg:Remove()
    obj.healthBar:Remove()
    -- chams são SelectionBox instances, destruir
    for _, sb in ipairs(obj.chams) do pcall(function() sb:Destroy() end) end
    espObjects[player] = nil
end

local function buildESP(player)
    cleanESP(player)
    local lines = {}
    for _ = 1, 4 do table.insert(lines, newLine()) end

    -- health bar background (cinza)
    local healthBg  = newLine(Color3.fromRGB(50,50,50), 4)
    -- health bar foreground (verde)
    local healthBar = newLine(Color3.fromRGB(0,220,80),  4)

    espObjects[player] = {
        lines      = lines,
        label      = newText(14, State.ESPColor),
        fill       = newQuad(State.ESPColor, 0.85),
        tracer     = newLine(State.TracerColor, 1.5),
        distLabel  = newText(12, Color3.fromRGB(255,220,80)),
        healthBg   = healthBg,
        healthBar  = healthBar,
        chams      = {},
    }
end

-- Chams usando SelectionBox (highlight no model)
local function applyCham(player)
    local obj = espObjects[player]
    if not obj then return end
    -- remove antigos
    for _, sb in ipairs(obj.chams) do pcall(function() sb:Destroy() end) end
    obj.chams = {}

    local char = player.Character
    if not char then return end

    local sb = Instance.new("SelectionBox")
    sb.Color3         = State.ChamColor
    sb.LineThickness  = 0.05
    sb.SurfaceColor3  = State.ChamColor
    sb.SurfaceTransparency = 0.5
    sb.Adornee        = char
    sb.Parent         = workspace
    table.insert(obj.chams, sb)
end

local function removeCham(player)
    local obj = espObjects[player]
    if not obj then return end
    for _, sb in ipairs(obj.chams) do pcall(function() sb:Destroy() end) end
    obj.chams = {}
end

-- ═══════════════════════════════════
--  BOUNDING BOX 2D
-- ═══════════════════════════════════
local function getCharBounds(char)
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum  = char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return nil end

    local height  = (hum.HipHeight * 2) + 1.2
    local topPos  = root.Position + Vector3.new(0, height * 0.55, 0)
    local botPos  = root.Position - Vector3.new(0, height * 0.45, 0)

    local tSP, onT = Camera:WorldToViewportPoint(topPos)
    local bSP, onB = Camera:WorldToViewportPoint(botPos)
    if not onT or not onB then return nil end

    local h  = math.abs(tSP.Y - bSP.Y)
    local w  = h * 0.55
    local cx = (tSP.X + bSP.X) / 2

    local x1, x2 = cx - w/2, cx + w/2
    local y1, y2 = tSP.Y, bSP.Y

    return {
        tl = Vector2.new(x1, y1),
        tr = Vector2.new(x2, y1),
        br = Vector2.new(x2, y2),
        bl = Vector2.new(x1, y2),
        cx = cx,
        top = y1,
        bot = y2,
        w   = w,
    }, Vector2.new(cx, y1 - 16), h
end

-- ═══════════════════════════════════
--  FOV CIRCLE
-- ═══════════════════════════════════
local fovCircle     = Drawing.new("Circle")
fovCircle.Visible   = false
fovCircle.Radius    = State.AimbotFOV
fovCircle.Color     = Color3.fromRGB(255,255,255)
fovCircle.Thickness = 1.5
fovCircle.Filled    = false
fovCircle.Position  = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

-- ═══════════════════════════════════
--  HITBOX
-- ═══════════════════════════════════
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
    local p         = Instance.new("Part")
    p.Name          = "HitboxExpand"
    p.Size          = Vector3.new(State.HitboxSize, State.HitboxSize, State.HitboxSize)
    p.Anchored      = false
    p.CanCollide    = false
    p.Massless      = true
    p.Transparency  = State.HitboxAlpha
    p.BrickColor    = BrickColor.new("Bright red")
    p.Material      = Enum.Material.ForceField
    p.Parent        = char
    local w = Instance.new("WeldConstraint")
    w.Part0 = root; w.Part1 = p; w.Parent = p
    hitboxParts[player] = p
end

local function refreshHitboxes()
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl ~= LocalPlayer then
            if State.HitboxEnabled then applyHitbox(pl) else removeHitbox(pl) end
        end
    end
end

-- ═══════════════════════════════════
--  AIMBOT TARGET
-- ═══════════════════════════════════
local function getClosestInFOV()
    local closest, closestDist = nil, math.huge
    local cx = Camera.ViewportSize.X / 2
    local cy = Camera.ViewportSize.Y / 2
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl == LocalPlayer then continue end
        if not isEnemy(pl) then continue end
        local char = pl.Character
        if not char then continue end
        local head = char:FindFirstChild("Head")
        if not head then continue end
        local sp, on = Camera:WorldToViewportPoint(head.Position)
        if not on then continue end
        local d = math.sqrt((sp.X-cx)^2 + (sp.Y-cy)^2)
        if d < State.AimbotFOV and d < closestDist then
            closest = head; closestDist = d
        end
    end
    return closest
end

-- ═══════════════════════════════════
--  TOUCH FLING
-- ═══════════════════════════════════
local touchConn = nil
local function startFling()
    if touchConn then return end
    touchConn = RunService.Heartbeat:Connect(function()
        local root = getRoot(); if not root then return end
        for _, p in ipairs(workspace:GetDescendants()) do
            if p:IsA("BasePart") and p ~= root and (p.Position - root.Position).Magnitude < 5 then
                local bv = Instance.new("BodyVelocity")
                bv.Velocity = (p.Position - root.Position).Unit * -500
                bv.MaxForce = Vector3.new(1e9,1e9,1e9); bv.P = 1e9; bv.Parent = p
                game:GetService("Debris"):AddItem(bv, 0.1)
            end
        end
    end)
end
local function stopFling()
    if touchConn then touchConn:Disconnect(); touchConn = nil end
end

-- ═══════════════════════════════════
--  ANTI-FLING
-- ═══════════════════════════════════
local antiFlingConn = nil
local function startAntiFling()
    if antiFlingConn then return end
    antiFlingConn = RunService.Heartbeat:Connect(function()
        local char = getChar(); if not char then return end
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

-- ═══════════════════════════════════
--  ANTI-VOID
-- ═══════════════════════════════════
local antiVoidConn = nil
local safePos = Vector3.new(0, 50, 0)

local function startAntiVoid()
    if antiVoidConn then return end
    antiVoidConn = RunService.Heartbeat:Connect(function()
        local root = getRoot(); if not root then return end
        if root.Position.Y > -50 then
            safePos = root.Position
        else
            root.CFrame = CFrame.new(safePos)
        end
    end)
end
local function stopAntiVoid()
    if antiVoidConn then antiVoidConn:Disconnect(); antiVoidConn = nil end
end

-- ═══════════════════════════════════
--  ANTI-STUN
-- ═══════════════════════════════════
local antiStunConn = nil
local function startAntiStun()
    if antiStunConn then return end
    antiStunConn = RunService.Heartbeat:Connect(function()
        local hum = getHum(); if not hum then return end
        local s = hum:GetState()
        if s == Enum.HumanoidStateType.Stunned or s == Enum.HumanoidStateType.FallingDown then
            hum:ChangeState(Enum.HumanoidStateType.Running)
        end
    end)
end
local function stopAntiStun()
    if antiStunConn then antiStunConn:Disconnect(); antiStunConn = nil end
end

-- ═══════════════════════════════════
--  DELETE RAGDOLL
-- ═══════════════════════════════════
local function deleteRagdoll()
    local char = getChar(); if not char then return end
    for _, v in ipairs(char:GetDescendants()) do
        if v:IsA("BallSocketConstraint") or v:IsA("HingeConstraint") or
           v.Name == "Ragdoll" or v.Name == "RagdollConstraint" then
            v:Destroy()
        end
    end
end

-- ═══════════════════════════════════
--  ANTI-AFK
-- ═══════════════════════════════════
local antiAFKConn = nil
local function startAntiAFK()
    if antiAFKConn then return end
    antiAFKConn = RunService.Heartbeat:Connect(function()
        -- Simula atividade via VirtualInputManager se disponível
        pcall(function()
            local vim = game:GetService("VirtualInputManager")
            vim:SendKeyEvent(true,  Enum.KeyCode.W, false, game)
            vim:SendKeyEvent(false, Enum.KeyCode.W, false, game)
        end)
    end)
    -- Também reseta o idle timer via método alternativo
    LocalPlayer.Idled:Connect(function()
        if State.AntiAFK then
            pcall(function()
                StarterGui:SetCore("SendNotification", {
                    Title = "Anti-AFK", Text = "Kick evitado!", Duration = 2
                })
            end)
        end
    end)
end
local function stopAntiAFK()
    if antiAFKConn then antiAFKConn:Disconnect(); antiAFKConn = nil end
end

-- ═══════════════════════════════════
--  ANTI-KICK  (hook básico)
-- ═══════════════════════════════════
local kickHooked = false
local function hookAntiKick()
    if kickHooked then return end
    kickHooked = true
    -- Sobrescreve o método Kick do LocalPlayer
    local mt = getrawmetatable and getrawmetatable(game)
    if mt then
        local oldIndex = mt.__namecall
        local ro = setreadonly or (function() end)
        pcall(ro, mt, false)
        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod and getnamecallmethod() or ""
            if method == "Kick" and self == LocalPlayer and State.AntiKick then
                WindUI:Notify({ Title="Anti-Kick", Content="Kick bloqueado!", Icon="shield", Duration=3 })
                return
            end
            return oldIndex(self, ...)
        end)
        pcall(ro, mt, true)
    end
end

-- ═══════════════════════════════════
--  AUTO REJOIN
-- ═══════════════════════════════════
local function setupAutoRejoin()
    game:GetService("Players").LocalPlayer.OnTeleport:Connect(function(state)
        if state == Enum.TeleportState.Failed and State.AutoRejoin then
            task.wait(3)
            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
        end
    end)

    -- Detecta queda de conexão / disconnect
    game:GetService("RunService").Heartbeat:Connect(function()
        -- placeholder: monitora a conexão via ping
    end)
end

-- ═══════════════════════════════════
--  SERVER HOPPER
-- ═══════════════════════════════════
local hopperActive = false
local function startServerHop()
    if hopperActive then return end
    hopperActive = true
    task.spawn(function()
        while hopperActive do
            local ok, servers = pcall(function()
                return HttpService:JSONDecode(
                    game:HttpGet("https://games.roblox.com/v1/games/" ..
                        game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=25")
                )
            end)
            if ok and servers and servers.data then
                local best = nil
                local bestPing = math.huge
                for _, s in ipairs(servers.data) do
                    if s.id ~= game.JobId and s.playing and s.maxPlayers then
                        local ping = s.ping or 9999
                        if ping < bestPing and s.playing < s.maxPlayers then
                            best = s; bestPing = ping
                        end
                    end
                end
                if best then
                    WindUI:Notify({ Title="Server Hopper", Content="Conectando ao melhor server...", Icon="wifi", Duration=3 })
                    task.wait(2)
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, best.id, LocalPlayer)
                    break
                end
            end
            task.wait(5)
        end
        hopperActive = false
    end)
end

-- ═══════════════════════════════════
--  INFINITE JUMP
-- ═══════════════════════════════════
UserInputService.JumpRequest:Connect(function()
    if State.InfiniteJump then
        local hum = getHum()
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- ═══════════════════════════════════
--  PERFORMANCE FUNÇÕES
-- ═══════════════════════════════════
local perfConns = {}
local originalTextures = {}
local removedObjects  = {}

local function disableParticles(enable)
    if enable then
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("ParticleEmitter") or v:IsA("Smoke") or
               v:IsA("Fire") or v:IsA("Sparkles") then
                v.Enabled = false
            end
        end
    else
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("ParticleEmitter") or v:IsA("Smoke") or
               v:IsA("Fire") or v:IsA("Sparkles") then
                pcall(function() v.Enabled = true end)
            end
        end
    end
end

local function setTextureLow(enable)
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            if enable then
                originalTextures[v] = v.Material
                v.Material = Enum.Material.SmoothPlastic
            elseif originalTextures[v] then
                pcall(function() v.Material = originalTextures[v] end)
            end
        end
    end
end

local function removeDecals(enable)
    if enable then
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("Decal") or v:IsA("Texture") or v:IsA("SpecialMesh") then
                table.insert(removedObjects, { obj = v, parent = v.Parent })
                v.Parent = nil
            end
        end
    else
        for _, entry in ipairs(removedObjects) do
            pcall(function() entry.obj.Parent = entry.parent end)
        end
        removedObjects = {}
    end
end

local dynConn = nil
local function setDynamicRender(enable)
    if dynConn then dynConn:Disconnect(); dynConn = nil end
    if enable then
        dynConn = RunService.Heartbeat:Connect(function()
            local ping = LocalPlayer.NetworkPing or 0.05
            if ping > 0.15 then
                settings().Rendering.QualityLevel = 1
            else
                settings().Rendering.QualityLevel = 5
            end
        end)
    else
        pcall(function() settings().Rendering.QualityLevel = 5 end)
    end
    if dynConn then table.insert(perfConns, dynConn) end
end

local entityConn = nil
local function setEntityLimiter(enable)
    if entityConn then entityConn:Disconnect(); entityConn = nil end
    if enable then
        entityConn = RunService.Heartbeat:Connect(function()
            local count = 0
            for _, v in ipairs(workspace:GetDescendants()) do
                if v:IsA("Model") and not Players:GetPlayerFromCharacter(v) then
                    count = count + 1
                    if count > 80 then v:Destroy() end
                end
            end
        end)
    end
end

local function cleanLighting(enable)
    if enable then
        Lighting.FogEnd          = 1e6
        Lighting.FogStart        = 1e6
        Lighting.GlobalShadows   = false
        Lighting.Brightness      = 2
        for _, v in ipairs(Lighting:GetChildren()) do
            if v:IsA("BlurEffect") or v:IsA("DepthOfFieldEffect") or
               v:IsA("SunRaysEffect") or v:IsA("ColorCorrectionEffect") or
               v:IsA("BloomEffect") then
                v.Enabled = false
            end
        end
    else
        Lighting.GlobalShadows = true
        for _, v in ipairs(Lighting:GetChildren()) do
            pcall(function() v.Enabled = true end)
        end
    end
end

local function setLowPoly(enable)
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("MeshPart") or v:IsA("SpecialMesh") then
            if enable then
                pcall(function() v.LODFactor = 0.25 end)
            else
                pcall(function() v.LODFactor = 1 end)
            end
        end
    end
end

local function applyFPSBoost(enable)
    if enable then
        pcall(function() settings().Rendering.QualityLevel = 1 end)
        cleanLighting(true)
        disableParticles(true)
    else
        pcall(function() settings().Rendering.QualityLevel = 5 end)
    end
end

local function applyAntiLag(enable)
    if enable then
        pcall(function() settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Disabled end)
        pcall(function() settings().Rendering.EagerBulkExecution = true end)
    end
end

-- ═══════════════════════════════════
--  RENDER LOOP PRINCIPAL
-- ═══════════════════════════════════
RunService.RenderStepped:Connect(function()
    -- FOV circle
    fovCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
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

    -- ESP
    local cx = Camera.ViewportSize.X / 2
    local cy = Camera.ViewportSize.Y  -- tracer começa embaixo da tela

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        local obj = espObjects[player]
        if not obj then continue end

        local char = player.Character
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        local root = char and char:FindFirstChild("HumanoidRootPart")

        local anyESP = State.ESPEnabled or State.TracerEnabled or
                       State.DistESP    or State.HealthESP

        if not char or not anyESP then
            for _, l in ipairs(obj.lines) do l.Visible = false end
            obj.label.Visible    = false
            obj.fill.Visible     = false
            obj.tracer.Visible   = false
            obj.distLabel.Visible= false
            obj.healthBg.Visible = false
            obj.healthBar.Visible= false
            continue
        end

        local bounds, labelPos, boxH = getCharBounds(char)
        if not bounds then
            for _, l in ipairs(obj.lines) do l.Visible = false end
            obj.label.Visible    = false
            obj.fill.Visible     = false
            obj.tracer.Visible   = false
            obj.distLabel.Visible= false
            obj.healthBg.Visible = false
            obj.healthBar.Visible= false
            continue
        end

        local col = State.ESPColor

        -- ── BOX 2D ──
        if State.ESPEnabled then
            local corners = { bounds.tl, bounds.tr, bounds.br, bounds.bl }
            for i = 1, 4 do
                local l = obj.lines[i]
                l.From    = corners[i]
                l.To      = corners[(i % 4) + 1]
                l.Color   = col
                l.Visible = true
            end
            -- nome acima
            obj.label.Text     = player.Name
            obj.label.Color    = col
            obj.label.Position = labelPos
            obj.label.Visible  = true
            -- fill
            obj.fill.PointA    = bounds.tl
            obj.fill.PointB    = bounds.tr
            obj.fill.PointC    = bounds.br
            obj.fill.PointD    = bounds.bl
            obj.fill.Color     = col
            obj.fill.Transparency = 1 - State.ESPFillAlpha
            obj.fill.Visible   = State.ESPFill
        else
            for _, l in ipairs(obj.lines) do l.Visible = false end
            obj.label.Visible = false
            obj.fill.Visible  = false
        end

        -- ── TRACER ──
        if State.TracerEnabled and root then
            local sp, on = Camera:WorldToViewportPoint(root.Position)
            if on then
                obj.tracer.From    = Vector2.new(cx, cy)
                obj.tracer.To      = Vector2.new(sp.X, sp.Y)
                obj.tracer.Color   = State.TracerColor
                obj.tracer.Visible = true
            else
                obj.tracer.Visible = false
            end
        else
            obj.tracer.Visible = false
        end

        -- ── DISTANCE ESP ──
        if State.DistESP and root then
            local myRoot = getRoot()
            if myRoot then
                local dist = math.floor((root.Position - myRoot.Position).Magnitude)
                obj.distLabel.Text     = dist .. " studs"
                obj.distLabel.Color    = Color3.fromRGB(255,220,80)
                obj.distLabel.Position = Vector2.new(bounds.cx, bounds.bot + 2)
                obj.distLabel.Visible  = true
            else
                obj.distLabel.Visible = false
            end
        else
            obj.distLabel.Visible = false
        end

        -- ── HEALTH ESP (barra vertical à esquerda do box) ──
        if State.HealthESP and hum then
            local hp     = hum.Health
            local maxHp  = hum.MaxHealth
            local ratio  = maxHp > 0 and (hp / maxHp) or 0

            local barX   = bounds.tl.X - 5
            local barTop = bounds.tl.Y
            local barBot = bounds.bl.Y
            local barH   = barBot - barTop

            -- fundo cinza (barra completa)
            obj.healthBg.From    = Vector2.new(barX, barTop)
            obj.healthBg.To      = Vector2.new(barX, barBot)
            obj.healthBg.Visible = true

            -- barra colorida (proporcional à vida)
            local healthColor = Color3.fromRGB(
                math.floor(255 * (1 - ratio)),
                math.floor(255 * ratio),
                50
            )
            obj.healthBar.From    = Vector2.new(barX, barBot)
            obj.healthBar.To      = Vector2.new(barX, barBot - barH * ratio)
            obj.healthBar.Color   = healthColor
            obj.healthBar.Visible = true
        else
            obj.healthBg.Visible  = false
            obj.healthBar.Visible = false
        end
    end
end)

-- ═══════════════════════════════════
--  PLAYER EVENTS
-- ═══════════════════════════════════
for _, pl in ipairs(Players:GetPlayers()) do
    if pl ~= LocalPlayer then buildESP(pl) end
end

Players.PlayerAdded:Connect(function(pl)
    buildESP(pl)
    pl.CharacterAdded:Connect(function()
        task.wait(1)
        if State.HitboxEnabled then applyHitbox(pl) end
        if State.ChamEnabled   then applyCham(pl)   end
    end)
end)

Players.PlayerRemoving:Connect(function(pl)
    cleanESP(pl); removeHitbox(pl)
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = State.WalkSpeed
        hum.JumpPower = State.JumpPower
        -- Reaplica God Mode após respawn
        if State.GodMode then
            hum.MaxHealth = math.huge
            hum.Health    = math.huge
            if State._godConn then State._godConn:Disconnect() end
            State._godConn = hum.HealthChanged:Connect(function(hp)
                if State.GodMode and hp < hum.MaxHealth then
                    hum.Health = math.huge
                end
            end)
        end
    end
    if State.HitboxEnabled then refreshHitboxes() end
    if State.DeleteRagdoll  then task.wait(0.3); deleteRagdoll() end
end)

setupAutoRejoin()

-- ══════════════════════════════════════════════════════
--  ABA: USEFUL / TROLL
-- ══════════════════════════════════════════════════════
do
    -- Fling
    local s1 = TabTroll:Section({ Title = "Fling" })
    s1:Toggle({
        Title = "Touch Fling", Desc = "Força nos objetos próximos", Value = false,
        Callback = function(v) State.TouchFling = v; if v then startFling() else stopFling() end end
    })
    TabTroll:Space()
    s1:Button({
        Title = "Anti-Fling  (toggle)", Icon = "shield", Justify = "Center",
        Callback = function()
            State.AntiFling = not State.AntiFling
            if State.AntiFling then startAntiFling() else stopAntiFling() end
            WindUI:Notify({ Title="Anti-Fling", Content = State.AntiFling and "ATIVADO" or "DESATIVADO", Icon="shield", Duration=2 })
        end
    })

    TabTroll:Space()

    -- Proteções
    local s2 = TabTroll:Section({ Title = "Proteções" })
    s2:Toggle({
        Title = "God Mode", Desc = "Vida máxima infinita — difícil de matar", Value = false,
        Callback = function(v)
            State.GodMode = v
            local char = getChar()
            local hum  = char and char:FindFirstChildOfClass("Humanoid")
            if not hum then return end
            if v then
                -- Método 1: MaxHealth absurdo + heal loop
                hum.MaxHealth = math.huge
                hum.Health    = math.huge
                -- Método 2: bloqueia dano via HealthChanged
                if not State._godConn then
                    State._godConn = hum.HealthChanged:Connect(function(hp)
                        if State.GodMode and hp < hum.MaxHealth then
                            hum.Health = math.huge
                        end
                    end)
                end
            else
                hum.MaxHealth = 100
                hum.Health    = 100
                if State._godConn then
                    State._godConn:Disconnect()
                    State._godConn = nil
                end
            end
        end
    })
    TabTroll:Space()
    s2:Toggle({
        Title = "Anti-Void", Desc = "Teleporta de volta se cair no void", Value = false,
        Callback = function(v) State.AntiVoid = v; if v then startAntiVoid() else stopAntiVoid() end end
    })
    TabTroll:Space()
    s2:Toggle({
        Title = "Anti-Stun", Desc = "Remove stun / knock-down", Value = false,
        Callback = function(v) State.AntiStun = v; if v then startAntiStun() else stopAntiStun() end end
    })
    TabTroll:Space()
    s2:Button({
        Title = "Delete Ragdoll", Icon = "trash-2", Justify = "Center",
        Desc  = "Remove constraints de ragdoll do personagem",
        Callback = function() deleteRagdoll(); WindUI:Notify({ Title="Ragdoll", Content="Deletado!", Icon="check", Duration=2 }) end
    })

    TabTroll:Space()

    -- Servidor
    local s3 = TabTroll:Section({ Title = "Servidor" })
    s3:Toggle({
        Title = "Auto Rejoin", Desc = "Caiu? Volta sozinho ao server", Value = false,
        Callback = function(v) State.AutoRejoin = v end
    })
    TabTroll:Space()
    s3:Button({
        Title = "Server Hopper", Icon = "wifi", Justify = "Center",
        Desc  = "Vai para o server com menor ping",
        Callback = function()
            WindUI:Notify({ Title="Server Hopper", Content="Buscando melhor server...", Icon="wifi", Duration=3 })
            startServerHop()
        end
    })

    TabTroll:Space()

    -- Tools
    local s4 = TabTroll:Section({ Title = "Tools" })
    local tools = {
        { "Instant Interact", "zap",    "https://pastefy.app/vg1Ap8MO/raw" },
        { "Destroy Tool",     "trash-2","https://rawscripts.net/raw/Universal-Script-destroy-tool-31432" },
        { "Fly Tool",         "wind",   "https://raw.githubusercontent.com/CoiledTom/Fly-tween-CoiledTom-/refs/heads/main/fly%20tween" },
        { "F3X Tool",         "box",    "https://rawscripts.net/raw/Universal-Script-F3X-Tool-44387" },
        { "Shift Lock",       "lock",   "https://raw.githubusercontent.com/CoiledTom/Shift-Lock-CoiledTom-/refs/heads/main/shift%20Lock%20CoiledTom" },
    }
    for i, t in ipairs(tools) do
        s4:Button({ Title=t[1], Icon=t[2], Justify="Center", Callback=function() loadstring(game:HttpGet(t[3]))() end })
        if i < #tools then TabTroll:Space() end
    end
end

-- ══════════════════════════════════════════════════════
--  ABA: SCRIPTS
-- ══════════════════════════════════════════════════════
do
    local sec = TabScripts:Section({ Title = "GUIs Externas" })
    local guis = {
        { "Fly GUI",      "airplay",  "https://raw.githubusercontent.com/CoiledTom/Fly-gui/refs/heads/main/%25" },
        { "Refast GUI",   "activity", "https://raw.githubusercontent.com/CoiledTom/Refast-CoiledTom-/refs/heads/main/refast%20CoiledTom" },
        { "Speed GUI",    "zap",      "https://raw.githubusercontent.com/CoiledTom/Speed-CoiledTom-/refs/heads/main/speed%20CoiledTom" },
        { "Waypoint GUI", "map-pin",  "https://raw.githubusercontent.com/CoiledTom/Way-point-universal-/refs/heads/main/Teleport%2Btween" },
        { "Speed X Hub",  "rocket",   "https://raw.githubusercontent.com/AhmadV99/Speed-Hub-X/main/Speed%20Hub%20X.lua" },
    }
    for i, g in ipairs(guis) do
        sec:Button({ Title=g[1], Icon=g[2], Justify="Center", Callback=function() loadstring(game:HttpGet(g[3]))() end })
        if i < #guis then TabScripts:Space() end
    end
end

-- ══════════════════════════════════════════════════════
--  ABA: PLAYER
-- ══════════════════════════════════════════════════════
do
    local sec = TabPlayer:Section({ Title = "Movimento" })
    sec:Slider({
        Flag="WalkSpeed", Title="WalkSpeed", Step=1, Value={Min=0,Max=500,Default=16},
        Callback=function(v) State.WalkSpeed=v; local h=getHum(); if h then h.WalkSpeed=v end end
    })
    TabPlayer:Space()
    sec:Slider({
        Flag="JumpPower", Title="JumpPower", Step=1, Value={Min=0,Max=500,Default=50},
        Callback=function(v) State.JumpPower=v; local h=getHum(); if h then h.JumpPower=v end end
    })
    TabPlayer:Space()
    TabPlayer:Section({ Title="Pulo" }):Toggle({
        Flag="InfiniteJump", Title="Infinite Jump", Value=false,
        Callback=function(v) State.InfiniteJump=v end
    })
end

-- ══════════════════════════════════════════════════════
--  ABA: COMBAT
-- ══════════════════════════════════════════════════════
do
    -- Aimbot
    local sAim = TabCombat:Section({ Title = "Aimbot" })
    sAim:Toggle({ Flag="AimbotEnabled", Title="Aimbot", Desc="Mira automática", Value=false,
        Callback=function(v) State.AimbotEnabled=v end })
    TabCombat:Space()
    sAim:Toggle({ Flag="TeamCheck", Title="Team Check", Desc="Ignora aliados", Value=false,
        Callback=function(v) State.TeamCheck=v end })
    TabCombat:Space()
    sAim:Slider({ Flag="AimbotFOV", Title="FOV (px)", Step=1, Value={Min=10,Max=600,Default=120},
        Callback=function(v) State.AimbotFOV=v; fovCircle.Radius=v end })
    TabCombat:Space()
    sAim:Slider({ Flag="AimbotSmooth", Title="Smooth", Desc="Maior = mais suave", Step=1, Value={Min=1,Max=30,Default=5},
        Callback=function(v) State.AimbotSmooth=v end })

    TabCombat:Space()

    -- ESP Box 2D
    local sESP = TabCombat:Section({ Title = "ESP  —  Box 2D" })
    sESP:Toggle({ Flag="ESPEnabled", Title="ESP Box", Desc="Retângulo 2D em volta do corpo", Value=false,
        Callback=function(v) State.ESPEnabled=v end })
    TabCombat:Space()
    sESP:Toggle({ Flag="ESPFill", Title="Fill", Value=false,
        Callback=function(v) State.ESPFill=v end })
    TabCombat:Space()
    sESP:Colorpicker({ Flag="ESPColor", Title="Cor do ESP", Default=Color3.fromRGB(255,50,50),
        Callback=function(c) State.ESPColor=c end })
    TabCombat:Space()
    sESP:Slider({ Flag="ESPFillAlpha", Title="Opacidade Fill", Step=0.05, Value={Min=0.05,Max=1,Default=0.15},
        Callback=function(v) State.ESPFillAlpha=v end })

    TabCombat:Space()

    -- Chams
    local sChams = TabCombat:Section({ Title = "Chams" })
    sChams:Toggle({ Flag="ChamEnabled", Title="Chams", Desc="Highlight colorido no body dos players", Value=false,
        Callback=function(v)
            State.ChamEnabled = v
            for _, pl in ipairs(Players:GetPlayers()) do
                if pl ~= LocalPlayer then
                    if v then applyCham(pl) else removeCham(pl) end
                end
            end
        end
    })
    TabCombat:Space()
    sChams:Colorpicker({ Flag="ChamColor", Title="Cor dos Chams", Default=Color3.fromRGB(255,100,0),
        Callback=function(c)
            State.ChamColor=c
            if State.ChamEnabled then
                for _, pl in ipairs(Players:GetPlayers()) do
                    if pl ~= LocalPlayer then applyCham(pl) end
                end
            end
        end
    })

    TabCombat:Space()

    -- Tracers
    local sTracer = TabCombat:Section({ Title = "Tracers" })
    sTracer:Toggle({ Flag="TracerEnabled", Title="Tracers", Desc="Linha do centro da tela até o player", Value=false,
        Callback=function(v) State.TracerEnabled=v end })
    TabCombat:Space()
    sTracer:Colorpicker({ Flag="TracerColor", Title="Cor dos Tracers", Default=Color3.fromRGB(0,255,128),
        Callback=function(c) State.TracerColor=c end })

    TabCombat:Space()

    -- Distance + Health
    local sExtra = TabCombat:Section({ Title = "Info Extra" })
    sExtra:Toggle({ Flag="DistESP", Title="Distance ESP", Desc="Distância em studs abaixo do box", Value=false,
        Callback=function(v) State.DistESP=v end })
    TabCombat:Space()
    sExtra:Toggle({ Flag="HealthESP", Title="Health ESP", Desc="Barra de vida à esquerda do box", Value=false,
        Callback=function(v) State.HealthESP=v end })

    TabCombat:Space()

    -- Hitbox
    local sHB = TabCombat:Section({ Title = "Hitbox Expander" })
    sHB:Toggle({ Flag="HitboxEnabled", Title="Hitbox Expander", Value=false,
        Callback=function(v) State.HitboxEnabled=v; refreshHitboxes() end })
    TabCombat:Space()
    sHB:Slider({ Flag="HitboxSize", Title="Tamanho", Step=0.5, Value={Min=1,Max=30,Default=5},
        Callback=function(v) State.HitboxSize=v; if State.HitboxEnabled then refreshHitboxes() end end })
    TabCombat:Space()
    sHB:Slider({ Flag="HitboxAlpha", Title="Transparência", Step=0.05, Value={Min=0,Max=1,Default=0.5},
        Callback=function(v)
            State.HitboxAlpha=v
            for _, p in pairs(hitboxParts) do p.Transparency=v end
        end
    })
end

-- ══════════════════════════════════════════════════════
--  ABA: DESEMPENHO
-- ══════════════════════════════════════════════════════
do
    local sDes = TabPerf:Section({ Title = "⚡ Otimizações de Performance" })

    sDes:Toggle({ Title="Anti-Lag", Desc="Otimiza física e rendering engine", Value=false,
        Callback=function(v) State.AntiLag=v; applyAntiLag(v) end })
    TabPerf:Space()

    sDes:Toggle({ Title="FPS Boost", Desc="Reduz qualidade geral para mais FPS", Value=false,
        Callback=function(v) State.FPSBoost=v; applyFPSBoost(v) end })
    TabPerf:Space()

    sDes:Toggle({ Title="Disable Particles", Desc="Remove fumaça, fogo, faíscas e partículas", Value=false,
        Callback=function(v) State.DisableParticles=v; disableParticles(v) end })
    TabPerf:Space()

    sDes:Toggle({ Title="Texture Low", Desc="Substitui materiais por SmoothPlastic", Value=false,
        Callback=function(v) State.TextureLow=v; setTextureLow(v) end })
    TabPerf:Space()

    sDes:Toggle({ Title="Remove Decals", Desc="Remove decals e texturas do mapa", Value=false,
        Callback=function(v) State.RemoveDecals=v; removeDecals(v) end })
    TabPerf:Space()

    sDes:Toggle({ Title="Dynamic Render Distance", Desc="Ajusta qualidade automaticamente pelo ping", Value=false,
        Callback=function(v) State.DynRender=v; setDynamicRender(v) end })
    TabPerf:Space()

    sDes:Toggle({ Title="Entity Limiter", Desc="Limita modelos no workspace (máx 80)", Value=false,
        Callback=function(v)
            State.EntityLimiter=v
            if not v and entityConn then entityConn:Disconnect(); entityConn=nil end
            setEntityLimiter(v)
        end
    })
    TabPerf:Space()

    sDes:Toggle({ Title="Lighting Cleaner", Desc="Remove fog, bloom, DOF e sombras", Value=false,
        Callback=function(v) State.LightingClean=v; cleanLighting(v) end })
    TabPerf:Space()

    sDes:Toggle({ Title="Low Poly Mode", Desc="Reduz LOD de meshes para ganhar FPS", Value=false,
        Callback=function(v) State.LowPoly=v; setLowPoly(v) end })
end

-- ══════════════════════════════════════════════════════
--  ABA: SETTINGS
-- ══════════════════════════════════════════════════════
do
    -- Anti-AFK
    local sProtect = TabSettings:Section({ Title = "Proteções" })
    sProtect:Toggle({ Flag="AntiAFK", Title="Anti-AFK", Desc="Evita kick por inatividade", Value=false,
        Callback=function(v) State.AntiAFK=v; if v then startAntiAFK() else stopAntiAFK() end end })
    TabSettings:Space()
    sProtect:Toggle({ Flag="AntiKick", Title="Anti-Kick / Anti-Ban", Desc="Bloqueia kick via metamétodo", Value=false,
        Callback=function(v) State.AntiKick=v; if v then hookAntiKick() end end })

    TabSettings:Space()

    -- Cor do Accent
    local sTheme = TabSettings:Section({ Title = "Aparência" })
    sTheme:Colorpicker({
        Flag    = "AccentColor",
        Title   = "Cor do Accent (UI)",
        Desc    = "Muda a cor principal da interface",
        Default = Color3.fromHex("#7B2FFF"),
        Callback = function(c)
            State.AccentColor = c
            -- Atualiza o tema em tempo real
            WindUI:AddTheme({
                Name       = "HubTheme",
                Accent     = c,
                Background = Color3.fromHex("#0d0d0f"),
                Outline    = Color3.fromHex("#2a2a35"),
                Text       = Color3.fromHex("#f0f0ff"),
                Placeholder= Color3.fromHex("#666680"),
                Button     = Color3.fromHex("#1e1e2e"),
                Icon       = c,
            })
            WindUI:SetTheme("HubTheme")
        end
    })

    TabSettings:Space()

    -- Keybind
    local sKeys = TabSettings:Section({ Title = "Atalhos" })
    sKeys:Keybind({
        Flag="ToggleUI", Title="Toggle UI", Desc="Abre/fecha o hub", Value="RightShift",
        Callback=function(v) pcall(function() Window:SetToggleKey(Enum.KeyCode[v]) end) end
    })

    TabSettings:Space()

    -- Salvar
    local sSave = TabSettings:Section({ Title = "Configuração" })
    sSave:Button({
        Title="Salvar Config", Icon="save", Justify="Center",
        Callback=function()
            local ok, err = pcall(function()
                local data = {
                    WalkSpeed=State.WalkSpeed, JumpPower=State.JumpPower,
                    InfiniteJump=State.InfiniteJump, AimbotEnabled=State.AimbotEnabled,
                    TeamCheck=State.TeamCheck, AimbotFOV=State.AimbotFOV,
                    AimbotSmooth=State.AimbotSmooth, ESPEnabled=State.ESPEnabled,
                    ESPFill=State.ESPFill, ESPFillAlpha=State.ESPFillAlpha,
                    ChamEnabled=State.ChamEnabled, TracerEnabled=State.TracerEnabled,
                    DistESP=State.DistESP, HealthESP=State.HealthESP,
                    HitboxEnabled=State.HitboxEnabled, HitboxSize=State.HitboxSize,
                    HitboxAlpha=State.HitboxAlpha, AntiAFK=State.AntiAFK,
                    AntiKick=State.AntiKick,
                    AccentColor = { State.AccentColor.R, State.AccentColor.G, State.AccentColor.B },
                    ESPColor    = { State.ESPColor.R,    State.ESPColor.G,    State.ESPColor.B },
                    ChamColor   = { State.ChamColor.R,   State.ChamColor.G,   State.ChamColor.B },
                    TracerColor = { State.TracerColor.R, State.TracerColor.G, State.TracerColor.B },
                }
                writefile("CoiledTomHub_Config.json", HttpService:JSONEncode(data))
            end)
            if ok then
                WindUI:Notify({ Title="✅ Salvo!", Content="CoiledTomHub_Config.json", Icon="check-circle", Duration=3 })
            else
                WindUI:Notify({ Title="❌ Erro", Content=tostring(err), Icon="alert-triangle", Duration=5 })
            end
        end
    })
end

-- ══════════════════════════════════════════════════════
--  NOTIFICAÇÃO INICIAL
-- ══════════════════════════════════════════════════════
WindUI:Notify({
    Title    = "CoiledTom Hub",
    Content  = "Carregado com sucesso! Confira a aba Logs.",
    Icon     = "solar:planet-bold",
    Duration = 6,
})
