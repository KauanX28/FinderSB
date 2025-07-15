-- Serviços
local TeleportService = game:GetService("TeleportService")
local Players         = game:GetService("Players")

-- ══════ Parâmetros fixos ══════
local PLACE_ID       = game.PlaceId
local INITIAL_DELAY  = 5     -- segundos para as GUIs carregarem
local IGNORE_RADIUS  = 30    -- stud de distância mínima para identificar (ajuste como quiser)

-- Aguarda LocalPlayer e Character
local player = Players.LocalPlayer or Players.PlayerAdded:Wait()
repeat task.wait() until player.Character and player.Character.Parent
local hrp = player.Character:WaitForChild("HumanoidRootPart", 5)

-- ══════ Auxiliar: converte "$2.5M", "400K", "10m" em número ══════
local function parseMoney(str)
    local s = tostring(str):lower():gsub("[%$,/]","")
    local num = tonumber(s:match("%d+%.?%d*")) or 0
    if s:find("k") then
        return num * 1e3
    elseif s:find("m") then
        return num * 1e6
    else
        return num
    end
end

-- ══════ 1) Busca por nome ou raridade (texto exato ou parcial) ══════
local function findByText(query)
    query = query:lower()
    local seen, results = {}, {}
    for _, gui in ipairs(workspace:GetDescendants()) do
        if gui:IsA("BillboardGui") then
            for _, lbl in ipairs(gui:GetDescendants()) do
                if lbl:IsA("TextLabel") and lbl.Text:lower():find(query) then
                    local mdl = gui:FindFirstAncestorOfClass("Model")
                    if mdl and not seen[mdl] then
                        seen[mdl] = true
                        table.insert(results, mdl)
                    end
                    break
                end
            end
        end
    end
    return results
end

-- ══════ 2) Busca por valor ≥ threshold ══════
local function findByValue(threshold)
    local seen, results = {}, {}
    for _, gui in ipairs(workspace:GetDescendants()) do
        if gui:IsA("BillboardGui") then
            for _, lbl in ipairs(gui:GetDescendants()) do
                if lbl:IsA("TextLabel") then
                    local txt = lbl.Text
                    if txt:match("^%$?%d+%.?%d*[KkMm]?$") then
                        local val = parseMoney(txt)
                        if val >= threshold then
                            local mdl = gui:FindFirstAncestorOfClass("Model")
                            if mdl and not seen[mdl] then
                                seen[mdl] = true
                                table.insert(results, mdl)
                            end
                        end
                    end
                    break
                end
            end
        end
    end
    return results
end

-- ══════ ESP reforçado ══════
local function createESP(model)
    local part = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
    if not part then return end
    local box = Instance.new("BoxHandleAdornment", part)
    box.Adornee      = part
    box.AlwaysOnTop  = true
    box.ZIndex       = 10
    box.Color3       = Color3.fromRGB(255,  0,  0)
    box.Transparency = 0.1
    box.Size         = part.Size + Vector3.new(2,2,2)
end

-- ══════ Tracer (linha) da cabeça ao modelo ══════
local function createTracer(model)
    local char = player.Character
    local head = char and char:FindFirstChild("Head")
    if not head then return end
    local part = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
    if not part then return end

    local att0 = head:FindFirstChild("TracerAttach") or Instance.new("Attachment", head)
    att0.Name = "TracerAttach"
    local att1 = part:FindFirstChild("TracerAttach") or Instance.new("Attachment", part)
    att1.Name = "TracerAttach"

    local beam = Instance.new("Beam", workspace)
    beam.Attachment0    = att0
    beam.Attachment1    = att1
    beam.FaceCamera     = true
    beam.LightEmission  = 1
    beam.Width0         = 0.2
    beam.Width1         = 0.2
    beam.Color          = ColorSequence.new(Color3.fromRGB(255, 0, 0))
end

-- ══════ Teleport para servidor aleatório ══════
local function hopServer()
    local ok, err = pcall(function()
        TeleportService:Teleport(PLACE_ID, player)
    end)
    if not ok then warn("Falha ao teleportar:", err) end
end

-- ══════ Botão manual “Trocar Servidor” ══════
local function createTeleportButton()
    local gui = Instance.new("ScreenGui", game.CoreGui)
    gui.Name = "TPButtonGUI"
    local btn = Instance.new("TextButton", gui)
    btn.Size             = UDim2.new(0,160,0,40)
    btn.Position         = UDim2.new(1,-170,1,-60)
    btn.BackgroundColor3 = Color3.fromRGB(0,140,255)
    btn.TextColor3       = Color3.new(1,1,1)
    btn.Font             = Enum.Font.GothamBold
    btn.TextSize         = 14
    btn.Text             = "Trocar Servidor"
    btn.BorderSizePixel  = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)
    btn.MouseButton1Click:Connect(hopServer)
end

-- ══════ Fluxo principal ══════
task.wait(INITIAL_DELAY)
createTeleportButton()

-- Carrega resultados conforme modo
local models = (SEARCH_MODE == "value")
    and findByValue(parseMoney(SEARCH_QUERY))
    or findByText(SEARCH_QUERY)

-- Filtra: ignora os muito próximos de você
if hrp then
    for i = #models, 1, -1 do
        local mdl = models[i]
        local part = mdl.PrimaryPart or mdl:FindFirstChildWhichIsA("BasePart")
        if part and (part.Position - hrp.Position).Magnitude <= IGNORE_RADIUS then
            table.remove(models, i)
        end
    end
end

-- Executa ESP/tracer ou troca de servidor
if #models > 0 then
    print(("✅ %d encontrados por %s='%s'"):format(#models, SEARCH_MODE, SEARCH_QUERY))
    for _, mdl in ipairs(models) do
        createESP(mdl)
        createTracer(mdl)
    end
else
    print(("❌ Nenhum resultado válido por %s='%s'. Indo para outro servidor…")
        :format(SEARCH_MODE, SEARCH_QUERY))
    hopServer()
end
