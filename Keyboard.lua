--[[
    Nexus-Lua: Mobile Touchscreen Keyboard UI
    Master's Request: Complete draggable keyboard with functional keys,
    minimize-to-circle feature, collapsible F-keys, and dark theme.
]]

-- Roblox Services
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService") -- Used for drag smoothing via RenderStepped

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
    KeySymbolBackground = Color3.fromRGB(45, 45, 45),
    KeyHoverBackground = Color3.fromRGB(75, 75, 75),
    KeyText = Color3.fromRGB(230, 230, 230),
    Border = Color3.fromRGB(15, 15, 15),
    Accent = Color3.fromRGB(0, 122, 204),
    CloseButton = Color3.fromRGB(200, 50, 50),
    CloseButtonHover = Color3.fromRGB(230, 80, 80),
    TitleBar = Color3.fromRGB(40, 40, 40),
}

-- Sizing and Layout Configuration
local BASE_KEY_WIDTH_UNIT = 32 -- Adjusted for better mobile fit
local KEY_HEIGHT = 40
local KEY_SPACING_VALUE = 4
local F_KEY_HEIGHT = 30
local TOP_BAR_HEIGHT = 30
local MINIMIZED_CIRCLE_SIZE = 45
local KEY_CORNER_RADIUS = UDim.new(0, 5)
local FRAME_CORNER_RADIUS = UDim.new(0, 8)
local BASE_FONT_SIZE = 16
local FONT = Enum.Font.GothamSemibold

local KEYBOARD_HORIZONTAL_PADDING = 8
local KEYBOARD_VERTICAL_PADDING = 8

-- Icon for minimized state
local KEYBOARD_ICON_ASSET = "rbxasset://textures/ui/Controls/Keyboard.png" -- Roblox's own keyboard icon

-- State variables
local fKeysVisible = true
local mainKeyboardFrame -- Forward declaration
local minimizedCircleButton -- Forward declaration
local lastKeyboardPosition = UDim2.new(0.5, -250, 0.5, -150) -- Default centered

-- Key definitions [display_text, value_for_event, width_factor, is_symbol_key]
local KEY_LAYOUT = {
    {
        {disp="`", val="`", w=1}, {disp="1", val="1", w=1}, {disp="2", val="2", w=1}, {disp="3", val="3", w=1},
        {disp="4", val="4", w=1}, {disp="5", val="5", w=1}, {disp="6", val="6", w=1}, {disp="7", val="7", w=1},
        {disp="8", val="8", w=1}, {disp="9", val="9", w=1}, {disp="0", val="0", w=1}, {disp="-", val="-", w=1},
        {disp="=", val="=", w=1}, {disp="Backspace", val="Backspace", w=2, symbol=true}
    },
    {
        {disp="Tab", val="Tab", w=1.5, symbol=true}, {disp="Q", val="Q", w=1}, {disp="W", val="W", w=1}, {disp="E", val="E", w=1},
        {disp="R", val="R", w=1}, {disp="T", val="T", w=1}, {disp="Y", val="Y", w=1}, {disp="U", val="U", w=1},
        {disp="I", val="I", w=1}, {disp="O", val="O", w=1}, {disp="P", val="P", w=1}, {disp="[", val="[", w=1},
        {disp="]", val="]", w=1}, {disp="\\", val="\\", w=1.5, symbol=true}
    },
    {
        {disp="Caps", val="Caps", w=1.7, symbol=true}, {disp="A", val="A", w=1}, {disp="S", val="S", w=1}, {disp="D", val="D", w=1},
        {disp="F", val="F", w=1}, {disp="G", val="G", w=1}, {disp="H", val="H", w=1}, {disp="J", val="J", w=1},
        {disp="K", val="K", w=1}, {disp="L", val="L", w=1}, {disp=";", val=";", w=1}, {disp="'", val="'", w=1},
        {disp="Enter", val="Enter", w=2.3, symbol=true}
    },
    {
        {disp="Shift", val="ShiftL", w=2.2, symbol=true}, {disp="Z", val="Z", w=1}, {disp="X", val="X", w=1}, {disp="C", val="C", w=1},
        {disp="V", val="V", w=1}, {disp="B", val="B", w=1}, {disp="N", val="N", w=1}, {disp="M", val="M", w=1},
        {disp=",", val=",", w=1}, {disp=".", val=".", w=1}, {disp="/", val="/", w=1}, {disp="Shift", val="ShiftR", w=2.2, symbol=true}
    },
    {
        {disp="Ctrl", val="CtrlL", w=1.5, symbol=true}, {disp="Alt", val="AltL", w=1.2, symbol=true},
        {disp=" ", val="Space", w=6.6, symbol=true}, -- Space key text is just a space
        {disp="Alt", val="AltR", w=1.2, symbol=true}, {disp="Ctrl", val="CtrlR", w=1.5, symbol=true}
    }
}

