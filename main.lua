local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local UNIQUE_ID = getgenv().VoidUniqueID or "----.----"

local CONFIG = {
    TOGGLE_KEY = Enum.KeyCode.RightShift,
    TOGGLE_KEY_ALT = Enum.KeyCode.Tab,
    STOP_KEY = Enum.KeyCode.End,
    GUI_PREFIX = "VoidYbaGui_",
    KILL_HEIGHT = -35,
    WARN_TIME = 10,
    ITEM_FARM_TIMEOUT = 8,
}

local ADMIN_NICKS = {
    ["GERPr1de"] = true,
    ["WizixxThugHunter"] = true,
    ["WizixxProject94"] = true,
}

local THEME = {
    bg = Color3.fromRGB(12, 12, 16),
    bgGrad = Color3.fromRGB(20, 20, 28),
    panel = Color3.fromRGB(20, 20, 26),
    panel2 = Color3.fromRGB(26, 26, 34),
    panel3 = Color3.fromRGB(34, 34, 44),
    accent = Color3.fromRGB(150, 90, 255),
    accent2 = Color3.fromRGB(80, 140, 255),
    text = Color3.fromRGB(240, 240, 250),
    subtext = Color3.fromRGB(140, 140, 165),
    dimtext = Color3.fromRGB(90, 90, 110),
    stroke = Color3.fromRGB(55, 55, 75),
    strokeSoft = Color3.fromRGB(40, 40, 55),
    ok = Color3.fromRGB(90, 255, 150),
    warn = Color3.fromRGB(255, 190, 90),
    err = Color3.fromRGB(255, 90, 110),
    blue = Color3.fromRGB(80, 140, 255),
    red = Color3.fromRGB(220, 60, 80),
}

local ITEM_MAX = {
    ["Mysterious Arrow"] = 25, ["Rokakaka"] = 25,
    ["Rib Cage of The Saint's Corpse"] = 10, ["Lucky Arrow"] = 10,
    ["Christmas Present"] = 45, ["Dio's Diary"] = 10,
    ["Steel Ball"] = 10, ["Ancient Scroll"] = 10,
    ["Caesar's Headband"] = 10, ["Quinton's Glove"] = 10,
    ["Stone Mask"] = 10, ["Gold Coin"] = 45,
    ["Diamond"] = 30, ["Pure Rokakaka"] = 10,
}

local ALL_FARM_ITEMS = {
    "Mysterious Arrow", "Rokakaka", "Rib Cage of The Saint's Corpse",
    "Lucky Arrow", "Christmas Present", "Dio's Diary", "Steel Ball",
    "Ancient Scroll", "Caesar's Headband", "Quinton's Glove",
    "Stone Mask", "Gold Coin", "Diamond", "Pure Rokakaka",
}

local ALL_TELEPORTS = {
    ["Newbie Giorno"] = CFrame.new(1, 0, -697),
    ["Train Station 1"] = CFrame.new(-214, 0, 18),
    ["Train Station 2"] = CFrame.new(-265, -30, -447),
    ["Pizza Place"] = CFrame.new(113, 6, 71),
    ["The Arcade"] = CFrame.new(255, 5, -239),
    ["The Cafe"] = CFrame.new(-544, -25, -174),
    ["Diavolo"] = CFrame.new(1126, 116, -129),
    ["Dio P3"] = CFrame.new(-44, 0, -973),
    ["Jotaro P3"] = CFrame.new(182, -25, 578),
    ["Jotaro P6"] = CFrame.new(784, -42, 144),
    ["Tallest Peak"] = CFrame.new(-237, 284, 305),
    ["Hamon Merchant"] = CFrame.new(421, 8, -287),
    ["Boxing Merchant"] = CFrame.new(281, 0, 101),
    ["Pluck Merchant"] = CFrame.new(125, -27, 438),
    ["Heaven Dimension"] = CFrame.new(8553, -479, 8154),
    ["Arrowsmith"] = CFrame.new(-667, 16, -299),
    ["Cosmetics"] = CFrame.new(512, 2, 22),
    ["Leaky Eye Luca"] = CFrame.new(-382, 0, -711),
    ["Chad"] = CFrame.new(-121, -24, 524),
    ["Brad"] = CFrame.new(-14, 0, -286),
    ["Dracula"] = CFrame.new(-420, -34, -75),
    ["Kars"] = CFrame.new(264, -33, 112),
    ["Homeless Man Jill"] = CFrame.new(-142, -31, -577),
    ["Vampire Room"] = CFrame.new(391, -31, -166),
    ["Enrico Pucci"] = CFrame.new(917, 34, -17),
    ["Safe Spot"] = CFrame.new(-324, -32, 47),
}

local State = {
    isActive = false,
    mainThread = nil,
    charConn = nil,
    step = 0,
    warnOverlay = nil,
    isFarmingItems = false,
    farmEnabled = false,
    selectedItems = {
        ["Mysterious Arrow"] = true,
        ["Rokakaka"] = true,
    },
    noFogEnabled = false,
    dayEnabled = false,
    nightEnabled = false,
    antiVampEnabled = false,
    antiTSEnabled = false,
    fpsBoost = false,
}

-- ============================================================
--  GUI SETUP
-- ============================================================
local function cleanupOldGuis()
    local containers = {CoreGui, LocalPlayer:FindFirstChild("PlayerGui")}
    for _, container in ipairs(containers) do
        if not container then continue end
        for _, child in ipairs(container:GetChildren()) do
            if child:IsA("ScreenGui") and child.Name:sub(1, #CONFIG.GUI_PREFIX) == CONFIG.GUI_PREFIX then
                pcall(function() child:Destroy() end)
            end
        end
    end
end

cleanupOldGuis()

local function safeParent(gui)
    local ok = pcall(function() gui.Parent = CoreGui end)
    if not ok then gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = CONFIG.GUI_PREFIX .. tostring(math.random(1, 999999))
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
safeParent(ScreenGui)

local function addStroke(parent, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color or THEME.stroke
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent
    return s
end

local function addCorner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 6)
    c.Parent = parent
    return c
end

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 720, 0, 500)
MainFrame.Position = UDim2.new(0.5, -360, 0.5, -250)
MainFrame.BackgroundColor3 = THEME.bg
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui
addCorner(MainFrame, 12)
addStroke(MainFrame, THEME.strokeSoft, 1, 0.3)

local BgGrad = Instance.new("UIGradient")
BgGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, THEME.bg),
    ColorSequenceKeypoint.new(1, THEME.bgGrad),
})
BgGrad.Rotation = 135
BgGrad.Parent = MainFrame

local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 38)
TopBar.BackgroundColor3 = THEME.panel
TopBar.BorderSizePixel = 0
TopBar.Active = true
TopBar.Parent = MainFrame
addCorner(TopBar, 12)

local TopBarCover = Instance.new("Frame")
TopBarCover.Size = UDim2.new(1, 0, 0, 16)
TopBarCover.Position = UDim2.new(0, 0, 1, -16)
TopBarCover.BackgroundColor3 = THEME.panel
TopBarCover.BorderSizePixel = 0
TopBarCover.Parent = TopBar

local TopGrad = Instance.new("UIGradient")
TopGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 25, 60)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(22, 22, 30)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 22, 50)),
})
TopGrad.Rotation = 90
TopGrad.Parent = TopBar

local LogoGlow = Instance.new("Frame")
LogoGlow.Size = UDim2.new(0, 10, 0, 10)
LogoGlow.Position = UDim2.new(0, 12, 0.5, -5)
LogoGlow.BackgroundColor3 = THEME.accent
LogoGlow.BorderSizePixel = 0
LogoGlow.Parent = TopBar
addCorner(LogoGlow, 5)

local LogoGlowGrad = Instance.new("UIGradient")
LogoGlowGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, THEME.accent),
    ColorSequenceKeypoint.new(1, THEME.accent2),
})
LogoGlowGrad.Parent = LogoGlow

local LogoText = Instance.new("TextLabel")
LogoText.Size = UDim2.new(0, 200, 1, 0)
LogoText.Position = UDim2.new(0, 30, 0, 0)
LogoText.BackgroundTransparency = 1
LogoText.Text = "VOID"
LogoText.TextColor3 = THEME.text
LogoText.TextSize = 15
LogoText.Font = Enum.Font.GothamBold
LogoText.TextXAlignment = Enum.TextXAlignment.Left
LogoText.Parent = TopBar

