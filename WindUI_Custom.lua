-- WindUI Custom v1.0
-- UI com botões X e - estilo clássico + aba de Changelog

local WindUI = {}
WindUI.__index = WindUI

-- Serviços
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

-- Cores padrão
local Theme = {
    Background     = Color3.fromRGB(18, 18, 24),
    TopBar         = Color3.fromRGB(24, 24, 32),
    Accent         = Color3.fromRGB(80, 120, 255),
    AccentDark     = Color3.fromRGB(55, 90, 200),
    TabActive      = Color3.fromRGB(35, 35, 48),
    TabInactive    = Color3.fromRGB(24, 24, 32),
    Element        = Color3.fromRGB(28, 28, 40),
    ElementHover   = Color3.fromRGB(38, 38, 55),
    Border         = Color3.fromRGB(50, 50, 70),
    TextPrimary    = Color3.fromRGB(240, 240, 255),
    TextSecondary  = Color3.fromRGB(150, 150, 180),
    Toggle_On      = Color3.fromRGB(80, 200, 120),
    Toggle_Off     = Color3.fromRGB(60, 60, 80),
    CloseBtn       = Color3.fromRGB(220, 70, 70),
    MinimizeBtn    = Color3.fromRGB(220, 180, 50),
    Success        = Color3.fromRGB(80, 200, 120),
    Warning        = Color3.fromRGB(220, 180, 50),
    Error          = Color3.fromRGB(220, 70, 70),
    Info           = Color3.fromRGB(80, 160, 255),
}

-- Utilitários
local function Tween(obj, props, duration, style, dir)
    style = style or Enum.EasingStyle.Quad
    dir = dir or Enum.EasingDirection.Out
    local tween = TweenService:Create(obj, TweenInfo.new(duration or 0.2, style, dir), props)
    tween:Play()
    return tween
end

local function MakeDraggable(frame, handle)
    local dragging, dragInput, mousePos, framePos = false, nil, nil, nil
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            mousePos = input.Position
            framePos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            frame.Position = UDim2.new(
                framePos.X.Scale,
                framePos.X.Offset + delta.X,
                framePos.Y.Scale,
                framePos.Y.Offset + delta.Y
            )
        end
    end)
end

local function CreateRipple(parent)
    local ripple = Instance.new("Frame")
    ripple.Size = UDim2.new(0, 0, 0, 0)
    ripple.Position = UDim2.new(0.5, 0, 0.5, 0)
    ripple.AnchorPoint = Vector2.new(0.5, 0.5)
    ripple.BackgroundColor3 = Color3.fromRGB(255,255,255)
    ripple.BackgroundTransparency = 0.85
    ripple.BorderSizePixel = 0
    ripple.ZIndex = parent.ZIndex + 1
    ripple.Parent = parent
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = ripple
    local size = math.max(parent.AbsoluteSize.X, parent.AbsoluteSize.Y) * 2
    Tween(ripple, {Size = UDim2.new(0, size, 0, size), BackgroundTransparency = 1}, 0.5)
    game:GetService("Debris"):AddItem(ripple, 0.6)
end

