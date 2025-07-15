local A=game:GetService("RunService")
local B=workspace
if not game:IsLoaded() then game.Loaded:Wait() end;A.Heartbeat:Wait()
local C={}
local function D(q)
    local t={},s={}
    for _,g in ipairs(B:GetDescendants())do
        if g:IsA("BillboardGui")then
            for _,l in ipairs(g:GetDescendants())do
                if l:IsA("TextLabel") and l.Text:lower():find(q:lower())then
                    local m=g:FindFirstAncestorOfClass("Model")
                    if m and not s[m]then s[m]=true;table.insert(t,m)end
                    break
                end
            end
        end
    end
    return t
end
local function E(th)
    local t={},s={}
    local function P(x)
        local u=x:lower():gsub("[%$,/]","")
        local n=tonumber(u:match("%d+%.?%d*"))or 0
        return u:find("k")and n*1e3 or u:find("m")and n*1e6 or n
    end
    for _,g in ipairs(B:GetDescendants())do
        if g:IsA("BillboardGui")then
            for _,l in ipairs(g:GetDescendants())do
                if l:IsA("TextLabel")then
                    local x=l.Text
                    if x:match("^%$?%d+%.?%d*[KkMm]?$")then
                        if P(x)>=th then
                            local m=g:FindFirstAncestorOfClass("Model")
                            if m and not s[m]then s[m]=true;table.insert(t,m)end
                        end
                        break
                    end
                end
            end
        end
    end
    return t
end
local function F(models)
    for _,m in ipairs(models)do
        local p=m.PrimaryPart or m:FindFirstChildWhichIsA("BasePart")
        if p then
            local z=Instance.new("BoxHandleAdornment",p)
            z.Adornee=p;z.AlwaysOnTop=true;z.ZIndex=10
            z.Color3=Color3.fromRGB(255,0,0);z.Transparency=0.1
            z.Size=p.Size+Vector3.new(2,2,2)
        end
    end
end

local list = (MODE=="value") and E( tonumber(QUERY:lower():gsub("[^%d%.]","")) * (QUERY:lower():find("m") and 1e6 or QUERY:lower():find("k") and 1e3 or 1) )
                       or D(QUERY)

print(("Encontrados %d modelo(s) por %s = '%s':"):format(#list,MODE,QUERY))
for _,m in ipairs(list)do
    print(" •",m.Name)
end
F(list)