local LogoAccent = Instance.new("TextLabel")
LogoAccent.Size = UDim2.new(0, 400, 1, 0)
LogoAccent.Position = UDim2.new(0, 72, 0, 0)
LogoAccent.BackgroundTransparency = 1
LogoAccent.Text = "| YBA Script"
LogoAccent.TextColor3 = THEME.subtext
LogoAccent.TextSize = 12
LogoAccent.Font = Enum.Font.Gotham
LogoAccent.TextXAlignment = Enum.TextXAlignment.Left
LogoAccent.Parent = TopBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 24, 0, 24)
CloseBtn.Position = UDim2.new(1, -32, 0.5, -12)
CloseBtn.BackgroundColor3 = THEME.panel3
CloseBtn.Text = "×"
CloseBtn.TextColor3 = THEME.subtext
CloseBtn.TextSize = 16
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.BorderSizePixel = 0
CloseBtn.AutoButtonColor = false
CloseBtn.Parent = TopBar
addCorner(CloseBtn, 6)

CloseBtn.MouseEnter:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.15), {BackgroundColor3 = THEME.err, TextColor3 = Color3.new(1,1,1)}):Play()
end)
CloseBtn.MouseLeave:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.15), {BackgroundColor3 = THEME.panel3, TextColor3 = THEME.subtext}):Play()
end)

local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 150, 1, -80)
Sidebar.Position = UDim2.new(0, 6, 0, 44)
Sidebar.BackgroundColor3 = THEME.panel
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame
addCorner(Sidebar, 10)
addStroke(Sidebar, THEME.strokeSoft, 1, 0.5)

local Content = Instance.new("Frame")
Content.Name = "Content"
Content.Size = UDim2.new(1, -170, 1, -80)
Content.Position = UDim2.new(0, 162, 0, 44)
Content.BackgroundColor3 = THEME.panel
Content.BorderSizePixel = 0
Content.Parent = MainFrame
addCorner(Content, 10)
addStroke(Content, THEME.strokeSoft, 1, 0.5)

-- BOTTOM BAR
local BottomBar = Instance.new("Frame")
BottomBar.Name = "BottomBar"
BottomBar.Size = UDim2.new(1, -12, 0, 30)
BottomBar.Position = UDim2.new(0, 6, 1, -36)
BottomBar.BackgroundColor3 = THEME.panel
BottomBar.BorderSizePixel = 0
BottomBar.Parent = MainFrame
addCorner(BottomBar, 8)
addStroke(BottomBar, THEME.strokeSoft, 1, 0.5)

local KeyBtn = Instance.new("TextButton")
KeyBtn.Size = UDim2.new(0.5, -6, 1, -6)
KeyBtn.Position = UDim2.new(0, 3, 0, 3)
KeyBtn.BackgroundColor3 = THEME.panel2
KeyBtn.Text = "Key - https://t.me/ybavoid"
KeyBtn.TextColor3 = THEME.text
KeyBtn.TextSize = 11
KeyBtn.Font = Enum.Font.Gotham
KeyBtn.BorderSizePixel = 0
KeyBtn.AutoButtonColor = false
KeyBtn.Parent = BottomBar
addCorner(KeyBtn, 5)

local UnicBtn = Instance.new("TextButton")
UnicBtn.Size = UDim2.new(0.5, -6, 1, -6)
UnicBtn.Position = UDim2.new(0.5, 3, 0, 3)
UnicBtn.BackgroundColor3 = THEME.panel2
UnicBtn.Text = "Unic ID - " .. UNIQUE_ID
UnicBtn.TextColor3 = THEME.text
UnicBtn.TextSize = 11
UnicBtn.Font = Enum.Font.Gotham
UnicBtn.BorderSizePixel = 0
UnicBtn.AutoButtonColor = false
UnicBtn.Parent = BottomBar
addCorner(UnicBtn, 5)

local function showCopyOverlay()
    local overlay = Instance.new("ScreenGui")
    overlay.Name = "VoidCopyOverlay"
    overlay.ResetOnSpawn = false
    overlay.IgnoreGuiInset = true
    overlay.DisplayOrder = 9999
    local ok = pcall(function() overlay.Parent = CoreGui end)
    if not ok then overlay.Parent = LocalPlayer:WaitForChild("PlayerGui") end

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(0, 200, 80)
    bg.BackgroundTransparency = 0.15
    bg.BorderSizePixel = 0
    bg.Parent = overlay

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 120)
    lbl.Position = UDim2.new(0, 0, 0.5, -60)
    lbl.BackgroundTransparency = 1
    lbl.Text = "COPIED"
    lbl.TextColor3 = Color3.new(1,1,1)
    lbl.TextScaled = true
    lbl.Font = Enum.Font.GothamBlack
    lbl.Parent = bg

    task.spawn(function()
        task.wait(1)
        overlay:Destroy()
    end)
end

local function copyToClipboard(text)
    pcall(function()
        if setclipboard then setclipboard(text)
        elseif toclipboard then toclipboard(text) end
    end)
    showCopyOverlay()
end

KeyBtn.MouseButton1Click:Connect(function()
    copyToClipboard("https://t.me/ybavoid")
end)

UnicBtn.MouseButton1Click:Connect(function()
    copyToClipboard(UNIQUE_ID)
end)

-- UI BUILDERS
local Tabs = {}
local function registerTab(name, button, label, indicator, frame)
    Tabs[name] = {button = button, label = label, indicator = indicator, frame = frame}
end

local function showTab(name)
    for n, t in pairs(Tabs) do
        if n == name then
            t.frame.Visible = true
            t.indicator.BackgroundTransparency = 0
            t.indicator.Size = UDim2.new(0, 3, 0.6, 0)
            t.label.TextColor3 = THEME.text
            TweenService:Create(t.button, TweenInfo.new(0.15), {BackgroundTransparency = 0.35}):Play()
        else
            t.frame.Visible = false
            t.indicator.BackgroundTransparency = 1
            t.indicator.Size = UDim2.new(0, 3, 0, 0)
            t.label.TextColor3 = THEME.subtext
            TweenService:Create(t.button, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play()
        end
    end
end

local function makeTabButton(parent, text, yPos, onClick)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -12, 0, 32)
    btn.Position = UDim2.new(0, 6, 0, yPos)
    btn.BackgroundColor3 = THEME.panel3
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Parent = parent
    addCorner(btn, 7)

    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 3, 0, 0)
    indicator.Position = UDim2.new(0, 4, 0.5, 0)
    indicator.AnchorPoint = Vector2.new(0, 0.5)
    indicator.BackgroundColor3 = THEME.accent
    indicator.BorderSizePixel = 0
    indicator.BackgroundTransparency = 1
    indicator.Parent = btn
    addCorner(indicator, 2)

    local indGrad = Instance.new("UIGradient")
    indGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, THEME.accent),
        ColorSequenceKeypoint.new(1, THEME.accent2),
    })
    indGrad.Rotation = 90
    indGrad.Parent = indicator

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -20, 1, 0)
    lbl.Position = UDim2.new(0, 18, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = THEME.subtext
    lbl.TextSize = 13
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = btn

    btn.MouseEnter:Connect(function()
        if btn.BackgroundTransparency == 1 then
            TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundTransparency = 0.75}):Play()
        end
    end)
    btn.MouseLeave:Connect(function()
        if btn.BackgroundTransparency ~= 0.35 then
            TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play()
        end
    end)
    btn.MouseButton1Click:Connect(onClick)

    return btn, lbl, indicator
end

local function addSectionLabel(parent, text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 18)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = THEME.dimtext
    lbl.TextSize = 10
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = parent
end

local function makeToggleBtn(parent, text, initial, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.BackgroundColor3 = initial and THEME.blue or THEME.red
    btn.Text = text
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Parent = parent
    addCorner(btn, 6)

    local state = initial
    btn.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = state and THEME.blue or THEME.red}):Play()
        pcall(callback, state)
    end)
    return btn
end

