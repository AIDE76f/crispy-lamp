local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "EasyExplorer"
local success, _ = pcall(function() ScreenGui.Parent = CoreGui end)
if not success then ScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui") end

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MainFrame.Position = UDim2.new(0.2, 0, 0.2, 0)
MainFrame.Size = UDim2.new(0, 550, 0, 400)
MainFrame.Active = true
MainFrame.Draggable = true

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

-- الشريط العلوي
local TopBar = Instance.new("Frame")
TopBar.Parent = MainFrame
TopBar.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
TopBar.Size = UDim2.new(1, 0, 0, 60)
local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 8)
TopCorner.Parent = TopBar

local PathLabel = Instance.new("TextLabel")
PathLabel.Parent = TopBar
PathLabel.BackgroundTransparency = 1
PathLabel.Position = UDim2.new(0, 50, 0, 0)
PathLabel.Size = UDim2.new(1, -60, 0, 30)
PathLabel.Font = Enum.Font.GothamSemibold
PathLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
PathLabel.TextSize = 14
PathLabel.TextXAlignment = Enum.TextXAlignment.Left

-- أزرار التحكم العلوية
local BackBtn = Instance.new("TextButton")
BackBtn.Parent = TopBar
BackBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
BackBtn.Position = UDim2.new(0, 5, 0, 5)
BackBtn.Size = UDim2.new(0, 35, 0, 25)
BackBtn.Font = Enum.Font.GothamBold
BackBtn.Text = "رجوع"
BackBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
BackBtn.TextSize = 12

local WorkBtn = Instance.new("TextButton")
WorkBtn.Parent = TopBar
WorkBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 200)
WorkBtn.Position = UDim2.new(0, 5, 0, 35)
WorkBtn.Size = UDim2.new(0, 80, 0, 20)
WorkBtn.Font = Enum.Font.Gotham
WorkBtn.Text = "Workspace"
WorkBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
WorkBtn.TextSize = 12

local RepBtn = Instance.new("TextButton")
RepBtn.Parent = TopBar
RepBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 150)
RepBtn.Position = UDim2.new(0, 90, 0, 35)
RepBtn.Size = UDim2.new(0, 120, 0, 20)
RepBtn.Font = Enum.Font.Gotham
RepBtn.Text = "ReplicatedStorage"
RepBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RepBtn.TextSize = 12

-- القوائم
local ItemList = Instance.new("ScrollingFrame")
ItemList.Parent = MainFrame
ItemList.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
ItemList.Position = UDim2.new(0, 10, 0, 70)
ItemList.Size = UDim2.new(0.55, -15, 1, -80)
ItemList.ScrollBarThickness = 6
local ListLayout = Instance.new("UIListLayout")
ListLayout.Parent = ItemList
ListLayout.Padding = UDim.new(0, 4)
ListLayout.SortOrder = Enum.SortOrder.Name

local InfoFrame = Instance.new("ScrollingFrame")
InfoFrame.Parent = MainFrame
InfoFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
InfoFrame.Position = UDim2.new(0.55, 5, 0, 70)
InfoFrame.Size = UDim2.new(0.45, -15, 1, -80)
InfoFrame.ScrollBarThickness = 6
local InfoLayout = Instance.new("UIListLayout")
InfoLayout.Parent = InfoFrame
InfoLayout.Padding = UDim.new(0, 5)

-----------------------------------
-- المنطق الأساسي
-----------------------------------
local CurrentNode = workspace

local function addInfoText(text, color)
    local lbl = Instance.new("TextLabel")
    lbl.Parent = InfoFrame
    lbl.BackgroundTransparency = 1
    lbl.Size = UDim2.new(1, -10, 0, 20)
    lbl.Position = UDim2.new(0, 5, 0, 0)
    lbl.Font = Enum.Font.Gotham
    lbl.Text = text
    lbl.TextColor3 = color or Color3.fromRGB(255, 255, 255)
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextWrapped = true
end

local function updateInfo(item)
    for _, child in pairs(InfoFrame:GetChildren()) do
        if child:IsA("TextLabel") then child:Destroy() end
    end
    
    addInfoText("📌 Name: " .. item.Name, Color3.fromRGB(100, 200, 255))
    addInfoText("🏷️ Class: " .. item.ClassName, Color3.fromRGB(200, 200, 100))
    
    pcall(function()
        if item.Value ~= nil then
            addInfoText("💰 Value: " .. tostring(item.Value), Color3.fromRGB(150, 255, 150))
        end
    end)
    
    addInfoText("--- Attributes ---", Color3.fromRGB(150, 150, 150))
    local hasAttributes = false
    pcall(function()
        for k, v in pairs(item:GetAttributes()) do
            addInfoText(k .. ": " .. tostring(v), Color3.fromRGB(255, 150, 150))
            hasAttributes = true
        end
    end)
    if not hasAttributes then addInfoText("لا توجد Attributes", Color3.fromRGB(100, 100, 100)) end
end

local function refreshView()
    for _, child in pairs(ItemList:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    
    PathLabel.Text = CurrentNode:GetFullName()
    local yOffset = 0
    local success, children = pcall(function() return CurrentNode:GetChildren() end)
    
    if success and children then
        for _, child in pairs(children) do
            local itemRow = Instance.new("Frame")
            itemRow.Parent = ItemList
            itemRow.BackgroundTransparency = 1
            itemRow.Size = UDim2.new(1, 0, 0, 30)
            
            -- زر قراءة المعلومات ( ℹ️ )
            local InfoBtn = Instance.new("TextButton")
            InfoBtn.Parent = itemRow
            InfoBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
            InfoBtn.Size = UDim2.new(0.8, -5, 1, 0)
            InfoBtn.Font = Enum.Font.Gotham
            InfoBtn.Text = ((child:IsA("Folder") or child:IsA("Model")) and "📁 " or "📄 ") .. child.Name
            InfoBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
            InfoBtn.TextSize = 12
            InfoBtn.TextXAlignment = Enum.TextXAlignment.Left
            
            InfoBtn.MouseButton1Click:Connect(function() updateInfo(child) end)
            
            -- زر فتح المجلد ( ➡️ )
            if child:IsA("Folder") or child:IsA("Model") or child:IsA("ReplicatedStorage") then
                local OpenBtn = Instance.new("TextButton")
                OpenBtn.Parent = itemRow
                OpenBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
                OpenBtn.Position = UDim2.new(0.8, 0, 0, 0)
                OpenBtn.Size = UDim2.new(0.2, 0, 1, 0)
                OpenBtn.Font = Enum.Font.GothamBold
                OpenBtn.Text = "➡️"
                OpenBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                OpenBtn.TextSize = 14
                
                OpenBtn.MouseButton1Click:Connect(function()
                    CurrentNode = child
                    refreshView()
                end)
            end
            
            yOffset = yOffset + 34
        end
    end
    ItemList.CanvasSize = UDim2.new(0, 0, 0, yOffset)
end

-- أزرار التنقل الأساسية
BackBtn.MouseButton1Click:Connect(function()
    if CurrentNode.Parent and CurrentNode ~= game then
        CurrentNode = CurrentNode.Parent
        refreshView()
    end
end)

WorkBtn.MouseButton1Click:Connect(function() CurrentNode = workspace; refreshView() end)
RepBtn.MouseButton1Click:Connect(function() CurrentNode = game:GetService("ReplicatedStorage"); refreshView() end)

refreshView()
