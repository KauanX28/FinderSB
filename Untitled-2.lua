-- loader_obf.lua (versão corrigida: busca por valor agora funciona)
local a=game:GetService("TeleportService")
local b=game:GetService("Players")
local c,d=game.PlaceId,5

-- parseMoney ofuscado
local function e(f)
  local g=tonumber((tostring(f):lower():gsub("[%$,/]",""):match("%d+%.?%d*"))) or 0
  local h=tostring(f):lower()
  if h:find("k") then return g*1e3
  elseif h:find("m") then return g*1e6
  else return g end
end

-- espera LocalPlayer e Character
local i=b.LocalPlayer or b.PlayerAdded:Wait()
if not i.Character or not i.Character.Parent then i.CharacterAdded:Wait() end

-- busca por texto (raridade/nome)
local function j(k)
  local t,u={},{}
  k=k:lower()
  for _,v in ipairs(workspace:GetDescendants()) do
    if v:IsA("BillboardGui") then
      for _,w in ipairs(v:GetDescendants()) do
        if w:IsA("TextLabel") then
          local x=w.Text:lower()
          if x:find(k) then
            local y=v:FindFirstAncestorOfClass("Model")
            if y and not t[y] then t[y]=true; u[#u+1]=y end
          end
          break  -- para após o primeiro TextLabel
        end
      end
    end
  end
  return u
end

-- busca por valor ≥ threshold
local function q(r)
  local t,u={},{}
  for _,v in ipairs(workspace:GetDescendants()) do
    if v:IsA("BillboardGui") then
      for _,w in ipairs(v:GetDescendants()) do
        if w:IsA("TextLabel") then
          local x=w.Text
          if x:match("^%$?%d+%.?%d*[KkMm]?$") and e(x)>=r then
            local y=v:FindFirstAncestorOfClass("Model")
            if y and not t[y] then t[y]=true; u[#u+1]=y end
          end
          break  -- **fix**: só quebra depois de processar o primeiro TextLabel
        end
      end
    end
  end
  return u
end

-- ESP reforçado
local function r(m)
  local p=m.PrimaryPart or m:FindFirstChildWhichIsA("BasePart")
  if not p then return end
  local o=Instance.new("BoxHandleAdornment",p)
  o.Adornee, o.AlwaysOnTop = p, true
  o.ZIndex, o.Transparency = 10, 0.1
  o.Size = p.Size + Vector3.new(2,2,2)
  o.Color3 = Color3.fromRGB(255,0,0)
end

-- Tracer da cabeça
local function s(m)
  local ch=i.Character or i.CharacterAdded:Wait()
  local hd=ch:FindFirstChild("Head")
  if not hd then return end
  local p=m.PrimaryPart or m:FindFirstChildWhichIsA("BasePart")
  if not p then return end

  local a0=hd:FindFirstChild("TracerAttach") or Instance.new("Attachment",hd)
  a0.Name="TracerAttach"
  local a1=p:FindFirstChild("TracerAttach") or Instance.new("Attachment",p)
  a1.Name="TracerAttach"

  local b0=Instance.new("Beam",workspace)
  b0.Attachment0, b0.Attachment1 = a0, a1
  b0.FaceCamera, b0.LightEmission = true, 1
  b0.Width0, b0.Width1 = 0.2, 0.2
  b0.Color = ColorSequence.new(Color3.fromRGB(255,0,0))
end

-- teleport/se servidor
local function t() local ok,err=pcall(function() a:Teleport(c,i) end) if not ok then warn(err) end end

-- botão manual
local function u()
  local g=Instance.new("ScreenGui",game.CoreGui); g.Name="TP_GUI"
  local btn=Instance.new("TextButton",g)
  btn.Size=UDim2.new(0,160,0,40); btn.Position=UDim2.new(1,-170,1,-60)
  btn.BackgroundColor3=Color3.fromRGB(0,140,255); btn.Text="Trocar Servidor"
  btn.TextColor3=Color3.new(1,1,1); btn.Font=Enum.Font.GothamBold
  btn.TextSize=14; btn.BorderSizePixel=0
  Instance.new("UICorner",btn).CornerRadius=UDim.new(0,8)
  btn.MouseButton1Click:Connect(t)
end

-- fluxo principal
task.wait(d)
u()
local results = (SEARCH_MODE=="value" and q(e(SEARCH_QUERY))) or j(SEARCH_QUERY)
if #results>0 then
  for _,m in ipairs(results) do r(m); s(m) end
else
  t()
end