local function makeSlider(parent, text, min, max, default, callback)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, 0, 0, 46)
    holder.BackgroundColor3 = THEME.panel2
    holder.BorderSizePixel = 0
    holder.Parent = parent
    addCorner(holder, 6)
    addStroke(holder, THEME.strokeSoft, 1, 0.5)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -20, 0, 18)
    lbl.Position = UDim2.new(0, 10, 0, 4)
    lbl.BackgroundTransparency = 1
    lbl.Text = text .. ": " .. tostring(default)
    lbl.TextColor3 = THEME.text
    lbl.TextSize = 11
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = holder

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -20, 0, 8)
    track.Position = UDim2.new(0, 10, 0, 30)
    track.BackgroundColor3 = THEME.bg
    track.BorderSizePixel = 0
    track.Parent = holder
    addCorner(track, 4)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = THEME.accent
    fill.BorderSizePixel = 0
    fill.Parent = track
    addCorner(fill, 4)

    local fillGrad = Instance.new("UIGradient")
    fillGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, THEME.accent),
        ColorSequenceKeypoint.new(1, THEME.accent2),
    })
    fillGrad.Parent = fill

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 12, 1.8, 0)
    knob.Position = UDim2.new((default - min) / (max - min), -6, -0.4, 0)
    knob.BackgroundColor3 = Color3.new(1,1,1)
    knob.BorderSizePixel = 0
    knob.Parent = track
    addCorner(knob, 6)

    local dragging = false
    local function updateFromPos(x)
        local relX = x - track.AbsolutePosition.X
        local pct = math.clamp(relX / track.AbsoluteSize.X, 0, 1)
        fill.Size = UDim2.new(pct, 0, 1, 0)
        knob.Position = UDim2.new(pct, -6, -0.4, 0)
        local val = min + (max - min) * pct
        lbl.Text = text .. ": " .. string.format("%.2f", val)
        pcall(callback, val)
    end

    local hit = Instance.new("TextButton")
    hit.Size = UDim2.new(1, 0, 1, 0)
    hit.BackgroundTransparency = 1
    hit.Text = ""
    hit.Parent = track

    hit.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateFromPos(input.Position.X)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateFromPos(input.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- ============================================================
--  HELPERS
-- ============================================================
local function getStat(name)
    local stats = LocalPlayer:FindFirstChild("PlayerStats")
    if not stats then return "—" end
    local s = stats:FindFirstChild(name)
    if s then return tostring(s.Value) end
    return "—"
end

local function getStandName()
    local stats = LocalPlayer:FindFirstChild("PlayerStats")
    if not stats then return nil end
    local stand = stats:FindFirstChild("Stand")
    return stand and stand.Value or nil
end

local function hasItem(itemName)
    local char = LocalPlayer.Character
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if char and char:FindFirstChild(itemName) then return true end
    if backpack and backpack:FindFirstChild(itemName) then return true end
    return false
end

local function countItem(itemName)
    local count = 0
    local char = LocalPlayer.Character
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if char then
        for _, v in ipairs(char:GetChildren()) do
            if v.Name == itemName then count = count + 1 end
        end
    end
    if backpack then
        for _, v in ipairs(backpack:GetChildren()) do
            if v.Name == itemName then count = count + 1 end
        end
    end
    return count
end

local function getRemoteEvent()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("RemoteEvent")
end

local function getRemoteFunction()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("RemoteFunction")
end

local function getHRP()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function getLiving()
    return Workspace:FindFirstChild("Living")
end

local function fireClick(button)
    if not button then return end
    pcall(function()
        for _, conn in ipairs(getconnections(button.MouseButton1Click)) do conn.Function() end
    end)
    pcall(function()
        for _, conn in ipairs(getconnections(button.MouseButton1Down)) do conn.Function() end
    end)
    pcall(function()
        for _, conn in ipairs(getconnections(button.Activated)) do conn.Function() end
    end)
end

local function clickDialogueOption()
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if not pg then return false end
    local dlg = pg:FindFirstChild("DialogueGui")
    if not dlg then return false end
    local frame = dlg:FindFirstChild("Frame")
    if not frame then return false end
    local options = frame:FindFirstChild("Options")
    if not options then return false end
    local opt = options:FindFirstChild("Option1")
    if not opt then return false end
    if not opt.Visible then return false end
    local tb = opt:FindFirstChild("TextButton")
    if tb then fireClick(tb) return true end
    fireClick(opt)
    return true
end

local function useItemViaDialogue(itemName, maxAttempts)
    maxAttempts = maxAttempts or 25
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid")
    if not hum then return false end
    local tool = LocalPlayer.Backpack:FindFirstChild(itemName) or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild(itemName))
    if not tool then
        for _, v in ipairs(LocalPlayer.Backpack:GetChildren()) do
            if v.Name == itemName then tool = v break end
        end
    end
    if not tool then return false end
    if tool.Parent ~= LocalPlayer.Character then
        pcall(function() hum:EquipTool(tool) end)
        task.wait(0.4)
    end
    for attempt = 1, maxAttempts do
        if not State.isActive then return false end
        if clickDialogueOption() then
            task.wait(0.2)
            clickDialogueOption()
            task.wait(0.4)
            local pg = LocalPlayer:FindFirstChild("PlayerGui")
            if pg and not pg:FindFirstChild("DialogueGui") then return true end
        end
        task.wait(0.15)
    end
    return false
end

local function findNpcByName(name)
    local living = getLiving()
    if not living then return nil end
    for _, v in ipairs(living:GetChildren()) do
        if v.Name:lower():find(name:lower(), 1, true) and v:FindFirstChild("HumanoidRootPart") then
            return v
        end
    end
    return nil
end

local function teleportToNpc(npcName)
    local npc = findNpcByName(npcName)
    if not npc then return nil end
    local hrp = getHRP()
    if hrp then
        hrp.CFrame = npc.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
        task.wait(0.4)
    end
    return npc
end

local function GetQuestXenon(npcModel)
    if not npcModel then return end
    local DialogueName = npcModel:FindFirstChild("Dialogue")
    local char = LocalPlayer.Character
    if DialogueName and char and char:FindFirstChild("RemoteEvent") then
        DialogueName = DialogueName.Value
        local Event = char:FindFirstChild("RemoteEvent")
        for i = 1, 10 do
            Event:FireServer("EndDialogue", {
                ["NPC"] = DialogueName,
                ["Option"] = "Option1",
                ["Dialogue"] = "Dialogue" .. i
            })
            Event:FireServer("EndDialogue", {
                ["NPC"] = DialogueName,
                ["Dialogue"] = "Dialogue" .. i
            })
        end
    end
end

local function doXenonDialogues(npcName, times)
    times = times or 1
    for i = 1, times do
        local npc = teleportToNpc(npcName)
        if npc then GetQuestXenon(npc) end
        task.wait(0.5)
    end
end

local function secondDialogue(npcName, dialogueIndex, option)
    local npc = teleportToNpc(npcName)
    if not npc then return end
    local dName = npc:FindFirstChild("Dialogue")
    if not dName then return end
    dName = dName.Value
    local re = getRemoteEvent()
    if not re then return end
    re:FireServer("EndDialogue", {
        ["NPC"] = dName,
        ["Option"] = option or "Option2",
        ["Dialogue"] = "Dialogue" .. dialogueIndex
    })
    task.wait(0.5)
end

local function learnSkills(skills)
    local rf = getRemoteFunction()
    if not rf then return end
    for _, skill in ipairs(skills) do
        pcall(function()
            rf:InvokeServer("LearnSkill", {
                ["Skill"] = skill,
                ["SkillTreeType"] = "Character",
            })
        end)
    end
end

local function statsUp()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    if not char then return end
    repeat task.wait() until char:FindFirstChild("RemoteFunction")
    learnSkills({"Agility I", "Agility II", "Agility III", "Worthiness"})
end

local function checkStand()
    local stats = LocalPlayer:FindFirstChild("PlayerStats")
    local stand = stats and stats:FindFirstChild("Stand")
    return stand and stand.Value or "None"
end

local function equipStand()
    local char = LocalPlayer.Character
    if not char then return end
    local rf = char:FindFirstChild("RemoteFunction")
    local summoned = char:FindFirstChild("SummonedStand")
    if rf and summoned and summoned.Value == false then
        pcall(function() rf:InvokeServer("ToggleStand", "Toggle") end)
    end
end

local function UseMove(Move)
    local char = LocalPlayer.Character
    if not char then return end
    if Move == string.lower("m1") or Move == string.lower("m2") then
        local rf = char:FindFirstChild("RemoteFunction")
        if rf then pcall(function() rf:InvokeServer("Attack", Move) end) end
    end
end

