--[[
    Nexus-Lua: Enhanced Mobile Touchscreen Keyboard UI (v1.1 - Error Fix)
    Master's Request: Complete draggable keyboard with truly functional keys
    for text input, Shift/Caps logic, text display, minimize-to-circle,
    collapsible F-keys, and dark theme.
    Fix: Added missing properties to F-Key definitions.
]]

-- Roblox Services
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Executor specific: gethui() or PlayerGui
local HUI_ENVIRONMENT
pcall(function() HUI_ENVIRONMENT = gethui and gethui() or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui") end)
if not HUI_ENVIRONMENT then
    warn("Nexus-Lua: Could not get a valid UI container. Script may not display.")
    return
end

-- Theme Configuration
local THEME = {
    Background = Color3.fromRGB(25, 25, 25),
    FrameBackground = Color3.fromRGB(35, 35, 35),
    KeyBackground = Color3.fromRGB(55, 55, 55),
    KeySymbolBackground = Color3.fromRGB(45, 45, 45), -- For special keys like Shift, Enter
    KeyHoverBackground = Color3.fromRGB(75, 75, 75),
    KeyText = Color3.fromRGB(230, 230, 230),
    Border = Color3.fromRGB(15, 15, 15),
    Accent = Color3.fromRGB(0, 122, 204), -- Used for active Shift/Caps
    CloseButton = Color3.fromRGB(200, 50, 50),
    TitleBar = Color3.fromRGB(40, 40, 40),
    TextDisplayBackground = Color3.fromRGB(30,30,30),
}

-- Sizing and Layout Configuration
local BASE_KEY_WIDTH_UNIT = 32
local KEY_HEIGHT = 40
local KEY_SPACING_VALUE = 4
local F_KEY_HEIGHT = 30
local TOP_BAR_HEIGHT = 30
local TEXT_DISPLAY_HEIGHT = 35
local MINIMIZED_CIRCLE_SIZE = 45
local KEY_CORNER_RADIUS = UDim.new(0, 5)
local FRAME_CORNER_RADIUS = UDim.new(0, 8)
local BASE_FONT_SIZE = 16
local FONT = Enum.Font.GothamSemibold

local KEYBOARD_HORIZONTAL_PADDING = 8
local KEYBOARD_VERTICAL_PADDING = 8

local KEYBOARD_ICON_ASSET = "rbxasset://textures/ui/Controls/Keyboard.png"

-- State variables
local fKeysVisible = true
local mainKeyboardFrame
local minimizedCircleButton
local lastKeyboardPosition = UDim2.new(0.5, -250, 0.5, -200)

local currentTextBuffer = ""
local isShiftActive = false
local isCapsActive = false

-- UI Element References
local textDisplayLabel = nil
local shiftLKeyButton, shiftRKeyButton, capsKeyButton = nil, nil, nil

-- Key definitions: {disp, val, ?shiftVal, w, ?isChar, ?isSpecialStyle}
local KEY_LAYOUT = {
    {
        {disp="~ `", val="`", shiftVal="~", w=1, isChar=true, isSpecialStyle=false}, {disp="! 1", val="1", shiftVal="!", w=1, isChar=true, isSpecialStyle=false},
        {disp="@ 2", val="2", shiftVal="@", w=1, isChar=true, isSpecialStyle=false}, {disp="# 3", val="3", shiftVal="#", w=1, isChar=true, isSpecialStyle=false},
        {disp="$ 4", val="4", shiftVal="$", w=1, isChar=true, isSpecialStyle=false}, {disp="% 5", val="5", shiftVal="%", w=1, isChar=true, isSpecialStyle=false},
        {disp="^ 6", val="6", shiftVal="^", w=1, isChar=true, isSpecialStyle=false}, {disp="& 7", val="7", shiftVal="&", w=1, isChar=true, isSpecialStyle=false},
        {disp="* 8", val="8", shiftVal="*", w=1, isChar=true, isSpecialStyle=false}, {disp="( 9", val="9", shiftVal="(", w=1, isChar=true, isSpecialStyle=false},
        {disp=") 0", val="0", shiftVal=")", w=1, isChar=true, isSpecialStyle=false}, {disp="_ -", val="-", shiftVal="_", w=1, isChar=true, isSpecialStyle=false},
        {disp="+ =", val="=", shiftVal="+", w=1, isChar=true, isSpecialStyle=false}, {disp="Backspace", val="Backspace", w=2, isChar=false, isSpecialStyle=true}
    },
    {
        {disp="Tab", val="Tab", w=1.5, isChar=false, isSpecialStyle=true}, {disp="Q", val="q", shiftVal="Q", w=1, isChar=true, isSpecialStyle=false},
        {disp="W", val="w", shiftVal="W", w=1, isChar=true, isSpecialStyle=false}, {disp="E", val="e", shiftVal="E", w=1, isChar=true, isSpecialStyle=false},
        {disp="R", val="r", shiftVal="R", w=1, isChar=true, isSpecialStyle=false}, {disp="T", val="t", shiftVal="T", w=1, isChar=true, isSpecialStyle=false},
        {disp="Y", val="y", shiftVal="Y", w=1, isChar=true, isSpecialStyle=false}, {disp="U", val="u", shiftVal="U", w=1, isChar=true, isSpecialStyle=false},
        {disp="I", val="i", shiftVal="I", w=1, isChar=true, isSpecialStyle=false}, {disp="O", val="o", shiftVal="O", w=1, isChar=true, isSpecialStyle=false},
        {disp="P", val="p", shiftVal="P", w=1, isChar=true, isSpecialStyle=false}, {disp="{ [", val="[", shiftVal="{", w=1, isChar=true, isSpecialStyle=false},
        {disp="} ]", val="]", shiftVal="}", w=1, isChar=true, isSpecialStyle=false}, {disp='| \\', val="\\", shiftVal="|", w=1.5, isChar=true, isSpecialStyle=true}
    },
    {
        {disp="Caps Lock", val="Caps", w=1.8, isChar=false, isSpecialStyle=true}, {disp="A", val="a", shiftVal="A", w=1, isChar=true, isSpecialStyle=false},
        {disp="S", val="s", shiftVal="S", w=1, isChar=true, isSpecialStyle=false}, {disp="D", val="d", shiftVal="D", w=1, isChar=true, isSpecialStyle=false},
        {disp="F", val="f", shiftVal="F", w=1, isChar=true, isSpecialStyle=false}, {disp="G", val="g", shiftVal="G", w=1, isChar=true, isSpecialStyle=false},
        {disp="H", val="h", shiftVal="H", w=1, isChar=true, isSpecialStyle=false}, {disp="J", val="j", shiftVal="J", w=1, isChar=true, isSpecialStyle=false},
        {disp="K", val="k", shiftVal="K", w=1, isChar=true, isSpecialStyle=false}, {disp="L", val="l", shiftVal="L", w=1, isChar=true, isSpecialStyle=false},
        {disp=': ;', val=";", shiftVal=":", w=1, isChar=true, isSpecialStyle=false}, {disp='" \'', val="'", shiftVal='"', w=1, isChar=true, isSpecialStyle=false},
        {disp="Enter", val="Enter", w=2.2, isChar=false, isSpecialStyle=true}
    },
    {
        {disp="Shift", val="ShiftL", w=2.3, isChar=false, isSpecialStyle=true}, {disp="Z", val="z", shiftVal="Z", w=1, isChar=true, isSpecialStyle=false},
        {disp="X", val="x", shiftVal="X", w=1, isChar=true, isSpecialStyle=false}, {disp="C", val="c", shiftVal="C", w=1, isChar=true, isSpecialStyle=false},
        {disp="V", val="v", shiftVal="V", w=1, isChar=true, isSpecialStyle=false}, {disp="B", val="b", shiftVal="B", w=1, isChar=true, isSpecialStyle=false},
        {disp="N", val="n", shiftVal="N", w=1, isChar=true, isSpecialStyle=false}, {disp="M", val="m", shiftVal="M", w=1, isChar=true, isSpecialStyle=false},
        {disp="< ,", val=",", shiftVal="<", w=1, isChar=true, isSpecialStyle=false}, {disp="> .", val=".", shiftVal=">", w=1, isChar=true, isSpecialStyle=false},
        {disp="? /", val="/", shiftVal="?", w=1, isChar=true, isSpecialStyle=false}, {disp="Shift", val="ShiftR", w=2.3, isChar=false, isSpecialStyle=true}
    },
    {
        {disp="Ctrl", val="CtrlL", w=1.5, isChar=false, isSpecialStyle=true}, {disp="Alt", val="AltL", w=1.2, isChar=false, isSpecialStyle=true},
        {disp="Space", val="Space", w=6.6, isChar=false, isSpecialStyle=true}, -- Spacebar is handled directly in onKeyPress
        {disp="Alt", val="AltR", w=1.2, isChar=false, isSpecialStyle=true}, {disp="Ctrl", val="CtrlR", w=1.5, isChar=false, isSpecialStyle=true}
    }
}
local F_KEY_LAYOUT = {
    {disp="F1", val="F1", w=1, isChar=false, isSpecialStyle=false}, {disp="F2", val="F2", w=1, isChar=false, isSpecialStyle=false},
    {disp="F3", val="F3", w=1, isChar=false, isSpecialStyle=false}, {disp="F4", val="F4", w=1, isChar=false, isSpecialStyle=false},
    {disp="F5", val="F5", w=1, isChar=false, isSpecialStyle=false}, {disp="F6", val="F6", w=1, isChar=false, isSpecialStyle=false},
    {disp="F7", val="F7", w=1, isChar=false, isSpecialStyle=false}, {disp="F8", val="F8", w=1, isChar=false, isSpecialStyle=false},
    {disp="F9", val="F9", w=1, isChar=false, isSpecialStyle=false}, {disp="F10", val="F10", w=1, isChar=false, isSpecialStyle=false},
    {disp="F11", val="F11", w=1, isChar=false, isSpecialStyle=false}, {disp="F12", val="F12", w=1, isChar=false, isSpecialStyle=false}
}

-- Calculate Keyboard Width
local max_row_units = 0; for _, r in ipairs(KEY_LAYOUT) do local u = 0; for _, k in ipairs(r) do u=u+k.w end; if u > max_row_units then max_row_units=u end end
local max_keys_count_for_spacing = 0; for _,r in ipairs(KEY_LAYOUT) do if #r > max_keys_count_for_spacing then max_keys_count_for_spacing=#r end end
local calculatedKeyboardContentWidth = (max_row_units * BASE_KEY_WIDTH_UNIT) + ((max_keys_count_for_spacing - 1) * KEY_SPACING_VALUE)
local TOTAL_KEYBOARD_WIDTH = calculatedKeyboardContentWidth + (2 * KEYBOARD_HORIZONTAL_PADDING)

-- Make GUI Draggable Function
local function makeDraggable(guiObject, dragHandle) dragHandle=dragHandle or guiObject; local d,di,ds,sp,lmp,rsc; dragHandle.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then d=true;di=i;ds=i.Position;sp=guiObject.Position;lmp=i.Position;if rsc then rsc:Disconnect()end;rsc=RunService.RenderStepped:Connect(function()if d and lmp then local dt=UserInputService:GetMouseLocation()-ds;guiObject.Position=UDim2.new(sp.X.Scale,sp.X.Offset+dt.X,sp.Y.Scale,sp.Y.Offset+dt.Y)end end)end end); dragHandle.InputEnded:Connect(function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then d=false;if rsc then rsc:Disconnect();rsc=nil end;lmp=nil end end) end

