-- MM2 Role-Aware Silent Aim + ESP | Delta Safe | Create By Max
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LP = Players.LocalPlayer

if _G.MaxSilentAimLoaded then
    pcall(function() if _G.MaxGui then _G.MaxGui:Destroy() end end)
end
_G.MaxSilentAimLoaded = true

local CONFIG = {
    Enabled = true,
    EspRoles = true,
    EspWeapons = true,
    MaxDistance = 100,
    InnocentDisabled = true,
    AimPart = "HumanoidRootPart",
}

local roleHighlights, roleBillboards, weaponEsp = {}, {}, {}

local function clearRoleEsp()
    for _, obj in pairs(roleHighlights) do if obj then obj:Destroy() end end
    for _, obj in pairs(roleBillboards) do if obj then obj:Destroy() end end
    roleHighlights, roleBillboards = {}, {}
end

local function clearWeaponEsp()
    for _, data in pairs(weaponEsp) do
        if data.hl then data.hl:Destroy() end
        if data.bb then data.bb:Destroy() end
    end
    weaponEsp = {}
end

-- ============ UI ============
local gui = Instance.new("ScreenGui")
gui.Name = "MaxSilentAim"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = LP:WaitForChild("PlayerGui")
_G.MaxGui = gui

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 280, 0, 440)
main.Position = UDim2.new(0.5, -140, 0.5, -220)
main.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
main.BorderSizePixel = 0
main.ClipsDescendants = true
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(60, 60, 80)
stroke.Thickness = 1
stroke.Transparency = 0.3
stroke.Parent = main

local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 40)
topBar.BackgroundTransparency = 1
topBar.Parent = main

local accentDot = Instance.new("Frame")
accentDot.Size = UDim2.new(0, 6, 0, 6)
accentDot.Position = UDim2.new(0, 8, 0.5, -3)
accentDot.BackgroundColor3 = Color3.fromRGB(120, 90, 255)
accentDot.BorderSizePixel = 0
accentDot.Parent = topBar
Instance.new("UICorner", accentDot).CornerRadius = UDim.new(1, 0)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -90, 1, 0)
title.Position = UDim2.new(0, 22, 0, 0)
title.BackgroundTransparency = 1
title.Text = "MM2  •  SILENT AIM"
title.TextColor3 = Color3.fromRGB(235, 235, 245)
title.Font = Enum.Font.GothamBold
title.TextSize = 13
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = topBar

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 26, 0, 26)
minBtn.Position = UDim2.new(1, -60, 0.5, -13)
minBtn.BackgroundColor3 = Color3.fromRGB(32, 32, 44)
minBtn.Text = "—"
minBtn.TextColor3 = Color3.fromRGB(200, 200, 215)
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 14
minBtn.BorderSizePixel = 0
minBtn.Parent = topBar
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 6)

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 26, 0, 26)
closeBtn.Position = UDim2.new(1, -32, 0.5, -13)
closeBtn.BackgroundColor3 = Color3.fromRGB(40, 24, 28)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 120, 130)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 12
closeBtn.BorderSizePixel = 0
closeBtn.Parent = topBar
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)

local body = Instance.new("Frame")
body.Size = UDim2.new(1, 0, 1, -40)
body.Position = UDim2.new(0, 0, 0, 40)
body.BackgroundTransparency = 1
body.Parent = main

local function makeToggle(y, labelText, initialState, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -24, 0, 32)
    row.Position = UDim2.new(0, 12, 0, y)
    row.BackgroundTransparency = 1
    row.Parent = body

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -50, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextColor3 = Color3.fromRGB(190, 190, 205)
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 40, 0, 20)
    btn.Position = UDim2.new(1, -40, 0.5, -10)
    btn.BackgroundColor3 = Color3.fromRGB(48, 48, 60)
    btn.Text = ""
    btn.BorderSizePixel = 0
    btn.Parent = row
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = UDim2.new(0, 3, 0.5, -7)
    knob.BackgroundColor3 = Color3.fromRGB(245, 245, 250)
    knob.BorderSizePixel = 0
    knob.Parent = btn
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local state = initialState
    local function render()
        local info = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        TweenService:Create(btn, info, {BackgroundColor3 = state and Color3.fromRGB(120,90,255) or Color3.fromRGB(48,48,60)}):Play()
        TweenService:Create(knob, info, {Position = state and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,3,0.5,-7)}):Play()
    end
    render()

    btn.MouseButton1Click:Connect(function()
        state = not state
        render()
        callback(state)
    end)
end

makeToggle(8, "Silent Aim", CONFIG.Enabled, function(v) CONFIG.Enabled = v end)
makeToggle(42, "ESP Roles", CONFIG.EspRoles, function(v) CONFIG.EspRoles = v; if not v then clearRoleEsp() end end)
makeToggle(76, "ESP Weapon Dropped", CONFIG.EspWeapons, function(v) CONFIG.EspWeapons = v; if not v then clearWeaponEsp() end end)