local function KillEnemy(Enemy)
    if not Enemy then return end
    local oldPos = getHRP() and getHRP().CFrame
    local EnemyHRP = Enemy:FindFirstChild("HumanoidRootPart")
    local EnemyHumanoid = Enemy:FindFirstChildWhichIsA("Humanoid")
    local EnemyHealth = Enemy:FindFirstChild("Health")
    if not (EnemyHRP and EnemyHumanoid and EnemyHealth and EnemyHealth.Value > 0) then return end

    while (Enemy and Enemy.Parent and EnemyHealth and EnemyHealth.Value > 0 and EnemyHRP and EnemyHumanoid) do
        if not State.isActive then break end
        EnemyHRP = Enemy:FindFirstChild("HumanoidRootPart")
        EnemyHumanoid = Enemy:FindFirstChildWhichIsA("Humanoid")
        EnemyHealth = Enemy:FindFirstChild("Health")
        if not Enemy or not EnemyHRP or not EnemyHumanoid or not EnemyHealth or EnemyHealth.Value <= 0 then break end

        local char = LocalPlayer.Character
        if char and char:FindFirstChildWhichIsA("Humanoid") and char:FindFirstChildWhichIsA("Humanoid").Health > 0 then
            if checkStand() ~= "None" then equipStand() end
            if char:FindFirstChild("FocusCam") == nil then
                local fc = Instance.new("ObjectValue", char)
                fc.Name = "FocusCam"
                fc.Value = EnemyHRP
            else
                char.FocusCam.Value = EnemyHRP
            end
            local standMorph = char:FindFirstChild("StandMorph")
            if standMorph and standMorph.PrimaryPart then
                standMorph.PrimaryPart.CFrame = EnemyHRP.CFrame - EnemyHRP.CFrame.LookVector * 1.1
                char.PrimaryPart.CFrame = standMorph.PrimaryPart.CFrame + standMorph.PrimaryPart.CFrame.LookVector * math.random(-3, -2) + Vector3.new(0, CONFIG.KILL_HEIGHT, 0)
            else
                char.PrimaryPart.CFrame = EnemyHRP.CFrame - EnemyHRP.CFrame.LookVector * 2.3
            end
            task.spawn(function() UseMove("m1") end)
        elseif char and char:FindFirstChildWhichIsA("Humanoid") and char:FindFirstChildWhichIsA("Humanoid").Health <= 0 then
            LocalPlayer.CharacterAdded:Wait()
        end
        task.wait()
    end

    task.wait(1)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") and oldPos then
        pcall(function() char.HumanoidRootPart.CFrame = oldPos end)
    end
    pcall(function()
        if char and char:FindFirstChild("FocusCam") then char.FocusCam:Destroy() end
    end)
end

local function waitForJotaroKujo()
    local living = getLiving()
    if not living then return nil end
    for _, v in ipairs(living:GetChildren()) do
        if v.Name:lower():find("jotaro kujo", 1, true) and v:FindFirstChild("Health") and v.Health.Value > 0 and v:FindFirstChild("HumanoidRootPart") then
            return v
        end
    end
    return nil
end

local function waitForAnasuiBoss()
    local living = getLiving()
    if not living then return nil end
    for _, v in ipairs(living:GetChildren()) do
        if v.Name:lower() == "anasui" and v:FindFirstChild("Health") and v.Health.Value > 0 and v:FindFirstChild("HumanoidRootPart") then
            return v
        end
    end
    return nil
end

local function showWarningOverlay()
    if State.warnOverlay then return end
    local overlay = Instance.new("Frame")
    overlay.Name = "VoidWarnOverlay"
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    overlay.BackgroundTransparency = 0.4
    overlay.BorderSizePixel = 0
    overlay.ZIndex = 100
    overlay.Parent = ScreenGui

    local warnText = Instance.new("TextLabel")
    warnText.Size = UDim2.new(1, 0, 0, 120)
    warnText.Position = UDim2.new(0, 0, 0.35, -60)
    warnText.BackgroundTransparency = 1
    warnText.Text = "WARNING!\nYour current stand (" .. (getStandName() or "—") .. ") WILL BE ROKA'D!"
    warnText.TextColor3 = THEME.err
    warnText.TextScaled = true
    warnText.Font = Enum.Font.GothamBlack
    warnText.ZIndex = 101
    warnText.Parent = overlay

    local timerText = Instance.new("TextLabel")
    timerText.Name = "TimerText"
    timerText.Size = UDim2.new(1, 0, 0, 160)
    timerText.Position = UDim2.new(0, 0, 0.5, 0)
    timerText.BackgroundTransparency = 1
    timerText.Text = tostring(CONFIG.WARN_TIME)
    timerText.TextColor3 = THEME.text
    timerText.TextScaled = true
    timerText.Font = Enum.Font.GothamBlack
    timerText.ZIndex = 101
    timerText.Parent = overlay

    State.warnOverlay = overlay

    task.spawn(function()
        for i = CONFIG.WARN_TIME, 1, -1 do
            if not State.warnOverlay or not State.warnOverlay.Parent then break end
            timerText.Text = tostring(i)
            task.wait(1)
        end
        if State.warnOverlay and State.warnOverlay.Parent then
            State.warnOverlay:Destroy()
            State.warnOverlay = nil
        end
    end)
end

local function hideWarningOverlay()
    if State.warnOverlay and State.warnOverlay.Parent then
        State.warnOverlay:Destroy()
    end
    State.warnOverlay = nil
end

local function getItemPrompt(Item)
    if not Item then return nil end
    local prompt = Item:FindFirstChildWhichIsA("ProximityPrompt")
    if prompt then return prompt end
    for _, v in ipairs(Item:GetDescendants()) do
        if v:IsA("ProximityPrompt") then return v end
    end
    return nil
end

local function getItemPart(Item)
    if not Item then return nil end
    if Item.PrimaryPart then return Item.PrimaryPart end
    local hrp = Item:FindFirstChild("HumanoidRootPart")
    if hrp then return hrp end
    return Item:FindFirstChildWhichIsA("BasePart")
end

local function getItemsFolder()
    local spawn = Workspace:FindFirstChild("Item_Spawns")
    if not spawn then return nil end
    return spawn:FindFirstChild("Items") or spawn
end

local function collectItem(Item)
    if not Item then return false end
    local part = getItemPart(Item)
    local prompt = getItemPrompt(Item)
    if not part or not prompt then return false end

    local myHrp = getHRP()
    if not myHrp then return false end

    local oldCF = myHrp.CFrame
    myHrp.CFrame = part.CFrame - Vector3.new(0, 10, 0)
    task.wait(0.15)

    prompt.RequiresLineOfSight = false
    prompt.HoldDuration = 0
    prompt.MaxActivationDistance = 30

    local start = tick()
    local folder = getItemsFolder()
    repeat
        if not Item.Parent or (folder and Item.Parent ~= folder) then break end
        if myHrp and myHrp.Parent and part and part.Parent then
            myHrp.CFrame = part.CFrame - Vector3.new(0, 10, 0)
        end
        pcall(function() fireproximityprompt(prompt) end)
        task.wait(0.05)
    until not Item.Parent or (folder and Item.Parent ~= folder) or tick() - start >= CONFIG.ITEM_FARM_TIMEOUT

    task.wait(0.2)
    if myHrp and myHrp.Parent then
        pcall(function() myHrp.CFrame = oldCF end)
    end
    return not Item.Parent or (folder and Item.Parent ~= folder)
end

local function isMaxItem(itemName)
    local max = ITEM_MAX[itemName]
    if not max then return false end
    return countItem(itemName) >= max
end

local function farmSelectedItems()
    State.farmEnabled = true
    while State.farmEnabled and ScreenGui.Parent do
        local folder = getItemsFolder()
        if folder then
            for _, v in ipairs(folder:GetChildren()) do
                if not State.farmEnabled then break end
                if State.selectedItems[v.Name] and not isMaxItem(v.Name) then
                    pcall(function() collectItem(v) end)
                end
            end
        end
        task.wait(0.3)
    end
end

-- ============================================================
--  DD TAB
-- ============================================================
local DDFrame = Instance.new("Frame")
DDFrame.Name = "DiverDown"
DDFrame.Size = UDim2.new(1, -20, 1, -20)
DDFrame.Position = UDim2.new(0, 10, 0, 10)
DDFrame.BackgroundTransparency = 1
DDFrame.Parent = Content

local DDLayout = Instance.new("UIListLayout")
DDLayout.SortOrder = Enum.SortOrder.LayoutOrder
DDLayout.Padding = UDim.new(0, 8)
DDLayout.Parent = DDFrame

local InfoPanel = Instance.new("Frame")
InfoPanel.Size = UDim2.new(1, 0, 0, 118)
InfoPanel.BackgroundColor3 = THEME.panel2
InfoPanel.BorderSizePixel = 0
InfoPanel.Parent = DDFrame
addCorner(InfoPanel, 8)
addStroke(InfoPanel, THEME.strokeSoft, 1, 0.5)

local InfoHeader = Instance.new("TextLabel")
InfoHeader.Size = UDim2.new(1, -20, 0, 18)
InfoHeader.Position = UDim2.new(0, 10, 0, 6)
InfoHeader.BackgroundTransparency = 1
InfoHeader.Text = "STATUS"
InfoHeader.TextColor3 = THEME.dimtext
InfoHeader.TextSize = 10
InfoHeader.Font = Enum.Font.GothamBold
InfoHeader.TextXAlignment = Enum.TextXAlignment.Left
InfoHeader.Parent = InfoPanel

local InfoLabel = Instance.new("TextLabel")
InfoLabel.Size = UDim2.new(1, -20, 1, -34)
InfoLabel.Position = UDim2.new(0, 10, 0, 26)
InfoLabel.BackgroundTransparency = 1
InfoLabel.Text = "Stand: —\nStep: 0\nJotaro's Disc: no\nAnasui Boss: —"
InfoLabel.TextColor3 = THEME.text
InfoLabel.TextSize = 12
InfoLabel.Font = Enum.Font.Gotham
InfoLabel.TextXAlignment = Enum.TextXAlignment.Left
InfoLabel.TextYAlignment = Enum.TextYAlignment.Top
InfoLabel.Parent = InfoPanel