-- Update Text Display Function
local function updateTextDisplay() if textDisplayLabel then textDisplayLabel.Text = currentTextBuffer end end

-- Update Modifier Key Visuals
local function updateModifierKeyVisuals()
    local function setKeyAppearance(keyButton, isActive)
        if keyButton then
            keyButton.BackgroundColor3 = isActive and THEME.Accent or (keyButton.keyDataRef.isSpecialStyle and THEME.KeySymbolBackground or THEME.KeyBackground)
        end
    end
    setKeyAppearance(shiftLKeyButton, isShiftActive)
    setKeyAppearance(shiftRKeyButton, isShiftActive)
    setKeyAppearance(capsKeyButton, isCapsActive)
end

-- Key Press Callback Logic
local function onKeyPress(keyData)
    if keyData.isChar then
        local charToAppend
        if isShiftActive then
            charToAppend = keyData.shiftVal or string.upper(keyData.val)
        else
            charToAppend = keyData.val
        end
        if string.len(charToAppend) == 1 and string.match(string.lower(charToAppend), "%a") then
            if isCapsActive then charToAppend = (isShiftActive) and string.lower(charToAppend) or string.upper(charToAppend) end
        end
        currentTextBuffer = currentTextBuffer .. charToAppend
        if isShiftActive then isShiftActive = false; end
    elseif keyData.val == "Space" then
        currentTextBuffer = currentTextBuffer .. " "
        if isShiftActive then isShiftActive = false; end
    elseif keyData.val == "Backspace" then
        if string.len(currentTextBuffer) > 0 then currentTextBuffer = string.sub(currentTextBuffer, 1, -2) end
    elseif keyData.val == "Enter" then
        print("Nexus-Lua Keyboard Input: " .. currentTextBuffer)
        currentTextBuffer = ""
    elseif keyData.val == "Tab" then
        currentTextBuffer = currentTextBuffer .. "\t"
        if isShiftActive then isShiftActive = false; end
    elseif keyData.val == "ShiftL" or keyData.val == "ShiftR" then
        isShiftActive = not isShiftActive
    elseif keyData.val == "Caps" then
        isCapsActive = not isCapsActive
    elseif string.match(keyData.val, "Ctrl") or string.match(keyData.val, "Alt") or string.match(keyData.val, "F%d+") then
        print("Nexus-Lua Keyboard: Special key '" .. keyData.disp .. "' pressed.")
    else
        -- This case should ideally not be reached if all keys are handled
        print("Nexus-Lua Keyboard: Unhandled key - Value: " .. keyData.val .. ", Display: " .. keyData.disp)
    end
    updateTextDisplay()
    updateModifierKeyVisuals()