local F_KEY_LAYOUT = {
    {disp="F1", val="F1", w=1}, {disp="F2", val="F2", w=1}, {disp="F3", val="F3", w=1}, {disp="F4", val="F4", w=1},
    {disp="F5", val="F5", w=1}, {disp="F6", val="F6", w=1}, {disp="F7", val="F7", w=1}, {disp="F8", val="F8", w=1},
    {disp="F9", val="F9", w=1}, {disp="F10", val="F10", w=1}, {disp="F11", val="F11", w=1}, {disp="F12", val="F12", w=1}
}

-- Calculate Keyboard Width
local max_row_units = 0
local temp_layouts = {KEY_LAYOUT, {F_KEY_LAYOUT}} -- Combine for easier iteration
for _, layout_group in ipairs(temp_layouts) do
    for _, rowLayout in ipairs(layout_group) do
        local current_row_units = 0
        for _, keyData in ipairs(rowLayout) do
            current_row_units = current_row_units + keyData.w
        end
        if current_row_units > max_row_units then
            max_row_units = current_row_units
        end
    end
end

local max_keys_count_for_spacing = 0
for _, layout_group in ipairs(temp_layouts) do
    for _, rowLayoutData in ipairs(layout_group) do
        if #rowLayoutData > max_keys_count_for_spacing then
            max_keys_count_for_spacing = #rowLayoutData
        end
    end
end

local calculatedKeyboardContentWidth = (max_row_units * BASE_KEY_WIDTH_UNIT) + ((max_keys_count_for_spacing - 1) * KEY_SPACING_VALUE)
local TOTAL_KEYBOARD_WIDTH = calculatedKeyboardContentWidth + (2 * KEYBOARD_HORIZONTAL_PADDING)


-- Make GUI Draggable Function
local function makeDraggable(guiObject, dragHandle)
    dragHandle = dragHandle or guiObject
    local dragging = false
    local dragInput = nil
    local dragStart = nil
    local startPosition = nil
    local lastMousePos = nil

    local rsConnection
    
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPosition = guiObject.Position
            lastMousePos = input.Position

            if rsConnection then rsConnection:Disconnect() end -- Disconnect previous if any
            rsConnection = RunService.RenderStepped:Connect(function()
                if dragging and lastMousePos then
                    local delta = UserInputService:GetMouseLocation() - dragStart -- Use GetMouseLocation for current pos
                     guiObject.Position = UDim2.new(
                        startPosition.X.Scale,
                        startPosition.X.Offset + delta.X,
                        startPosition.Y.Scale,
                        startPosition.Y.Offset + delta.Y
                    )
                end
            end)
            
            -- Old input.Changed connection, sometimes less smooth for dragging
            -- input.Changed:Connect(function() 
            --     if input.UserInputState == Enum.UserInputState.End then
            --         dragging = false
            --         if rsConnection then rsConnection:Disconnect(); rsConnection = nil; end
            --     end
            -- end)
        end
    end)

    -- Use UserInputService.InputChanged for tracking mouse movement when dragging
    -- This is primarily to update lastMousePos if needed, actual movement is in RenderStepped
    -- UserInputService.InputChanged:Connect(function(input)
    --     if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
    --         lastMousePos = input.Position 
    --     end
    -- end)
    
    dragHandle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            if rsConnection then rsConnection:Disconnect(); rsConnection = nil; end
            lastMousePos = nil
        end
    end)
end


-- Key Press Callback
local function onKeyPress(keyValue, keyDisplay)
    print("Nexus-Lua Keyboard: Key pressed - Value: " .. keyValue .. ", Display: " .. keyDisplay)
    -- Implement Shift/Caps logic here if needed in future
    -- Implement typing into focused TextBox if needed (advanced)
end