local DDMainButton = Instance.new("TextButton")
DDMainButton.Size = UDim2.new(1, 0, 0, 42)
DDMainButton.BackgroundColor3 = THEME.red
DDMainButton.Text = "START DIVER DOWN"
DDMainButton.TextColor3 = Color3.new(1,1,1)
DDMainButton.TextSize = 13
DDMainButton.Font = Enum.Font.GothamBold
DDMainButton.BorderSizePixel = 0
DDMainButton.AutoButtonColor = false
DDMainButton.Parent = DDFrame
addCorner(DDMainButton, 8)

local CheckDiscButton = Instance.new("TextButton")
CheckDiscButton.Size = UDim2.new(1, 0, 0, 32)
CheckDiscButton.BackgroundColor3 = THEME.panel3
CheckDiscButton.Text = "Check Jotaro's Disc"
CheckDiscButton.TextColor3 = THEME.text
CheckDiscButton.TextSize = 12
CheckDiscButton.Font = Enum.Font.Gotham
CheckDiscButton.BorderSizePixel = 0
CheckDiscButton.AutoButtonColor = false
CheckDiscButton.Parent = DDFrame
addCorner(CheckDiscButton, 6)
addStroke(CheckDiscButton, THEME.strokeSoft, 1, 0.5)

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, 0, 0, 24)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Status: idle"
StatusLabel.TextColor3 = THEME.subtext
StatusLabel.TextSize = 12
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = DDFrame

local function setStatus(text, color)
    StatusLabel.Text = "Status: " .. text
    StatusLabel.TextColor3 = color or THEME.subtext
end

local function updateInfo()
    local disc = hasItem("Jotaro's Disc") and "yes" or "no"
    local anasuiBoss = nil
    local living = Workspace:FindFirstChild("Living")
    if living then
        for _, v in ipairs(living:GetChildren()) do
            if v.Name:lower():find("anasui") and v:FindFirstChild("Health") and v.Health.Value > 0 then
                anasuiBoss = "alive (" .. math.floor(v.Health.Value) .. ")"
                break
            end
        end
    end
    InfoLabel.Text = "Stand: " .. (getStandName() or "—") ..
        "\nStep: " .. tostring(State.step) ..
        "\nJotaro's Disc: " .. disc ..
        "\nAnasui Boss: " .. (anasuiBoss or "—") ..
        "\nArrows: " .. tostring(countItem("Mysterious Arrow")) ..
        " | Rokas: " .. tostring(countItem("Rokakaka"))
end

local function autoRespawn()
    local char = LocalPlayer.Character
    if char then
        pcall(function()
            local fc = char:FindFirstChild("FocusCam")
            if fc then fc:Destroy() end
        end)
    end
    pcall(function()
        Camera.CameraType = Enum.CameraType.Custom
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then Camera.CameraSubject = hum end
    end)
    task.wait(0.1)
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then pcall(function() hum.Health = 0 end) end
    LocalPlayer.CharacterAdded:Wait()
    task.wait(1.5)
    local newChar = LocalPlayer.Character
    if newChar then
        repeat task.wait() until newChar:FindFirstChild("RemoteFunction")
        pcall(function()
            Camera.CameraType = Enum.CameraType.Custom
            local newHum = newChar:FindFirstChildOfClass("Humanoid")
            if newHum then Camera.CameraSubject = newHum end
        end)
        equipStand()
    end
end

local function farmStoneFree()
    setStatus("farming Stone Free", THEME.warn)
    local hrp = getHRP()
    if hrp then hrp.CFrame = CFrame.new(-324, -32, 47) end
    while State.isActive do
        if checkStand() == "Stone Free" then
            setStatus("Stone Free obtained!", THEME.ok)
            return true
        end
        if countItem("Mysterious Arrow") < 1 or countItem("Rokakaka") < 1 then
            local folder = getItemsFolder()
            if folder then
                for _, v in ipairs(folder:GetChildren()) do
                    if not State.isActive then return false end
                    if v.Name == "Mysterious Arrow" or v.Name == "Rokakaka" then
                        pcall(function() collectItem(v) end)
                    end
                end
            end
            task.wait(0.5)
        end
        statsUp()
        if checkStand() ~= "None" and checkStand() ~= "Stone Free" then
            setStatus("using Rokakaka", THEME.warn)
            useItemViaDialogue("Rokakaka")
            task.wait(1)
        end
        if checkStand() == "None" then
            setStatus("using Mysterious Arrow", THEME.warn)
            useItemViaDialogue("Mysterious Arrow")
            task.wait(1)
        end
        task.wait(0.5)
    end
    return false
end

local function runAutoDiverDown()
    if State.isActive then return end
    State.isActive = true
    State.step = 0
    setStatus("starting...", THEME.warn)

    State.mainThread = task.spawn(function()
        local stand = checkStand()
        if stand ~= "Stone Free" then
            setStatus("not Stone Free, warning", THEME.err)
            showWarningOverlay()
            task.wait(CONFIG.WARN_TIME)
            hideWarningOverlay()
            if not State.isActive then return end
            State.step = 1
            farmStoneFree()
            if not State.isActive then return end
            setStatus("dying to respawn", THEME.warn)
            autoRespawn()
            if not State.isActive then return end
        end

        if checkStand() ~= "Stone Free" then
            setStatus("Stone Free not obtained, stopping", THEME.err)
            State.isActive = false
            DDMainButton.Text = "START DIVER DOWN"
            TweenService:Create(DDMainButton, TweenInfo.new(0.2), {BackgroundColor3 = THEME.red}):Play()
            return
        end

        equipStand()
        task.wait(0.5)

        State.step = 2
        setStatus("step: Pucci", THEME.accent2)
        secondDialogue("Pucci", 2, "Option2")
        task.wait(0.5)
        if not State.isActive then return end

        State.step = 3
        setStatus("step: Anasui top", THEME.accent2)
        doXenonDialogues("Anasui", 1)
        task.wait(0.3)
        if not State.isActive then return end

        State.step = 4
        setStatus("step: Anasui 3rd", THEME.accent2)
        secondDialogue("Anasui", 3, "Option1")
        task.wait(0.5)
        if not State.isActive then return end

        State.step = 5
        setStatus("step: Anasui 4x top", THEME.accent2)
        for i = 1, 4 do
            doXenonDialogues("Anasui", 1)
            task.wait(0.3)
        end
        if not State.isActive then return end

        State.step = 6
        if not hasItem("Jotaro's Disc") then
            setStatus("farming Jotaro's Disc", THEME.warn)
            local start = tick()
            while State.isActive and not hasItem("Jotaro's Disc") do
                if tick() - start > 900 then break end
                local target = waitForJotaroKujo()
                if target then pcall(KillEnemy, target) end
                task.wait(0.4)
            end
            if not State.isActive then return end
        end

        State.step = 7
        setStatus("step: Anasui 2x top", THEME.accent2)
        for i = 1, 2 do
            doXenonDialogues("Anasui", 1)
            task.wait(0.3)
        end
        if not State.isActive then return end

        State.step = 8
        setStatus("step: Pucci 2nd", THEME.accent2)
        secondDialogue("Pucci", 2, "Option2")
        task.wait(0.5)
        if not State.isActive then return end

        State.step = 9
        setStatus("step: Pucci 3x top", THEME.accent2)
        for i = 1, 3 do
            doXenonDialogues("Pucci", 1)
            task.wait(0.3)
        end
        if not State.isActive then return end

        State.step = 10
        setStatus("farming Anasui boss", THEME.warn)
        while State.isActive do
            local target = waitForAnasuiBoss()
            if target then pcall(KillEnemy, target) end
            task.wait(0.4)
        end

        setStatus("done", THEME.ok)
        State.isActive = false
        DDMainButton.Text = "START DIVER DOWN"
        TweenService:Create(DDMainButton, TweenInfo.new(0.2), {BackgroundColor3 = THEME.red}):Play()
    end)
end

local function stopAutoDiverDown()
    State.isActive = false
    hideWarningOverlay()
    if State.mainThread then
        pcall(function() task.cancel(State.mainThread) end)
        State.mainThread = nil
    end
    setStatus("stopped", THEME.subtext)
    DDMainButton.Text = "START DIVER DOWN"
    TweenService:Create(DDMainButton, TweenInfo.new(0.2), {BackgroundColor3 = THEME.red}):Play()
end

DDMainButton.MouseButton1Click:Connect(function()
    if State.isActive then
        stopAutoDiverDown()
    else
        runAutoDiverDown()
        DDMainButton.Text = "STOP DIVER DOWN"
        TweenService:Create(DDMainButton, TweenInfo.new(0.2), {BackgroundColor3 = THEME.blue}):Play()
    end
end)