end

-- Create Individual Key Function
local function createKey(parentRow, keyData, keyHeight, currentBaseKeyWidthUnit)
    local keyButton = Instance.new("TextButton")
    keyButton.Name = "Key_" .. keyData.val
    keyButton.Text = keyData.disp
    keyButton.Font = FONT
    keyButton.keyDataRef = keyData -- Store reference to key data

    local baseTextSize = BASE_FONT_SIZE
    if string.len(keyData.disp) > 3 then baseTextSize = BASE_FONT_SIZE * 0.7 end
    if keyData.disp == "Space" then baseTextSize = BASE_FONT_SIZE * 0.8 end
    keyButton.TextSize = baseTextSize

    keyButton.TextColor3 = THEME.KeyText
    keyButton.BackgroundColor3 = keyData.isSpecialStyle and THEME.KeySymbolBackground or THEME.KeyBackground
    
    local keyActualWidth = (currentBaseKeyWidthUnit * keyData.w)
    keyButton.Size = UDim2.new(0, keyActualWidth, 0, keyHeight)
    
    keyButton.AutoButtonColor = false
    keyButton.Parent = parentRow

    local corner = Instance.new("UICorner"); corner.CornerRadius = KEY_CORNER_RADIUS; corner.Parent = keyButton

    keyButton.MouseEnter:Connect(function() if keyButton.BackgroundColor3 ~= THEME.Accent then keyButton.BackgroundColor3 = THEME.KeyHoverBackground end end)
    keyButton.MouseLeave:Connect(function() if keyButton.BackgroundColor3 ~= THEME.Accent then keyButton.BackgroundColor3 = keyData.isSpecialStyle and THEME.KeySymbolBackground or THEME.KeyBackground end end)

    keyButton.MouseButton1Click:Connect(function()
        onKeyPress(keyData)
        if not (keyData.val == "ShiftL" or keyData.val == "ShiftR" or keyData.val == "Caps") then
            local originalColor = keyButton.BackgroundColor3 -- Store current color (could be hover or default)
            keyButton.BackgroundColor3 = THEME.Accent
            task.wait(0.08)
            -- Check if it's a modifier key that might have its state changed by onKeyPress itself
            if keyButton == shiftLKeyButton or keyButton == shiftRKeyButton then
                keyButton.BackgroundColor3 = isShiftActive and THEME.Accent or (keyData.isSpecialStyle and THEME.KeySymbolBackground or THEME.KeyBackground)
            elseif keyButton == capsKeyButton then
                keyButton.BackgroundColor3 = isCapsActive and THEME.Accent or (keyData.isSpecialStyle and THEME.KeySymbolBackground or THEME.KeyBackground)
            else
                 keyButton.BackgroundColor3 = keyData.isSpecialStyle and THEME.KeySymbolBackground or THEME.KeyBackground -- Revert to non-hover default
            end
        end
    end)
    
    if keyData.val == "ShiftL" then shiftLKeyButton = keyButton end
    if keyData.val == "ShiftR" then shiftRKeyButton = keyButton end
    if keyData.val == "Caps" then capsKeyButton = keyButton end
    
    return keyButton