-- Slider
local distRow = Instance.new("Frame")
distRow.Size = UDim2.new(1, -24, 0, 20)
distRow.Position = UDim2.new(0, 12, 0, 118)
distRow.BackgroundTransparency = 1
distRow.Parent = body

local distLbl = Instance.new("TextLabel")
distLbl.Size = UDim2.new(1, -50, 1, 0)
distLbl.BackgroundTransparency = 1
distLbl.Text = "Distância Máx (studs)"
distLbl.TextColor3 = Color3.fromRGB(190, 190, 205)
distLbl.Font = Enum.Font.GothamMedium
distLbl.TextSize = 12
distLbl.TextXAlignment = Enum.TextXAlignment.Left
distLbl.Parent = distRow

local distVal = Instance.new("TextLabel")
distVal.Size = UDim2.new(0, 40, 1, 0)
distVal.Position = UDim2.new(1, -40, 0, 0)
distVal.BackgroundTransparency = 1
distVal.Text = tostring(CONFIG.MaxDistance)
distVal.TextColor3 = Color3.fromRGB(120, 90, 255)
distVal.Font = Enum.Font.GothamBold
distVal.TextSize = 12
distVal.TextXAlignment = Enum.TextXAlignment.Right
distVal.Parent = distRow

local sliderBg = Instance.new("Frame")
sliderBg.Size = UDim2.new(1, -24, 0, 4)
sliderBg.Position = UDim2.new(0, 12, 0, 148)
sliderBg.BackgroundColor3 = Color3.fromRGB(40, 40, 54)
sliderBg.BorderSizePixel = 0
sliderBg.Parent = body
Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(1, 0)

local sliderFill = Instance.new("Frame")
sliderFill.Size = UDim2.new(CONFIG.MaxDistance / 300, 0, 1, 0)
sliderFill.BackgroundColor3 = Color3.fromRGB(120, 90, 255)
sliderFill.BorderSizePixel = 0
sliderFill.Parent = sliderBg
Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(1, 0)

local sliderKnob = Instance.new("Frame")
sliderKnob.Size = UDim2.new(0, 10, 0, 10)
sliderKnob.Position = UDim2.new(CONFIG.MaxDistance / 300, -5, 0.5, -5)
sliderKnob.BackgroundColor3 = Color3.fromRGB(245, 245, 250)
sliderKnob.BorderSizePixel = 0
sliderKnob.Parent = sliderBg
Instance.new("UICorner", sliderKnob).CornerRadius = UDim.new(1, 0)

local draggingSlider = false
local function updateSlider(input)
    local rel = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
    CONFIG.MaxDistance = math.floor(rel * 300)
    sliderFill.Size = UDim2.new(rel, 0, 1, 0)
    sliderKnob.Position = UDim2.new(rel, -5, 0.5, -5)
    distVal.Text = tostring(CONFIG.MaxDistance)
end
sliderBg.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        draggingSlider = true; updateSlider(i)
    end
end)
UIS.InputChanged:Connect(function(i)
    if draggingSlider and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        updateSlider(i)
    end
end)
UIS.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        draggingSlider = false
    end
end)

-- Regras e Créditos
local roleTitle = Instance.new("TextLabel")
roleTitle.Size = UDim2.new(1, -24, 0, 20)
roleTitle.Position = UDim2.new(0, 12, 0, 168)
roleTitle.BackgroundTransparency = 1
roleTitle.Text = "REGRA POR PAPEL"
roleTitle.TextColor3 = Color3.fromRGB(110, 110, 130)
roleTitle.Font = Enum.Font.GothamBold
roleTitle.TextSize = 9
roleTitle.TextXAlignment = Enum.TextXAlignment.Left
roleTitle.Parent = body

local function makeRoleRow(y, labelText, state)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -24, 0, 26)
    row.Position = UDim2.new(0, 12, 0, y)
    row.BackgroundTransparency = 1
    row.Parent = body
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -90, 1, 0)
    l.BackgroundTransparency = 1
    l.Text = labelText
    l.TextColor3 = Color3.fromRGB(190, 190, 205)
    l.Font = Enum.Font.GothamMedium
    l.TextSize = 12
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = row
    local s = Instance.new("TextLabel")
    s.Size = UDim2.new(0, 90, 1, 0)
    s.Position = UDim2.new(1, -90, 0, 0)
    s.BackgroundTransparency = 1
    s.Text = state
    s.TextColor3 = Color3.fromRGB(120, 90, 255)
    s.Font = Enum.Font.GothamMedium
    s.TextSize = 11
    s.TextXAlignment = Enum.TextXAlignment.Right
    s.Parent = row