CheckDiscButton.MouseButton1Click:Connect(function()
    local has = hasItem("Jotaro's Disc")
    setStatus(has and "Jotaro's Disc found!" or "no Jotaro's Disc", has and THEME.ok or THEME.err)
end)

-- ============================================================
--  AUTOFARM TAB
-- ============================================================
local FarmFrame = Instance.new("Frame")
FarmFrame.Name = "Autofarm"
FarmFrame.Size = UDim2.new(1, -20, 1, -20)
FarmFrame.Position = UDim2.new(0, 10, 0, 10)
FarmFrame.BackgroundTransparency = 1
FarmFrame.Visible = false
FarmFrame.Parent = Content

local FarmToggle = Instance.new("TextButton")
FarmToggle.Size = UDim2.new(1, 0, 0, 38)
FarmToggle.BackgroundColor3 = THEME.red
FarmToggle.Text = "ENABLE AUTOFARM"
FarmToggle.TextColor3 = Color3.new(1,1,1)
FarmToggle.TextSize = 13
FarmToggle.Font = Enum.Font.GothamBold
FarmToggle.BorderSizePixel = 0
FarmToggle.AutoButtonColor = false
FarmToggle.Parent = FarmFrame
addCorner(FarmToggle, 8)

local FarmScroll = Instance.new("ScrollingFrame")
FarmScroll.Size = UDim2.new(1, 0, 1, -50)
FarmScroll.Position = UDim2.new(0, 0, 0, 46)
FarmScroll.BackgroundColor3 = THEME.panel2
FarmScroll.BorderSizePixel = 0
FarmScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
FarmScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
FarmScroll.ScrollBarThickness = 6
FarmScroll.ScrollBarImageColor3 = THEME.accent
FarmScroll.ScrollingDirection = Enum.ScrollingDirection.Y
FarmScroll.ClipsDescendants = true
FarmScroll.Parent = FarmFrame
addCorner(FarmScroll, 8)
addStroke(FarmScroll, THEME.strokeSoft, 1, 0.5)

local FarmLayout = Instance.new("UIListLayout")
FarmLayout.SortOrder = Enum.SortOrder.LayoutOrder
FarmLayout.Padding = UDim.new(0, 4)
FarmLayout.Parent = FarmScroll

local FarmPadding = Instance.new("UIPadding")
FarmPadding.PaddingTop = UDim.new(0, 6)
FarmPadding.PaddingBottom = UDim.new(0, 6)
FarmPadding.PaddingLeft = UDim.new(0, 6)
FarmPadding.PaddingRight = UDim.new(0, 6)
FarmPadding.Parent = FarmScroll

local itemToggles = {}

local function addItemToggle(itemName)
    local row = Instance.new("TextButton")
    row.Size = UDim2.new(1, -12, 0, 28)
    row.BackgroundColor3 = THEME.panel3
    row.Text = ""
    row.BorderSizePixel = 0
    row.AutoButtonColor = false
    row.Parent = FarmScroll
    addCorner(row, 6)

    local box = Instance.new("Frame")
    box.Size = UDim2.new(0, 14, 0, 14)
    box.Position = UDim2.new(0, 8, 0.5, -7)
    box.BackgroundColor3 = THEME.bg
    box.BorderSizePixel = 0
    box.Parent = row
    addCorner(box, 3)
    addStroke(box, THEME.stroke, 1, 0)

    local check = Instance.new("Frame")
    check.Size = UDim2.new(0, 8, 0, 8)
    check.Position = UDim2.new(0.5, -4, 0.5, -4)
    check.BackgroundColor3 = THEME.accent
    check.BorderSizePixel = 0
    check.BackgroundTransparency = State.selectedItems[itemName] and 0 or 1
    check.Parent = box
    addCorner(check, 2)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -40, 1, 0)
    lbl.Position = UDim2.new(0, 30, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = itemName
    lbl.TextColor3 = THEME.text
    lbl.TextSize = 12
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    row.MouseButton1Click:Connect(function()
        State.selectedItems[itemName] = not State.selectedItems[itemName]
        TweenService:Create(check, TweenInfo.new(0.15), {BackgroundTransparency = State.selectedItems[itemName] and 0 or 1}):Play()
    end)

    itemToggles[itemName] = {row = row, check = check}
end

for _, name in ipairs(ALL_FARM_ITEMS) do
    addItemToggle(name)
end

FarmToggle.MouseButton1Click:Connect(function()
    State.farmEnabled = not State.farmEnabled
    if State.farmEnabled then
        FarmToggle.Text = "DISABLE AUTOFARM"
        TweenService:Create(FarmToggle, TweenInfo.new(0.2), {BackgroundColor3 = THEME.blue}):Play()
        task.spawn(farmSelectedItems)
    else
        FarmToggle.Text = "ENABLE AUTOFARM"
        TweenService:Create(FarmToggle, TweenInfo.new(0.2), {BackgroundColor3 = THEME.red}):Play()
    end
end)

-- ============================================================
--  PLAYER TAB
-- ============================================================
local PlayerFrame = Instance.new("Frame")
PlayerFrame.Name = "Player"
PlayerFrame.Size = UDim2.new(1, -20, 1, -20)
PlayerFrame.Position = UDim2.new(0, 10, 0, 10)
PlayerFrame.BackgroundTransparency = 1
PlayerFrame.Visible = false
PlayerFrame.Parent = Content

local PlayerScroll = Instance.new("ScrollingFrame")
PlayerScroll.Size = UDim2.new(1, 0, 1, 0)
PlayerScroll.BackgroundTransparency = 1
PlayerScroll.BorderSizePixel = 0
PlayerScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
PlayerScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
PlayerScroll.ScrollBarThickness = 6
PlayerScroll.ScrollBarImageColor3 = THEME.accent
PlayerScroll.Parent = PlayerFrame

local PlayerLayout = Instance.new("UIListLayout")
PlayerLayout.SortOrder = Enum.SortOrder.LayoutOrder
PlayerLayout.Padding = UDim.new(0, 6)
PlayerLayout.Parent = PlayerScroll

local PlayerPadding = Instance.new("UIPadding")
PlayerPadding.PaddingTop = UDim.new(0, 4)
PlayerPadding.PaddingBottom = UDim.new(0, 4)
PlayerPadding.PaddingLeft = UDim.new(0, 4)
PlayerPadding.PaddingRight = UDim.new(0, 4)
PlayerPadding.Parent = PlayerScroll

local PState = {
    speed = false, speedVal = 100,
    jump = false, jumpVal = 100,
    fly = false, flySpeed = 1,
    noclip = false, autoSprint = false,
    infDash = false, dashPower = 50, dashDelay = 1, lastDash = 0,
    flyBV = nil, flyAttach = nil,
}

addSectionLabel(PlayerScroll, "CHARACTER")
makeToggleBtn(PlayerScroll, "Speed", false, function(s) PState.speed = s end)
makeSlider(PlayerScroll, "Speed Value", 16, 500, 100, function(v) PState.speedVal = v end)
makeToggleBtn(PlayerScroll, "Jump", false, function(s) PState.jump = s end)
makeSlider(PlayerScroll, "Jump Value", 50, 1000, 100, function(v) PState.jumpVal = v end)

makeToggleBtn(PlayerScroll, "Fly", false, function(s)
    PState.fly = s
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if s then
        if PState.flyBV then PState.flyBV:Destroy() end
        if PState.flyAttach then PState.flyAttach:Destroy() end
        PState.flyAttach = Instance.new("Attachment")
        PState.flyAttach.Name = "VoidFlyAttach"
        PState.flyAttach.Parent = hrp
        PState.flyBV = Instance.new("LinearVelocity")
        PState.flyBV.Name = "VoidFlyBV"
        PState.flyBV.Attachment0 = PState.flyAttach
        PState.flyBV.MaxForce = 1e6
        PState.flyBV.VectorVelocity = Vector3.new(0, 0, 0)
        PState.flyBV.Parent = hrp
    else
        if PState.flyBV then PState.flyBV:Destroy() PState.flyBV = nil end
        if PState.flyAttach then PState.flyAttach:Destroy() PState.flyAttach = nil end
    end
end)
makeSlider(PlayerScroll, "Fly Speed", 0.1, 5, 1, function(v) PState.flySpeed = v end)

makeToggleBtn(PlayerScroll, "NoClip", false, function(s)
    PState.noclip = s
    if not s then
        local char = LocalPlayer.Character
        if char then
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then
                    pcall(function() p.CanCollide = true end)
                end
            end
        end
    end
end)

makeToggleBtn(PlayerScroll, "Auto Sprint", false, function(s) PState.autoSprint = s end)

addSectionLabel(PlayerScroll, "DASH")
makeToggleBtn(PlayerScroll, "Infinite Dash", false, function(s) PState.infDash = s end)
makeSlider(PlayerScroll, "Dash Power", 10, 500, 50, function(v) PState.dashPower = v end)
makeSlider(PlayerScroll, "Dash Delay", 0, 3, 1, function(v) PState.dashDelay = v end)

task.spawn(function()
    while ScreenGui.Parent do
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            local hrp = char:FindFirstChild("HumanoidRootPart")

            if PState.speed and hum then
                pcall(function() hum.WalkSpeed = PState.speedVal end)
            end
            if PState.jump and hum then
                pcall(function() hum.JumpPower = PState.jumpVal end)
            end
            if PState.noclip then
                for _, p in ipairs(char:GetDescendants()) do
                    if p:IsA("BasePart") and p.CanCollide then
                        pcall(function() p.CanCollide = false end)
                    end
                end
            end
            if PState.fly and PState.flyBV and hrp then
                local cam = Camera.CFrame
                local vel = Vector3.new(0, 0, 0)
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then vel = vel + cam.LookVector * PState.flySpeed * 50 end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then vel = vel - cam.LookVector * PState.flySpeed * 50 end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then vel = vel - cam.RightVector * PState.flySpeed * 50 end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then vel = vel + cam.RightVector * PState.flySpeed * 50 end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then vel = vel + Vector3.new(0, PState.flySpeed * 50, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then vel = vel - Vector3.new(0, PState.flySpeed * 50, 0) end
                pcall(function() PState.flyBV.VectorVelocity = vel end)
            end
            if PState.autoSprint and hum and char:FindFirstChild("RemoteFunction") then
                pcall(function()
                    local res = char.RemoteFunction:InvokeServer("ReturnSprint")
                    if res and res.IsSprinting ~= true then
                        char.RemoteFunction:InvokeServer("ToggleSprinting")
                    end
                end)
            end
        end
        task.wait(PState.autoSprint and 1 or 0.1)
    end
end)

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if not PState.infDash then return end
    local stats = LocalPlayer:FindFirstChild("PlayerStats")
    if not stats then return end
    local dashKey = stats:FindFirstChild("DashKey")
    if not dashKey then return end
    if input.KeyCode == Enum.KeyCode[dashKey.Value] then
        if tick() - PState.lastDash < PState.dashDelay then return end
        PState.lastDash = tick()
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local dir = 0
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = 90 end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = -90 end
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = 0 end
        pcall(function()
            local bv = Instance.new("BodyVelocity")
            bv.Velocity = (hrp.CFrame * CFrame.Angles(0, math.rad(dir), 0)).lookVector * PState.dashPower
            bv.MaxForce = Vector3.new(55555, 1000, 55555)
            bv.Parent = hrp
            game:GetService("Debris"):AddItem(bv, 0.25)
        end)
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    if PState.flyBV then PState.flyBV:Destroy() PState.flyBV = nil end
    if PState.flyAttach then PState.flyAttach:Destroy() PState.flyAttach = nil end
    if PState.fly then
        task.wait(1)
        local char = LocalPlayer.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                PState.flyAttach = Instance.new("Attachment")
                PState.flyAttach.Name = "VoidFlyAttach"
                PState.flyAttach.Parent = hrp
                PState.flyBV = Instance.new("LinearVelocity")
                PState.flyBV.Name = "VoidFlyBV"
                PState.flyBV.Attachment0 = PState.flyAttach
                PState.flyBV.MaxForce = 1e6
                PState.flyBV.VectorVelocity = Vector3.new(0, 0, 0)
                PState.flyBV.Parent = hrp
            end
        end
    end
end)

-- ============================================================
--  TELEPORTS TAB
-- ============================================================
local TpFrame = Instance.new("Frame")
TpFrame.Name = "Teleports"
TpFrame.Size = UDim2.new(1, -20, 1, -20)
TpFrame.Position = UDim2.new(0, 10, 0, 10)
TpFrame.BackgroundTransparency = 1
TpFrame.Visible = false
TpFrame.Parent = Content

local TpScroll = Instance.new("ScrollingFrame")
TpScroll.Size = UDim2.new(1, 0, 1, 0)
TpScroll.BackgroundTransparency = 1
TpScroll.BorderSizePixel = 0
TpScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
TpScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
TpScroll.ScrollBarThickness = 6
TpScroll.ScrollBarImageColor3 = THEME.accent
TpScroll.Parent = TpFrame

local TpLayout = Instance.new("UIListLayout")
TpLayout.SortOrder = Enum.SortOrder.LayoutOrder
TpLayout.Padding = UDim.new(0, 4)
TpLayout.Parent = TpScroll

local TpPadding = Instance.new("UIPadding")
TpPadding.PaddingTop = UDim.new(0, 4)
TpPadding.PaddingBottom = UDim.new(0, 4)
TpPadding.PaddingLeft = UDim.new(0, 4)
TpPadding.PaddingRight = UDim.new(0, 4)
TpPadding.Parent = TpScroll

local function makeTpBtn(parent, text, cf)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 26)
    btn.BackgroundColor3 = THEME.panel3
    btn.Text = text
    btn.TextColor3 = THEME.text
    btn.TextSize = 11
    btn.Font = Enum.Font.Gotham
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Parent = parent
    addCorner(btn, 5)
    addStroke(btn, THEME.strokeSoft, 1, 0.5)

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = THEME.panel2}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = THEME.panel3}):Play()
    end)

    btn.MouseButton1Click:Connect(function()
        local hrp = getHRP()
        if hrp then hrp.CFrame = cf end
    end)
    return btn