end

-- Main Script Execution (UI Setup - condensed for brevity, logic is the same)
local screenGui = Instance.new("ScreenGui"); screenGui.Name = "NexusLuaKeyboardScreenGui"; screenGui.ResetOnSpawn = false; screenGui.IgnoreGuiInset = true; screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
mainKeyboardFrame = Instance.new("Frame"); mainKeyboardFrame.Name = "MainKeyboardFrame"; mainKeyboardFrame.BackgroundColor3 = THEME.Background; mainKeyboardFrame.BorderColor3 = THEME.Border; mainKeyboardFrame.BorderSizePixel = 1; mainKeyboardFrame.Position = lastKeyboardPosition; mainKeyboardFrame.Size = UDim2.new(0, TOTAL_KEYBOARD_WIDTH, 0, 100); mainKeyboardFrame.AutomaticSize = Enum.AutomaticSize.Y; mainKeyboardFrame.ClipsDescendants = true; mainKeyboardFrame.Parent = screenGui;
Instance.new("UICorner", mainKeyboardFrame).CornerRadius = FRAME_CORNER_RADIUS;
local mainListLayout = Instance.new("UIListLayout", mainKeyboardFrame); mainListLayout.FillDirection = Enum.FillDirection.Vertical; mainListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center; mainListLayout.SortOrder = Enum.SortOrder.LayoutOrder; mainListLayout.Padding = UDim.new(0, KEY_SPACING_VALUE);
local mainPadding = Instance.new("UIPadding", mainKeyboardFrame); mainPadding.PaddingTop = UDim.new(0,KEYBOARD_VERTICAL_PADDING); mainPadding.PaddingBottom = UDim.new(0,KEYBOARD_VERTICAL_PADDING); mainPadding.PaddingLeft = UDim.new(0,KEYBOARD_HORIZONTAL_PADDING); mainPadding.PaddingRight = UDim.new(0,KEYBOARD_HORIZONTAL_PADDING);