-- Create Individual Key Function
local function createKey(parentRow, keyData, keyHeight, currentBaseKeyWidthUnit, onKeyPressFn)
    local keyButton = Instance.new("TextButton")
    keyButton.Name = "Key_" .. keyData.val
    keyButton.Text = keyData.disp
    keyButton.Font = FONT
    keyButton.TextSize = BASE_FONT_SIZE
    if keyData.disp == " " then -- Special handling for spacebar text size if needed
        keyButton.TextSize = BASE_FONT_SIZE * 0.8 -- Make spacebar "text" (if any) smaller
    elseif string.len(keyData.disp) > 1 then -- like "Shift", "Enter"
         keyButton.TextSize = BASE_FONT_SIZE * 0.8
    end

    keyButton.TextColor3 = THEME.KeyText
    keyButton.BackgroundColor3 = keyData.symbol and THEME.KeySymbolBackground or THEME.KeyBackground
    
    -- Calculate actual width for this specific key based on its width factor and the base unit
    local keyActualWidth = (currentBaseKeyWidthUnit * keyData.w)
    keyButton.Size = UDim2.new(0, keyActualWidth, 0, keyHeight)
    
    keyButton.AutoButtonColor = false
    keyButton.Parent = parentRow

    local corner = Instance.new("UICorner")
    corner.CornerRadius = KEY_CORNER_RADIUS
    corner.Parent = keyButton

    keyButton.MouseEnter:Connect(function()
        keyButton.BackgroundColor3 = THEME.KeyHoverBackground
    end)
    keyButton.MouseLeave:Connect(function()
        keyButton.BackgroundColor3 = keyData.symbol and THEME.KeySymbolBackground or THEME.KeyBackground
    end)

    keyButton.MouseButton1Click:Connect(function()
        onKeyPressFn(keyData.val, keyData.disp)
        keyButton.BackgroundColor3 = THEME.Accent
        task.wait(0.1)
        keyButton.BackgroundColor3 = keyData.symbol and THEME.KeySymbolBackground or THEME.KeyBackground
    end)
    return keyButton
end


-- Main Script Execution
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "NexusLuaKeyboardScreenGui"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true -- Use full screen area
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling -- Ensures it can overlay other Sibling GUIs

mainKeyboardFrame = Instance.new("Frame")
mainKeyboardFrame.Name = "MainKeyboardFrame"
mainKeyboardFrame.BackgroundColor3 = THEME.Background
mainKeyboardFrame.BorderColor3 = THEME.Border
mainKeyboardFrame.BorderSizePixel = 1
mainKeyboardFrame.Position = lastKeyboardPosition
mainKeyboardFrame.Size = UDim2.new(0, TOTAL_KEYBOARD_WIDTH, 0, 100) -- Initial Y, will be overridden by AutomaticSize
mainKeyboardFrame.AutomaticSize = Enum.AutomaticSize.Y -- Height will adjust based on content
mainKeyboardFrame.ClipsDescendants = true
mainKeyboardFrame.Parent = screenGui

local mainFrameCorner = Instance.new("UICorner")
mainFrameCorner.CornerRadius = FRAME_CORNER_RADIUS
mainFrameCorner.Parent = mainKeyboardFrame

local mainListLayout = Instance.new("UIListLayout")
mainListLayout.FillDirection = Enum.FillDirection.Vertical
mainListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
mainListLayout.SortOrder = Enum.SortOrder.LayoutOrder
mainListLayout.Padding = UDim.new(0, KEY_SPACING_VALUE)
mainListLayout.Parent = mainKeyboardFrame

local mainPadding = Instance.new("UIPadding")
mainPadding.PaddingTop = UDim.new(0, KEYBOARD_VERTICAL_PADDING)
mainPadding.PaddingBottom = UDim.new(0, KEYBOARD_VERTICAL_PADDING)
mainPadding.PaddingLeft = UDim.new(0, KEYBOARD_HORIZONTAL_PADDING)
mainPadding.PaddingRight = UDim.new(0, KEYBOARD_HORIZONTAL_PADDING)
mainPadding.Parent = mainKeyboardFrame

-- Top Bar (for dragging, title, and buttons)
local topBar = Instance.new("Frame")
topBar.Name = "TopBar"
topBar.Size = UDim2.new(1, 0, 0, TOP_BAR_HEIGHT)
topBar.BackgroundColor3 = THEME.TitleBar
topBar.LayoutOrder = 1
topBar.Parent = mainKeyboardFrame

makeDraggable(mainKeyboardFrame, topBar) -- Make the entire keyboard draggable by its top bar

local topBarListLayout = Instance.new("UIListLayout")
topBarListLayout.FillDirection = Enum.FillDirection.Horizontal
topBarListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
topBarListLayout.SortOrder = Enum.SortOrder.LayoutOrder
topBarListLayout.Padding = UDim.new(0, 5)
topBarListLayout.Parent = topBar