end

makeRoleRow(192, "Sheriff", "→ Murderer")
makeRoleRow(220, "Murderer", "→ Mais próximo")
makeRoleRow(248, "Innocent", "→ Desligado")

local credits = Instance.new("TextLabel")
credits.Size = UDim2.new(1, -24, 0, 20)
credits.Position = UDim2.new(0, 12, 1, -28)
credits.BackgroundTransparency = 1
credits.Text = "Create By Max"
credits.TextColor3 = Color3.fromRGB(130, 110, 255)
credits.Font = Enum.Font.GothamBold
credits.TextSize = 11
credits.TextXAlignment = Enum.TextXAlignment.Center
credits.Parent = body

-- DRAG DO MENU
local dragging, dragStart, startPos
topBar.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = i.Position; startPos = main.Position
    end
end)

-- BOLINHA
local bubble = Instance.new("Frame")
bubble.Name = "MaxBubble"
bubble.Size = UDim2.new(0, 50, 0, 50)
bubble.Position = UDim2.new(0.5, -25, 0.5, -25)
bubble.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
bubble.BorderSizePixel = 0
bubble.Visible = false
bubble.ClipsDescendants = true
bubble.Parent = gui
Instance.new("UICorner", bubble).CornerRadius = UDim.new(1, 0)

local bubbleStroke = Instance.new("UIStroke")
bubbleStroke.Color = Color3.fromRGB(180, 180, 180)
bubbleStroke.Thickness = 2
bubbleStroke.Parent = bubble

local bubbleImg = Instance.new("ImageLabel")
bubbleImg.Size = UDim2.new(1, 0, 1, 0)
bubbleImg.BackgroundTransparency = 1
bubbleImg.ScaleType = Enum.ScaleType.Crop
bubbleImg.Image = "rbxassetid://110245160930288"
bubbleImg.Parent = bubble

local bubbleBtn = Instance.new("TextButton")
bubbleBtn.Size = UDim2.new(1, 0, 1, 0)
bubbleBtn.BackgroundTransparency = 1
bubbleBtn.Text = ""
bubbleBtn.Parent = bubble

-- DRAG DA BOLINHA
local bubbleDragging, bubbleStart, bubbleStartPos
bubble.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        bubbleDragging = true; bubbleStart = i.Position; bubbleStartPos = bubble.Position
    end
end)

UIS.InputChanged:Connect(function(i)
    if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local delta = i.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    elseif bubbleDragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local delta = i.Position - bubbleStart
        bubble.Position = UDim2.new(bubbleStartPos.X.Scale, bubbleStartPos.X.Offset + delta.X, bubbleStartPos.Y.Scale, bubbleStartPos.Y.Offset + delta.Y)
    end
end)

UIS.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then 
        dragging = false; bubbleDragging = false
    end
end)

-- AÇÕES DE MINIMIZAR E REABRIR
closeBtn.MouseButton1Click:Connect(function()
    main.Visible = false
    bubble.Visible = true
end)

bubbleBtn.MouseButton1Click:Connect(function()
    bubble.Visible = false
    main.Visible = true
end)

-- ============ LÓGICA DE ROLE ============
local function getRole(player)
    local char = player.Character
    if not char then return "Innocent" end
    for _, obj in ipairs(char:GetChildren()) do
        local n = obj.Name:lower()
        if n:find("sheriff") then return "Sheriff" end
        if n:find("murder") then return "Murderer" end
    end
    if player.Team then
        local t = player.Team.Name:lower()
        if t:find("murder") then return "Murderer" end
        if t:find("sheriff") then return "Sheriff" end
    end
    return "Innocent"
end

local function alive(p)
    return p and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0
end

-- ============ SILENT AIM ============
local function getMurderer()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and alive(p) and getRole(p) == "Murderer" then return p end
    end
end

local function getClosest()
    local myChar = LP.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return nil end
    local myPos = myChar.HumanoidRootPart.Position
    local best, bestDist = nil, CONFIG.MaxDistance
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and alive(p) then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local d = (hrp.Position - myPos).Magnitude
                if d < bestDist then best, bestDist = p, d end
            end
        end
    end
    return best
end

local function pickTarget()
    local role = getRole(LP)
    if role == "Sheriff" then return getMurderer()
    elseif role == "Murderer" then return getClosest()
    else
        if CONFIG.InnocentDisabled then return nil end
        return getClosest()
    end
end

local function getAimPart(p)
    if not p or not p.Character then return nil end
    return p.Character:FindFirstChild(CONFIG.AimPart) or p.Character:FindFirstChild("Head")
end

