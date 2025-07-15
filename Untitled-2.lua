local a=game:GetService("TeleportService")
local b=game:GetService("Players")
local c,d=game.PlaceId,5
local function e(f)
  local g=tonumber((tostring(f):lower():gsub("[%$,/]",""):match("%d+%.?%d*")))or 0
  local h=tostring(f):lower()
  if h:find("k")then return g*1e3
  elseif h:find("m")then return g*1e6 end
  return g
end
local i=b.LocalPlayer or b.PlayerAdded:Wait()
if not i.Character or not i.Character.Parent then i.CharacterAdded:Wait() end
local function j(k)
  local l,m={},{}
  k=k:lower()
  for _,n in ipairs(workspace:GetDescendants())do
    if n:IsA("BillboardGui")then
      for _,o in ipairs(n:GetDescendants())do
        if o:IsA("TextLabel")and o.Text:lower():find(k)then
          local p=n:FindFirstAncestorOfClass("Model")
          if p and not l[p]then l[p]=true; m[#m+1]=p end
          break
        end
      end
    end
  end
  return m
end
local function q(r)
  local l,m={},{}
  for _,n in ipairs(workspace:GetDescendants())do
    if n:IsA("BillboardGui")then
      for _,o in ipairs(n:GetDescendants())do
        if o:IsA("TextLabel")then
          local s=o.Text
          if s:match("^%$?%d+%.?%d*[KkMm]?$")and e(s)>=r then
            local p=n:FindFirstAncestorOfClass("Model")
            if p and not l[p]then l[p]=true; m[#m+1]=p end
          end
        end
        break
      end
    end
  end
  return m
end
local function t(u)
  local v=u.PrimaryPart or u:FindFirstChildWhichIsA("BasePart")
  if not v then return end
  local w=Instance.new("BoxHandleAdornment",v)
  w.Adornee=v; w.AlwaysOnTop=true; w.ZIndex=10; w.Transparency=0.1
  w.Size=v.Size+Vector3.new(2,2,2); w.Color3=Color3.fromRGB(255,0,0)
end
local function x(u)
  local y=i.Character or i.CharacterAdded:Wait()
  local z=y:FindFirstChild("Head")
  if not z then return end
  local v=u.PrimaryPart or u:FindFirstChildWhichIsA("BasePart")
  if not v then return end
  local A=z:FindFirstChild("TracerAttach")or Instance.new("Attachment",z)
  A.Name="TracerAttach"
  local B=v:FindFirstChild("TracerAttach")or Instance.new("Attachment",v)
  B.Name="TracerAttach"
  local C=Instance.new("Beam",workspace)
  C.Attachment0=A; C.Attachment1=B; C.FaceCamera=true; C.LightEmission=1
  C.Width0=0.2; C.Width1=0.2
  C.Color=ColorSequence.new(Color3.fromRGB(255,0,0))
end
local function D()
  local ok,err=pcall(function() a:Teleport(c,i) end)
  if not ok then warn(err) end
end
local function G()
  local H=Instance.new("ScreenGui",game.CoreGui)
  H.Name="TP_GUI"
  local I=Instance.new("TextButton",H)
  I.Size=UDim2.new(0,160,0,40)
  I.Position=UDim2.new(1,-170,1,-60)
  I.BackgroundColor3=Color3.fromRGB(0,140,255)
  I.Text="Trocar Servidor"
  I.TextColor3=Color3.new(1,1,1)
  I.Font=Enum.Font.GothamBold
  I.TextSize=14
  I.BorderSizePixel=0
  Instance.new("UICorner",I).CornerRadius=UDim.new(0,8)
  I.MouseButton1Click:Connect(D)
end
task.wait(d)
G()
local J=(SEARCH_MODE=="value" and q(e(SEARCH_QUERY)) or j(SEARCH_QUERY))
if #J>0 then
  for _,u in ipairs(J)do t(u); x(u) end
else
  D()
end