end

addSectionLabel(TpScroll, "PLACES")
for name, cf in pairs(ALL_TELEPORTS) do
    makeTpBtn(TpScroll, name, cf)
end

addSectionLabel(TpScroll, "NPCs")
for _, v in ipairs(Workspace:FindFirstChild("Living") and Workspace.Living:GetChildren() or {}) do
    if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") then
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 26)
        btn.BackgroundColor3 = THEME.panel3
        btn.Text = v.Name
        btn.TextColor3 = THEME.text
        btn.TextSize = 11
        btn.Font = Enum.Font.Gotham
        btn.BorderSizePixel = 0
        btn.AutoButtonColor = false
        btn.Parent = TpScroll
        addCorner(btn, 5)
        addStroke(btn, THEME.strokeSoft, 1, 0.5)
        local target = v
        btn.MouseButton1Click:Connect(function()
            local hrp = getHRP()
            if hrp and target and target.Parent then
                hrp.CFrame = target.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
            end
        end)
    end
end

-- ============================================================
--  MISC TAB
-- ============================================================
local MiscFrame = Instance.new("Frame")
MiscFrame.Name = "Misc"
MiscFrame.Size = UDim2.new(1, -20, 1, -20)
MiscFrame.Position = UDim2.new(0, 10, 0, 10)
MiscFrame.BackgroundTransparency = 1
MiscFrame.Visible = false
MiscFrame.Parent = Content

local MiscScroll = Instance.new("ScrollingFrame")
MiscScroll.Size = UDim2.new(1, 0, 1, 0)
MiscScroll.BackgroundTransparency = 1
MiscScroll.BorderSizePixel = 0
MiscScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
MiscScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
MiscScroll.ScrollBarThickness = 6
MiscScroll.ScrollBarImageColor3 = THEME.accent
MiscScroll.Parent = MiscFrame

local MiscLayout = Instance.new("UIListLayout")
MiscLayout.SortOrder = Enum.SortOrder.LayoutOrder
MiscLayout.Padding = UDim.new(0, 6)
MiscLayout.Parent = MiscScroll

local MiscPadding = Instance.new("UIPadding")
MiscPadding.PaddingTop = UDim.new(0, 4)
MiscPadding.PaddingBottom = UDim.new(0, 4)
MiscPadding.PaddingLeft = UDim.new(0, 4)
MiscPadding.PaddingRight = UDim.new(0, 4)
MiscPadding.Parent = MiscScroll

addSectionLabel(MiscScroll, "WORLD")
makeToggleBtn(MiscScroll, "No Fog", false, function(s)
    State.noFogEnabled = s
    if s then Lighting.FogStart = 1000000 else Lighting.FogStart = 15 end
end)
makeToggleBtn(MiscScroll, "Always Day", false, function(s)
    State.dayEnabled = s State.nightEnabled = false
end)
makeToggleBtn(MiscScroll, "Always Night", false, function(s)
    State.nightEnabled = s State.dayEnabled = false
end)

addSectionLabel(MiscScroll, "COMBAT")
makeToggleBtn(MiscScroll, "Anti Vamp Burn", false, function(s)
    State.antiVampEnabled = s
    if s then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("RemoteEvent") then
            pcall(function() char.RemoteEvent:FireServer("VampireBurnOff") end)
        end
    end
end)
makeToggleBtn(MiscScroll, "Anti Timestop", false, function(s) State.antiTSEnabled = s end)