local topBar = Instance.new("Frame", mainKeyboardFrame); topBar.Name = "TopBar"; topBar.Size = UDim2.new(1,0,0,TOP_BAR_HEIGHT); topBar.BackgroundColor3 = THEME.TitleBar; topBar.LayoutOrder = 1; makeDraggable(mainKeyboardFrame, topBar);
local topBarListLayout = Instance.new("UIListLayout",topBar); topBarListLayout.FillDirection=Enum.FillDirection.Horizontal; topBarListLayout.VerticalAlignment=Enum.VerticalAlignment.Center; topBarListLayout.SortOrder=Enum.SortOrder.LayoutOrder; topBarListLayout.Padding=UDim.new(0,5);
Instance.new("UIPadding", topBar).PaddingLeft = UDim.new(0,5); Instance.new("UIPadding", topBar).PaddingRight = UDim.new(0,5); -- This needs correction, should be one UIPadding
local titleLabel = Instance.new("TextLabel",topBar); titleLabel.Name="Title"; titleLabel.Size=UDim2.new(0.4,0,1,0); titleLabel.Text="Mobile Keyboard"; titleLabel.Font=FONT; titleLabel.TextSize=BASE_FONT_SIZE*0.9; titleLabel.TextColor3=THEME.KeyText; titleLabel.TextXAlignment=Enum.TextXAlignment.Left; titleLabel.BackgroundTransparency=1; titleLabel.LayoutOrder=1;
local fKeysToggleButton = Instance.new("TextButton",topBar); fKeysToggleButton.Name="FKeysToggle"; fKeysToggleButton.Size=UDim2.new(0.3,0,0.8,0); fKeysToggleButton.Text=(fKeysVisible and "▲ F-Keys" or "▼ F-Keys"); fKeysToggleButton.Font=FONT; fKeysToggleButton.TextSize=BASE_FONT_SIZE*0.8; fKeysToggleButton.TextColor3=THEME.KeyText; fKeysToggleButton.BackgroundColor3=THEME.KeySymbolBackground; Instance.new("UICorner",fKeysToggleButton).CornerRadius=KEY_CORNER_RADIUS; fKeysToggleButton.LayoutOrder=2;
local minimizeButton = Instance.new("TextButton",topBar); minimizeButton.Name="MinimizeButton"; minimizeButton.Size=UDim2.new(0,TOP_BAR_HEIGHT*0.8,0,TOP_BAR_HEIGHT*0.8); minimizeButton.Text="X"; minimizeButton.Font=FONT; minimizeButton.TextSize=BASE_FONT_SIZE; minimizeButton.TextColor3=THEME.KeyText; minimizeButton.BackgroundColor3=THEME.CloseButton; Instance.new("UICorner",minimizeButton).CornerRadius=UDim.new(1,0); minimizeButton.LayoutOrder=4; minimizeButton.ZIndex=2;
local spacer = Instance.new("Frame",topBar); spacer.Name="Spacer"; spacer.BackgroundTransparency=1; spacer.LayoutOrder=3; local function updateSpacer() local uw=titleLabel.AbsoluteSize.X+fKeysToggleButton.AbsoluteSize.X+minimizeButton.AbsoluteSize.X+(topBarListLayout.Padding.Offset*2)+(topBar.UIPadding.PaddingLeft.Offset+topBar.UIPadding.PaddingRight.Offset); spacer.Size=UDim2.new(0,topBar.AbsoluteSize.X-uw-15,1,0) end; RunService.RenderStepped:Connect(updateSpacer)
-- Corrected UIPadding for topBar
topBar:FindFirstChildOfClass("UIPadding"):Destroy() -- Remove potentially incorrect one
local topBarPaddingCorrected = Instance.new("UIPadding", topBar); topBarPaddingCorrected.PaddingLeft = UDim.new(0,5); topBarPaddingCorrected.PaddingRight = UDim.new(0,5);
-- Spacer update needs to refer to the correct padding object
RunService:Disconnect(RunService.RenderStepped, updateSpacer) -- Disconnect old spacer update
local function updateSpacerCorrected() local uw=titleLabel.AbsoluteSize.X+fKeysToggleButton.AbsoluteSize.X+minimizeButton.AbsoluteSize.X+(topBarListLayout.Padding.Offset*2)+(topBarPaddingCorrected.PaddingLeft.Offset+topBarPaddingCorrected.PaddingRight.Offset); spacer.Size=UDim2.new(0,topBar.AbsoluteSize.X-uw-15,1,0) end; RunService.RenderStepped:Connect(updateSpacerCorrected)