local topBarPadding = Instance.new("UIPadding")
topBarPadding.PaddingLeft = UDim.new(0,5)
topBarPadding.PaddingRight = UDim.new(0,5)
topBarPadding.Parent = topBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(0.4, 0, 1, 0) -- Takes up some space
titleLabel.Text = "Mobile Keyboard"
titleLabel.Font = FONT
titleLabel.TextSize = BASE_FONT_SIZE * 0.9
titleLabel.TextColor3 = THEME.KeyText
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.BackgroundTransparency = 1
titleLabel.LayoutOrder = 1
titleLabel.Parent = topBar

local fKeysToggleButton = Instance.new("TextButton")
fKeysToggleButton.Name = "FKeysToggle"
fKeysToggleButton.Size = UDim2.new(0.3, 0, 0.8, 0)
fKeysToggleButton.Text = (fKeysVisible and "▲ Hide F-Keys" or "▼ Show F-Keys")
fKeysToggleButton.Font = FONT
fKeysToggleButton.TextSize = BASE_FONT_SIZE * 0.8
fKeysToggleButton.TextColor3 = THEME.KeyText
fKeysToggleButton.BackgroundColor3 = THEME.KeySymbolBackground
local fToggleCorner = Instance.new("UICorner"); fToggleCorner.CornerRadius = KEY_CORNER_RADIUS; fToggleCorner.Parent = fKeysToggleButton
fKeysToggleButton.LayoutOrder = 2
fKeysToggleButton.Parent = topBar

local minimizeButton = Instance.new("TextButton")
minimizeButton.Name = "MinimizeButton"
minimizeButton.Size = UDim2.new(0, TOP_BAR_HEIGHT * 0.8, 0, TOP_BAR_HEIGHT * 0.8)
minimizeButton.Text = "X"
minimizeButton.Font = FONT
minimizeButton.TextSize = BASE_FONT_SIZE
minimizeButton.TextColor3 = THEME.KeyText
minimizeButton.BackgroundColor3 = THEME.CloseButton
local minBtnCorner = Instance.new("UICorner"); minBtnCorner.CornerRadius = UDim.new(1,0); minBtnCorner.Parent = minimizeButton -- Make it circular
minimizeButton.LayoutOrder = 3
minimizeButton.ZIndex = 2
minimizeButton.Parent = topBar

-- Spacer to push minimize button to the right
local spacer = Instance.new("Frame")
spacer.Name = "Spacer"
spacer.Size = UDim2.new(1, - (titleLabel.AbsoluteSize.X + fKeysToggleButton.AbsoluteSize.X + minimizeButton.AbsoluteSize.X + 20), 0, 1) -- Fill remaining space
spacer.BackgroundTransparency = 1
spacer.LayoutOrder = 2 -- Between title/fkey and minimize
spacer.Parent = topBar
-- Dynamic spacer adjustment
local function updateSpacer()
    local usedWidth = titleLabel.AbsoluteSize.X + fKeysToggleButton.AbsoluteSize.X + minimizeButton.AbsoluteSize.X + (topBarListLayout.Padding.Offset * 2) + (topBarPadding.PaddingLeft.Offset + topBarPadding.PaddingRight.Offset)
    spacer.Size = UDim2.new(0, topBar.AbsoluteSize.X - usedWidth - 15 , 1, 0) -- -15 for safety margin
end
RunService.RenderStepped:Connect(updateSpacer) -- Or use :GetPropertyChangedSignal("AbsoluteSize") on topBar


-- F-Keys Row Container
local fKeyRowContainerFrame = Instance.new("Frame")
fKeyRowContainerFrame.Name = "FKeyRowContainer"
fKeyRowContainerFrame.BackgroundTransparency = 1
fKeyRowContainerFrame.AutomaticSize = Enum.AutomaticSize.XY
fKeyRowContainerFrame.LayoutOrder = 2
fKeyRowContainerFrame.Visible = fKeysVisible
fKeyRowContainerFrame.Parent = mainKeyboardFrame

local fKeyRowLayout = Instance.new("UIListLayout")
fKeyRowLayout.FillDirection = Enum.FillDirection.Horizontal
fKeyRowLayout.VerticalAlignment = Enum.VerticalAlignment.Center
fKeyRowLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
fKeyRowLayout.SortOrder = Enum.SortOrder.LayoutOrder
fKeyRowLayout.Padding = UDim.new(0, KEY_SPACING_VALUE)
fKeyRowLayout.Parent = fKeyRowContainerFrame

for _, keyData in ipairs(F_KEY_LAYOUT) do
    createKey(fKeyRowContainerFrame, keyData, F_KEY_HEIGHT, BASE_KEY_WIDTH_UNIT, onKeyPress)