addSectionLabel(MiscScroll, "PERFORMANCE")
makeToggleBtn(MiscScroll, "FPS Boost", false, function(s)
    State.fpsBoost = s
    if s then
        pcall(function()
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 9e9
            for _, v in ipairs(Lighting:GetChildren()) do
                if v:IsA("PostEffect") or v:IsA("Atmosphere") then v.Enabled = false end
            end
        end)
    end
end)

task.spawn(function()
    while ScreenGui.Parent do
        if State.noFogEnabled then pcall(function() Lighting.FogStart = 1000000 end) end
        if State.dayEnabled then pcall(function() Lighting.ClockTime = 12 end) end
        if State.nightEnabled then pcall(function() Lighting.ClockTime = 0 end) end
        if State.antiVampEnabled then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("RemoteEvent") then
                pcall(function() char.RemoteEvent:FireServer("VampireBurnOff") end)
            end
        end
        task.wait(1)
    end
end)

-- ============================================================
--  INFO TAB
-- ============================================================
local InfoTabFrame = Instance.new("Frame")
InfoTabFrame.Name = "InfoTab"
InfoTabFrame.Size = UDim2.new(1, -20, 1, -20)
InfoTabFrame.Position = UDim2.new(0, 10, 0, 10)
InfoTabFrame.BackgroundTransparency = 1
InfoTabFrame.Visible = false
InfoTabFrame.Parent = Content

local AvatarImage = Instance.new("ImageLabel")
AvatarImage.Size = UDim2.new(0, 96, 0, 96)
AvatarImage.Position = UDim2.new(0, 0, 0, 0)
AvatarImage.BackgroundColor3 = THEME.panel2
AvatarImage.BorderSizePixel = 0
AvatarImage.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. tostring(LocalPlayer.UserId) .. "&width=420&height=420&format=png"
AvatarImage.Parent = InfoTabFrame
addCorner(AvatarImage, 10)
addStroke(AvatarImage, THEME.accent, 2, 0.3)

local InfoTabText = Instance.new("TextLabel")
InfoTabText.Size = UDim2.new(1, -110, 0, 96)
InfoTabText.Position = UDim2.new(0, 110, 0, 0)
InfoTabText.BackgroundTransparency = 1
InfoTabText.TextColor3 = THEME.text
InfoTabText.TextSize = 13
InfoTabText.Font = Enum.Font.Gotham
InfoTabText.TextXAlignment = Enum.TextXAlignment.Left
InfoTabText.TextYAlignment = Enum.TextYAlignment.Top
InfoTabText.TextWrapped = true
InfoTabText.Text = ""
InfoTabText.Parent = InfoTabFrame

task.spawn(function()
    while ScreenGui.Parent do
        if InfoTabFrame.Visible then
            local time = os.date("%H:%M:%S %d/%m/%Y")
            InfoTabText.Text =
                "Nick: " .. LocalPlayer.Name ..
                "\nUser ID: " .. tostring(LocalPlayer.UserId) ..
                "\nUnique ID: " .. UNIQUE_ID ..
                "\n\nStand: " .. getStat("Stand") ..
                "\nLevel: " .. getStat("Level") ..
                "\nExperience: " .. getStat("Experience") ..
                "\nSpec: " .. (getStat("FightingStyle") ~= "—" and getStat("FightingStyle") or getStat("Spec")) ..
                "\nPrestige: " .. getStat("Prestige") ..
                "\nGang: " .. (getStat("Gang") ~= "—" and getStat("Gang") or "—") ..
                "\nMoney: " .. (getStat("Money") ~= "—" and getStat("Money") or getStat("Cash")) ..
                "\n\nPC Time: " .. time
        end
        task.wait(1)
    end
end)

-- ============================================================
--  ADMIN TAB (only for admin nicks)
-- ============================================================
local AdminFrame = Instance.new("Frame")
AdminFrame.Name = "Admin"
AdminFrame.Size = UDim2.new(1, -20, 1, -20)
AdminFrame.Position = UDim2.new(0, 10, 0, 10)
AdminFrame.BackgroundTransparency = 1
AdminFrame.Visible = false
AdminFrame.Parent = Content

local AdminLabel = Instance.new("TextLabel")
AdminLabel.Size = UDim2.new(1, 0, 0, 30)
AdminLabel.BackgroundTransparency = 1
AdminLabel.Text = "ADMIN PANEL"
AdminLabel.TextColor3 = THEME.accent
AdminLabel.TextSize = 18
AdminLabel.Font = Enum.Font.GothamBold
AdminLabel.TextXAlignment = Enum.TextXAlignment.Left
AdminLabel.Parent = AdminFrame

local AdminInfo = Instance.new("TextLabel")
AdminInfo.Size = UDim2.new(1, 0, 0, 200)
AdminInfo.Position = UDim2.new(0, 0, 0, 40)
AdminInfo.BackgroundColor3 = THEME.panel2
AdminInfo.BorderSizePixel = 0
AdminInfo.TextColor3 = THEME.text
AdminInfo.TextSize = 13
AdminInfo.Font = Enum.Font.Gotham
AdminInfo.TextXAlignment = Enum.TextXAlignment.Left
AdminInfo.TextYAlignment = Enum.TextYAlignment.Top
AdminInfo.Text = ""
AdminInfo.Parent = AdminFrame
addCorner(AdminInfo, 8)
addStroke(AdminInfo, THEME.strokeSoft, 1, 0.5)

local AdminPad = Instance.new("UIPadding")
AdminPad.PaddingTop = UDim.new(0, 10)
AdminPad.PaddingBottom = UDim.new(0, 10)
AdminPad.PaddingLeft = UDim.new(0, 10)
AdminPad.PaddingRight = UDim.new(0, 10)
AdminPad.Parent = AdminInfo

task.spawn(function()
    while ScreenGui.Parent do
        if AdminFrame.Visible then
            AdminInfo.Text =
                "Твой ник: " .. LocalPlayer.Name ..
                "\nТвой User ID: " .. tostring(LocalPlayer.UserId) ..
                "\nТвой Unique ID: " .. UNIQUE_ID ..
                "\n\nСкопируй Unique ID и используй в Python-панели для выдачи доступов." ..
                "\n\nУправление банами/доступами — через Python-приложение.\nКоманды: 1-9 в консоли."
        end
        task.wait(1)
    end
end)

-- ============================================================
--  REGISTER TABS
-- ============================================================
local ddBtn, ddLbl, ddInd = makeTabButton(Sidebar, "Diver Down", 8, function() showTab("dd") end)
local afBtn, afLbl, afInd = makeTabButton(Sidebar, "Autofarm", 44, function() showTab("af") end)
local plBtn, plLbl, plInd = makeTabButton(Sidebar, "Player", 80, function() showTab("pl") end)
local tpBtn, tpLbl, tpInd = makeTabButton(Sidebar, "Teleports", 116, function() showTab("tp") end)
local msBtn, msLbl, msInd = makeTabButton(Sidebar, "Misc", 152, function() showTab("ms") end)
local inBtn, inLbl, inInd = makeTabButton(Sidebar, "Info", 188, function() showTab("in") end)

registerTab("dd", ddBtn, ddLbl, ddInd, DDFrame)
registerTab("af", afBtn, afLbl, afInd, FarmFrame)
registerTab("pl", plBtn, plLbl, plInd, PlayerFrame)
registerTab("tp", tpBtn, tpLbl, tpInd, TpFrame)
registerTab("ms", msBtn, msLbl, msInd, MiscFrame)
registerTab("in", inBtn, inLbl, inInd, InfoTabFrame)

if ADMIN_NICKS[LocalPlayer.Name] then
    local adBtn, adLbl, adInd = makeTabButton(Sidebar, "Admin", 224, function() showTab("ad") end)
    registerTab("ad", adBtn, adLbl, adInd, AdminFrame)
end

showTab("dd")

-- ============================================================
--  DRAG / TOGGLE / STOP
-- ============================================================
local dragging, dragStart, startPos
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)
TopBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui.Enabled = false
end)

UserInputService.InputBegan:Connect(function(input, processed)
    if input.KeyCode == CONFIG.TOGGLE_KEY or input.KeyCode == CONFIG.TOGGLE_KEY_ALT then
        ScreenGui.Enabled = not ScreenGui.Enabled
        return
    end
    if input.KeyCode == CONFIG.STOP_KEY then
        stopAutoDiverDown()
        ScreenGui.Enabled = true
        return
    end
end)

task.spawn(function()
    while ScreenGui.Parent do
        updateInfo()
        task.wait(1)
    end
end)

ScreenGui.Enabled = true
setStatus("idle", THEME.subtext)