-- ╔══════════════════════════════╗
-- ║        CRIAR JANELA          ║
-- ╚══════════════════════════════╝
function WindUI:Init(config)
    config = config or {}
    local Title    = config.Title    or "Wind UI"
    local SubTitle = config.SubTitle or "by Custom"
    local Size     = config.Size     or UDim2.fromOffset(560, 440)

    local self = setmetatable({}, WindUI)
    self._tabs = {}
    self._activeTab = nil
    self._minimized = false
    self._originalSize = Size

    -- ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "WindUI_Custom"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.DisplayOrder = 999

    if syn and syn.protect_gui then
        syn.protect_gui(ScreenGui)
        ScreenGui.Parent = game:GetService("CoreGui")
    elseif gethui then
        ScreenGui.Parent = gethui()
    else
        ScreenGui.Parent = Player:WaitForChild("PlayerGui")
    end

    -- Sombra externa
    local Shadow = Instance.new("Frame")
    Shadow.Name = "Shadow"
    Shadow.Size = UDim2.new(0, Size.X.Offset + 20, 0, Size.Y.Offset + 20)
    Shadow.Position = UDim2.new(0.5, -(Size.X.Offset/2 + 10), 0.5, -(Size.Y.Offset/2 + 10))
    Shadow.BackgroundColor3 = Color3.fromRGB(0,0,0)
    Shadow.BackgroundTransparency = 0.5
    Shadow.BorderSizePixel = 0
    Shadow.Parent = ScreenGui
    local ShadowCorner = Instance.new("UICorner")
    ShadowCorner.CornerRadius = UDim.new(0, 14)
    ShadowCorner.Parent = Shadow

    -- Janela principal
    local Window = Instance.new("Frame")
    Window.Name = "Window"
    Window.Size = Size
    Window.Position = UDim2.new(0.5, -Size.X.Offset/2, 0.5, -Size.Y.Offset/2)
    Window.BackgroundColor3 = Theme.Background
    Window.BorderSizePixel = 0
    Window.ClipsDescendants = true
    Window.Parent = ScreenGui
    local WinCorner = Instance.new("UICorner")
    WinCorner.CornerRadius = UDim.new(0, 10)
    WinCorner.Parent = Window

    -- Borda sutil
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Theme.Border
    Stroke.Thickness = 1
    Stroke.Transparency = 0.5
    Stroke.Parent = Window

    self._window = Window
    self._screenGui = ScreenGui
    self._shadow = Shadow

    -- ══ TopBar ══
    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Size = UDim2.new(1, 0, 0, 40)
    TopBar.BackgroundColor3 = Theme.TopBar
    TopBar.BorderSizePixel = 0
    TopBar.Parent = Window
    local TopCorner = Instance.new("UICorner")
    TopCorner.CornerRadius = UDim.new(0, 10)
    TopCorner.Parent = TopBar
    -- Fix nos cantos de baixo da topbar
    local TopFix = Instance.new("Frame")
    TopFix.Size = UDim2.new(1, 0, 0, 10)
    TopFix.Position = UDim2.new(0, 0, 1, -10)
    TopFix.BackgroundColor3 = Theme.TopBar
    TopFix.BorderSizePixel = 0
    TopFix.Parent = TopBar

    -- Ícone colorido
    local Dot = Instance.new("Frame")
    Dot.Size = UDim2.new(0, 8, 0, 8)
    Dot.Position = UDim2.new(0, 14, 0.5, -4)
    Dot.BackgroundColor3 = Theme.Accent
    Dot.BorderSizePixel = 0
    Dot.Parent = TopBar
    local DotCorner = Instance.new("UICorner")
    DotCorner.CornerRadius = UDim.new(1, 0)
    DotCorner.Parent = Dot

    -- Título
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(0, 200, 1, 0)
    TitleLabel.Position = UDim2.new(0, 28, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = Title
    TitleLabel.TextColor3 = Theme.TextPrimary
    TitleLabel.TextSize = 14
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TopBar

    -- SubTítulo
    local SubLabel = Instance.new("TextLabel")
    SubLabel.Size = UDim2.new(0, 200, 1, 0)
    SubLabel.Position = UDim2.new(0, 28 + TitleLabel.TextBounds.X + 8, 0, 0)
    SubLabel.BackgroundTransparency = 1
    SubLabel.Text = SubTitle
    SubLabel.TextColor3 = Theme.TextSecondary
    SubLabel.TextSize = 12
    SubLabel.Font = Enum.Font.Gotham
    SubLabel.TextXAlignment = Enum.TextXAlignment.Left
    SubLabel.Parent = TopBar

    -- ══ Botão MINIMIZAR (—) ══
    local MinBtn = Instance.new("TextButton")
    MinBtn.Size = UDim2.new(0, 28, 0, 20)
    MinBtn.Position = UDim2.new(1, -62, 0.5, -10)
    MinBtn.BackgroundColor3 = Theme.MinimizeBtn
    MinBtn.Text = "—"
    MinBtn.TextColor3 = Color3.fromRGB(30, 30, 30)
    MinBtn.TextSize = 13
    MinBtn.Font = Enum.Font.GothamBold
    MinBtn.BorderSizePixel = 0
    MinBtn.Parent = TopBar
    local MinCorner = Instance.new("UICorner")
    MinCorner.CornerRadius = UDim.new(0, 5)
    MinCorner.Parent = MinBtn

    -- ══ Botão FECHAR (X) ══
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 28, 0, 20)
    CloseBtn.Position = UDim2.new(1, -30, 0.5, -10)
    CloseBtn.BackgroundColor3 = Theme.CloseBtn
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.TextSize = 12
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.BorderSizePixel = 0
    CloseBtn.Parent = TopBar
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 5)
    CloseCorner.Parent = CloseBtn

    -- Hover nos botões
    MinBtn.MouseEnter:Connect(function()
        Tween(MinBtn, {BackgroundColor3 = Color3.fromRGB(255, 210, 60)}, 0.15)
    end)
    MinBtn.MouseLeave:Connect(function()
        Tween(MinBtn, {BackgroundColor3 = Theme.MinimizeBtn}, 0.15)
    end)
    CloseBtn.MouseEnter:Connect(function()
        Tween(CloseBtn, {BackgroundColor3 = Color3.fromRGB(255, 80, 80)}, 0.15)
    end)
    CloseBtn.MouseLeave:Connect(function()
        Tween(CloseBtn, {BackgroundColor3 = Theme.CloseBtn}, 0.15)
    end)

    -- Lógica minimizar
    MinBtn.MouseButton1Click:Connect(function()
        CreateRipple(MinBtn)
        if self._minimized then
            -- Restaurar
            self._minimized = false
            Window.ClipsDescendants = false
            Tween(Window, {Size = self._originalSize}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
            Tween(Shadow, {Size = UDim2.new(0, self._originalSize.X.Offset+20, 0, self._originalSize.Y.Offset+20)}, 0.3)
            task.delay(0.15, function()
                Window.ClipsDescendants = true
            end)
        else
            -- Minimizar
            self._minimized = true
            Tween(Window, {Size = UDim2.new(0, self._originalSize.X.Offset, 0, 40)}, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            Tween(Shadow, {Size = UDim2.new(0, self._originalSize.X.Offset+20, 0, 60)}, 0.3)
        end
    end)

    -- Lógica fechar
    CloseBtn.MouseButton1Click:Connect(function()
        CreateRipple(CloseBtn)
        Tween(Window, {Size = UDim2.new(0, self._originalSize.X.Offset, 0, 0), BackgroundTransparency = 1}, 0.25)
        Tween(Shadow, {BackgroundTransparency = 1}, 0.25)
        task.delay(0.3, function()
            ScreenGui:Destroy()
        end)
    end)

    -- Arrastar
    MakeDraggable(Window, TopBar)
    MakeDraggable(Shadow, TopBar)

    -- ══ TabBar (lateral esquerda) ══
    local TabBar = Instance.new("Frame")
    TabBar.Name = "TabBar"
    TabBar.Size = UDim2.new(0, 130, 1, -40)
    TabBar.Position = UDim2.new(0, 0, 0, 40)
    TabBar.BackgroundColor3 = Theme.TopBar
    TabBar.BorderSizePixel = 0
    TabBar.Parent = Window
    local TabList = Instance.new("UIListLayout")
    TabList.Padding = UDim.new(0, 4)
    TabList.Parent = TabBar
    local TabPad = Instance.new("UIPadding")
    TabPad.PaddingTop = UDim.new(0, 8)
    TabPad.PaddingLeft = UDim.new(0, 8)
    TabPad.PaddingRight = UDim.new(0, 8)
    TabPad.Parent = TabBar

    -- Divisor
    local Divider = Instance.new("Frame")
    Divider.Size = UDim2.new(0, 1, 1, -40)
    Divider.Position = UDim2.new(0, 130, 0, 40)
    Divider.BackgroundColor3 = Theme.Border
    Divider.BackgroundTransparency = 0.5
    Divider.BorderSizePixel = 0
    Divider.Parent = Window

    -- Conteúdo
    local Content = Instance.new("Frame")
    Content.Name = "Content"
    Content.Size = UDim2.new(1, -131, 1, -40)
    Content.Position = UDim2.new(0, 131, 0, 40)
    Content.BackgroundTransparency = 1
    Content.BorderSizePixel = 0
    Content.Parent = Window

    self._tabBar = TabBar
    self._content = Content

    -- Animação de entrada
    Window.Size = UDim2.new(0, 0, 0, 0)
    Window.BackgroundTransparency = 1
    Shadow.BackgroundTransparency = 1
    Tween(Window, {Size = Size, BackgroundTransparency = 0}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    Tween(Shadow, {BackgroundTransparency = 0.5}, 0.4)

    return self
end

-- ╔══════════════════════════════╗
-- ║         CRIAR ABA            ║
-- ╚══════════════════════════════╝
function WindUI:Tab(config)
    config = config or {}
    local Name = config.Name or "Tab"
    local Icon = config.Icon or ""

    local tab = {}
    tab._elements = {}

    -- Botão da aba
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(1, 0, 0, 32)
    TabBtn.BackgroundColor3 = Theme.TabInactive
    TabBtn.Text = (Icon ~= "" and Icon .. "  " or "") .. Name
    TabBtn.TextColor3 = Theme.TextSecondary
    TabBtn.TextSize = 12
    TabBtn.Font = Enum.Font.Gotham
    TabBtn.TextXAlignment = Enum.TextXAlignment.Left
    TabBtn.BorderSizePixel = 0
    TabBtn.Parent = self._tabBar
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 6)
    BtnCorner.Parent = TabBtn
    local BtnPad = Instance.new("UIPadding")
    BtnPad.PaddingLeft = UDim.new(0, 10)
    BtnPad.Parent = TabBtn

    -- Indicador lateral
    local Indicator = Instance.new("Frame")
    Indicator.Size = UDim2.new(0, 3, 0, 16)
    Indicator.Position = UDim2.new(0, 0, 0.5, -8)
    Indicator.BackgroundColor3 = Theme.Accent
    Indicator.BackgroundTransparency = 1
    Indicator.BorderSizePixel = 0
    Indicator.Parent = TabBtn
    local IndCorner = Instance.new("UICorner")
    IndCorner.CornerRadius = UDim.new(0, 3)
    IndCorner.Parent = Indicator

    -- Frame de conteúdo da aba
    local TabFrame = Instance.new("ScrollingFrame")
    TabFrame.Size = UDim2.new(1, 0, 1, 0)
    TabFrame.BackgroundTransparency = 1
    TabFrame.BorderSizePixel = 0
    TabFrame.ScrollBarThickness = 3
    TabFrame.ScrollBarImageColor3 = Theme.Accent
    TabFrame.Visible = false
    TabFrame.Parent = self._content
    local FrameList = Instance.new("UIListLayout")
    FrameList.Padding = UDim.new(0, 6)
    FrameList.Parent = TabFrame
    local FramePad = Instance.new("UIPadding")
    FramePad.PaddingTop = UDim.new(0, 10)
    FramePad.PaddingLeft = UDim.new(0, 12)
    FramePad.PaddingRight = UDim.new(0, 12)
    FramePad.Parent = TabFrame

    -- Auto-resize
    FrameList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabFrame.CanvasSize = UDim2.new(0, 0, 0, FrameList.AbsoluteContentSize.Y + 20)
    end)

    tab._btn = TabBtn
    tab._frame = TabFrame
    tab._indicator = Indicator
    tab._ui = self

    -- Selecionar aba
    local function Select()
        -- Desativar aba atual
        if self._activeTab then
            local prev = self._activeTab
            prev._frame.Visible = false
            Tween(prev._btn, {BackgroundColor3 = Theme.TabInactive, TextColor3 = Theme.TextSecondary}, 0.15)
            Tween(prev._indicator, {BackgroundTransparency = 1}, 0.15)
        end
        -- Ativar nova aba
        self._activeTab = tab
        TabFrame.Visible = true
        Tween(TabBtn, {BackgroundColor3 = Theme.TabActive, TextColor3 = Theme.TextPrimary}, 0.15)
        Tween(Indicator, {BackgroundTransparency = 0}, 0.15)
    end

    TabBtn.MouseButton1Click:Connect(function()
        CreateRipple(TabBtn)
        Select()
    end)

    TabBtn.MouseEnter:Connect(function()
        if self._activeTab ~= tab then
            Tween(TabBtn, {BackgroundColor3 = Theme.ElementHover}, 0.15)
        end
    end)
    TabBtn.MouseLeave:Connect(function()
        if self._activeTab ~= tab then
            Tween(TabBtn, {BackgroundColor3 = Theme.TabInactive}, 0.15)
        end
    end)

    -- Primeira aba é selecionada automaticamente
    if #self._tabs == 0 then
        Select()
    end

    table.insert(self._tabs, tab)

    -- ══════════════════════════════
    -- Elementos da aba
    -- ══════════════════════════════

    -- Seção
    function tab:Section(name)
        local Sect = Instance.new("TextLabel")
        Sect.Size = UDim2.new(1, 0, 0, 20)
        Sect.BackgroundTransparency = 1
        Sect.Text = name:upper()
        Sect.TextColor3 = Theme.Accent
        Sect.TextSize = 10
        Sect.Font = Enum.Font.GothamBold
        Sect.TextXAlignment = Enum.TextXAlignment.Left
        Sect.Parent = TabFrame
        return Sect
    end

    -- Botão
    function tab:Button(config)
        config = config or {}
        local Name = config.Name or "Button"
        local Desc = config.Desc or ""
        local Callback = config.Callback or function() end

        local Elem = Instance.new("TextButton")
        Elem.Size = UDim2.new(1, 0, 0, Desc ~= "" and 48 or 36)
        Elem.BackgroundColor3 = Theme.Element
        Elem.Text = ""
        Elem.BorderSizePixel = 0
        Elem.Parent = TabFrame
        local ElemCorner = Instance.new("UICorner")
        ElemCorner.CornerRadius = UDim.new(0, 7)
        ElemCorner.Parent = Elem
        local ElemStroke = Instance.new("UIStroke")
        ElemStroke.Color = Theme.Border
        ElemStroke.Thickness = 1
        ElemStroke.Transparency = 0.7
        ElemStroke.Parent = Elem

        local NameLbl = Instance.new("TextLabel")
        NameLbl.Size = UDim2.new(1, -16, 0, 20)
        NameLbl.Position = UDim2.new(0, 12, 0, Desc ~= "" and 6 or 8)
        NameLbl.BackgroundTransparency = 1
        NameLbl.Text = Name
        NameLbl.TextColor3 = Theme.TextPrimary
        NameLbl.TextSize = 13
        NameLbl.Font = Enum.Font.Gotham
        NameLbl.TextXAlignment = Enum.TextXAlignment.Left
        NameLbl.Parent = Elem

        if Desc ~= "" then
            local DescLbl = Instance.new("TextLabel")
            DescLbl.Size = UDim2.new(1, -16, 0, 16)
            DescLbl.Position = UDim2.new(0, 12, 0, 26)
            DescLbl.BackgroundTransparency = 1
            DescLbl.Text = Desc
            DescLbl.TextColor3 = Theme.TextSecondary
            DescLbl.TextSize = 11
            DescLbl.Font = Enum.Font.Gotham
            DescLbl.TextXAlignment = Enum.TextXAlignment.Left
            DescLbl.Parent = Elem
        end

        Elem.MouseEnter:Connect(function()
            Tween(Elem, {BackgroundColor3 = Theme.ElementHover}, 0.15)
        end)
        Elem.MouseLeave:Connect(function()
            Tween(Elem, {BackgroundColor3 = Theme.Element}, 0.15)
        end)
        Elem.MouseButton1Click:Connect(function()
            CreateRipple(Elem)
            Callback()
        end)
    end

    -- Toggle
    function tab:Toggle(config)
        config = config or {}
        local Name = config.Name or "Toggle"
        local Desc = config.Desc or ""
        local Default = config.Default or false
        local Callback = config.Callback or function() end
        local state = Default

        local Elem = Instance.new("Frame")
        Elem.Size = UDim2.new(1, 0, 0, Desc ~= "" and 48 or 36)
        Elem.BackgroundColor3 = Theme.Element
        Elem.BorderSizePixel = 0
        Elem.Parent = TabFrame
        local ElemCorner = Instance.new("UICorner")
        ElemCorner.CornerRadius = UDim.new(0, 7)
        ElemCorner.Parent = Elem
        local ElemStroke = Instance.new("UIStroke")
        ElemStroke.Color = Theme.Border
        ElemStroke.Thickness = 1
        ElemStroke.Transparency = 0.7
        ElemStroke.Parent = Elem

        local NameLbl = Instance.new("TextLabel")
        NameLbl.Size = UDim2.new(1, -60, 0, 20)
        NameLbl.Position = UDim2.new(0, 12, 0, Desc ~= "" and 6 or 8)
        NameLbl.BackgroundTransparency = 1
        NameLbl.Text = Name
        NameLbl.TextColor3 = Theme.TextPrimary
        NameLbl.TextSize = 13
        NameLbl.Font = Enum.Font.Gotham
        NameLbl.TextXAlignment = Enum.TextXAlignment.Left
        NameLbl.Parent = Elem

        if Desc ~= "" then
            local DescLbl = Instance.new("TextLabel")
            DescLbl.Size = UDim2.new(1, -60, 0, 16)
            DescLbl.Position = UDim2.new(0, 12, 0, 26)
            DescLbl.BackgroundTransparency = 1
            DescLbl.Text = Desc
            DescLbl.TextColor3 = Theme.TextSecondary
            DescLbl.TextSize = 11
            DescLbl.Font = Enum.Font.Gotham
            DescLbl.TextXAlignment = Enum.TextXAlignment.Left
            DescLbl.Parent = Elem
        end

        -- Track do toggle
        local Track = Instance.new("Frame")
        Track.Size = UDim2.new(0, 38, 0, 20)
        Track.Position = UDim2.new(1, -50, 0.5, -10)
        Track.BackgroundColor3 = state and Theme.Toggle_On or Theme.Toggle_Off
        Track.BorderSizePixel = 0
        Track.Parent = Elem
        local TrackCorner = Instance.new("UICorner")
        TrackCorner.CornerRadius = UDim.new(1, 0)
        TrackCorner.Parent = Track

        local Knob = Instance.new("Frame")
        Knob.Size = UDim2.new(0, 14, 0, 14)
        Knob.Position = UDim2.new(0, state and 21 or 3, 0.5, -7)
        Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Knob.BorderSizePixel = 0
        Knob.Parent = Track
        local KnobCorner = Instance.new("UICorner")
        KnobCorner.CornerRadius = UDim.new(1, 0)
        KnobCorner.Parent = Knob

        local Btn = Instance.new("TextButton")
        Btn.Size = UDim2.new(1, 0, 1, 0)
        Btn.BackgroundTransparency = 1
        Btn.Text = ""
        Btn.Parent = Elem

        local function UpdateToggle()
            Tween(Track, {BackgroundColor3 = state and Theme.Toggle_On or Theme.Toggle_Off}, 0.2)
            Tween(Knob, {Position = UDim2.new(0, state and 21 or 3, 0.5, -7)}, 0.2, Enum.EasingStyle.Back)
        end

        Btn.MouseButton1Click:Connect(function()
            state = not state
            UpdateToggle()
            Callback(state)
        end)
        Btn.MouseEnter:Connect(function()
            Tween(Elem, {BackgroundColor3 = Theme.ElementHover}, 0.15)
        end)
        Btn.MouseLeave:Connect(function()
            Tween(Elem, {BackgroundColor3 = Theme.Element}, 0.15)
        end)

        UpdateToggle()

        local obj = {}
        function obj:Set(val)
            state = val
            UpdateToggle()
            Callback(state)
        end
        function obj:Get() return state end
        return obj
    end

    -- Slider
    function tab:Slider(config)
        config = config or {}
        local Name = config.Name or "Slider"
        local Min = config.Min or 0
        local Max = config.Max or 100
        local Default = config.Default or Min
        local Suffix = config.Suffix or ""
        local Callback = config.Callback or function() end
        local value = Default

        local Elem = Instance.new("Frame")
        Elem.Size = UDim2.new(1, 0, 0, 54)
        Elem.BackgroundColor3 = Theme.Element
        Elem.BorderSizePixel = 0
        Elem.Parent = TabFrame
        local ElemCorner = Instance.new("UICorner")
        ElemCorner.CornerRadius = UDim.new(0, 7)
        ElemCorner.Parent = Elem
        local ElemStroke = Instance.new("UIStroke")
        ElemStroke.Color = Theme.Border
        ElemStroke.Thickness = 1
        ElemStroke.Transparency = 0.7
        ElemStroke.Parent = Elem

        local NameLbl = Instance.new("TextLabel")
        NameLbl.Size = UDim2.new(0.7, 0, 0, 20)
        NameLbl.Position = UDim2.new(0, 12, 0, 8)
        NameLbl.BackgroundTransparency = 1
        NameLbl.Text = Name
        NameLbl.TextColor3 = Theme.TextPrimary
        NameLbl.TextSize = 13
        NameLbl.Font = Enum.Font.Gotham
        NameLbl.TextXAlignment = Enum.TextXAlignment.Left
        NameLbl.Parent = Elem

        local ValLbl = Instance.new("TextLabel")
        ValLbl.Size = UDim2.new(0.3, -12, 0, 20)
        ValLbl.Position = UDim2.new(0.7, 0, 0, 8)
        ValLbl.BackgroundTransparency = 1
        ValLbl.Text = tostring(value) .. Suffix
        ValLbl.TextColor3 = Theme.Accent
        ValLbl.TextSize = 12
        ValLbl.Font = Enum.Font.GothamBold
        ValLbl.TextXAlignment = Enum.TextXAlignment.Right
        ValLbl.Parent = Elem

        local TrackBg = Instance.new("Frame")
        TrackBg.Size = UDim2.new(1, -24, 0, 6)
        TrackBg.Position = UDim2.new(0, 12, 0, 36)
        TrackBg.BackgroundColor3 = Theme.Toggle_Off
        TrackBg.BorderSizePixel = 0
        TrackBg.Parent = Elem
        local TBCorner = Instance.new("UICorner")
        TBCorner.CornerRadius = UDim.new(1, 0)
        TBCorner.Parent = TrackBg

        local Fill = Instance.new("Frame")
        Fill.Size = UDim2.new((value - Min)/(Max - Min), 0, 1, 0)
        Fill.BackgroundColor3 = Theme.Accent
        Fill.BorderSizePixel = 0
        Fill.Parent = TrackBg
        local FillCorner = Instance.new("UICorner")
        FillCorner.CornerRadius = UDim.new(1, 0)
        FillCorner.Parent = Fill

        local Thumb = Instance.new("Frame")
        Thumb.Size = UDim2.new(0, 14, 0, 14)
        Thumb.Position = UDim2.new((value - Min)/(Max - Min), -7, 0.5, -7)
        Thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Thumb.BorderSizePixel = 0
        Thumb.ZIndex = 3
        Thumb.Parent = TrackBg
        local ThumbCorner = Instance.new("UICorner")
        ThumbCorner.CornerRadius = UDim.new(1, 0)
        ThumbCorner.Parent = Thumb

        local Drag = Instance.new("TextButton")
        Drag.Size = UDim2.new(1, 0, 0, 20)
        Drag.Position = UDim2.new(0, 0, 0, -7)
        Drag.BackgroundTransparency = 1
        Drag.Text = ""
        Drag.ZIndex = 4
        Drag.Parent = TrackBg

        local sliding = false
        Drag.MouseButton1Down:Connect(function() sliding = true end)
        UserInputService.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end
        end)
        UserInputService.InputChanged:Connect(function(i)
            if sliding and i.UserInputType == Enum.UserInputType.MouseMovement then
                local rel = (i.Position.X - TrackBg.AbsolutePosition.X) / TrackBg.AbsoluteSize.X
                rel = math.clamp(rel, 0, 1)
                value = math.floor(Min + (Max - Min) * rel)
                Fill.Size = UDim2.new(rel, 0, 1, 0)
                Thumb.Position = UDim2.new(rel, -7, 0.5, -7)
                ValLbl.Text = tostring(value) .. Suffix
                Callback(value)
            end
        end)

        local obj = {}
        function obj:Set(val)
            val = math.clamp(val, Min, Max)
            value = val
            local rel = (val - Min)/(Max - Min)
            Fill.Size = UDim2.new(rel, 0, 1, 0)
            Thumb.Position = UDim2.new(rel, -7, 0.5, -7)
            ValLbl.Text = tostring(val) .. Suffix
            Callback(val)
        end
        function obj:Get() return value end
        return obj
    end

    -- Dropdown
    function tab:Dropdown(config)
        config = config or {}
        local Name = config.Name or "Dropdown"
        local Options = config.Options or {}
        local Default = config.Default or Options[1] or "Selecione"
        local Callback = config.Callback or function() end
        local selected = Default
        local open = false

        local Wrap = Instance.new("Frame")
        Wrap.Size = UDim2.new(1, 0, 0, 36)
        Wrap.BackgroundTransparency = 1
        Wrap.BorderSizePixel = 0
        Wrap.ClipsDescendants = false
        Wrap.Parent = TabFrame

        local Elem = Instance.new("Frame")
        Elem.Size = UDim2.new(1, 0, 0, 36)
        Elem.BackgroundColor3 = Theme.Element
        Elem.BorderSizePixel = 0
        Elem.ZIndex = 2
        Elem.Parent = Wrap
        local ElemCorner = Instance.new("UICorner")
        ElemCorner.CornerRadius = UDim.new(0, 7)
        ElemCorner.Parent = Elem
        local ElemStroke = Instance.new("UIStroke")
        ElemStroke.Color = Theme.Border
        ElemStroke.Thickness = 1
        ElemStroke.Transparency = 0.7
        ElemStroke.Parent = Elem

        local NameLbl = Instance.new("TextLabel")
        NameLbl.Size = UDim2.new(0.5, 0, 1, 0)
        NameLbl.Position = UDim2.new(0, 12, 0, 0)
        NameLbl.BackgroundTransparency = 1
        NameLbl.Text = Name
        NameLbl.TextColor3 = Theme.TextPrimary
        NameLbl.TextSize = 13
        NameLbl.Font = Enum.Font.Gotham
        NameLbl.TextXAlignment = Enum.TextXAlignment.Left
        NameLbl.ZIndex = 2
        NameLbl.Parent = Elem

        local SelLbl = Instance.new("TextLabel")
        SelLbl.Size = UDim2.new(0.5, -40, 1, 0)
        SelLbl.Position = UDim2.new(0.5, 0, 0, 0)
        SelLbl.BackgroundTransparency = 1
        SelLbl.Text = selected
        SelLbl.TextColor3 = Theme.Accent
        SelLbl.TextSize = 12
        SelLbl.Font = Enum.Font.Gotham
        SelLbl.TextXAlignment = Enum.TextXAlignment.Right
        SelLbl.ZIndex = 2
        SelLbl.Parent = Elem

        local Arrow = Instance.new("TextLabel")
        Arrow.Size = UDim2.new(0, 24, 1, 0)
        Arrow.Position = UDim2.new(1, -28, 0, 0)
        Arrow.BackgroundTransparency = 1
        Arrow.Text = "▼"
        Arrow.TextColor3 = Theme.TextSecondary
        Arrow.TextSize = 10
        Arrow.Font = Enum.Font.Gotham
        Arrow.ZIndex = 2
        Arrow.Parent = Elem

        local DropFrame = Instance.new("Frame")
        DropFrame.Size = UDim2.new(1, 0, 0, 0)
        DropFrame.Position = UDim2.new(0, 0, 1, 4)
        DropFrame.BackgroundColor3 = Theme.Element
        DropFrame.BorderSizePixel = 0
        DropFrame.ClipsDescendants = true
        DropFrame.ZIndex = 10
        DropFrame.Parent = Elem
        local DFCorner = Instance.new("UICorner")
        DFCorner.CornerRadius = UDim.new(0, 7)
        DFCorner.Parent = DropFrame
        local DFStroke = Instance.new("UIStroke")
        DFStroke.Color = Theme.Border
        DFStroke.Thickness = 1
        DFStroke.Transparency = 0.5
        DFStroke.Parent = DropFrame
        local DFList = Instance.new("UIListLayout")
        DFList.Padding = UDim.new(0, 2)
        DFList.Parent = DropFrame
        local DFPad = Instance.new("UIPadding")
        DFPad.PaddingTop = UDim.new(0, 4)
        DFPad.PaddingBottom = UDim.new(0, 4)
        DFPad.PaddingLeft = UDim.new(0, 4)
        DFPad.PaddingRight = UDim.new(0, 4)
        DFPad.Parent = DropFrame

        for _, opt in ipairs(Options) do
            local OptBtn = Instance.new("TextButton")
            OptBtn.Size = UDim2.new(1, 0, 0, 28)
            OptBtn.BackgroundColor3 = Theme.Element
            OptBtn.Text = opt
            OptBtn.TextColor3 = Theme.TextPrimary
            OptBtn.TextSize = 12
            OptBtn.Font = Enum.Font.Gotham
            OptBtn.BorderSizePixel = 0
            OptBtn.ZIndex = 11
            OptBtn.Parent = DropFrame
            local OptCorner = Instance.new("UICorner")
            OptCorner.CornerRadius = UDim.new(0, 5)
            OptCorner.Parent = OptBtn
            OptBtn.MouseEnter:Connect(function()
                Tween(OptBtn, {BackgroundColor3 = Theme.ElementHover}, 0.1)
            end)
            OptBtn.MouseLeave:Connect(function()
                Tween(OptBtn, {BackgroundColor3 = Theme.Element}, 0.1)
            end)
            OptBtn.MouseButton1Click:Connect(function()
                selected = opt
                SelLbl.Text = opt
                open = false
                Tween(DropFrame, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
                Tween(Arrow, {Rotation = 0}, 0.2)
                Wrap.Size = UDim2.new(1, 0, 0, 36)
                Callback(opt)
            end)
        end

        local totalH = #Options * 30 + 8

        local Btn = Instance.new("TextButton")
        Btn.Size = UDim2.new(1, 0, 1, 0)
        Btn.BackgroundTransparency = 1
        Btn.Text = ""
        Btn.ZIndex = 3
        Btn.Parent = Elem
        Btn.MouseButton1Click:Connect(function()
            open = not open
            if open then
                Tween(DropFrame, {Size = UDim2.new(1, 0, 0, totalH)}, 0.25, Enum.EasingStyle.Back)
                Tween(Arrow, {Rotation = 180}, 0.2)
                Wrap.Size = UDim2.new(1, 0, 0, 36 + totalH + 4)
            else
                Tween(DropFrame, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
                Tween(Arrow, {Rotation = 0}, 0.2)
                Wrap.Size = UDim2.new(1, 0, 0, 36)
            end
        end)
    end

    -- Input
    function tab:Input(config)
        config = config or {}
        local Name = config.Name or "Input"
        local Placeholder = config.Placeholder or "Digite aqui..."
        local Callback = config.Callback or function() end

        local Elem = Instance.new("Frame")
        Elem.Size = UDim2.new(1, 0, 0, 54)
        Elem.BackgroundColor3 = Theme.Element
        Elem.BorderSizePixel = 0
        Elem.Parent = TabFrame
        local ElemCorner = Instance.new("UICorner")
        ElemCorner.CornerRadius = UDim.new(0, 7)
        ElemCorner.Parent = Elem
        local ElemStroke = Instance.new("UIStroke")
        ElemStroke.Color = Theme.Border
        ElemStroke.Thickness = 1
        ElemStroke.Transparency = 0.7
        ElemStroke.Parent = Elem

        local NameLbl = Instance.new("TextLabel")
        NameLbl.Size = UDim2.new(1, -16, 0, 18)
        NameLbl.Position = UDim2.new(0, 12, 0, 6)
        NameLbl.BackgroundTransparency = 1
        NameLbl.Text = Name
        NameLbl.TextColor3 = Theme.TextPrimary
        NameLbl.TextSize = 12
        NameLbl.Font = Enum.Font.Gotham
        NameLbl.TextXAlignment = Enum.TextXAlignment.Left
        NameLbl.Parent = Elem

        local Box = Instance.new("TextBox")
        Box.Size = UDim2.new(1, -24, 0, 22)
        Box.Position = UDim2.new(0, 12, 0, 26)
        Box.BackgroundColor3 = Theme.TopBar
        Box.Text = ""
        Box.PlaceholderText = Placeholder
        Box.PlaceholderColor3 = Theme.TextSecondary
        Box.TextColor3 = Theme.TextPrimary
        Box.TextSize = 12
        Box.Font = Enum.Font.Gotham
        Box.TextXAlignment = Enum.TextXAlignment.Left
        Box.ClearTextOnFocus = false
        Box.BorderSizePixel = 0
        Box.Parent = Elem
        local BoxCorner = Instance.new("UICorner")
        BoxCorner.CornerRadius = UDim.new(0, 5)
        BoxCorner.Parent = Box
        local BoxPad = Instance.new("UIPadding")
        BoxPad.PaddingLeft = UDim.new(0, 8)
        BoxPad.Parent = Box

        Box.FocusLost:Connect(function(enter)
            if enter then Callback(Box.Text) end
        end)
        Box.Focused:Connect(function()
            Tween(ElemStroke, {Color = Theme.Accent, Transparency = 0}, 0.2)
        end)
        Box.FocusLost:Connect(function()
            Tween(ElemStroke, {Color = Theme.Border, Transparency = 0.7}, 0.2)
        end)
    end

    -- Label
    function tab:Label(text, color)
        local Lbl = Instance.new("TextLabel")
        Lbl.Size = UDim2.new(1, 0, 0, 24)
        Lbl.BackgroundTransparency = 1
        Lbl.Text = text
        Lbl.TextColor3 = color or Theme.TextSecondary
        Lbl.TextSize = 12
        Lbl.Font = Enum.Font.Gotham
        Lbl.TextXAlignment = Enum.TextXAlignment.Left
        Lbl.Parent = TabFrame
        return Lbl
    end

    return tab
end

-- ╔══════════════════════════════╗
-- ║      ABA DE CHANGELOG        ║
-- ╚══════════════════════════════╝
function WindUI:Changelog(config)
    config = config or {}
    local Updates = config.Updates or {}
    -- Updates = { {Version="v1.0", Date="19/03/2026", Changes={"Adicionado X","Corrigido Y"}} }

    local tab = self:Tab({Name = "Changelog", Icon = "📋"})

    for _, update in ipairs(Updates) do
        -- Header da versão
        local Header = Instance.new("Frame")
        Header.Size = UDim2.new(1, 0, 0, 42)
        Header.BackgroundColor3 = Theme.TabActive
        Header.BorderSizePixel = 0
        Header.Parent = tab._frame
        local HCorner = Instance.new("UICorner")
        HCorner.CornerRadius = UDim.new(0, 7)
        HCorner.Parent = Header
        local HStroke = Instance.new("UIStroke")
        HStroke.Color = Theme.Accent
        HStroke.Thickness = 1
        HStroke.Transparency = 0.5
        HStroke.Parent = Header

        local VerBadge = Instance.new("Frame")
        VerBadge.Size = UDim2.new(0, 50, 0, 22)
        VerBadge.Position = UDim2.new(0, 10, 0.5, -11)
        VerBadge.BackgroundColor3 = Theme.Accent
        VerBadge.BorderSizePixel = 0
        VerBadge.Parent = Header
        local VBCorner = Instance.new("UICorner")
        VBCorner.CornerRadius = UDim.new(0, 5)
        VBCorner.Parent = VerBadge

        local VerLbl = Instance.new("TextLabel")
        VerLbl.Size = UDim2.new(1, 0, 1, 0)
        VerLbl.BackgroundTransparency = 1
        VerLbl.Text = update.Version or "v?"
        VerLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
        VerLbl.TextSize = 11
        VerLbl.Font = Enum.Font.GothamBold
        VerLbl.Parent = VerBadge

        local DateLbl = Instance.new("TextLabel")
        DateLbl.Size = UDim2.new(0, 150, 1, 0)
        DateLbl.Position = UDim2.new(0, 68, 0, 0)
        DateLbl.BackgroundTransparency = 1
        DateLbl.Text = update.Date or ""
        DateLbl.TextColor3 = Theme.TextSecondary
        DateLbl.TextSize = 11
        DateLbl.Font = Enum.Font.Gotham
        DateLbl.TextXAlignment = Enum.TextXAlignment.Left
        DateLbl.Parent = Header

        -- Mudanças
        for _, change in ipairs(update.Changes or {}) do
            local Row = Instance.new("Frame")
            Row.Size = UDim2.new(1, 0, 0, 26)
            Row.BackgroundColor3 = Theme.Element
            Row.BorderSizePixel = 0
            Row.Parent = tab._frame
            local RCorner = Instance.new("UICorner")
            RCorner.CornerRadius = UDim.new(0, 5)
            RCorner.Parent = Row

            local Bullet = Instance.new("Frame")
            Bullet.Size = UDim2.new(0, 5, 0, 5)
            Bullet.Position = UDim2.new(0, 14, 0.5, -2.5)
            Bullet.BackgroundColor3 = Theme.Accent
            Bullet.BorderSizePixel = 0
            Bullet.Parent = Row
            local BCorner = Instance.new("UICorner")
            BCorner.CornerRadius = UDim.new(1, 0)
            BCorner.Parent = Bullet

            local ChangeLbl = Instance.new("TextLabel")
            ChangeLbl.Size = UDim2.new(1, -30, 1, 0)
            ChangeLbl.Position = UDim2.new(0, 26, 0, 0)
            ChangeLbl.BackgroundTransparency = 1
            ChangeLbl.Text = change
            ChangeLbl.TextColor3 = Theme.TextPrimary
            ChangeLbl.TextSize = 12
            ChangeLbl.Font = Enum.Font.Gotham
            ChangeLbl.TextXAlignment = Enum.TextXAlignment.Left
            ChangeLbl.Parent = Row
        end

        -- Espaço entre versões
        local Spacer = Instance.new("Frame")
        Spacer.Size = UDim2.new(1, 0, 0, 6)
        Spacer.BackgroundTransparency = 1
        Spacer.Parent = tab._frame
    end

    return tab
end

-- ╔══════════════════════════════╗
-- ║         NOTIFICAÇÃO          ║
-- ╚══════════════════════════════╝
function WindUI:Notify(config)
    config = config or {}
    local Title = config.Title or "Notificação"
    local Desc = config.Desc or ""
    local Type = config.Type or "Info" -- Info, Success, Warning, Error
    local Duration = config.Duration or 4

    local colorMap = {
        Info = Theme.Info,
        Success = Theme.Success,
        Warning = Theme.Warning,
        Error = Theme.Error,
    }
    local color = colorMap[Type] or Theme.Info

    local gui = self._screenGui

    -- Container de notificações
    if not gui:FindFirstChild("NotifContainer") then
        local c = Instance.new("Frame")
        c.Name = "NotifContainer"
        c.Size = UDim2.new(0, 280, 1, 0)
        c.Position = UDim2.new(1, -290, 0, 0)
        c.BackgroundTransparency = 1
        c.BorderSizePixel = 0
        c.Parent = gui
        local l = Instance.new("UIListLayout")
        l.VerticalAlignment = Enum.VerticalAlignment.Bottom
        l.Padding = UDim.new(0, 8)
        l.Parent = c
        local p = Instance.new("UIPadding")
        p.PaddingBottom = UDim.new(0, 10)
        p.Parent = c
    end

    local container = gui.NotifContainer

    local Notif = Instance.new("Frame")
    Notif.Size = UDim2.new(1, 0, 0, 0)
    Notif.BackgroundColor3 = Theme.Element
    Notif.BorderSizePixel = 0
    Notif.ClipsDescendants = true
    Notif.Parent = container
    local NCorner = Instance.new("UICorner")
    NCorner.CornerRadius = UDim.new(0, 8)
    NCorner.Parent = Notif
    local NStroke = Instance.new("UIStroke")
    NStroke.Color = color
    NStroke.Thickness = 1
    NStroke.Transparency = 0.3
    NStroke.Parent = Notif

    local Bar = Instance.new("Frame")
    Bar.Size = UDim2.new(0, 3, 1, 0)
    Bar.BackgroundColor3 = color
    Bar.BorderSizePixel = 0
    Bar.Parent = Notif
    local BCorner = Instance.new("UICorner")
    BCorner.CornerRadius = UDim.new(0, 3)
    BCorner.Parent = Bar

    local TitleLbl = Instance.new("TextLabel")
    TitleLbl.Size = UDim2.new(1, -16, 0, 22)
    TitleLbl.Position = UDim2.new(0, 14, 0, 8)
    TitleLbl.BackgroundTransparency = 1
    TitleLbl.Text = Title
    TitleLbl.TextColor3 = Theme.TextPrimary
    TitleLbl.TextSize = 13
    TitleLbl.Font = Enum.Font.GothamBold
    TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
    TitleLbl.Parent = Notif

    local DescLbl = Instance.new("TextLabel")
    DescLbl.Size = UDim2.new(1, -16, 0, Desc ~= "" and 30 or 0)
    DescLbl.Position = UDim2.new(0, 14, 0, 30)
    DescLbl.BackgroundTransparency = 1
    DescLbl.Text = Desc
    DescLbl.TextColor3 = Theme.TextSecondary
    DescLbl.TextSize = 11
    DescLbl.Font = Enum.Font.Gotham
    DescLbl.TextXAlignment = Enum.TextXAlignment.Left
    DescLbl.TextWrapped = true
    DescLbl.Parent = Notif

    local totalH = Desc ~= "" and 70 or 42
    Tween(Notif, {Size = UDim2.new(1, 0, 0, totalH)}, 0.3, Enum.EasingStyle.Back)

    task.delay(Duration, function()
        Tween(Notif, {Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1}, 0.3)
        task.delay(0.35, function()
            Notif:Destroy()
        end)
    end)
end

return WindUI