task.spawn(function()
    task.wait(3)
    local function hookAll()
        for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
            if obj:IsA("RemoteEvent") then
                local n = obj.Name:lower()
                if n:find("shoot") or n:find("hit") or n:find("gun") or n:find("knife") then
                    local oldFire = obj.FireServer
                    obj.FireServer = function(self, ...)
                        if CONFIG.Enabled then
                            local t = pickTarget()
                            local part = getAimPart(t)
                            if part then
                                local args = {...}
                                table.insert(args, part)
                                return oldFire(self, unpack(args))
                            end
                        end
                        return oldFire(self, ...)
                    end
                end
            end
        end
    end
    pcall(hookAll)
end)

-- ============ ESP ROLES ============
local roleColors = {
    Sheriff  = Color3.fromRGB(80, 160, 255),
    Murderer = Color3.fromRGB(255, 70, 80),
    Innocent = Color3.fromRGB(80, 255, 80),
}

local function applyRoleEsp(p)
    if not p or p == LP or not p.Character then return end
    local role = getRole(p)
    local color = roleColors[role] or roleColors.Innocent
    local char = p.Character
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local hl = roleHighlights[p]
    if not hl or not hl.Parent then
        hl = Instance.new("Highlight")
        hl.Name = "MaxRoleHL"
        hl.FillColor = color
        hl.FillTransparency = 0.5
        hl.OutlineColor = color
        hl.OutlineTransparency = 0.1
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Parent = char
        roleHighlights[p] = hl
    else
        hl.FillColor = color
        hl.OutlineColor = color
    end

    local bb = roleBillboards[p]
    if not bb or not bb.Parent then
        bb = Instance.new("BillboardGui")
        bb.Name = "MaxRoleBB"
        bb.Size = UDim2.new(0, 120, 0, 32)
        bb.StudsOffset = Vector3.new(0, 2.4, 0)
        bb.AlwaysOnTop = true
        bb.Parent = char

        local nameLbl = Instance.new("TextLabel")
        nameLbl.Size = UDim2.new(1, 0, 0.55, 0)
        nameLbl.BackgroundTransparency = 1
        nameLbl.Text = p.Name
        nameLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLbl.Font = Enum.Font.GothamBold
        nameLbl.TextSize = 12
        nameLbl.TextStrokeTransparency = 0.4
        nameLbl.Parent = bb

        local roleLbl = Instance.new("TextLabel")
        roleLbl.Size = UDim2.new(1, 0, 0.45, 0)
        roleLbl.Position = UDim2.new(0, 0, 0.55, 0)
        roleLbl.BackgroundTransparency = 1
        roleLbl.Text = role
        roleLbl.TextColor3 = color
        roleLbl.Font = Enum.Font.GothamMedium
        roleLbl.TextSize = 10
        roleLbl.TextStrokeTransparency = 0.5
        roleLbl.Parent = bb

        roleBillboards[p] = bb
    else
        for _, c in ipairs(bb:GetChildren()) do
            if c:IsA("TextLabel") and c.Text ~= p.Name then
                c.Text = role
                c.TextColor3 = color
            end
        end
    end
end

local function refreshRoleEsp()
    if not CONFIG.EspRoles then clearRoleEsp(); return end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and alive(p) then
            applyRoleEsp(p)
        else
            if roleHighlights[p] then roleHighlights[p]:Destroy(); roleHighlights[p] = nil end
            if roleBillboards[p] then roleBillboards[p]:Destroy(); roleBillboards[p] = nil end
        end
    end
end

-- ============ ESP WEAPON DROPPED ============
local validWeapons = {
    ["knife"] = true, ["gun"] = true, ["revolver"] = true,
    ["pistol"] = true, ["stuckknife"] = true,
    ["droppedknife"] = true, ["droppedgun"] = true,
}
local ignoreKeywords = { "display", "spawn", "decor", "shop", "crate", "wall", "inventory", "gui" }

local function isWeapon(inst)
    if not inst or not inst:IsA("BasePart") then return false end
    local n = inst.Name:lower()
    for _, k in ipairs(ignoreKeywords) do
        if n:find(k) then return false end
    end
    return validWeapons[n] or false
end

local function applyWeaponEsp(part)
    if weaponEsp[part] and weaponEsp[part].hl and weaponEsp[part].hl.Parent then return end

    local hl = Instance.new("Highlight")
    hl.Name = "MaxWeaponHL"
    hl.FillColor = Color3.fromRGB(255, 255, 0)
    hl.FillTransparency = 0.5
    hl.OutlineColor = Color3.fromRGB(255, 255, 0)
    hl.OutlineTransparency = 0.1
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent = part

    local bb = Instance.new("BillboardGui")
    bb.Name = "MaxWeaponBB"
    bb.Size = UDim2.new(0, 100, 0, 24)
    bb.StudsOffset = Vector3.new(0, 1.2, 0)
    bb.AlwaysOnTop = true
    bb.Parent = part

    local lbl = Instance.new("TextLabel")
   
