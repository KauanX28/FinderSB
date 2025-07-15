-- loader_obf.lua (versão corrigida: busca por valor varrendo até achar o label numérico)
local a=game:GetService("TeleportService")
local b=game:GetService("Players")
local c,d=game.PlaceId,5

-- parseMoney minificado
local function e(f)
  local g=tonumber((tostring(f):lower():gsub("[%$,/]",""):match("%d+%.?%d*"))) or 0
  local h=tostring(f):lower()
  if h:find("k") then return g*1e3
  elseif h:find("m") then return g*1e6 end
  return g
end

-- espera LocalPlayer e Character
local f=b.LocalPlayer or b.PlayerAdded:Wait()
if not f.Character or not f.Character.Parent then f.CharacterAdded:Wait() end

-- busca por texto (raridade/nome)
local function g(h)
  local i,j={},{}
  h=h:lower()
  for _,k in ipairs(workspace:GetDescendants()) do
    if k:IsA("BillboardGui") then
      for _,l in ipairs(k:GetDescendants()) do
        if l:IsA("TextLabel") then
          local m=l.Text:lower()
          if m:find(h) then
            local n=k:FindFirstAncestorOfClass("Model")
            if n and not i[n] then i[n]=true; j[#j+1]=n end
          end
          break
        end
      end
    end
  end
  return j
end

-- busca por valor ≥ threshold (corrigido)
local function h(th)
  local seen,out={},{}
  for _,k in ipairs(workspace:GetDescendants()) do
    if k:IsA("BillboardGui") then
      for _,l in ipairs(k:GetDescendants()) do
        if l:IsA("TextLabel") then
          local txt=l.Text
          if txt:match("^%$?%d+%.?%d*[KkMm]?$") then
            local v=e(txt)
            if v>=th then
              local mdl=k:FindFirstAncestorOfClass("Model")
              if mdl and not seen[mdl] then seen[mdl]=true; out[#out+1]=mdl end
            end
            break  -- sai do loop interno só depois de achar o label numérico
          end
        end
      end
    end
  end
  return out
end

-- ESP reforçado
local function i(mdl)
  local part=mdl.PrimaryPart or mdl:FindFirstChildWhichIsA("BasePart")
  if not part then return end
  local box=Instance.new("BoxHandleAdornment",part)
  box.Adornee=part; box.AlwaysOnTop=true; box.ZIndex=10; box.Transparency=0.1
  box.Size=part.Size+Vector3.new(2,2,2); box.Color3=Color3.fromRGB(255,0,0)
end

-- Tracer da cabeça
local function j(mdl)
  local ch=f.Character or f.CharacterAdded:Wait()
  local head=ch:FindFirstChild("Head")
  if not head then return end
  local part=mdl.PrimaryPart or mdl:FindFirstChildWhichIsA("BasePart")
  if not part then return end
  local a0=head:FindFirstChild("TracerAttach")or Instance.new("Attachment",head)
  a0.Name="TracerAttach"
  local a1=part:FindFirstChild("TracerAttach")or Instance.new("Attachment",part)
  a1.Name="TracerAttach"
  local beam=Instance.new("Beam",workspace)
  beam.Attachment0,beam.Attachment1=a0,a1; beam.FaceCamera=true; beam.LightEmission=1
  beam.Width0,beam.Width1=0.2,0.2; beam.Color=ColorSequence.new(Color3.fromRGB(255,0,0))
end

-- teleport/restart
local function k()
  local ok,err=pcall(function() a:Teleport(c,f) end)
  if not ok then warn(err) end
end

-- botão manual “Trocar Servidor”
local function l()
  local gui=Instance.new("ScreenGui",game.CoreGui); gui.Name="TP_GUI"
  local btn=Instance.new("TextButton",gui)
  btn.Size=UDim2.new(0,160,0,40); btn.Position=UDim2.new(1,-170,1,-60)
  btn.BackgroundColor3=Color3.fromRGB(0,140,255); btn.Text="Trocar Servidor"
  btn.TextColor3=Color3.new(1,1,1); btn.Font=Enum.Font.GothamBold
  btn.TextSize=14; btn.BorderSizePixel=0
  Instance.new("UICorner",btn).CornerRadius=UDim.new(0,8)
  btn.MouseButton1Click:Connect(k)
end

-- fluxo principal
task.wait(d)
l()
local res=(SEARCH_MODE=="value" and h(e(SEARCH_QUERY))) or g(SEARCH_QUERY)
if #res>0 then
  for _,mdl in ipairs(res) do
    i(mdl); j(mdl)
  end
else
  k()
end