end

-- Main Keys Container
local mainKeysContainerFrame = Instance.new("Frame")
mainKeysContainerFrame.Name = "MainKeysContainer"
mainKeysContainerFrame.BackgroundTransparency = 1
mainKeysContainerFrame.AutomaticSize = Enum.AutomaticSize.XY
mainKeysContainerFrame.LayoutOrder = 3
mainKeysContainerFrame.Parent = mainKeyboardFrame

local mainKeysListLayout = Instance.new("UIListLayout")
mainKeysListLayout.FillDirection = Enum.FillDirection.Vertical
mainKeysListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
mainKeysListLayout.SortOrder = Enum.SortOrder.LayoutOrder
mainKeysListLayout.Padding = UDim.new(0, KEY_SPACING_VALUE)
mainKeysListLayout.Parent = mainKeysContainerFrame

for _, rowLayoutData in ipairs(KEY_LAYOUT) do
    local keyRowFrame = Instance.new("Frame")
    keyRowFrame.Name = "KeyRow"
    keyRowFrame.BackgroundTransparency = 1
    keyRowFrame.AutomaticSize = Enum.AutomaticSize.XY
    keyRowFrame.Parent = mainKeysContainerFrame

    local keyRowListLayout = Instance.new("UIListLayout")
    keyRowListLayout.FillDirection = Enum.FillDirection.Horizontal
    keyRowListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    keyRowListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    keyRowListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    keyRowListLayout.Padding = UDim.new(0, KEY_SPACING_VALUE)
    keyRowListLayout.Parent = keyRowFrame

    for _, keyData in ipairs(rowLayoutData) do
        createKey(keyRowFrame, keyData, KEY_HEIGHT, BASE_KEY_WIDTH_UNIT, onKeyPress)
    end
end

-- Minimized Circle Button
minimizedCircleButton = Instance.new("ImageButton")
minimizedCircleButton.Name = "MinimizedKeyboardCircle"
minimizedCircleButton.Size = UDim2.new(0, MINIMIZED_CIRCLE_SIZE, 0, MINIMIZED_CIRCLE_SIZE)
minimizedCircleButton.Position = UDim2.new(0, 10, 0.5, -MINIMIZED_CIRCLE_SIZE / 2) -- Default position if keyboard never moved
minimizedCircleButton.BackgroundColor3 = THEME.Accent
minimizedCircleButton.Image = KEYBOARD_ICON_ASSET
minimizedCircleButton.ImageColor3 = THEME.KeyText
minimizedCircleButton.ScaleType = Enum.ScaleType.Fit -- Or Slice for 9-slice if icon supports
minimizedCircleButton.Visible = false
minimizedCircleButton.ZIndex = 100 -- Ensure it's on top when visible
minimizedCircleButton.Parent = screenGui

local circleCorner = Instance.new("UICorner")
circleCorner.CornerRadius = UDim.new(1, 0) -- Perfect circle
circleCorner.Parent = minimizedCircleButton

makeDraggable(minimizedCircleButton)

-- Toggle F-Keys Functionality
fKeysToggleButton.MouseButton1Click:Connect(function()
    fKeysVisible = not fKeysVisible
    fKeyRowContainerFrame.Visible = fKeysVisible
    fKeysToggleButton.Text = (fKeysVisible and "▲ Hide F-Keys" or "▼ Show F-Keys")
end)

-- Minimize/Restore Functionality
minimizeButton.MouseButton1Click:Connect(function()
    lastKeyboardPosition = mainKeyboardFrame.Position -- Save position
    mainKeyboardFrame.Visible = false
    minimizedCircleButton.Position = UDim2.new(0, mainKeyboardFrame.AbsolutePosition.X, 0, mainKeyboardFrame.AbsolutePosition.Y) -- Appear where keyboard was
    minimizedCircleButton.Visible = true
end)

minimizedCircleButton.MouseButton1Click:Connect(function()
    minimizedCircleButton.Visible = false
    mainKeyboardFrame.Position = lastKeyboardPosition -- Restore position
    mainKeyboardFrame.Visible = true
end)

-- Parent ScreenGui to the determined UI Environment last
screenGui.Parent = HUI_ENVIRONMENT

print("Nexus-Lua: Mobile Keyboard UI Initialized.")

-- Cleanup function (optional, if user wants to manually remove it)
-- function DestroyKeyboard()
--     if screenGui then screenGui:Destroy() end
--     print("Nexus-Lua: Mobile Keyboard UI Destroyed.")
-- end
-- Example: To destroy, call DestroyKeyboard()