textDisplayLabel = Instance.new("TextLabel", mainKeyboardFrame); textDisplayLabel.Name = "TextDisplay"; textDisplayLabel.Size = UDim2.new(1,0,0,TEXT_DISPLAY_HEIGHT); textDisplayLabel.BackgroundColor3 = THEME.TextDisplayBackground; textDisplayLabel.BorderColor3 = THEME.Border; textDisplayLabel.BorderSizePixel = 1; textDisplayLabel.Font = FONT; textDisplayLabel.TextSize = BASE_FONT_SIZE*1.2; textDisplayLabel.TextColor3 = THEME.KeyText; textDisplayLabel.TextXAlignment = Enum.TextXAlignment.Left; textDisplayLabel.TextYAlignment = Enum.TextYAlignment.Center; textDisplayLabel.Text = ""; textDisplayLabel.LayoutOrder = 2; textDisplayLabel.ClipsDescendants = true;
Instance.new("UIPadding", textDisplayLabel).PaddingLeft = UDim.new(0,5); Instance.new("UIPadding", textDisplayLabel).PaddingRight = UDim.new(0,5);

local fKeyRowContainerFrame = Instance.new("Frame", mainKeyboardFrame); fKeyRowContainerFrame.Name = "FKeyRowContainer"; fKeyRowContainerFrame.BackgroundTransparency = 1; fKeyRowContainerFrame.AutomaticSize = Enum.AutomaticSize.XY; fKeyRowContainerFrame.LayoutOrder = 3; fKeyRowContainerFrame.Visible = fKeysVisible;
local fKeyRowLayout = Instance.new("UIListLayout", fKeyRowContainerFrame); fKeyRowLayout.FillDirection = Enum.FillDirection.Horizontal; fKeyRowLayout.VerticalAlignment = Enum.VerticalAlignment.Center; fKeyRowLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center; fKeyRowLayout.SortOrder = Enum.SortOrder.LayoutOrder; fKeyRowLayout.Padding = UDim.new(0, KEY_SPACING_VALUE);
for _, keyData in ipairs(F_KEY_LAYOUT) do createKey(fKeyRowContainerFrame, keyData, F_KEY_HEIGHT, BASE_KEY_WIDTH_UNIT) end

local mainKeysContainerFrame = Instance.new("Frame", mainKeyboardFrame); mainKeysContainerFrame.Name = "MainKeysContainer"; mainKeysContainerFrame.BackgroundTransparency = 1; mainKeysContainerFrame.AutomaticSize = Enum.AutomaticSize.XY; mainKeysContainerFrame.LayoutOrder = 4;
local mainKeysListLayout = Instance.new("UIListLayout", mainKeysContainerFrame); mainKeysListLayout.FillDirection = Enum.FillDirection.Vertical; mainKeysListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center; mainKeysListLayout.SortOrder = Enum.SortOrder.LayoutOrder; mainKeysListLayout.Padding = UDim.new(0, KEY_SPACING_VALUE);
for _, rowLayoutData in ipairs(KEY_LAYOUT) do local keyRowFrame = Instance.new("Frame", mainKeysContainerFrame); keyRowFrame.Name = "KeyRow"; keyRowFrame.BackgroundTransparency = 1; keyRowFrame.AutomaticSize = Enum.AutomaticSize.XY; local krl = Instance.new("UIListLayout",keyRowFrame); krl.FillDirection=Enum.FillDirection.Horizontal;krl.VerticalAlignment=Enum.VerticalAlignment.Center;krl.HorizontalAlignment=Enum.HorizontalAlignment.Center;krl.SortOrder=Enum.SortOrder.LayoutOrder;krl.Padding=UDim.new(0,KEY_SPACING_VALUE); for _, keyData in ipairs(rowLayoutData) do createKey(keyRowFrame, keyData, KEY_HEIGHT, BASE_KEY_WIDTH_UNIT) end end

minimizedCircleButton = Instance.new("ImageButton", screenGui); minimizedCircleButton.Name = "MinimizedKeyboardCircle"; minimizedCircleButton.Size = UDim2.new(0, MINIMIZED_CIRCLE_SIZE, 0, MINIMIZED_CIRCLE_SIZE); minimizedCircleButton.Position = UDim2.new(0, 10, 0.5, -MINIMIZED_CIRCLE_SIZE / 2); minimizedCircleButton.BackgroundColor3 = THEME.Accent; minimizedCircleButton.Image = KEYBOARD_ICON_ASSET; minimizedCircleButton.ImageColor3 = THEME.KeyText; minimizedCircleButton.ScaleType = Enum.ScaleType.Fit; minimizedCircleButton.Visible = false; minimizedCircleButton.ZIndex = 100;
Instance.new("UICorner", minimizedCircleButton).CornerRadius = UDim.new(1,0);
makeDraggable(minimizedCircleButton);

fKeysToggleButton.MouseButton1Click:Connect(function() fKeysVisible = not fKeysVisible; fKeyRowContainerFrame.Visible = fKeysVisible; fKeysToggleButton.Text = (fKeysVisible and "▲ F-Keys" or "▼ F-Keys") end)
minimizeButton.MouseButton1Click:Connect(function() lastKeyboardPosition = mainKeyboardFrame.Position; mainKeyboardFrame.Visible = false; minimizedCircleButton.Position = UDim2.new(0, mainKeyboardFrame.AbsolutePosition.X, 0, mainKeyboardFrame.AbsolutePosition.Y); minimizedCircleButton.Visible = true; end)
minimizedCircleButton.MouseButton1Click:Connect(function() minimizedCircleButton.Visible = false; mainKeyboardFrame.Position = lastKeyboardPosition; mainKeyboardFrame.Visible = true; end)

updateTextDisplay()
updateModifierKeyVisuals()

screenGui.Parent = HUI_ENVIRONMENT
print("Nexus-Lua: Enhanced Mobile Keyboard UI (v1.1) Initialized.")
