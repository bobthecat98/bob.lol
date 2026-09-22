local __bob_root = _G
local __bob_getgenv
if type(__bob_root) == "table" then
    pcall(function() __bob_getgenv = rawget(__bob_root, "getgenv") end)
end
local __bob_environment = __bob_root
if type(__bob_getgenv) == "function" then
    local __bob_env_ok, __bob_env_result = pcall(__bob_getgenv)
    if __bob_env_ok and type(__bob_env_result) == "table" then
        __bob_environment = __bob_env_result
    end
end
local function __bob_outer_capability(name)
    local value
    if type(__bob_environment) == "table" then
        pcall(function() value = rawget(__bob_environment, name) end)
    end
    if value == nil and type(__bob_root) == "table" then
        pcall(function() value = rawget(__bob_root, name) end)
    end
    return value
end
local __bob_source = [========[
local __bob_global = _G

local function __bob_read_global(name)
    local value
    if type(__bob_global) == "table" then
        pcall(function()
            value = rawget(__bob_global, name)
        end)
    end
    return value
end

local __bob_getgenv = __bob_read_global("getgenv")
local __bob_environment = __bob_global
if type(__bob_getgenv) == "function" then
    local ok, result = pcall(__bob_getgenv)
    if ok and type(result) == "table" then
        __bob_environment = result
    end
end

local function __bob_capability(name)
    local value
    if type(__bob_environment) == "table" then
        pcall(function()
            value = rawget(__bob_environment, name)
        end)
    end
    if value == nil then
        value = __bob_read_global(name)
    end
    return value
end

local getgenv = __bob_capability("getgenv") or function()
    return __bob_environment
end
local gethui = __bob_capability("gethui")
local getgc = __bob_capability("getgc")
local getupvalues = __bob_capability("getupvalues")
local getconnections = __bob_capability("getconnections")
local getloadedmodules = __bob_capability("getloadedmodules")
local getnilinstances = __bob_capability("getnilinstances")
local getrenv = __bob_capability("getrenv")
local getinfo = __bob_capability("getinfo")
local firetouchinterest = __bob_capability("firetouchinterest")
local fireproximityprompt = __bob_capability("fireproximityprompt")
local fireclickdetector = __bob_capability("fireclickdetector")
local queue_on_teleport = __bob_capability("queue_on_teleport")
local queueonteleport = __bob_capability("queueonteleport")
local request = __bob_capability("request")
local http_request = __bob_capability("http_request")
local sethiddenproperty = __bob_capability("sethiddenproperty")
local Drawing = __bob_capability("Drawing")
local syn = __bob_capability("syn")
local http = __bob_capability("http")
local shared = __bob_capability("shared") or shared
local debug = __bob_capability("debug")
local loadstring = __bob_capability("loadstring")
local load = __bob_capability("load")

local __bob_traceback = tostring
if type(debug) == "table" and type(debug.traceback) == "function" then
    __bob_traceback = debug.traceback
end

__bob_environment.bob_lol_obfuscation_compatibility = {
    Active = true,
    Revision = "runtime-capsule-v2"
}

local UI = (function()
if not game:IsLoaded() then game.Loaded:Wait() end

local library
do
    local folder = "bob.lol"

    local services = setmetatable({}, {
        __index = function(_, service)
            if service == "InputService" then
                return game:GetService("UserInputService")
            end

            return game:GetService(service)
        end
    })

    local utility = {}
    local libraryConnections = {}

    -- Semantic colors keep the original Specter look while allowing every
    -- important surface to be changed at runtime from the Appearance page.
    local themeDefaults = {
        canvas = Color3.fromRGB(20, 20, 20),
        panel = Color3.fromRGB(22, 22, 22),
        control = Color3.fromRGB(25, 25, 25),
        window = Color3.fromRGB(30, 30, 30),
        hover = Color3.fromRGB(35, 35, 35),
        border = Color3.fromRGB(40, 40, 40),
        edge = Color3.fromRGB(45, 45, 45),
        strongborder = Color3.fromRGB(50, 50, 50),
        subtletext = Color3.fromRGB(110, 110, 110),
        placeholder = Color3.fromRGB(120, 120, 120),
        mutedtext = Color3.fromRGB(150, 150, 150),
        disabledtext = Color3.fromRGB(180, 180, 180),
        text = Color3.fromRGB(210, 210, 210)
    }

    local theme = {}
    for role, color in next, themeDefaults do
        theme[role] = color
    end

    local themeobjects = {}
    local gradientobjects = {}
    local fontobjects = {}
    local strokeobjects = {}
    local cornerobjects = {}
    local interfaceState = {
        font = Enum.Font.Code,
        animationSpeed = 1,
        roundness = 4,
        textOutline = true
    }

    local function getColorRole(color)
        if typeof(color) ~= "Color3" then return nil end
        for role, defaultColor in next, themeDefaults do
            if color == defaultColor or color == theme[role] then
                return role
            end
        end
        return nil
    end

    local function resolveColor(color)
        local role = getColorRole(color)
        return role and theme[role] or color, role
    end

    local function resolveSequence(sequence)
        local points, definition = {}, {}
        local hasThemeRole = false
        for _, point in ipairs(sequence.Keypoints) do
            local resolved, role = resolveColor(point.Value)
            points[#points + 1] = ColorSequenceKeypoint.new(point.Time, resolved)
            definition[#definition + 1] = {
                time = point.Time,
                role = role,
                color = point.Value
            }
            hasThemeRole = hasThemeRole or role ~= nil
        end
        return ColorSequence.new(points), definition, hasThemeRole
    end

    function utility.randomstring(length)
        local str = ""
        local chars = string.split("abcdefghijklmnopqrstuvwxyz1234567890", "")

        for i = 1, length do
            local i = math.random(1, #chars)

            if not tonumber(chars[i]) then
                local uppercase = math.random(1, 2) == 2 and true or false
                str = str .. (uppercase and chars[i]:upper() or chars[i])
            else
                str = str .. chars[i]
            end
        end

        return str
    end

    function utility.create(class, properties)
        local obj = Instance.new(class)

        local forced = {
            AutoButtonColor = false
        }

        for prop, v in next, properties do
            if typeof(v) == "Color3" then
                local resolved, role = resolveColor(v)
                obj[prop] = resolved
                if role then
                    themeobjects[role] = themeobjects[role] or {}
                    table.insert(themeobjects[role], { object = obj, property = prop })
                end
            elseif typeof(v) == "ColorSequence" then
                local resolved, definition, hasThemeRole = resolveSequence(v)
                obj[prop] = resolved
                if hasThemeRole then
                    table.insert(gradientobjects, {
                        object = obj,
                        property = prop,
                        definition = definition
                    })
                end
            else
                obj[prop] = v
            end
        end

        for prop, v in next, forced do
            pcall(function()
                obj[prop] = v
            end)
        end

        obj.Name = utility.randomstring(16)

        if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
            -- Roblox gives TextButtons the literal caption "Button" by default.
            -- Most buttons in this library are transparent input surfaces, so an
            -- omitted caption must mean an empty caption.
            if obj:IsA("TextButton") and properties.Text == nil then
                obj.Text = ""
            end
            if properties.TextTransparency == nil then
                obj.TextTransparency = 0
            end
            if properties.Font == Enum.Font.Code then
                obj.Font = interfaceState.font
                table.insert(fontobjects, obj)
            end
            if properties.TextStrokeTransparency ~= nil then
                table.insert(strokeobjects, obj)
                obj.TextStrokeTransparency = interfaceState.textOutline and 0 or 1
            end

        end

        if obj:IsA("GuiObject") and properties.BackgroundTransparency ~= 1 then
            local size = properties.Size
            local height = size and math.abs(size.Y.Offset) or 0
            if height == 0 or height >= 6 then
                local position = properties.Position
                local isOutline = size and position
                    and size.X.Offset >= 2 and size.Y.Offset >= 2
                    and position.X.Offset <= -1 and position.Y.Offset <= -1
                local corner = Instance.new("UICorner")
                corner.CornerRadius = UDim.new(0, interfaceState.roundness + (isOutline and 1 or 0))
                corner.Parent = obj
                table.insert(cornerobjects, { object = corner, outline = isOutline and true or false })

                -- Legacy borders remain square around rounded objects. A
                -- UIStroke follows UICorner and keeps the whole outline rounded.
                if properties.BorderColor3 and properties.BorderSizePixel ~= 0 then
                    local borderColor, borderRole = resolveColor(properties.BorderColor3)
                    local border = Instance.new("UIStroke")
                    border.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                    border.Thickness = tonumber(properties.BorderSizePixel) or 1
                    border.Color = borderColor
                    border.Parent = obj
                    obj.BorderSizePixel = 0
                    if borderRole then
                        themeobjects[borderRole] = themeobjects[borderRole] or {}
                        table.insert(themeobjects[borderRole], { object = border, property = "Color" })
                    end
                end
            end
        end

        return obj
    end

    function utility.setfixedroundness(object, pixels)
        pixels = math.clamp(tonumber(pixels) or 0, 0, 12)
        for _, entry in ipairs(cornerobjects) do
            local corner = entry.object
            if corner and corner.Parent == object then
                entry.fixed = pixels
                corner.CornerRadius = UDim.new(0, pixels)
                return corner
            end
        end
    end

    function utility.connect(signal, callback)
        local connection = signal:Connect(callback)
        table.insert(libraryConnections, connection)
        return connection
    end

    function utility.dragify(object, speed, bounds)
        local start, objectPosition, dragging

        speed = speed or 0

        object.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                start = input.Position
                objectPosition = object.Position
            end
        end)

        object.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)

        utility.connect(services.InputService.InputChanged, function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
                local delta = input.Position - start
                local target = UDim2.new(
                    objectPosition.X.Scale,
                    objectPosition.X.Offset + delta.X,
                    objectPosition.Y.Scale,
                    objectPosition.Y.Offset + delta.Y
                )

                local camera = workspace.CurrentCamera
                if camera and bounds then
                    local viewport = camera.ViewportSize
                    local scale = (library and library.uiscale) or 1
                    local absoluteX = target.X.Scale * viewport.X + target.X.Offset
                    local absoluteY = target.Y.Scale * viewport.Y + target.Y.Offset
                    absoluteX = math.clamp(absoluteX, 8, math.max(8, viewport.X - bounds.X * scale - 8))
                    absoluteY = math.clamp(absoluteY, 8, math.max(8, viewport.Y - bounds.Y * scale - 8))
                    target = UDim2.new(
                        target.X.Scale,
                        absoluteX - target.X.Scale * viewport.X,
                        target.Y.Scale,
                        absoluteY - target.Y.Scale * viewport.Y
                    )
                end

                if speed > 0 then
                    utility.tween(object, { speed }, { Position = target })
                else
                    object.Position = target
                end
            end
        end)
    end

    function utility.getrgb(color)
        local r = math.floor(color.r * 255)
        local g = math.floor(color.g * 255)
        local b = math.floor(color.b * 255)

        return r, g, b
    end

    function utility.getcenter(sizeX, sizeY)
        return UDim2.new(0.5, -(sizeX / 2), 0.5, -(sizeY / 2))
    end

    function utility.table(tbl)
        tbl = tbl or {}

        local newtbl = {}

        for i, v in next, tbl do
            if type(i) == "string" then
                newtbl[i:lower()] = v
            end
        end

        return setmetatable({}, {
            __newindex = function(_, k, v)
                rawset(newtbl, k:lower(), v)
            end,

            __index = function(_, k)
                return newtbl[k:lower()]
            end
        })
    end

    function utility.tween(obj, info, properties, callback)
        local tweenInfo = table.clone(info)
        tweenInfo[1] = (tonumber(tweenInfo[1]) or 0) / math.max(interfaceState.animationSpeed, 0.05)
        local themedProperties = {}
        for property, value in next, properties do
            if typeof(value) == "Color3" then
                themedProperties[property] = (resolveColor(value))
            elseif typeof(value) == "ColorSequence" then
                themedProperties[property] = (resolveSequence(value))
            else
                themedProperties[property] = value
            end
        end
        local anim = services.TweenService:Create(obj, TweenInfo.new(unpack(tweenInfo)), themedProperties)
        anim:Play()

        if callback then
            anim.Completed:Connect(callback)
        end

        return anim
    end

    local sequenceAnimations = setmetatable({}, { __mode = "k" })

    local function animateColorSequence(gradient, target, duration)
        if not gradient or not gradient.Parent or typeof(target) ~= "ColorSequence" then return end
        local source = gradient.Color
        if #source.Keypoints ~= #target.Keypoints then
            gradient.Color = target
            return
        end

        sequenceAnimations[gradient] = (sequenceAnimations[gradient] or 0) + 1
        local generation = sequenceAnimations[gradient]
        duration = (tonumber(duration) or 0.2) / math.max(interfaceState.animationSpeed, 0.05)

        task.spawn(function()
            local elapsed = 0
            while elapsed < duration and gradient.Parent and sequenceAnimations[gradient] == generation do
                elapsed = elapsed + services.RunService.Heartbeat:Wait()
                local alpha = math.clamp(elapsed / duration, 0, 1)
                alpha = 1 - ((1 - alpha) ^ 3)
                local points = {}
                for index, targetPoint in ipairs(target.Keypoints) do
                    local sourcePoint = source.Keypoints[index]
                    points[index] = ColorSequenceKeypoint.new(
                        targetPoint.Time,
                        sourcePoint.Value:Lerp(targetPoint.Value, alpha)
                    )
                end
                gradient.Color = ColorSequence.new(points)
            end

            if gradient.Parent and sequenceAnimations[gradient] == generation then
                gradient.Color = target
            end
        end)
    end

    local gui
    local fadeStates = setmetatable({}, { __mode = "k" })
    local fadeGenerations = setmetatable({}, { __mode = "k" })

    local function transparencyProperties(object)
        local properties = { "BackgroundTransparency" }
        if object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox") then
            properties[#properties + 1] = "TextTransparency"
            properties[#properties + 1] = "TextStrokeTransparency"
        elseif object:IsA("ImageLabel") or object:IsA("ImageButton") then
            properties[#properties + 1] = "ImageTransparency"
        elseif object:IsA("ScrollingFrame") then
            properties[#properties + 1] = "ScrollBarImageTransparency"
        end
        return properties
    end

    local function fadeObject(object, visible)
        if not object:IsA("GuiObject") then return nil end
        local target = {}

        if visible then
            local saved = fadeStates[object]
            for _, property in ipairs(transparencyProperties(object)) do
                target[property] = saved and saved[property] or object[property]
            end
            fadeStates[object] = nil
        else
            -- Never replace a real baseline with values sampled halfway through
            -- an existing fade. That was the source of permanently missing text.
            local saved = fadeStates[object]
            if not saved then
                saved = {}
                for _, property in ipairs(transparencyProperties(object)) do
                    saved[property] = object[property]
                end
                fadeStates[object] = saved
            end
            for _, property in ipairs(transparencyProperties(object)) do
                target[property] = 1
            end
        end

        return utility.tween(object, { 0.2 }, target)
    end

    local function isVisibleBranch(object, root)
        if not object.Visible then return false end

        local ancestor = object.Parent
        while ancestor and ancestor ~= root do
            if ancestor:IsA("GuiObject") and not ancestor.Visible then
                return false
            end
            ancestor = ancestor.Parent
        end

        return ancestor == root
    end

    local function isHierarchyVisible(object)
        local current = object
        while current and current ~= gui do
            if current:IsA("GuiObject") and not current.Visible then
                return false
            end
            current = current.Parent
        end
        return current == gui
    end

    local function normalizeVisibleText()
        for _, object in ipairs(gui:GetDescendants()) do
            if (object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox"))
                and object.Text ~= ""
                and isHierarchyVisible(object)
                and not fadeStates[object]
            then
                object.TextTransparency = 0
            end
        end
    end

    function utility.makevisible(obj, visible)
        visible = visible and true or false
        fadeGenerations[obj] = (fadeGenerations[obj] or 0) + 1
        local generation = fadeGenerations[obj]
        if visible then obj.Visible = true end

        local tween = fadeObject(obj, visible)
        for _, descendant in ipairs(obj:GetDescendants()) do
            -- Hidden pages and closed popups own separate fade state. A window
            -- fade must not consume or overwrite that state.
            if descendant:IsA("GuiObject") and isVisibleBranch(descendant, obj) then
                fadeObject(descendant, visible)
            end
        end

        if tween and not visible then
            tween.Completed:Connect(function()
                if fadeGenerations[obj] == generation then
                    obj.Visible = false
                end
            end)
        end

        return tween
    end

    function utility.updatescrolling(scrolling, list)
        return list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            scrolling.CanvasSize = UDim2.new(0, 0, 0, list.AbsoluteContentSize.Y)
        end)
    end

    function utility.changecolor(color, amount)
        local r, g, b = utility.getrgb(color)
        r = math.clamp(r + amount, 0, 255)
        g = math.clamp(g + amount, 0, 255)
        b = math.clamp(b + amount, 0, 255)

        return Color3.fromRGB(r, g, b)
    end

    function utility.gradient(colors)
        local colortbl = {}

        for i, color in next, colors do
            table.insert(colortbl, ColorSequenceKeypoint.new((i - 1) / (#colors - 1), (resolveColor(color))))
        end

        return ColorSequence.new(colortbl)
    end

    library = utility.table {
        flags = {},
        toggled = true,
        accent = Color3.fromRGB(162, 109, 184),
        outline = { Color3.fromRGB(121, 66, 254), Color3.fromRGB(223, 57, 137) },
        keybind = Enum.KeyCode.RightShift,
        uiscale = 1
    }

    local accentobjects = { gradient = {}, bg = {}, text = {} }
    local themeTransitionDuration = 0.42

    function library:ChangeAccent(accent)
        if typeof(accent) ~= "Color3" then return end
        library.accent = accent

        for obj, color in next, accentobjects.gradient do
            if obj and obj.Parent then
                local ok, value = pcall(color, accent)
                if ok and typeof(value) == "ColorSequence" then
                    animateColorSequence(obj, value, themeTransitionDuration)
                end
            else
                accentobjects.gradient[obj] = nil
            end
        end

        for index = #accentobjects.bg, 1, -1 do
            local obj = accentobjects.bg[index]
            if obj and obj.Parent then
                utility.tween(obj, { themeTransitionDuration, Enum.EasingStyle.Quart, Enum.EasingDirection.Out }, {
                    BackgroundColor3 = accent
                })
            else
                table.remove(accentobjects.bg, index)
            end
        end

        for index = #accentobjects.text, 1, -1 do
            local obj = accentobjects.text[index]
            if obj and obj.Parent then
                utility.tween(obj, { themeTransitionDuration, Enum.EasingStyle.Quart, Enum.EasingDirection.Out }, {
                    TextColor3 = accent
                })
            else
                table.remove(accentobjects.text, index)
            end
        end
    end

    function library:ChangeThemeColor(role, color, deferAccentRefresh)
        if not theme[role] or typeof(color) ~= "Color3" then return end
        theme[role] = color

        for _, ref in next, themeobjects[role] or {} do
            if ref.object and ref.object.Parent then
                utility.tween(ref.object, { themeTransitionDuration, Enum.EasingStyle.Quart, Enum.EasingDirection.Out }, {
                    [ref.property] = color
                })
            end
        end

        for _, ref in next, gradientobjects do
            if ref.object and ref.object.Parent then
                local points = {}
                for _, point in ipairs(ref.definition) do
                    points[#points + 1] = ColorSequenceKeypoint.new(
                        point.time,
                        point.role and theme[point.role] or point.color
                    )
                end
                animateColorSequence(ref.object, ColorSequence.new(points), themeTransitionDuration)
            end
        end

        -- Accent gradients also contain panel/control colors.
        if not deferAccentRefresh then
            library:ChangeAccent(library.accent)
        end
    end

    local fontGeneration = 0
    function library:ChangeFont(font)
        if typeof(font) ~= "EnumItem" then return end
        interfaceState.font = font
        fontGeneration = fontGeneration + 1
        local generation = fontGeneration
        local visibleObjects = {}
        local fadeOutDuration = 0.12
        local fadeInDuration = 0.2

        for _, obj in next, fontobjects do
            if obj and obj.Parent then
                if isHierarchyVisible(obj) and not fadeStates[obj] and obj.Text ~= "" then
                    visibleObjects[#visibleObjects + 1] = {
                        object = obj,
                        stroke = table.find(strokeobjects, obj) ~= nil
                    }
                    -- Keep the interface readable while the glyph shapes change.
                    -- A full fade was visually harsh and could capture a dropdown's
                    -- temporary opacity as the final state.
                    utility.tween(obj, { fadeOutDuration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut }, {
                        TextTransparency = 0.48,
                        TextStrokeTransparency = 1
                    })
                else
                    obj.Font = font
                end
            end
        end

        task.delay(fadeOutDuration / math.max(interfaceState.animationSpeed, 0.05), function()
            if fontGeneration ~= generation then return end
            for _, entry in ipairs(visibleObjects) do
                local obj = entry.object
                if obj and obj.Parent then
                    obj.Font = font
                    utility.tween(obj, { fadeInDuration, Enum.EasingStyle.Quart, Enum.EasingDirection.Out }, {
                        TextTransparency = 0,
                        TextStrokeTransparency = entry.stroke and interfaceState.textOutline and 0 or 1
                    })
                end
            end

            task.delay(fadeInDuration / math.max(interfaceState.animationSpeed, 0.05), function()
                if fontGeneration == generation then
                    normalizeVisibleText()
                end
            end)
        end)
    end

    function library:SetTextOutline(enabled)
        interfaceState.textOutline = enabled and true or false
        for _, obj in next, strokeobjects do
            if obj and obj.Parent then
                local savedFade = fadeStates[obj]
                if savedFade then
                    savedFade.TextStrokeTransparency = interfaceState.textOutline and 0 or 1
                end
                if not interfaceState.textOutline then
                    obj.TextStrokeTransparency = 1
                else
                    local visible = true
                    local ancestor = obj
                    while ancestor and ancestor ~= gui do
                        if ancestor:IsA("GuiObject") and not ancestor.Visible then
                            visible = false
                            break
                        end
                        ancestor = ancestor.Parent
                    end
                    if visible then obj.TextStrokeTransparency = 0 end
                end
            end
        end
    end

    function library:SetAnimationSpeed(speed)
        interfaceState.animationSpeed = math.clamp(tonumber(speed) or 1, 0.25, 3)
    end

    function library:SetRoundness(pixels)
        interfaceState.roundness = math.clamp(math.floor(tonumber(pixels) or 0), 0, 12)
        for _, entry in next, cornerobjects do
            local corner = entry.object
            if corner and corner.Parent then
                utility.tween(corner, { 0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out }, {
                    CornerRadius = UDim.new(0, entry.fixed or (interfaceState.roundness + (entry.outline and 1 or 0)))
                })
            end
        end
    end

    local outlineobjs = {}

    function library:ChangeOutline(colors)
        library.outline = colors
        for index = #outlineobjs, 1, -1 do
            local obj = outlineobjs[index]
            if obj and obj.Parent then
                animateColorSequence(obj, utility.gradient(colors), themeTransitionDuration)
            else
                table.remove(outlineobjs, index)
            end
        end
    end

    gui = utility.create("ScreenGui", {
        DisplayOrder = 1000,
        IgnoreGuiInset = true,
        ResetOnSpawn = false,
        -- This library assigns absolute ZIndex values across nested controls.
        -- Global ordering keeps labels above their decorative child frames.
        ZIndexBehavior = Enum.ZIndexBehavior.Global
    })
    library.gui = gui

    local flags = {}

    function library:SetFlag(flag, value)
        local setter = flags[flag]
        if setter then
            setter(value)
            return true
        end
        return false
    end

    local function configApiReady(writeAccess)
        local readable = type(isfolder) == "function" and type(isfile) == "function"
            and type(readfile) == "function" and type(listfiles) == "function"
        local writable = type(makefolder) == "function" and type(writefile) == "function"
            and type(delfile) == "function"
        return readable and (not writeAccess or writable)
    end

    local function cleanConfigName(name)
        name = tostring(name or ""):gsub("[^%w%s%-%_]", "")
        name = name:gsub("^%s+", ""):gsub("%s+$", ""):sub(1, 48)
        if name == "" then return nil end
        return name
    end

    function library:SaveConfig(name, universal)
        name = cleanConfigName(name)
        if not name then return false, "Enter a config name" end
        if not configApiReady(true) then return false, "Filesystem API unavailable" end

        local ok, result = pcall(function()
            local configtbl = {}
            local placeid = universal and "universal" or game.PlaceId

            for flag, _ in next, flags do
                local value = library.flags[flag]
                if typeof(value) == "EnumItem" then
                    configtbl[flag] = tostring(value)
                elseif typeof(value) == "Color3" then
                    configtbl[flag] = { math.floor(value.R * 255), math.floor(value.G * 255), math.floor(value.B * 255) }
                else
                    configtbl[flag] = value
                end
            end

            local config = services.HttpService:JSONEncode(configtbl)
            local folderpath = string.format("%s/%s", folder, placeid)

            if not isfolder(folder) then
                makefolder(folder)
            end
            if not isfolder(folderpath) then
                makefolder(folderpath)
            end

            local filepath = string.format("%s/%s.json", folderpath, name)
            writefile(filepath, config)
            return name
        end)

        if not ok then return false, tostring(result) end
        return true, result
    end

    function library:DeleteConfig(name, universal)
        name = cleanConfigName(name)
        if not name then return false, "Choose a config" end
        if not configApiReady(true) then return false, "Filesystem API unavailable" end

        local ok, deleted = pcall(function()
            local placeid = universal and "universal" or game.PlaceId
            local folderpath = string.format("%s/%s", folder, placeid)

            if isfolder(folderpath) then
                local filepath = string.format("%s/%s.json", folderpath, name)
                if isfile(filepath) then
                    delfile(filepath)
                    return true
                end
            end
            return false
        end)

        if not ok then return false, tostring(deleted) end
        return deleted, deleted and nil or "Config not found in this scope"
    end

    function library:LoadConfig(name)
        name = cleanConfigName(name)
        if not name then return false, "Choose a config" end
        if not configApiReady(false) then return false, "Filesystem API unavailable" end

        local placeidfolder = string.format("%s/%s", folder, game.PlaceId)
        local placeidfile = string.format("%s/%s.json", placeidfolder, name)

        local universalfile = string.format("%s/universal/%s.json", folder, name)
        local filepath
        if isfolder(placeidfolder) and isfile(placeidfile) then
            filepath = placeidfile
        elseif isfile(universalfile) then
            filepath = universalfile
        else
            return false, "Config not found"
        end

        local readOk, file = pcall(readfile, filepath)
        if not readOk then return false, file end

        local decodeOk, config = pcall(function()
            return services.HttpService:JSONDecode(file)
        end)
        if not decodeOk or type(config) ~= "table" then
            return false, config
        end

        for flag, v in next, config do
            local func = flags[flag]
            if func then
                pcall(func, v)
            end
        end
        return true
    end

    function library:ListConfigs(universal)
        if not configApiReady(false) then return {} end
        local configs = {}
        local seen = {}
        local placeidfolder = string.format("%s/%s", folder, game.PlaceId)
        local universalfolder = folder .. "/universal"

        local function addConfig(path)
            local name = path:match("([^\\/]+)$")
            name = name and name:gsub("%.json$", "")
            if name and not seen[name] then
                seen[name] = true
                table.insert(configs, name)
            end
        end

        pcall(function()
            for _, config in next, (isfolder(placeidfolder) and listfiles(placeidfolder) or {}) do
                addConfig(config)
            end
            if universal and isfolder(universalfolder) then
                for _, config in next, listfiles(universalfolder) do
                    addConfig(config)
                end
            end
        end)
        table.sort(configs)
        return configs
    end

    function library:New(options)
        options = utility.table(options)
        local name = options.name
        local accent = options.accent or library.accent
        local outlinecolor = options.outline or { accent, utility.changecolor(accent, -100) }
        local sizeX = options.sizeX or 550
        local sizeY = options.sizeY or 350
        local sidebar = options.sidebar == true or tostring(options.tablayout or ""):lower() == "sidebar"
        local sidebarWidth = math.clamp(tonumber(options.sidebarwidth) or 126, 100, 170)
        local sidebarFooterKey = tostring(options.sidebarfooterkey or "")
        local sidebarFooterText = tostring(options.sidebarfootertext or "")
        local hasSidebarFooter = sidebar and (sidebarFooterKey ~= "" or sidebarFooterText ~= "")
        local scrollSidebar = sidebar and options.scrollsidebar == true
        local collapseHeaderEnabled = sidebar and options.collapseheader == true
        local collapseHeaderWidth = math.clamp(tonumber(options.collapseheaderwidth) or 270, 220, 360)
        local refinedHeader = sidebar and options.refinedheader == true
        local sliderRoundness = tonumber(options.sliderroundness)
        if sliderRoundness then sliderRoundness = math.clamp(sliderRoundness, 0, 12) end
        local headerBrand, headerContext = name, ""
        if refinedHeader then
            local parsedBrand, parsedContext = tostring(name):match("^%s*(.-)%s*|%s*(.-)%s*$")
            if parsedBrand and parsedBrand ~= "" then
                headerBrand = parsedBrand
                headerContext = parsedContext or ""
            end
        end
        local headerBrandWidth = services.TextService:GetTextSize(headerBrand, 14, Enum.Font.Code, Vector2.new(1000, 1000)).X

        library.accent = accent
        library.outline = outlinecolor

        local holder = utility.create("Frame", {
            Size = UDim2.new(0, sizeX, 0, 24),
            BackgroundTransparency = 1,
            Position = utility.getcenter(sizeX, sizeY),
            Parent = gui
        })
        library.holder = holder

        local interfaceScale = utility.create("UIScale", {
            Scale = library.uiscale,
            Parent = holder
        })
        library.scaleobject = interfaceScale

        function library:SetScale(scale)
            scale = math.clamp(tonumber(scale) or 1, 0.7, 1.35)
            library.uiscale = scale
            interfaceScale.Scale = scale
            holder.Position = UDim2.new(0.5, -(sizeX * scale) / 2, 0.5, -(sizeY * scale) / 2)
        end

        local toggling = false
        local collapsed = false
        local expandedPosition = holder.Position
        local collapseHeader
        local collapseHeaderScale

        local function primeHidden(root)
            local objects = { root }
            for _, descendant in ipairs(root:GetDescendants()) do
                if descendant:IsA("GuiObject") then
                    objects[#objects + 1] = descendant
                end
            end
            for _, object in ipairs(objects) do
                local saved = {}
                for _, property in ipairs(transparencyProperties(object)) do
                    saved[property] = object[property]
                    object[property] = 1
                end
                fadeStates[object] = saved
            end
            root.Visible = false
        end

        if collapseHeaderEnabled then
            collapseHeader = utility.create("TextButton", {
                ZIndex = 40,
                Size = UDim2.new(0, collapseHeaderWidth, 0, 29),
                Position = UDim2.new(0.5, -(collapseHeaderWidth / 2), 0, 18),
                BorderSizePixel = 1,
                BorderColor3 = library.accent,
                BackgroundColor3 = Color3.fromRGB(18, 18, 18),
                AutoButtonColor = false,
                Active = true,
                Text = "",
                Parent = gui
            })
            collapseHeaderScale = utility.create("UIScale", {
                Scale = 1,
                Parent = collapseHeader
            })
            utility.create("UIGradient", {
                Rotation = 90,
                Color = ColorSequence.new(Color3.fromRGB(27, 27, 27), Color3.fromRGB(17, 17, 17)),
                Parent = collapseHeader
            })
            utility.create("Frame", {
                ZIndex = 41,
                Size = UDim2.new(1, -6, 1, -6),
                Position = UDim2.new(0, 3, 0, 3),
                BackgroundTransparency = 1,
                BorderSizePixel = 1,
                BorderColor3 = Color3.fromRGB(50, 50, 50),
                Parent = collapseHeader
            })
            local collapseTitle = utility.create("TextLabel", {
                ZIndex = 42,
                Size = UDim2.new(0, refinedHeader and headerBrandWidth or collapseHeaderWidth - 42, 1, 0),
                Position = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1,
                FontSize = Enum.FontSize.Size14,
                TextSize = 14,
                TextColor3 = library.accent,
                Text = refinedHeader and headerBrand or name,
                Font = Enum.Font.Code,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Parent = collapseHeader
            })
            if refinedHeader and headerContext ~= "" then
                utility.create("Frame", {
                    ZIndex = 42,
                    Size = UDim2.new(0, 1, 0, 14),
                    Position = UDim2.new(0, 18 + headerBrandWidth, 0.5, -7),
                    BorderSizePixel = 0,
                    BackgroundColor3 = Color3.fromRGB(92, 92, 92),
                    Parent = collapseHeader
                })
                utility.create("TextLabel", {
                    ZIndex = 42,
                    Size = UDim2.new(1, -(headerBrandWidth + 72), 1, 0),
                    Position = UDim2.new(0, headerBrandWidth + 27, 0, 0),
                    BackgroundTransparency = 1,
                    FontSize = Enum.FontSize.Size14,
                    TextSize = 14,
                    TextColor3 = Color3.fromRGB(182, 182, 182),
                    Text = headerContext,
                    Font = Enum.Font.Code,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    Parent = collapseHeader
                })
            end
            local collapseChevron = utility.create("TextLabel", {
                ZIndex = 42,
                Size = UDim2.new(0, 28, 1, 0),
                Position = UDim2.new(1, -34, 0, -1),
                BackgroundTransparency = 1,
                FontSize = Enum.FontSize.Size14,
                TextSize = 16,
                TextColor3 = refinedHeader and Color3.fromRGB(175, 175, 175) or library.accent,
                Text = "⌄",
                Font = Enum.Font.Code,
                Parent = collapseHeader
            })
            utility.create("Frame", {
                ZIndex = 41,
                Size = UDim2.new(1, -6, 0, 1),
                Position = UDim2.new(0, 3, 1, -3),
                BorderSizePixel = 0,
                BackgroundColor3 = Color3.fromRGB(58, 58, 58),
                Parent = collapseHeader
            })
            local collapseAccent = utility.create("Frame", {
                ZIndex = 42,
                Size = refinedHeader and UDim2.new(0, math.min(headerBrandWidth + 22, collapseHeaderWidth - 44), 0, 1) or UDim2.new(1, -6, 0, 1),
                Position = UDim2.new(0, 3, 1, -3),
                BorderSizePixel = 0,
                BackgroundColor3 = library.accent,
                Parent = collapseHeader
            })
            table.insert(accentobjects.text, collapseTitle)
            if not refinedHeader then table.insert(accentobjects.text, collapseChevron) end
            table.insert(accentobjects.bg, collapseAccent)
            primeHidden(collapseHeader)
        end

        local function collapseToHeader()
            if not collapseHeader or collapsed or toggling or not library.toggled then return end
            toggling = true
            collapsed = true
            expandedPosition = holder.Position
            holder.Rotation = 0
            collapseHeaderScale.Scale = 0.94

            local holderTween = utility.makevisible(holder, false)
            utility.makevisible(collapseHeader, true)
            utility.tween(interfaceScale, { 0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.In }, {
                Scale = library.uiscale * 0.975
            })
            utility.tween(collapseHeaderScale, { 0.26, Enum.EasingStyle.Quint, Enum.EasingDirection.Out }, {
                Scale = 1
            })
            if holderTween then holderTween.Completed:Wait() end
            interfaceScale.Scale = library.uiscale
            toggling = false
        end

        local function restoreFromHeader()
            if not collapseHeader or not collapsed or toggling then return end
            toggling = true
            collapsed = false
            library.toggled = true
            holder.Position = expandedPosition
            holder.Rotation = -0.25
            interfaceScale.Scale = library.uiscale * 0.965

            utility.makevisible(collapseHeader, false)
            local holderTween = utility.makevisible(holder, true)
            utility.tween(collapseHeaderScale, { 0.16, Enum.EasingStyle.Quint, Enum.EasingDirection.In }, {
                Scale = 0.96
            })
            utility.tween(interfaceScale, { 0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out }, {
                Scale = library.uiscale
            })
            utility.tween(holder, { 0.24, Enum.EasingStyle.Quint, Enum.EasingDirection.Out }, {
                Rotation = 0
            })
            if holderTween then holderTween.Completed:Wait() end
            collapseHeaderScale.Scale = 1
            toggling = false
        end

        if collapseHeader then
            local draggingHeader = false
            local headerMoved = false
            local headerDragStart
            local headerStartPosition
            local headerInputType

            utility.connect(collapseHeader.InputBegan, function(input)
                if toggling then return end
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    draggingHeader = true
                    headerMoved = false
                    headerDragStart = input.Position
                    headerStartPosition = collapseHeader.AbsolutePosition
                    headerInputType = input.UserInputType
                end
            end)

            utility.connect(services.InputService.InputChanged, function(input)
                if not draggingHeader or not headerDragStart or not headerStartPosition then return end
                if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
                local delta = input.Position - headerDragStart
                if delta.Magnitude > 4 then headerMoved = true end
                local camera = workspace.CurrentCamera
                local viewport = camera and camera.ViewportSize or Vector2.new(1920, 1080)
                local width = collapseHeader.AbsoluteSize.X
                local height = collapseHeader.AbsoluteSize.Y
                local x = math.clamp(headerStartPosition.X + delta.X, 6, math.max(6, viewport.X - width - 6))
                local y = math.clamp(headerStartPosition.Y + delta.Y, 6, math.max(6, viewport.Y - height - 6))
                collapseHeader.Position = UDim2.fromOffset(x, y)
            end)

            utility.connect(services.InputService.InputEnded, function(input)
                if not draggingHeader or input.UserInputType ~= headerInputType then return end
                draggingHeader = false
                if not headerMoved then
                    task.spawn(restoreFromHeader)
                end
            end)
        end

        function library:Toggle()
            if toggling then return end
            toggling = true

            library.toggled = not library.toggled
            local targetScale = library.uiscale
            local tween

            if collapsed and collapseHeader then
                if library.toggled then
                    collapseHeaderScale.Scale = 0.96
                    tween = utility.makevisible(collapseHeader, true)
                    utility.tween(collapseHeaderScale, { 0.24, Enum.EasingStyle.Quint, Enum.EasingDirection.Out }, { Scale = 1 })
                else
                    tween = utility.makevisible(collapseHeader, false)
                    utility.tween(collapseHeaderScale, { 0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.In }, { Scale = 0.96 })
                end
            elseif library.toggled then
                interfaceScale.Scale = targetScale * 0.965
                holder.Rotation = -0.35
                tween = utility.makevisible(holder, true)
                utility.tween(interfaceScale, { 0.26, Enum.EasingStyle.Quint, Enum.EasingDirection.Out }, { Scale = targetScale })
                utility.tween(holder, { 0.24, Enum.EasingStyle.Quint, Enum.EasingDirection.Out }, { Rotation = 0 })
            else
                utility.tween(interfaceScale, { 0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.In }, { Scale = targetScale * 0.975 })
                utility.tween(holder, { 0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.In }, { Rotation = 0.25 })
                tween = utility.makevisible(holder, false)
            end

            if tween then tween.Completed:Wait() end
            if not library.toggled then
                interfaceScale.Scale = targetScale
                holder.Rotation = 0
            end
            if collapseHeaderScale and not library.toggled then collapseHeaderScale.Scale = 1 end

            toggling = false
        end

        function library:FadeOut()
            if not holder or not holder.Parent then return end
            library.toggled = false

            holder.Rotation = 0
            interfaceScale.Scale = library.uiscale
            local holderTween = holder.Visible and utility.makevisible(holder, false) or nil
            local headerTween = collapseHeader and collapseHeader.Visible and utility.makevisible(collapseHeader, false) or nil
            if headerTween then
                headerTween.Completed:Wait()
            elseif holderTween then
                holderTween.Completed:Wait()
            end
        end

        utility.dragify(holder, 0, Vector2.new(sizeX, sizeY))

        local title = utility.create("TextLabel", {
            ZIndex = 5,
            Size = refinedHeader and UDim2.new(0, headerBrandWidth, 0, 28) or (sidebar and UDim2.new(1, -104, 0, 28) or UDim2.new(1, -24, 1, -2)),
            BorderColor3 = Color3.fromRGB(50, 50, 50),
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 12, 0, 0),
            BackgroundColor3 = Color3.fromRGB(30, 30, 30),
            FontSize = Enum.FontSize.Size14,
            TextStrokeTransparency = 0,
            TextSize = 14,
            TextColor3 = library.accent,
            Text = refinedHeader and headerBrand or name,
            Font = Enum.Font.Code,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = holder
        })

        table.insert(accentobjects.text, title)
        if refinedHeader then
            title.TextStrokeTransparency = 1
            local strokeIndex = table.find(strokeobjects, title)
            if strokeIndex then table.remove(strokeobjects, strokeIndex) end
            utility.create("Frame", {
                ZIndex = 6,
                Size = UDim2.new(0, 1, 0, 14),
                Position = UDim2.new(0, headerBrandWidth + 21, 0, 7),
                BorderSizePixel = 0,
                BackgroundColor3 = Color3.fromRGB(92, 92, 92),
                Parent = holder
            })
            utility.create("TextLabel", {
                ZIndex = 5,
                Size = UDim2.new(0, math.max(0, sizeX - headerBrandWidth - 145), 0, 28),
                Position = UDim2.new(0, headerBrandWidth + 31, 0, 0),
                BackgroundTransparency = 1,
                FontSize = Enum.FontSize.Size14,
                TextSize = 14,
                TextColor3 = Color3.fromRGB(182, 182, 182),
                Text = headerContext,
                Font = Enum.Font.Code,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Parent = holder
            })
        end

        if sidebar then
            local boxed = false
            local function addWindowButton(text, offset, callback)
                local button = utility.create("TextButton", {
                    ZIndex = 12,
                    Size = refinedHeader and UDim2.new(0, 26, 0, 24) or UDim2.new(0, 24, 0, 22),
                    Position = refinedHeader and UDim2.new(1, offset, 0, 2) or UDim2.new(1, offset, 0, 3),
                    BorderSizePixel = 0,
                    BackgroundTransparency = 1,
                    BackgroundColor3 = Color3.fromRGB(35, 35, 35),
                    AutoButtonColor = false,
                    Font = Enum.Font.Code,
                    TextSize = refinedHeader and 14 or 15,
                    TextColor3 = Color3.fromRGB(210, 210, 210),
                    Text = text,
                    Parent = holder
                })
                if refinedHeader then
                    utility.create("Frame", {
                        ZIndex = 13,
                        Size = UDim2.new(0, 1, 0, 14),
                        Position = UDim2.new(0, 0, 0.5, -7),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Color3.fromRGB(48, 48, 48),
                        Parent = button
                    })
                end
                button.MouseEnter:Connect(function()
                    utility.tween(button, { 0.12 }, { BackgroundTransparency = 0, TextColor3 = library.accent })
                end)
                button.MouseLeave:Connect(function()
                    utility.tween(button, { 0.12 }, { BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(210, 210, 210) })
                end)
                button.MouseButton1Click:Connect(callback)
                return button
            end

            addWindowButton("_", -78, function()
                task.spawn(function() library:Toggle() end)
            end)
            addWindowButton("□", -52, function()
                if collapseHeaderEnabled then
                    task.spawn(collapseToHeader)
                    return
                end
                boxed = not boxed
                local targetScale = library.uiscale
                if boxed then
                    local camera = workspace.CurrentCamera
                    local viewport = camera and camera.ViewportSize or Vector2.new(sizeX, sizeY)
                    local fit = math.min((viewport.X - 40) / sizeX, (viewport.Y - 40) / sizeY, 1.25)
                    targetScale = math.max(targetScale, fit)
                end
                utility.tween(interfaceScale, { 0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out }, { Scale = targetScale })
                utility.tween(holder, { 0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out }, {
                    Position = UDim2.new(0.5, -(sizeX * targetScale) / 2, 0.5, -(sizeY * targetScale) / 2)
                })
            end)
            addWindowButton("X", -26, function()
                task.spawn(function()
                    if type(options.onclose) == "function" then
                        options.onclose()
                    else
                        library:Unload()
                    end
                end)
            end)
        end

        local main = utility.create("Frame", {
            ZIndex = 2,
            Size = UDim2.new(1, 0, 0, sizeY),
            BorderColor3 = Color3.fromRGB(27, 42, 53),
            BorderSizePixel = 0,
            BackgroundColor3 = Color3.fromRGB(30, 30, 30),
            Parent = holder
        })

        if refinedHeader then
            local titlebarShade = utility.create("Frame", {
                ZIndex = 4,
                Size = UDim2.new(1, 0, 0, 29),
                BorderSizePixel = 0,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                Parent = main
            })
            utility.create("UIGradient", {
                Rotation = 90,
                Color = ColorSequence.new(Color3.fromRGB(29, 29, 29), Color3.fromRGB(20, 20, 20)),
                Parent = titlebarShade
            })
        end

        local outline = utility.create("Frame", {
            Size = UDim2.new(1, 2, 1, 2),
            BorderColor3 = Color3.fromRGB(45, 45, 45),
            Position = UDim2.new(0, -1, 0, -1),
            BorderSizePixel = 0,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            Parent = main
        })

        local outlinegradient = utility.create("UIGradient", {
            Rotation = 45,
            Color = utility.gradient(library.outline),
            Parent = outline
        })

        table.insert(outlineobjs, outlinegradient)

        local border = utility.create("Frame", {
            ZIndex = 0,
            Size = UDim2.new(1, 2, 1, 2),
            Position = UDim2.new(0, -1, 0, -1),
            BorderSizePixel = 0,
            BackgroundColor3 = Color3.fromRGB(45, 45, 45),
            Parent = outline
        })

        utility.create("Frame", {
            ZIndex = 3,
            Visible = sidebar,
            Size = UDim2.new(1, -6, 1, -6),
            Position = UDim2.new(0, 3, 0, 3),
            BackgroundTransparency = 1,
            BorderSizePixel = 1,
            BorderColor3 = Color3.fromRGB(50, 50, 50),
            Parent = main
        })

        utility.create("Frame", {
            ZIndex = 5,
            Visible = refinedHeader,
            Size = UDim2.new(1, -16, 0, 1),
            Position = UDim2.new(0, 8, 0, 28),
            BorderSizePixel = 0,
            BackgroundColor3 = Color3.fromRGB(58, 58, 58),
            Parent = main
        })

        local titlebarline = utility.create("Frame", {
            ZIndex = 6,
            Visible = sidebar,
            Size = refinedHeader and UDim2.new(0, math.min(headerBrandWidth + 112, sizeX - 112), 0, 1) or UDim2.new(1, -16, 0, 1),
            Position = UDim2.new(0, 8, 0, 28),
            BorderSizePixel = 0,
            BackgroundColor3 = library.accent,
            Parent = main
        })
        table.insert(accentobjects.bg, titlebarline)

        local tabs = utility.create("Frame", {
            ZIndex = 4,
            Size = sidebar and UDim2.new(1, -16, 1, -38) or UDim2.new(1, -16, 1, -30),
            BorderColor3 = Color3.fromRGB(50, 50, 50),
            Position = sidebar and UDim2.new(0, 8, 0, 30) or UDim2.new(0, 8, 0, 22),
            BorderSizePixel = 0,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            Parent = main
        })

        utility.create("UIGradient", {
            Rotation = 90,
            Color = ColorSequence.new(Color3.fromRGB(25, 25, 25), Color3.fromRGB(20, 20, 20)),
            Parent = tabs
        })

        utility.create("Frame", {
            ZIndex = 3,
            Size = UDim2.new(1, 2, 1, 2),
            Position = UDim2.new(0, -1, 0, -1),
            BorderSizePixel = 0,
            BackgroundColor3 = Color3.fromRGB(20, 20, 20),
            Parent = tabs
        })

        utility.create("Frame", {
            ZIndex = 4,
            Visible = sidebar,
            Size = UDim2.new(0, sidebarWidth + 8, 1, -8),
            Position = UDim2.new(0, 2, 0, 4),
            BorderSizePixel = 1,
            BorderColor3 = Color3.fromRGB(42, 42, 42),
            BackgroundColor3 = Color3.fromRGB(18, 18, 18),
            Parent = tabs
        })

        local tabToggleProperties = {
            ZIndex = 5,
            Size = sidebar and UDim2.new(0, sidebarWidth, 1, hasSidebarFooter and -52 or -12) or UDim2.new(1, -12, 0, 22),
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 6, 0, 6),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            Parent = tabs
        }
        if scrollSidebar then
            tabToggleProperties.BorderSizePixel = 0
            tabToggleProperties.CanvasSize = UDim2.new(0, 0, 0, 0)
            tabToggleProperties.ScrollBarThickness = 2
            tabToggleProperties.ScrollBarImageColor3 = Color3.fromRGB(90, 90, 90)
            tabToggleProperties.ScrollingDirection = Enum.ScrollingDirection.Y
            tabToggleProperties.ElasticBehavior = Enum.ElasticBehavior.Never
            tabToggleProperties.ClipsDescendants = true
        end
        local tabtoggles = utility.create(scrollSidebar and "ScrollingFrame" or "Frame", tabToggleProperties)

        local tabToggleList = utility.create("UIListLayout", {
            FillDirection = sidebar and Enum.FillDirection.Vertical or Enum.FillDirection.Horizontal,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, sidebar and 1 or 4),
            Parent = tabtoggles
        })
        if scrollSidebar then
            utility.updatescrolling(tabtoggles, tabToggleList)
            tabtoggles.CanvasSize = UDim2.new(0, 0, 0, tabToggleList.AbsoluteContentSize.Y)
        end

        local footerContent
        local footerKeyLabel
        local footerTextLabel

        if hasSidebarFooter then
            local footer = utility.create("Frame", {
                ZIndex = 6,
                Size = UDim2.new(0, sidebarWidth, 0, 35),
                Position = UDim2.new(0, 6, 1, -41),
                BackgroundTransparency = 1,
                Parent = tabs
            })

            utility.create("Frame", {
                ZIndex = 7,
                Size = UDim2.new(1, 0, 0, 1),
                BorderSizePixel = 0,
                BackgroundColor3 = Color3.fromRGB(48, 48, 48),
                Parent = footer
            })

            local keyWidth = sidebarFooterKey ~= "" and math.max(30, services.TextService:GetTextSize(sidebarFooterKey, 12, Enum.Font.Code, Vector2.new(1000, 1000)).X + 12) or 0
            local footerGap = keyWidth > 0 and sidebarFooterText ~= "" and 9 or 0
            local footerTextWidth = sidebarFooterText ~= "" and services.TextService:GetTextSize(sidebarFooterText, 12, Enum.Font.Code, Vector2.new(1000, 1000)).X or 0
            local footerContentWidth = keyWidth + footerGap + footerTextWidth
            footerContent = utility.create("Frame", {
                ZIndex = 6,
                Size = UDim2.new(0, footerContentWidth, 0, 29),
                Position = UDim2.new(0.5, -(footerContentWidth / 2), 0, 0),
                BackgroundTransparency = 1,
                Parent = footer
            })
            if sidebarFooterKey ~= "" then
                footerKeyLabel = utility.create("TextLabel", {
                    ZIndex = 7,
                    Size = UDim2.new(0, keyWidth, 0, 21),
                    Position = UDim2.new(0, 0, 0, 8),
                    BorderSizePixel = 1,
                    BorderColor3 = Color3.fromRGB(54, 54, 54),
                    BackgroundColor3 = Color3.fromRGB(24, 24, 24),
                    FontSize = Enum.FontSize.Size12,
                    TextStrokeTransparency = 1,
                    TextSize = 12,
                    TextColor3 = Color3.fromRGB(175, 175, 175),
                    Text = sidebarFooterKey,
                    Font = Enum.Font.Code,
                    Parent = footerContent
                })
            end

            if sidebarFooterText ~= "" then
                footerTextLabel = utility.create("TextLabel", {
                    ZIndex = 7,
                    Size = UDim2.new(0, footerTextWidth, 0, 21),
                    Position = UDim2.new(0, keyWidth + footerGap, 0, 8),
                    BackgroundTransparency = 1,
                    FontSize = Enum.FontSize.Size12,
                    TextStrokeTransparency = 1,
                    TextSize = 12,
                    TextColor3 = Color3.fromRGB(135, 135, 135),
                    Text = sidebarFooterText,
                    Font = Enum.Font.Code,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = footerContent
                })
            end
        end

        local function formatSidebarKey(key)
            if key == nil then return "NONE" end
            local keyName = tostring(key)
                :gsub("Enum.KeyCode.", "")
                :gsub("Enum.UserInputType.", "")
            local aliases = {
                LeftControl = "L-CTRL",
                RightControl = "R-CTRL",
                LeftShift = "L-SHIFT",
                RightShift = "R-SHIFT",
                LeftAlt = "L-ALT",
                RightAlt = "R-ALT",
                MouseButton1 = "MOUSE-1",
                MouseButton2 = "MOUSE-2",
                MouseButton3 = "MOUSE-3"
            }
            return aliases[keyName] or keyName
        end

        function library:SetSidebarFooterKey(key)
            if not footerContent or not footerKeyLabel then return end
            sidebarFooterKey = formatSidebarKey(key)
            local keyWidth = math.max(30, services.TextService:GetTextSize(sidebarFooterKey, 12, interfaceState.font, Vector2.new(1000, 1000)).X + 12)
            local footerGap = sidebarFooterText ~= "" and 9 or 0
            local footerTextWidth = sidebarFooterText ~= "" and services.TextService:GetTextSize(sidebarFooterText, 12, interfaceState.font, Vector2.new(1000, 1000)).X or 0
            local footerContentWidth = keyWidth + footerGap + footerTextWidth

            footerContent.Size = UDim2.new(0, footerContentWidth, 0, 29)
            footerContent.Position = UDim2.new(0.5, -(footerContentWidth / 2), 0, 0)
            footerKeyLabel.Size = UDim2.new(0, keyWidth, 0, 21)
            footerKeyLabel.Text = sidebarFooterKey
            if footerTextLabel then
                footerTextLabel.Size = UDim2.new(0, footerTextWidth, 0, 21)
                footerTextLabel.Position = UDim2.new(0, keyWidth + footerGap, 0, 8)
            end
        end

        if hasSidebarFooter then library:SetSidebarFooterKey(sidebarFooterKey) end

        utility.create("Frame", {
            ZIndex = 5,
            Visible = sidebar,
            Size = UDim2.new(0, 1, 1, -12),
            Position = UDim2.new(0, sidebarWidth + 11, 0, 6),
            BorderSizePixel = 0,
            BackgroundColor3 = Color3.fromRGB(48, 48, 48),
            Parent = tabs
        })

        local tabframes = utility.create("Frame", {
            ZIndex = 5,
            Size = sidebar and UDim2.new(1, -(sidebarWidth + 24), 1, -12) or UDim2.new(1, -12, 1, -35),
            BorderColor3 = Color3.fromRGB(50, 50, 50),
            Position = sidebar and UDim2.new(0, sidebarWidth + 18, 0, 6) or UDim2.new(0, 6, 0, 29),
            BackgroundColor3 = Color3.fromRGB(30, 30, 30),
            Parent = tabs
        })

        local tabholder = utility.create("Frame", {
            Size = UDim2.new(1, -16, 1, -16),
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 8, 0, 8),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            Parent = tabframes
        })

        local windowtypes = utility.table()

        local pagetoggles = {}
        local tabbuttons = {}
        local sidebarLayoutOrder = 0
        local lastSidebarGroup

        local function addSidebarGroup(groupName)
            if not sidebar then return end
            groupName = tostring(groupName or ""):upper()
            if groupName == "" or groupName == lastSidebarGroup then return end
            lastSidebarGroup = groupName
            sidebarLayoutOrder = sidebarLayoutOrder + 1

            local header = utility.create("Frame", {
                ZIndex = 6,
                Size = UDim2.new(1, 0, 0, 21),
                BackgroundTransparency = 1,
                LayoutOrder = sidebarLayoutOrder,
                Parent = tabtoggles
            })
            local textWidth = services.TextService:GetTextSize(groupName, 11, Enum.Font.Code, Vector2.new(1000, 1000)).X
            utility.create("TextLabel", {
                ZIndex = 7,
                Size = UDim2.new(0, textWidth, 1, 0),
                BackgroundTransparency = 1,
                FontSize = Enum.FontSize.Size11,
                TextStrokeTransparency = 1,
                TextSize = 11,
                TextColor3 = Color3.fromRGB(110, 110, 110),
                Text = groupName,
                Font = Enum.Font.Code,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = header
            })
            utility.create("Frame", {
                ZIndex = 7,
                Size = UDim2.new(1, -(textWidth + 12), 0, 1),
                Position = UDim2.new(0, textWidth + 12, 0.5, 0),
                BorderSizePixel = 0,
                BackgroundColor3 = Color3.fromRGB(54, 54, 54),
                Parent = header
            })
        end

        local function updateTabWidths()
            local count = #tabbuttons
            if count == 0 then return end
            if sidebar then
                for _, button in ipairs(tabbuttons) do
                    button.Size = UDim2.new(1, 0, 0, 24)
                end
                return
            end
            local totalPadding = (count - 1) * 4
            for _, button in ipairs(tabbuttons) do
                button.Size = UDim2.new(1 / count, -(totalPadding / count), 1, 0)
            end
        end

        local switchingtabs = false

        local firsttab
        local currenttab
        local currentPageIndex = 1

        function windowtypes:Page(options)

            options = utility.table(options)
            local name = options.name

            local first = #tabbuttons == 0
            local pageIndex = #tabbuttons + 1
            if sidebar then addSidebarGroup(options.group) end
            sidebarLayoutOrder = sidebarLayoutOrder + 1

            local togglesizeX = math.clamp(services.TextService:GetTextSize(name, 14, Enum.Font.Code, Vector2.new(1000, 1000)).X, 25, math.huge)

            local tabtoggle = utility.create("TextButton", {
                Size = sidebar and UDim2.new(1, 0, 0, 24) or UDim2.new(0, togglesizeX + 18, 1, 0),
                BackgroundTransparency = 1,
                FontSize = Enum.FontSize.Size14,
                TextSize = 14,
                LayoutOrder = sidebar and sidebarLayoutOrder or 0,
                Parent = tabtoggles
            })

            table.insert(tabbuttons, tabtoggle)
            updateTabWidths()

            local antiborder = utility.create("Frame", {
                ZIndex = 6,
                Visible = first and not sidebar,
                Size = sidebar and UDim2.new(0, 0, 0, 0) or UDim2.new(1, 0, 0, 1),
                Position = UDim2.new(0, 0, 1, 0),
                BorderSizePixel = 0,
                BackgroundColor3 = Color3.fromRGB(30, 30, 30),
                Parent = tabtoggle
            })

            local selectedglow = utility.create("Frame", {
                ZIndex = 6,
                Size = sidebar and UDim2.new(0, 3, 1, -6) or UDim2.new(1, 0, 0, 1),
                Visible = first,
                BorderColor3 = Color3.fromRGB(50, 50, 50),
                Position = sidebar and UDim2.new(0, 0, 0, 3) or UDim2.new(0, 0, 0, 0),
                BorderSizePixel = 0,
                BackgroundColor3 = library.accent,
                Parent = tabtoggle
            })

            table.insert(accentobjects.bg, selectedglow)

            utility.create("Frame", {
                ZIndex = 7,
                Visible = not sidebar,
                Size = UDim2.new(1, 0, 0, 1),
                Position = UDim2.new(0, 0, 1, 0),
                BorderSizePixel = 0,
                BackgroundColor3 = Color3.fromRGB(30, 30, 30),
                Parent = selectedglow
            })

            local titleholder = utility.create("Frame", {
                ZIndex = 6,
                Size = sidebar and UDim2.new(1, -4, 1, -2) or UDim2.new(1, 0, 1, first and -1 or -4),
                BorderColor3 = Color3.fromRGB(50, 50, 50),
                Position = sidebar and UDim2.new(0, 4, 0, 1) or UDim2.new(0, 0, 0, first and 1 or 4),
                BorderSizePixel = 0,
                ClipsDescendants = true,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                Parent = tabtoggle
            })

            local title = utility.create("TextLabel", {
                ZIndex = 7,
                Size = sidebar and UDim2.new(1, -14, 1, 0) or UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Position = sidebar and UDim2.new(0, 10, 0, 0) or UDim2.new(0, 0, 0, 0),
                FontSize = Enum.FontSize.Size14,
                TextStrokeTransparency = sidebar and nil or 0,
                TextSize = 14,
                TextScaled = not sidebar,
                TextTruncate = Enum.TextTruncate.AtEnd,
                TextColor3 = first and library.accent or (sidebar and Color3.fromRGB(190, 190, 190) or Color3.fromRGB(110, 110, 110)),
                Text = name,
                Font = Enum.Font.Code,
                TextXAlignment = sidebar and Enum.TextXAlignment.Left or Enum.TextXAlignment.Center,
                Parent = titleholder
            })
            if sidebar then title.TextStrokeTransparency = 1 end

            utility.create("UITextSizeConstraint", {
                MinTextSize = 9,
                MaxTextSize = 14,
                Parent = title
            })

            if first then
                table.insert(accentobjects.text, title)
            end

            local selected = first

            local tabglowgradient = utility.create("UIGradient", {
                Rotation = sidebar and 0 or 90,
                Color = first and (sidebar and utility.gradient { Color3.fromRGB(22, 22, 22):Lerp(library.accent, 0.2), Color3.fromRGB(22, 22, 22) } or utility.gradient { utility.changecolor(library.accent, -30), Color3.fromRGB(30, 30, 30) }) or utility.gradient { Color3.fromRGB(22, 22, 22), Color3.fromRGB(22, 22, 22) },
                Offset = sidebar and Vector2.new(0, 0) or Vector2.new(0, -0.55),
                Parent = titleholder
            })

            accentobjects.gradient[tabglowgradient] = function(color)
                if selected then
                    return sidebar and utility.gradient { Color3.fromRGB(22, 22, 22):Lerp(color, 0.2), Color3.fromRGB(22, 22, 22) } or utility.gradient { utility.changecolor(color, -30), Color3.fromRGB(30, 30, 30) }
                end
                return utility.gradient { Color3.fromRGB(22, 22, 22), Color3.fromRGB(22, 22, 22) }
            end

            local tabtoggleborder = utility.create("Frame", {
                ZIndex = 5,
                Visible = not sidebar,
                Size = UDim2.new(1, 2, 1, 2),
                Position = UDim2.new(0, -1, 0, -1),
                BorderSizePixel = 0,
                BackgroundColor3 = Color3.fromRGB(50, 50, 50),
                Parent = title
            })

            pagetoggles[tabtoggle] = {}
            pagetoggles[tabtoggle] = function()
                selected = false
                utility.tween(antiborder, { 0.2 }, { BackgroundTransparency = 1 }, function()
                    antiborder.Visible = false
                end)

                utility.tween(selectedglow, { 0.2 }, { BackgroundTransparency = 1 }, function()
                    selectedglow.Visible = false
                end)

                utility.tween(titleholder, { 0.2 }, {
                    Size = sidebar and UDim2.new(1, -4, 1, -2) or UDim2.new(1, 0, 1, -4),
                    Position = sidebar and UDim2.new(0, 4, 0, 1) or UDim2.new(0, 0, 0, 4)
                })

                utility.tween(title, { 0.2 }, { TextColor3 = sidebar and Color3.fromRGB(190, 190, 190) or Color3.fromRGB(110, 110, 110) })
                if table.find(accentobjects.text, title) then
                    table.remove(accentobjects.text, table.find(accentobjects.text, title))
                end

                animateColorSequence(tabglowgradient, utility.gradient { Color3.fromRGB(22, 22, 22), Color3.fromRGB(22, 22, 22) }, 0.2)
            end

            tabtoggle.MouseEnter:Connect(function()
                if not selected then
                    if sidebar then
                        animateColorSequence(tabglowgradient, utility.gradient { Color3.fromRGB(27, 27, 27), Color3.fromRGB(22, 22, 22) }, 0.16)
                    else
                        utility.tween(titleholder, { 0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out }, {
                            Position = UDim2.new(0, 0, 0, 2),
                            Size = UDim2.new(1, 0, 1, -2)
                        })
                    end
                    utility.tween(title, { 0.16 }, { TextColor3 = sidebar and Color3.fromRGB(225, 225, 225) or Color3.fromRGB(180, 180, 180) })
                end
            end)

            tabtoggle.MouseLeave:Connect(function()
                if not selected then
                    if sidebar then
                        animateColorSequence(tabglowgradient, utility.gradient { Color3.fromRGB(22, 22, 22), Color3.fromRGB(22, 22, 22) }, 0.18)
                    else
                        utility.tween(titleholder, { 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out }, {
                            Position = UDim2.new(0, 0, 0, 4),
                            Size = UDim2.new(1, 0, 1, -4)
                        })
                    end
                    utility.tween(title, { 0.18 }, { TextColor3 = sidebar and Color3.fromRGB(190, 190, 190) or Color3.fromRGB(110, 110, 110) })
                end
            end)

            local tab = utility.create("Frame", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Visible = first,
                Parent = tabholder
            })

            if first then
                currenttab = tab
                firsttab = tab
            end

            tab.DescendantAdded:Connect(function(descendant)
                if tab ~= currenttab then
                    task.wait()
                    fadeObject(descendant, false)
                end
            end)

            local column1 = utility.create("ScrollingFrame", {
                Size = UDim2.new(0.5, -4, 1, 0),
                BackgroundTransparency = 1,
                Active = true,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                CanvasSize = UDim2.new(0, 0, 0, 123),
                ScrollBarImageColor3 = Color3.fromRGB(50, 50, 50),
                ScrollBarThickness = 3,
                Parent = tab
            })

            local column1list = utility.create("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 10),
                Parent = column1
            })

            utility.updatescrolling(column1, column1list)

            local column2 = utility.create("ScrollingFrame", {
                Size = UDim2.new(0.5, -4, 1, 0),
                BackgroundTransparency = 1,
                Position = UDim2.new(0.5, 4, 0, 0),
                Active = true,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                CanvasSize = UDim2.new(0, 0, 0, 0),
                ScrollBarImageColor3 = Color3.fromRGB(50, 50, 50),
                ScrollBarThickness = 3,
                Parent = tab
            })

            local column2list = utility.create("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 10),
                Parent = column2
            })

            utility.updatescrolling(column2, column2list)

            local function opentab()
                if not switchingtabs then
                    if currenttab == tab then return end
                    switchingtabs = true

                    local direction = pageIndex >= currentPageIndex and 1 or -1
                    local outgoing = currenttab
                    currenttab = tab
                    currentPageIndex = pageIndex
                    selected = true

                    for toggle, close in next, pagetoggles do
                        if toggle ~= tabtoggle then
                            close()
                        end
                    end

                    if outgoing and outgoing ~= tab and outgoing.Visible then
                        utility.tween(outgoing, { 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.In }, {
                            Position = UDim2.new(-direction * 0.035, 0, 0, 0)
                        })
                        local hideTween = utility.makevisible(outgoing, false)
                        if hideTween then
                            hideTween.Completed:Connect(function()
                                outgoing.Position = UDim2.new(0, 0, 0, 0)
                            end)
                        end
                    end

                    antiborder.Visible = true
                    utility.tween(antiborder, { 0.2 }, { BackgroundTransparency = 0 })

                    selectedglow.Visible = true
                    utility.tween(selectedglow, { 0.2 }, { BackgroundTransparency = 0 })

                    utility.tween(titleholder, { 0.2 }, {
                        Size = sidebar and UDim2.new(1, -4, 1, -2) or UDim2.new(1, 0, 1, -1),
                        Position = sidebar and UDim2.new(0, 4, 0, 1) or UDim2.new(0, 0, 0, 1)
                    })

                    utility.tween(title, { 0.2 }, { TextColor3 = library.accent })

                    if not table.find(accentobjects.text, title) then
                        table.insert(accentobjects.text, title)
                    end

                    animateColorSequence(tabglowgradient, sidebar and utility.gradient { Color3.fromRGB(22, 22, 22):Lerp(library.accent, 0.2), Color3.fromRGB(22, 22, 22) } or utility.gradient { utility.changecolor(library.accent, -30), Color3.fromRGB(30, 30, 30) }, 0.22)

                    if not tab.Visible then
                        tab.Position = UDim2.new(direction * 0.035, 0, 0, 0)
                        column1.Position = UDim2.new(0, direction * 10, 0, 3)
                        column2.Position = UDim2.new(0.5, 4 + direction * 10, 0, 3)
                        task.wait(0.045)
                        local tween = utility.makevisible(tab, true)
                        utility.tween(tab, { 0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out }, {
                            Position = UDim2.new(0, 0, 0, 0)
                        })
                        utility.tween(column1, { 0.30, Enum.EasingStyle.Quint, Enum.EasingDirection.Out }, {
                            Position = UDim2.new(0, 0, 0, 0)
                        })
                        utility.tween(column2, { 0.34, Enum.EasingStyle.Quint, Enum.EasingDirection.Out }, {
                            Position = UDim2.new(0.5, 4, 0, 0)
                        })
                        if tween then tween.Completed:Wait() end
                    end

                    switchingtabs = false
                end
            end

            tabtoggle.MouseButton1Click:Connect(opentab)

            local pagetypes = utility.table()

            function pagetypes:Section(options)
                options = utility.table(options)
                local name = options.name
                local side = options.side or "left"
                local max = options.max or math.huge
                local column = (side:lower() == "left" and column1) or (side:lower() == "right" and column2)

                local sectionholder = utility.create("Frame", {
                    Size = UDim2.new(1, -1, 0, sidebar and 40 or 28),
                    BackgroundTransparency = 1,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    Parent = column
                })

                local section = utility.create("Frame", {
                    ZIndex = 6,
                    Size = UDim2.new(1, -2, 1, -2),
                    BorderColor3 = Color3.fromRGB(50, 50, 50),
                    Position = UDim2.new(0, 1, 0, 1),
                    BackgroundColor3 = Color3.fromRGB(22, 22, 22),
                    Parent = sectionholder
                })

                local title = utility.create("TextLabel", {
                    ZIndex = 8,
                    Size = UDim2.new(1, -12, 0, sidebar and 18 or 14),
                    BorderColor3 = Color3.fromRGB(50, 50, 50),
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 6, 0, sidebar and 5 or 3),
                    BackgroundColor3 = Color3.fromRGB(30, 30, 30),
                    FontSize = Enum.FontSize.Size14,
                    TextStrokeTransparency = 0,
                    TextSize = sidebar and 15 or 14,
                    TextColor3 = library.accent,
                    Text = name,
                    Font = Enum.Font.Code,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = section
                })

                table.insert(accentobjects.text, title)

                local glow = utility.create("Frame", {
                    ZIndex = 8,
                    Size = sidebar and UDim2.new(1, -12, 0, 1) or UDim2.new(1, 0, 0, 1),
                    BorderColor3 = Color3.fromRGB(50, 50, 50),
                    Position = sidebar and UDim2.new(0, 6, 0, 27) or UDim2.new(0, 0, 0, 0),
                    BorderSizePixel = 0,
                    BackgroundColor3 = library.accent,
                    Parent = section
                })

                table.insert(accentobjects.bg, glow)

                utility.create("Frame", {
                    ZIndex = 9,
                    Size = UDim2.new(1, 0, 0, 1),
                    Position = UDim2.new(0, 0, 1, 0),
                    BorderSizePixel = 0,
                    BackgroundColor3 = Color3.fromRGB(30, 30, 30),
                    Parent = glow
                })

                local fade = utility.create("Frame", {
                    ZIndex = 7,
                    Visible = not sidebar,
                    Size = UDim2.new(1, 0, 0, 20),
                    BorderSizePixel = 0,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    Parent = glow
                })

                local fadegradient = utility.create("UIGradient", {
                    Rotation = 90,
                    Color = utility.gradient { utility.changecolor(library.accent, -30), Color3.fromRGB(22, 22, 22) },
                    Offset = Vector2.new(0, -0.55),
                    Parent = fade
                })

                accentobjects.gradient[fadegradient] = function(color)
                    return utility.gradient { utility.changecolor(color, -30), Color3.fromRGB(22, 22, 22) }
                end

                local sectioncontent = utility.create("ScrollingFrame", {
                    ZIndex = 7,
                    Size = UDim2.new(1, -7, 1, sidebar and -39 or -26),
                    BorderColor3 = Color3.fromRGB(27, 42, 53),
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 6, 0, sidebar and 33 or 20),
                    Active = true,
                    BorderSizePixel = 0,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    CanvasSize = UDim2.new(0, 0, 0, 1),
                    ScrollBarThickness = sidebar and 0 or 2,
                    Parent = section
                })

                local sectionlist = utility.create("UIListLayout", {
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, sidebar and 4 or 2),
                    Parent = sectioncontent
                })

                utility.updatescrolling(sectioncontent, sectionlist)
                sectionlist:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    if #sectioncontent:GetChildren() - 1 <= max then
                        sectionholder.Size = UDim2.new(1, -1, 0, sectionlist.AbsoluteContentSize.Y + (sidebar and 42 or 28))
                    end
                end)

                local sectiontypes = utility.table()

                function sectiontypes:Label(options)
                    options = utility.table(options)
                    local name = options.name

                    local label = utility.create("TextLabel", {
                        ZIndex = 8,
                        Size = UDim2.new(1, sidebar and -6 or 0, 0, 13),
                        BorderColor3 = Color3.fromRGB(50, 50, 50),
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 6, 0, 3),
                        BackgroundColor3 = Color3.fromRGB(30, 30, 30),
                        FontSize = Enum.FontSize.Size14,
                        TextStrokeTransparency = 0,
                        TextSize = 13,
                        TextWrapped = sidebar,
                        AutomaticSize = sidebar and Enum.AutomaticSize.Y or Enum.AutomaticSize.None,
                        TextYAlignment = Enum.TextYAlignment.Top,
                        TextColor3 = Color3.fromRGB(210, 210, 210),
                        Text = name,
                        Font = Enum.Font.Code,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = sectioncontent
                    })

                    if #sectioncontent:GetChildren() - 1 <= max then
                        sectionholder.Size = UDim2.new(1, -1, 0, sectionlist.AbsoluteContentSize.Y + (sidebar and 42 or 28))
                    end
                    return label
                end

                function sectiontypes:Button(options)
                    options = utility.table(options)
                    local name = options.name
                    local callback = options.callback or function() end

                    local buttonholder = utility.create("Frame", {
                        Size = UDim2.new(1, -5, 0, 17),
                        BackgroundTransparency = 1,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        Parent = sectioncontent
                    })

                    local button = utility.create("TextButton", {
                        ZIndex = 10,
                        Size = UDim2.new(1, -4, 1, -4),
                        BorderColor3 = Color3.fromRGB(40, 40, 40),
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 2, 0, 2),
                        BackgroundColor3 = Color3.fromRGB(25, 25, 25),
                        AutoButtonColor = false,
                        FontSize = Enum.FontSize.Size14,
                        TextStrokeTransparency = 0,
                        TextSize = 13,
                        TextColor3 = Color3.fromRGB(210, 210, 210),
                        Text = name,
                        Font = Enum.Font.Code,
                        Parent = buttonholder
                    })

                    local bg = utility.create("Frame", {
                        ZIndex = 9,
                        Size = UDim2.new(1, 0, 1, 0),
                        BorderColor3 = Color3.fromRGB(40, 40, 40),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        Parent = button
                    })

                    local bggradient = utility.create("UIGradient", {
                        Rotation = 90,
                        Color = utility.gradient { Color3.fromRGB(35, 35, 35), Color3.fromRGB(25, 25, 25) },
                        Parent = bg
                    })

                    local grayborder = utility.create("Frame", {
                        ZIndex = 8,
                        Size = UDim2.new(1, 2, 1, 2),
                        Position = UDim2.new(0, -1, 0, -1),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Color3.fromRGB(40, 40, 40),
                        Parent = button
                    })

                    local blackborder = utility.create("Frame", {
                        ZIndex = 7,
                        Size = UDim2.new(1, 2, 1, 2),
                        Position = UDim2.new(0, -1, 0, -1),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Color3.fromRGB(10, 10, 10),
                        Parent = grayborder
                    })

                    local hovering = false

                    button.MouseEnter:Connect(function()
                        hovering = true
                        utility.tween(button, { 0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.Out }, {
                            Size = UDim2.new(1, -2, 1, -2),
                            Position = UDim2.new(0, 1, 0, 1),
                            TextColor3 = Color3.fromRGB(235, 235, 235)
                        })
                    end)

                    button.MouseLeave:Connect(function()
                        hovering = false
                        utility.tween(button, { 0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out }, {
                            Size = UDim2.new(1, -4, 1, -4),
                            Position = UDim2.new(0, 2, 0, 2),
                            TextColor3 = Color3.fromRGB(210, 210, 210)
                        })
                        bggradient.Color = utility.gradient { Color3.fromRGB(35, 35, 35), Color3.fromRGB(25, 25, 25) }
                    end)

                    button.MouseButton1Click:Connect(callback)

                    button.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            bggradient.Color = utility.gradient { Color3.fromRGB(45, 45, 45), Color3.fromRGB(35, 35, 35) }
                            utility.tween(button, { 0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out }, {
                                Size = UDim2.new(1, -7, 1, -6),
                                Position = UDim2.new(0, 3.5, 0, 3)
                            })
                        end
                    end)

                    button.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            bggradient.Color = utility.gradient { Color3.fromRGB(35, 35, 35), Color3.fromRGB(25, 25, 25) }
                            utility.tween(button, { 0.16, Enum.EasingStyle.Back, Enum.EasingDirection.Out }, {
                                Size = hovering and UDim2.new(1, -2, 1, -2) or UDim2.new(1, -4, 1, -4),
                                Position = hovering and UDim2.new(0, 1, 0, 1) or UDim2.new(0, 2, 0, 2)
                            })
                        end
                    end)

                    if #sectioncontent:GetChildren() - 1 <= max then
                        sectionholder.Size = UDim2.new(1, -1, 0, sectionlist.AbsoluteContentSize.Y + (sidebar and 42 or 28))
                    end

                    local control = { Object = button }
                    function control:SetText(value)
                        name = tostring(value or "")
                        button.Text = name
                    end
                    function control:GetText()
                        return button.Text
                    end
                    return control
                end

                function sectiontypes:Toggle(options)
                    options = utility.table(options)
                    local name = options.name
                    local default = options.default
                    local flag = options.pointer
                    local callback = options.callback or function() end

                    local toggleholder = utility.create("TextButton", {
                        Size = UDim2.new(1, -5, 0, 14),
                        BackgroundTransparency = 1,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        FontSize = Enum.FontSize.Size14,
                        TextSize = 14,
                        TextColor3 = Color3.fromRGB(0, 0, 0),
                        Font = Enum.Font.SourceSans,
                        Parent = sectioncontent
                    })

                    local togglething = utility.create("TextButton", {
                        ZIndex = 9,
                        Size = UDim2.new(1, 0, 0, 14),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BackgroundTransparency = 1,
                        TextTransparency = 1,
                        Parent = toggleholder
                    })

                    local icon = utility.create("Frame", {
                        ZIndex = 9,
                        Size = UDim2.new(0, 10, 0, 10),
                        BorderColor3 = Color3.fromRGB(40, 40, 40),
                        Position = UDim2.new(0, 2, 0, 2),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        Parent = toggleholder
                    })

                    local grayborder = utility.create("Frame", {
                        ZIndex = 8,
                        Size = UDim2.new(1, 2, 1, 2),
                        Position = UDim2.new(0, -1, 0, -1),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Color3.fromRGB(40, 40, 40),
                        Parent = icon
                    })

                    local blackborder = utility.create("Frame", {
                        ZIndex = 7,
                        Size = UDim2.new(1, 2, 1, 2),
                        Position = UDim2.new(0, -1, 0, -1),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Color3.fromRGB(10, 10, 10),
                        Parent = grayborder
                    })

                    local icongradient = utility.create("UIGradient", {
                        Rotation = 90,
                        Color = utility.gradient { Color3.fromRGB(35, 35, 35), Color3.fromRGB(25, 25, 25) },
                        Parent = icon
                    })

                    local enablediconholder = utility.create("Frame", {
                        ZIndex = 10,
                        Size = UDim2.new(1, 0, 1, 0),
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        Parent = icon
                    })

                    local enabledicongradient = utility.create("UIGradient", {
                        Rotation = 90,
                        Color = utility.gradient { library.accent, Color3.fromRGB(25, 25, 25) },
                        Parent = enablediconholder
                    })

                    accentobjects.gradient[enabledicongradient] = function(color)
                        return utility.gradient { color, Color3.fromRGB(25, 25, 25) }
                    end

                    local title = utility.create("TextLabel", {
                        ZIndex = 7,
                        Size = UDim2.new(1, -24, 0, 14),
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 20, 0, 0),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        FontSize = Enum.FontSize.Size14,
                        TextStrokeTransparency = 0,
                        TextSize = 13,
                        TextColor3 = Color3.fromRGB(180, 180, 180),
                        Text = name,
                        Font = Enum.Font.Code,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = toggleholder
                    })

                    local toggled = false
                    local toggleHovering = false

                    togglething.MouseEnter:Connect(function()
                        toggleHovering = true
                        utility.tween(icon, { 0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.Out }, {
                            Size = UDim2.new(0, 12, 0, 12),
                            Position = UDim2.new(0, 1, 0, 1)
                        })
                        if not toggled then
                            utility.tween(title, { 0.16 }, { TextColor3 = Color3.fromRGB(205, 205, 205) })
                        end
                    end)

                    togglething.MouseLeave:Connect(function()
                        toggleHovering = false
                        utility.tween(icon, { 0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out }, {
                            Size = UDim2.new(0, 10, 0, 10),
                            Position = UDim2.new(0, 2, 0, 2)
                        })
                        if not toggled then
                            utility.tween(title, { 0.18 }, { TextColor3 = Color3.fromRGB(180, 180, 180) })
                        end
                    end)

                    togglething.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            utility.tween(icon, { 0.07, Enum.EasingStyle.Quad, Enum.EasingDirection.Out }, {
                                Size = UDim2.new(0, 8, 0, 8),
                                Position = UDim2.new(0, 3, 0, 3)
                            })
                        end
                    end)

                    togglething.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            utility.tween(icon, { 0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out }, {
                                Size = toggleHovering and UDim2.new(0, 12, 0, 12) or UDim2.new(0, 10, 0, 10),
                                Position = toggleHovering and UDim2.new(0, 1, 0, 1) or UDim2.new(0, 2, 0, 2)
                            })
                        end
                    end)

                    if flag then
                        library.flags[flag] = toggled
                    end

                    -- Keep the authoritative toggle state separate from page fading.
                    -- A toggle can be changed while its tab is hidden; in that case
                    -- the live object is transparent, so its saved fade baseline must
                    -- also be updated or it will look disabled when the tab is opened.
                    local function syncToggleVisual()
                        local enabledTransparency = toggled and 0 or 1
                        local savedIconFade = fadeStates[enablediconholder]
                        if savedIconFade then
                            savedIconFade.BackgroundTransparency = enabledTransparency
                        else
                            enablediconholder.BackgroundTransparency = enabledTransparency
                        end

                        enablediconholder.Size = toggled and UDim2.new(1, 0, 1, 0) or UDim2.new(0, 2, 0, 2)
                        enablediconholder.Position = toggled and UDim2.new(0, 0, 0, 0) or UDim2.new(0.5, -1, 0.5, -1)
                        title.TextColor3 = toggled and library.accent or Color3.fromRGB(180, 180, 180)

                        local accentIndex = table.find(accentobjects.text, title)
                        if toggled and not accentIndex then
                            table.insert(accentobjects.text, title)
                        elseif not toggled and accentIndex then
                            table.remove(accentobjects.text, accentIndex)
                        end
                    end

                    local function toggle()
                        if not switchingtabs then
                            toggled = not toggled

                            if flag then
                                library.flags[flag] = toggled
                            end

                            callback(toggled)

                            if toggled then
                                enablediconholder.Size = UDim2.new(0, 2, 0, 2)
                                enablediconholder.Position = UDim2.new(0.5, -1, 0.5, -1)
                                utility.tween(enablediconholder, { 0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out }, {
                                    Size = UDim2.new(1, 0, 1, 0),
                                    Position = UDim2.new(0, 0, 0, 0),
                                    BackgroundTransparency = 0
                                })
                            else
                                utility.tween(enablediconholder, { 0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.In }, {
                                    Size = UDim2.new(0, 2, 0, 2),
                                    Position = UDim2.new(0.5, -1, 0.5, -1),
                                    BackgroundTransparency = 1
                                })
                            end

                            local textcolor = toggled and library.accent or Color3.fromRGB(180, 180, 180)
                            utility.tween(title, { 0.2 }, { TextColor3 = textcolor })

                            local savedIconFade = fadeStates[enablediconholder]
                            if savedIconFade then
                                savedIconFade.BackgroundTransparency = toggled and 0 or 1
                            end

                            if toggled then
                                if not table.find(accentobjects.text, title) then
                                    table.insert(accentobjects.text, title)
                                end
                            elseif table.find(accentobjects.text, title) then
                                table.remove(accentobjects.text, table.find(accentobjects.text, title))
                            end
                        end
                    end

                    togglething.MouseButton1Click:Connect(toggle)

                    local function set(bool)
                        if type(bool) ~= "boolean" then return end
                        if toggled == bool then
                            syncToggleVisual()
                        elseif toggled ~= bool then
                            if switchingtabs then
                                task.defer(function()
                                    while switchingtabs do services.RunService.Heartbeat:Wait() end
                                    if toggled ~= bool then toggle() end
                                end)
                            else
                                toggle()
                            end
                        end
                    end

                    if default == true then
                        -- Hidden pages are faded as their controls are created. Animating
                        -- the initial checked state here lets that page fade capture a
                        -- half-faded checkbox as its baseline, making an enabled feature
                        -- look disabled when the page is opened later. Apply defaults
                        -- immediately so the saved baseline always represents "on".
                        toggled = true
                        if flag then
                            library.flags[flag] = true
                        end
                        callback(true)
                        enablediconholder.Size = UDim2.new(1, 0, 1, 0)
                        enablediconholder.Position = UDim2.new(0, 0, 0, 0)
                        enablediconholder.BackgroundTransparency = 0
                        title.TextColor3 = library.accent
                        if not table.find(accentobjects.text, title) then
                            table.insert(accentobjects.text, title)
                        end
                    end

                    if flag then
                        flags[flag] = set
                    end

                    local toggletypes = utility.table()

                    function toggletypes:Toggle(bool)
                        set(bool)
                    end

                    function toggletypes:Set(bool)
                        set(bool)
                    end

                    function toggletypes:Get()
                        return toggled
                    end

                    function toggletypes:Refresh()
                        syncToggleVisual()
                    end

                    function toggletypes:Colorpicker(newoptions)

                        newoptions = utility.table(newoptions)
                        local name = newoptions.name
                        local default = newoptions.default or Color3.fromRGB(255, 255, 255)
                        local colorpickertype = newoptions.mode
                        local toggleflag = colorpickertype and colorpickertype:lower() == "toggle" and newoptions.togglepointer
                        local togglecallback = colorpickertype and colorpickertype:lower() == "toggle" and newoptions.togglecallback or function() end
                        local flag = newoptions.pointer
                        local callback = newoptions.callback or function() end
                        local opened = false
                        local opening = false

                        local colorpickerframe = utility.create("Frame", {
                            ZIndex = 9,
                            Size = UDim2.new(1, -70, 0, 148),
                            Position = UDim2.new(1, -168, 0, 18),
                            BorderSizePixel = 0,
                            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                            Visible = false,
                            Parent = toggleholder
                        })

                        colorpickerframe.DescendantAdded:Connect(function(descendant)
                            if not opened then
                                task.wait()
                                fadeObject(descendant, false)
                            end
                        end)

                        local bggradient = utility.create("UIGradient", {
                            Rotation = 90,
                            Color = utility.gradient { Color3.fromRGB(35, 35, 35), Color3.fromRGB(25, 25, 25) },
                            Parent = colorpickerframe
                        })

                        local grayborder = utility.create("Frame", {
                            ZIndex = 8,
                            Size = UDim2.new(1, 2, 1, 2),
                            Position = UDim2.new(0, -1, 0, -1),
                            BorderSizePixel = 0,
                            BackgroundColor3 = Color3.fromRGB(40, 40, 40),
                            Parent = colorpickerframe
                        })

                        local blackborder = utility.create("Frame", {
                            ZIndex = 7,
                            Size = UDim2.new(1, 2, 1, 2),
                            Position = UDim2.new(0, -1, 0, -1),
                            BorderSizePixel = 0,
                            BackgroundColor3 = Color3.fromRGB(10, 10, 10),
                            Parent = grayborder
                        })

                        local saturationframe = utility.create("ImageLabel", {
                            ZIndex = 12,
                        Size = UDim2.new(1, -34, 0, 100),
                            BorderColor3 = Color3.fromRGB(50, 50, 50),
                            Position = UDim2.new(0, 6, 0, 6),
                            BorderSizePixel = 0,
                            BackgroundColor3 = default,
                            Image = "http://www.roblox.com/asset/?id=8630797271",
                            Parent = colorpickerframe
                        })

                        local grayborder = utility.create("Frame", {
                            ZIndex = 11,
                            Size = UDim2.new(1, 2, 1, 2),
                            Position = UDim2.new(0, -1, 0, -1),
                            BorderSizePixel = 0,
                            BackgroundColor3 = Color3.fromRGB(40, 40, 40),
                            Parent = saturationframe
                        })

                        utility.create("Frame", {
                            ZIndex = 10,
                            Size = UDim2.new(1, 2, 1, 2),
                            Position = UDim2.new(0, -1, 0, -1),
                            BorderSizePixel = 0,
                            BackgroundColor3 = Color3.fromRGB(10, 10, 10),
                            Parent = grayborder
                        })

                        local saturationpicker = utility.create("Frame", {
                            ZIndex = 13,
                        Size = UDim2.new(0, 8, 0, 8),
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        BorderColor3 = Color3.fromRGB(10, 10, 10),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                            Parent = saturationframe
                        })

                        local hueframe = utility.create("ImageLabel", {
                            ZIndex = 12,
                        Size = UDim2.new(0, 16, 0, 100),
                        Position = UDim2.new(1, -22, 0, 6),
                            BorderSizePixel = 0,
                            BackgroundColor3 = Color3.fromRGB(255, 193, 49),
                            ScaleType = Enum.ScaleType.Crop,
                            Image = "http://www.roblox.com/asset/?id=8630799159",
                            Parent = colorpickerframe
                        })

                        local grayborder = utility.create("Frame", {
                            ZIndex = 11,
                            Size = UDim2.new(1, 2, 1, 2),
                            Position = UDim2.new(0, -1, 0, -1),
                            BorderSizePixel = 0,
                            BackgroundColor3 = Color3.fromRGB(40, 40, 40),
                            Parent = hueframe
                        })

                        utility.create("Frame", {
                            ZIndex = 10,
                            Size = UDim2.new(1, 2, 1, 2),
                            Position = UDim2.new(0, -1, 0, -1),
                            BorderSizePixel = 0,
                            BackgroundColor3 = Color3.fromRGB(10, 10, 10),
                            Parent = grayborder
                        })

                        local huepicker = utility.create("Frame", {
                            ZIndex = 13,
                        Size = UDim2.new(1, 0, 0, 3),
                        AnchorPoint = Vector2.new(0, 0.5),
                        BorderColor3 = Color3.fromRGB(10, 10, 10),
                        BorderSizePixel = 0,
                            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                            Parent = hueframe
                        })

                        local boxholder = utility.create("Frame", {
                            Size = UDim2.new(1, -8, 0, 17),
                            ClipsDescendants = true,
                            Position = UDim2.new(0, 4, 0, 110),
                            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                            Parent = colorpickerframe
                        })

                        local box = utility.create("TextBox", {
                            ZIndex = 13,
                            Size = UDim2.new(1, -4, 1, -4),
                            BackgroundTransparency = 1,
                            Position = UDim2.new(0, 2, 0, 2),
                            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                            FontSize = Enum.FontSize.Size14,
                            TextStrokeTransparency = 0,
                            TextSize = 13,
                            TextColor3 = Color3.fromRGB(210, 210, 210),
                        Text = string.format("#%02X%02X%02X", math.floor(default.R * 255 + 0.5), math.floor(default.G * 255 + 0.5), math.floor(default.B * 255 + 0.5)),
                        PlaceholderText = "#RRGGBB or R, G, B",
                            Font = Enum.Font.Code,
                            Parent = boxholder
                        })

                        local grayborder = utility.create("Frame", {
                            ZIndex = 11,
                            Size = UDim2.new(1, 2, 1, 2),
                            Position = UDim2.new(0, -1, 0, -1),
                            BorderSizePixel = 0,
                            BackgroundColor3 = Color3.fromRGB(40, 40, 40),
                            Parent = box
                        })

                        utility.create("Frame", {
                            ZIndex = 10,
                            Size = UDim2.new(1, 2, 1, 2),
                            Position = UDim2.new(0, -1, 0, -1),
                            BorderSizePixel = 0,
                            BackgroundColor3 = Color3.fromRGB(10, 10, 10),
                            Parent = grayborder
                        })

                        local bg = utility.create("Frame", {
                            ZIndex = 12,
                            Size = UDim2.new(1, 0, 1, 0),
                            BorderColor3 = Color3.fromRGB(40, 40, 40),
                            BorderSizePixel = 0,
                            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                            Parent = box
                        })

                        utility.create("UIGradient", {
                            Rotation = 90,
                            Color = utility.gradient { Color3.fromRGB(35, 35, 35), Color3.fromRGB(25, 25, 25) },
                            Parent = bg
                        })

                        local rainbowtoggleholder = utility.create("TextButton", {
                            Size = UDim2.new(1, -8, 0, 14),
                            BackgroundTransparency = 1,
                            Position = UDim2.new(0, 4, 0, 130),
                            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                            FontSize = Enum.FontSize.Size14,
                            TextSize = 14,
                            TextColor3 = Color3.fromRGB(0, 0, 0),
                            Font = Enum.Font.SourceSans,
                            Parent = colorpickerframe
                        })

                        local toggleicon = utility.create("Frame", {
                            ZIndex = 12,
                            Size = UDim2.new(0, 10, 0, 10),
                            BorderColor3 = Color3.fromRGB(40, 40, 40),
                            Position = UDim2.new(0, 2, 0, 2),
                            BorderSizePixel = 0,
                            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                            Parent = rainbowtoggleholder
                        })

                        local enablediconholder = utility.create("Frame", {
                            ZIndex = 13,
                            Size = UDim2.new(1, 0, 1, 0),
                            BackgroundTransparency = 1,
                            BorderSizePixel = 0,
                            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                            Parent = toggleicon
                        })

                        local enabledicongradient = utility.create("UIGradient", {
                            Rotation = 90,
                            Color = utility.gradient { library.accent, Color3.fromRGB(25, 25, 25) },
                            Parent = enablediconholder
                        })

                        accentobjects.gradient[enabledicongradient] = function(color)
                            return utility.gradient { color, Color3.fromRGB(25, 25, 25) }
                        end

                        local grayborder = utility.create("Frame", {
                            ZIndex = 11,
                            Size = UDim2.new(1, 2, 1, 2),
                            Position = UDim2.new(0, -1, 0, -1),
                            BorderSizePixel = 0,
                            BackgroundColor3 = Color3.fromRGB(40, 40, 40),
                            Parent = toggleicon
                        })

                        utility.create("Frame", {
                            ZIndex = 10,
                            Size = UDim2.new(1, 2, 1, 2),
                            Position = UDim2.new(0, -1, 0, -1),
                            BorderSizePixel = 0,
                            BackgroundColor3 = Color3.fromRGB(10, 10, 10),
                            Parent = grayborder
                        })

                        utility.create("UIGradient", {
                            Rotation = 90,
                            Color = utility.gradient { Color3.fromRGB(35, 35, 35), Color3.fromRGB(25, 25, 25) },
                            Parent = toggleicon
                        })

                        local rainbowtxt = utility.create("TextLabel", {
                            ZIndex = 10,
                            Size = UDim2.new(1, -24, 1, 0),
                            BackgroundTransparency = 1,
                            Position = UDim2.new(0, 20, 0, 0),
                            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                            FontSize = Enum.FontSize.Size14,
                            TextStrokeTransparency = 0,
                            TextSize = 13,
                            TextColor3 = Color3.fromRGB(180, 180, 180),
                            Text = "Rainbow",
                            Font = Enum.Font.Code,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            Parent = rainbowtoggleholder
                        })

                        local colorpicker = utility.create("TextButton", {
                            ZIndex = 8,
                            Size = UDim2.new(1, 0, 0, 14),
                            BackgroundTransparency = 1,
                            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                            FontSize = Enum.FontSize.Size14,
                            TextSize = 14,
                            TextColor3 = Color3.fromRGB(0, 0, 0),
                            Font = Enum.Font.SourceSans,
                            Parent = toggleholder
                        })

                        local icon = utility.create("TextButton", {
                            ZIndex = 9,
                            Size = UDim2.new(0, 18, 0, 10),
                            BorderColor3 = Color3.fromRGB(40, 40, 40),
                            Position = UDim2.new(1, -20, 0, 2),
                            BorderSizePixel = 0,
                            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                            Parent = colorpicker,
                            Text = ""
                        })

                        local grayborder = utility.create("Frame", {
                            ZIndex = 8,
                            Size = UDim2.new(1, 2, 1, 2),
                            Position = UDim2.new(0, -1, 0, -1),
                            BorderSizePixel = 0,
                            BackgroundColor3 = Color3.fromRGB(40, 40, 40),
                            Parent = icon
                        })

                        utility.create("Frame", {
                            ZIndex = 7,
                            Size = UDim2.new(1, 2, 1, 2),
                            Position = UDim2.new(0, -1, 0, -1),
                            BorderSizePixel = 0,
                            BackgroundColor3 = Color3.fromRGB(10, 10, 10),
                            Parent = grayborder
                        })

                        local icongradient = utility.create("UIGradient", {
                            Rotation = 90,
                            Color = utility.gradient { default, utility.changecolor(default, -200) },
                            Parent = icon
                        })

                        colorpicker.MouseEnter:Connect(function()
                            utility.tween(icon, { 0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.Out }, {
                                Size = UDim2.new(0, 22, 0, 12),
                                Position = UDim2.new(1, -22, 0, 1)
                            })
                        end)

                        colorpicker.MouseLeave:Connect(function()
                            utility.tween(icon, { 0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out }, {
                                Size = UDim2.new(0, 18, 0, 10),
                                Position = UDim2.new(1, -20, 0, 2)
                            })
                        end)

                        if #sectioncontent:GetChildren() - 1 <= max then
                        sectionholder.Size = UDim2.new(1, -1, 0, sectionlist.AbsoluteContentSize.Y + (sidebar and 42 or 28))
                        end

                        local function opencolorpicker()
                            if not opening then
                                opening = true

                                opened = not opened

                                if opened then
                                    colorpickerframe.Position = UDim2.new(1, -168, 0, 12)
                                    utility.tween(toggleholder, { 0.2 }, { Size = UDim2.new(1, -5, 0, 168) })
                                end

                                if not opened then
                                    utility.tween(colorpickerframe, { 0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.In }, {
                                        Position = UDim2.new(1, -168, 0, 12)
                                    })
                                end

                                local tween = utility.makevisible(colorpickerframe, opened)

                                if opened then
                                    utility.tween(colorpickerframe, { 0.24, Enum.EasingStyle.Quint, Enum.EasingDirection.Out }, {
                                        Position = UDim2.new(1, -168, 0, 18)
                                    })
                                end

                                tween.Completed:Wait()

                                if not opened then
                                    local tween = utility.tween(toggleholder, { 0.2 }, { Size = UDim2.new(1, -5, 0, 16) })
                                    tween.Completed:Wait()
                                end

                                opening = false
                            end
                        end

                        icon.MouseButton1Click:Connect(opencolorpicker)

                        local hue, sat, val = default:ToHSV()

                        local slidinghue = false
                        local slidingsaturation = false

                        local hsv = Color3.fromHSV(hue, sat, val)

                        local function formatcolor(color)
                            return string.format(
                                "#%02X%02X%02X",
                                math.clamp(math.floor(color.R * 255 + 0.5), 0, 255),
                                math.clamp(math.floor(color.G * 255 + 0.5), 0, 255),
                                math.clamp(math.floor(color.B * 255 + 0.5), 0, 255)
                            )
                        end

                        if flag then
                            library.flags[flag] = default
                        end

                        local function updatehue(input)
                            local sizeY = 1 - math.clamp((input.Position.Y - hueframe.AbsolutePosition.Y) / hueframe.AbsoluteSize.Y, 0, 1)
                            local posY = math.clamp(((input.Position.Y - hueframe.AbsolutePosition.Y) / hueframe.AbsoluteSize.Y) * hueframe.AbsoluteSize.Y, 0, hueframe.AbsoluteSize.Y)
                            huepicker.Position = UDim2.new(0, 0, 0, posY)

                            hue = sizeY
                            hsv = Color3.fromHSV(sizeY, sat, val)

                            box.Text = formatcolor(hsv)

                            saturationframe.BackgroundColor3 = hsv
                            icon.BackgroundColor3 = hsv
                            icongradient.Color = utility.gradient { hsv, utility.changecolor(hsv, -200) }

                            if flag then
                                library.flags[flag] = hsv
                            end

                            callback(hsv)
                        end

                        hueframe.InputBegan:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                                slidinghue = true
                                utility.tween(huepicker, { 0.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out }, {
                                    Size = UDim2.new(1, 2, 0, 5)
                                })
                                updatehue(input)
                            end
                        end)

                        hueframe.InputEnded:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                                slidinghue = false
                                utility.tween(huepicker, { 0.16, Enum.EasingStyle.Back, Enum.EasingDirection.Out }, {
                                    Size = UDim2.new(1, 0, 0, 3)
                                })
                            end
                        end)

                        utility.connect(services.InputService.InputChanged, function(input)
                            if input.UserInputType == Enum.UserInputType.MouseMovement then
                                if slidinghue then
                                    updatehue(input)
                                end
                            end
                        end)

                        local function updatesatval(input)
                            local sizeX = math.clamp((input.Position.X - saturationframe.AbsolutePosition.X) / saturationframe.AbsoluteSize.X, 0, 1)
                            local sizeY = 1 - math.clamp((input.Position.Y - saturationframe.AbsolutePosition.Y) / saturationframe.AbsoluteSize.Y, 0, 1)
                            local posY = math.clamp(((input.Position.Y - saturationframe.AbsolutePosition.Y) / saturationframe.AbsoluteSize.Y) * saturationframe.AbsoluteSize.Y, 0, saturationframe.AbsoluteSize.Y)
                            local posX = math.clamp(((input.Position.X - saturationframe.AbsolutePosition.X) / saturationframe.AbsoluteSize.X) * saturationframe.AbsoluteSize.X, 0, saturationframe.AbsoluteSize.X)

                            saturationpicker.Position = UDim2.new(0, posX, 0, posY)

                            sat = sizeX
                            val = sizeY
                            hsv = Color3.fromHSV(hue, sizeX, sizeY)

                            box.Text = formatcolor(hsv)

                            saturationframe.BackgroundColor3 = hsv
                            icon.BackgroundColor3 = hsv
                            icongradient.Color = utility.gradient { hsv, utility.changecolor(hsv, -200) }

                            if flag then
                                library.flags[flag] = hsv
                            end

                            callback(hsv)
                        end

                        saturationframe.InputBegan:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                                slidingsaturation = true
                                utility.tween(saturationpicker, { 0.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out }, {
                                    Size = UDim2.new(0, 11, 0, 11)
                                })
                                updatesatval(input)
                            end
                        end)

                        saturationframe.InputEnded:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                                slidingsaturation = false
                                utility.tween(saturationpicker, { 0.16, Enum.EasingStyle.Back, Enum.EasingDirection.Out }, {
                                    Size = UDim2.new(0, 8, 0, 8)
                                })
                            end
                        end)

                        utility.connect(services.InputService.InputChanged, function(input)
                            if input.UserInputType == Enum.UserInputType.MouseMovement then
                                if slidingsaturation then
                                    updatesatval(input)
                                end
                            end
                        end)

                        local function set(color)
                            if type(color) == "table" then
                                color = Color3.fromRGB(unpack(color))
                            end

                            hue, sat, val = color:ToHSV()
                            hsv = Color3.fromHSV(hue, sat, val)

                            utility.tween(saturationframe, { 0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.Out }, { BackgroundColor3 = hsv })
                            utility.tween(icon, { 0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.Out }, { BackgroundColor3 = hsv })
                            animateColorSequence(icongradient, utility.gradient { hsv, utility.changecolor(hsv, -200) }, 0.16)
                            utility.tween(saturationpicker, { 0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.Out }, {
                                Position = UDim2.new(sat, 0, 1 - val, 0)
                            })
                            utility.tween(huepicker, { 0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.Out }, {
                                Position = UDim2.new(0, 0, 1 - hue, 0)
                            })

                            box.Text = formatcolor(hsv)

                            if flag then
                                library.flags[flag] = hsv
                            end

                            callback(hsv)
                        end

                        local toggled = false

                        local function toggle()
                            if not switchingtabs then
                                toggled = not toggled

                                if toggled then
                                    task.spawn(function()
                                        while toggled do
                                            for i = 0, 1, 0.0015 do
                                                if not toggled then
                                                    return
                                                end

                                                local color = Color3.fromHSV(i, 1, 1)
                                                set(color)

                                                task.wait()
                                            end
                                        end
                                    end)
                                end

                                local enabledtransparency = toggled and 0 or 1
                                utility.tween(enablediconholder, { 0.2 }, { BackgroundTransparency = enabledtransparency })

                                local textcolor = toggled and library.accent or Color3.fromRGB(180, 180, 180)
                                utility.tween(rainbowtxt, { 0.2 }, { TextColor3 = textcolor })

                                if toggled then
                                    if not table.find(accentobjects.text, rainbowtxt) then
                                        table.insert(accentobjects.text, rainbowtxt)
                                    end
                                elseif table.find(accentobjects.text, rainbowtxt) then
                                    table.remove(accentobjects.text, table.find(accentobjects.text, rainbowtxt))
                                end
                            end
                        end

                        rainbowtoggleholder.MouseButton1Click:Connect(toggle)

                    box.FocusLost:Connect(function()
                        local valid = false
                        local compact = box.Text:gsub("%s+", "")
                        local hex = compact:match("^#?(%x%x%x%x%x%x)$")

                        if hex then
                            set(Color3.fromRGB(
                                tonumber(hex:sub(1, 2), 16),
                                tonumber(hex:sub(3, 4), 16),
                                tonumber(hex:sub(5, 6), 16)
                            ))
                            valid = true
                        else
                            local values = {}
                            for value in box.Text:gmatch("%-?%d+%.?%d*") do
                                values[#values + 1] = tonumber(value)
                            end
                            if #values >= 3 then
                                set(Color3.fromRGB(
                                    math.clamp(values[1], 0, 255),
                                    math.clamp(values[2], 0, 255),
                                    math.clamp(values[3], 0, 255)
                                ))
                                valid = true
                            end
                        end
                        if not valid then
                            box.Text = formatcolor(hsv)
                        end
                    end)

                        if default then
                            set(default)
                        end

                        if flag then
                            flags[flag] = set
                        end

                        local colorpickertypes = utility.table()

                        function colorpickertypes:Set(color)
                            set(color)
                        end

                        return colorpickertypes
                    end

                    if #sectioncontent:GetChildren() - 1 <= max then
                        sectionholder.Size = UDim2.new(1, -1, 0, sectionlist.AbsoluteContentSize.Y + (sidebar and 42 or 28))
                    end

                    return toggletypes
                end


                function sectiontypes:Box(options)
                    options = utility.table(options)
                    local name = options.name
                    local placeholder = options.placeholder or ""
                    local default = options.default
                    local boxtype = options.type or "string"
                    local flag = options.pointer
                    local callback = options.callback or function() end

                    local boxholder = utility.create("Frame", {
                        Size = UDim2.new(1, -5, 0, 32),
                        ClipsDescendants = true,
                        BorderColor3 = Color3.fromRGB(27, 42, 53),
                        BackgroundTransparency = 1,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        Parent = sectioncontent
                    })

                    local title = utility.create("TextLabel", {
                        ZIndex = 7,
                        Size = UDim2.new(1, -2, 0, 13),
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 1, 0, 0),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        FontSize = Enum.FontSize.Size14,
                        TextStrokeTransparency = 0,
                        TextSize = 13,
                        TextColor3 = Color3.fromRGB(210, 210, 210),
                        Text = name,
                        Font = Enum.Font.Code,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = boxholder
                    })

                    local box = utility.create("TextBox", {
                        ZIndex = 10,
                        Size = UDim2.new(1, -4, 0, 13),
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 2, 0, 17),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        FontSize = Enum.FontSize.Size14,
                        TextStrokeTransparency = 0,
                        PlaceholderColor3 = Color3.fromRGB(120, 120, 120),
                        TextSize = 13,
                        TextColor3 = Color3.fromRGB(210, 210, 210),
                        Text = "",
                        PlaceholderText = placeholder,
                        Font = Enum.Font.Code,
                        Parent = boxholder
                    })

                    local bg = utility.create("Frame", {
                        ZIndex = 9,
                        Size = UDim2.new(1, 0, 1, 0),
                        BorderColor3 = Color3.fromRGB(40, 40, 40),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        Parent = box
                    })

                    local bggradient = utility.create("UIGradient", {
                        Rotation = 90,
                        Color = ColorSequence.new(Color3.fromRGB(35, 35, 35), Color3.fromRGB(25, 25, 25)),
                        Parent = bg
                    })

                    local grayborder = utility.create("Frame", {
                        ZIndex = 8,
                        Size = UDim2.new(1, 2, 1, 2),
                        Position = UDim2.new(0, -1, 0, -1),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Color3.fromRGB(40, 40, 40),
                        Parent = box
                    })

                    local blackborder = utility.create("Frame", {
                        ZIndex = 7,
                        Size = UDim2.new(1, 2, 1, 2),
                        Position = UDim2.new(0, -1, 0, -1),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Color3.fromRGB(10, 10, 10),
                        Parent = grayborder
                    })

                    if #sectioncontent:GetChildren() - 1 <= max then
                        sectionholder.Size = UDim2.new(1, -1, 0, sectionlist.AbsoluteContentSize.Y + (sidebar and 42 or 28))
                    end

                    if flag then
                        library.flags[flag] = default or ""
                    end

                    local function set(str)
                        str = tostring(str or "")
                        if boxtype:lower() == "number" then
                            str = str:gsub("[^%d%.%-]+", "")
                        end

                        box.Text = str

                        if flag then
                            library.flags[flag] = str
                        end

                        callback(str)
                    end

                    if default then
                        set(default)
                    end

                    if boxtype:lower() == "number" then
                        box:GetPropertyChangedSignal("Text"):Connect(function()
                            box.Text = box.Text:gsub("[^%d%.%-]+", "")
                        end)
                    end

                    box.FocusLost:Connect(function()
                        set(box.Text)
                        utility.tween(box, { 0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out }, {
                            Size = UDim2.new(1, -4, 0, 13),
                            Position = UDim2.new(0, 2, 0, 17),
                            TextColor3 = Color3.fromRGB(210, 210, 210)
                        })
                        utility.tween(grayborder, { 0.18 }, { BackgroundColor3 = Color3.fromRGB(40, 40, 40) })
                        utility.tween(title, { 0.18 }, { TextColor3 = Color3.fromRGB(210, 210, 210) })
                    end)

                    box.Focused:Connect(function()
                        utility.tween(box, { 0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out }, {
                            Size = UDim2.new(1, -2, 0, 15),
                            Position = UDim2.new(0, 1, 0, 16),
                            TextColor3 = Color3.fromRGB(240, 240, 240)
                        })
                        utility.tween(grayborder, { 0.18 }, { BackgroundColor3 = Color3.fromRGB(70, 70, 70) })
                        utility.tween(title, { 0.18 }, { TextColor3 = Color3.fromRGB(235, 235, 235) })
                    end)

                    if flag then
                        flags[flag] = set
                    end

                    local boxtypes = utility.table()

                    function boxtypes:Set(str)
                        set(str)
                    end

                    return boxtypes
                end

                function sectiontypes:Slider(options)
                    options = utility.table(options)
                    local name = options.name
                    local min = tonumber(options.minimum or options.min) or 0
                    local slidermax = tonumber(options.maximum or options.max) or 100
                    if slidermax <= min then slidermax = min + 1 end
                    local valuetext = options.value or "[value]/" .. slidermax
                    local increment = math.max(tonumber(options.increment or options.decimals) or 1, 0.0001)

                    local function quantize(value)
                        value = math.clamp(tonumber(value) or min, min, slidermax)
                        local steps = math.floor(((value - min) / increment) + 0.5)
                        local rounded = math.clamp(min + steps * increment, min, slidermax)
                        return tonumber(string.format("%.4f", rounded))
                    end

                    local default = quantize(options.default or min)
                    local flag = options.pointer
                    local callback = options.callback or function() end

                    local sliderholder = utility.create("Frame", {
                        Size = UDim2.new(1, -5, 0, 28),
                        BackgroundTransparency = 1,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        Parent = sectioncontent
                    })

                    local slider = utility.create("Frame", {
                        ZIndex = 10,
                        Size = UDim2.new(1, -4, 0, 9),
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 2, 1, -11),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        Parent = sliderholder
                    })

                    local grayborder = utility.create("Frame", {
                        ZIndex = 8,
                        Size = UDim2.new(1, 2, 1, 2),
                        Position = UDim2.new(0, -1, 0, -1),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Color3.fromRGB(40, 40, 40),
                        Parent = slider
                    })

                    local sliderBlackborder = utility.create("Frame", {
                        ZIndex = 7,
                        Size = UDim2.new(1, 2, 1, 2),
                        Position = UDim2.new(0, -1, 0, -1),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Color3.fromRGB(10, 10, 10),
                        Parent = grayborder
                    })

                    local bg = utility.create("Frame", {
                        ZIndex = 9,
                        Size = UDim2.new(1, 0, 1, 0),
                        BorderColor3 = Color3.fromRGB(40, 40, 40),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        Parent = slider
                    })

                    utility.create("UIGradient", {
                        Rotation = 90,
                        Color = ColorSequence.new(Color3.fromRGB(35, 35, 35), Color3.fromRGB(25, 25, 25)),
                        Parent = bg
                    })

                    local fill = utility.create("Frame", {
                        ZIndex = 11,
                        Size = UDim2.new((default - min) / (slidermax - min), 0, 1, 0),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        Parent = slider
                    })

                    if sliderRoundness then
                        utility.setfixedroundness(grayborder, sliderRoundness)
                        utility.setfixedroundness(sliderBlackborder, sliderRoundness)
                        utility.setfixedroundness(bg, sliderRoundness)
                        utility.setfixedroundness(fill, sliderRoundness)
                    end

                    local fillgradient = utility.create("UIGradient", {
                        Rotation = 90,
                        Color = utility.gradient { library.accent, Color3.fromRGB(25, 25, 25) },
                        Parent = fill
                    })

                    accentobjects.gradient[fillgradient] = function(color)
                        return utility.gradient { color, Color3.fromRGB(25, 25, 25) }
                    end

                    local valuelabel = utility.create("TextLabel", {
                        ZIndex = 12,
                        Size = UDim2.new(1, 0, 1, 0),
                        BackgroundTransparency = 1,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        FontSize = Enum.FontSize.Size14,
                        TextStrokeTransparency = 0,
                        TextSize = 13,
                        TextColor3 = Color3.fromRGB(210, 210, 210),
                        Text = valuetext:gsub("%[value%]", tostring(default)),
                        Font = Enum.Font.Code,
                        Parent = slider
                    })

                    local title = utility.create("TextLabel", {
                        ZIndex = 7,
                        Size = UDim2.new(1, -2, 0, 13),
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 1, 0, 0),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        FontSize = Enum.FontSize.Size14,
                        TextStrokeTransparency = 0,
                        TextSize = 13,
                        TextColor3 = Color3.fromRGB(210, 210, 210),
                        Text = name,
                        Font = Enum.Font.Code,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = sliderholder
                    })

                    if #sectioncontent:GetChildren() - 1 <= max then
                        sectionholder.Size = UDim2.new(1, -1, 0, sectionlist.AbsoluteContentSize.Y + (sidebar and 42 or 28))
                    end

                    local sliding = false
                    local sliderHovering = false

                    slider.MouseEnter:Connect(function()
                        sliderHovering = true
                        utility.tween(slider, { 0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.Out }, {
                            Size = UDim2.new(1, -2, 0, 11),
                            Position = UDim2.new(0, 1, 1, -12)
                        })
                        utility.tween(title, { 0.16 }, { TextColor3 = Color3.fromRGB(235, 235, 235) })
                        utility.tween(valuelabel, { 0.16 }, { TextColor3 = Color3.fromRGB(235, 235, 235) })
                    end)

                    slider.MouseLeave:Connect(function()
                        sliderHovering = false
                        if not sliding then
                            utility.tween(slider, { 0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out }, {
                                Size = UDim2.new(1, -4, 0, 9),
                                Position = UDim2.new(0, 2, 1, -11)
                            })
                            utility.tween(title, { 0.18 }, { TextColor3 = Color3.fromRGB(210, 210, 210) })
                            utility.tween(valuelabel, { 0.18 }, { TextColor3 = Color3.fromRGB(210, 210, 210) })
                        end
                    end)

                    local function slide(input)
                        if slider.AbsoluteSize.X <= 0 then return end
                        local sizeX = math.clamp((input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
                        local value = quantize(min + sizeX * (slidermax - min))
                        local newsizeX = (value - min) / (slidermax - min)

                        utility.tween(fill, { 0.06 }, { Size = UDim2.new(newsizeX, 0, 1, 0) })
                        valuelabel.Text = valuetext:gsub("%[value%]", tostring(value))

                        if flag then
                            library.flags[flag] = value
                        end

                        callback(value)
                    end

                    slider.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            sliding = true
                            utility.tween(slider, { 0.09, Enum.EasingStyle.Quad, Enum.EasingDirection.Out }, {
                                Size = UDim2.new(1, 0, 0, 11),
                                Position = UDim2.new(0, 0, 1, -12)
                            })
                            utility.tween(valuelabel, { 0.09 }, { TextColor3 = Color3.fromRGB(255, 255, 255) })
                            slide(input)
                        end
                    end)

                    slider.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            sliding = false
                            utility.tween(slider, { 0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out }, {
                                Size = sliderHovering and UDim2.new(1, -2, 0, 11) or UDim2.new(1, -4, 0, 9),
                                Position = sliderHovering and UDim2.new(0, 1, 1, -12) or UDim2.new(0, 2, 1, -11)
                            })
                            utility.tween(valuelabel, { 0.18 }, { TextColor3 = sliderHovering and Color3.fromRGB(235, 235, 235) or Color3.fromRGB(210, 210, 210) })
                            if not sliderHovering then
                                utility.tween(title, { 0.18 }, { TextColor3 = Color3.fromRGB(210, 210, 210) })
                            end
                        end
                    end)

                    utility.connect(services.InputService.InputChanged, function(input)
                        if input.UserInputType == Enum.UserInputType.MouseMovement then
                            if sliding then
                                slide(input)
                            end
                        end
                    end)

                    local function set(value)
                        value = quantize(value)
                        local newsizeX = (value - min) / (slidermax - min)

                        fill.Size = UDim2.new(newsizeX, 0, 1, 0)
                        valuelabel.Text = valuetext:gsub("%[value%]", tostring(value))

                        if flag then
                            library.flags[flag] = value
                        end

                        callback(value)
                    end

                    if default then
                        set(default)
                    end

                    if flag then
                        flags[flag] = set
                    end

                    local slidertypes = utility.table()

                    slidertypes.Object = sliderholder

                    function slidertypes:Set(value)
                        set(value)
                    end

                    function slidertypes:SetVisible(visible)
                        sliderholder.Visible = visible == true
                        task.defer(function()
                            if sectionholder.Parent then
                                sectionholder.Size = UDim2.new(1, -1, 0, sectionlist.AbsoluteContentSize.Y + (sidebar and 42 or 28))
                            end
                        end)
                    end

                    return slidertypes
                end


                function sectiontypes:Dropdown(options)
                    options = utility.table(options)
                    local name = options.name
                    local content = options["options"] or {}
                    local maxoptions = options.maximum and (options.maximum > 1 and options.maximum)
                    local default = options.default or maxoptions and {}
                    local flag = options.pointer
                    local callback = options.callback or function() end

                    if maxoptions then
                        local filtered = {}
                        for _, def in next, default do
                            if table.find(content, def) and not table.find(filtered, def) then
                                filtered[#filtered + 1] = def
                            end
                        end
                        default = filtered
                    else
                        if not table.find(content, default) then
                            default = nil
                        end
                    end

                    local defaulttext = default and ((type(default) == "table" and table.concat(default, ", ")) or default)

                    local opened = false

                    local dropdownholder = utility.create("Frame", {
                        Size = UDim2.new(1, -5, 0, 32),
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 0, 0, 0),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        Parent = sectioncontent
                    })

                    local dropdown = utility.create("TextButton", {
                        ZIndex = 10,
                        Size = UDim2.new(1, -4, 0, 13),
                        BorderColor3 = Color3.fromRGB(40, 40, 40),
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 2, 0, 17),
                        BackgroundColor3 = Color3.fromRGB(25, 25, 25),
                        AutoButtonColor = false,
                        FontSize = Enum.FontSize.Size14,
                        TextStrokeTransparency = 0,
                        TextSize = 13,
                        TextColor3 = default and (defaulttext ~= "" and Color3.fromRGB(210, 210, 210) or Color3.fromRGB(120, 120, 120)) or Color3.fromRGB(120, 120, 120),
                        Text = default and (defaulttext ~= "" and defaulttext or "NONE") or "NONE",
                        TextTruncate = Enum.TextTruncate.AtEnd,
                        Font = Enum.Font.Code,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = dropdownholder
                    })

                    local bg = utility.create("Frame", {
                        ZIndex = 9,
                        Size = UDim2.new(1, 6, 1, 0),
                        BorderColor3 = Color3.fromRGB(40, 40, 40),
                        Position = UDim2.new(0, -6, 0, 0),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        Parent = dropdown
                    })

                    local bggradient = utility.create("UIGradient", {
                        Rotation = 90,
                        Color = ColorSequence.new(Color3.fromRGB(35, 35, 35), Color3.fromRGB(25, 25, 25)),
                        Parent = bg
                    })

                    local textpadding = utility.create("UIPadding", {
                        PaddingLeft = UDim.new(0, 6),
                        Parent = dropdown
                    })

                    local grayborder = utility.create("Frame", {
                        ZIndex = 8,
                        Size = UDim2.new(1, 8, 1, 2),
                        Position = UDim2.new(0, -7, 0, -1),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Color3.fromRGB(40, 40, 40),
                        Parent = dropdown
                    })

                    utility.create("Frame", {
                        ZIndex = 7,
                        Size = UDim2.new(1, 2, 1, 2),
                        Position = UDim2.new(0, -1, 0, -1),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Color3.fromRGB(10, 10, 10),
                        Parent = grayborder
                    })

                    local icon = utility.create("TextLabel", {
                        ZIndex = 11,
                        Size = UDim2.new(0, 13, 1, 0),
                        BackgroundTransparency = 1,
                        Position = UDim2.new(1, -13, 0, 0),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        FontSize = Enum.FontSize.Size12,
                        TextStrokeTransparency = 0,
                        TextSize = 12,
                        TextColor3 = Color3.fromRGB(210, 210, 210),
                        Text = "+",
                        Font = Enum.Font.Gotham,
                        Parent = dropdown
                    })

                    local title = utility.create("TextLabel", {
                        ZIndex = 7,
                        Size = UDim2.new(1, -2, 0, 13),
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 1, 0, 0),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        FontSize = Enum.FontSize.Size14,
                        TextStrokeTransparency = 0,
                        TextSize = 13,
                        TextColor3 = Color3.fromRGB(210, 210, 210),
                        Text = name,
                        Font = Enum.Font.Code,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = dropdownholder
                    })

                    dropdown.MouseEnter:Connect(function()
                        utility.tween(dropdown, { 0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.Out }, {
                            Size = UDim2.new(1, -2, 0, 15),
                            Position = UDim2.new(0, 1, 0, 16),
                            TextColor3 = Color3.fromRGB(235, 235, 235)
                        })
                        utility.tween(title, { 0.16 }, { TextColor3 = Color3.fromRGB(235, 235, 235) })
                        utility.tween(icon, { 0.16 }, { TextColor3 = Color3.fromRGB(245, 245, 245) })
                    end)

                    dropdown.MouseLeave:Connect(function()
                        utility.tween(dropdown, { 0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out }, {
                            Size = UDim2.new(1, -4, 0, 13),
                            Position = UDim2.new(0, 2, 0, 17),
                            TextColor3 = dropdown.Text ~= "NONE" and Color3.fromRGB(210, 210, 210) or Color3.fromRGB(120, 120, 120)
                        })
                        utility.tween(title, { 0.18 }, { TextColor3 = Color3.fromRGB(210, 210, 210) })
                        utility.tween(icon, { 0.18 }, { TextColor3 = Color3.fromRGB(210, 210, 210) })
                    end)

                    local contentframe = utility.create("Frame", {
                        ZIndex = 9,
                        Size = UDim2.new(1, -4, 1, -38),
                        Position = UDim2.new(0, 2, 0, 36),
                        BorderSizePixel = 0,
                        Visible = false,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        Parent = dropdownholder
                    })

                    contentframe.DescendantAdded:Connect(function(descendant)
                        if not opened then
                            task.wait()
                            fadeObject(descendant, false)
                        end
                    end)

                    local contentframegradient = utility.create("UIGradient", {
                        Rotation = 90,
                        Color = ColorSequence.new(Color3.fromRGB(35, 35, 35), Color3.fromRGB(25, 25, 25)),
                        Parent = contentframe
                    })

                    local grayborder = utility.create("Frame", {
                        ZIndex = 8,
                        Size = UDim2.new(1, 2, 1, 2),
                        Position = UDim2.new(0, -1, 0, -1),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Color3.fromRGB(40, 40, 40),
                        Parent = contentframe
                    })

                    utility.create("Frame", {
                        ZIndex = 7,
                        Size = UDim2.new(1, 2, 1, 2),
                        Position = UDim2.new(0, -1, 0, -1),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Color3.fromRGB(10, 10, 10),
                        Parent = grayborder
                    })

                    local dropdowncontent = utility.create("Frame", {
                        Size = UDim2.new(1, -2, 1, -2),
                        Position = UDim2.new(0, 1, 0, 1),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        Parent = contentframe
                    })

                    local dropdowncontentlist = utility.create("UIListLayout", {
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        Padding = UDim.new(0, 2),
                        Parent = dropdowncontent
                    })

                    local option = utility.create("TextButton", {
                        ZIndex = 12,
                        Size = UDim2.new(1, 0, 0, 16),
                        BorderColor3 = Color3.fromRGB(50, 50, 50),
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 2, 0, 2),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Color3.fromRGB(22, 22, 22),
                        AutoButtonColor = false,
                        FontSize = Enum.FontSize.Size14,
                        TextStrokeTransparency = 0,
                        TextSize = 13,
                        TextColor3 = Color3.fromRGB(150, 150, 150),
                        Text = "",
                        Font = Enum.Font.Code,
                        TextXAlignment = Enum.TextXAlignment.Left
                    })

                    utility.create("UIPadding", {
                        PaddingLeft = UDim.new(0, 10),
                        Parent = option
                    })

                    if #sectioncontent:GetChildren() - 1 <= max then
                        sectionholder.Size = UDim2.new(1, -1, 0, sectionlist.AbsoluteContentSize.Y + (sidebar and 42 or 28))
                    end

                    local opening = false

                    local function opendropdown()
                        if not opening then
                            opening = true

                            opened = not opened

                            utility.tween(icon, { 0.2 }, { TextTransparency = 1, TextStrokeTransparency = 1 }, function()
                                icon.Text = opened and "-" or "+"
                            end)

                            if opened then
                                contentframe.Position = UDim2.new(0, 2, 0, 31)
                                utility.tween(dropdownholder, { 0.2 }, { Size = UDim2.new(1, -5, 0, dropdowncontentlist.AbsoluteContentSize.Y + 40) })
                            end

                            if not opened then
                                utility.tween(contentframe, { 0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.In }, {
                                    Position = UDim2.new(0, 2, 0, 31)
                                })
                            end

                            local tween = utility.makevisible(contentframe, opened)

                            if opened then
                                utility.tween(contentframe, { 0.24, Enum.EasingStyle.Quint, Enum.EasingDirection.Out }, {
                                    Position = UDim2.new(0, 2, 0, 36)
                                })
                            end

                            tween.Completed:Wait()

                            if not opened then
                                local tween = utility.tween(dropdownholder, { 0.2 }, { Size = UDim2.new(1, -5, 0, 32) })
                                tween.Completed:Wait()
                            end

                            utility.tween(icon, { 0.2 }, { TextTransparency = 0, TextStrokeTransparency = 0 })

                            opening = false
                        end
                    end

                    dropdown.MouseButton1Click:Connect(opendropdown)

                    local chosen = maxoptions and {}
                    local choseninstances = {}
                    local optioninstances = {}

                    local function optionischosen(opt)
                        return maxoptions and table.find(chosen, opt) ~= nil or chosen == opt
                    end

                    local function bindoptionmotion(optionbtn, opt)
                        optionbtn.MouseEnter:Connect(function()
                            if not optionischosen(opt) then
                                utility.tween(optionbtn, { 0.14, Enum.EasingStyle.Quart, Enum.EasingDirection.Out }, {
                                    BackgroundTransparency = 0.55,
                                    TextColor3 = Color3.fromRGB(200, 200, 200)
                                })
                            end
                        end)

                        optionbtn.MouseLeave:Connect(function()
                            if not optionischosen(opt) then
                                utility.tween(optionbtn, { 0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.Out }, {
                                    BackgroundTransparency = 1,
                                    TextColor3 = Color3.fromRGB(150, 150, 150)
                                })
                            end
                        end)
                    end

                    if flag then
                        library.flags[flag] = default
                    end

                    for _, opt in next, content do
                        if not maxoptions then
                            local optionbtn = option:Clone()
                            optionbtn.Parent = dropdowncontent
                            optionbtn.Text = opt
                            bindoptionmotion(optionbtn, opt)

                            optioninstances[opt] = optionbtn

                            if default == opt then
                                chosen = opt
                                optionbtn.BackgroundTransparency = 0
                                optionbtn.TextColor3 = Color3.fromRGB(210, 210, 210)
                            end

                            optionbtn.MouseButton1Click:Connect(function()
                                if chosen ~= opt then
                                    for _, optbtn in next, dropdowncontent:GetChildren() do
                                        if optbtn ~= optionbtn and optbtn:IsA("TextButton") then
                                            utility.tween(optbtn, { 0.2 }, { BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(150, 150, 150) })
                                        end
                                    end

                                    utility.tween(optionbtn, { 0.2 }, { BackgroundTransparency = 0, TextColor3 = Color3.fromRGB(210, 210, 210) })

                                    local tween = utility.tween(dropdown, { 0.2 }, { TextTransparency = 1, TextStrokeTransparency = 1 }, function()
                                        dropdown.Text = opt
                                    end)

                                    chosen = opt

                                    tween.Completed:Wait()

                                    utility.tween(dropdown, { 0.2 }, { TextTransparency = 0, TextStrokeTransparency = 0, TextColor3 = Color3.fromRGB(210, 210, 210) })

                                    if flag then
                                        library.flags[flag] = opt
                                    end

                                    callback(opt)
                                else
                                    utility.tween(optionbtn, { 0.2 }, { BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(150, 150, 150) })

                                    local tween = utility.tween(dropdown, { 0.2 }, { TextTransparency = 1, TextStrokeTransparency = 1 }, function()
                                        dropdown.Text = "NONE"
                                    end)

                                    tween.Completed:Wait()

                                    utility.tween(dropdown, { 0.2 }, { TextTransparency = 0, TextStrokeTransparency = 0, TextColor3 = Color3.fromRGB(150, 150, 150) })
                                    chosen = nil

                                    if flag then
                                        library.flags[flag] = nil
                                    end

                                    callback(nil)
                                end
                            end)
                        else
                            local optionbtn = option:Clone()
                            optionbtn.Parent = dropdowncontent
                            optionbtn.Text = opt
                            bindoptionmotion(optionbtn, opt)

                            optioninstances[opt] = optionbtn

                            if table.find(default, opt) then
                                table.insert(chosen, opt)
                                table.insert(choseninstances, optionbtn)
                                optionbtn.BackgroundTransparency = 0
                                optionbtn.TextColor3 = Color3.fromRGB(210, 210, 210)
                            end

                            optionbtn.MouseButton1Click:Connect(function()
                                if not table.find(chosen, opt) then
                                    if #chosen >= maxoptions then
                                        table.remove(chosen, 1)
                                        utility.tween(choseninstances[1], { 0.2 }, { BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(150, 150, 150) })
                                        table.remove(choseninstances, 1)
                                    end

                                    utility.tween(optionbtn, { 0.2 }, { BackgroundTransparency = 0, TextColor3 = Color3.fromRGB(210, 210, 210) })

                                    table.insert(chosen, opt)
                                    table.insert(choseninstances, optionbtn)

                                    local tween = utility.tween(dropdown, { 0.2 }, { TextTransparency = 1, TextStrokeTransparency = 1 }, function()
                                        dropdown.Text = table.concat(chosen, ", ")
                                    end)

                                    tween.Completed:Wait()

                                    utility.tween(dropdown, { 0.2 }, { TextTransparency = 0, TextStrokeTransparency = 0, TextColor3 = Color3.fromRGB(210, 210, 210) })

                                    if flag then
                                        library.flags[flag] = chosen
                                    end

                                    callback(chosen)
                                else
                                    utility.tween(optionbtn, { 0.2 }, { BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(150, 150, 150) })

                                    table.remove(chosen, table.find(chosen, opt))
                                    table.remove(choseninstances, table.find(choseninstances, optionbtn))

                                    local tween = utility.tween(dropdown, { 0.2 }, { TextTransparency = 1, TextStrokeTransparency = 1 }, function()
                                        dropdown.Text = table.concat(chosen, ", ") ~= "" and table.concat(chosen, ", ") or "NONE"
                                    end)

                                    tween.Completed:Wait()

                                    utility.tween(dropdown, { 0.2 }, { TextTransparency = 0, TextStrokeTransparency = 0, TextColor3 = table.concat(chosen, ", ") ~= "" and Color3.fromRGB(210, 210, 210) or Color3.fromRGB(150, 150, 150) })

                                    if flag then
                                        library.flags[flag] = chosen
                                    end

                                    callback(chosen)
                                end
                            end)
                        end
                    end

                    local function set(opt)
                        if not maxoptions then
                            if optioninstances[opt] then
                                for _, optbtn in next, dropdowncontent:GetChildren() do
                                    if optbtn ~= optioninstances[opt] and optbtn:IsA("TextButton") then
                                        utility.tween(optbtn, { 0.2 }, { BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(150, 150, 150) })
                                    end
                                end

                                utility.tween(optioninstances[opt], { 0.2 }, { BackgroundTransparency = 0, TextColor3 = Color3.fromRGB(210, 210, 210) })

                                local tween = utility.tween(dropdown, { 0.2 }, { TextTransparency = 1, TextStrokeTransparency = 1 }, function()
                                    dropdown.Text = opt
                                end)

                                chosen = opt

                                tween.Completed:Wait()

                                utility.tween(dropdown, { 0.2 }, { TextTransparency = 0, TextStrokeTransparency = 0, TextColor3 = Color3.fromRGB(210, 210, 210) })

                                if flag then
                                    library.flags[flag] = opt
                                end

                                callback(opt)
                            else
                                for _, optbtn in next, dropdowncontent:GetChildren() do
                                    if optbtn:IsA("TextButton") then
                                        utility.tween(optbtn, { 0.2 }, { BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(150, 150, 150) })
                                    end
                                end

                                local tween = utility.tween(dropdown, { 0.2 }, { TextTransparency = 1, TextStrokeTransparency = 1 }, function()
                                    dropdown.Text = "NONE"
                                end)

                                tween.Completed:Wait()

                                utility.tween(dropdown, { 0.2 }, { TextTransparency = 0, TextStrokeTransparency = 0, TextColor3 = Color3.fromRGB(150, 150, 150) })
                                chosen = nil

                                if flag then
                                    library.flags[flag] = nil
                                end

                                callback(nil)
                            end
                        else
                            table.clear(chosen)
                            table.clear(choseninstances)

                            if not opt then
                                local tween = utility.tween(dropdown, { 0.2 }, { TextTransparency = 1, TextStrokeTransparency = 1 }, function()
                                    dropdown.Text = table.concat(chosen, ", ") ~= "" and table.concat(chosen, ", ") or "NONE"
                                end)

                                tween.Completed:Wait()

                                utility.tween(dropdown, { 0.2 }, { TextTransparency = 0, TextStrokeTransparency = 0, TextColor3 = table.concat(chosen, ", ") ~= "" and Color3.fromRGB(210, 210, 210) or Color3.fromRGB(150, 150, 150) })

                                if flag then
                                    library.flags[flag] = chosen
                                end

                                callback(chosen)
                            else
                                for _, opti in next, opt do
                                    if optioninstances[opti] then
                                        if #chosen >= maxoptions then
                                            table.remove(chosen, 1)
                                            utility.tween(choseninstances[1], { 0.2 }, { BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(150, 150, 150) })
                                            table.remove(choseninstances, 1)
                                        end

                                        utility.tween(optioninstances[opti], { 0.2 }, { BackgroundTransparency = 0, TextColor3 = Color3.fromRGB(210, 210, 210) })

                                        if not table.find(chosen, opti) then
                                            table.insert(chosen, opti)
                                        end

                                        if not table.find(choseninstances, optioninstances[opti]) then
                                            table.insert(choseninstances, optioninstances[opti])
                                        end

                                        local tween = utility.tween(dropdown, { 0.2 }, { TextTransparency = 1, TextStrokeTransparency = 1 }, function()
                                            dropdown.Text = table.concat(chosen, ", ")
                                        end)

                                        tween.Completed:Wait()

                                        utility.tween(dropdown, { 0.2 }, { TextTransparency = 0, TextStrokeTransparency = 0, TextColor3 = Color3.fromRGB(210, 210, 210) })

                                        if flag then
                                            library.flags[flag] = chosen
                                        end

                                        callback(chosen)
                                    end
                                end
                            end
                        end
                    end

                    if flag then
                        flags[flag] = set
                    end

                    local dropdowntypes = utility.table()

                    dropdowntypes.Object = dropdownholder

                    function dropdowntypes:Set(option)
                        set(option)
                    end

                    function dropdowntypes:SetVisible(visible)
                        visible = visible == true
                        if not visible then
                            opened = false
                            opening = false
                            contentframe.Visible = false
                            contentframe.Position = UDim2.new(0, 2, 0, 31)
                            dropdownholder.Size = UDim2.new(1, -5, 0, 32)
                            icon.Text = "+"
                        end
                        dropdownholder.Visible = visible
                        task.defer(function()
                            if sectionholder.Parent then
                        sectionholder.Size = UDim2.new(1, -1, 0, sectionlist.AbsoluteContentSize.Y + (sidebar and 42 or 28))
                            end
                        end)
                    end

                    function dropdowntypes:Refresh(content)
                        if maxoptions then
                            table.clear(chosen)
                        end

                        table.clear(choseninstances)
                        table.clear(optioninstances)

                        for _, optbtn in next, dropdowncontent:GetChildren() do
                            if optbtn:IsA("TextButton") then
                                optbtn:Destroy()
                            end
                        end

                        set()

                        for _, opt in next, content do
                            if not maxoptions then
                                local optionbtn = option:Clone()
                                optionbtn.Parent = dropdowncontent
                                optionbtn.BackgroundTransparency = 1
                                optionbtn.Text = opt
                                bindoptionmotion(optionbtn, opt)

                                optioninstances[opt] = optionbtn

                                optionbtn.MouseButton1Click:Connect(function()
                                    if chosen ~= opt then
                                        for _, optbtn in next, dropdowncontent:GetChildren() do
                                            if optbtn ~= optionbtn and optbtn:IsA("TextButton") then
                                                utility.tween(optbtn, { 0.2 }, { BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(150, 150, 150) })
                                            end
                                        end

                                        utility.tween(optionbtn, { 0.2 }, { BackgroundTransparency = 0, TextColor3 = Color3.fromRGB(210, 210, 210) })

                                        local tween = utility.tween(dropdown, { 0.2 }, { TextTransparency = 1, TextStrokeTransparency = 1 }, function()
                                            dropdown.Text = opt
                                        end)

                                        chosen = opt

                                        tween.Completed:Wait()

                                        utility.tween(dropdown, { 0.2 }, { TextTransparency = 0, TextStrokeTransparency = 0, TextColor3 = Color3.fromRGB(210, 210, 210) })

                                        if flag then
                                            library.flags[flag] = opt
                                        end

                                        callback(opt)
                                    else
                                        utility.tween(optionbtn, { 0.2 }, { BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(150, 150, 150) })

                                        local tween = utility.tween(dropdown, { 0.2 }, { TextTransparency = 1, TextStrokeTransparency = 1 }, function()
                                            dropdown.Text = "NONE"
                                        end)

                                        tween.Completed:Wait()

                                        utility.tween(dropdown, { 0.2 }, { TextTransparency = 0, TextStrokeTransparency = 0, TextColor3 = Color3.fromRGB(150, 150, 150) })
                                        chosen = nil

                                        if flag then
                                            library.flags[flag] = nil
                                        end

                                        callback(nil)
                                    end
                                end)
                            else
                                local optionbtn = option:Clone()
                                optionbtn.Parent = dropdowncontent
                                optionbtn.Text = opt
                                bindoptionmotion(optionbtn, opt)

                                optioninstances[opt] = optionbtn

                                if table.find(default, opt) then
                                    table.insert(chosen, opt)
                                    table.insert(choseninstances, optionbtn)
                                    optionbtn.BackgroundTransparency = 0
                                    optionbtn.TextColor3 = Color3.fromRGB(210, 210, 210)
                                end

                                optionbtn.MouseButton1Click:Connect(function()
                                    if not table.find(chosen, opt) then
                                        if #chosen >= maxoptions then
                                            table.remove(chosen, 1)
                                            utility.tween(choseninstances[1], { 0.2 }, { BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(150, 150, 150) })
                                            table.remove(choseninstances, 1)
                                        end

                                        utility.tween(optionbtn, { 0.2 }, { BackgroundTransparency = 0, TextColor3 = Color3.fromRGB(210, 210, 210) })

                                        table.insert(chosen, opt)
                                        table.insert(choseninstances, optionbtn)

                                        local tween = utility.tween(dropdown, { 0.2 }, { TextTransparency = 1, TextStrokeTransparency = 1 }, function()
                                            dropdown.Text = table.concat(chosen, ", ")
                                        end)

                                        tween.Completed:Wait()

                                        utility.tween(dropdown, { 0.2 }, { TextTransparency = 0, TextStrokeTransparency = 0, TextColor3 = Color3.fromRGB(210, 210, 210) })

                                        if flag then
                                            library.flags[flag] = chosen
                                        end

                                        callback(chosen)
                                    else
                                        utility.tween(optionbtn, { 0.2 }, { BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(150, 150, 150) })

                                        table.remove(chosen, table.find(chosen, opt))
                                        table.remove(choseninstances, table.find(choseninstances, optionbtn))

                                        local tween = utility.tween(dropdown, { 0.2 }, { TextTransparency = 1, TextStrokeTransparency = 1 }, function()
                                            dropdown.Text = table.concat(chosen, ", ") ~= "" and table.concat(chosen, ", ") or "NONE"
                                        end)

                                        tween.Completed:Wait()

                                        utility.tween(dropdown, { 0.2 }, { TextTransparency = 0, TextStrokeTransparency = 0, TextColor3 = table.concat(chosen, ", ") ~= "" and Color3.fromRGB(210, 210, 210) or Color3.fromRGB(150, 150, 150) })

                                        if flag then
                                            library.flags[flag] = chosen
                                        end

                                        callback(chosen)
                                    end
                                end)
                            end
                        end
                    end

                    return dropdowntypes
                end

                function sectiontypes:Multibox(options)
                    local newoptions = {}
                    for i, v in next, options do
                        newoptions[i:lower()] = v
                    end

                    newoptions.maximum = newoptions.maximum or math.huge
                    return sectiontypes:Dropdown(newoptions)
                end


                function sectiontypes:Keybind(options)
                    options = utility.table(options)
                    local name = options.name
                    local keybindtype = options.mode
                    local default = options.default
                    local toggledefault = keybindtype and keybindtype:lower() == "toggle" and options.toggledefault
                    local toggleflag = keybindtype and keybindtype:lower() == "toggle" and options.togglepointer
                    local togglecallback = keybindtype and keybindtype:lower() == "toggle" and options.togglecallback or function() end
                    local holdflag = keybindtype and keybindtype:lower() == "hold" and options.holdflag
                    local holdcallback = keybindtype and keybindtype:lower() == "hold" and options.holdcallback or function() end
                    local blacklist = options.blacklist or {}
                    local flag = options.pointer
                    local callback = options.callback or function() end

                    table.insert(blacklist, Enum.UserInputType.Focus)

                    local keybindholder = utility.create("TextButton", {
                        Size = UDim2.new(1, -5, 0, 14),
                        BackgroundTransparency = 1,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        FontSize = Enum.FontSize.Size14,
                        TextSize = 14,
                        TextColor3 = Color3.fromRGB(0, 0, 0),
                        Font = Enum.Font.SourceSans,
                        Parent = sectioncontent
                    })

                    local icon, grayborder, enablediconholder
                    do
                        if keybindtype and keybindtype:lower() == "toggle" then
                            icon = utility.create("Frame", {
                                ZIndex = 9,
                                Size = UDim2.new(0, 10, 0, 10),
                                BorderColor3 = Color3.fromRGB(40, 40, 40),
                                Position = UDim2.new(0, 2, 0, 2),
                                BorderSizePixel = 0,
                                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                Parent = keybindholder
                            })

                            grayborder = utility.create("Frame", {
                                ZIndex = 8,
                                Size = UDim2.new(1, 2, 1, 2),
                                Position = UDim2.new(0, -1, 0, -1),
                                BorderSizePixel = 0,
                                BackgroundColor3 = Color3.fromRGB(40, 40, 40),
                                Parent = icon
                            })

                            utility.create("UIGradient", {
                                Rotation = 90,
                                Color = ColorSequence.new(Color3.fromRGB(35, 35, 35), Color3.fromRGB(25, 25, 25)),
                                Parent = icon
                            })

                            utility.create("Frame", {
                                ZIndex = 7,
                                Size = UDim2.new(1, 2, 1, 2),
                                Position = UDim2.new(0, -1, 0, -1),
                                BorderSizePixel = 0,
                                BackgroundColor3 = Color3.fromRGB(10, 10, 10),
                                Parent = grayborder
                            })

                            enablediconholder = utility.create("Frame", {
                                ZIndex = 10,
                                Size = UDim2.new(1, 0, 1, 0),
                                BackgroundTransparency = 1,
                                BorderSizePixel = 0,
                                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                Parent = icon
                            })

                            local enabledicongradient = utility.create("UIGradient", {
                                Rotation = 90,
                                Color = utility.gradient { library.accent, Color3.fromRGB(25, 25, 25) },
                                Parent = enablediconholder
                            })

                            accentobjects.gradient[enabledicongradient] = function(color)
                                return utility.gradient { color, Color3.fromRGB(25, 25, 25) }
                            end
                        end
                    end

                    local title = utility.create("TextLabel", {
                        ZIndex = 7,
                        Size = UDim2.new(1, -72, 1, 0),
                        BackgroundTransparency = 1,
                        Position = keybindtype and keybindtype:lower() == "toggle" and UDim2.new(0, 20, 0, 0) or UDim2.new(0, 1, 0, 0),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        FontSize = Enum.FontSize.Size14,
                        TextStrokeTransparency = 0,
                        TextSize = 13,
                        TextColor3 = (keybindtype and keybindtype:lower() == "toggle" and Color3.fromRGB(180, 180, 180)) or Color3.fromRGB(210, 210, 210),
                        Text = name,
                        Font = Enum.Font.Code,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = keybindholder
                    })

                    local keytext = utility.create(keybindtype and keybindtype:lower() == "toggle" and "TextButton" or "TextLabel", {
                        ZIndex = 7,
                        Size = keybindtype and keybindtype:lower() == "toggle" and UDim2.new(0, 45, 1, 0) or UDim2.new(0, 0, 1, 0),
                        BackgroundTransparency = 1,
                        AnchorPoint = keybindtype and keybindtype:lower() == "toggle" and Vector2.new(0, 0) or Vector2.new(1, 0),
                        Position = keybindtype and keybindtype:lower() == "toggle" and UDim2.new(1, -45, 0, 0) or UDim2.new(1, 0, 0, 0),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        TextSize = 13,
                        TextColor3 = Color3.fromRGB(150, 150, 150),
                        Text = "[NONE]",
                        Font = Enum.Font.Code,
                        TextXAlignment = Enum.TextXAlignment.Right,
                        Parent = keybindholder
                    })

                    utility.create("UIPadding", {
                        PaddingBottom = UDim.new(0, 1),
                        Parent = keytext
                    })

                    if #sectioncontent:GetChildren() - 1 <= max then
                        sectionholder.Size = UDim2.new(1, -1, 0, sectionlist.AbsoluteContentSize.Y + (sidebar and 42 or 28))
                    end

                    local keys = {
                        [Enum.KeyCode.LeftShift] = "L-SHIFT",
                        [Enum.KeyCode.RightShift] = "R-SHIFT",
                        [Enum.KeyCode.LeftControl] = "L-CTRL",
                        [Enum.KeyCode.RightControl] = "R-CTRL",
                        [Enum.KeyCode.LeftAlt] = "L-ALT",
                        [Enum.KeyCode.RightAlt] = "R-ALT",
                        [Enum.KeyCode.CapsLock] = "CAPSLOCK",
                        [Enum.KeyCode.One] = "1",
                        [Enum.KeyCode.Two] = "2",
                        [Enum.KeyCode.Three] = "3",
                        [Enum.KeyCode.Four] = "4",
                        [Enum.KeyCode.Five] = "5",
                        [Enum.KeyCode.Six] = "6",
                        [Enum.KeyCode.Seven] = "7",
                        [Enum.KeyCode.Eight] = "8",
                        [Enum.KeyCode.Nine] = "9",
                        [Enum.KeyCode.Zero] = "0",
                        [Enum.KeyCode.KeypadOne] = "NUM-1",
                        [Enum.KeyCode.KeypadTwo] = "NUM-2",
                        [Enum.KeyCode.KeypadThree] = "NUM-3",
                        [Enum.KeyCode.KeypadFour] = "NUM-4",
                        [Enum.KeyCode.KeypadFive] = "NUM-5",
                        [Enum.KeyCode.KeypadSix] = "NUM-6",
                        [Enum.KeyCode.KeypadSeven] = "NUM-7",
                        [Enum.KeyCode.KeypadEight] = "NUM-8",
                        [Enum.KeyCode.KeypadNine] = "NUM-9",
                        [Enum.KeyCode.KeypadZero] = "NUM-0",
                        [Enum.KeyCode.Minus] = "-",
                        [Enum.KeyCode.Equals] = "=",
                        [Enum.KeyCode.Tilde] = "~",
                        [Enum.KeyCode.LeftBracket] = "[",
                        [Enum.KeyCode.RightBracket] = "]",
                        [Enum.KeyCode.RightParenthesis] = ")",
                        [Enum.KeyCode.LeftParenthesis] = "(",
                        [Enum.KeyCode.Semicolon] = ";",
                        [Enum.KeyCode.Quote] = "'",
                        [Enum.KeyCode.BackSlash] = "\\",
                        [Enum.KeyCode.Comma] = ",",
                        [Enum.KeyCode.Period] = ".",
                        [Enum.KeyCode.Slash] = "/",
                        [Enum.KeyCode.Asterisk] = "*",
                        [Enum.KeyCode.Plus] = "+",
                        [Enum.KeyCode.Backquote] = "`",
                        [Enum.UserInputType.MouseButton1] = "MOUSE-1",
                        [Enum.UserInputType.MouseButton2] = "MOUSE-2",
                        [Enum.UserInputType.MouseButton3] = "MOUSE-3"
                    }

                    local keychosen
                    local isbinding = false

                    keybindholder.MouseEnter:Connect(function()
                        utility.tween(keytext, { 0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out }, {
                            TextColor3 = Color3.fromRGB(225, 225, 225),
                            TextTransparency = 0
                        })
                    end)

                    keybindholder.MouseLeave:Connect(function()
                        if not isbinding then
                            utility.tween(keytext, { 0.17, Enum.EasingStyle.Quart, Enum.EasingDirection.Out }, {
                                TextColor3 = Color3.fromRGB(150, 150, 150),
                                TextTransparency = 0
                            })
                        end
                    end)

                    local function startbinding()
                        if isbinding then return end
                        isbinding = true
                        keytext.Text = "[...]"
                        utility.tween(keytext, { 0.14, Enum.EasingStyle.Back, Enum.EasingDirection.Out }, {
                            TextColor3 = Color3.fromRGB(245, 245, 245),
                            TextTransparency = 0
                        })

                        local binding
                        binding = utility.connect(services.InputService.InputBegan, function(input)
                            local key = keys[input.KeyCode] or keys[input.UserInputType]
                            keytext.Text = "[" .. (key or tostring(input.KeyCode):gsub("Enum.KeyCode.", "")) .. "]"
                            keytext.TextColor3 = Color3.fromRGB(180, 180, 180)
                            keytext.Size = UDim2.new(0, keytext.TextBounds.X, 1, 0)
                            keytext.Position = UDim2.new(1, -keytext.TextBounds.X, 0, 0)

                            if input.UserInputType == Enum.UserInputType.Keyboard then
                                task.wait()
                                if not table.find(blacklist, input.KeyCode) then
                                    keychosen = input.KeyCode

                                    if flag then
                                        library.flags[flag] = input.KeyCode
                                    end

                                    binding:Disconnect()
                                    callback(input.KeyCode)
                                else
                                    keychosen = nil
                                    keytext.TextColor3 = Color3.fromRGB(180, 180, 180)
                                    keytext.Text = "NONE"

                                    if flag then
                                        library.flags[flag] = nil
                                    end

                                    binding:Disconnect()
                                    callback(nil)
                                end
                            else
                                if not table.find(blacklist, input.UserInputType) then
                                    keychosen = input.UserInputType

                                    if flag then
                                        library.flags[flag] = input.UserInputType
                                    end

                                    binding:Disconnect()
                                    callback(input.UserInputType)
                                else
                                    keychosen = nil
                                    keytext.TextColor3 = Color3.fromRGB(180, 180, 180)
                                    keytext.Text = "[NONE]"

                                    keytext.Size = UDim2.new(0, keytext.TextBounds.X, 1, 0)
                                    keytext.Position = UDim2.new(1, -keytext.TextBounds.X, 0, 0)

                                    if flag then
                                        library.flags[flag] = nil
                                    end

                                    binding:Disconnect()
                                    callback(nil)
                                end
                            end

                            isbinding = false
                            utility.tween(keytext, { 0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out }, {
                                TextColor3 = Color3.fromRGB(180, 180, 180)
                            })
                        end)
                    end

                    if not keybindtype or keybindtype:lower() == "hold" then
                        keybindholder.MouseButton1Click:Connect(startbinding)
                    else
                        keytext.MouseButton1Click:Connect(startbinding)
                    end

                    local keybindtypes = utility.table()

                    if keybindtype and keybindtype:lower() == "toggle" then
                        local toggled = false

                        if toggleflag then
                            library.flags[toggleflag] = toggled
                        end

                        local function toggle()
                            if not switchingtabs then
                                toggled = not toggled

                                if toggleflag then
                                    library.flags[toggleflag] = toggled
                                end

                                togglecallback(toggled)

                                local enabledtransparency = toggled and 0 or 1
                                utility.tween(enablediconholder, { 0.2 }, { BackgroundTransparency = enabledtransparency })

                                local textcolor = toggled and library.accent or Color3.fromRGB(180, 180, 180)
                                utility.tween(title, { 0.2 }, { TextColor3 = textcolor })

                                if toggled then
                                    if not table.find(accentobjects.text, title) then
                                        table.insert(accentobjects.text, title)
                                    end
                                elseif table.find(accentobjects.text, title) then
                                    table.remove(accentobjects.text, table.find(accentobjects.text, title))
                                end
                            end
                        end

                        keybindholder.MouseButton1Click:Connect(toggle)

                        local function set(bool)
                            if type(bool) == "boolean" and toggled ~= bool then
                                toggle()
                            end
                        end

                        function keybindtypes:Toggle(bool)
                            set(bool)
                        end

                        if toggledefault then
                            set(toggledefault)
                        end

                        if toggleflag then
                            flags[toggleflag] = set
                        end

                        utility.connect(services.InputService.InputBegan, function(input)
                            if input.UserInputType == Enum.UserInputType.Keyboard then
                                if input.KeyCode == keychosen then
                                    toggle()
                                    callback(keychosen)
                                end
                            else
                                if input.UserInputType == keychosen and keychosen then
                                    toggle()
                                    callback(keychosen)
                                end
                            end
                        end)
                    end

                    if keybindtype and keybindtype:lower() == "hold" then
                        utility.connect(services.InputService.InputBegan, function(input)
                            if input.UserInputType == Enum.UserInputType.Keyboard then
                                if input.KeyCode == keychosen then
                                    if holdflag then
                                        library.flags[holdflag] = true
                                    end

                                    callback(keychosen)
                                    holdcallback(true)
                                end
                            else
                                if input.UserInputType == keychosen and keychosen then
                                    if holdflag then
                                        library.flags[holdflag] = true
                                    end

                                    callback(keychosen)
                                    holdcallback(true)
                                end
                            end
                        end)

                        utility.connect(services.InputService.InputEnded, function(input)
                            if input.UserInputType == Enum.UserInputType.Keyboard then
                                if input.KeyCode == keychosen then
                                    if holdflag then
                                        library.flags[holdflag] = false
                                    end

                                    holdcallback(false)
                                end
                            else
                                if input.UserInputType == keychosen and keychosen then
                                    if holdflag then
                                        library.flags[holdflag] = false
                                    end

                                    holdcallback(false)
                                end
                            end
                        end)
                    end

                    if not keybindtype then
                        utility.connect(services.InputService.InputBegan, function(input)
                            if input.UserInputType == Enum.UserInputType.Keyboard then
                                if input.KeyCode == keychosen then
                                    callback(keychosen)
                                end
                            else
                                if input.UserInputType == keychosen and keychosen then
                                    callback(keychosen)
                                end
                            end
                        end)
                    end

                    local function setkey(newkey)
                        if newkey == nil then
                            keychosen = nil
                            keytext.TextColor3 = Color3.fromRGB(180, 180, 180)
                            keytext.Text = "[NONE]"
                            if flag then library.flags[flag] = nil end
                            callback(nil, true)
                            return
                        end

                        if tostring(newkey):find("Enum.KeyCode.") then
                            newkey = Enum.KeyCode[tostring(newkey):gsub("Enum.KeyCode.", "")]
                        else
                            newkey = Enum.UserInputType[tostring(newkey):gsub("Enum.UserInputType.", "")]
                        end

                        if not table.find(blacklist, newkey) then
                            local key = keys[newkey]
                            local text = "[" .. (keys[newkey] or tostring(newkey):gsub("Enum.KeyCode.", "")) .. "]"
                            local sizeX = services.TextService:GetTextSize(text, 13, interfaceState.font, Vector2.new(1000, 1000)).X

                            keytext.Text = text
                            keytext.Size = UDim2.new(0, sizeX, 1, 0)
                            keytext.Position = UDim2.new(1, -sizeX, 0, 0)

                            keytext.TextColor3 = Color3.fromRGB(180, 180, 180)

                            keychosen = newkey

                            if flag then
                                library.flags[flag] = newkey
                            end

                            callback(newkey, true)
                        else
                            keychosen = nil
                            keytext.TextColor3 = Color3.fromRGB(180, 180, 180)
                            keytext.Text = "[NONE]"
                            keytext.Size = UDim2.new(0, keytext.TextBounds.X, 1, 0)
                            keytext.Position = UDim2.new(1, -keytext.TextBounds.X, 0, 0)

                            if flag then
                                library.flags[flag] = nil
                            end

                            callback(newkey, true)
                        end
                    end

                    if default then
                        task.wait()
                        setkey(default)
                    end

                    if flag then
                        flags[flag] = setkey
                    end

                    function keybindtypes:Set(newkey)
                        setkey(newkey)
                    end

                    return keybindtypes
                end


                function sectiontypes:ColorPicker(options)
                    options = utility.table(options)
                    local name = options.name
                    local default = options.default or Color3.fromRGB(255, 255, 255)
                    local colorpickertype = options.mode
                    local toggleflag = colorpickertype and colorpickertype:lower() == "toggle" and options.togglepointer
                    local togglecallback = colorpickertype and colorpickertype:lower() == "toggle" and options.togglecallback or function() end
                    local flag = options.pointer
                    local callback = options.callback or function() end
                    local opened = false
                    local opening = false

                    local colorpickerholder = utility.create("Frame", {
                        Size = UDim2.new(1, -5, 0, 14),
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 0, 0, 0),
                        Parent = sectioncontent
                    })

                    local enabledcpiconholder
                    do
                        if colorpickertype and colorpickertype:lower() == "toggle" then
                            local togglecpicon = utility.create("Frame", {
                                ZIndex = 9,
                                Size = UDim2.new(0, 10, 0, 10),
                                BorderColor3 = Color3.fromRGB(40, 40, 40),
                                Position = UDim2.new(0, 2, 0, 2),
                                BorderSizePixel = 0,
                                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                Parent = colorpickerholder
                            })

                            local grayborder = utility.create("Frame", {
                                ZIndex = 8,
                                Size = UDim2.new(1, 2, 1, 2),
                                Position = UDim2.new(0, -1, 0, -1),
                                BorderSizePixel = 0,
                                BackgroundColor3 = Color3.fromRGB(40, 40, 40),
                                Parent = togglecpicon
                            })

                            utility.create("UIGradient", {
                                Rotation = 90,
                                Color = ColorSequence.new(Color3.fromRGB(35, 35, 35), Color3.fromRGB(25, 25, 25)),
                                Parent = togglecpicon
                            })

                            utility.create("Frame", {
                                ZIndex = 7,
                                Size = UDim2.new(1, 2, 1, 2),
                                Position = UDim2.new(0, -1, 0, -1),
                                BorderSizePixel = 0,
                                BackgroundColor3 = Color3.fromRGB(10, 10, 10),
                                Parent = grayborder
                            })

                            enabledcpiconholder = utility.create("Frame", {
                                ZIndex = 10,
                                Size = UDim2.new(1, 0, 1, 0),
                                BackgroundTransparency = 1,
                                BorderSizePixel = 0,
                                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                Parent = togglecpicon
                            })

                            local enabledicongradient = utility.create("UIGradient", {
                                Rotation = 90,
                                Color = utility.gradient { library.accent, Color3.fromRGB(25, 25, 25) },
                                Parent = enabledcpiconholder
                            })

                            accentobjects.gradient[enabledicongradient] = function(color)
                                return utility.gradient { color, Color3.fromRGB(25, 25, 25) }
                            end
                        end
                    end

                    local colorpickerframe = utility.create("Frame", {
                        ZIndex = 9,
                        Size = UDim2.new(1, -70, 0, 148),
                        Position = UDim2.new(1, -168, 0, 18),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        Visible = false,
                        Parent = colorpickerholder
                    })

                    colorpickerframe.DescendantAdded:Connect(function(descendant)
                        if not opened then
                            task.wait()
                            fadeObject(descendant, false)
                        end
                    end)

                    local bggradient = utility.create("UIGradient", {
                        Rotation = 90,
                        Color = utility.gradient { Color3.fromRGB(35, 35, 35), Color3.fromRGB(25, 25, 25) },
                        Parent = colorpickerframe
                    })

                    local grayborder = utility.create("Frame", {
                        ZIndex = 8,
                        Size = UDim2.new(1, 2, 1, 2),
                        Position = UDim2.new(0, -1, 0, -1),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Color3.fromRGB(40, 40, 40),
                        Parent = colorpickerframe
                    })

                    local blackborder = utility.create("Frame", {
                        ZIndex = 7,
                        Size = UDim2.new(1, 2, 1, 2),
                        Position = UDim2.new(0, -1, 0, -1),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Color3.fromRGB(10, 10, 10),
                        Parent = grayborder
                    })

                    local saturationframe = utility.create("ImageLabel", {
                        ZIndex = 12,
                        Size = UDim2.new(1, -34, 0, 100),
                        BorderColor3 = Color3.fromRGB(50, 50, 50),
                        Position = UDim2.new(0, 6, 0, 6),
                        BorderSizePixel = 0,
                        BackgroundColor3 = default,
                        Image = "http://www.roblox.com/asset/?id=8630797271",
                        Parent = colorpickerframe
                    })

                    local grayborder = utility.create("Frame", {
                        ZIndex = 11,
                        Size = UDim2.new(1, 2, 1, 2),
                        Position = UDim2.new(0, -1, 0, -1),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Color3.fromRGB(40, 40, 40),
                        Parent = saturationframe
                    })

                    utility.create("Frame", {
                        ZIndex = 10,
                        Size = UDim2.new(1, 2, 1, 2),
                        Position = UDim2.new(0, -1, 0, -1),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Color3.fromRGB(10, 10, 10),
                        Parent = grayborder
                    })

                    local saturationpicker = utility.create("Frame", {
                        ZIndex = 13,
                        Size = UDim2.new(0, 8, 0, 8),
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        BorderColor3 = Color3.fromRGB(10, 10, 10),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        Parent = saturationframe
                    })

                    local hueframe = utility.create("ImageLabel", {
                        ZIndex = 12,
                        Size = UDim2.new(0, 16, 0, 100),
                        Position = UDim2.new(1, -22, 0, 6),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Color3.fromRGB(255, 193, 49),
                        ScaleType = Enum.ScaleType.Crop,
                        Image = "http://www.roblox.com/asset/?id=8630799159",
                        Parent = colorpickerframe
                    })

                    local grayborder = utility.create("Frame", {
                        ZIndex = 11,
                        Size = UDim2.new(1, 2, 1, 2),
                        Position = UDim2.new(0, -1, 0, -1),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Color3.fromRGB(40, 40, 40),
                        Parent = hueframe
                    })

                    utility.create("Frame", {
                        ZIndex = 10,
                        Size = UDim2.new(1, 2, 1, 2),
                        Position = UDim2.new(0, -1, 0, -1),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Color3.fromRGB(10, 10, 10),
                        Parent = grayborder
                    })

                    local huepicker = utility.create("Frame", {
                        ZIndex = 13,
                        Size = UDim2.new(1, 0, 0, 3),
                        AnchorPoint = Vector2.new(0, 0.5),
                        BorderColor3 = Color3.fromRGB(10, 10, 10),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        Parent = hueframe
                    })

                    local boxholder = utility.create("Frame", {
                        Size = UDim2.new(1, -8, 0, 17),
                        ClipsDescendants = true,
                        Position = UDim2.new(0, 4, 0, 110),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        Parent = colorpickerframe
                    })

                    local box = utility.create("TextBox", {
                        ZIndex = 13,
                        Size = UDim2.new(1, -4, 1, -4),
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 2, 0, 2),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        FontSize = Enum.FontSize.Size14,
                        TextStrokeTransparency = 0,
                        TextSize = 13,
                        TextColor3 = Color3.fromRGB(210, 210, 210),
                        Text = string.format("#%02X%02X%02X", math.floor(default.R * 255 + 0.5), math.floor(default.G * 255 + 0.5), math.floor(default.B * 255 + 0.5)),
                        PlaceholderText = "#RRGGBB or R, G, B",
                        Font = Enum.Font.Code,
                        Parent = boxholder
                    })

                    local grayborder = utility.create("Frame", {
                        ZIndex = 11,
                        Size = UDim2.new(1, 2, 1, 2),
                        Position = UDim2.new(0, -1, 0, -1),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Color3.fromRGB(40, 40, 40),
                        Parent = box
                    })

                    utility.create("Frame", {
                        ZIndex = 10,
                        Size = UDim2.new(1, 2, 1, 2),
                        Position = UDim2.new(0, -1, 0, -1),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Color3.fromRGB(10, 10, 10),
                        Parent = grayborder
                    })

                    local bg = utility.create("Frame", {
                        ZIndex = 12,
                        Size = UDim2.new(1, 0, 1, 0),
                        BorderColor3 = Color3.fromRGB(40, 40, 40),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        Parent = box
                    })

                    utility.create("UIGradient", {
                        Rotation = 90,
                        Color = utility.gradient { Color3.fromRGB(35, 35, 35), Color3.fromRGB(25, 25, 25) },
                        Parent = bg
                    })

                    local toggleholder = utility.create("TextButton", {
                        Size = UDim2.new(1, -8, 0, 14),
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 4, 0, 130),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        FontSize = Enum.FontSize.Size14,
                        TextSize = 14,
                        TextColor3 = Color3.fromRGB(0, 0, 0),
                        Font = Enum.Font.SourceSans,
                        Parent = colorpickerframe
                    })

                    local toggleicon = utility.create("Frame", {
                        ZIndex = 12,
                        Size = UDim2.new(0, 10, 0, 10),
                        BorderColor3 = Color3.fromRGB(40, 40, 40),
                        Position = UDim2.new(0, 2, 0, 2),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        Parent = toggleholder
                    })

                    local enablediconholder = utility.create("Frame", {
                        ZIndex = 13,
                        Size = UDim2.new(1, 0, 1, 0),
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        Parent = toggleicon
                    })

                    local enabledicongradient = utility.create("UIGradient", {
                        Rotation = 90,
                        Color = utility.gradient { library.accent, Color3.fromRGB(25, 25, 25) },
                        Parent = enablediconholder
                    })

                    accentobjects.gradient[enabledicongradient] = function(color)
                        return utility.gradient { color, Color3.fromRGB(25, 25, 25) }
                    end

                    local grayborder = utility.create("Frame", {
                        ZIndex = 11,
                        Size = UDim2.new(1, 2, 1, 2),
                        Position = UDim2.new(0, -1, 0, -1),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Color3.fromRGB(40, 40, 40),
                        Parent = toggleicon
                    })

                    utility.create("Frame", {
                        ZIndex = 10,
                        Size = UDim2.new(1, 2, 1, 2),
                        Position = UDim2.new(0, -1, 0, -1),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Color3.fromRGB(10, 10, 10),
                        Parent = grayborder
                    })

                    utility.create("UIGradient", {
                        Rotation = 90,
                        Color = utility.gradient { Color3.fromRGB(35, 35, 35), Color3.fromRGB(25, 25, 25) },
                        Parent = toggleicon
                    })

                    local rainbowtxt = utility.create("TextLabel", {
                        ZIndex = 10,
                        Size = UDim2.new(1, -24, 1, 0),
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 20, 0, 0),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        FontSize = Enum.FontSize.Size14,
                        TextStrokeTransparency = 0,
                        TextSize = 13,
                        TextColor3 = Color3.fromRGB(180, 180, 180),
                        Text = "Rainbow",
                        Font = Enum.Font.Code,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = toggleholder
                    })

                    local colorpicker = utility.create("TextButton", {
                        ZIndex = colorpickertype and colorpickertype:lower() == "toggle" and 8 or 10,
                        Size = UDim2.new(1, 0, 0, 14),
                        BackgroundTransparency = 1,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        FontSize = Enum.FontSize.Size14,
                        TextSize = 14,
                        TextColor3 = Color3.fromRGB(0, 0, 0),
                        Font = Enum.Font.SourceSans,
                        Parent = colorpickerholder
                    })

                    local icon = utility.create(colorpickertype and colorpickertype:lower() == "toggle" and "TextButton" or "Frame", {
                        ZIndex = 9,
                        Size = UDim2.new(0, 18, 0, 10),
                        BorderColor3 = Color3.fromRGB(40, 40, 40),
                        Position = UDim2.new(1, -20, 0, 2),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        Parent = colorpicker
                    })

                    if colorpickertype and colorpickertype:lower() == "toggle" then
                        icon.Text = ""
                    end

                    local grayborder = utility.create("Frame", {
                        ZIndex = 8,
                        Size = UDim2.new(1, 2, 1, 2),
                        Position = UDim2.new(0, -1, 0, -1),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Color3.fromRGB(40, 40, 40),
                        Parent = icon
                    })

                    utility.create("Frame", {
                        ZIndex = 7,
                        Size = UDim2.new(1, 2, 1, 2),
                        Position = UDim2.new(0, -1, 0, -1),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Color3.fromRGB(10, 10, 10),
                        Parent = grayborder
                    })

                    local icongradient = utility.create("UIGradient", {
                        Rotation = 90,
                        Color = utility.gradient { default, utility.changecolor(default, -200) },
                        Parent = icon
                    })

                    local title = utility.create("TextLabel", {
                        ZIndex = 7,
                        Size = UDim2.new(1, -44, 0, 14),
                        BackgroundTransparency = 1,
                        Position = colorpickertype and colorpickertype:lower() == "toggle" and UDim2.new(0, 20, 0, 0) or UDim2.new(0, 1, 0, 0),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        FontSize = Enum.FontSize.Size14,
                        TextStrokeTransparency = 0,
                        TextSize = 13,
                        TextColor3 = Color3.fromRGB(210, 210, 210),
                        Text = name,
                        Font = Enum.Font.Code,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = colorpicker
                    })

                    colorpicker.MouseEnter:Connect(function()
                        utility.tween(icon, { 0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.Out }, {
                            Size = UDim2.new(0, 22, 0, 12),
                            Position = UDim2.new(1, -22, 0, 1)
                        })
                    end)

                    colorpicker.MouseLeave:Connect(function()
                        utility.tween(icon, { 0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out }, {
                            Size = UDim2.new(0, 18, 0, 10),
                            Position = UDim2.new(1, -20, 0, 2)
                        })
                    end)

                    if #sectioncontent:GetChildren() - 1 <= max then
                        sectionholder.Size = UDim2.new(1, -1, 0, sectionlist.AbsoluteContentSize.Y + (sidebar and 42 or 28))
                    end

                    if colorpickertype and colorpickertype:lower() == "toggle" then
                        local toggled = false

                        if toggleflag then
                            library.flags[toggleflag] = toggled
                        end

                        local function toggletoggle()
                            if not switchingtabs then
                                toggled = not toggled

                                if toggleflag then
                                    library.flags[toggleflag] = toggled
                                end

                                togglecallback(toggled)

                                local enabledtransparency = toggled and 0 or 1
                                utility.tween(enabledcpiconholder, { 0.2 }, { BackgroundTransparency = enabledtransparency })

                                local textcolor = toggled and library.accent or Color3.fromRGB(180, 180, 180)
                                utility.tween(title, { 0.2 }, { TextColor3 = textcolor })

                                if toggled then
                                    if not table.find(accentobjects.text, title) then
                                        table.insert(accentobjects.text, title)
                                    end
                                elseif table.find(accentobjects.text, title) then
                                    table.remove(accentobjects.text, table.find(accentobjects.text, title))
                                end
                            end
                        end

                        colorpicker.MouseButton1Click:Connect(toggletoggle)

                        local function set(bool)
                            if type(bool) == "boolean" and toggled ~= bool then
                                toggletoggle()
                            end
                        end

                        if toggledefault then
                            set(toggledefault)
                        end

                        if toggleflag then
                            flags[toggleflag] = set
                        end
                    end

                    local function opencolorpicker()
                        if not opening then
                            opening = true

                            opened = not opened

                            if opened then
                                colorpickerframe.Position = UDim2.new(1, -168, 0, 12)
                                utility.tween(colorpickerholder, { 0.2 }, { Size = UDim2.new(1, -5, 0, 168) })
                            end

                            if not opened then
                                utility.tween(colorpickerframe, { 0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.In }, {
                                    Position = UDim2.new(1, -168, 0, 12)
                                })
                            end

                            local tween = utility.makevisible(colorpickerframe, opened)

                            if opened then
                                utility.tween(colorpickerframe, { 0.24, Enum.EasingStyle.Quint, Enum.EasingDirection.Out }, {
                                    Position = UDim2.new(1, -168, 0, 18)
                                })
                            end

                            tween.Completed:Wait()

                            if not opened then
                                local tween = utility.tween(colorpickerholder, { 0.2 }, { Size = UDim2.new(1, -5, 0, 16) })
                                tween.Completed:Wait()
                            end

                            opening = false
                        end
                    end

                    if colorpickertype and colorpickertype:lower() == "toggle" then
                        icon.MouseButton1Click:Connect(opencolorpicker)
                    else
                        colorpicker.MouseButton1Click:Connect(opencolorpicker)
                    end

                    local hue, sat, val = default:ToHSV()

                    local slidinghue = false
                    local slidingsaturation = false

                    local hsv = Color3.fromHSV(hue, sat, val)

                    local function formatcolor(color)
                        return string.format(
                            "#%02X%02X%02X",
                            math.clamp(math.floor(color.R * 255 + 0.5), 0, 255),
                            math.clamp(math.floor(color.G * 255 + 0.5), 0, 255),
                            math.clamp(math.floor(color.B * 255 + 0.5), 0, 255)
                        )
                    end

                    if flag then
                        library.flags[flag] = default
                    end

                    local function updatehue(input)
                        local sizeY = 1 - math.clamp((input.Position.Y - hueframe.AbsolutePosition.Y) / hueframe.AbsoluteSize.Y, 0, 1)
                        local posY = math.clamp(((input.Position.Y - hueframe.AbsolutePosition.Y) / hueframe.AbsoluteSize.Y) * hueframe.AbsoluteSize.Y, 0, hueframe.AbsoluteSize.Y)
                        huepicker.Position = UDim2.new(0, 0, 0, posY)

                        hue = sizeY
                        hsv = Color3.fromHSV(sizeY, sat, val)

                        box.Text = formatcolor(hsv)

                        saturationframe.BackgroundColor3 = hsv
                        icon.BackgroundColor3 = hsv
                        icongradient.Color = utility.gradient { hsv, utility.changecolor(hsv, -200) }

                        if flag then
                            library.flags[flag] = hsv
                        end

                        callback(hsv)
                    end

                    hueframe.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            slidinghue = true
                            utility.tween(huepicker, { 0.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out }, {
                                Size = UDim2.new(1, 2, 0, 5)
                            })
                            updatehue(input)
                        end
                    end)

                    hueframe.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            slidinghue = false
                            utility.tween(huepicker, { 0.16, Enum.EasingStyle.Back, Enum.EasingDirection.Out }, {
                                Size = UDim2.new(1, 0, 0, 3)
                            })
                        end
                    end)

                    utility.connect(services.InputService.InputChanged, function(input)
                        if input.UserInputType == Enum.UserInputType.MouseMovement then
                            if slidinghue then
                                updatehue(input)
                            end
                        end
                    end)

                    local function updatesatval(input)
                        local sizeX = math.clamp((input.Position.X - saturationframe.AbsolutePosition.X) / saturationframe.AbsoluteSize.X, 0, 1)
                        local sizeY = 1 - math.clamp((input.Position.Y - saturationframe.AbsolutePosition.Y) / saturationframe.AbsoluteSize.Y, 0, 1)
                        local posY = math.clamp(((input.Position.Y - saturationframe.AbsolutePosition.Y) / saturationframe.AbsoluteSize.Y) * saturationframe.AbsoluteSize.Y, 0, saturationframe.AbsoluteSize.Y)
                        local posX = math.clamp(((input.Position.X - saturationframe.AbsolutePosition.X) / saturationframe.AbsoluteSize.X) * saturationframe.AbsoluteSize.X, 0, saturationframe.AbsoluteSize.X)

                        saturationpicker.Position = UDim2.new(0, posX, 0, posY)

                        sat = sizeX
                        val = sizeY
                        hsv = Color3.fromHSV(hue, sizeX, sizeY)

                        box.Text = formatcolor(hsv)

                        saturationframe.BackgroundColor3 = hsv
                        icon.BackgroundColor3 = hsv
                        icongradient.Color = utility.gradient { hsv, utility.changecolor(hsv, -200) }

                        if flag then
                            library.flags[flag] = hsv
                        end

                        callback(hsv)
                    end

                    saturationframe.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            slidingsaturation = true
                            utility.tween(saturationpicker, { 0.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out }, {
                                Size = UDim2.new(0, 11, 0, 11)
                            })
                            updatesatval(input)
                        end
                    end)

                    saturationframe.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            slidingsaturation = false
                            utility.tween(saturationpicker, { 0.16, Enum.EasingStyle.Back, Enum.EasingDirection.Out }, {
                                Size = UDim2.new(0, 8, 0, 8)
                            })
                        end
                    end)

                    utility.connect(services.InputService.InputChanged, function(input)
                        if input.UserInputType == Enum.UserInputType.MouseMovement then
                            if slidingsaturation then
                                updatesatval(input)
                            end
                        end
                    end)

                    local function set(color)
                        if type(color) == "table" then
                            color = Color3.fromRGB(unpack(color))
                        end

                        hue, sat, val = color:ToHSV()
                        hsv = Color3.fromHSV(hue, sat, val)

                        utility.tween(saturationframe, { 0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.Out }, { BackgroundColor3 = hsv })
                        utility.tween(icon, { 0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.Out }, { BackgroundColor3 = hsv })
                        animateColorSequence(icongradient, utility.gradient { hsv, utility.changecolor(hsv, -200) }, 0.16)
                        utility.tween(saturationpicker, { 0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.Out }, {
                            Position = UDim2.new(sat, 0, 1 - val, 0)
                        })
                        utility.tween(huepicker, { 0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.Out }, {
                            Position = UDim2.new(0, 0, 1 - hue, 0)
                        })

                        box.Text = formatcolor(hsv)

                        if flag then
                            library.flags[flag] = hsv
                        end

                        callback(hsv)
                    end

                    local toggled = false

                    local function rainbowtogglefunc()
                        if not switchingtabs then
                            toggled = not toggled

                            if toggled then
                                task.spawn(function()
                                    while toggled do
                                        for i = 0, 1, 0.0015 do
                                            if not toggled then
                                                return
                                            end

                                            local color = Color3.fromHSV(i, 1, 1)
                                            set(color)

                                            task.wait()
                                        end
                                    end
                                end)
                            end

                            local enabledtransparency = toggled and 0 or 1
                            utility.tween(enablediconholder, { 0.2 }, { BackgroundTransparency = enabledtransparency })

                            local textcolor = toggled and library.accent or Color3.fromRGB(180, 180, 180)
                            utility.tween(rainbowtxt, { 0.2 }, { TextColor3 = textcolor })

                            if toggled then
                                if not table.find(accentobjects.text, rainbowtxt) then
                                    table.insert(accentobjects.text, rainbowtxt)
                                end
                            elseif table.find(accentobjects.text, rainbowtxt) then
                                table.remove(accentobjects.text, table.find(accentobjects.text, rainbowtxt))
                            end
                        end
                    end

                    toggleholder.MouseButton1Click:Connect(rainbowtogglefunc)

                    box.FocusLost:Connect(function()
                        local valid = false
                        local compact = box.Text:gsub("%s+", "")
                        local hex = compact:match("^#?(%x%x%x%x%x%x)$")

                        if hex then
                            set(Color3.fromRGB(
                                tonumber(hex:sub(1, 2), 16),
                                tonumber(hex:sub(3, 4), 16),
                                tonumber(hex:sub(5, 6), 16)
                            ))
                            valid = true
                        else
                            local values = {}
                            for value in box.Text:gmatch("%-?%d+%.?%d*") do
                                values[#values + 1] = tonumber(value)
                            end
                            if #values >= 3 then
                                set(Color3.fromRGB(
                                    math.clamp(values[1], 0, 255),
                                    math.clamp(values[2], 0, 255),
                                    math.clamp(values[3], 0, 255)
                                ))
                                valid = true
                            end
                        end
                        if not valid then
                            box.Text = formatcolor(hsv)
                        end
                    end)

                    if default then
                        set(default)
                    end

                    if flag then
                        flags[flag] = set
                    end
                end

                return sectiontypes
            end

            return pagetypes
        end

        return windowtypes
    end

    function library:Initialize()
        normalizeVisibleText()
        if gethui then
            gui.Parent = gethui()
        elseif syn and syn.protect_gui then
            syn.protect_gui(gui)
            gui.Parent = services.CoreGui
        else
            gui.Parent = services.CoreGui
        end
    end

    function library:Destroy()
        for _, connection in ipairs(libraryConnections) do
            pcall(function() connection:Disconnect() end)
        end
        table.clear(libraryConnections)
        if gui then
            pcall(function() gui:Destroy() end)
        end
    end

    function library:Init()
        library:Initialize()
    end
end

local easyPresets = {
    Rose = {
        Accent = Color3.fromRGB(225, 72, 112),
        Outline = { Color3.fromRGB(255, 105, 145), Color3.fromRGB(105, 42, 65) },
        Colors = {
            canvas = Color3.fromRGB(22, 17, 20), panel = Color3.fromRGB(28, 21, 25),
            window = Color3.fromRGB(35, 27, 31), control = Color3.fromRGB(42, 31, 36),
            hover = Color3.fromRGB(49, 35, 42), border = Color3.fromRGB(58, 39, 48),
            edge = Color3.fromRGB(70, 46, 58), strongborder = Color3.fromRGB(84, 54, 68),
            subtletext = Color3.fromRGB(118, 93, 102), placeholder = Color3.fromRGB(132, 105, 115),
            mutedtext = Color3.fromRGB(169, 141, 151), disabledtext = Color3.fromRGB(194, 171, 180),
            text = Color3.fromRGB(235, 222, 227)
        }
    },
    Amber = {
        Accent = Color3.fromRGB(255, 176, 32),
        Outline = { Color3.fromRGB(255, 176, 32), Color3.fromRGB(60, 45, 10) },
        Colors = {
            canvas = Color3.fromRGB(20, 20, 20), panel = Color3.fromRGB(22, 22, 22),
            window = Color3.fromRGB(30, 30, 30), control = Color3.fromRGB(25, 25, 25),
            hover = Color3.fromRGB(35, 35, 35), border = Color3.fromRGB(40, 40, 40),
            edge = Color3.fromRGB(45, 45, 45), strongborder = Color3.fromRGB(50, 50, 50),
            subtletext = Color3.fromRGB(110, 110, 110), placeholder = Color3.fromRGB(120, 120, 120),
            mutedtext = Color3.fromRGB(150, 150, 150), disabledtext = Color3.fromRGB(180, 180, 180),
            text = Color3.fromRGB(210, 210, 210)
        }
    },
    Nebula = {
        Accent = Color3.fromRGB(181, 116, 255),
        Outline = { Color3.fromRGB(120, 89, 255), Color3.fromRGB(224, 72, 181) },
        Colors = {
            canvas = Color3.fromRGB(18, 17, 25), panel = Color3.fromRGB(24, 22, 33),
            window = Color3.fromRGB(31, 28, 41), control = Color3.fromRGB(38, 34, 50),
            hover = Color3.fromRGB(46, 41, 61), border = Color3.fromRGB(55, 49, 72),
            edge = Color3.fromRGB(65, 57, 84), strongborder = Color3.fromRGB(78, 68, 99),
            subtletext = Color3.fromRGB(115, 106, 136), placeholder = Color3.fromRGB(130, 121, 151),
            mutedtext = Color3.fromRGB(157, 148, 178), disabledtext = Color3.fromRGB(193, 187, 207),
            text = Color3.fromRGB(229, 224, 240)
        }
    },
    Ocean = {
        Accent = Color3.fromRGB(65, 181, 255),
        Outline = { Color3.fromRGB(57, 143, 255), Color3.fromRGB(45, 225, 207) },
        Colors = {
            canvas = Color3.fromRGB(15, 20, 24), panel = Color3.fromRGB(19, 27, 32),
            window = Color3.fromRGB(24, 34, 40), control = Color3.fromRGB(29, 42, 49),
            hover = Color3.fromRGB(34, 50, 58), border = Color3.fromRGB(40, 59, 68),
            edge = Color3.fromRGB(47, 68, 78), strongborder = Color3.fromRGB(56, 81, 92),
            subtletext = Color3.fromRGB(96, 125, 136), placeholder = Color3.fromRGB(111, 141, 152),
            mutedtext = Color3.fromRGB(137, 164, 174), disabledtext = Color3.fromRGB(181, 202, 209),
            text = Color3.fromRGB(220, 235, 240)
        }
    },
    Graphite = {
        Accent = Color3.fromRGB(195, 202, 214),
        Outline = { Color3.fromRGB(170, 178, 192), Color3.fromRGB(73, 78, 88) },
        Colors = {
            canvas = Color3.fromRGB(18, 19, 21), panel = Color3.fromRGB(23, 24, 27),
            window = Color3.fromRGB(29, 30, 34), control = Color3.fromRGB(36, 38, 43),
            hover = Color3.fromRGB(43, 45, 51), border = Color3.fromRGB(51, 53, 60),
            edge = Color3.fromRGB(60, 63, 71), strongborder = Color3.fromRGB(72, 75, 85),
            subtletext = Color3.fromRGB(108, 113, 124), placeholder = Color3.fromRGB(125, 130, 141),
            mutedtext = Color3.fromRGB(151, 157, 168), disabledtext = Color3.fromRGB(190, 194, 202),
            text = Color3.fromRGB(226, 229, 235)
        }
    }
}

local presetOrder = { "Rose", "Amber", "Nebula", "Ocean", "Graphite" }
local optionAliases = {
    Name = "name", Text = "name", Default = "default", Callback = "callback",
    Flag = "pointer", Pointer = "pointer", Min = "min", Max = "max",
    Values = "options", Options = "options", Side = "side", Suffix = "value",
    Format = "value", Mode = "mode"
}

local function copyOptions(options)
    local result = {}
    if type(options) == "table" then
        for key, value in pairs(options) do result[key] = value end
        for source, target in pairs(optionAliases) do
            if result[target] == nil and result[source] ~= nil then result[target] = result[source] end
        end
    elseif options ~= nil then
        result.name = tostring(options)
    end
    return result
end

local function addToggleColorAlias(control)
    if type(control) == "table" and type(control.Colorpicker) == "function" then
        function control:AddColorPicker(options, default, callback)
            local normalized
            if type(options) == "table" then
                normalized = copyOptions(options)
            else
                normalized = { name = tostring(options or "Color"), default = default, callback = callback }
            end
            return self:Colorpicker(normalized)
        end
    end
    return control
end

local function wrapSection(rawSection)
    local section = { Raw = rawSection }

    function section:AddLabel(options)
        return rawSection:Label(copyOptions(options))
    end

    function section:AddButton(options, callback)
        local normalized = type(options) == "table" and copyOptions(options)
            or { name = tostring(options or "Button"), callback = callback }
        return rawSection:Button(normalized)
    end

    function section:AddToggle(options, default, callback)
        local normalized = type(options) == "table" and copyOptions(options)
            or { name = tostring(options or "Toggle"), default = default, callback = callback }
        return addToggleColorAlias(rawSection:Toggle(normalized))
    end

    function section:AddTextbox(options, default, callback)
        local normalized = type(options) == "table" and copyOptions(options)
            or { name = tostring(options or "Text"), default = default, callback = callback }
        return rawSection:Box(normalized)
    end

    function section:AddSlider(options, minimum, maximum, default, callback, format)
        local normalized
        if type(options) == "table" then
            normalized = copyOptions(options)
        else
            normalized = {
                name = tostring(options or "Slider"), min = minimum, max = maximum,
                default = default, callback = callback, value = format or "[value]"
            }
        end
        normalized.value = normalized.value or "[value]"
        return rawSection:Slider(normalized)
    end

    function section:AddDropdown(options, values, default, callback)
        local normalized = type(options) == "table" and copyOptions(options)
            or { name = tostring(options or "Dropdown"), options = values, default = default, callback = callback }
        return rawSection:Dropdown(normalized)
    end

    function section:AddMultiDropdown(options, values, default, callback)
        local normalized = type(options) == "table" and copyOptions(options)
            or { name = tostring(options or "Multi Dropdown"), options = values, default = default, callback = callback }
        return rawSection:Multibox(normalized)
    end

    function section:AddKeybind(options, default, callback)
        local normalized = type(options) == "table" and copyOptions(options)
            or { name = tostring(options or "Keybind"), default = default, callback = callback }
        return rawSection:Keybind(normalized)
    end

    function section:AddColorPicker(options, default, callback)
        local normalized = type(options) == "table" and copyOptions(options)
            or { name = tostring(options or "Color"), default = default, callback = callback }
        return rawSection:ColorPicker(normalized)
    end

    return setmetatable(section, { __index = rawSection })
end

local function wrapTab(rawTab)
    local tab = { Raw = rawTab }

    function tab:AddSection(options, side)
        local normalized = type(options) == "table" and copyOptions(options)
            or { name = tostring(options or "Section"), side = side or "left" }
        normalized.side = normalized.side or side or "left"
        return wrapSection(rawTab:Section(normalized))
    end

    return setmetatable(tab, { __index = rawTab })
end

function library:GetPresetNames()
    local names = {}
    for index, name in ipairs(presetOrder) do names[index] = name end
    return names
end

function library:ApplyPreset(name)
    local preset = easyPresets[name]
    if not preset then return false end
    for role, color in pairs(preset.Colors) do
        self:ChangeThemeColor(role, color, true)
    end
    self:ChangeAccent(preset.Accent)
    self:ChangeOutline({ preset.Outline[1], preset.Outline[2] })
    return true
end

function library:Bind(target, key, afterChange)
    return function(value)
        target[key] = value
        if afterChange then afterChange(value) end
    end
end

function library:GetFlag(flag)
    return self.flags[flag]
end

function library:SetMenuKey(key)
    if typeof(key) ~= "EnumItem" then return false end
    self.keybind = key
    if self.SetSidebarFooterKey then self:SetSidebarFooterKey(key) end
    if self._easyMenuConnection then self._easyMenuConnection:Disconnect() end
    self._easyMenuConnection = game:GetService("UserInputService").InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == self.keybind or input.UserInputType == self.keybind then
            task.spawn(function() pcall(function() self:Toggle() end) end)
        end
    end)
    return true
end

local baseDestroy = library.Destroy
function library:Destroy()
    if self._easyMenuConnection then
        self._easyMenuConnection:Disconnect()
        self._easyMenuConnection = nil
    end
    return baseDestroy(self)
end

function library:Unload()
    if self.holder then pcall(function() self:FadeOut() end) end
    self:Destroy()
end

function library:CreateWindow(options)
    options = options or {}
    local presetName = options.Preset or options.preset or "Rose"
    self:ApplyPreset(presetName)

    local rawWindow = self:New({
        name = options.Title or options.Name or options.name or "bob.lol",
        accent = options.Accent or options.accent or self.accent,
        outline = options.Outline or options.outline or self.outline,
        sizeX = options.Width or options.SizeX or options.sizeX or 620,
        sizeY = options.Height or options.SizeY or options.sizeY or 400,
        sidebar = options.Sidebar == true or tostring(options.TabLayout or ""):lower() == "sidebar",
        sidebarWidth = options.SidebarWidth or 126,
        sidebarFooterKey = options.SidebarFooterKey,
        sidebarFooterText = options.SidebarFooterText,
        collapseHeader = options.CollapsibleHeader == true or options.CollapseToHeader == true,
        collapseHeaderWidth = options.CollapseHeaderWidth,
        refinedHeader = options.RefinedHeader == true,
        sliderRoundness = options.SliderRoundness,
        scrollSidebar = options.ScrollSidebar == true,
        onclose = options.OnClose or options.onClose
    })

    local window = {
        Raw = rawWindow,
        Preset = presetName,
        ToggleKey = options.ToggleKey or options.MenuKey or Enum.KeyCode.F1
    }

    function window:AddTab(options)
        local normalized = type(options) == "table" and copyOptions(options)
            or { name = tostring(options or "Tab") }
        return wrapTab(rawWindow:Page(normalized))
    end

    function window:AddSettingsTab(options)
        if self._settingsTab then return self._settingsTab end
        options = options or {}

        local tab = self:AddTab({
            Name = options.Name or "Settings",
            Group = options.Group
        })
        local themeSection = tab:AddSection("Theme", "left")
        local surfaceSection = tab:AddSection("Surface Colors", "left")
        local interfaceSection = tab:AddSection("Interface", "right")
        local configSection = tab:AddSection("Configs", "right")
        local scriptSection = tab:AddSection("Script", "right")
        local currentOutline = { library.outline[1], library.outline[2] }

        themeSection:AddDropdown("Preset", library:GetPresetNames(), self.Preset, function(value)
            if library:ApplyPreset(value) then
                self.Preset = value
                currentOutline = { library.outline[1], library.outline[2] }
            end
        end)
        themeSection:AddColorPicker("Accent", library.accent, function(color) library:ChangeAccent(color) end)
        themeSection:AddColorPicker("Outline Start", currentOutline[1], function(color)
            currentOutline[1] = color
            library:ChangeOutline(currentOutline)
        end)
        themeSection:AddColorPicker("Outline End", currentOutline[2], function(color)
            currentOutline[2] = color
            library:ChangeOutline(currentOutline)
        end)

        local surfaceControls = {
            { "Canvas", "canvas" }, { "Panels", "panel" }, { "Window", "window" },
            { "Controls", "control" }, { "Primary Text", "text" }, { "Muted Text", "mutedtext" }
        }
        local activePreset = easyPresets[self.Preset] or easyPresets.Rose
        for _, entry in ipairs(surfaceControls) do
            surfaceSection:AddColorPicker(entry[1], activePreset.Colors[entry[2]], function(color)
                library:ChangeThemeColor(entry[2], color)
            end)
        end

        local fontNames = { "Code", "Gotham", "SourceSans", "Arial", "Ubuntu" }
        interfaceSection:AddDropdown("Font", fontNames, options.Font or "Code", function(value)
            local font = Enum.Font[value]
            if font then library:ChangeFont(font) end
        end)
        interfaceSection:AddSlider("UI Scale", 70, 135, options.Scale or 100, function(value)
            library:SetScale(value / 100)
        end, "[value]%")
        interfaceSection:AddSlider("Animation Speed", 50, 250, options.AnimationSpeed or 100, function(value)
            library:SetAnimationSpeed(value / 100)
        end, "[value]%")
        if options.ShowCornerRadius ~= false then
            interfaceSection:AddSlider("Corner Radius", 0, 12, options.Roundness or 4, function(value)
                library:SetRoundness(value)
            end, "[value]px")
        end
        interfaceSection:AddToggle("Text Outline", options.TextOutline ~= false, function(value)
            library:SetTextOutline(value)
        end)
        interfaceSection:AddKeybind("Menu Key", self.ToggleKey, function(key)
            if typeof(key) == "EnumItem" then
                self.ToggleKey = key
                library:SetMenuKey(key)
            end
        end)

        local configName = options.DefaultConfig or "default"
        local universal = options.UniversalConfig == true
        local selectedConfig
        local configDropdown

        configSection:AddTextbox("Name", configName, function(value) configName = value end)
        configDropdown = configSection:AddDropdown("Saved Config", library:ListConfigs(universal), nil, function(value)
            selectedConfig = value
            if value then configName = value end
        end)
        configSection:AddToggle("Universal", universal, function(value)
            universal = value
            configDropdown:Refresh(library:ListConfigs(universal))
        end)
        configSection:AddButton("Save", function()
            if configName and configName ~= "" then
                library:SaveConfig(configName, universal)
                configDropdown:Refresh(library:ListConfigs(universal))
            end
        end)
        configSection:AddButton("Load", function()
            library:LoadConfig(selectedConfig or configName)
        end)
        configSection:AddButton("Delete", function()
            library:DeleteConfig(selectedConfig or configName, universal)
            selectedConfig = nil
            configDropdown:Refresh(library:ListConfigs(universal))
        end)
        configSection:AddButton("Refresh", function()
            configDropdown:Refresh(library:ListConfigs(universal))
        end)

        scriptSection:AddButton(options.UnloadText or "Unload bob.lol", function()
            if options.OnUnload then pcall(options.OnUnload) end
            library:Unload()
        end)

        self._settingsTab = tab
        return tab
    end

    function window:Init()
        library:Init()
        library:SetMenuKey(self.ToggleKey)
        return self
    end

    function window:Toggle()
        library:Toggle()
    end

    function window:Unload()
        library:Unload()
    end

    return setmetatable(window, { __index = rawWindow })
end

library.Create = library.CreateWindow
library.ThemePresets = easyPresets

return library
end)()

local __bob_ok, __bob_error = xpcall(function()
local environment = (getgenv and getgenv()) or _G

if environment.bob_lol_blox_fruits and environment.bob_lol_blox_fruits.Unload then
    pcall(environment.bob_lol_blox_fruits.Unload)
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")
local LocalPlayer = Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local CommF = Remotes:WaitForChild("CommF_")
local SEA_PLACE_IDS = {
    First = 2753915549,
    Second = 4442272183,
    Third = 7449423635
}
if game.GameId == 994732206 then
    local worldOrigin = workspace:FindFirstChild("_WorldOrigin")
    local locations = worldOrigin and worldOrigin:FindFirstChild("Locations")
    if game.PlaceId == 100117331123089 or (locations and (locations:FindFirstChild("Tiki Outpost") or locations:FindFirstChild("Hydra Island"))) then
        SEA_PLACE_IDS.Third = game.PlaceId
    elseif locations and (locations:FindFirstChild("Kingdom of Rose") or locations:FindFirstChild("Green Zone")) then
        SEA_PLACE_IDS.Second = game.PlaceId
    elseif locations and (locations:FindFirstChild("Pirate Village") or locations:FindFirstChild("Frozen Village")) then
        SEA_PLACE_IDS.First = game.PlaceId
    end
end
local AUTO_FRUIT_PRIORITY = {
    "Dragon", "Kitsune", "Yeti", "Tiger", "Gas", "Spirit", "Control", "Venom", "Shadow", "Dough",
    "Mammoth", "T-Rex", "Gravity", "Blizzard", "Pain", "Lightning", "Portal", "Phoenix", "Sound", "Spider",
    "Love", "Buddha", "Quake", "Magma", "Creation", "Magnet", "Ghost", "Eagle", "Diamond", "Light",
    "Rubber", "Ice", "Sand", "Dark", "Flame", "Spike", "Smoke", "Bomb", "Spring", "Blade", "Spin", "Rocket"
}

local Accent = Color3.fromRGB(255, 179, 71)
local Red = Color3.fromRGB(255, 82, 76)
local Green = Color3.fromRGB(100, 225, 135)
local Blue = Color3.fromRGB(90, 175, 255)
local Muted = Color3.fromRGB(205, 205, 215)

local Settings = {
    Aimbot = false,
    AimKey = Enum.UserInputType.MouseButton2,
    AimPart = "Head",
    AimFov = 180,
    AimSmoothness = 7,
    AimPrediction = 80,
    AimVisibleOnly = true,
    AimAllyCheck = true,
    AimSticky = true,
    AimMaxDistance = 4000,
    ShowFov = true,
    FovColor = Accent,
    Hitbox = false,
    HitboxPlayers = false,
    HitboxEnemies = true,
    HitboxBosses = true,
    HitboxUniform = true,
    HitboxSize = 5,
    HitboxX = 5,
    HitboxY = 5,
    HitboxZ = 5,
    HitboxDistance = 1500,
    HitboxWireframe = true,
    HitboxColor = Accent,
    AutoAura = false,
    NoCameraShake = false,
    PlayerESP = true,
    PlayerBoxes = true,
    PlayerNames = true,
    PlayerHealth = true,
    PlayerDistance = true,
    PlayerEquipment = true,
    PlayerTracers = false,
    PlayerChams = false,
    PlayerMaxDistance = 0,
    ESPUseAccent = true,
    PlayerColor = Accent,
    AllyColor = Green,
    EnemyESP = false,
    BossESP = true,
    EnemyBoxes = true,
    EnemyHealth = true,
    EnemyDistance = true,
    EnemyMaxDistance = 1800,
    EnemyColor = Color3.fromRGB(255, 205, 92),
    BossColor = Red,
    FruitESP = true,
    FruitAlerts = true,
    FruitColor = Color3.fromRGB(205, 105, 255),
    FruitMaxDistance = 0,
    SeaESP = true,
    SeaAlerts = true,
    SeaColor = Blue,
    NearestChest = false,
    ChestColor = Accent,
    Flight = false,
    FlightKey = Enum.KeyCode.F,
    FlightSpeed = 100,
    Noclip = false,
    NoclipKey = Enum.KeyCode.N,
    WaterWalk = false,
    InfiniteJump = false,
    TravelSpeed = 130,
    SelectedIsland = nil,
    SelectedBoss = nil,
    AutoChest = false,
    AutoChestSpeed = 130,
    AutoFish = false,
    AutoBuyBait = false,
    AutoFruit = false,
    AutoFruitWantedFruits = {},
    AutoFruitSpeed = 130,
    AutoStoreFruit = true,
    AutoFarm = false,
    AutoSea2 = false,
    AutoSaber = false,
    FarmMode = "Level",
    FarmAutoQuest = true,
    FarmAutoTravel = true,
    FarmEnemy = "Auto by Level",
    FarmWeapon = "Auto",
    FarmPosition = "Above",
    FarmDistance = 7,
    FarmSquareSize = 10,
    FarmSquareCornerTime = 0.7,
    FarmAutoGroup = false,
    FarmTravelSpeed = 130,
    FarmAttackDelay = 0.18,
    FarmAttackMethod = "Remote",
    FarmMasteryType = "Melee",
    FarmMasteryGoal = 600,
    MasteryFinisher = false,
    MasteryFinisherType = "Blox Fruit",
    MasteryFinisherHealth = 20,
    FarmBoss = nil,
    FarmBossQuest = true,
    FarmLevelBosses = true,
    AutoBosses = false,
    BossUseQuest = true,
    BossAutoHop = false,
    BossHopDelay = 30,
    FarmDropAlerts = true,
    AutoMaterial = false,
    MaterialGoal = "Ectoplasm",
    AutoWeaponGoal = false,
    WeaponGoal = "Rengoku",
    AutoStats = false,
    AutoStatSelection = { "Melee", "Defense", "Blox Fruit" },
    DealerTracker = true,
    AutoFactory = false,
    AutoPirateRaid = false,
    AutoBartilo = false,
    AutoRaceV2 = false,
    AutoRaceV3 = false,
    AutoRaceV3Ability = false,
    RaceV3AbilityTrigger = "When Ready",
    RaceV3AbilityHealth = 50,
    RaceV3AbilityRange = 120,
    RaceV3AbilityRetryDelay = 8,
    AutoRaceV4 = false,
    IslandFinderTarget = "Mirage Island",
    IslandFinderAlerts = true,
    IslandFinderAutoFind = false,
    IslandFinderSpeed = 300,
    AutoMirage = false,
    MirageAutoTravel = true,
    MirageAutoMoon = true,
    MirageAutoGear = true,
    MirageAutoHop = false,
    MirageHopDelay = 30,
    MirageDealerESP = true,
    MirageGearESP = true,
    MirageESPBoxes = true,
    MirageESPDistance = true,
    MirageDealerColor = Accent,
    MirageGearColor = Blue,
    RaidType = "Flame",
    RaidAutoClear = false,
    RaidTargetBoss = false,
    RaidLowHealthRetreat = false,
    RaidRetreatHealth = 5000,
    RaidRetreatHeight = 500,
    DropGoal = "Hellfire Torch",
    AutoDropGoal = false,
    AutoSea3 = false,
    AutoTyrant = false,
    AutoCakePrince = false,
    AutoDoughKing = false,
    AutoSpawnCakePrince = false,
    AutoSpawnDoughKing = false,
    DoughKingPlayerSafety = true,
    DoughKingSafetyRange = 250,
    DoughKingRetreatHeight = 500,
    AutoEliteHunter = false,
    AutoGhoul = false,
    AutoCyborg = false,
    AutoSeaBeast = false,
    SeaBeastAutoHunt = true,
    SeaBeastWeapon = "Blox Fruit",
    SeaBeastHoverHeight = 60,
    SeaBeastTravelSpeed = 300,
    SeaBeastSkillDelay = 0.45,
    Sea1FightingStyle = "Dark Step",
    Sea2FightingStyle = "Dragon Breath",
    Sea3FightingStyle = "Electric Claw",
    AutoBuyFightingStyle = false,
    StockOverlay = false,
    StockNotifications = true,
    StockWantedFruits = { "Dragon", "Kitsune", "Tiger", "Gas", "Yeti", "Dough" },
    StockMinimumPrice = 1000000,
    StockBuyFruit = "Rocket",
    StockDragonType = "West",
    AutoBuyStock = false,
    ObfuscationCompatibility = true,
    EventFinder = false,
    EventName = "Darkbeard",
    EventAutoHop = false,
    EventHopDelay = 20,
    AntiAFK = true,
    AutoRejoin30 = false,
    Fullbright = false,
    NoFog = false,
    LowQuality = false
}

local state = {
    Alive = true,
    Cleaned = false,
    UIReady = false,
    AutoRejoinAt = 0,
    AutoRejoinCheckAt = 0,
    AutoRejoinBusy = false,
    AutoRejoinControl = nil,
    Connections = {},
    Tasks = setmetatable({}, { __mode = "k" }),
    Drawings = {},
    PlayerDrawings = {},
    WorldDrawings = {},
    Highlights = {},
    Expanded = setmetatable({}, { __mode = "k" }),
    Adornments = setmetatable({}, { __mode = "k" }),
    VisualHeads = setmetatable({}, { __mode = "k" }),
    Collision = setmetatable({}, { __mode = "k" }),
    DisabledEffects = setmetatable({}, { __mode = "k" }),
    AimTarget = nil,
    TravelTarget = nil,
    TravelName = nil,
    TravelMode = nil,
    TravelObject = nil,
    TravelOwner = nil,
    TravelButtonKey = nil,
    TravelButtons = {},
    TravelSerial = 0,
    TravelBudget = 0,
    AutomationMoveSeconds = 0,
    AutomationMovePauseUntil = 0,
    AutomationMoveOwner = nil,
    FlightBudget = 0,
    NearestChestInstance = nil,
    Fruits = {},
    Chests = setmetatable({}, { __mode = "k" }),
    ChestCacheReady = false,
    ChestCacheScanning = false,
    Stock = {},
    FruitCatalog = {},
    FruitPrices = {},
    FruitRawNames = {},
    StockSignature = "",
    StockInitialized = false,
    StockBuyBusy = false,
    AutoStockNextAt = 0,
    LastAura = 0,
    LastHitboxScan = 0,
    LastChestScan = 0,
    Notifications = {},
    ContextNotices = {},
    NotificationGui = nil,
    NotificationContainer = nil,
    StockPanel = nil,
    StockStroke = nil,
    StockAccent = nil,
    StockTitle = nil,
    StockCount = nil,
    StockList = nil,
    StockPriceLabels = {},
    StockRenderedSignature = nil,
    StockVisible = false,
    StockHideSerial = 0,
    DealerSword = nil,
    DealerAvailable = false,
    DealerLastCheck = 0,
    DealerCheckBusy = false,
    ChestAttempts = setmetatable({}, { __mode = "k" }),
    ChestPositionAttempts = {},
    ChestIslandAttempts = {},
    ChestIslandSearchReadyAt = 0,
    FishingController = nil,
    FishingState = nil,
    FishingOriginalIsReeling = nil,
    FishingInputHeld = false,
    FishingCastBusy = false,
    FishingPulseBusy = false,
    FishingWasPlaying = false,
    FishingNextActionAt = 0,
    FishingDismissAt = 0,
    FishingReleaseUntil = 0,
    FishingCompletedAt = 0,
    FishingSerial = 0,
    BaitBuyBusy = false,
    BaitBuyNextAt = 0,
    CakeCounterNextAt = 0,
    CakeCounterBusy = false,
    CakeCounterLastText = nil,
    CakeSpawnPollAt = 0,
    CakeSpawnPollBusy = false,
    CakeSpawnRemaining = nil,
    CakeSpawnReady = false,
    CakeSpawnSpamAt = 0,
    CakeSpawnSpamInFlight = 0,
    CakeSpawnHadSweetChalice = false,
    CakeSpawnAwaitUntil = 0,
    DoughCounterNextAt = 0,
    DoughCounterLastText = nil,
    PirateRaidDetectedUntil = 0,
    PirateRaidLastCount = 0,
    FruitRollBusy = false,
    FruitAttempts = setmetatable({}, { __mode = "k" }),
    FruitStoreAttempts = setmetatable({}, { __mode = "k" }),
    FruitOverrideActive = false,
    FruitOverrideObject = nil,
    FruitOverrideName = nil,
    FruitOverrideStartedAt = 0,
    FruitOverrideMissingAt = 0,
    FruitOverrideReachedAt = 0,
    PhysicalFruitChoiceIds = setmetatable({}, { __mode = "k" }),
    PhysicalFruitChoiceNextId = 0,
    PhysicalFruitChoiceMap = {},
    PhysicalFruitChoiceObject = nil,
    PhysicalFruitChoiceControl = nil,
    PhysicalFruitChoiceRefreshing = false,
    PhysicalFruitChoiceSignature = nil,
    CameraShaker = nil,
    LightingSnapshot = nil,
    TerrainSnapshot = nil,
    RenderQuality = nil,
    WaterPart = nil,
    QuestDefinitions = nil,
    GuideModule = nil,
    GuideDataModule = nil,
    QuestCatalog = {},
    QuestGivers = {},
    EnemySpawns = {},
    FarmQuest = nil,
    FarmTarget = nil,
    FarmTargetName = nil,
    FarmLevelBossActive = false,
    BossNextHopAt = 0,
    SpecialToggleSyncAt = 0,
    FarmQuestGiver = nil,
    FarmStatus = "Idle",
    FarmStatusAt = 0,
    FarmPhase = "Idle",
    FarmPhaseAt = 0,
    FarmGeneration = 0,
    FarmWarning = "",
    FarmToggleSyncAt = 0,
    FarmReadyAt = 0,
    FarmLastUpdate = 0,
    FarmLastAttack = 0,
    FarmNextAttackAt = 0,
    FarmCombo = 0,
    FarmLastQuestRequest = 0,
    FarmQuestRequestPending = false,
    FarmQuestRequestId = 0,
    FarmQuestRequest = nil,
    FarmTool = nil,
    FarmWeaponInfo = nil,
    FarmEquipAttempts = 0,
    FarmEquipRequestedAt = 0,
    FarmClickRequest = nil,
    FarmClickSerial = 0,
    FarmSkillIndex = 0,
    FarmSkillBusy = false,
    FarmSkillToken = 0,
    FarmLastSkill = nil,
    FarmRemoteThread = nil,
    FarmRemoteToken = nil,
    FarmRemoteWeapon = nil,
    FarmRemoteHitCursor = 0,
    FarmFruitM1Targets = setmetatable({}, { __mode = "k" }),
    FarmDamageTarget = nil,
    FarmDamageBaseline = nil,
    FarmDamageAttacks = 0,
    FarmDamageCheckAt = 0,
    FarmLastDamage = nil,
    FarmNoDamageCount = 0,
    FarmRecoverAt = 0,
    FarmCloserUntil = 0,
    FarmInventoryVersion = 0,
    FarmTravelBudget = 0,
    FarmFishmanApproached = false,
    FarmFishmanWaitUntil = 0,
    FarmShipTransition = nil,
    FarmShipApproached = false,
    FarmShipWaitUntil = 0,
    FarmGroupDestination = nil,
    FarmGroupTargetName = nil,
    FarmGroupNextUpdate = 0,
    FarmGroupMembers = setmetatable({}, { __mode = "k" }),
    Sea2Phase = "Idle",
    Sea2PhaseAt = 0,
    Sea2ReadyAt = 0,
    Sea2LastUpdate = 0,
    Sea2Generation = 0,
    Sea2RequestId = 0,
    Sea2Request = nil,
    Sea2RetryCount = 0,
    Sea2Target = nil,
    Sea2Tool = nil,
    Sea2WeaponInfo = nil,
    Sea2EquipAttempts = 0,
    Sea2EquipRequestedAt = 0,
    Sea2NextAttackAt = 0,
    Sea2DamageBaseline = nil,
    Sea2DamageAttacks = 0,
    Sea2DamageCheckAt = 0,
    Sea2NoDamageCount = 0,
    Sea2DoorTouchedAt = 0,
    Sea2BossWaitAt = 0,
    SpecialOwner = nil,
    SpecialFarm = nil,
    SpecialStatus = "Idle",
    SpecialLastUpdate = 0,
    SpecialNextCheck = 0,
    SpecialRequestBusy = {},
    SpecialData = {},
    BartiloPlate = 1,
    BartiloPuzzleNoclip = false,
    SaberPuzzleNoclip = false,
    RaidStartedAt = 0,
    SeaBeastTarget = nil,
    SeaBeastTool = nil,
    SeaBeastActive = false,
    SeaBeastNextSkillAt = 0,
    SeaBeastNextEquipAt = 0,
    SeaBeastSkillIndex = 0,
    SeaBeastKeyBusy = false,
    SeaBeastBoat = nil,
    SeaBeastDriving = false,
    SeaBeastHuntStartedAt = 0,
    SeaBeastNextBoatAt = 0,
    SeaBeastBoatRequestBusy = false,
    SeaBeastNextSeatAt = 0,
    SeaBeastLastBoatStep = 0,
    SeaBeastBoatCollision = setmetatable({}, { __mode = "k" }),
    SeaBeastNoClipBoat = nil,
    RaceAbilityNextAt = 0,
    RaceAbilityMissingNotified = false,
    AutoStatsBusy = false,
    AutoStatsNextAt = 0,
    RaceV4Busy = false,
    RaceV4NextAt = 0,
    MirageFound = nil,
    MirageMarker = nil,
    MirageDealer = nil,
    MirageGear = nil,
    MirageNextScanAt = 0,
    MirageNextHopAt = 0,
    MirageNextAbilityAt = 0,
    IslandFinderFound = nil,
    IslandFinderFoundName = nil,
    IslandFinderNextScanAt = 0,
    IslandFinderAutoControl = nil,
    IslandFinderButtonControl = nil,
    IslandFinderTravelActive = false,
    IslandFinderTravelPendingUntil = 0,
    EventNextCheckAt = 0,
    EventNextHopAt = 0,
    EventFound = nil,
    EventFoundName = nil,
    KnownTools = setmetatable({}, { __mode = "k" }),
    RecentDrops = {},
    DropReady = false
}

local task = (function(nativeTask)
    local function scheduleTracked(kind, delaySeconds, callback, ...)
        if not state.Alive then return nil end
        local arguments = table.pack(...)
        local thread = coroutine.create(function()
            callback(table.unpack(arguments, 1, arguments.n))
            state.Tasks[coroutine.running()] = nil
        end)
        state.Tasks[thread] = true
        if kind == "delay" then
            nativeTask.delay(delaySeconds, thread)
        elseif kind == "defer" then
            nativeTask.defer(thread)
        else
            nativeTask.spawn(thread)
        end
        return thread
    end

    state.CancelTasks = function()
        local running = coroutine.running()
        for thread in pairs(state.Tasks) do
            if thread ~= running and coroutine.status(thread) ~= "dead" then
                pcall(nativeTask.cancel, thread)
            end
            state.Tasks[thread] = nil
        end
    end

    return setmetatable({
        spawn = function(callback, ...)
            return scheduleTracked("spawn", 0, callback, ...)
        end,
        defer = function(callback, ...)
            return scheduleTracked("defer", 0, callback, ...)
        end,
        delay = function(seconds, callback, ...)
            return scheduleTracked("delay", tonumber(seconds) or 0, callback, ...)
        end
    }, { __index = nativeTask })
end)(task)

local showNotice
local FarmEnabledControl
local AutoSea2Control
local MaterialFarmControl
local WeaponGoalControl
local FightingStyleAutoControl
local SecondSeaControls = {}
local FarmRuntime = {}

FarmRuntime.Session = {
    Folder = "bob_lol",
    SettingsPath = "bob_lol/blox_fruits_session.json",
    SourcePath = "bob_lol/blox_fruits_session.lua",
    Restored = false
}

FarmRuntime.Session.Encode = function(value)
    local valueType = typeof(value)
    if valueType == "Color3" then
        return { __type = "Color3", R = value.R, G = value.G, B = value.B }
    end
    if valueType == "EnumItem" then
        return { __type = "EnumItem", Enum = tostring(value.EnumType), Name = value.Name }
    end
    if type(value) == "table" then
        local encoded = {}
        for key, child in pairs(value) do
            local encodedChild = FarmRuntime.Session.Encode(child)
            if encodedChild ~= nil then encoded[key] = encodedChild end
        end
        return encoded
    end
    if type(value) == "boolean" or type(value) == "number" or type(value) == "string" then return value end
    return nil
end

FarmRuntime.Session.Decode = function(value)
    if type(value) ~= "table" then return value end
    if value.__type == "Color3" then
        return Color3.new(tonumber(value.R) or 0, tonumber(value.G) or 0, tonumber(value.B) or 0)
    end
    if value.__type == "EnumItem" then
        local rawEnum = tostring(value.Enum or "")
        local enumName = rawEnum:match("^Enum%.(.+)$") or rawEnum
        local enumType = enumName and Enum[enumName] or nil
        return enumType and enumType[value.Name] or nil
    end
    local decoded = {}
    for key, child in pairs(value) do decoded[key] = FarmRuntime.Session.Decode(child) end
    return decoded
end

FarmRuntime.Session.EnsureFolder = function()
    if type(isfolder) ~= "function" or type(makefolder) ~= "function" then return false, "Filesystem API unavailable" end
    if not isfolder(FarmRuntime.Session.Folder) then
        local ok, err = pcall(makefolder, FarmRuntime.Session.Folder)
        if not ok then return false, tostring(err) end
    end
    return true
end

FarmRuntime.Session.CacheSource = function()
    if type(writefile) ~= "function" then return false, "Filesystem API unavailable" end
    local ready, folderError = FarmRuntime.Session.EnsureFolder()
    if not ready then return false, folderError end
    local source = environment.bob_lol_blox_fruits_source
    if type(source) ~= "string" or source == "" then return false, "Script source is unavailable" end
    local ok, err = pcall(writefile, FarmRuntime.Session.SourcePath, source)
    return ok, ok and nil or tostring(err)
end

FarmRuntime.Session.SavePending = function()
    if type(writefile) ~= "function" then return false, "Filesystem API unavailable" end
    local ready, folderError = FarmRuntime.Session.EnsureFolder()
    if not ready then return false, folderError end
    local saved = {}
    for key, value in pairs(Settings) do
        local encoded = FarmRuntime.Session.Encode(value)
        if encoded ~= nil then saved[key] = encoded end
    end
    local payload = {
        Version = 1,
        Resume = true,
        PlaceId = game.PlaceId,
        SavedAt = os.time(),
        Settings = saved
    }
    local encodedOk, encodedPayload = pcall(HttpService.JSONEncode, HttpService, payload)
    if not encodedOk then return false, tostring(encodedPayload) end
    local writeOk, writeError = pcall(writefile, FarmRuntime.Session.SettingsPath, encodedPayload)
    return writeOk, writeOk and nil or tostring(writeError)
end

FarmRuntime.Session.LoadPending = function()
    if type(isfile) ~= "function" or type(readfile) ~= "function" or type(writefile) ~= "function" then return false end
    if not isfile(FarmRuntime.Session.SettingsPath) then return false end
    local readOk, contents = pcall(readfile, FarmRuntime.Session.SettingsPath)
    if not readOk then return false end
    local decodeOk, payload = pcall(HttpService.JSONDecode, HttpService, contents)
    if not decodeOk or type(payload) ~= "table" or payload.Resume ~= true or type(payload.Settings) ~= "table" then return false end
    for key, value in pairs(payload.Settings) do
        if type(key) == "string" then
            local decoded = FarmRuntime.Session.Decode(value)
            if decoded ~= nil then Settings[key] = decoded end
        end
    end
    payload.Resume = false
    pcall(function() writefile(FarmRuntime.Session.SettingsPath, HttpService:JSONEncode(payload)) end)
    FarmRuntime.Session.Restored = true
    return true
end

FarmRuntime.Session.ClearPending = function()
    if type(isfile) ~= "function" or type(readfile) ~= "function" or type(writefile) ~= "function" then return end
    if not isfile(FarmRuntime.Session.SettingsPath) then return end
    local readOk, contents = pcall(readfile, FarmRuntime.Session.SettingsPath)
    if not readOk then return end
    local decodeOk, payload = pcall(HttpService.JSONDecode, HttpService, contents)
    if not decodeOk or type(payload) ~= "table" then return end
    payload.Resume = false
    pcall(function() writefile(FarmRuntime.Session.SettingsPath, HttpService:JSONEncode(payload)) end)
end

FarmRuntime.Session.QueueBootstrap = function()
    if FarmRuntime.Session.Queued then return true end
    local queue = queue_on_teleport or queueonteleport or (type(syn) == "table" and syn.queue_on_teleport)
    if type(queue) ~= "function" then return false, "Teleport queue unavailable" end
    local bootstrap = [=[
local resume = false
pcall(function()
    local saved = game:GetService("HttpService"):JSONDecode(readfile("bob_lol/blox_fruits_session.json"))
    resume = type(saved) == "table" and saved.Resume == true
end)
if not resume then return end
if not game:IsLoaded() then game.Loaded:Wait() end
local ok, source = pcall(readfile, "bob_lol/blox_fruits_session.lua")
if ok and type(source) == "string" and source ~= "" then
    local environment = (getgenv and getgenv()) or _G
    environment.bob_lol_blox_fruits_source = source
    local loader = loadstring or load
    local chunk = loader(source, "@bob_lol_blox_fruits_rejoin")
    if chunk then chunk() end
end
]=]
    local ok, err = pcall(queue, bootstrap)
    if ok then FarmRuntime.Session.Queued = true end
    return ok, ok and nil or tostring(err)
end

FarmRuntime.Session.PrepareTeleport = function()
    local sourceOk, sourceError = FarmRuntime.Session.CacheSource()
    if not sourceOk then return false, sourceError end
    local saveOk, saveError = FarmRuntime.Session.SavePending()
    if not saveOk then return false, saveError end
    local queueOk, queueError = FarmRuntime.Session.QueueBootstrap()
    if not queueOk then FarmRuntime.Session.ClearPending() end
    return queueOk, queueError
end

FarmRuntime.Session.LoadPending()

FarmRuntime.ObfuscationCompatibility = {
    Revision = "native-remote-hitbox-bridge-v1",
    Enabled = Settings.ObfuscationCompatibility,
    Active = false,
    Changes = {
        "CommF_ native proxy",
        "RegisterAttack and RegisterHit native dispatch",
        "Native hitbox target scan and property updates"
    }
}

do
    local compiler = loadstring or load
    if Settings.ObfuscationCompatibility and type(compiler) == "function" then
        local chunk = compiler([=[
return {
    WrapRemoteFunction = function(remote)
        return {
            InvokeServer = function(_, ...)
                return remote:InvokeServer(...)
            end
        }
    end,
    FireRemote = function(remote, ...)
        return remote:FireServer(...)
    end,
    CollectHitboxTargets = function(players, localPlayer, workspaceRoot, localRoot, settings, farmTarget, specialFarm)
        local targets = {}
        local manualSize = settings.HitboxUniform
            and Vector3.new(settings.HitboxSize, settings.HitboxSize, settings.HitboxSize)
            or Vector3.new(settings.HitboxX, settings.HitboxY, settings.HitboxZ)
        if settings.Hitbox and settings.HitboxPlayers then
            for _, player in ipairs(players:GetPlayers()) do
                if player ~= localPlayer and (not settings.AimAllyCheck or player.Team ~= localPlayer.Team) then
                    local character = player.Character
                    local part = character and (character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart"))
                    if part and part:IsA("BasePart") and (part.Position - localRoot.Position).Magnitude <= settings.HitboxDistance then
                        targets[part] = manualSize
                    end
                end
            end
        end
        local enemies = settings.Hitbox and workspaceRoot:FindFirstChild("Enemies")
        if enemies then
            for _, model in ipairs(enemies:GetChildren()) do
                local humanoid = model:FindFirstChildOfClass("Humanoid")
                local root = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
                local part = model:FindFirstChild("Head") or root
                local lowered = string.lower(model.Name)
                local boss = string.find(lowered, "[boss]", 1, true) ~= nil
                    or string.find(lowered, "boss", 1, true) ~= nil
                    or model:GetAttribute("Boss") == true
                    or model:GetAttribute("IsBoss") == true
                    or model:GetAttribute("RaidBoss") == true
                local enabled = (boss and settings.HitboxBosses) or (not boss and settings.HitboxEnemies)
                if enabled and humanoid and humanoid.Health > 0 and part and part:IsA("BasePart")
                    and (part.Position - localRoot.Position).Magnitude <= settings.HitboxDistance
                then
                    targets[part] = manualSize
                end
            end
        end
        if settings.AutoFarm or specialFarm then
            local humanoid = farmTarget and farmTarget:FindFirstChildOfClass("Humanoid")
            local root = farmTarget and (farmTarget:FindFirstChild("HumanoidRootPart") or farmTarget.PrimaryPart)
            local part = farmTarget and (farmTarget:FindFirstChild("Head") or root)
            if humanoid and humanoid.Health > 0 and part and part:IsA("BasePart") then
                targets[part] = Vector3.new(20, 20, 20)
            end
        end
        return targets
    end,
    ApplyHitbox = function(part, size, hidePart)
        part.Size = size
        part.CanCollide = false
        part.CanTouch = false
        part.CanQuery = true
        part.Massless = true
        if hidePart then part.LocalTransparencyModifier = 1 end
    end,
    RestoreHitbox = function(part, original)
        part.Size = original.Size
        part.CanCollide = original.CanCollide
        part.CanTouch = original.CanTouch
        part.CanQuery = original.CanQuery
        part.Massless = original.Massless
        part.LocalTransparencyModifier = original.LocalTransparencyModifier
    end
}
]=], "@bob_lol_obfuscation_compat")
        if type(chunk) == "function" then
            local ok, native = pcall(chunk)
            if ok and type(native) == "table" then
                FarmRuntime.ObfuscationCompatibility.Native = native
                FarmRuntime.ObfuscationCompatibility.Active = true
                FarmRuntime.RawCommF = CommF
                CommF = native.WrapRemoteFunction(CommF)
            end
        end
    end
end

FarmRuntime.FireRemote = function(remote, ...)
    local native = FarmRuntime.ObfuscationCompatibility.Native
    if Settings.ObfuscationCompatibility and native then return native.FireRemote(remote, ...) end
    return remote:FireServer(...)
end

FarmRuntime.MaterialTargets = {
    ["Leather"] = {
        [SEA_PLACE_IDS.First] = { "Brute" },
        [SEA_PLACE_IDS.Second] = { "Mercenary" },
        [SEA_PLACE_IDS.Third] = { "Pirate Millionaire" }
    },
    ["Scrap Metal"] = {
        [SEA_PLACE_IDS.First] = { "Pirate" },
        [SEA_PLACE_IDS.Second] = { "Swan Pirate" },
        [SEA_PLACE_IDS.Third] = { "Pirate Millionaire", "Pistol Billionaire" }
    },
    ["Magma Ore"] = {
        [SEA_PLACE_IDS.First] = { "Military Soldier", "Military Spy" },
        [SEA_PLACE_IDS.Second] = { "Magma Ninja", "Lava Pirate" }
    },
    ["Angel Wings"] = { [SEA_PLACE_IDS.First] = { "God's Guard" } },
    ["Fish Tail"] = {
        [SEA_PLACE_IDS.First] = { "Fishman Warrior", "Fishman Commando" },
        [SEA_PLACE_IDS.Third] = { "Fishman Raider", "Fishman Captain" }
    },
    ["Mystic Droplet"] = { [SEA_PLACE_IDS.Second] = { "Sea Soldier", "Water Fighter" } },
    ["Radioactive Material"] = { [SEA_PLACE_IDS.Second] = { "Factory Staff" } },
    ["Vampire Fang"] = { [SEA_PLACE_IDS.Second] = { "Vampire" } },
    ["Ectoplasm"] = { [SEA_PLACE_IDS.Second] = { "Ship Deckhand", "Ship Engineer", "Ship Steward", "Ship Officer" } },
    ["Gunpowder"] = { [SEA_PLACE_IDS.Third] = { "Pistol Billionaire" } },
    ["Mini Tusk"] = { [SEA_PLACE_IDS.Third] = { "Mythological Pirate" } },
    ["Conjured Cocoa"] = { [SEA_PLACE_IDS.Third] = { "Cocoa Warrior", "Chocolate Bar Battler", "Sweet Thief", "Candy Rebel" } },
    ["Dragon Scale"] = { [SEA_PLACE_IDS.Third] = { "Dragon Crew Warrior", "Dragon Crew Archer" } },
    ["Demonic Wisp"] = { [SEA_PLACE_IDS.Third] = { "Demonic Soul" } },
    ["Bones"] = { [SEA_PLACE_IDS.Third] = { "Posessed Mummy", "Possessed Mummy" } }
}

FarmRuntime.WeaponTargets = {
    ["Saber"] = { Place = SEA_PLACE_IDS.First, Targets = { "Saber Expert" }, Boss = true, Hint = "Complete the Saber puzzle before farming Saber Expert" },
    ["Pole (1st Form)"] = { Place = SEA_PLACE_IDS.First, Targets = { "Thunder God" }, Boss = true },
    ["Rengoku"] = { Place = SEA_PLACE_IDS.Second, Targets = { "Awakened Ice Admiral" }, Boss = true, Hint = "Farm the Hidden Key, then open the chest inside Ice Castle" },
    ["Dragon Trident"] = { Place = SEA_PLACE_IDS.Second, Targets = { "Tide Keeper" }, Boss = true },
    ["Gravity Cane"] = { Place = SEA_PLACE_IDS.Second, Targets = { "Fajita" }, Boss = true },
    ["Swan Glasses"] = { Place = SEA_PLACE_IDS.Second, Targets = { "Don Swan" }, Boss = true },
    ["Koko"] = { Place = SEA_PLACE_IDS.Second, Targets = { "Order" }, Boss = true },
    ["Twin Hooks"] = { Place = SEA_PLACE_IDS.Third, Targets = { "Captain Elephant" }, Boss = true },
    ["Hallow Scythe"] = { Place = SEA_PLACE_IDS.Third, Targets = { "Soul Reaper" }, Boss = true },
    ["Buddy Sword"] = { Place = SEA_PLACE_IDS.Third, Targets = { "Cake Queen" }, Boss = true },
    ["Spikey Trident"] = { Place = SEA_PLACE_IDS.Third, Targets = { "Cake Prince", "Dough King" }, Boss = true },
    ["Dark Dagger"] = { Place = SEA_PLACE_IDS.Third, Targets = { "rip_indra True Form", "rip_indra" }, Boss = true },
    ["Tushita"] = { Place = SEA_PLACE_IDS.Third, Targets = { "Longma" }, Boss = true, Hint = "Complete the Holy Torch puzzle before defeating Longma" },
    ["Yama"] = { Place = SEA_PLACE_IDS.Third, Targets = { "Deandre", "Diablo", "Urban" }, Boss = true, Hint = "Farm Elite Pirates, then pull Yama after enough Elite Hunter completions" }
}

FarmRuntime.EventDefinitions = {
    ["Saber Expert"] = { Place = SEA_PLACE_IDS.First, Enemies = { "Saber Expert" } },
    ["Thunder God"] = { Place = SEA_PLACE_IDS.First, Enemies = { "Thunder God" } },
    ["Darkbeard"] = { Place = SEA_PLACE_IDS.Second, Enemies = { "Darkbeard" } },
    ["Factory"] = { Place = SEA_PLACE_IDS.Second, Enemies = { "Core" } },
    ["Cursed Captain"] = { Place = SEA_PLACE_IDS.Second, Enemies = { "Cursed Captain" } },
    ["Order"] = { Place = SEA_PLACE_IDS.Second, Enemies = { "Order" } },
    ["Tide Keeper"] = { Place = SEA_PLACE_IDS.Second, Enemies = { "Tide Keeper" } },
    ["Sea Beast"] = { Enemies = { "Sea Beast" }, Folders = { "SeaBeasts" } },
    ["rip_indra"] = { Place = SEA_PLACE_IDS.Third, Enemies = { "rip_indra True Form", "rip_indra" } },
    ["Dough King"] = { Place = SEA_PLACE_IDS.Third, Enemies = { "Dough King" } },
    ["Cake Prince"] = { Place = SEA_PLACE_IDS.Third, Enemies = { "Cake Prince" } },
    ["Soul Reaper"] = { Place = SEA_PLACE_IDS.Third, Enemies = { "Soul Reaper" } },
    ["Elite Pirate"] = { Place = SEA_PLACE_IDS.Third, Enemies = { "Deandre", "Diablo", "Urban" } },
    ["Mirage Island"] = { Place = SEA_PLACE_IDS.Third, Locations = { "Mirage Island", "MysticIsland" } },
    ["Prehistoric Island"] = { Place = SEA_PLACE_IDS.Third, Locations = { "Prehistoric Island", "PrehistoricIsland" } }
}

local function currentAccent()
    return (UI and UI.accent) or Accent
end

local function espColor(custom)
    return Settings.ESPUseAccent and currentAccent() or custom
end

local function connect(signal, callback)
    local connection = signal:Connect(callback)
    state.Connections[#state.Connections + 1] = connection
    return connection
end

local function newDrawing(kind, properties)
    local object = Drawing.new(kind)
    for key, value in pairs(properties or {}) do object[key] = value end
    state.Drawings[#state.Drawings + 1] = object
    return object
end

local function removeDrawing(object)
    if not object then return end
    pcall(function()
        object.Visible = false
        object:Remove()
    end)
end

local function hideGroup(group)
    if not group then return end
    for _, object in pairs(group) do
        if typeof(object) ~= "Instance" then pcall(function() object.Visible = false end) end
    end
end

local function getCharacter(player)
    local character = player and player.Character
    if not character or not character.Parent then return nil end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local root = character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart
    if not humanoid or not root or humanoid.Health <= 0 then return nil end
    return character, humanoid, root
end

local function getPart(instance)
    if not instance then return nil end
    if instance:IsA("BasePart") then return instance end
    if instance:IsA("Model") then
        return instance:FindFirstChild("HumanoidRootPart") or instance.PrimaryPart or instance:FindFirstChildWhichIsA("BasePart", true)
    end
    return instance:FindFirstChildWhichIsA("BasePart", true)
end

local function getHumanoid(instance)
    if not instance then return nil end
    if instance:IsA("Model") then return instance:FindFirstChildOfClass("Humanoid") end
    local model = instance:FindFirstAncestorOfClass("Model")
    return model and model:FindFirstChildOfClass("Humanoid") or nil
end

local function isBoss(model)
    if not model then return false end
    local name = string.lower(model.Name)
    return name:find("%[boss%]") ~= nil
        or name:find("boss") ~= nil
        or model:GetAttribute("Boss") == true
        or model:GetAttribute("IsBoss") == true
        or model:GetAttribute("RaidBoss") == true
end

local function equippedName(player)
    local character = player and player.Character
    if character then
        for _, child in ipairs(character:GetChildren()) do
            if child:IsA("Tool") then return child.Name end
        end
    end
    return nil
end

local function crewId(player)
    local data = player and player:FindFirstChild("Data")
    local crew = data and data:FindFirstChild("CrewID")
    return crew and tostring(crew.Value) or ""
end

local function isAlly(player)
    if not player or player == LocalPlayer then return true end
    local ownCrew, theirCrew = crewId(LocalPlayer), crewId(player)
    if ownCrew ~= "" and ownCrew == theirCrew then return true end
    if LocalPlayer.Team and player.Team == LocalPlayer.Team and LocalPlayer.Team.Name == "Marines" then return true end
    return false
end

local function characterBounds(character, camera)
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local root = character and (character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart)
    local head = character and character:FindFirstChild("Head")
    if not humanoid or not root or not head or not head:IsA("BasePart") then return nil end
    local top = camera:WorldToViewportPoint(head.Position + Vector3.new(0, math.max(1, head.Size.Y * 0.75), 0))
    local bottom = camera:WorldToViewportPoint(root.Position - Vector3.new(0, humanoid.HipHeight + root.Size.Y * 0.55, 0))
    if top.Z <= 0 or bottom.Z <= 0 then return nil end
    local height = math.max(math.abs(bottom.Y - top.Y), 4)
    local width = height * 0.55
    local centerX = (top.X + bottom.X) * 0.5
    local topY = math.min(top.Y, bottom.Y)
    return Vector2.new(centerX - width * 0.5, topY), Vector2.new(centerX + width * 0.5, topY + height)
end

local function worldBounds(instance)
    if not instance then return nil end
    if instance:IsA("BasePart") then return instance.CFrame, instance.Size end
    if instance:IsA("Model") then
        local ok, cf, size = pcall(instance.GetBoundingBox, instance)
        if ok then return cf, size end
    end
    local part = getPart(instance)
    return part and part.CFrame or nil, part and part.Size or nil
end

local function projectBounds(camera, cf, size, minimumSize)
    if not cf or not size then return nil end
    local half = size * 0.5
    local minX, minY = math.huge, math.huge
    local maxX, maxY = -math.huge, -math.huge
    local count = 0
    for x = -1, 1, 2 do
        for y = -1, 1, 2 do
            for z = -1, 1, 2 do
                local point = cf:PointToWorldSpace(Vector3.new(half.X * x, half.Y * y, half.Z * z))
                local screen = camera:WorldToViewportPoint(point)
                if screen.Z > 0 then
                    count = count + 1
                    minX, minY = math.min(minX, screen.X), math.min(minY, screen.Y)
                    maxX, maxY = math.max(maxX, screen.X), math.max(maxY, screen.Y)
                end
            end
        end
    end
    if count == 0 then return nil end
    local width, height = maxX - minX, maxY - minY
    if width < 2 or height < 2 then
        if not minimumSize then return nil end
        local centerX, centerY = (minX + maxX) * 0.5, (minY + maxY) * 0.5
        width, height = math.max(width, minimumSize), math.max(height, minimumSize)
        minX, maxX = centerX - width * 0.5, centerX + width * 0.5
        minY, maxY = centerY - height * 0.5, centerY + height * 0.5
    end
    return Vector2.new(minX - 2, minY - 2), Vector2.new(maxX + 2, maxY + 2)
end

local function createPlayerGroup(player)
    local group = {
        BoxOutline = newDrawing("Square", { Visible = false, Filled = false, Thickness = 3, Color = Color3.new(), Transparency = 0.82 }),
        Box = newDrawing("Square", { Visible = false, Filled = false, Thickness = 1.25, Color = Settings.PlayerColor }),
        Name = newDrawing("Text", { Visible = false, Center = true, Outline = true, Size = 13, Font = 2, Color = Settings.PlayerColor }),
        Info = newDrawing("Text", { Visible = false, Center = true, Outline = true, Size = 11, Font = 2, Color = Settings.PlayerColor }),
        HealthBack = newDrawing("Square", { Visible = false, Filled = true, Color = Color3.new(), Transparency = 0.82 }),
        Health = newDrawing("Square", { Visible = false, Filled = true, Color = Green }),
        Tracer = newDrawing("Line", { Visible = false, Thickness = 1, Color = Settings.PlayerColor })
    }
    -- Some Drawing implementations do not reliably retain Square.Filled from
    -- the constructor table. Keep player boxes explicitly outline-only.
    group.BoxOutline.Filled = false
    group.Box.Filled = false
    state.PlayerDrawings[player] = group
    return group
end

local function createWorldGroup(instance)
    local group = {
        BoxOutline = newDrawing("Square", { Visible = false, Filled = false, Thickness = 3, Color = Color3.new(), Transparency = 0.82 }),
        Box = newDrawing("Square", { Visible = false, Filled = false, Thickness = 1.25, Color = Accent }),
        Name = newDrawing("Text", { Visible = false, Center = true, Outline = true, Size = 13, Font = 2, Color = Accent }),
        Info = newDrawing("Text", { Visible = false, Center = true, Outline = true, Size = 11, Font = 2, Color = Accent }),
        HealthBack = newDrawing("Square", { Visible = false, Filled = true, Color = Color3.new(), Transparency = 0.82 }),
        Health = newDrawing("Square", { Visible = false, Filled = true, Color = Green })
    }
    state.WorldDrawings[instance] = group
    return group
end

local function removePlayer(player)
    local group = state.PlayerDrawings[player]
    if group then for _, object in pairs(group) do removeDrawing(object) end end
    state.PlayerDrawings[player] = nil
    local highlight = state.Highlights[player]
    if highlight then pcall(function() highlight:Destroy() end) end
    state.Highlights[player] = nil
    if state.AimTarget == player then state.AimTarget = nil end
end

local function removeWorld(instance)
    local group = state.WorldDrawings[instance]
    if group then for _, object in pairs(group) do removeDrawing(object) end end
    state.WorldDrawings[instance] = nil
end

local function updateHighlight(player, character, enabled, color)
    local highlight = state.Highlights[player]
    if not enabled then
        if highlight then highlight.Enabled = false end
        return
    end
    if not highlight or not highlight.Parent then
        highlight = Instance.new("Highlight")
        highlight.Name = "bob_lol_player"
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        if not pcall(function() highlight.Parent = CoreGui end) then highlight.Parent = workspace.CurrentCamera end
        state.Highlights[player] = highlight
    end
    highlight.Adornee = character
    highlight.FillColor = color
    highlight.OutlineColor = color
    highlight.FillTransparency = 0.85
    highlight.OutlineTransparency = 0.08
    highlight.Enabled = true
end

local function updatePlayerESP(camera, localRoot)
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local group = state.PlayerDrawings[player] or createPlayerGroup(player)
            hideGroup(group)
            local character, humanoid, root = getCharacter(player)
            local distance = root and localRoot and (root.Position - localRoot.Position).Magnitude or math.huge
            local maxDistance = tonumber(Settings.PlayerMaxDistance) or 0
            local enabled = Settings.PlayerESP and character and localRoot
                and (maxDistance <= 0 or distance <= maxDistance)
            local ally = enabled and isAlly(player)
            local color = espColor(ally and Settings.AllyColor or Settings.PlayerColor)
            updateHighlight(player, character, enabled and Settings.PlayerChams, color)
            if enabled then
                local point, onScreen = camera:WorldToViewportPoint(root.Position)
                if onScreen and point.Z > 0 then
                    local topLeft, bottomRight = characterBounds(character, camera)
                    if topLeft and bottomRight then
                        local width, height = bottomRight.X - topLeft.X, bottomRight.Y - topLeft.Y
                        group.BoxOutline.Filled = false
                        group.BoxOutline.Position = topLeft
                        group.BoxOutline.Size = Vector2.new(width, height)
                        group.BoxOutline.Visible = Settings.PlayerBoxes
                        group.Box.Filled = false
                        group.Box.Position = topLeft
                        group.Box.Size = Vector2.new(width, height)
                        group.Box.Color = color
                        group.Box.Visible = Settings.PlayerBoxes
                        group.Name.Position = Vector2.new(topLeft.X + width * 0.5, topLeft.Y - 16)
                        group.Name.Text = player.DisplayName ~= player.Name and (player.DisplayName .. "  (@" .. player.Name .. ")") or player.Name
                        group.Name.Color = color
                        group.Name.Visible = Settings.PlayerNames
                        local details = {}
                        if Settings.PlayerDistance then details[#details + 1] = tostring(math.floor(distance + 0.5)) .. "m" end
                        if player.Team then details[#details + 1] = player.Team.Name end
                        if Settings.PlayerEquipment then
                            local equipped = equippedName(player)
                            if equipped then details[#details + 1] = equipped end
                        end
                        group.Info.Position = Vector2.new(topLeft.X + width * 0.5, bottomRight.Y + 2)
                        group.Info.Text = table.concat(details, "  |  ")
                        group.Info.Color = color
                        group.Info.Visible = #details > 0
                        if Settings.PlayerHealth then
                            local ratio = math.clamp(humanoid.Health / math.max(humanoid.MaxHealth, 1), 0, 1)
                            group.HealthBack.Position = Vector2.new(topLeft.X - 6, topLeft.Y)
                            group.HealthBack.Size = Vector2.new(3, height)
                            group.HealthBack.Visible = true
                            group.Health.Position = Vector2.new(topLeft.X - 6, topLeft.Y + height * (1 - ratio))
                            group.Health.Size = Vector2.new(3, height * ratio)
                            group.Health.Color = Color3.fromRGB(math.floor(255 * (1 - ratio)), math.floor(230 * ratio), 70)
                            group.Health.Visible = true
                        end
                        if Settings.PlayerTracers then
                            group.Tracer.From = Vector2.new(camera.ViewportSize.X * 0.5, camera.ViewportSize.Y - 2)
                            group.Tracer.To = Vector2.new(topLeft.X + width * 0.5, bottomRight.Y)
                            group.Tracer.Color = color
                            group.Tracer.Visible = true
                        end
                    end
                end
            end
        end
    end
end

local function updateWorldObject(camera, localRoot, instance, color, label, details, healthRatio, boxes, minimumSize)
    local group = state.WorldDrawings[instance] or createWorldGroup(instance)
    hideGroup(group)
    local part = getPart(instance)
    if not part or not localRoot then return end
    local point, onScreen = camera:WorldToViewportPoint(part.Position)
    if not onScreen or point.Z <= 0 then return end
    local cf, size = worldBounds(instance)
    local topLeft, bottomRight = projectBounds(camera, cf, size, minimumSize)
    if not topLeft or not bottomRight then return end
    local width, height = bottomRight.X - topLeft.X, bottomRight.Y - topLeft.Y
    group.BoxOutline.Position = topLeft
    group.BoxOutline.Size = Vector2.new(width, height)
    group.BoxOutline.Visible = boxes ~= false
    group.Box.Position = topLeft
    group.Box.Size = Vector2.new(width, height)
    group.Box.Color = color
    group.Box.Visible = boxes ~= false
    group.Name.Position = Vector2.new(topLeft.X + width * 0.5, topLeft.Y - 16)
    group.Name.Text = label
    group.Name.Color = color
    group.Name.Visible = true
    group.Info.Position = Vector2.new(topLeft.X + width * 0.5, bottomRight.Y + 2)
    group.Info.Text = details or ""
    group.Info.Color = color
    group.Info.Visible = details ~= nil and details ~= ""
    if healthRatio then
        healthRatio = math.clamp(healthRatio, 0, 1)
        group.HealthBack.Position = Vector2.new(topLeft.X - 6, topLeft.Y)
        group.HealthBack.Size = Vector2.new(3, height)
        group.HealthBack.Visible = true
        group.Health.Position = Vector2.new(topLeft.X - 6, topLeft.Y + height * (1 - healthRatio))
        group.Health.Size = Vector2.new(3, height * healthRatio)
        group.Health.Color = Color3.fromRGB(math.floor(255 * (1 - healthRatio)), math.floor(230 * healthRatio), 70)
        group.Health.Visible = true
    end
end

local function formatFruitName(name)
    if typeof(name) == "Instance" then
        local originalName = name:GetAttribute("OriginalName")
            or name:GetAttribute("FruitName")
            or name:GetAttribute("DisplayName")
        if (type(originalName) ~= "string" or originalName == "") and name:GetAttribute("ItemId") ~= nil then
            local ok, storageKey = pcall(function()
                local itemIds = require(ReplicatedStorage.Economy.ItemId)
                local result = itemIds.getDataFromId(name:GetAttribute("ItemId"))
                local data = type(result) == "table" and type(result.unwrap) == "function" and result:unwrap() or result
                return data and (data.StorageKey or data.Name)
            end)
            if ok and type(storageKey) == "string" and storageKey ~= "" then originalName = storageKey end
        end
        name = type(originalName) == "string" and originalName ~= "" and originalName or name.Name
    end
    local raw = tostring(name or "Fruit")
    for index = 2, #raw - 1 do
        if raw:sub(index, index) == "-" then
            local left, right = raw:sub(1, index - 1), raw:sub(index + 1)
            if string.lower(left) == string.lower(right) then
                raw = left
                break
            end
        end
    end
    raw = raw:gsub("%-", " ")
    raw = raw:gsub("%s+[Ff]ruit$", "")
    return raw:match("^%s*(.-)%s*$") or raw
end

FarmRuntime.FruitSelectionKey = function(name)
    return string.gsub(string.lower(formatFruitName(name)), "[^%w]", "")
end

FarmRuntime.FruitPriorityRanks = {}
for index, fruitName in ipairs(AUTO_FRUIT_PRIORITY) do
    FarmRuntime.FruitPriorityRanks[FarmRuntime.FruitSelectionKey(fruitName)] = index
end

FarmRuntime.FruitPriorityRank = function(name)
    return FarmRuntime.FruitPriorityRanks[FarmRuntime.FruitSelectionKey(name)] or math.huge
end

local function physicalFruit(instance)
    if not instance or not (instance:IsA("Model") or instance:IsA("Tool")) then return false end
    local handle = instance:FindFirstChild("Handle")
    return handle and handle:IsA("BasePart") and (instance:FindFirstChild("Fruit") ~= nil or string.lower(instance.Name):find("fruit") ~= nil)
end

local function refreshFruits()
    local found = {}
    for _, child in ipairs(workspace:GetChildren()) do
        if physicalFruit(child) then
            found[child] = true
            if not state.Fruits[child] and Settings.FruitAlerts then
                showNotice(formatFruitName(child) .. " Fruit spawned", espColor(Settings.FruitColor), 6)
            end
        end
    end
    for fruit in pairs(state.Fruits) do
        if not found[fruit] then removeWorld(fruit) end
    end
    state.Fruits = found
    if FarmRuntime.RefreshPhysicalFruitChoices then FarmRuntime.RefreshPhysicalFruitChoices(false) end
end

local function updateWorldESP(camera, localRoot)
    local enemies = workspace:FindFirstChild("Enemies")
    if enemies then
        for _, model in ipairs(enemies:GetChildren()) do
            local humanoid = getHumanoid(model)
            local part = getPart(model)
            local boss = isBoss(model)
            local distance = part and localRoot and (part.Position - localRoot.Position).Magnitude or math.huge
            local enabled = humanoid and humanoid.Health > 0 and distance <= Settings.EnemyMaxDistance and ((boss and Settings.BossESP) or (not boss and Settings.EnemyESP))
            if enabled then
                local color = espColor(boss and Settings.BossColor or Settings.EnemyColor)
                local health = Settings.EnemyHealth and humanoid.Health / math.max(humanoid.MaxHealth, 1) or nil
                local info = Settings.EnemyDistance and (tostring(math.floor(distance + 0.5)) .. "m") or ""
                updateWorldObject(camera, localRoot, model, color, model.Name, info, health, Settings.EnemyBoxes)
            else
                hideGroup(state.WorldDrawings[model])
            end
        end
    end
    for fruit in pairs(state.Fruits) do
        local part = getPart(fruit)
        local distance = part and localRoot and (part.Position - localRoot.Position).Magnitude or math.huge
        local maxDistance = tonumber(Settings.FruitMaxDistance) or 0
        if Settings.FruitESP and fruit.Parent and part and localRoot
            and (maxDistance <= 0 or distance <= maxDistance) then
            updateWorldObject(camera, localRoot, fruit, espColor(Settings.FruitColor), formatFruitName(fruit) .. " Fruit", tostring(math.floor(distance + 0.5)) .. "m", nil, true, 4)
        else
            hideGroup(state.WorldDrawings[fruit])
        end
    end
    for _, folderName in ipairs({ "SeaBeasts", "SeaEvents" }) do
        local folder = workspace:FindFirstChild(folderName)
        if folder then
            for _, instance in ipairs(folder:GetChildren()) do
                if Settings.SeaESP then
                    local part = getPart(instance)
                    local distance = part and localRoot and (part.Position - localRoot.Position).Magnitude or 0
                    updateWorldObject(camera, localRoot, instance, espColor(Settings.SeaColor), instance.Name, tostring(math.floor(distance + 0.5)) .. "m", nil, true)
                else
                    hideGroup(state.WorldDrawings[instance])
                end
            end
        end
    end
    local chest = state.NearestChestInstance
    if Settings.NearestChest and chest and chest.Parent then
        local part = getPart(chest)
        local distance = part and localRoot and (part.Position - localRoot.Position).Magnitude or 0
        updateWorldObject(camera, localRoot, chest, espColor(Settings.ChestColor), "Nearest Chest", tostring(math.floor(distance + 0.5)) .. "m", nil, true)
    elseif chest then
        hideGroup(state.WorldDrawings[chest])
    end
    local mirageDealer = state.MirageDealer
    if Settings.MirageDealerESP and mirageDealer and mirageDealer.Parent then
        local part = getPart(mirageDealer)
        local distance = part and localRoot and (part.Position - localRoot.Position).Magnitude or 0
        local info = Settings.MirageESPDistance and (tostring(math.floor(distance + 0.5)) .. "m") or ""
        updateWorldObject(camera, localRoot, mirageDealer, espColor(Settings.MirageDealerColor), "Advanced Fruit Dealer", info, nil, Settings.MirageESPBoxes, 8)
    elseif mirageDealer then
        hideGroup(state.WorldDrawings[mirageDealer])
    end
    local mirageGear = state.MirageGear
    if Settings.MirageGearESP and mirageGear and mirageGear.Parent then
        local part = getPart(mirageGear)
        local distance = part and localRoot and (part.Position - localRoot.Position).Magnitude or 0
        local info = Settings.MirageESPDistance and (tostring(math.floor(distance + 0.5)) .. "m") or ""
        updateWorldObject(camera, localRoot, mirageGear, Settings.MirageGearColor, "Blue Gear", info, nil, Settings.MirageESPBoxes, 10)
    elseif mirageGear then
        hideGroup(state.WorldDrawings[mirageGear])
    end
end

local function aimPart(player)
    local character = player and player.Character
    if not character then return nil end
    return character:FindFirstChild(Settings.AimPart)
        or character:FindFirstChild("Head")
        or character:FindFirstChild("UpperTorso")
        or character:FindFirstChild("HumanoidRootPart")
end

local function visibleToCamera(player)
    local camera = workspace.CurrentCamera
    local part = aimPart(player)
    if not camera or not part or not player.Character then return false end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = LocalPlayer.Character and { LocalPlayer.Character } or {}
    params.IgnoreWater = true
    local result = workspace:Raycast(camera.CFrame.Position, part.Position - camera.CFrame.Position, params)
    return not result or result.Instance:IsDescendantOf(player.Character)
end

local function aimHeld()
    if typeof(Settings.AimKey) ~= "EnumItem" then return false end
    if Settings.AimKey.EnumType == Enum.KeyCode then return UserInputService:IsKeyDown(Settings.AimKey) end
    return UserInputService:IsMouseButtonPressed(Settings.AimKey)
end

local function validAimTarget(player, localRoot)
    if not player or player == LocalPlayer then return false end
    local _, humanoid, root = getCharacter(player)
    if not humanoid or not root or not localRoot then return false end
    if Settings.AimAllyCheck and isAlly(player) then return false end
    if (root.Position - localRoot.Position).Magnitude > Settings.AimMaxDistance then return false end
    if Settings.AimVisibleOnly and not visibleToCamera(player) then return false end
    return aimPart(player) ~= nil
end

local function findAimTarget(camera, localRoot)
    local mouse = UserInputService:GetMouseLocation()
    local best, bestDistance = nil, Settings.AimFov
    for _, player in ipairs(Players:GetPlayers()) do
        if validAimTarget(player, localRoot) then
            local part = aimPart(player)
            local point, onScreen = camera:WorldToViewportPoint(part.Position)
            if onScreen and point.Z > 0 then
                local distance = (Vector2.new(point.X, point.Y) - mouse).Magnitude
                if distance < bestDistance then
                    best, bestDistance = player, distance
                end
            end
        end
    end
    return best
end

local fovCircle = newDrawing("Circle", {
    Visible = false,
    Filled = false,
    Thickness = 1,
    NumSides = 72,
    Radius = Settings.AimFov,
    Color = Settings.FovColor,
    Transparency = 0.92
})

local function ensureNotificationGui()
    if state.NotificationGui and state.NotificationGui.Parent and state.NotificationContainer then
        return state.NotificationContainer
    end
    local screen = Instance.new("ScreenGui")
    screen.Name = "bob_lol_notifications"
    screen.ResetOnSpawn = false
    screen.IgnoreGuiInset = true
    screen.DisplayOrder = 1000000
    screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    local parent = CoreGui
    if gethui then
        local ok, result = pcall(gethui)
        if ok and result then parent = result end
    end
    if not pcall(function() screen.Parent = parent end) then
        screen.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
    local container = Instance.new("Frame")
    container.Name = "Stack"
    container.AnchorPoint = Vector2.zero
    container.Position = UDim2.fromOffset(20, 30)
    container.Size = UDim2.fromOffset(450, 500)
    container.BackgroundTransparency = 1
    container.Parent = screen
    local layout = Instance.new("UIListLayout")
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 12)
    layout.Parent = container
    state.NotificationGui = screen
    state.NotificationContainer = container
    return container
end

local function removeNotificationEntry(entry)
    for index, existing in ipairs(state.Notifications) do
        if existing == entry then
            table.remove(state.Notifications, index)
            break
        end
    end
end

local dismissNotification
dismissNotification = function(entry, immediate)
    if not entry or entry.Closing then return end
    entry.Closing = true
    removeNotificationEntry(entry)
    if not entry.Holder or not entry.Holder.Parent then return end
    if immediate then
        entry.Holder:Destroy()
        return
    end
    if entry.Card and entry.Card.Parent then
        TweenService:Create(entry.Card, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
            Position = UDim2.fromOffset(-50, 0),
            GroupTransparency = 1
        }):Play()
    end
    task.delay(0.22, function()
        if entry.Holder then pcall(function() entry.Holder:Destroy() end) end
    end)
end

showNotice = function(text, color, duration)
    if not state.Alive then return end
    local container = ensureNotificationGui()
    while #state.Notifications >= 5 do dismissNotification(state.Notifications[1], true) end
    local accent = color or currentAccent()
    local dynamicAccent = color == nil or color == Accent or color == currentAccent()
    local message = tostring(text or "")
    local unbounded = TextService:GetTextSize(message, 14, Enum.Font.Code, Vector2.new(1000, 100))
    local textWidth = math.min(unbounded.X, 390)
    local bounded = TextService:GetTextSize(message, 14, Enum.Font.Code, Vector2.new(textWidth, 120))
    local boxWidth = math.clamp(textWidth + 42, 150, 432)
    local boxHeight = math.max(40, bounded.Y + 24)
    local holder = Instance.new("Frame")
    holder.Name = "Notice"
    holder.Size = UDim2.fromOffset(boxWidth + 4, boxHeight + 4)
    holder.BackgroundTransparency = 1
    holder.ClipsDescendants = false
    holder.Parent = container
    local card = Instance.new("CanvasGroup")
    card.Name = "Card"
    card.Position = UDim2.fromOffset(-50, 0)
    card.Size = UDim2.fromOffset(boxWidth + 4, boxHeight + 4)
    card.BackgroundTransparency = 1
    card.GroupTransparency = 1
    card.ClipsDescendants = false
    card.Parent = holder
    local shadow = Instance.new("Frame")
    shadow.Name = "Shadow"
    shadow.Position = UDim2.fromOffset(2, 4)
    shadow.Size = UDim2.fromOffset(boxWidth, boxHeight)
    shadow.BackgroundColor3 = Color3.new()
    shadow.BackgroundTransparency = 0.6
    shadow.BorderSizePixel = 0
    shadow.Parent = card
    local shadowCorner = Instance.new("UICorner")
    shadowCorner.CornerRadius = UDim.new(0, 8)
    shadowCorner.Parent = shadow
    local surface = Instance.new("Frame")
    surface.Name = "Surface"
    surface.Size = UDim2.fromOffset(boxWidth, boxHeight)
    surface.BackgroundColor3 = Color3.fromRGB(20, 20, 22)
    surface.BackgroundTransparency = 0.06
    surface.BorderSizePixel = 0
    surface.ClipsDescendants = true
    surface.Parent = card
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = surface
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(40, 40, 45)
    stroke.Transparency = 0
    stroke.Thickness = 1
    stroke.Parent = surface
    local bar = Instance.new("Frame")
    bar.Name = "Accent"
    bar.Size = UDim2.new(0, 4, 1, 0)
    bar.BackgroundColor3 = accent
    bar.BorderSizePixel = 0
    bar.Parent = surface
    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(0, 8)
    barCorner.Parent = bar
    local body = Instance.new("TextLabel")
    body.Name = "Message"
    body.Position = UDim2.fromOffset(18, 0)
    body.Size = UDim2.new(1, -30, 1, 0)
    body.BackgroundTransparency = 1
    body.Font = Enum.Font.Code
    body.Text = message
    body.TextColor3 = Color3.fromRGB(245, 245, 250)
    body.TextSize = 14
    body.TextWrapped = unbounded.X > 390
    body.TextXAlignment = Enum.TextXAlignment.Left
    body.TextYAlignment = Enum.TextYAlignment.Center
    body.Parent = surface
    local entry = {
        Holder = holder,
        Card = card,
        Bar = bar,
        DynamicAccent = dynamicAccent,
        Closing = false
    }
    state.Notifications[#state.Notifications + 1] = entry
    local lifetime = math.max(1, tonumber(duration) or 3)
    TweenService:Create(card, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Position = UDim2.fromOffset(0, 0),
        GroupTransparency = 0
    }):Play()
    task.delay(lifetime, function()
        if state.Alive then dismissNotification(entry, false) else dismissNotification(entry, true) end
    end)
end

local function contextNotice(key, text, color, duration, cooldown)
    if not state.Alive then return end
    key = tostring(key or text or "Context")
    text = tostring(text or "This option is unavailable")
    local now = os.clock()
    local previous = state.ContextNotices[key]
    if previous and previous.Text == text and now < previous.Next then return end
    state.ContextNotices[key] = {
        Text = text,
        Next = now + math.max(1, tonumber(cooldown) or 5)
    }
    showNotice(text, color or Red, duration or 4)
end

local function updateNotificationAccents()
    local accent = currentAccent()
    for _, entry in ipairs(state.Notifications) do
        if entry.DynamicAccent and not entry.Closing then
            if entry.Bar then entry.Bar.BackgroundColor3 = accent end
        end
    end
end

local function formatMoney(value)
    local text = tostring(math.max(0, math.floor(tonumber(value) or 0)))
    local formatted = text:reverse():gsub("(%d%d%d)", "%1,"):reverse()
    return "$" .. formatted:gsub("^,", "")
end

local function ensureStockPanel()
    ensureNotificationGui()
    if state.StockPanel and state.StockPanel.Parent then return state.StockPanel end
    local panel = Instance.new("CanvasGroup")
    panel.Name = "FruitStock"
    panel.AnchorPoint = Vector2.new(0, 1)
    panel.Position = UDim2.new(1, -306, 1, -8)
    panel.Size = UDim2.fromOffset(286, 86)
    panel.BackgroundColor3 = Color3.fromRGB(16, 17, 20)
    panel.BackgroundTransparency = 0
    panel.GroupTransparency = 1
    panel.ClipsDescendants = true
    panel.Visible = false
    panel.Parent = state.NotificationGui
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = panel
    local stroke = Instance.new("UIStroke")
    stroke.Color = currentAccent()
    stroke.Transparency = 0.08
    stroke.Thickness = 1
    stroke.Parent = panel
    local accent = Instance.new("Frame")
    accent.Name = "Accent"
    accent.Size = UDim2.new(1, 0, 0, 2)
    accent.BackgroundColor3 = currentAccent()
    accent.BorderSizePixel = 0
    accent.Parent = panel
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Position = UDim2.fromOffset(12, 9)
    title.Size = UDim2.new(0.65, -12, 0, 18)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.Code
    title.Text = "Fruit Stock"
    title.TextColor3 = currentAccent()
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = panel
    local count = Instance.new("TextLabel")
    count.Name = "Count"
    count.AnchorPoint = Vector2.new(1, 0)
    count.Position = UDim2.new(1, -12, 0, 10)
    count.Size = UDim2.new(0.35, -8, 0, 16)
    count.BackgroundTransparency = 1
    count.Font = Enum.Font.Code
    count.TextColor3 = Color3.fromRGB(150, 151, 160)
    count.TextSize = 12
    count.TextXAlignment = Enum.TextXAlignment.Right
    count.Parent = panel
    local separator = Instance.new("Frame")
    separator.Position = UDim2.fromOffset(10, 34)
    separator.Size = UDim2.new(1, -20, 0, 1)
    separator.BackgroundColor3 = Color3.fromRGB(52, 53, 60)
    separator.BorderSizePixel = 0
    separator.Parent = panel
    local list = Instance.new("Frame")
    list.Name = "Rows"
    list.Position = UDim2.fromOffset(10, 42)
    list.Size = UDim2.new(1, -20, 1, -50)
    list.BackgroundTransparency = 1
    list.Parent = panel
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 4)
    layout.Parent = list
    state.StockPanel = panel
    state.StockStroke = stroke
    state.StockAccent = accent
    state.StockTitle = title
    state.StockCount = count
    state.StockList = list
    return panel
end

local function rebuildStockPanel()
    local panel = ensureStockPanel()
    for _, child in ipairs(state.StockList:GetChildren()) do
        if not child:IsA("UIListLayout") then child:Destroy() end
    end
    state.StockPriceLabels = {}
    local entries = state.Stock
    local rowCount = math.max(1, #entries)
    state.StockCount.Text = #entries == 1 and "1 available" or (tostring(#entries) .. " available")
    if #entries == 0 then
        entries = { { Name = "Unavailable", Price = nil } }
        state.StockCount.Text = ""
    end
    for index, fruit in ipairs(entries) do
        local row = Instance.new("Frame")
        row.Name = "Row" .. tostring(index)
        row.LayoutOrder = index
        row.Size = UDim2.new(1, 0, 0, 25)
        row.BackgroundColor3 = index % 2 == 0 and Color3.fromRGB(24, 25, 29) or Color3.fromRGB(21, 22, 26)
        row.BorderSizePixel = 0
        row.Parent = state.StockList
        local rowCorner = Instance.new("UICorner")
        rowCorner.CornerRadius = UDim.new(0, 3)
        rowCorner.Parent = row
        local name = Instance.new("TextLabel")
        name.Position = UDim2.fromOffset(8, 0)
        name.Size = UDim2.new(0.62, -8, 1, 0)
        name.BackgroundTransparency = 1
        name.Font = Enum.Font.Code
        name.Text = tostring(fruit.Name or "Fruit")
        name.TextColor3 = Color3.fromRGB(226, 227, 232)
        name.TextSize = 12
        name.TextTruncate = Enum.TextTruncate.AtEnd
        name.TextXAlignment = Enum.TextXAlignment.Left
        name.Parent = row
        if fruit.Price ~= nil then
            local price = Instance.new("TextLabel")
            price.AnchorPoint = Vector2.new(1, 0)
            price.Position = UDim2.new(1, -8, 0, 0)
            price.Size = UDim2.new(0.38, -4, 1, 0)
            price.BackgroundTransparency = 1
            price.Font = Enum.Font.Code
            price.Text = formatMoney(fruit.Price)
            price.TextColor3 = currentAccent()
            price.TextSize = 12
            price.TextXAlignment = Enum.TextXAlignment.Right
            price.Parent = row
            state.StockPriceLabels[#state.StockPriceLabels + 1] = price
        end
    end
    panel.Size = UDim2.fromOffset(286, 50 + rowCount * 29)
end

local function stockRenderSignature()
    local parts = {}
    for _, fruit in ipairs(state.Stock) do
        parts[#parts + 1] = tostring(fruit.RawName or fruit.Name) .. ":" .. tostring(fruit.Price or 0)
    end
    return table.concat(parts, "|")
end

local function updateStockOverlay()
    local panel = ensureStockPanel()
    local signature = stockRenderSignature()
    if signature ~= state.StockRenderedSignature then
        state.StockRenderedSignature = signature
        rebuildStockPanel()
        panel = state.StockPanel
    end
    local accent = currentAccent()
    state.StockStroke.Color = accent
    state.StockAccent.BackgroundColor3 = accent
    state.StockTitle.TextColor3 = accent
    for _, label in ipairs(state.StockPriceLabels) do label.TextColor3 = accent end
    if Settings.StockOverlay and not state.StockVisible then
        state.StockVisible = true
        state.StockHideSerial = (state.StockHideSerial or 0) + 1
        panel.Visible = true
        panel.Position = UDim2.new(1, -306, 1, -8)
        panel.GroupTransparency = 1
        TweenService:Create(panel, TweenInfo.new(0.24, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Position = UDim2.new(1, -306, 1, -20),
            GroupTransparency = 0
        }):Play()
    elseif not Settings.StockOverlay and state.StockVisible then
        state.StockVisible = false
        state.StockHideSerial = (state.StockHideSerial or 0) + 1
        local serial = state.StockHideSerial
        TweenService:Create(panel, TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
            Position = UDim2.new(1, -306, 1, -8),
            GroupTransparency = 1
        }):Play()
        task.delay(0.2, function()
            if state.StockPanel == panel and not state.StockVisible and state.StockHideSerial == serial then panel.Visible = false end
        end)
    end
end

local function updateOverlays()
    updateStockOverlay()
end

local function updateAimbot(camera, localRoot, deltaTime)
    local mouse = UserInputService:GetMouseLocation()
    fovCircle.Position = mouse
    fovCircle.Radius = Settings.AimFov
    fovCircle.Color = Settings.FovColor
    fovCircle.Visible = Settings.ShowFov
    if not Settings.Aimbot or not aimHeld() or not localRoot then
        state.AimTarget = nil
        return
    end
    if not Settings.AimSticky or not validAimTarget(state.AimTarget, localRoot) then
        state.AimTarget = findAimTarget(camera, localRoot)
    end
    local part = aimPart(state.AimTarget)
    if not part then return end
    local predicted = part.Position + part.AssemblyLinearVelocity * (Settings.AimPrediction / 1000)
    local desired = CFrame.lookAt(camera.CFrame.Position, predicted)
    local response = math.max(1, 24 - Settings.AimSmoothness * 1.75)
    local alpha = 1 - math.exp(-response * deltaTime)
    camera.CFrame = camera.CFrame:Lerp(desired, math.clamp(alpha, 0, 1))
end

local function hitboxSize()
    if Settings.HitboxUniform then
        return Vector3.new(Settings.HitboxSize, Settings.HitboxSize, Settings.HitboxSize)
    end
    return Vector3.new(Settings.HitboxX, Settings.HitboxY, Settings.HitboxZ)
end

local function createAdornment(part)
    local adornment = Instance.new("BoxHandleAdornment")
    adornment.Name = "bob_lol_hitbox"
    adornment.Adornee = part
    adornment.AlwaysOnTop = true
    adornment.ZIndex = 10
    adornment.Transparency = 0.72
    adornment.Color3 = espColor(Settings.HitboxColor)
    if not pcall(function() adornment.Parent = CoreGui end) then adornment.Parent = workspace.CurrentCamera end
    state.Adornments[part] = adornment
    return adornment
end

local function createVisualHead(part, original)
    if not part or part.Name ~= "Head" or not original then return nil end
    local ok, clone = pcall(function() return part:Clone() end)
    if not ok or not clone then return nil end
    clone.Name = "bob_lol_visual_head"
    for _, child in ipairs(clone:GetDescendants()) do
        if child:IsA("JointInstance") or child:IsA("WeldConstraint") or child:IsA("Attachment")
            or child:IsA("Script") or child:IsA("LocalScript") or child:IsA("ModuleScript")
        then
            child:Destroy()
        end
    end
    clone.Size = original.Size
    clone.CFrame = part.CFrame
    clone.CanCollide = false
    clone.CanTouch = false
    clone.CanQuery = false
    clone.Massless = true
    clone.Anchored = true
    clone.LocalTransparencyModifier = original.LocalTransparencyModifier
    clone.Parent = part.Parent
    local weld = Instance.new("WeldConstraint")
    weld.Name = "bob_lol_visual_weld"
    weld.Part0 = part
    weld.Part1 = clone
    weld.Parent = clone
    clone.Anchored = false
    state.VisualHeads[part] = clone
    return clone
end

local function restoreExpanded(part)
    local original = state.Expanded[part]
    if original and part and part.Parent then
        local native = FarmRuntime.ObfuscationCompatibility.Native
        local restored = Settings.ObfuscationCompatibility and native and pcall(native.RestoreHitbox, part, original)
        if not restored then
            pcall(function()
                part.Size = original.Size
                part.CanCollide = original.CanCollide
                part.CanTouch = original.CanTouch
                part.CanQuery = original.CanQuery
                part.Massless = original.Massless
                part.LocalTransparencyModifier = original.LocalTransparencyModifier
            end)
        end
    end
    local visual = state.VisualHeads[part]
    if visual then pcall(function() visual:Destroy() end) end
    state.VisualHeads[part] = nil
    state.Expanded[part] = nil
    local adornment = state.Adornments[part]
    if adornment then pcall(function() adornment:Destroy() end) end
    state.Adornments[part] = nil
end

local function restoreAllExpanded()
    local parts = {}
    for part in pairs(state.Expanded) do parts[#parts + 1] = part end
    for _, part in ipairs(parts) do restoreExpanded(part) end
end

local function collectHitboxTargets(localRoot)
    local native = FarmRuntime.ObfuscationCompatibility.Native
    if Settings.ObfuscationCompatibility and native then
        local ok, targets = pcall(native.CollectHitboxTargets, Players, LocalPlayer, workspace, localRoot, Settings, state.FarmTarget, state.SpecialFarm ~= nil)
        if ok and type(targets) == "table" then return targets end
    end
    local targets = {}
    local manualSize = hitboxSize()
    if Settings.Hitbox and Settings.HitboxPlayers then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and (not Settings.AimAllyCheck or not isAlly(player)) then
                local character, _, root = getCharacter(player)
                local part = character and (character:FindFirstChild("Head") or root)
                if part and part:IsA("BasePart") and (part.Position - localRoot.Position).Magnitude <= Settings.HitboxDistance then targets[part] = manualSize end
            end
        end
    end
    local enemies = Settings.Hitbox and workspace:FindFirstChild("Enemies")
    if enemies then
        for _, model in ipairs(enemies:GetChildren()) do
            local humanoid = getHumanoid(model)
            local root = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
            local part = model:FindFirstChild("Head") or root
            local boss = isBoss(model)
            local enabled = (boss and Settings.HitboxBosses) or (not boss and Settings.HitboxEnemies)
            if enabled and humanoid and humanoid.Health > 0 and part and part:IsA("BasePart") and (part.Position - localRoot.Position).Magnitude <= Settings.HitboxDistance then
                targets[part] = manualSize
            end
        end
    end
    if Settings.AutoFarm or state.SpecialFarm then
        local target = state.FarmTarget
        local humanoid = getHumanoid(target)
        local root = getPart(target)
        local part = target and (target:FindFirstChild("Head") or root)
        if humanoid and humanoid.Health > 0 and part and part:IsA("BasePart") then
            targets[part] = Vector3.new(20, 20, 20)
        end
    end
    return targets
end

local function updateHitboxes(localRoot)
    if (not Settings.Hitbox and not Settings.AutoFarm and not state.SpecialFarm) or not localRoot then
        restoreAllExpanded()
        return
    end
    local targets = collectHitboxTargets(localRoot)
    for part, size in pairs(targets) do
        if not state.Expanded[part] then
            state.Expanded[part] = {
                Size = part.Size,
                CanCollide = part.CanCollide,
                CanTouch = part.CanTouch,
                CanQuery = part.CanQuery,
                Massless = part.Massless,
                LocalTransparencyModifier = part.LocalTransparencyModifier
            }
        end
        local original = state.Expanded[part]
        local visual = state.VisualHeads[part]
        if part.Name == "Head" and (not visual or not visual.Parent) then
            visual = createVisualHead(part, original)
        end
        local native = FarmRuntime.ObfuscationCompatibility.Native
        local applied = Settings.ObfuscationCompatibility and native and pcall(native.ApplyHitbox, part, size, visual ~= nil)
        if not applied then
            pcall(function()
                part.Size = size
                part.CanCollide = false
                part.CanTouch = false
                part.CanQuery = true
                part.Massless = true
                if visual then part.LocalTransparencyModifier = 1 end
            end)
        end
        local adornment = state.Adornments[part]
        if Settings.Hitbox and Settings.HitboxWireframe then
            adornment = adornment or createAdornment(part)
            adornment.Size = size
            adornment.Color3 = espColor(Settings.HitboxColor)
            adornment.Visible = true
        elseif adornment then
            adornment.Visible = false
        end
    end
    local stale = {}
    for part in pairs(state.Expanded) do if not targets[part] then stale[#stale + 1] = part end end
    for _, part in ipairs(stale) do restoreExpanded(part) end
end

local function setCameraShake(disabled)
    Settings.NoCameraShake = disabled
    if not state.CameraShaker then
        local ok, util = pcall(require, ReplicatedStorage:WaitForChild("Util"))
        if ok and type(util) == "table" then state.CameraShaker = util.CameraShaker end
    end
    if state.CameraShaker and type(state.CameraShaker.SetEnabled) == "function" then
        pcall(function() state.CameraShaker:SetEnabled(not disabled) end)
    end
end

local function applyAura()
    if not Settings.AutoAura or os.clock() - state.LastAura < 1.5 then return end
    state.LastAura = os.clock()
    local character = LocalPlayer.Character
    if character and not character:FindFirstChild("HasBuso") then
        task.spawn(function() pcall(function() CommF:InvokeServer("Buso") end) end)
    end
end

local function restoreCollision()
    for part, value in pairs(state.Collision) do
        if part and part.Parent then pcall(function() part.CanCollide = value end) end
        state.Collision[part] = nil
    end
end

local function setCharacterCollision(character, disabled)
    if not character then return end
    if disabled then
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                if state.Collision[part] == nil then state.Collision[part] = part.CanCollide end
                part.CanCollide = false
            end
        end
    else
        restoreCollision()
    end
end

local function stopTravel(message)
    local stoppedIslandTravel = state.TravelButtonKey == "specialIsland"
    state.TravelSerial = state.TravelSerial + 1
    state.TravelTarget = nil
    state.TravelName = nil
    state.TravelMode = nil
    state.TravelObject = nil
    state.TravelOwner = nil
    state.TravelButtonKey = nil
    state.TravelBudget = 0
    state.AutomationMoveSeconds = 0
    state.AutomationMovePauseUntil = 0
    state.AutomationMoveOwner = nil
    if stoppedIslandTravel then state.IslandFinderTravelActive = false end
    if not Settings.Noclip and not state.BartiloPuzzleNoclip and not state.SaberPuzzleNoclip then restoreCollision() end
    if FarmRuntime.RefreshTravelButtons then FarmRuntime.RefreshTravelButtons() end
    if message then showNotice(message, Muted, 2.5) end
end

local function beginTravel(position, name, mode, object, silent, buttonKey)
    local _, _, root = getCharacter(LocalPlayer)
    mode = mode or "manual"
    if Settings.AutoFish and FarmRuntime.StopFishing then FarmRuntime.StopFishing(true) end
    local fruitOverride = mode == "fruit" and state.FruitOverrideActive
    local specialBlocksTravel = state.SpecialOwner and (state.SpecialFarm ~= nil
        or state.TravelOwner == state.SpecialOwner or state.SpecialData.BlockNormalFarm == true)
    local sea2ProgressionActive = Settings.AutoSea2 and game.PlaceId == SEA_PLACE_IDS.First
    if ((Settings.AutoFarm and not fruitOverride) or sea2ProgressionActive or (specialBlocksTravel and not fruitOverride))
        and string.sub(mode, 1, 4) ~= "farm" then
        showNotice("Disable farming before starting another travel", Red, 3)
        return false
    end
    if not root or typeof(position) ~= "Vector3" then
        showNotice("Travel target unavailable", Red, 3)
        return false
    end
    state.TravelTarget = position
    state.TravelName = name or "Target"
    state.TravelMode = mode
    state.TravelObject = object
    state.TravelOwner = mode == "fruit" and "fruit"
        or (mode == "chest" or mode == "chestIsland") and "chest" or "manual"
    state.TravelButtonKey = buttonKey
    state.TravelSerial = state.TravelSerial + 1
    state.TravelBudget = 0
    if FarmRuntime.RefreshTravelButtons then FarmRuntime.RefreshTravelButtons() end
    if not silent then showNotice("Travelling to " .. state.TravelName, nil, 3) end
    return true
end

local function moveInOneStudSteps(root, direction, speed, deltaTime, budgetKey, maximumDistance)
    state[budgetKey] = math.min((state[budgetKey] or 0) + math.clamp(speed, 1, 200) * deltaTime, 30)
    local count = math.min(math.floor(state[budgetKey]), 30)
    if maximumDistance then count = math.min(count, math.ceil(maximumDistance)) end
    if count <= 0 then return 0 end
    local moved = 0
    local rotation = root.CFrame - root.Position
    for _ = 1, count do
        local step = maximumDistance and math.min(1, maximumDistance - moved) or 1
        if step <= 0 then break end
        root.CFrame = CFrame.new(root.Position + direction * step) * rotation
        moved = moved + step
    end
    state[budgetKey] = math.max(0, state[budgetKey] - moved)
    return moved
end

FarmRuntime.AutomationMovementReady = function(owner, deltaTime)
    owner = tostring(owner or "travel")
    local now = os.clock()
    if state.AutomationMoveOwner ~= owner then
        state.AutomationMoveOwner = owner
        state.AutomationMoveSeconds = 0
        state.AutomationMovePauseUntil = 0
    end
    if now < state.AutomationMovePauseUntil then
        state.TravelBudget = 0
        return false
    end
    if state.AutomationMovePauseUntil > 0 then
        state.AutomationMovePauseUntil = 0
        state.AutomationMoveSeconds = 0
    end
    state.AutomationMoveSeconds = state.AutomationMoveSeconds + math.clamp(tonumber(deltaTime) or 0, 0, 0.25)
    if state.AutomationMoveSeconds >= 5 then
        state.AutomationMoveSeconds = 0
        state.AutomationMovePauseUntil = now + 0.2
        state.TravelBudget = 0
        return false
    end
    return true
end

FarmRuntime.SafeTravelWaypoint = function(root, destination, mode)
    if not root or typeof(destination) ~= "Vector3" then return destination end

    -- Instanced interiors use coordinates far outside the normal sea map and
    -- do not contain the overworld ocean between their local destinations.
    local rootInterior = math.abs(root.Position.X) > 30000 or math.abs(root.Position.Z) > 25000 or root.Position.Y < -500
    local targetInterior = math.abs(destination.X) > 30000 or math.abs(destination.Z) > 25000 or destination.Y < -500
    if rootInterior and targetInterior then return destination end

    local horizontal = Vector3.new(destination.X - root.Position.X, 0, destination.Z - root.Position.Z)
    if horizontal.Magnitude <= 35 then return destination end

    -- Long routes ascend first, cross the sea at a stable height, and only
    -- descend once directly above the destination. farmTransition still
    -- reaches the Sea 1 whirlpool exactly, so its normal gravity drop works.
    local cruiseY = math.max(115, root.Position.Y, destination.Y + 55)
    if root.Position.Y < cruiseY - 2 then
        return Vector3.new(root.Position.X, cruiseY, root.Position.Z)
    end
    return Vector3.new(destination.X, cruiseY, destination.Z)
end

local function flightDirection(camera)
    local look = Vector3.new(camera.CFrame.LookVector.X, 0, camera.CFrame.LookVector.Z)
    local right = Vector3.new(camera.CFrame.RightVector.X, 0, camera.CFrame.RightVector.Z)
    if look.Magnitude > 0 then look = look.Unit end
    if right.Magnitude > 0 then right = right.Unit end
    local direction = Vector3.zero
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction = direction + look end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction = direction - look end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction = direction + right end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction = direction - right end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then direction = direction + Vector3.yAxis end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then direction = direction - Vector3.yAxis end
    return direction.Magnitude > 0 and direction.Unit or Vector3.zero
end

local function ensureWaterPart()
    if state.WaterPart and state.WaterPart.Parent then return state.WaterPart end
    local part = Instance.new("Part")
    part.Name = "bob_lol_water_walk"
    part.Anchored = true
    part.CanCollide = false
    part.CanTouch = false
    part.CanQuery = false
    part.Transparency = 1
    part.Size = Vector3.new(14, 0.5, 14)
    part.Parent = workspace
    state.WaterPart = part
    return part
end

local function updateWaterWalk(character, root)
    local platform = ensureWaterPart()
    platform.CanCollide = false
    if not Settings.WaterWalk or not character or not root then return end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { character, platform }
    params.IgnoreWater = false
    local result = workspace:Raycast(root.Position, Vector3.new(0, -12, 0), params)
    if result and result.Material == Enum.Material.Water then
        platform.CFrame = CFrame.new(result.Position + Vector3.new(0, 0.15, 0))
        platform.CanCollide = true
    end
end

local function captureLighting()
    if state.LightingSnapshot then return end
    local atmospheres = {}
    for _, instance in ipairs(Lighting:GetChildren()) do
        if instance:IsA("Atmosphere") then atmospheres[instance] = instance.Density end
    end
    state.LightingSnapshot = {
        Ambient = Lighting.Ambient,
        OutdoorAmbient = Lighting.OutdoorAmbient,
        Brightness = Lighting.Brightness,
        ClockTime = Lighting.ClockTime,
        ExposureCompensation = Lighting.ExposureCompensation,
        GlobalShadows = Lighting.GlobalShadows,
        FogStart = Lighting.FogStart,
        FogEnd = Lighting.FogEnd,
        Atmospheres = atmospheres
    }
end

local restoreLighting

local function applyLighting()
    captureLighting()
    local original = state.LightingSnapshot
    if not Settings.Fullbright and not Settings.NoFog and not Settings.LowQuality then
        restoreLighting()
        return
    end
    if Settings.Fullbright then
        Lighting.Ambient = Color3.fromRGB(210, 210, 210)
        Lighting.OutdoorAmbient = Color3.fromRGB(210, 210, 210)
        Lighting.Brightness = 3
        Lighting.ClockTime = 14
        Lighting.ExposureCompensation = 0.15
        Lighting.GlobalShadows = false
    else
        Lighting.Ambient = original.Ambient
        Lighting.OutdoorAmbient = original.OutdoorAmbient
        Lighting.Brightness = original.Brightness
        Lighting.ClockTime = original.ClockTime
        Lighting.ExposureCompensation = original.ExposureCompensation
        Lighting.GlobalShadows = Settings.LowQuality and false or original.GlobalShadows
    end
    if Settings.NoFog then
        Lighting.FogStart = 100000
        Lighting.FogEnd = 1000000
        for atmosphere in pairs(original.Atmospheres) do
            if atmosphere.Parent then atmosphere.Density = 0 end
        end
    else
        Lighting.FogStart = original.FogStart
        Lighting.FogEnd = original.FogEnd
        for atmosphere, density in pairs(original.Atmospheres) do
            if atmosphere.Parent then atmosphere.Density = density end
        end
    end
end

restoreLighting = function()
    local original = state.LightingSnapshot
    if not original then return end
    Lighting.Ambient = original.Ambient
    Lighting.OutdoorAmbient = original.OutdoorAmbient
    Lighting.Brightness = original.Brightness
    Lighting.ClockTime = original.ClockTime
    Lighting.ExposureCompensation = original.ExposureCompensation
    Lighting.GlobalShadows = original.GlobalShadows
    Lighting.FogStart = original.FogStart
    Lighting.FogEnd = original.FogEnd
    for atmosphere, density in pairs(original.Atmospheres) do
        if atmosphere.Parent then atmosphere.Density = density end
    end
end

local function disableEffect(instance)
    if not (instance:IsA("ParticleEmitter") or instance:IsA("Trail") or instance:IsA("Beam")) then return end
    if state.DisabledEffects[instance] == nil then state.DisabledEffects[instance] = instance.Enabled end
    instance.Enabled = false
end

local function restoreQuality()
    for instance, enabled in pairs(state.DisabledEffects) do
        if instance and instance.Parent then pcall(function() instance.Enabled = enabled end) end
        state.DisabledEffects[instance] = nil
    end
    local terrain = workspace:FindFirstChildOfClass("Terrain")
    if terrain and state.TerrainSnapshot then
        pcall(function()
            terrain.WaterWaveSize = state.TerrainSnapshot.WaterWaveSize
            terrain.WaterWaveSpeed = state.TerrainSnapshot.WaterWaveSpeed
            terrain.WaterReflectance = state.TerrainSnapshot.WaterReflectance
            terrain.WaterTransparency = state.TerrainSnapshot.WaterTransparency
        end)
    end
    if state.RenderQuality then pcall(function() settings().Rendering.QualityLevel = state.RenderQuality end) end
    state.TerrainSnapshot = nil
    state.RenderQuality = nil
    applyLighting()
end

local function setLowQuality(value)
    Settings.LowQuality = value
    if not value then
        restoreQuality()
        return
    end
    captureLighting()
    local terrain = workspace:FindFirstChildOfClass("Terrain")
    if terrain and not state.TerrainSnapshot then
        state.TerrainSnapshot = {
            WaterWaveSize = terrain.WaterWaveSize,
            WaterWaveSpeed = terrain.WaterWaveSpeed,
            WaterReflectance = terrain.WaterReflectance,
            WaterTransparency = terrain.WaterTransparency
        }
    end
    if terrain then
        pcall(function()
            terrain.WaterWaveSize = 0
            terrain.WaterWaveSpeed = 0
            terrain.WaterReflectance = 0
            terrain.WaterTransparency = 1
        end)
    end
    if not state.RenderQuality then pcall(function() state.RenderQuality = settings().Rendering.QualityLevel end) end
    pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
    Lighting.GlobalShadows = false
    task.spawn(function()
        for index, instance in ipairs(workspace:GetDescendants()) do
            if not state.Alive or not Settings.LowQuality then break end
            disableEffect(instance)
            if index % 500 == 0 then task.wait() end
        end
    end)
end

local buyStockFruit

local function selectedFruitSet()
    local selected = {}
    for _, name in ipairs(Settings.StockWantedFruits or {}) do
        selected[string.lower(tostring(name))] = true
    end
    return selected
end

local function refreshStock(notifyChanges)
    local ok, result = pcall(function() return CommF:InvokeServer("GetFruits", false) end)
    if not ok or type(result) ~= "table" then
        showNotice("Fruit stock unavailable", Red, 3)
        return false
    end
    local stock, set, catalog, catalogSeen, prices, rawNames = {}, {}, {}, {}, {}, {}
    for _, entry in ipairs(result) do
        if type(entry) == "table" and type(entry.Name) == "string" then
            local displayName = formatFruitName(entry.Name)
            prices[displayName] = tonumber(entry.Price) or 0
            rawNames[displayName] = entry.Name
            if not catalogSeen[displayName] then
                catalogSeen[displayName] = true
                catalog[#catalog + 1] = displayName
            end
        end
        if type(entry) == "table" and entry.OnSale then
            local fruit = {
                Name = formatFruitName(entry.Name),
                RawName = entry.Name,
                Price = tonumber(entry.Price) or 0,
                Rarity = tonumber(entry.Rarity) or 0
            }
            stock[#stock + 1] = fruit
            set[fruit.RawName] = fruit
        end
    end
    table.sort(catalog)
    table.sort(stock, function(a, b) return a.Price < b.Price end)
    local names = {}
    for _, fruit in ipairs(stock) do names[#names + 1] = fruit.RawName end
    local signature = table.concat(names, "|")
    if notifyChanges and state.StockInitialized and signature ~= state.StockSignature and Settings.StockNotifications then
        local additions = {}
        local old = {}
        for _, fruit in ipairs(state.Stock) do old[fruit.RawName] = true end
        local wanted = selectedFruitSet()
        for _, fruit in ipairs(stock) do
            if not old[fruit.RawName] and (wanted[string.lower(fruit.Name)] or fruit.Price >= Settings.StockMinimumPrice) then
                additions[#additions + 1] = fruit.Name
            end
        end
        if #additions > 0 then showNotice("Stock: " .. table.concat(additions, ", "), espColor(Settings.FruitColor), 7) end
    end
    state.Stock = stock
    state.FruitCatalog = catalog
    state.FruitPrices = prices
    state.FruitRawNames = rawNames
    state.StockSignature = signature
    state.StockInitialized = true
    if Settings.AutoBuyStock and os.clock() >= state.AutoStockNextAt then
        state.AutoStockNextAt = os.clock() + 45
        task.defer(function() buyStockFruit(true) end)
    end
    return true
end

local function currentMoney()
    local data = LocalPlayer:FindFirstChild("Data")
    local money = data and (data:FindFirstChild("Beli") or data:FindFirstChild("Money"))
    return money and tonumber(money.Value) or nil
end

buyStockFruit = function(automatic)
    if state.StockBuyBusy then
        if not automatic then contextNotice("StockBuyBusy", "A fruit purchase is already being processed", Red, 3, 2) end
        return
    end
    local selected = tostring(Settings.StockBuyFruit or "")
    if selected == "" then
        if not automatic then showNotice("Choose a fruit first", Red, 4) end
        return
    end
    if not refreshStock(false) then return end
    local available
    for _, fruit in ipairs(state.Stock) do
        if fruit.Name == selected then
            available = fruit
            break
        end
    end
    if not available then
        if not automatic then showNotice(selected .. " is not currently in stock", Red, 5) end
        return
    end
    local money = currentMoney()
    if money and money < available.Price then
        if not automatic then showNotice("You need $" .. tostring(available.Price) .. " for " .. selected, Red, 5) end
        return
    end
    state.StockBuyBusy = true
    showNotice((automatic and "Auto buying " or "Buying ") .. selected, nil, 3)
    task.spawn(function()
        local dragonType = selected == "Dragon" and Settings.StockDragonType or nil
        local ok, result = pcall(function()
            return CommF:InvokeServer("PurchaseRawFruit", available.RawName, false, dragonType)
        end)
        state.StockBuyBusy = false
        if not state.Alive then return end
        if ok and result then
            showNotice(selected .. " purchased and equipped", espColor(Settings.FruitColor), 5)
        elseif ok then
            showNotice(selected .. " could not be purchased", Red, 5)
        else
            showNotice("Fruit purchase failed", Red, 5)
        end
        refreshStock(false)
    end)
end

FarmRuntime.OpenFruitDealer = function()
    task.spawn(function()
        local ok, result = pcall(function()
            local controller = require(ReplicatedStorage.Controllers.UI.FruitShop)
            controller:Open("FruitDealer")
            return true
        end)
        if not state.Alive then return end
        if not ok or result ~= true then showNotice("Fruit Dealer could not be opened", Red, 4) end
    end)
end

FarmRuntime.RollFruit = function()
    if state.FruitRollBusy then
        contextNotice("FruitRollBusy", "A fruit roll is already being processed", Muted, 3, 2)
        return
    end
    state.FruitRollBusy = true
    task.spawn(function()
        local ok, success, response = pcall(function()
            local gacha = require(ReplicatedStorage.Controllers.GachaClient)
            local check = gacha.CheckGachaAsync("ZiolesGacha", "Blox Fruit Gacha")
            if type(check) ~= "table" then return false, "Fruit Gacha is unavailable" end
            if check.RequirementsMet == false then
                return false, tostring(check.ErrorMessage or (check.Cooldown and check.Cooldown.ErrorMessage) or "Fruit roll requirements are not met")
            end
            local purchase = gacha.PurchaseGachaAsync("ZiolesGacha")
            if purchase == nil or purchase == false then return false, "Fruit roll was rejected" end
            return true, purchase
        end)
        state.FruitRollBusy = false
        if not state.Alive then return end
        if not ok then
            showNotice("Fruit roll failed", Red, 4)
            return
        end
        if success == false then
            showNotice(tostring(response or "Fruit roll is unavailable"), Red, 5)
        else
            showNotice("Fruit rolled", espColor(Settings.FruitColor), 4)
        end
    end)
end

local function cacheChest(instance)
    if not instance then return end
    local tagged = CollectionService:HasTag(instance, "WorldChest")
    local part = getPart(instance)
    local namedPart = instance:IsA("BasePart") and string.find(string.lower(instance.Name), "chest", 1, true) ~= nil
    local touch = part and (part:FindFirstChild("TouchInterest") or part:FindFirstChildWhichIsA("TouchTransmitter"))
    if part and (tagged or (namedPart and touch)) then state.Chests[instance] = true end
end

FarmRuntime.ChestPositionKey = function(chest)
    local part = getPart(chest)
    if not part then return nil end
    local position = part.Position
    return string.format("%d:%d:%d", math.floor(position.X / 4 + 0.5), math.floor(position.Y / 4 + 0.5), math.floor(position.Z / 4 + 0.5))
end

local function ensureChestCache()
    if state.ChestCacheReady or state.ChestCacheScanning then return end
    state.ChestCacheScanning = true
    for _, tagged in ipairs(CollectionService:GetTagged("WorldChest")) do cacheChest(tagged) end
    task.spawn(function()
        local roots = { workspace, ReplicatedStorage }
        local scanned = 0
        for _, root in ipairs(roots) do
            if root then
                for _, instance in ipairs(root:GetDescendants()) do
                    if not state.Alive then return end
                    if instance:IsA("BasePart") and string.find(string.lower(instance.Name), "chest", 1, true) then cacheChest(instance) end
                    scanned = scanned + 1
                    if scanned % 750 == 0 then task.wait() end
                end
            end
        end
        state.ChestCacheReady = true
        state.ChestCacheScanning = false
    end)
end

local function chestAvailable(chest)
    local part = getPart(chest)
    if not part or (not part:IsDescendantOf(workspace) and not part:IsDescendantOf(ReplicatedStorage)) then return false end
    if chest:GetAttribute("IsDisabled") == true or part:GetAttribute("IsDisabled") == true then return false end
    local touch = part:FindFirstChild("TouchInterest") or part:FindFirstChildWhichIsA("TouchTransmitter")
    if part:IsDescendantOf(workspace) and (part.CanTouch == false or not touch) then return false end
    return CollectionService:HasTag(chest, "WorldChest") or touch ~= nil
end

local function findNearestChest(localRoot, skipRecent, maximumDistance)
    if not localRoot then return nil end
    ensureChestCache()
    local best, bestDistance
    local now = os.clock()
    for chest in pairs(state.Chests) do
        local part = getPart(chest)
        if part and part:IsDescendantOf(workspace) and not chestAvailable(chest) then
            local disabledKey = FarmRuntime.ChestPositionKey(chest)
            if disabledKey then state.ChestPositionAttempts[disabledKey] = now end
            state.Chests[chest] = nil
        end
    end
    for chest in pairs(state.Chests) do
        local part = getPart(chest)
        local positionKey = FarmRuntime.ChestPositionKey(chest)
        local recentInstance = state.ChestAttempts[chest] and now - state.ChestAttempts[chest] < 300
        local recentPosition = positionKey and state.ChestPositionAttempts[positionKey] and now - state.ChestPositionAttempts[positionKey] < 300
        local recent = recentPosition or (skipRecent and recentInstance)
        local live = part and part:IsDescendantOf(workspace)
        if not recent and live and chestAvailable(chest) then
            local distance = (part.Position - localRoot.Position).Magnitude
            if (not maximumDistance or distance <= maximumDistance)
                and (not bestDistance or distance < bestDistance)
            then
                best, bestDistance = chest, distance
            end
        elseif live and not chestAvailable(chest) then
            state.Chests[chest] = nil
        end
    end
    return best
end

FarmRuntime.ChestIslandForPosition = function(position)
    local origin = workspace:FindFirstChild("_WorldOrigin")
    local locations = origin and origin:FindFirstChild("Locations")
    local best, bestPosition, bestDistance
    if locations then
        for _, location in ipairs(locations:GetChildren()) do
            local locationPosition
            if location:IsA("BasePart") then
                locationPosition = location.Position
            elseif location:IsA("Model") then
                local ok, pivot = pcall(location.GetPivot, location)
                if ok then locationPosition = pivot.Position end
            end
            if locationPosition then
                local distance = Vector2.new(locationPosition.X - position.X, locationPosition.Z - position.Z).Magnitude
                if not bestDistance or distance < bestDistance then
                    best, bestPosition, bestDistance = location, locationPosition, distance
                end
            end
        end
    end
    if best then
        local key = string.format("%s:%d:%d", best.Name, math.floor(bestPosition.X / 100 + 0.5), math.floor(bestPosition.Z / 100 + 0.5))
        return key, best.Name
    end
    return string.format("area:%d:%d", math.floor(position.X / 2000 + 0.5), math.floor(position.Z / 2000 + 0.5)), "Chest area"
end

FarmRuntime.IsChestSearchIsland = function(location)
    if not location or (not location:IsA("BasePart") and not location:IsA("Model")) then return false end
    local name = string.lower(location.Name)
    if name == "sea" or name == "ancient clock" or name == "temple of time"
        or name == "secret temple" or name == "submerged island" or name == "sharkman arena"
        or name == "sealed cavern" or name == "beautiful pirate domain" or name == "friendly arena"
        or string.find(name, "trial", 1, true) or string.find(name, "dimension", 1, true)
        or string.match(name, "^island%s+%d+$")
    then
        return false
    end
    return true
end

FarmRuntime.FindChestIslandDestination = function(localRoot)
    if not localRoot then return nil end
    local origin = workspace:FindFirstChild("_WorldOrigin")
    local locations = origin and origin:FindFirstChild("Locations")
    local now = os.clock()
    local islands = {}
    local closestKey, closestDistance
    local function addIsland(instance, displayName, keyName)
        if not instance then return end
        local position
        if instance:IsA("BasePart") then
            position = instance.Position
        elseif instance:IsA("Model") then
            local ok, pivot = pcall(instance.GetPivot, instance)
            if ok then position = pivot.Position end
        end
        if not position then return end
        local distance = Vector2.new(position.X - localRoot.Position.X, position.Z - localRoot.Position.Z).Magnitude
        local key = keyName or string.format("%s:%d:%d", instance.Name, math.floor(position.X / 100 + 0.5), math.floor(position.Z / 100 + 0.5))
        islands[#islands + 1] = {
            Key = key,
            Name = displayName or instance.Name,
            Position = Vector3.new(position.X, math.max(position.Y + 120, 250), position.Z),
            Distance = distance
        }
        if not closestDistance or distance < closestDistance then
            closestKey, closestDistance = key, distance
        end
    end
    if game.PlaceId == SEA_PLACE_IDS.Second then
        local map = workspace:FindFirstChild("Map")
        local routes = {
            Dressrosa = "Kingdom of Rose",
            GreenBit = "Green Zone",
            GraveIsland = "Graveyard Island",
            SnowMountain = "Snow Mountain",
            CircleIsland = "Hot and Cold",
            GhostShip = "Cursed Ship Exterior",
            GhostShipInterior = "Cursed Ship",
            IceCastle = "Ice Castle",
            ForgottenIsland = "Forgotten Island",
            DarkbeardArena = "Dark Arena",
            Mini1 = "Usoap's Island",
            Mini2 = "Remote Island"
        }
        if map then
            for modelName, displayName in pairs(routes) do
                addIsland(map:FindFirstChild(modelName), displayName, "SecondSea:" .. modelName)
            end
        end
    elseif locations then
        for _, location in ipairs(locations:GetChildren()) do
            if FarmRuntime.IsChestSearchIsland(location) then addIsland(location) end
        end
    end
    if closestKey and closestDistance <= 1800 then state.ChestIslandAttempts[closestKey] = now end
    local function chooseIsland()
        local best
        for _, island in ipairs(islands) do
            local searchedAt = state.ChestIslandAttempts[island.Key]
            if (not searchedAt or now - searchedAt >= 300)
                and (not best or island.Distance < best.Distance)
            then
                best = island
            end
        end
        return best
    end
    local best = chooseIsland()
    if not best and #islands > 1 then
        state.ChestIslandAttempts = closestKey and { [closestKey] = now } or {}
        best = chooseIsland()
    end
    if not best then return nil end
    return best.Position, best.Key, best.Name
end

FarmRuntime.ResolveLiveChest = function(reference)
    local referencePart = getPart(reference)
    if not referencePart then return nil end
    if referencePart:IsDescendantOf(workspace) then return reference end
    local best, bestDistance
    for chest in pairs(state.Chests) do
        local part = getPart(chest)
        if part and part:IsDescendantOf(workspace) and chestAvailable(chest) then
            local distance = (part.Position - referencePart.Position).Magnitude
            if distance <= 16 and (not bestDistance or distance < bestDistance) then
                best, bestDistance = chest, distance
            end
        end
    end
    return best
end

local function findNearestBoss(localRoot, selectedName)
    local enemies = workspace:FindFirstChild("Enemies")
    if not localRoot then return nil end
    local best, bestDistance
    if enemies then
        for _, model in ipairs(enemies:GetChildren()) do
            local part = getPart(model)
            local humanoid = getHumanoid(model)
            local nameMatches = not selectedName or selectedName == "Nearest Spawned" or model.Name == selectedName
                or string.find(model.Name, selectedName, 1, true) ~= nil
            if isBoss(model) and nameMatches and part and humanoid and humanoid.Health > 0 then
                local distance = (part.Position - localRoot.Position).Magnitude
                if not bestDistance or distance < bestDistance then best, bestDistance = model, distance end
            end
        end
    end
    if best then return best, false end
    local stored = FarmRuntime.FindReplicatedBoss and FarmRuntime.FindReplicatedBoss(localRoot, selectedName) or nil
    return stored, stored ~= nil
end

local function autoFruitAllowed(fruit)
    local wanted = Settings.AutoFruitWantedFruits or {}
    if #wanted == 0 then return true end
    local fruitName = FarmRuntime.FruitSelectionKey(fruit)
    for _, selectedName in ipairs(wanted) do
        if FarmRuntime.FruitSelectionKey(selectedName) == fruitName then return true end
    end
    return false
end

local function findNearestFruit(localRoot, skipRecent, ignoreFilter)
    local best, bestDistance, bestPriority
    if not localRoot then return nil end
    local now = os.clock()
    for fruit in pairs(state.Fruits) do
        local part = getPart(fruit)
        local recent = skipRecent and state.FruitAttempts[fruit] and now - state.FruitAttempts[fruit] < 2.5
        if not recent and (ignoreFilter or autoFruitAllowed(fruit)) and part and part:IsDescendantOf(workspace) then
            local distance = (part.Position - localRoot.Position).Magnitude
            local priority = FarmRuntime.FruitPriorityRank(fruit)
            if not bestPriority or priority < bestPriority or (priority == bestPriority and distance < bestDistance) then
                best, bestDistance, bestPriority = fruit, distance, priority
            end
        end
    end
    return best
end

FarmRuntime.RefreshPhysicalFruitChoices = function(force)
    local entries = {}
    local _, _, root = getCharacter(LocalPlayer)
    for fruit in pairs(state.Fruits) do
        local part = getPart(fruit)
        if part and part:IsDescendantOf(workspace) then
            local id = state.PhysicalFruitChoiceIds[fruit]
            if not id then
                state.PhysicalFruitChoiceNextId = state.PhysicalFruitChoiceNextId + 1
                id = state.PhysicalFruitChoiceNextId
                state.PhysicalFruitChoiceIds[fruit] = id
            end
            entries[#entries + 1] = {
                Fruit = fruit,
                Id = id,
                Rank = FarmRuntime.FruitPriorityRank(fruit),
                Distance = root and (part.Position - root.Position).Magnitude or math.huge
            }
        end
    end
    table.sort(entries, function(a, b)
        if a.Rank ~= b.Rank then return a.Rank < b.Rank end
        return a.Id < b.Id
    end)
    local options, choiceMap = {}, {}
    for _, entry in ipairs(entries) do
        local label = string.format("%s Fruit #%d", formatFruitName(entry.Fruit), entry.Id)
        options[#options + 1] = label
        choiceMap[label] = entry.Fruit
    end
    if #options == 0 then options[1] = "No physical fruits" end
    local signature = table.concat(options, "\0")
    state.PhysicalFruitChoiceMap = choiceMap
    if state.PhysicalFruitCountLabel and state.PhysicalFruitCountLabel.Parent then
        state.PhysicalFruitCountLabel.Text = "On map: " .. tostring(#entries)
    end
    local control = state.PhysicalFruitChoiceControl
    if not control or (not force and signature == state.PhysicalFruitChoiceSignature) then return end
    state.PhysicalFruitChoiceSignature = signature
    local selected = state.PhysicalFruitChoiceObject
    if not selected or not selected.Parent or not state.Fruits[selected] then selected = entries[1] and entries[1].Fruit or nil end
    local selectedLabel
    for label, fruit in pairs(choiceMap) do
        if fruit == selected then selectedLabel = label; break end
    end
    state.PhysicalFruitChoiceObject = selected
    state.PhysicalFruitChoiceRefreshing = true
    control:Refresh(options)
    if selectedLabel then control:Set(selectedLabel) end
    state.PhysicalFruitChoiceRefreshing = false
    if state.TravelButtonKey == "physicalFruitMap"
        and (not state.TravelObject or not state.TravelObject.Parent)
    then
        stopTravel("Selected fruit is no longer available")
    end
end

FarmRuntime.TravelSelectedPhysicalFruit = function()
    if state.TravelTarget and state.TravelButtonKey == "physicalFruitMap" then
        stopTravel("Travel stopped")
        return
    end
    local fruit = state.PhysicalFruitChoiceObject
    local part = getPart(fruit)
    if not fruit or not state.Fruits[fruit] or not part or not part:IsDescendantOf(workspace) then
        FarmRuntime.RefreshPhysicalFruitChoices(true)
        fruit = state.PhysicalFruitChoiceObject
        part = getPart(fruit)
    end
    if not part then
        showNotice("No physical fruit is currently available", Red, 4)
        return
    end
    beginTravel(part.Position + Vector3.new(0, 3, 0), formatFruitName(fruit) .. " Fruit", "manual", fruit, false, "physicalFruitMap")
end

local function touchTravelObject(root, object)
    local part = getPart(object)
    if not root or not part or not part:IsDescendantOf(workspace) then return false end
    if firetouchinterest then
        pcall(function()
            firetouchinterest(root, part, 0)
            firetouchinterest(root, part, 1)
        end)
    end
    return true
end

local function autoTravelObjectValid()
    if state.TravelMode == "fruit" then
        local part = getPart(state.TravelObject)
        return part and part:IsDescendantOf(workspace)
    end
    if state.TravelMode == "chest" or state.TravelMode == "cyborgChest" then
        local reference = state.TravelObject
        local part = getPart(reference)
        if not chestAvailable(reference) or not part then return false end
        if part:IsDescendantOf(workspace) or FarmRuntime.ResolveLiveChest(reference) then return true end
        local _, _, root = getCharacter(LocalPlayer)
        if root and (root.Position - part.Position).Magnitude <= 250 then
            local positionKey = FarmRuntime.ChestPositionKey(reference)
            state.ChestAttempts[reference] = os.clock()
            if positionKey then state.ChestPositionAttempts[positionKey] = os.clock() end
            return false
        end
        return true
    end
    if state.TravelMode == "farmMirageGear" or state.TravelMode == "farmMirageDealer" then
        local part = getPart(state.TravelObject)
        return part and part:IsDescendantOf(workspace)
    end
    if state.TravelMode == "farmEnemy" or state.TravelMode == "farmBoss" then
        local humanoid = getHumanoid(state.TravelObject)
        local part = getPart(state.TravelObject)
        return humanoid and humanoid.Health > 0 and part and part:IsDescendantOf(workspace)
    end
    return true
end

FarmRuntime.FindFishingController = function()
    local controller = state.FishingController
    if type(controller) == "table" and type(controller.Activated) == "function"
        and type(controller.OnRelease) == "function" and type(controller.Cleanup) == "function"
    then
        return controller
    end
    if type(getgc) ~= "function" then return nil end
    local ok, objects = pcall(getgc, true)
    if not ok or type(objects) ~= "table" then return nil end
    for _, candidate in ipairs(objects) do
        if type(candidate) == "table" and type(rawget(candidate, "Activated")) == "function"
            and type(rawget(candidate, "Deactivated")) == "function"
            and type(rawget(candidate, "OnBegin")) == "function"
            and type(rawget(candidate, "OnRelease")) == "function"
            and type(rawget(candidate, "IsIdle")) == "function"
            and type(rawget(candidate, "IsReeling")) == "function"
            and type(rawget(candidate, "Cleanup")) == "function"
        then
            state.FishingController = candidate
            return candidate
        end
    end
    return nil
end

FarmRuntime.GetFishingState = function(controller)
    if type(state.FishingState) == "table" and state.FishingState.Controller == controller then
        return state.FishingState
    end
    controller = controller or FarmRuntime.FindFishingController()
    if not controller then return nil end
    local reader = type(getupvalues) == "function" and getupvalues
        or debug and type(debug.getupvalues) == "function" and debug.getupvalues
    if type(reader) ~= "function" then return nil end
    for _, name in ipairs({ "IsIdle", "Update", "Cleanup", "Activated" }) do
        local fn = controller[name]
        if type(fn) == "function" then
            local ok, values = pcall(reader, fn)
            if ok and type(values) == "table" then
                for _, value in pairs(values) do
                    if type(value) == "table" and rawget(value, "clientEvents") ~= nil
                        and rawget(value, "Components") ~= nil
                    then
                        state.FishingState = value
                        return value
                    end
                end
            end
        end
    end
    return nil
end

FarmRuntime.FindFishingRod = function()
    local character = LocalPlayer.Character
    local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
    for _, container in ipairs({ character, backpack }) do
        if container then
            for _, tool in ipairs(container:GetChildren()) do
                if tool:IsA("Tool") and (tool:FindFirstChild("FishingRodData")
                    or CollectionService:HasTag(tool, "FishingRod"))
                then
                    return tool
                end
            end
        end
    end
    return nil
end

FarmRuntime.FishingBaitReady = function()
    local data = LocalPlayer:FindFirstChild("Data")
    local fishingData = data and data:FindFirstChild("FishingData")
    local bait = fishingData and fishingData:GetAttribute("SelectedBait")
    return bait ~= nil and bait ~= "None"
end

FarmRuntime.UpdateAutoBait = function(force)
    if not Settings.AutoBuyBait or state.BaitBuyBusy then return false end
    local now = os.clock()
    if not force and now < state.BaitBuyNextAt then return false end
    state.BaitBuyNextAt = now + 3
    state.BaitBuyBusy = true
    task.spawn(function()
        local okJobs, jobs = pcall(require, ReplicatedStorage:WaitForChild("JobsReplicated"))
        local okCheck, baitData = false, nil
        if okJobs and jobs and type(jobs.InvokeServer) == "function" then
            okCheck, baitData = pcall(jobs.InvokeServer, "FishingNPC", "Bait", "Check", "Fisherman")
        end
        if not state.Alive then return end
        if not okCheck or type(baitData) ~= "table" then
            state.BaitBuyBusy = false
            contextNotice("AutoBaitCheck", "Bait inventory could not be checked", Red, 4, 8)
            return
        end

        local preferred, preferredAmount
        for _, entry in ipairs(type(baitData.All) == "table" and baitData.All or {}) do
            local amount = tonumber(entry.Amount) or 0
            if entry.Unlocked and amount > 0 then
                if entry.Name == baitData.Equipped then
                    preferred, preferredAmount = entry.Name, amount
                    break
                elseif not preferred or entry.Name == "Basic Bait" then
                    preferred, preferredAmount = entry.Name, amount
                end
            end
        end

        local total = tonumber(baitData.Total) or 0
        local bought = false
        if total < 5 then
            local okNet, net = pcall(require, ReplicatedStorage.Modules.Net)
            local craft = okNet and net:RemoteFunction("Craft") or nil
            local okRecipe, recipe = false, nil
            if craft then
                okRecipe, recipe = pcall(function() return craft:InvokeServer("Check", "Basic Bait") end)
            end
            local result = okRecipe and type(recipe) == "table" and recipe.Result or nil
            if result and result.Could ~= false then
                local okCraft, craftResult = pcall(function()
                    return craft:InvokeServer("Craft", result.Recipe or "Basic Bait", 1, {})
                end)
                bought = okCraft and craftResult ~= nil and craftResult ~= false
                if bought then
                    preferred, preferredAmount = "Basic Bait", math.max(preferredAmount or 0, 10)
                    showNotice("Bought 10 Basic Bait", nil, 3)
                end
            end
            if not bought then
                local message = result and result.ErrorMessage or "Basic Bait could not be purchased"
                contextNotice("AutoBaitPurchase", tostring(message), Red, 4, 8)
            end
        end

        local fishingData = LocalPlayer:FindFirstChild("Data")
        fishingData = fishingData and fishingData:FindFirstChild("FishingData")
        local selected = fishingData and fishingData:GetAttribute("SelectedBait")
        if preferred and (preferredAmount or 0) > 0 and (selected == nil or selected == "None") then
            local okEquip, equipped = pcall(function()
                return CommF:InvokeServer("LoadItem", preferred, { "Usables" })
            end)
            if not okEquip or equipped == false then
                contextNotice("AutoBaitEquip", preferred .. " could not be equipped", Red, 4, 8)
            end
        end
        state.BaitBuyBusy = false
        state.BaitBuyNextAt = os.clock() + (bought and 1 or 3)
    end)
    return true
end

FarmRuntime.HookFishingController = function(controller)
    if not controller or state.FishingOriginalIsReeling then return end
    state.FishingOriginalIsReeling = controller.IsReeling
    controller.IsReeling = function(...)
        if state.Alive and Settings.AutoFish then return state.FishingInputHeld == true end
        return state.FishingOriginalIsReeling(...)
    end
end

FarmRuntime.PulseFishingAction = function()
    if state.FishingPulseBusy then return end
    state.FishingPulseBusy = true
    local serial = state.FishingSerial
    local fired = false
    if type(getconnections) == "function" then
        local ok, connections = pcall(getconnections, UserInputService.InputBegan)
        if ok and type(connections) == "table" then
            local fakeInput = {
                UserInputType = Enum.UserInputType.MouseButton1,
                KeyCode = Enum.KeyCode.Unknown
            }
            for _, connection in ipairs(connections) do
                local fn = connection.Function
                if type(fn) == "function" then
                    local source
                    pcall(function()
                        if debug and type(debug.info) == "function" then source = debug.info(fn, "s")
                        elseif type(getinfo) == "function" then source = getinfo(fn).source end
                    end)
                    if type(source) == "string" and string.find(source, "FishReplicated.FishingClient", 1, true) then
                        if pcall(fn, fakeInput, false) then fired = true end
                        local reader = type(getupvalues) == "function" and getupvalues
                            or debug and type(debug.getupvalues) == "function" and debug.getupvalues
                        if type(reader) == "function" then
                            local readOk, values = pcall(reader, fn)
                            if readOk and type(values) == "table" then
                                for _, value in pairs(values) do
                                    if type(value) == "function" and value ~= fn then
                                        local nestedSource
                                        pcall(function()
                                            if debug and type(debug.info) == "function" then nestedSource = debug.info(value, "s")
                                            elseif type(getinfo) == "function" then nestedSource = getinfo(value).source end
                                        end)
                                        if type(nestedSource) == "string"
                                            and string.find(nestedSource, "FishReplicated.FishingClient", 1, true)
                                        then
                                            if pcall(value, fakeInput) then fired = true end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    if type(getgc) == "function" then
        local ok, objects = pcall(getgc, true)
        local reader = type(getupvalues) == "function" and getupvalues
            or debug and type(debug.getupvalues) == "function" and debug.getupvalues
        if ok and type(objects) == "table" and type(reader) == "function" then
            for _, candidate in ipairs(objects) do
                if type(candidate) == "function" then
                    local source, line
                    pcall(function()
                        if debug and type(debug.info) == "function" then
                            source, line = debug.info(candidate, "s"), debug.info(candidate, "l")
                        elseif type(getinfo) == "function" then
                            local info = getinfo(candidate)
                            source, line = info.source, info.currentline or info.linedefined
                        end
                    end)
                    if source == "ReplicatedStorage.FishReplicated.FishingClient"
                        and tonumber(line) and line >= 450 and line <= 520
                    then
                        local readOk, values = pcall(reader, candidate)
                        local count, hasFalseBoolean = 0, false
                        if readOk and type(values) == "table" then
                            for _, value in pairs(values) do
                                count = count + 1
                                if value == false then hasFalseBoolean = true end
                            end
                        end
                        if count == 1 and hasFalseBoolean and pcall(candidate) then fired = true end
                    end
                end
            end
        end
    end
    task.spawn(function()
        local camera = workspace.CurrentCamera
        local viewport = camera and camera.ViewportSize or Vector2.new(800, 600)
        local x, y = math.floor(viewport.X * 0.5), math.max(2, math.floor(viewport.Y - 8))
        pcall(function() farmVirtualInput:SendMouseButtonEvent(x, y, 0, true, game, 0) end)
        task.wait(fired and 0.025 or 0.04)
        pcall(function() farmVirtualInput:SendMouseButtonEvent(x, y, 0, false, game, 0) end)
    end)
    task.delay(0.12, function()
        if state.FishingSerial == serial then state.FishingPulseBusy = false end
    end)
end

FarmRuntime.GetFishingGui = function()
    local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    local gui = playerGui and playerGui:FindFirstChild("Fishing_Reeling", true)
    local minigame = gui and gui:FindFirstChild("Minigame")
    local container = minigame and minigame:FindFirstChild("Container")
    if not container then return nil end
    local zone = container:FindFirstChild("ReelZone")
    local fish = container:FindFirstChild("Fish")
    local treasure = container:FindFirstChild("Treasure")
    if not zone or not fish then return nil end
    return gui, zone, fish, treasure
end

FarmRuntime.FindFishingWater = function(root, rod, searchDistance)
    if not root then return nil end
    local character = LocalPlayer.Character
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    local ignore = { character }
    local characters = workspace:FindFirstChild("Characters")
    local enemies = workspace:FindFirstChild("Enemies")
    if characters then ignore[#ignore + 1] = characters end
    if enemies then ignore[#ignore + 1] = enemies end
    params.FilterDescendantsInstances = ignore
    params.IgnoreWater = false
    local maximum = tonumber(rod and rod:GetAttribute("MaxLaunchDistance")) or 100
    local distance = searchDistance or math.clamp(maximum - 10, 35, 100)
    local look = Vector3.new(root.CFrame.LookVector.X, 0, root.CFrame.LookVector.Z)
    if look.Magnitude < 0.1 then look = Vector3.new(0, 0, -1) else look = look.Unit end
    for index = 0, 31 do
        local step = math.ceil(index / 2)
        local sign = index % 2 == 0 and -1 or 1
        local angle = index == 0 and 0 or sign * step * math.pi / 16
        local direction = CFrame.fromAxisAngle(Vector3.yAxis, angle):VectorToWorldSpace(look)
        local sample = root.Position + direction * distance
        local result = workspace:Raycast(sample + Vector3.new(0, 350, 0), Vector3.new(0, -1800, 0), params)
        if result and CollectionService:HasTag(result.Instance, "WaterBody") then
            return result.Position + Vector3.new(0, 0.15, 0), direction
        end
    end
    return nil
end

FarmRuntime.FindFishingStand = function(root, rod)
    for _, distance in ipairs({ 140, 220, 320, 450, 650 }) do
        local water, direction = FarmRuntime.FindFishingWater(root, rod, distance)
        if water and direction then
            local params = RaycastParams.new()
            params.FilterType = Enum.RaycastFilterType.Exclude
            params.FilterDescendantsInstances = { LocalPlayer.Character }
            for _, inset in ipairs({ 20, 40, 80, 120, 180, 260, 360, 500 }) do
                local sample = water - direction * inset
                local result = workspace:Raycast(sample + Vector3.new(0, 800, 0), Vector3.new(0, -2000, 0), params)
                if result and not CollectionService:HasTag(result.Instance, "WaterBody") then
                    return result.Position + Vector3.new(0, 3.5, 0), water
                end
            end
        end
    end
    return nil
end

FarmRuntime.StopFishing = function(cancel)
    state.FishingSerial = state.FishingSerial + 1
    state.FishingCastBusy = false
    state.FishingPulseBusy = false
    state.FishingInputHeld = false
    state.FishingWasPlaying = false
    state.FishingDismissAt = 0
    state.FishingReleaseUntil = 0
    state.FishingCompletedAt = 0
    local controller = state.FishingController
    local fishingState = state.FishingState
    if cancel and fishingState and tonumber(fishingState.progress) and fishingState.progress >= 1
        and fishingState.currentFish
    then
        local dialogueModule = ReplicatedStorage:FindFirstChild("DialogueController")
        local ok, dialogue = false, nil
        if dialogueModule then ok, dialogue = pcall(require, dialogueModule) end
        if ok and dialogue and dialogue.Active then pcall(function() dialogue.close() end) end
    end
    if controller and state.FishingOriginalIsReeling then
        controller.IsReeling = state.FishingOriginalIsReeling
    end
    state.FishingOriginalIsReeling = nil
    if cancel and controller and type(controller.Cleanup) == "function" then
        pcall(function() controller:Cleanup() end)
    end
    state.FishingController = nil
    state.FishingState = nil
end

FarmRuntime.BeginFishingCast = function(root, rod, target)
    if state.FishingCastBusy then return end
    state.FishingCastBusy = true
    state.FishingSerial = state.FishingSerial + 1
    local serial = state.FishingSerial
    task.spawn(function()
        local character, humanoid, liveRoot = getCharacter(LocalPlayer)
        local controller = FarmRuntime.FindFishingController()
        if not character or not humanoid or not liveRoot or not controller or not rod or not rod.Parent then
            state.FishingCastBusy = false
            state.FishingNextActionAt = os.clock() + 2
            return
        end
        FarmRuntime.HookFishingController(controller)
        local previousState = FarmRuntime.GetFishingState(controller)
        if previousState and previousState.holding then
            pcall(function() controller:Cleanup() end)
            task.wait(0.2)
        end
        if rod.Parent ~= character then
            pcall(function() humanoid:EquipTool(rod) end)
            local deadline = os.clock() + 1.5
            while state.Alive and state.FishingSerial == serial and rod.Parent ~= character and os.clock() < deadline do
                task.wait(0.05)
            end
        end
        if not state.Alive or state.FishingSerial ~= serial or rod.Parent ~= character then
            state.FishingCastBusy = false
            state.FishingNextActionAt = os.clock() + 2
            return
        end
        local flatTarget = Vector3.new(target.X, liveRoot.Position.Y, target.Z)
        if (flatTarget - liveRoot.Position).Magnitude > 0.1 then
            liveRoot.CFrame = CFrame.lookAt(liveRoot.Position, flatTarget)
        end
        local setIdentity = type(setthreadidentity) == "function" and setthreadidentity
            or type(setidentity) == "function" and setidentity
        local getIdentity = type(getthreadidentity) == "function" and getthreadidentity
            or type(getidentity) == "function" and getidentity
        local previousIdentity
        if getIdentity then pcall(function() previousIdentity = getIdentity() end) end
        if setIdentity then pcall(setIdentity, 2) end
        task.spawn(function()
            local taskIdentity
            if getIdentity then pcall(function() taskIdentity = getIdentity() end) end
            if setIdentity then pcall(setIdentity, 2) end
            pcall(function() controller:Activated() end)
            if setIdentity and taskIdentity then pcall(setIdentity, taskIdentity) end
        end)
        task.wait(2.45)
        local fishingState = FarmRuntime.GetFishingState(controller)
        if fishingState and fishingState.holding then
            fishingState.surfaceData = { Position = target, Valid = true }
        end
        local released, releaseError = pcall(function() controller:OnRelease() end)
        if setIdentity and previousIdentity then pcall(setIdentity, previousIdentity) end
        if not released then
            contextNotice("Waiting:AutoFishRelease", "The fishing cast could not be released: " .. tostring(releaseError), Red, 5, 8)
            pcall(function() controller:Cleanup() end)
        end
        state.FishingCastBusy = false
        state.FishingNextActionAt = os.clock() + 2
    end)
end

FarmRuntime.UpdateFishing = function(root)
    if not Settings.AutoFish or not root then return false end
    local rod = FarmRuntime.FindFishingRod()
    if not rod then
        contextNotice("Waiting:AutoFishRod", "Auto Fish is waiting for a fishing rod", Red, 4, 8)
        return false
    end
    if not FarmRuntime.FishingBaitReady() then
        if state.FishingController then FarmRuntime.StopFishing(true) end
        if Settings.AutoBuyBait then
            FarmRuntime.UpdateAutoBait(false)
            contextNotice("Waiting:AutoFishBait", "Auto Fish is buying or equipping bait", Muted, 4, 8)
        else
            contextNotice("Waiting:AutoFishBait", "Auto Fish is waiting for equipped bait", Red, 4, 8)
        end
        return false
    end
    local controller = FarmRuntime.FindFishingController()
    local fishingState = controller and FarmRuntime.GetFishingState(controller)
    if not controller or not fishingState then
        contextNotice("Waiting:AutoFishController", "The fishing controller is still loading", Red, 4, 8)
        return false
    end
    FarmRuntime.HookFishingController(controller)
    local gui, zone, fish, treasure = FarmRuntime.GetFishingGui()
    local now = os.clock()
    if gui then
        state.FishingWasPlaying = true
        state.FishingCompletedAt = 0
        local target = treasure and treasure.Visible and treasure or fish
        if target and target.Visible and zone.Visible then
            local targetCenter = target.AbsolutePosition.X + target.AbsoluteSize.X * 0.5
            local zoneCenter = zone.AbsolutePosition.X + zone.AbsoluteSize.X * 0.5
            if targetCenter > zoneCenter + 2 then state.FishingInputHeld = true
            elseif targetCenter < zoneCenter - 2 then state.FishingInputHeld = false end
        else
            state.FishingInputHeld = false
        end
        return true
    end
    if state.FishingWasPlaying then
        state.FishingWasPlaying = false
        state.FishingInputHeld = true
        state.FishingReleaseUntil = now + 0.3
        state.FishingDismissAt = now + 0.55
        state.FishingNextActionAt = now + 1.2
    end
    if now < state.FishingReleaseUntil then return true end
    state.FishingInputHeld = false
    if tonumber(fishingState.progress) and fishingState.progress >= 1 and fishingState.currentFish
        and not fishingState.playing and not fishingState.reelingIn
    then
        local dialogueModule = ReplicatedStorage:FindFirstChild("DialogueController")
        local ok, dialogue = false, nil
        if dialogueModule then ok, dialogue = pcall(require, dialogueModule) end
        if ok and dialogue and dialogue.Active then
            if now >= state.FishingDismissAt then
                pcall(function() dialogue.advance() end)
                state.FishingDismissAt = now + 0.45
            end
            return true
        end
        fishingState.currentFish = nil
        fishingState.progress = 0
        state.FishingCompletedAt = 0
        state.FishingDismissAt = 0
        state.FishingNextActionAt = now + 0.5
    end
    if tonumber(fishingState.progress) and fishingState.progress >= 1
        and (fishingState.playing or fishingState.reelingIn)
    then
        if state.FishingCompletedAt == 0 then state.FishingCompletedAt = now end
        local dialogueModule = ReplicatedStorage:FindFirstChild("DialogueController")
        local ok, dialogue = false, nil
        if dialogueModule then ok, dialogue = pcall(require, dialogueModule) end
        if ok and dialogue and dialogue.Active and now >= state.FishingDismissAt then
            pcall(function() dialogue.advance() end)
            state.FishingDismissAt = now + 0.45
            return true
        end
        if now - state.FishingCompletedAt > 4 then
            pcall(function() controller:Cleanup() end)
            state.FishingCompletedAt = 0
            state.FishingDismissAt = 0
            state.FishingNextActionAt = now + 1
            return true
        end
    elseif not fishingState.playing and not fishingState.reelingIn then
        state.FishingCompletedAt = 0
    end
    if now >= state.FishingDismissAt and state.FishingDismissAt > 0 then
        local dialogueModule = ReplicatedStorage:FindFirstChild("DialogueController")
        local ok, dialogue = false, nil
        if dialogueModule then ok, dialogue = pcall(require, dialogueModule) end
        if ok and dialogue and dialogue.Active then
            pcall(function() dialogue.advance() end)
            state.FishingDismissAt = now + 0.7
            return true
        end
        state.FishingDismissAt = 0
    end
    if fishingState.isBiting then
        if now >= state.FishingNextActionAt then
            state.FishingNextActionAt = now + 0.3
            FarmRuntime.PulseFishingAction()
        end
        return true
    end
    if fishingState.holding and not state.FishingCastBusy
        and tick() - (tonumber(fishingState.StartedCastingAt) or tick()) > 4
    then
        pcall(function() controller:Cleanup() end)
        state.FishingNextActionAt = now + 0.5
        return true
    end
    if fishingState.isBobbing and not fishingState.bobber and not fishingState.isBiting and not fishingState.playing then
        fishingState.isBobbing = false
    end
    if fishingState.bobber or fishingState.isThrowing
        or fishingState.holding or fishingState.reelingIn or fishingState.playing
    then
        return true
    end
    if state.FishingCastBusy or now < state.FishingNextActionAt then return true end
    local target = FarmRuntime.FindFishingWater(root, rod)
    if target then
        FarmRuntime.BeginFishingCast(root, rod, target)
        return true
    end
    local stand = FarmRuntime.FindFishingStand(root, rod)
    if stand then
        beginTravel(stand, "Fishing spot", "fishSpot", nil, true)
        return true
    end
    contextNotice("Waiting:AutoFishWater", "Move closer to open water so Auto Fish can cast", Muted, 4, 8)
    return false
end

local function updateAutoCollection(root)
    if not root or state.TravelTarget or Settings.AutoFarm then return end
    if Settings.AutoFruit then
        local fruit = findNearestFruit(root, true)
        local part = getPart(fruit)
        if part then
            if FarmRuntime.StopFishing then FarmRuntime.StopFishing(true) end
            if beginTravel(part.Position, formatFruitName(fruit) .. " Fruit", "fruit", fruit, true) then return end
        end
    end
    if Settings.AutoChest then
        local chest = findNearestChest(root, true, 1800)
        local part = getPart(chest)
        if part then
            if FarmRuntime.StopFishing then FarmRuntime.StopFishing(true) end
            beginTravel(part.Position, "Chest", "chest", chest, true)
            return
        end
    end
    if Settings.AutoFish and FarmRuntime.UpdateFishing and FarmRuntime.UpdateFishing(root) then return end
    if Settings.AutoChest then
        if os.clock() >= state.ChestIslandSearchReadyAt then
            local position, islandKey, islandName = FarmRuntime.FindChestIslandDestination(root)
            if position then
                beginTravel(position + Vector3.new(0, 4, 0), tostring(islandName) .. " chests", "chestIsland", islandKey, true)
            elseif state.ChestCacheReady then
                contextNotice("Waiting:AutoChest", "No uncollected chest area is currently available", Muted, 4, 8)
            end
        end
    end
end

local function getIslandNames()
    local names, seen = {}, {}
    local function add(instance)
        if not instance or seen[instance.Name] then return end
        if instance:IsA("BasePart") or instance:IsA("Model") then
            seen[instance.Name] = true
            names[#names + 1] = instance.Name
        end
    end
    local origin = workspace:FindFirstChild("_WorldOrigin")
    local locations = origin and origin:FindFirstChild("Locations")
    if locations then
        for _, location in ipairs(locations:GetChildren()) do add(location) end
    end
    local map = workspace:FindFirstChild("Map")
    if map then
        for _, island in ipairs(map:GetChildren()) do
            if island:IsA("Model") and #island:GetDescendants() > 20 then add(island) end
        end
    end
    table.sort(names)
    if #names == 0 then names[1] = "Unavailable" end
    return names
end

FarmRuntime.ResolveIsland = function(name, root)
    local wanted = string.lower(tostring(name or ""))
    local best, bestPosition, bestDistance
    local function consider(instance)
        if not instance or string.lower(instance.Name) ~= wanted then return end
        local position
        if instance:IsA("BasePart") then
            position = instance.Position
        elseif instance:IsA("Model") then
            local ok, pivot = pcall(instance.GetPivot, instance)
            if ok then position = pivot.Position end
        end
        if not position then
            local part = getPart(instance)
            position = part and part.Position or nil
        end
        if position then
            local distance = root and (position - root.Position).Magnitude or 0
            if not bestDistance or distance < bestDistance then
                best, bestPosition, bestDistance = instance, position, distance
            end
        end
    end

    local origin = workspace:FindFirstChild("_WorldOrigin")
    local locations = origin and origin:FindFirstChild("Locations")
    if locations then
        for _, location in ipairs(locations:GetChildren()) do consider(location) end
    end
    if best then return bestPosition, best end

    local map = workspace:FindFirstChild("Map")
    if map then
        for _, instance in ipairs(map:GetDescendants()) do consider(instance) end
        consider(map:FindFirstChild(name))
    end
    return bestPosition, best
end

local function normalizeEnemyName(value)
    local name = tostring(value or "")
    name = name:gsub("%s*%[Lv%.?[^%]]+%]", "")
    name = name:gsub("%s*%[Boss%]", "")
    return name:match("^%s*(.-)%s*$") or name
end

FarmRuntime.ForEachReplicatedBoss = function(callback)
    local seen = {}
    local function scan(container)
        if not container then return end
        for _, model in ipairs(container:GetChildren()) do
            if model:IsA("Model") and not seen[model] then
                seen[model] = true
                local humanoid = getHumanoid(model)
                if isBoss(model) and getPart(model) and humanoid and humanoid.Health > 0 then callback(model) end
            end
        end
    end
    scan(ReplicatedStorage)
    scan(ReplicatedStorage:FindFirstChild("Enemies"))
    scan(ReplicatedStorage:FindFirstChild("EnemyStorage"))
end

FarmRuntime.FindReplicatedBoss = function(root, selectedName)
    if not root then return nil end
    local wanted = selectedName and selectedName ~= "Nearest Spawned" and normalizeEnemyName(selectedName) or nil
    local best, bestDistance
    FarmRuntime.ForEachReplicatedBoss(function(model)
        if not wanted or normalizeEnemyName(model.Name) == wanted then
            local part = getPart(model)
            local distance = (part.Position - root.Position).Magnitude
            if not bestDistance or distance < bestDistance then
                best, bestDistance = model, distance
            end
        end
    end)
    return best
end

local function getBossNames()
    local names, seen = { "Nearest Spawned" }, { ["Nearest Spawned"] = true }
    local function add(name)
        name = normalizeEnemyName(name)
        if name ~= "" and not seen[name] then
            seen[name] = true
            names[#names + 1] = name
        end
    end
    for _, entry in ipairs(state.QuestCatalog) do
        if entry.Count == 1 and state.EnemySpawns[entry.Target] then
            add(entry.Target)
        end
    end
    local origin = workspace:FindFirstChild("_WorldOrigin")
    local spawns = origin and origin:FindFirstChild("EnemySpawns")
    if spawns then
        for _, part in ipairs(spawns:GetDescendants()) do
            if part:IsA("BasePart") then
                local display = tostring(part:GetAttribute("DisplayName") or part.Name)
                if string.find(string.lower(display), "[boss]", 1, true) then add(display) end
            end
        end
    end
    local enemies = workspace:FindFirstChild("Enemies")
    if enemies then
        for _, model in ipairs(enemies:GetChildren()) do
            if model:IsA("Model") and isBoss(model) then add(model.Name) end
        end
    end
    FarmRuntime.ForEachReplicatedBoss(function(model) add(model.Name) end)
    table.sort(names, function(a, b)
        if a == "Nearest Spawned" then return true end
        if b == "Nearest Spawned" then return false end
        return a < b
    end)
    return names
end

local IslandNames = getIslandNames()

local function refreshQuestGivers()
    table.clear(state.QuestGivers)
    local guide = state.GuideModule
    local list = guide and guide.Data and guide.Data.NPCList
    if type(list) ~= "table" then return end
    for _, data in pairs(list) do
        if type(data) == "table" and type(data.InternalQuestName) == "string" and typeof(data.Position) == "Vector3" then
            local entries = state.QuestGivers[data.InternalQuestName]
            if not entries then
                entries = {}
                state.QuestGivers[data.InternalQuestName] = entries
            end
            entries[#entries + 1] = data
        end
    end
end

local function refreshEnemySpawns()
    table.clear(state.EnemySpawns)
    local origin = workspace:FindFirstChild("_WorldOrigin")
    local folder = origin and origin:FindFirstChild("EnemySpawns")
    if not folder then return end
    for _, part in ipairs(folder:GetDescendants()) do
        if part:IsA("BasePart") and part:GetAttribute("Active") ~= false then
            local name = normalizeEnemyName(part:GetAttribute("DisplayName") or part.Name)
            if name ~= "" then
                local entries = state.EnemySpawns[name]
                if not entries then
                    entries = {}
                    state.EnemySpawns[name] = entries
                end
                entries[#entries + 1] = part
            end
        end
    end
end

local function rebuildFarmData()
    local questOk, quests = pcall(require, ReplicatedStorage:WaitForChild("Quests"))
    state.QuestDefinitions = questOk and type(quests) == "table" and quests or nil
    local guideScript = ReplicatedStorage:WaitForChild("GuideModule")
    local guideOk, guide = pcall(require, guideScript)
    state.GuideModule = guideOk and type(guide) == "table" and guide or nil
    local guideDataScript = guideScript:FindFirstChild("GuideData")
    local guideDataOk, guideData = pcall(require, guideDataScript)
    state.GuideDataModule = guideDataOk and type(guideData) == "table" and guideData or nil
    table.clear(state.QuestCatalog)
    if state.QuestDefinitions then
        for questId, tiers in pairs(state.QuestDefinitions) do
            if type(tiers) == "table" then
                for tier, info in pairs(tiers) do
                    if type(tier) == "number" and type(info) == "table" and type(info.Task) == "table" then
                        for target, count in pairs(info.Task) do
                            state.QuestCatalog[#state.QuestCatalog + 1] = {
                                Id = tostring(questId),
                                Tier = tier,
                                Level = tonumber(info.LevelReq) or 0,
                                Name = tostring(info.Name or target),
                                Target = normalizeEnemyName(target),
                                Count = tonumber(count) or 1
                            }
                        end
                    end
                end
            end
        end
        table.sort(state.QuestCatalog, function(a, b)
            if a.Level == b.Level then return a.Tier < b.Tier end
            return a.Level < b.Level
        end)
    end
    refreshQuestGivers()
    refreshEnemySpawns()
end

local function questGiverFor(entry, root)
    if not entry then return nil end
    local entries = state.QuestGivers[entry.Id]
    if not entries then return nil end
    local best, bestDistance
    for _, data in ipairs(entries) do
        local exactLevel = false
        if type(data.Levels) == "table" then
            for _, level in pairs(data.Levels) do
                if tonumber(level) == entry.Level then
                    exactLevel = true
                    break
                end
            end
        end
        if exactLevel or #entries == 1 then
            local distance = root and (data.Position - root.Position).Magnitude or 0
            if not bestDistance or distance < bestDistance then
                best, bestDistance = data, distance
            end
        end
    end
    return best or entries[1]
end

local function farmEnemyNames()
    local names, seen = { "Auto by Level" }, { ["Auto by Level"] = true }
    for _, entry in ipairs(state.QuestCatalog) do
        if entry.Count > 1 and state.QuestGivers[entry.Id] and not seen[entry.Target] then
            seen[entry.Target] = true
            names[#names + 1] = entry.Target
        end
    end
    if #names == 1 then
        for name in pairs(state.EnemySpawns) do
            if not seen[name] then
                seen[name] = true
                names[#names + 1] = name
            end
        end
    end
    table.sort(names, function(a, b)
        if a == "Auto by Level" then return true end
        if b == "Auto by Level" then return false end
        return a < b
    end)
    return names
end

local function playerLevel()
    local data = LocalPlayer:FindFirstChild("Data")
    local level = data and data:FindFirstChild("Level")
    return level and tonumber(level.Value) or 0
end

local function selectFarmQuest(targetName, allowBoss)
    local level = playerLevel()
    local best
    refreshQuestGivers()
    for _, entry in ipairs(state.QuestCatalog) do
        local targetMatches = not targetName or entry.Target == targetName
        if targetMatches and entry.Level <= level and (allowBoss or entry.Count > 1) and questGiverFor(entry) then
            if not best or entry.Level > best.Level or (entry.Level == best.Level and entry.Tier > best.Tier) then
                best = entry
            end
        end
    end
    return best
end

local function nearestFarmEnemy(root, targetName, bossesOnly)
    local folder = workspace:FindFirstChild("Enemies")
    if not folder or not root then return nil end
    local best, bestDistance
    for _, model in ipairs(folder:GetChildren()) do
        local part = getPart(model)
        local humanoid = getHumanoid(model)
        local boss = isBoss(model)
        local matches = not targetName or targetName == "Nearest Spawned" or normalizeEnemyName(model.Name) == targetName
        if matches and (not bossesOnly or boss) and part and humanoid and humanoid.Health > 0 then
            local distance = (part.Position - root.Position).Magnitude
            if not bestDistance or distance < bestDistance then
                best, bestDistance = model, distance
            end
        end
    end
    return best
end

FarmRuntime.NearestReplicatedEnemyReference = function(root, targetName)
    if not root or not targetName then return nil, nil end
    local wanted = normalizeEnemyName(targetName)
    local best, bestPart, bestDistance
    local scanned = {}
    local function scan(container)
        if not container or scanned[container] then return end
        scanned[container] = true
        for _, model in ipairs(container:GetChildren()) do
            local part = model:IsA("Model") and getPart(model) or nil
            local humanoid = model:IsA("Model") and getHumanoid(model) or nil
            if part and humanoid and normalizeEnemyName(model.Name) == wanted then
                local distance = (part.Position - root.Position).Magnitude
                if not bestDistance or distance < bestDistance then
                    best, bestPart, bestDistance = model, part, distance
                end
            end
        end
    end
    scan(ReplicatedStorage)
    scan(ReplicatedStorage:FindFirstChild("Enemies"))
    scan(ReplicatedStorage:FindFirstChild("EnemyStorage"))
    return best, bestPart
end

local function spawnedBossForQuestList(root, levelQuest)
    if not root or not levelQuest then return nil, nil end
    local level = playerLevel()
    local bestQuest, bestTarget, bestLevel, bestDistance
    for _, entry in ipairs(state.QuestCatalog) do
        if entry.Id == levelQuest.Id and entry.Count == 1 and entry.Level <= level then
            local target = nearestFarmEnemy(root, entry.Target, true)
            local part = target and getPart(target)
            if part then
                local distance = (part.Position - root.Position).Magnitude
                if not bestTarget or entry.Level > bestLevel or (entry.Level == bestLevel and distance < bestDistance) then
                    bestQuest = entry
                    bestTarget = target
                    bestLevel = entry.Level
                    bestDistance = distance
                end
            end
        end
    end
    return bestQuest, bestTarget
end

FarmRuntime.ResolveBossCycle = function(root)
    local level = playerLevel()
    local bestQuest, bestTarget, bestDistance
    local fallbackQuest, fallbackDistance
    refreshQuestGivers()
    for _, entry in ipairs(state.QuestCatalog) do
        local giver = entry.Count == 1 and entry.Level <= level and questGiverFor(entry, root) or nil
        if giver then
            local target = nearestFarmEnemy(root, entry.Target, true)
            local _, storedPart = FarmRuntime.NearestReplicatedEnemyReference(root, entry.Target)
            local part = target and getPart(target) or storedPart
            if part then
                local distance = (part.Position - root.Position).Magnitude
                if not bestDistance or distance < bestDistance then
                    bestQuest, bestTarget, bestDistance = entry, target, distance
                end
            end
            local knownPosition = giver.Position
            for _, spawnPart in ipairs(state.EnemySpawns[entry.Target] or {}) do
                if spawnPart and spawnPart.Parent and (spawnPart.Position - root.Position).Magnitude < (knownPosition - root.Position).Magnitude then
                    knownPosition = spawnPart.Position
                end
            end
            local distance = (knownPosition - root.Position).Magnitude
            if not fallbackDistance or distance < fallbackDistance then
                fallbackQuest, fallbackDistance = entry, distance
            end
        end
    end
    local quest = bestQuest or fallbackQuest
    return quest and quest.Target or nil, quest, bestTarget
end

local function nearestEnemySpawn(root, targetName)
    if not root then return nil end
    local entries = state.EnemySpawns[targetName] or {}
    local best, bestDistance
    for _, part in ipairs(entries) do
        if part and part.Parent then
            local distance = (part.Position - root.Position).Magnitude
            if not bestDistance or distance < bestDistance then
                best, bestDistance = part, distance
            end
        end
    end
    local _, storedPart = FarmRuntime.NearestReplicatedEnemyReference(root, targetName)
    if storedPart then
        local distance = (storedPart.Position - root.Position).Magnitude
        if not bestDistance or distance < bestDistance then best, bestDistance = storedPart, distance end
    end
    return best
end

do
local farmCombatUtil
local farmRegisterAttack
local farmRegisterHit
local farmModuleRetryAt = 0
local farmVirtualInput = game:GetService("VirtualInputManager")
local fishmanEntrance = Vector3.new(4047.7, 83.6, -1814.4)
FarmRuntime.CursedShipEntrance = Vector3.new(-6498.5029296875, 83, -122.5301742553711)
FarmRuntime.CursedShipExit = Vector3.new(923.846923828125, 125.08697509765625, 32840.2734375)

local function loadFarmCombatModules()
    if farmCombatUtil and farmRegisterAttack and farmRegisterAttack.Parent and farmRegisterHit and farmRegisterHit.Parent then
        return true
    end
    if os.clock() < farmModuleRetryAt then return false, "Combat data unavailable" end
    farmModuleRetryAt = os.clock() + 1
    local modules = ReplicatedStorage:FindFirstChild("Modules")
    local net = modules and modules:FindFirstChild("Net")
    local utilScript = modules and modules:FindFirstChild("CombatUtil")
    local globalScript = ReplicatedStorage:FindFirstChild("Global")
    local utilOk, util = pcall(require, utilScript)
    local globalOk, global = pcall(require, globalScript)
    local attack = net and net:FindFirstChild("RE/RegisterAttack")
    local hit = net and net:FindFirstChild("RE/RegisterHit")
    if not utilOk or type(util) ~= "table" or not attack or not hit then
        return false, "Combat data unavailable"
    end
    farmCombatUtil = util
    farmRegisterAttack = attack
    farmRegisterHit = hit
    if globalOk and type(global) == "table" and type(global.SendHitsToServer) == "function" then
        FarmRuntime.FarmGlobal = global
    end
    return true
end

local function toolMasteryLevel(tool)
    if not tool or not tool:IsA("Tool") then return 0 end
    local level = tool:FindFirstChild("Level")
    if level and level:IsA("ValueBase") then return tonumber(level.Value) or 0 end
    return tonumber(tool:GetAttribute("Level") or tool:GetAttribute("Mastery")) or 0
end

local function normalizeWeaponCategory(weaponType)
    local lowered = string.lower(tostring(weaponType or ""))
    if lowered == "melee" then return "Melee" end
    if lowered == "sword" then return "Sword" end
    if lowered == "gun" then return "Gun" end
    if lowered == "demon fruit" or lowered == "blox fruit" or lowered == "fruit" then return "Blox Fruit" end
    return nil
end

local function weaponDescriptor(tool)
    if not tool or not tool:IsA("Tool") then return nil, "Not a weapon tool" end
    if not CollectionService:HasTag(tool, "WeaponTool") then
        local category = normalizeWeaponCategory(tool:GetAttribute("WeaponType") or tool.ToolTip)
        local level = tool:FindFirstChild("Level")
        local fruitRemote = tool:FindFirstChild("RemoteEvent")
        local fruitM1Remote = tool:FindFirstChild("LeftClickRemote")
        local hasFruitM1 = category == "Blox Fruit" and fruitM1Remote and fruitM1Remote:IsA("RemoteEvent")
        if category ~= "Blox Fruit" or not level or not fruitRemote then return nil, "Missing WeaponTool tag" end
        return {
            Tool = tool,
            DisplayName = tool.Name,
            WeaponName = tool.Name,
            WeaponData = nil,
            Category = "Blox Fruit",
            ComboCount = hasFruitM1 and 3 or 0,
            Damage = 0,
            Mastery = toolMasteryLevel(tool),
            Pointer = nil,
            FruitM1Remote = hasFruitM1 and fruitM1Remote or nil,
            FruitM1ComboCount = hasFruitM1 and 3 or nil,
            HasBasicAttack = hasFruitM1 and true or false,
            SkillOnly = not hasFruitM1
        }
    end
    local loaded, loadError = loadFarmCombatModules()
    if not loaded then return nil, loadError end
    local nameOk, weaponName = pcall(function() return farmCombatUtil:GetWeaponName(tool) end)
    if not nameOk or type(weaponName) ~= "string" or weaponName == "" then return nil, "Weapon name unavailable" end
    local dataOk, weaponData = pcall(function() return farmCombatUtil:GetWeaponData(weaponName) end)
    if not dataOk or type(weaponData) ~= "table" then return nil, "Weapon data unavailable" end
    local category = normalizeWeaponCategory(weaponData.WeaponType)
    if not category then return nil, "Weapon type unavailable" end
    local basic = weaponData.Moveset and weaponData.Moveset.Basic
    local comboCount, damage = 0, 0
    if type(basic) == "table" then
        for index, attackData in pairs(basic) do
            if type(index) == "number" and type(attackData) == "table" then
                comboCount = math.max(comboCount, index)
                damage = damage + (tonumber(attackData.Damage) or 0)
            end
        end
    end
    local fruitM1Remote = category == "Blox Fruit" and tool:FindFirstChild("LeftClickRemote") or nil
    local hasFruitM1 = fruitM1Remote and fruitM1Remote:IsA("RemoteEvent") or false
    if hasFruitM1 and comboCount <= 0 then comboCount = 3 end
    local skillOnly = category == "Blox Fruit" and comboCount <= 0
    if comboCount <= 0 and not skillOnly then return nil, "Basic attacks unavailable" end
    local pointer = tool:FindFirstChild("LocalEquippedWeaponPointer", true)
    if not skillOnly and not hasFruitM1 and (not pointer or not pointer:IsA("ObjectValue")) then return nil, "Equip pointer unavailable" end
    return {
        Tool = tool,
        DisplayName = tool.Name,
        WeaponName = weaponName,
        WeaponData = weaponData,
        Category = category,
        ComboCount = comboCount,
        Damage = damage,
        Mastery = toolMasteryLevel(tool),
        Pointer = pointer,
        FruitM1Remote = hasFruitM1 and fruitM1Remote or nil,
        FruitM1ComboCount = hasFruitM1 and math.min(3, math.max(1, comboCount)) or nil,
        HasBasicAttack = comboCount > 0,
        SkillOnly = skillOnly
    }
end

FarmRuntime.WeaponReady = function(info, character)
    if not info or not info.Tool or info.Tool.Parent ~= character then return false end
    if info.FruitM1Remote then
        return info.FruitM1Remote.Parent == info.Tool and info.FruitM1Remote:IsA("RemoteEvent")
    end
    if info.SkillOnly then return true end
    return info.Pointer and info.Pointer.Parent and info.Pointer.Value ~= nil
end

FarmRuntime.MasterySkills = (function()
local keys = {
    { Name = "Z", Code = Enum.KeyCode.Z },
    { Name = "X", Code = Enum.KeyCode.X },
    { Name = "C", Code = Enum.KeyCode.C },
    { Name = "V", Code = Enum.KeyCode.V }
}

local function skillFrame(tool, name)
    local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    local main = playerGui and playerGui:FindFirstChild("Main")
    local skills = main and main:FindFirstChild("Skills")
    local weaponFrame = skills and skills:FindFirstChild(tool.Name)
    return weaponFrame and weaponFrame:FindFirstChild(name)
end

local function requiredMastery(frame)
    local label = frame and frame:FindFirstChild("Level")
    local value = label and tonumber(string.match(tostring(label.Text), "%d+"))
    return value or 0
end

local function cooldownReady(frame)
    local cooldown = frame and frame:FindFirstChild("Cooldown")
    if not cooldown or not cooldown:IsA("GuiObject") then return true end
    return cooldown.Size.X.Scale <= 0.035 and cooldown.Size.X.Offset <= 1
end

local function chooseSkill(info)
    local available = {}
    local mastery = toolMasteryLevel(info.Tool)
    for _, entry in ipairs(keys) do
        local frame = skillFrame(info.Tool, entry.Name)
        if frame and requiredMastery(frame) <= mastery and cooldownReady(frame) then
            available[#available + 1] = entry
        end
    end
    if #available == 0 then
        local hasUnlocked = false
        for _, entry in ipairs(keys) do
            local frame = skillFrame(info.Tool, entry.Name)
            if frame and requiredMastery(frame) <= mastery then hasUnlocked = true; break end
        end
        return nil, hasUnlocked and "cooldown" or "locked"
    end
    state.FarmSkillIndex = state.FarmSkillIndex % #available + 1
    return available[state.FarmSkillIndex]
end

local function aimAtTarget(info, target)
    local camera = workspace.CurrentCamera
    local part = getPart(target)
    if not camera or not part or not part:IsA("BasePart") then return nil, "Fruit target unavailable" end
    local distance = (part.Position - camera.CFrame.Position).Magnitude
    local lead = math.clamp(distance / 650, 0.04, 0.3)
    local velocity = part.AssemblyLinearVelocity
    local aimPosition = part.Position + Vector3.new(0, math.clamp(part.Size.Y * 0.2, 0.5, 2.5), 0) + velocity * lead
    camera.CFrame = CFrame.lookAt(camera.CFrame.Position, aimPosition)
    local point = camera:WorldToViewportPoint(aimPosition)
    local x = math.clamp(point.X, 2, camera.ViewportSize.X - 2)
    local y = math.clamp(point.Y, 2, camera.ViewportSize.Y - 2)
    pcall(function() farmVirtualInput:SendMouseMoveEvent(x, y, game) end)
    local mousePos = info.Tool:FindFirstChild("MousePos")
    if mousePos and mousePos:IsA("Vector3Value") then mousePos.Value = aimPosition end
    local mouse = info.Tool:FindFirstChild("Mouse")
    if mouse and mouse:IsA("CFrameValue") then mouse.Value = CFrame.new(aimPosition) end
    return aimPosition
end

local function cast(info, target)
    if state.FarmSkillBusy then return nil end
    local skill, reason = chooseSkill(info)
    if not skill then
        if reason == "cooldown" then return nil end
        return false, "No unlocked fruit move"
    end
    local aimed, aimError = aimAtTarget(info, target)
    if not aimed then return false, aimError end
    state.FarmSkillBusy = true
    state.FarmSkillToken = state.FarmSkillToken + 1
    state.FarmLastSkill = skill.Name
    local token = state.FarmSkillToken
    local generation = state.FarmGeneration
    task.spawn(function()
        local pressed = pcall(function() farmVirtualInput:SendKeyEvent(true, skill.Code, false, game) end)
        if pressed then task.wait(0.12) end
        pcall(function() farmVirtualInput:SendKeyEvent(false, skill.Code, false, game) end)
        if state.FarmSkillToken == token and state.FarmGeneration == generation then
            state.FarmSkillBusy = false
        end
    end)
    return true, nil, math.max(0.25, Settings.FarmAttackDelay)
end

return { Cast = cast }
end)()

local function ownsFarmTool(tool)
    if not tool then return false end
    return tool.Parent == LocalPlayer.Character or tool.Parent == LocalPlayer:FindFirstChildOfClass("Backpack")
end

local function farmRequestedCategory()
    if Settings.MasteryFinisher and state.FarmTarget then
        local targetHumanoid = getHumanoid(state.FarmTarget)
        if targetHumanoid and targetHumanoid.MaxHealth > 0
            and targetHumanoid.Health / targetHumanoid.MaxHealth * 100 <= Settings.MasteryFinisherHealth then
            return Settings.MasteryFinisherType
        end
    end
    return Settings.FarmMode == "Mastery" and Settings.FarmMasteryType or Settings.FarmWeapon
end

local function resolveFarmWeapon(category)
    category = category or farmRequestedCategory()
    local character = LocalPlayer.Character
    local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
    local candidates, seen = {}, {}
    local lastError = "No matching weapon"
    local function scan(container)
        if not container then return end
        for _, tool in ipairs(container:GetChildren()) do
            if tool:IsA("Tool") and not seen[tool] then
                seen[tool] = true
                local info, reason = weaponDescriptor(tool)
                if info and (category == "Auto" or info.Category == category) then
                    info.Equipped = tool.Parent == character
                    candidates[#candidates + 1] = info
                elseif reason and reason ~= "Missing WeaponTool tag" then
                    lastError = reason
                end
            end
        end
    end
    scan(character)
    scan(backpack)
    table.sort(candidates, function(a, b)
        if category == "Auto" or category == "Blox Fruit" then
            local aFruitM1 = a.Category == "Blox Fruit" and a.HasBasicAttack
            local bFruitM1 = b.Category == "Blox Fruit" and b.HasBasicAttack
            if aFruitM1 ~= bFruitM1 then return aFruitM1 end
        end
        if a.Equipped ~= b.Equipped then return a.Equipped end
        if a.Mastery ~= b.Mastery then return a.Mastery > b.Mastery end
        if a.Damage ~= b.Damage then return a.Damage > b.Damage end
        return string.lower(a.DisplayName) < string.lower(b.DisplayName)
    end)
    return candidates[1], #candidates > 0 and nil or lastError
end

local function masteryLevel(category)
    local current = state.FarmWeaponInfo
    if current and ownsFarmTool(current.Tool) and (category == "Auto" or current.Category == category) then
        return toolMasteryLevel(current.Tool)
    end
    local resolved = resolveFarmWeapon(category)
    return resolved and resolved.Mastery or 0
end

local function isFarmTravelMode(mode)
    return type(mode) == "string" and string.sub(mode, 1, 4) == "farm"
end

local function farmAutomationActive()
    return Settings.AutoFarm or Settings.AutoBosses or Settings.AutoMaterial or Settings.AutoWeaponGoal or state.SpecialFarm ~= nil
end

local function farmBossMode()
    local weaponGoal = Settings.AutoWeaponGoal and FarmRuntime.WeaponTargets[Settings.WeaponGoal]
    return state.SpecialFarm and state.SpecialFarm.Boss == true
        or weaponGoal and weaponGoal.Boss == true
        or Settings.AutoBosses
        or Settings.FarmMode == "Boss"
        or state.FarmLevelBossActive == true
end

local function setFarmStatus(status)
    status = tostring(status or "Idle")
    if state.FarmStatus ~= status then
        state.FarmStatus = status
        state.FarmStatusAt = os.clock()
    end
end

local function setFarmPhase(phase, status)
    phase = tostring(phase or "Idle")
    if state.FarmPhase ~= phase then
        state.FarmPhase = phase
        state.FarmPhaseAt = os.clock()
    end
    if status then setFarmStatus(status) end
end

local function setFarmWarning(message)
    message = tostring(message or "")
    local changed = state.FarmWarning ~= message
    state.FarmWarning = message
    if changed and message ~= "" and farmAutomationActive() then
        contextNotice("FarmWarning", message, Red, 4, 6)
    end
end

local function resetFarmRemoteSession()
    local thread = state.FarmRemoteThread
    state.FarmRemoteThread = nil
    state.FarmRemoteToken = nil
    state.FarmRemoteWeapon = nil
    state.FarmRemoteHitCursor = 0
    if thread and coroutine.close then pcall(coroutine.close, thread) end
end

local function resetFarmDamage(target)
    state.FarmDamageTarget = target
    local humanoid = getHumanoid(target)
    state.FarmDamageBaseline = humanoid and humanoid.Health or nil
    state.FarmDamageAttacks = 0
    state.FarmDamageCheckAt = 0
end

local function clearFarmTravel()
    state.FarmTravelBudget = 0
    if isFarmTravelMode(state.TravelMode) then stopTravel() end
end

local function setFarmTravel(position, name, mode, object)
    if (not Settings.FarmAutoTravel and not state.SpecialFarm) or typeof(position) ~= "Vector3" then
        if isFarmTravelMode(state.TravelMode) then stopTravel() end
        return false
    end
    if state.TravelMode ~= mode or state.TravelObject ~= object then
        state.TravelBudget = 0
        state.TravelSerial = state.TravelSerial + 1
    end
    state.TravelTarget = position
    state.TravelName = name
    state.TravelMode = mode
    state.TravelObject = object
    state.TravelOwner = "farm"
    return true
end

local function cancelFarmQuestRequest()
    state.FarmQuestRequestId = state.FarmQuestRequestId + 1
    state.FarmQuestRequest = nil
    state.FarmQuestRequestPending = false
end

local function invalidateFarmRuntime(warning, readyDelay)
    if FarmRuntime.ClearFarmGroup then FarmRuntime.ClearFarmGroup() end
    state.FarmGeneration = state.FarmGeneration + 1
    cancelFarmQuestRequest()
    resetFarmRemoteSession()
    clearFarmTravel()
    state.FarmQuest = nil
    state.FarmQuestGiver = nil
    state.FarmTarget = nil
    state.FarmTargetName = nil
    state.FarmLevelBossActive = false
    state.FarmTool = nil
    state.FarmWeaponInfo = nil
    state.FarmEquipAttempts = 0
    state.FarmEquipRequestedAt = 0
    state.FarmClickSerial = state.FarmClickSerial + 1
    state.FarmClickRequest = nil
    state.FarmSkillIndex = 0
    state.FarmSkillBusy = false
    state.FarmSkillToken = state.FarmSkillToken + 1
    state.FarmLastSkill = nil
    state.FarmFruitM1Targets = setmetatable({}, { __mode = "k" })
    state.FarmCombo = 0
    state.FarmNextAttackAt = 0
    state.FarmNoDamageCount = 0
    state.FarmCloserUntil = 0
    state.FarmFishmanApproached = false
    state.FarmFishmanWaitUntil = 0
    state.FarmShipTransition = nil
    state.FarmShipApproached = false
    state.FarmShipWaitUntil = 0
    resetFarmDamage(nil)
    state.FarmReadyAt = os.clock() + (tonumber(readyDelay) or 0)
    if warning ~= nil then state.FarmWarning = tostring(warning) end
    local active = farmAutomationActive()
    setFarmPhase(active and "Resolve Quest" or "Idle", active and "Preparing farm" or "Idle")
end

local function currentQuestSnapshot()
    local guideData = state.GuideDataModule
    local tracked = guideData and guideData.Data and guideData.Data.QuestData
    if type(tracked) ~= "table" or type(tracked.Info) ~= "table" then return { Active = false } end
    local tasks, progress, current, required, taskCount = {}, {}, 0, 0, 0
    for target, count in pairs(tracked.Info.Task or {}) do
        local normalized = normalizeEnemyName(target)
        tasks[normalized] = tonumber(count) or 0
        progress[normalized] = tonumber(tracked.Progress and tracked.Progress[target]) or 0
        current = current + progress[normalized]
        required = required + tasks[normalized]
        taskCount = taskCount + 1
    end
    local questId = tostring(tracked.InternalQuestName or "")
    local tier = tonumber(tracked.QuestIndex or tracked.Tier or tracked.Info.Tier)
    if not tier and state.QuestDefinitions and type(state.QuestDefinitions[questId]) == "table" then
        for candidateTier, info in pairs(state.QuestDefinitions[questId]) do
            if type(candidateTier) == "number" and type(info) == "table" and tonumber(info.LevelReq) == tonumber(tracked.Info.LevelReq) then
                local matched, candidateCount = true, 0
                for target, count in pairs(info.Task or {}) do
                    candidateCount = candidateCount + 1
                    if tasks[normalizeEnemyName(target)] ~= (tonumber(count) or 0) then matched = false; break end
                end
                if matched and candidateCount == taskCount then tier = candidateTier; break end
            end
        end
    end
    return {
        Active = true,
        Id = questId,
        Tier = tier,
        Level = tonumber(tracked.Info.LevelReq),
        Name = tostring(tracked.Info.Name or ""),
        Tasks = tasks,
        Progress = progress,
        Current = current,
        Required = required
    }
end

local function questMatches(entry, snapshot)
    if not entry then return false end
    snapshot = snapshot or currentQuestSnapshot()
    if not snapshot.Active or snapshot.Id ~= entry.Id then return false end
    if snapshot.Tier and snapshot.Tier ~= entry.Tier then return false end
    if snapshot.Level and snapshot.Level ~= entry.Level then return false end
    return snapshot.Tasks[entry.Target] == entry.Count
end

local function questComplete(snapshot)
    snapshot = snapshot or currentQuestSnapshot()
    return snapshot.Active and snapshot.Required > 0 and snapshot.Current >= snapshot.Required
end

local function beginFarmQuestRequest(action, entry)
    if state.FarmQuestRequestPending then return state.FarmQuestRequest end
    if os.clock() - state.FarmLastQuestRequest < 0.35 then return nil end
    state.FarmLastQuestRequest = os.clock()
    state.FarmQuestRequestId = state.FarmQuestRequestId + 1
    local requestId = state.FarmQuestRequestId
    local generation = state.FarmGeneration
    local request = {
        Id = requestId,
        Action = action,
        Entry = entry,
        Deadline = os.clock() + 5,
        Done = false,
        Ok = nil,
        Result = nil
    }
    state.FarmQuestRequest = request
    state.FarmQuestRequestPending = true
    task.spawn(function()
        local ok, result
        if action == "Abandon" then
            ok, result = pcall(function() return CommF:InvokeServer("AbandonQuest") end)
        else
            ok, result = pcall(function() return CommF:InvokeServer("StartQuest", entry.Id, entry.Tier) end)
        end
        if state.Alive and state.FarmGeneration == generation and state.FarmQuestRequestId == requestId then
            request.Done = true
            request.Ok = ok
            request.Result = result
            state.FarmQuestRequestPending = false
        end
    end)
    return request
end

local function farmDesiredPosition(part)
    local distance = math.clamp(Settings.FarmDistance, 3, 50)
    if state.FarmCloserUntil > os.clock() then distance = math.max(3, distance - 3) end
    if Settings.FarmPosition == "Square" then
        local radius = math.clamp(tonumber(Settings.FarmSquareSize) or 10, 4, 30)
        local interval = math.clamp(tonumber(Settings.FarmSquareCornerTime) or 0.7, 0.2, 3)
        local corner = math.floor(os.clock() / interval) % 4 + 1
        local x = (corner == 1 or corner == 4) and -radius or radius
        local z = (corner == 1 or corner == 2) and -radius or radius
        return part.Position + Vector3.new(0, distance, 0)
            + part.CFrame.RightVector * x
            + part.CFrame.LookVector * z
    end
    if Settings.FarmPosition == "Behind" then
        return part.Position - part.CFrame.LookVector * distance + Vector3.new(0, 2, 0)
    end
    if Settings.FarmPosition == "Front" then
        return part.Position + part.CFrame.LookVector * distance + Vector3.new(0, 2, 0)
    end
    return part.Position + Vector3.new(0, distance, 0)
end

local function stopAutoFarm(message)
    Settings.AutoFarm = false
    invalidateFarmRuntime("", 0)
    if FarmEnabledControl and FarmEnabledControl.Set then FarmEnabledControl:Set(false) end
    if message then showNotice(message, nil, 4) end
end

local function clickFarmAttack(info, target)
    local pending = state.FarmClickRequest
    if pending then
        if pending.Generation ~= state.FarmGeneration then
            state.FarmClickRequest = nil
        elseif pending.Done then
            state.FarmClickRequest = nil
            return pending.Ok, pending.Error, math.max(0.05, Settings.FarmAttackDelay)
        elseif os.clock() >= pending.Deadline then
            state.FarmClickRequest = nil
            return false, "Virtual click timed out"
        else
            return nil
        end
    end
    local camera = workspace.CurrentCamera
    local targetPart = getPart(target)
    if not camera or not targetPart then return false, "Click target unavailable" end
    local point = Vector2.new(math.max(1, camera.ViewportSize.X - 24), math.floor(camera.ViewportSize.Y * 0.5))
    state.FarmClickSerial = state.FarmClickSerial + 1
    state.FarmClickRequest = {
        Id = state.FarmClickSerial,
        Generation = state.FarmGeneration,
        Point = point,
        Deadline = os.clock() + 1,
        Processing = false,
        Done = false,
        Ok = nil,
        Error = nil
    }
    return nil
end

local function processFarmClick()
    local request = state.FarmClickRequest
    if not request or request.Done or request.Processing then return end
    if request.Generation ~= state.FarmGeneration or os.clock() >= request.Deadline then return end
    request.Processing = true
    local pressed = pcall(function()
        farmVirtualInput:SendMouseButtonEvent(request.Point.X, request.Point.Y, 0, true, game, 0)
    end)
    local released = false
    if pressed then
        task.wait(0.04)
        released = pcall(function()
            farmVirtualInput:SendMouseButtonEvent(request.Point.X, request.Point.Y, 0, false, game, 0)
        end)
    end
    if state.FarmClickRequest == request and request.Generation == state.FarmGeneration then
        request.Ok = pressed and released
        request.Error = request.Ok and nil or "Virtual click failed"
        request.Done = true
    end
end

local function farmAnimationDuration(info, humanoid, combo)
    local loaded = loadFarmCombatModules()
    if not loaded then return nil end
    local ok, animations = pcall(function() return farmCombatUtil:GetLoadedAnimsFor(info.WeaponName, humanoid) end)
    if not ok or type(animations) ~= "table" then return nil end
    local track = animations["basic" .. tostring(combo)] or animations[combo]
    if not track then return nil end
    local length = tonumber(track.Length)
    if not length or length <= 0 then return nil end
    local speed = 1
    pcall(function() speed = tonumber(track:GetAttribute("SpeedMult")) or 1 end)
    return length / math.max(0.05, speed)
end

local function createFarmRemoteSession(info)
    local loaded, loadError = loadFarmCombatModules()
    if not loaded then return false, loadError end
    resetFarmRemoteSession()
    local generation = state.FarmGeneration
    local thread
    thread = coroutine.create(function()
        local token = tostring(LocalPlayer.UserId):sub(2, 4) .. tostring(coroutine.running()):sub(11, 15)
        state.FarmRemoteToken = token
        FarmRuntime.FireRemote(farmRegisterHit, token)
        while state.Alive and state.FarmGeneration == generation do
            local hitPart, extraHits = coroutine.yield()
            if not hitPart then return end
            FarmRuntime.FireRemote(farmRegisterHit, hitPart, extraHits or {}, nil, token)
        end
    end)
    state.FarmRemoteThread = thread
    state.FarmRemoteWeapon = info.Tool
    local resumed = coroutine.resume(thread)
    if not resumed or coroutine.status(thread) ~= "suspended" then
        resetFarmRemoteSession()
        return false, "Remote session failed"
    end
    return true
end

FarmRuntime.FarmGroupMatches = function(model, fallbackName)
    if not model then return false end
    local special = state.SpecialFarm
    if special and special.GroupAll then
        local part = getPart(model)
        if special.GroupOrigin and special.GroupRange and part then
            return (part.Position - special.GroupOrigin).Magnitude <= special.GroupRange
        end
        return true
    end
    if special and type(special.GroupNames) == "table" then
        local modelName = normalizeEnemyName(model.Name)
        for _, name in ipairs(special.GroupNames) do
            if modelName == normalizeEnemyName(name) then return true end
        end
        return false
    end
    return normalizeEnemyName(model.Name) == normalizeEnemyName(fallbackName)
end

FarmRuntime.RaycastEnemiesBelow = function(localRoot, primaryPart)
    local extraHits = {}
    local enemies = workspace:FindFirstChild("Enemies")
    if not localRoot or not enemies then return extraHits end
    local primaryModel = primaryPart and primaryPart:FindFirstAncestorOfClass("Model") or nil
    local origin = localRoot.Position
    local center = state.FarmGroupDestination or (primaryPart and primaryPart.Position) or origin
    local radius = Settings.FarmAutoGroup and 90 or math.clamp((tonumber(Settings.FarmDistance) or 7) + 35, 35, 90)
    local verticalRange = math.clamp((tonumber(Settings.FarmDistance) or 7) + 65, 65, 140)
    local targetName = normalizeEnemyName(state.FarmTargetName)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Include
    params.IgnoreWater = true
    for _, model in ipairs(enemies:GetChildren()) do
        if model:IsA("Model") and model ~= primaryModel then
            local enemyHumanoid = getHumanoid(model)
            local enemyPart = model:FindFirstChild("Head") or model:FindFirstChild("HumanoidRootPart")
                or model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true)
            if enemyHumanoid and enemyHumanoid.Health > 0 and enemyPart and enemyPart:IsA("BasePart") then
                local playerOffset = enemyPart.Position - origin
                local centerOffset = enemyPart.Position - center
                local playerHorizontal = Vector3.new(playerOffset.X, 0, playerOffset.Z).Magnitude
                local centerHorizontal = Vector3.new(centerOffset.X, 0, centerOffset.Z).Magnitude
                local questMatch = not Settings.FarmAutoGroup or targetName == ""
                    or FarmRuntime.FarmGroupMatches(model, targetName)
                local inRange = (playerHorizontal <= radius and math.abs(playerOffset.Y) <= verticalRange)
                    or (centerHorizontal <= radius and math.abs(centerOffset.Y) <= verticalRange)
                if questMatch and inRange then
                    params.FilterDescendantsInstances = { model }
                    local result
                    if playerOffset.Magnitude > 0.05 then
                        result = workspace:Raycast(origin, playerOffset, params)
                    end
                    if not result then
                        result = workspace:Raycast(enemyPart.Position + Vector3.new(0, 12, 0), Vector3.new(0, -24, 0), params)
                    end
                    if result and result.Instance and result.Instance:IsDescendantOf(model) then
                        extraHits[#extraHits + 1] = { model, result.Instance }
                    end
                end
            end
        end
    end
    return extraHits
end

local function remoteFarmAttack(info, target, humanoid)
    if info.Category == "Gun" then return false, "Remote unsupported for Gun" end
    local hitPart
    if target then
        if target:IsA("Model") then
            hitPart = target:FindFirstChild("Head") or target:FindFirstChild("HumanoidRootPart") or target.PrimaryPart
                or target:FindFirstChildWhichIsA("BasePart", true)
        elseif target:IsA("BasePart") then
            hitPart = target
        else
            hitPart = getPart(target)
        end
    end
    if not hitPart or not hitPart:IsA("BasePart") then return false, "Hit part unavailable" end
    if info.FruitM1Remote then
        if not info.FruitM1Remote.Parent or info.FruitM1Remote.Parent ~= info.Tool then
            return false, "Fruit M1 remote unavailable"
        end
        local character, _, localRoot = getCharacter(LocalPlayer)
        if not localRoot then return false, "Character root unavailable" end
        local offset = (hitPart.Position - localRoot.Position) * Vector3.new(1, 0, 1)
        local direction
        if offset.Magnitude > 0.05 then
            direction = offset.Unit
        else
            local look = localRoot.CFrame.LookVector * Vector3.new(1, 0, 1)
            direction = look.Magnitude > 0.05 and look.Unit or Vector3.new(0, 0, -1)
        end
        if os.clock() - state.FarmLastAttack > 1 then state.FarmCombo = 0 end
        local comboCount = math.max(1, tonumber(info.FruitM1ComboCount) or math.min(3, tonumber(info.ComboCount) or 3))
        local combo = state.FarmCombo % comboCount + 1
        local rayParams = RaycastParams.new()
        rayParams.FilterType = Enum.RaycastFilterType.Exclude
        rayParams.FilterDescendantsInstances = character and { character } or {}
        rayParams.IgnoreWater = false
        local groundDistance = humanoid and (humanoid.HipHeight + localRoot.Size.Y * 0.5 + 4) or 8
        local grounded = workspace:Raycast(localRoot.Position, Vector3.new(0, -groundDistance, 0), rayParams) ~= nil
        local sent = pcall(function()
            FarmRuntime.FireRemote(info.FruitM1Remote, direction, combo, grounded)
        end)
        if not sent then return false, "Fruit M1 remote failed" end
        state.FarmCombo = combo
        local targetModel = hitPart:FindFirstAncestorOfClass("Model")
        local targetRoot = targetModel and (targetModel:FindFirstChild("HumanoidRootPart") or targetModel.PrimaryPart)
        if targetRoot and targetRoot:IsA("BasePart") and not targetRoot.Anchored then
            state.FarmFruitM1Targets[targetRoot] = {
                Until = os.clock() + 0.55,
                Position = targetRoot.Position,
                Rotation = targetRoot.CFrame - targetRoot.Position
            }
        end
        local duration = combo >= comboCount and 1.05 or 0.3
        return true, nil, math.max(Settings.FarmAttackDelay, duration)
    end
    local combo = state.FarmCombo % math.max(1, info.ComboCount) + 1
    local duration = farmAnimationDuration(info, humanoid, combo)
    if not duration then return false, "Attack animation unavailable" end
    local sent = pcall(function() FarmRuntime.FireRemote(farmRegisterAttack, duration, combo) end)
    if not sent then
        resetFarmRemoteSession()
        return false, "RegisterAttack failed"
    end
    local _, _, localRoot = getCharacter(LocalPlayer)
    local extraHits = FarmRuntime.RaycastEnemiesBelow(localRoot, hitPart)
    local selectedHitPart = hitPart
    local selectedExtraHits = extraHits
    if #extraHits > 1 then
        local hitQueue = { { hitPart:FindFirstAncestorOfClass("Model") or target, hitPart } }
        for _, pair in ipairs(extraHits) do
            if type(pair) == "table" and pair[2] and pair[2]:IsA("BasePart") then
                hitQueue[#hitQueue + 1] = pair
            end
        end
        local hitCount = #hitQueue
        local startIndex = (state.FarmRemoteHitCursor % hitCount) + 1
        local secondIndex = (startIndex % hitCount) + 1
        selectedHitPart = hitQueue[startIndex][2]
        selectedExtraHits = { hitQueue[secondIndex] }
        state.FarmRemoteHitCursor = (startIndex + 1) % hitCount
    end
    local global = FarmRuntime.FarmGlobal
    if global and type(global.SendHitsToServer) == "function" then
        local nativeSent = pcall(global.SendHitsToServer, selectedHitPart, selectedExtraHits)
        if nativeSent then
            state.FarmCombo = combo
            return true, nil, math.max(Settings.FarmAttackDelay, duration)
        end
    end
    local thread = state.FarmRemoteThread
    if state.FarmRemoteWeapon ~= info.Tool or not thread or coroutine.status(thread) ~= "suspended" then
        local created, createError = createFarmRemoteSession(info)
        if not created then return false, createError end
        thread = state.FarmRemoteThread
    end
    local resumed = coroutine.resume(thread, selectedHitPart, selectedExtraHits)
    if not resumed then
        resetFarmRemoteSession()
        return false, "RegisterHit session expired"
    end
    state.FarmCombo = combo
    return true, nil, math.max(Settings.FarmAttackDelay, duration)
end

local function validFarmTarget(target)
    local part = getPart(target)
    local humanoid = getHumanoid(target)
    return part and part:IsDescendantOf(workspace) and humanoid and humanoid.Health > 0, part, humanoid
end

FarmRuntime.ClearFarmGroup = function()
    for model, entry in pairs(state.FarmGroupMembers or {}) do
        if entry.Tween then pcall(function() entry.Tween:Cancel() end) end
        if entry.Root and entry.Root.Parent and entry.CanCollide ~= nil then
            pcall(function() entry.Root.CanCollide = entry.CanCollide end)
        end
        state.FarmGroupMembers[model] = nil
    end
    state.FarmGroupMembers = setmetatable({}, { __mode = "k" })
    state.FarmGroupDestination = nil
    state.FarmGroupTargetName = nil
    state.FarmGroupNextUpdate = 0
end

FarmRuntime.AdvanceFarmGroupTween = function(model, entry)
    if not entry or entry.Done or entry.Tween or os.clock() < (entry.PauseUntil or 0) then return end
    local valid, enemyRoot = validFarmTarget(model)
    local destination = state.FarmGroupDestination
    if not valid or not destination or enemyRoot.Anchored then return end
    local offset = destination - enemyRoot.Position
    local distance = offset.Magnitude
    if distance <= 1 then
        entry.Done = true
        if enemyRoot.Parent then pcall(function() enemyRoot.CanCollide = entry.CanCollide end) end
        return
    end
    local segmentDistance = math.min(distance, 200 * 5)
    local duration = segmentDistance / 200
    local rotation = enemyRoot.CFrame - enemyRoot.Position
    local segmentDestination = enemyRoot.Position + offset.Unit * segmentDistance
    local ok, tween = pcall(function()
        enemyRoot.CanCollide = false
        enemyRoot.AssemblyLinearVelocity = Vector3.zero
        enemyRoot.AssemblyAngularVelocity = Vector3.zero
        return TweenService:Create(enemyRoot, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
            CFrame = CFrame.new(segmentDestination) * rotation
        })
    end)
    if not ok or not tween then
        entry.PauseUntil = os.clock() + 0.2
        return
    end
    entry.Root = enemyRoot
    entry.TweenSerial = (entry.TweenSerial or 0) + 1
    local tweenSerial = entry.TweenSerial
    entry.Tween = tween
    entry.TweenDestination = destination
    local completed
    completed = tween.Completed:Connect(function(playbackState)
        if completed then completed:Disconnect() end
        if state.FarmGroupMembers[model] ~= entry or entry.TweenSerial ~= tweenSerial then return end
        entry.Tween = nil
        entry.TweenDestination = nil
        if playbackState ~= Enum.PlaybackState.Completed then return end
        if enemyRoot.Parent then
            pcall(function()
                enemyRoot.AssemblyLinearVelocity = Vector3.zero
                enemyRoot.AssemblyAngularVelocity = Vector3.zero
            end)
        end
        local remaining = enemyRoot.Parent and (destination - enemyRoot.Position).Magnitude or math.huge
        if remaining <= 1 then
            entry.Done = true
        elseif duration >= 4.99 then
            entry.PauseUntil = os.clock() + 0.2
        else
            entry.PauseUntil = 0
        end
    end)
    tween:Play()
end

FarmRuntime.NearestGroupedEnemy = function(localRoot)
    if not Settings.FarmAutoGroup or not localRoot then return nil end
    local best, bestDistance
    for model in pairs(state.FarmGroupMembers or {}) do
        local valid, enemyRoot = validFarmTarget(model)
        if valid and not isBoss(model) then
            local distance = (enemyRoot.Position - localRoot.Position).Magnitude
            if distance <= 120 and (not bestDistance or distance < bestDistance) then
                best, bestDistance = model, distance
            end
        end
    end
    return best
end

FarmRuntime.UpdateFarmGroup = function(localRoot)
    if not Settings.FarmAutoGroup or not farmAutomationActive() then
        if state.FarmGroupDestination then FarmRuntime.ClearFarmGroup() end
        return
    end
    local target = state.FarmTarget
    local targetValid, targetPart = validFarmTarget(target)
    if not targetValid or isBoss(target) then
        if state.FarmGroupDestination then FarmRuntime.ClearFarmGroup() end
        return
    end
    local targetName = normalizeEnemyName(target.Name)
    if state.FarmGroupTargetName ~= targetName then
        FarmRuntime.ClearFarmGroup()
        state.FarmGroupTargetName = targetName
    end
    state.FarmGroupDestination = targetPart.Position
    local now = os.clock()
    if now < state.FarmGroupNextUpdate then return end
    state.FarmGroupNextUpdate = now + 0.1

    for model, entry in pairs(state.FarmGroupMembers) do
        local valid, enemyRoot = validFarmTarget(model)
        if model == target or not valid then
            if entry.Tween then pcall(function() entry.Tween:Cancel() end) end
            if entry.Root and entry.Root.Parent and entry.CanCollide ~= nil then
                pcall(function() entry.Root.CanCollide = entry.CanCollide end)
            end
            state.FarmGroupMembers[model] = nil
        else
            local destination = state.FarmGroupDestination
            local distance = destination and (enemyRoot.Position - destination).Magnitude or math.huge
            if entry.Tween and entry.TweenDestination
                and (entry.TweenDestination - destination).Magnitude > 6
            then
                local oldTween = entry.Tween
                entry.TweenSerial = (entry.TweenSerial or 0) + 1
                entry.Tween = nil
                entry.TweenDestination = nil
                pcall(function() oldTween:Cancel() end)
            end
            if entry.Done and distance > 1.5 then
                entry.Done = false
                entry.PauseUntil = 0
            elseif entry.Done then
                pcall(function()
                    enemyRoot.AssemblyLinearVelocity = Vector3.zero
                    enemyRoot.AssemblyAngularVelocity = Vector3.zero
                end)
            end
            if not entry.Done and not entry.Tween and now >= (entry.PauseUntil or 0) then
                FarmRuntime.AdvanceFarmGroupTween(model, entry)
            end
        end
    end

    local enemies = workspace:FindFirstChild("Enemies")
    if not enemies then return end
    for _, model in ipairs(enemies:GetChildren()) do
        if model ~= target and model:IsA("Model") and not state.FarmGroupMembers[model]
            and not isBoss(model) and FarmRuntime.FarmGroupMatches(model, targetName)
        then
            local valid, enemyRoot = validFarmTarget(model)
            if valid and not enemyRoot.Anchored then
                local entry = {
                    Root = enemyRoot,
                    CanCollide = enemyRoot.CanCollide,
                    Tween = nil,
                    TweenDestination = nil,
                    TweenSerial = 0,
                    Done = false,
                    PauseUntil = 0
                }
                state.FarmGroupMembers[model] = entry
                FarmRuntime.AdvanceFarmGroupTween(model, entry)
            end
        end
    end
end

local function maintainFarmTargetPosition(root, target)
    local valid, part = validFarmTarget(target)
    if not valid then return false, false end
    if Settings.FarmAutoTravel or state.SpecialFarm then
        local desired = farmDesiredPosition(part)
        setFarmTravel(desired, target.Name, farmBossMode() and "farmBoss" or "farmEnemy", target)
        return true, (desired - root.Position).Magnitude <= 3.5
    end
    if isFarmTravelMode(state.TravelMode) then stopTravel() end
    local closeEnough = (part.Position - root.Position).Magnitude <= math.max(35, Settings.FarmDistance + 15)
    return true, closeEnough
end

local function observeFarmDamage(target)
    local humanoid = getHumanoid(target)
    if not humanoid then return "invalid" end
    if humanoid.Health <= 0 then return "dead" end
    if state.FarmDamageTarget ~= target or state.FarmDamageBaseline == nil then
        resetFarmDamage(target)
        return "waiting"
    end
    if humanoid.Health < state.FarmDamageBaseline - 0.01 then
        state.FarmLastDamage = state.FarmDamageBaseline - humanoid.Health
        state.FarmDamageBaseline = humanoid.Health
        state.FarmDamageAttacks = 0
        state.FarmDamageCheckAt = 0
        state.FarmNoDamageCount = 0
        setFarmWarning("")
        return "damaged"
    end
    if humanoid.Health > state.FarmDamageBaseline then state.FarmDamageBaseline = humanoid.Health end
    local requiredAttacks = state.SpecialFarm and state.SpecialFarm.SpamRemote and 8 or 3
    if state.FarmDamageAttacks >= requiredAttacks and state.FarmDamageCheckAt > 0 and os.clock() >= state.FarmDamageCheckAt then
        return "failed"
    end
    return "waiting"
end

local function beginFarmRecovery(message, countFailure)
    if countFailure then state.FarmNoDamageCount = state.FarmNoDamageCount + 1 end
    setFarmWarning(message)
    resetFarmRemoteSession()
    state.FarmTool = nil
    state.FarmWeaponInfo = nil
    state.FarmEquipAttempts = 0
    state.FarmEquipRequestedAt = 0
    state.FarmSkillBusy = false
    state.FarmSkillToken = state.FarmSkillToken + 1
    state.FarmCombo = 0
    state.FarmNextAttackAt = 0
    state.FarmCloserUntil = os.clock() + 2
    state.FarmRecoverAt = os.clock() + math.min(1.5, 0.5 + state.FarmNoDamageCount * 0.2)
    resetFarmDamage(state.FarmTarget)
    setFarmPhase("Recover", message)
end

local function resolveFarmObjective(root)
    state.FarmLevelBossActive = false
    local special = state.SpecialFarm
    if special then
        local target = special.Target
        if not validFarmTarget(target) then target = nearestFarmEnemy(root, special.Name, special.Boss == true) end
        return special.Name, special.Quest, target
    end
    if Settings.AutoWeaponGoal then
        local definition = FarmRuntime.WeaponTargets[Settings.WeaponGoal]
        if not definition or definition.Place ~= game.PlaceId then return nil end
        for _, name in ipairs(definition.Targets) do
            local target = nearestFarmEnemy(root, name, definition.Boss == true)
            if target then return normalizeEnemyName(target.Name), nil, target end
        end
        return definition.Targets[1], nil, nil
    end
    if Settings.AutoMaterial then
        local definition = FarmRuntime.MaterialTargets[Settings.MaterialGoal]
        local names = definition and definition[game.PlaceId]
        if not names then return nil end
        for _, name in ipairs(names) do
            local target = nearestFarmEnemy(root, name, false)
            if target then return normalizeEnemyName(target.Name), nil, target end
        end
        return names[1], nil, nil
    end
    if Settings.AutoBosses then
        return FarmRuntime.ResolveBossCycle(root)
    end
    local mode = Settings.FarmMode
    if mode == "Boss" then
        local target = nearestFarmEnemy(root, Settings.FarmBoss, true)
        local targetName = target and normalizeEnemyName(target.Name)
            or (Settings.FarmBoss and Settings.FarmBoss ~= "Nearest Spawned" and normalizeEnemyName(Settings.FarmBoss) or nil)
        return targetName, targetName and selectFarmQuest(targetName, true) or nil, target
    end
    local selected = Settings.FarmEnemy ~= "Auto by Level" and Settings.FarmEnemy or nil
    local quest = selectFarmQuest(selected, false)
    if mode == "Level" and Settings.FarmLevelBosses and quest then
        local bossQuest, bossTarget = spawnedBossForQuestList(root, quest)
        if bossQuest and bossTarget then
            state.FarmLevelBossActive = true
            return bossQuest.Target, bossQuest, bossTarget
        end
    end
    return selected or (quest and quest.Target), quest, nil
end

local function farmUsesQuest()
    if state.SpecialFarm then return state.SpecialFarm.UseQuest == true and state.FarmQuest ~= nil end
    if Settings.AutoMaterial or Settings.AutoWeaponGoal then return false end
    if Settings.AutoBosses then return Settings.BossUseQuest and state.FarmQuest ~= nil end
    return Settings.FarmAutoQuest and state.FarmQuest and (Settings.FarmMode ~= "Boss" or Settings.FarmBossQuest)
end

local function isFishmanQuest(entry)
    if not entry or entry.Level < 375 or entry.Level >= 450 then return false end
    return string.find(string.lower(tostring(entry.Target or "")), "fishman", 1, true) ~= nil
end

local function needsFishmanEntrance(entry, root)
    if not root or not isFishmanQuest(entry) then return false end
    local entranceDistance = (root.Position - fishmanEntrance).Magnitude
    local giver = questGiverFor(entry, root)
    if giver then
        local giverDistance = (root.Position - giver.Position).Magnitude
        -- The Fishman quest giver is in the separate Underwater City region.
        -- If it is already nearby and the outside entrance is far away, the
        -- game has completed the entrance transition and normal routing is safe.
        if giverDistance <= 5000 and entranceDistance >= 10000 then return false end
    end
    return true
end

function FarmRuntime.InsideCursedShip(root)
    return root and (root.Position - FarmRuntime.CursedShipExit).Magnitude <= 6500
end

function FarmRuntime.NeededCursedShipTransition(root)
    if game.PlaceId ~= SEA_PLACE_IDS.Second or not root or state.SpecialFarm then return nil end
    if Settings.FarmMode ~= "Level" or Settings.FarmEnemy ~= "Auto by Level" then return nil end
    local level = playerLevel()
    local inside = FarmRuntime.InsideCursedShip(root)
    if level >= 1250 and level < 1350 and not inside then return "Enter" end
    if level >= 1350 and inside then return "Exit" end
    return nil
end

local function updateAutoFarm(root)
    local now = os.clock()
    if not farmAutomationActive() then
        if state.FarmPhase ~= "Idle" or (isFarmTravelMode(state.TravelMode) and state.TravelOwner == "farm") then
            invalidateFarmRuntime("", 0)
        end
        return
    end
    local character, humanoid = getCharacter(LocalPlayer)
    if not root or not character or not humanoid or humanoid.Health <= 0 then
        clearFarmTravel()
        setFarmPhase("Recover", "Waiting for character")
        return
    end
    if now < state.FarmReadyAt then
        setFarmPhase("Recover", "Preparing character")
        return
    end
    if state.SpecialOwner and (state.TravelOwner == state.SpecialOwner or state.SpecialOwner == "AutoSaber") and not state.SpecialFarm then
        resetFarmRemoteSession()
        state.FarmTarget = nil
        setFarmPhase("Idle", state.SpecialStatus)
        return
    end
    if #state.QuestCatalog == 0 and not state.SpecialFarm and not Settings.AutoMaterial and not Settings.AutoWeaponGoal then
        setFarmWarning("Quest data unavailable")
        setFarmPhase("Recover", "Quest data unavailable")
        return
    end
    if now - state.FarmLastUpdate < 0.05 then
        return
    end
    state.FarmLastUpdate = now
    local phase = state.FarmPhase
    if phase == "Idle" then
        setFarmPhase("Resolve Quest", "Preparing farm")
        return
    end

    if phase == "Resolve Quest" then
        local targetName, quest = resolveFarmObjective(root)
        state.FarmTargetName = targetName
        state.FarmQuest = quest
        state.FarmTarget = nil
        resetFarmDamage(nil)
        if not targetName then
            clearFarmTravel()
            setFarmWarning(farmBossMode() and "Select a spawned boss" or "No eligible target")
            setFarmStatus(farmBossMode() and "Waiting for boss" or "No eligible target")
            return
        end
        local shipTransition = FarmRuntime.NeededCursedShipTransition(root)
        if shipTransition then
            state.FarmQuestGiver = nil
            state.FarmShipTransition = shipTransition
            state.FarmShipApproached = false
            state.FarmShipWaitUntil = 0
            setFarmWarning("")
            setFarmPhase("Travel Cursed Ship", shipTransition == "Enter" and "Going to Cursed Ship entrance" or "Going to Cursed Ship exit")
            return
        end
        if quest and needsFishmanEntrance(quest, root) then
            state.FarmQuestGiver = nil
            state.FarmFishmanApproached = false
            state.FarmFishmanWaitUntil = 0
            setFarmWarning("")
            setFarmPhase("Travel to Fishman", "Going to Fishman entrance")
            return
        end
        if farmUsesQuest() and not questMatches(quest) then
            local giver = questGiverFor(quest, root)
            if not giver then
                beginFarmRecovery("Quest giver unavailable", false)
                return
            end
            state.FarmQuestGiver = giver
            setFarmPhase("Travel to Quest", "Going to " .. tostring(giver.NPCName or "quest giver"))
        else
            state.FarmQuestGiver = nil
            setFarmWarning("")
            setFarmPhase("Find Enemy", "Finding " .. targetName)
        end
        return
    end

    if phase == "Travel Cursed Ship" then
        local transition = FarmRuntime.NeededCursedShipTransition(root)
        if not transition then
            clearFarmTravel()
            state.FarmShipTransition = nil
            state.FarmShipApproached = false
            state.FarmShipWaitUntil = 0
            state.FarmReadyAt = now + 0.75
            setFarmWarning("")
            setFarmPhase("Resolve Quest", "Cursed Ship transition complete")
            return
        end
        if state.FarmShipTransition ~= transition then
            clearFarmTravel()
            state.FarmShipTransition = transition
            state.FarmShipApproached = false
            state.FarmShipWaitUntil = 0
        end
        local entering = transition == "Enter"
        local destination = entering and FarmRuntime.CursedShipEntrance or FarmRuntime.CursedShipExit
        local action = entering and "Entering Cursed Ship" or "Leaving Cursed Ship"
        local travelName = entering and "Cursed Ship entrance" or "Cursed Ship exit"
        local portalDistance = (root.Position - destination).Magnitude
        if state.FarmShipApproached then
            clearFarmTravel()
            if now >= state.FarmShipWaitUntil then
                state.FarmShipApproached = false
                state.FarmShipWaitUntil = 0
                setFarmWarning(travelName .. " is not responding")
                setFarmStatus("Retrying " .. travelName)
            else
                setFarmStatus(action)
            end
        elseif portalDistance <= 2 then
            state.FarmShipApproached = true
            state.FarmShipWaitUntil = now + 8
            setFarmWarning("")
            clearFarmTravel()
            setFarmStatus(action)
        elseif not Settings.FarmAutoTravel then
            clearFarmTravel()
            setFarmWarning("Auto Travel is disabled")
            setFarmStatus(travelName .. " is out of range")
        else
            setFarmTravel(destination, travelName, "farmTransition", state.FarmQuest)
            setFarmStatus("Going to " .. travelName)
        end
        return
    end

    if phase == "Travel to Fishman" then
        local entry = state.FarmQuest
        if not entry or not isFishmanQuest(entry) then
            clearFarmTravel()
            state.FarmFishmanApproached = false
            state.FarmFishmanWaitUntil = 0
            setFarmPhase("Resolve Quest", "Refreshing quest")
            return
        end
        if not needsFishmanEntrance(entry, root) then
            clearFarmTravel()
            state.FarmFishmanApproached = false
            state.FarmFishmanWaitUntil = 0
            state.FarmReadyAt = now + 0.75
            setFarmWarning("")
            setFarmPhase("Resolve Quest", "Entering Fishman area")
            return
        end
        local entranceDistance = (root.Position - fishmanEntrance).Magnitude
        if state.FarmFishmanApproached then
            clearFarmTravel()
            if now >= state.FarmFishmanWaitUntil then
                state.FarmFishmanApproached = false
                state.FarmFishmanWaitUntil = 0
                setFarmWarning("Fishman entrance is not responding")
                setFarmStatus("Retrying Fishman entrance")
            else
                setFarmStatus("Entering Fishman area")
            end
        elseif entranceDistance <= 2 then
            state.FarmFishmanApproached = true
            state.FarmFishmanWaitUntil = now + 6
            setFarmWarning("")
            clearFarmTravel()
            setFarmStatus("Entering Fishman area")
        elseif not Settings.FarmAutoTravel and not state.SpecialFarm then
            clearFarmTravel()
            setFarmWarning("Auto Travel is disabled")
            setFarmStatus("Fishman entrance is out of range")
        else
            setFarmTravel(fishmanEntrance, "Fishman entrance", "farmTransition", entry)
            setFarmStatus("Going to Fishman entrance")
        end
        return
    end

    if phase == "Travel to Quest" then
        local giver = state.FarmQuestGiver
        local entry = state.FarmQuest
        if not giver or not entry then setFarmPhase("Resolve Quest", "Refreshing quest"); return end
        local destination = giver.Position + Vector3.new(0, 3, 0)
        if (destination - root.Position).Magnitude <= 9 then
            clearFarmTravel()
            local snapshot = currentQuestSnapshot()
            setFarmPhase(snapshot.Active and not questMatches(entry, snapshot) and "Request Abandon" or "Request Quest", "Requesting " .. entry.Name)
        elseif not Settings.FarmAutoTravel and not state.SpecialFarm then
            setFarmWarning("Auto Travel is disabled")
            setFarmStatus("Quest giver is out of range")
        else
            setFarmTravel(destination, giver.NPCName or "Quest Giver", "farmQuest", entry)
        end
        return
    end

    if phase == "Request Abandon" then
        if beginFarmQuestRequest("Abandon", state.FarmQuest) then
            setFarmPhase("Confirm Abandon", "Abandoning old quest")
        end
        return
    end

    if phase == "Confirm Abandon" then
        local request = state.FarmQuestRequest
        if not currentQuestSnapshot().Active then
            cancelFarmQuestRequest()
            setFarmPhase("Request Quest", "Requesting " .. tostring(state.FarmQuest and state.FarmQuest.Name or "quest"))
        elseif not request or now >= request.Deadline then
            cancelFarmQuestRequest()
            beginFarmRecovery("Quest abandon timed out", false)
        elseif request.Done and not request.Ok then
            cancelFarmQuestRequest()
            beginFarmRecovery("Quest abandon failed", false)
        end
        return
    end

    if phase == "Request Quest" then
        if not state.FarmQuest then setFarmPhase("Resolve Quest", "Refreshing quest"); return end
        if beginFarmQuestRequest("Start", state.FarmQuest) then
            setFarmPhase("Confirm Quest", "Confirming " .. state.FarmQuest.Name)
        end
        return
    end

    if phase == "Confirm Quest" then
        local request = state.FarmQuestRequest
        if questMatches(state.FarmQuest) then
            cancelFarmQuestRequest()
            setFarmWarning("")
            setFarmPhase("Find Enemy", "Finding " .. tostring(state.FarmTargetName))
        elseif not request or now >= request.Deadline then
            cancelFarmQuestRequest()
            beginFarmRecovery("Quest confirmation timed out", false)
        elseif request.Done and not request.Ok then
            cancelFarmQuestRequest()
            beginFarmRecovery("Quest request failed", false)
        end
        return
    end

    if phase == "Find Enemy" then
        if farmUsesQuest() then
            local snapshot = currentQuestSnapshot()
            if questComplete(snapshot) or not questMatches(state.FarmQuest, snapshot) then
                setFarmPhase("Resolve Quest", "Refreshing quest")
                return
            end
        end
        local forcedTarget = state.SpecialFarm and state.SpecialFarm.Target or nil
        local forcedValid = forcedTarget and validFarmTarget(forcedTarget)
        local target = forcedValid and forcedTarget or nearestFarmEnemy(root, state.FarmTargetName, farmBossMode())
        if target then
            state.FarmTarget = target
            resetFarmDamage(target)
            setFarmPhase("Travel to Target", "Going to " .. normalizeEnemyName(target.Name))
            return
        end
        if state.FarmLevelBossActive then
            state.FarmLevelBossActive = false
            setFarmPhase("Resolve Quest", "Boss unavailable; resuming levels")
            return
        end
        local spawn = nearestEnemySpawn(root, state.FarmTargetName)
        if spawn and (spawn.Position + Vector3.new(0, 6, 0) - root.Position).Magnitude > 12 then
            state.FarmQuestGiver = spawn
            setFarmPhase("Travel to Spawn", "Going to " .. state.FarmTargetName)
        else
            clearFarmTravel()
            setFarmPhase("Wait for Enemy", "Waiting for " .. state.FarmTargetName)
        end
        return
    end

    if phase == "Travel to Spawn" then
        local target = nearestFarmEnemy(root, state.FarmTargetName, farmBossMode())
        if target then
            state.FarmTarget = target
            resetFarmDamage(target)
            setFarmPhase("Travel to Target", "Going to " .. normalizeEnemyName(target.Name))
            return
        end
        local spawn = state.FarmQuestGiver
        if not spawn or not spawn.Parent then setFarmPhase("Find Enemy", "Refreshing enemy spawn"); return end
        local destination = spawn.Position + Vector3.new(0, 6, 0)
        if (destination - root.Position).Magnitude <= 12 then
            clearFarmTravel()
            setFarmPhase("Wait for Enemy", "Waiting for " .. state.FarmTargetName)
        elseif not Settings.FarmAutoTravel and not state.SpecialFarm then
            setFarmWarning("Auto Travel is disabled")
            setFarmStatus("Enemy spawn is out of range")
        else
            setFarmTravel(destination, state.FarmTargetName .. " spawn", "farmSpawn", spawn)
        end
        return
    end

    if phase == "Wait for Enemy" then
        if farmUsesQuest() and not questMatches(state.FarmQuest) then setFarmPhase("Resolve Quest", "Refreshing quest"); return end
        local target = nearestFarmEnemy(root, state.FarmTargetName, farmBossMode())
        if target then
            state.BossNextHopAt = 0
            state.FarmTarget = target
            resetFarmDamage(target)
            setFarmPhase("Travel to Target", "Going to " .. normalizeEnemyName(target.Name))
        elseif Settings.AutoBosses and Settings.BossAutoHop and FarmRuntime.ServerHop then
            if state.BossNextHopAt <= 0 then
                state.BossNextHopAt = now + math.max(10, tonumber(Settings.BossHopDelay) or 30)
                setFarmStatus("Waiting for " .. tostring(state.FarmTargetName))
            elseif now >= state.BossNextHopAt then
                state.BossNextHopAt = now + math.max(10, tonumber(Settings.BossHopDelay) or 30)
                showNotice("Searching another server for a boss", nil, 4)
                FarmRuntime.ServerHop(true)
            end
        end
        return
    end

    local targetValid, targetPart, targetHumanoid = validFarmTarget(state.FarmTarget)
    if not targetValid then
        local finishedTarget = state.FarmTarget
        state.FarmTarget = nil
        resetFarmDamage(nil)
        clearFarmTravel()
        if not state.SpecialFarm and not isBoss(finishedTarget) then
            local groupedTarget = FarmRuntime.NearestGroupedEnemy(root)
            if groupedTarget then
                state.FarmTarget = groupedTarget
                resetFarmDamage(groupedTarget)
                setFarmPhase("Travel to Target", "Clearing nearby " .. normalizeEnemyName(groupedTarget.Name))
                return
            end
        end
        setFarmPhase("Resolve Quest", "Target changed")
        return
    end

    if phase == "Travel to Target" then
        local _, arrived = maintainFarmTargetPosition(root, state.FarmTarget)
        if not arrived and state.SpecialFarm
            and (state.SpecialOwner == "RaidAutoClear" or state.SpecialFarm.SpamRemote)
            and Settings.FarmAttackMethod == "Remote" and now >= state.FarmNextAttackAt
        then
            local movingInfo = state.FarmWeaponInfo
            if not movingInfo or not movingInfo.Tool or not ownsFarmTool(movingInfo.Tool) then
                movingInfo = resolveFarmWeapon(farmRequestedCategory())
                if movingInfo and movingInfo.Category ~= "Gun" then
                    state.FarmTool = movingInfo.Tool
                    state.FarmWeaponInfo = movingInfo
                    state.FarmEquipAttempts = 0
                    state.FarmCombo = 0
                else
                    movingInfo = nil
                end
            end
            if movingInfo and not movingInfo.SkillOnly then
                if movingInfo.Tool.Parent ~= character then
                    pcall(function() humanoid:EquipTool(movingInfo.Tool) end)
                    state.FarmNextAttackAt = now + 0.2
                    setFarmStatus("Equipping while moving to " .. normalizeEnemyName(state.FarmTarget.Name))
                elseif FarmRuntime.WeaponReady(movingInfo, character) then
                    local attacked = remoteFarmAttack(movingInfo, state.FarmTarget, humanoid)
                    if attacked then
                        state.FarmLastAttack = now
                        state.FarmNextAttackAt = now + math.max(0.05, Settings.FarmAttackDelay)
                        setFarmStatus("Attacking while moving to " .. normalizeEnemyName(state.FarmTarget.Name))
                    else
                        state.FarmNextAttackAt = now + 0.15
                    end
                end
            end
        end
        if arrived then
            setFarmWarning("")
            local info = state.FarmWeaponInfo
            if info and ownsFarmTool(info.Tool) and FarmRuntime.WeaponReady(info, character) then
                setFarmPhase("Attack", "Attacking " .. normalizeEnemyName(state.FarmTarget.Name))
            else
                setFarmPhase("Resolve Weapon", "Selecting weapon")
            end
        elseif not Settings.FarmAutoTravel and not state.SpecialFarm then
            setFarmWarning("Auto Travel is disabled")
            setFarmStatus("Target is out of range")
        end
        return
    end

    if phase == "Resolve Weapon" then
        local _, arrived = maintainFarmTargetPosition(root, state.FarmTarget)
        if not arrived then setFarmPhase("Travel to Target", "Repositioning"); return end
        local info, reason = resolveFarmWeapon(farmRequestedCategory())
        if not info then
            beginFarmRecovery(reason or "No matching weapon", false)
            return
        end
        if Settings.FarmAttackMethod == "Remote" and info.Category == "Gun" then
            beginFarmRecovery("Remote unsupported for Gun", false)
            return
        end
        if Settings.AutoFarm and not Settings.AutoMaterial and not Settings.AutoWeaponGoal and not state.SpecialFarm
            and Settings.FarmMode == "Mastery" and info.Mastery >= Settings.FarmMasteryGoal then
            stopAutoFarm(info.Category .. " mastery goal reached")
            return
        end
        if state.FarmRemoteWeapon and state.FarmRemoteWeapon ~= info.Tool then resetFarmRemoteSession() end
        state.FarmTool = info.Tool
        state.FarmWeaponInfo = info
        state.FarmEquipAttempts = 0
        state.FarmEquipRequestedAt = 0
        state.FarmCombo = 0
        setFarmWarning("")
        setFarmPhase("Equip Weapon", "Equipping " .. info.DisplayName)
        return
    end

    if phase == "Equip Weapon" then
        maintainFarmTargetPosition(root, state.FarmTarget)
        local info, reason = weaponDescriptor(state.FarmTool)
        if not info or not ownsFarmTool(state.FarmTool) then
            state.FarmTool = nil
            state.FarmWeaponInfo = nil
            setFarmPhase("Resolve Weapon", reason or "Weapon changed")
            return
        end
        state.FarmWeaponInfo = info
        if FarmRuntime.WeaponReady(info, character) then
            resetFarmDamage(state.FarmTarget)
            state.FarmNextAttackAt = now
            setFarmWarning("")
            setFarmPhase("Attack", "Attacking " .. normalizeEnemyName(state.FarmTarget.Name))
            return
        end
        if state.FarmEquipAttempts == 0 or now - state.FarmEquipRequestedAt >= 0.75 then
            if state.FarmEquipAttempts >= 2 then
                beginFarmRecovery("Equip timed out", false)
                return
            end
            state.FarmEquipAttempts = state.FarmEquipAttempts + 1
            state.FarmEquipRequestedAt = now
            local equipped = pcall(function() humanoid:EquipTool(info.Tool) end)
            if not equipped and state.FarmEquipAttempts >= 2 then beginFarmRecovery("Equip failed", false) end
        end
        return
    end

    if phase == "Attack" then
        local _, arrived = maintainFarmTargetPosition(root, state.FarmTarget)
        if not arrived and Settings.FarmPosition ~= "Square" then
            setFarmPhase("Travel to Target", "Repositioning")
            return
        end
        local info, reason = weaponDescriptor(state.FarmTool)
        if not info or not FarmRuntime.WeaponReady(info, character) then
            setFarmPhase("Equip Weapon", reason or "Re-equipping weapon")
            return
        end
        state.FarmWeaponInfo = info
        local requestedCategory = farmRequestedCategory()
        if requestedCategory ~= "Auto" and info.Category ~= requestedCategory then
            resetFarmRemoteSession()
            state.FarmTool = nil
            setFarmPhase("Resolve Weapon", "Switching to " .. requestedCategory)
            return
        end
        if Settings.AutoFarm and not Settings.AutoMaterial and not Settings.AutoWeaponGoal and not state.SpecialFarm
            and Settings.FarmMode == "Mastery" and info.Mastery >= Settings.FarmMasteryGoal then
            stopAutoFarm(info.Category .. " mastery goal reached")
            return
        end
        local damageState = observeFarmDamage(state.FarmTarget)
        if damageState == "dead" or damageState == "invalid" then setFarmPhase("Resolve Quest", "Target defeated"); return end
        if damageState == "failed" then resetFarmDamage(state.FarmTarget) end
        local spamRemote = state.SpecialFarm and state.SpecialFarm.SpamRemote
        if now < state.FarmNextAttackAt then return end
        local attacked, attackError, duration
        if info.SkillOnly and info.Category == "Blox Fruit" then
            attacked, attackError, duration = FarmRuntime.MasterySkills.Cast(info, state.FarmTarget)
        elseif Settings.FarmAttackMethod == "Remote" then
            attacked, attackError, duration = remoteFarmAttack(info, state.FarmTarget, humanoid)
        else
            attacked, attackError, duration = clickFarmAttack(info, state.FarmTarget)
        end
        if attacked == nil then return end
        if not attacked then
            beginFarmRecovery(attackError or "Attack failed", false)
            return
        end
        state.FarmLastAttack = now
        if Settings.FarmAttackMethod == "Remote" and spamRemote and not info.FruitM1Remote then
            state.FarmNextAttackAt = now + math.max(0.03, Settings.FarmAttackDelay)
        else
            state.FarmNextAttackAt = now + math.max(Settings.FarmAttackDelay, tonumber(duration) or 0.05)
        end
        if state.FarmDamageAttacks == 0 then
            state.FarmDamageBaseline = targetHumanoid.Health
            state.FarmDamageCheckAt = now + 1.25
        end
        state.FarmDamageAttacks = state.FarmDamageAttacks + 1
        setFarmStatus("Attacking " .. normalizeEnemyName(state.FarmTarget.Name))
        return
    end

    if phase == "Recover" then
        maintainFarmTargetPosition(root, state.FarmTarget)
        if now >= state.FarmRecoverAt then setFarmPhase("Resolve Weapon", "Retrying attack") end
        return
    end

    setFarmPhase("Resolve Quest", "Refreshing farm")
end

local sea2FallbackLocations = {
    Prison = Vector3.new(5277.79, -13.78, 743.14),
    ["Frozen Village"] = Vector3.new(1276.79, -13.78, -1472.86),
    ["Middle Town"] = Vector3.new(-826.45, -3.78, 1613.27)
}
local iceAdmiralDoor = Vector3.new(1347.71, 37.38, -1325.65)

local function setSea2Phase(phase, delay)
    if state.Sea2Phase ~= phase then
        state.Sea2Phase = phase
        state.Sea2PhaseAt = os.clock()
    end
    state.Sea2ReadyAt = os.clock() + (tonumber(delay) or 0)
end

local function cancelSea2Request()
    state.Sea2RequestId = state.Sea2RequestId + 1
    state.Sea2Request = nil
end

local function resetSea2Combat()
    resetFarmRemoteSession()
    state.FarmGeneration = state.FarmGeneration + 1
    state.FarmClickSerial = state.FarmClickSerial + 1
    state.FarmClickRequest = nil
    state.FarmCombo = 0
    state.Sea2Target = nil
    state.Sea2Tool = nil
    state.Sea2WeaponInfo = nil
    state.Sea2EquipAttempts = 0
    state.Sea2EquipRequestedAt = 0
    state.Sea2NextAttackAt = 0
    state.Sea2DamageBaseline = nil
    state.Sea2DamageAttacks = 0
    state.Sea2DamageCheckAt = 0
end

local function clearSea2Travel()
    if state.TravelOwner == "sea2" then stopTravel() end
end

local function invalidateSea2Runtime(readyDelay)
    state.Sea2Generation = state.Sea2Generation + 1
    cancelSea2Request()
    resetSea2Combat()
    clearSea2Travel()
    state.Sea2RetryCount = 0
    state.Sea2NoDamageCount = 0
    state.Sea2DoorTouchedAt = 0
    state.Sea2BossWaitAt = 0
    state.Sea2LastUpdate = 0
    setSea2Phase(Settings.AutoSea2 and "Check" or "Idle", readyDelay)
end

local function stopAutoSea2(message)
    Settings.AutoSea2 = false
    invalidateSea2Runtime(0)
    if AutoSea2Control and AutoSea2Control.Set then
        pcall(function() AutoSea2Control:Set(false) end)
    end
    if message then showNotice(message, nil, 5) end
end

local function beginSea2Request(action)
    if state.Sea2Request then return state.Sea2Request end
    state.Sea2RequestId = state.Sea2RequestId + 1
    local requestId = state.Sea2RequestId
    local generation = state.Sea2Generation
    local request = {
        Action = action,
        Deadline = os.clock() + 8,
        Done = false,
        Ok = false,
        Result = nil
    }
    state.Sea2Request = request
    task.spawn(function()
        local ok, result = pcall(function()
            if action == "Detective" then
                return CommF:InvokeServer("DressrosaQuestProgress", "Detective")
            end
            if action == "Dressrosa" then
                return CommF:InvokeServer("DressrosaQuestProgress", "Dressrosa")
            end
            if action == "TravelDressrosa" then
                return CommF:InvokeServer("TravelDressrosa")
            end
            error("Unknown Sea 2 request")
        end)
        if state.Alive and state.Sea2Generation == generation and state.Sea2RequestId == requestId then
            request.Done = true
            request.Ok = ok
            request.Result = result
        end
    end)
    return request
end

local function pollSea2Request(action)
    local request = state.Sea2Request
    if request and request.Action ~= action then
        cancelSea2Request()
        request = nil
    end
    if not request then
        beginSea2Request(action)
        return "pending"
    end
    if not request.Done and os.clock() < request.Deadline then return "pending" end
    local ok = request.Done and request.Ok
    local result = request.Result
    cancelSea2Request()
    return ok and "done" or "failed", result
end

local function sea2Location(name)
    local locations = workspace:FindFirstChild("_WorldOrigin")
    locations = locations and locations:FindFirstChild("Locations")
    if locations then
        for _, instance in ipairs(locations:GetChildren()) do
            if instance.Name == name and instance:IsA("BasePart") then return instance.Position end
        end
    end
    return sea2FallbackLocations[name]
end

local function findSpecialNpc(name)
    local folder = workspace:FindFirstChild("NPCs")
    if not folder then return nil end
    local wanted = string.lower(name)
    for _, npc in ipairs(folder:GetChildren()) do
        if string.lower(npc.Name) == wanted and getPart(npc) then return npc end
    end
    return nil
end

local function findOwnedTool(name)
    local wanted = string.lower(name)
    for _, container in ipairs({ LocalPlayer.Character, LocalPlayer:FindFirstChildOfClass("Backpack") }) do
        if container then
            for _, tool in ipairs(container:GetChildren()) do
                if tool:IsA("Tool") and string.lower(tool.Name) == wanted then return tool end
            end
        end
    end
    return nil
end

FarmRuntime.MaterialCount = function(name)
    local ok, count = pcall(function()
        FarmRuntime.MaterialIds = FarmRuntime.MaterialIds or {}
        local itemId = FarmRuntime.MaterialIds[name]
        if not itemId then
            local itemIds = require(ReplicatedStorage.Economy.ItemId)
            itemId = itemIds.getId(name, "Material"):unwrap()
            FarmRuntime.MaterialIds[name] = itemId
        end
        local replication = require(ReplicatedStorage.Util.ItemReplication)
        return tonumber(replication.Quantity.readClient(itemId)) or 0
    end)
    return ok and count or nil
end

local function setSea2Travel(position, name, mode, object)
    if typeof(position) ~= "Vector3" then return false end
    mode = mode or "farmSea2"
    if state.TravelMode ~= mode or state.TravelObject ~= object or state.TravelOwner ~= "sea2" then
        state.TravelBudget = 0
        state.TravelSerial = state.TravelSerial + 1
    end
    state.TravelTarget = position
    state.TravelName = name or "Sea 2 quest"
    state.TravelMode = mode
    state.TravelObject = object
    state.TravelOwner = "sea2"
    return true
end

local function travelSea2Safely(root, destination, name, arrivalRadius, mode, object)
    if not root or typeof(destination) ~= "Vector3" then return false end
    arrivalRadius = tonumber(arrivalRadius) or 7
    if (destination - root.Position).Magnitude <= arrivalRadius then
        clearSea2Travel()
        return true
    end
    local flatOffset = Vector3.new(destination.X - root.Position.X, 0, destination.Z - root.Position.Z)
    local cruiseY = math.max(90, destination.Y + 55)
    local waypoint
    if flatOffset.Magnitude > 30 then
        if root.Position.Y < cruiseY - 2 then
            waypoint = Vector3.new(root.Position.X, cruiseY, root.Position.Z)
        else
            waypoint = Vector3.new(destination.X, cruiseY, destination.Z)
        end
    else
        waypoint = destination
    end
    setSea2Travel(waypoint, name, mode, object)
    return false
end

local function travelToSea2Npc(root, islandName, npcName)
    local npc = findSpecialNpc(npcName)
    if npc then
        local part = getPart(npc)
        return travelSea2Safely(root, part.Position + Vector3.new(0, 3, 0), npcName, 8, "farmSea2", npc)
    end
    local island = sea2Location(islandName)
    if not island then return false end
    local arrived = travelSea2Safely(root, island + Vector3.new(0, 80, 0), islandName, 8, "farmSea2", islandName)
    return arrived and os.clock() - state.Sea2PhaseAt >= 2
end

local function findIceAdmiral()
    local folder = workspace:FindFirstChild("Enemies")
    if not folder then return nil end
    for _, enemy in ipairs(folder:GetChildren()) do
        if normalizeEnemyName(enemy.Name) == "Ice Admiral" then
            local humanoid = getHumanoid(enemy)
            if humanoid and humanoid.Health > 0 and getPart(enemy) then return enemy end
        end
    end
    return nil
end

local function iceAdmiralSpawn(root)
    if not state.EnemySpawns["Ice Admiral"] then refreshEnemySpawns() end
    return nearestEnemySpawn(root, "Ice Admiral")
end

local function touchIceAdmiralDoor(root, key)
    local keyPart = getPart(key) or root
    for _, instance in ipairs(workspace:GetDescendants()) do
        if instance:IsA("BasePart") and (instance.Position - iceAdmiralDoor).Magnitude <= 22 then
            local lowered = string.lower(instance.Name .. " " .. (instance.Parent and instance.Parent.Name or ""))
            if (instance.Position - root.Position).Magnitude <= 7 or string.find(lowered, "door", 1, true) or string.find(lowered, "gate", 1, true) then
                touchTravelObject(root, instance)
                if keyPart ~= root then touchTravelObject(keyPart, instance) end
            end
        end
    end
end

local function resolveSea2Weapon()
    local info, reason = resolveFarmWeapon("Auto")
    if info and Settings.FarmAttackMethod == "Remote" and info.Category == "Gun" then
        info = nil
        for _, category in ipairs({ "Melee", "Sword", "Blox Fruit" }) do
            info = resolveFarmWeapon(category)
            if info then break end
        end
        if not info then reason = "Remote attack needs a non-gun weapon" end
    end
    return info, reason
end

local function maintainSea2BossPosition(root, target)
    local valid, part = validFarmTarget(target)
    if not valid then return false, false end
    local distance = math.clamp(Settings.FarmDistance, 5, 50)
    local desired = part.Position + Vector3.new(0, distance, 0)
    setSea2Travel(desired, "Ice Admiral", "farmBoss", target)
    return true, (desired - root.Position).Magnitude <= 3.5
end

local function retrySea2Combat(message)
    resetFarmRemoteSession()
    state.Sea2Tool = nil
    state.Sea2WeaponInfo = nil
    state.Sea2EquipAttempts = 0
    state.Sea2EquipRequestedAt = 0
    state.Sea2NextAttackAt = 0
    state.Sea2DamageAttacks = 0
    state.Sea2DamageCheckAt = 0
    state.Sea2NoDamageCount = state.Sea2NoDamageCount + 1
    setSea2Phase("BossEquip", math.min(2, 0.5 + state.Sea2NoDamageCount * 0.25))
    if state.Sea2NoDamageCount == 3 then showNotice(message or "Retrying Ice Admiral", Red, 4) end
end

local function updateAutoSea2(root)
    if not Settings.AutoSea2 then
        if state.Sea2Phase ~= "Idle" then invalidateSea2Runtime(0) end
        return
    end
    if game.PlaceId ~= SEA_PLACE_IDS.First then
        stopAutoSea2("Second Sea is already unlocked")
        return
    end
    if playerLevel() < 700 then
        clearSea2Travel()
        setSea2Phase("Check", 1)
        return
    end
    local character, humanoid = getCharacter(LocalPlayer)
    if not root or not character or not humanoid then
        clearSea2Travel()
        setSea2Phase("Check", 1)
        return
    end
    local now = os.clock()
    if now < state.Sea2ReadyAt or now - state.Sea2LastUpdate < 0.05 then return end
    state.Sea2LastUpdate = now
    local phase = state.Sea2Phase

    if phase == "Idle" or phase == "Check" then
        if findOwnedTool("Key") then
            setSea2Phase("TravelFrozen")
        else
            setSea2Phase("TravelPrison")
        end
        return
    end

    if phase == "TravelPrison" then
        if travelToSea2Npc(root, "Prison", "Military Detective") then
            clearSea2Travel()
            setSea2Phase("AcceptDetective")
        end
        return
    end

    if phase == "AcceptDetective" then
        local requestState, result = pollSea2Request("Detective")
        if requestState == "pending" then return end
        if requestState == "failed" then
            state.Sea2RetryCount = state.Sea2RetryCount + 1
            if state.Sea2RetryCount >= 4 then
                stopAutoSea2("Could not accept the Sea 2 quest")
            else
                setSea2Phase("AcceptDetective", 1.5)
            end
        else
            state.Sea2RetryCount = 0
            local progress = tonumber(result)
            if progress == 2 then
                setSea2Phase("TravelCaptain")
            elseif progress == 0 or progress == 1 then
                setSea2Phase("ConfirmKey", 0.5)
            else
                stopAutoSea2("Sea 2 quest is unavailable")
            end
        end
        return
    end

    if phase == "ConfirmKey" then
        if findOwnedTool("Key") then
            setSea2Phase("TravelFrozen")
        elseif now - state.Sea2PhaseAt >= 5 then
            state.Sea2RetryCount = state.Sea2RetryCount + 1
            if state.Sea2RetryCount >= 4 then
                stopAutoSea2("The Military Detective did not give the Key")
            else
                setSea2Phase("TravelPrison", 1)
            end
        end
        return
    end

    if phase == "TravelFrozen" then
        local location = sea2Location("Frozen Village")
        if location and travelSea2Safely(root, location + Vector3.new(0, 80, 0), "Frozen Village", 8, "farmSea2", "Frozen Village") then
            clearSea2Travel()
            setSea2Phase("UnlockDoor")
        end
        return
    end

    if phase == "UnlockDoor" then
        local key = findOwnedTool("Key")
        if not key then
            setSea2Phase("FindBoss")
            return
        end
        if key.Parent ~= character then pcall(function() humanoid:EquipTool(key) end) end
        if travelSea2Safely(root, iceAdmiralDoor, "Ice Admiral door", 3.5, "farmSea2", key) then
            touchIceAdmiralDoor(root, key)
            state.Sea2DoorTouchedAt = now
            setSea2Phase("WaitDoor", 1.25)
        end
        return
    end

    if phase == "WaitDoor" then
        if now >= state.Sea2ReadyAt then setSea2Phase("FindBoss") end
        return
    end

    if phase == "FindBoss" then
        local target = findIceAdmiral()
        if target then
            state.Sea2Target = target
            state.Sea2NoDamageCount = 0
            setSea2Phase("BossTravel")
            return
        end
        local spawn = iceAdmiralSpawn(root)
        local destination = spawn and (spawn.Position + Vector3.new(0, 6, 0)) or (sea2Location("Frozen Village") + Vector3.new(0, 30, 0))
        if travelSea2Safely(root, destination, "Ice Admiral spawn", 9, "farmSea2", spawn or "Ice Admiral") then
            clearSea2Travel()
            state.Sea2BossWaitAt = now
            setSea2Phase("WaitBoss")
        end
        return
    end

    if phase == "WaitBoss" then
        local target = findIceAdmiral()
        if target then
            state.Sea2Target = target
            setSea2Phase("BossTravel")
        elseif findOwnedTool("Key") and now - state.Sea2BossWaitAt >= 8 then
            setSea2Phase("UnlockDoor")
        end
        return
    end

    if phase == "BossTravel" then
        local valid, arrived = maintainSea2BossPosition(root, state.Sea2Target)
        if not valid then
            setSea2Phase("VerifyBoss", 0.75)
        elseif arrived then
            setSea2Phase("BossEquip")
        end
        return
    end

    if phase == "BossEquip" then
        local valid = maintainSea2BossPosition(root, state.Sea2Target)
        if not valid then setSea2Phase("VerifyBoss", 0.75); return end
        local info, reason = resolveSea2Weapon()
        if not info then
            state.Sea2RetryCount = state.Sea2RetryCount + 1
            if state.Sea2RetryCount >= 5 then stopAutoSea2(reason or "No usable weapon"); return end
            setSea2Phase("BossEquip", 1)
            return
        end
        state.Sea2Tool = info.Tool
        state.Sea2WeaponInfo = info
        if info.Tool.Parent == character and info.Pointer and info.Pointer.Value ~= nil then
            local targetHumanoid = getHumanoid(state.Sea2Target)
            state.Sea2DamageBaseline = targetHumanoid and targetHumanoid.Health or nil
            state.Sea2DamageAttacks = 0
            state.Sea2DamageCheckAt = 0
            state.Sea2NextAttackAt = now
            state.Sea2RetryCount = 0
            setSea2Phase("BossAttack")
            return
        end
        if state.Sea2EquipAttempts == 0 or now - state.Sea2EquipRequestedAt >= 0.75 then
            state.Sea2EquipAttempts = state.Sea2EquipAttempts + 1
            state.Sea2EquipRequestedAt = now
            pcall(function() humanoid:EquipTool(info.Tool) end)
            if state.Sea2EquipAttempts >= 3 then retrySea2Combat("Could not equip a weapon") end
        end
        return
    end

    if phase == "BossAttack" then
        local valid, _, targetHumanoid = validFarmTarget(state.Sea2Target)
        if not valid or not targetHumanoid or targetHumanoid.Health <= 0 then
            setSea2Phase("VerifyBoss", 0.75)
            return
        end
        maintainSea2BossPosition(root, state.Sea2Target)
        local info, reason = weaponDescriptor(state.Sea2Tool)
        if not info or info.Tool.Parent ~= character or not info.Pointer or info.Pointer.Value == nil then
            retrySea2Combat(reason or "Weapon became unavailable")
            return
        end
        if state.Sea2DamageBaseline and targetHumanoid.Health < state.Sea2DamageBaseline - 0.01 then
            state.Sea2DamageBaseline = targetHumanoid.Health
            state.Sea2DamageAttacks = 0
            state.Sea2DamageCheckAt = 0
            state.Sea2NoDamageCount = 0
        elseif state.Sea2DamageAttacks >= 3 and state.Sea2DamageCheckAt > 0 and now >= state.Sea2DamageCheckAt then
            retrySea2Combat("Retrying Ice Admiral")
            return
        end
        if now < state.Sea2NextAttackAt then return end
        local attacked, attackError, duration
        if Settings.FarmAttackMethod == "Remote" then
            attacked, attackError, duration = remoteFarmAttack(info, state.Sea2Target, humanoid)
        else
            attacked, attackError, duration = clickFarmAttack(info, state.Sea2Target)
        end
        if attacked == nil then return end
        if not attacked then retrySea2Combat(attackError or "Attack failed"); return end
        if state.Sea2DamageAttacks == 0 then
            state.Sea2DamageBaseline = targetHumanoid.Health
            state.Sea2DamageCheckAt = now + 1.25
        end
        state.Sea2DamageAttacks = state.Sea2DamageAttacks + 1
        state.Sea2NextAttackAt = now + math.max(Settings.FarmAttackDelay, tonumber(duration) or 0.05)
        return
    end

    if phase == "VerifyBoss" then
        if now < state.Sea2ReadyAt then return end
        resetSea2Combat()
        setSea2Phase("ReturnPrison")
        return
    end

    if phase == "ReturnPrison" then
        if travelToSea2Npc(root, "Prison", "Military Detective") then
            clearSea2Travel()
            setSea2Phase("ConfirmDetective")
        end
        return
    end

    if phase == "ConfirmDetective" then
        local requestState, result = pollSea2Request("Detective")
        if requestState == "pending" then return end
        if requestState == "failed" then
            setSea2Phase("ConfirmDetective", 1.5)
            return
        end
        local progress = tonumber(result)
        if progress == 2 then
            setSea2Phase("TravelCaptain")
        elseif progress == 1 then
            setSea2Phase("FindBoss")
        elseif progress == 0 then
            setSea2Phase("ConfirmKey", 0.5)
        else
            stopAutoSea2("Could not confirm the Ice Admiral quest")
        end
        return
    end

    if phase == "TravelCaptain" then
        if travelToSea2Npc(root, "Middle Town", "Experienced Captain") then
            clearSea2Travel()
            setSea2Phase("CheckCaptain")
        end
        return
    end

    if phase == "CheckCaptain" then
        local requestState, result = pollSea2Request("Dressrosa")
        if requestState == "pending" then return end
        if requestState == "failed" then
            state.Sea2RetryCount = state.Sea2RetryCount + 1
            if state.Sea2RetryCount >= 4 then
                stopAutoSea2("Could not speak to the Experienced Captain")
            else
                setSea2Phase("CheckCaptain", 1.5)
            end
        elseif tonumber(result) == 0 then
            state.Sea2RetryCount = 0
            setSea2Phase("EnterSea2")
        else
            setSea2Phase("ReturnPrison", 1)
        end
        return
    end

    if phase == "EnterSea2" then
        local requestState = pollSea2Request("TravelDressrosa")
        if requestState == "pending" then return end
        if requestState == "failed" then
            state.Sea2RetryCount = state.Sea2RetryCount + 1
            if state.Sea2RetryCount >= 3 then
                stopAutoSea2("Could not enter the Second Sea")
            else
                setSea2Phase("TravelCaptain", 1.5)
            end
        else
            state.Sea2RetryCount = 0
            setSea2Phase("AwaitTeleport", 15)
            showNotice("Entering Second Sea", nil, 5)
        end
        return
    end

    if phase == "AwaitTeleport" and now >= state.Sea2ReadyAt then
        setSea2Phase("TravelCaptain", 1)
    end
end

local secondSeaRuntime = (function()
local specialModes = { "AutoPirateRaid", "AutoSaber", "AutoTyrant", "AutoCakePrince", "AutoDoughKing", "AutoEliteHunter", "AutoCyborg", "RaidAutoClear", "AutoFactory", "AutoBartilo", "AutoRaceV2", "AutoRaceV3", "AutoGhoul", "AutoSea3", "AutoDropGoal" }
local raidTypes = { "Flame", "Ice", "Quake", "Light", "Dark", "Spider", "Magma", "Buddha", "Sand", "Phoenix", "Dough" }
local dropGoals = {
    ["Hellfire Torch"] = { Target = "Cursed Captain", Boss = true, Wait = "Cursed Ship" },
    ["Hidden Key"] = { Target = "Awakened Ice Admiral", Boss = true, Wait = "Ice Castle" },
    ["Library Key"] = { Target = "Awakened Ice Admiral", Boss = true, Wait = "Ice Castle" },
    ["Dragon Trident"] = { Target = "Tide Keeper", Boss = true, Wait = "Forgotten Island" },
    ["Gravity Cane"] = { Target = "Fajita", Boss = true, Wait = "Green Zone" },
    ["Black Spikey Coat"] = { Target = "Jeremy", Boss = true, Wait = "Kingdom of Rose" },
    ["Swan Glasses"] = { Target = "Don Swan", Boss = true, Wait = "Mansion" }
}

local function currentRace()
    local data = LocalPlayer:FindFirstChild("Data")
    local race = data and data:FindFirstChild("Race")
    return race and tostring(race.Value) or "Unknown"
end

local function fragmentCount()
    local data = LocalPlayer:FindFirstChild("Data")
    local fragments = data and data:FindFirstChild("Fragments")
    return fragments and tonumber(fragments.Value) or nil
end

local fragmentPurchaseBusy = false
local function buyFragmentReward(action, label, cost)
    if fragmentPurchaseBusy then
        contextNotice("FragmentPurchaseBusy", "A fragment purchase is already being processed", Red, 3, 2)
        return
    end
    local before = fragmentCount()
    if before and before < cost then
        contextNotice("FragmentPurchase:" .. action, "You need " .. tostring(cost) .. " Fragments for " .. label, Red, 5, 3)
        return
    end
    fragmentPurchaseBusy = true
    showNotice("Buying " .. label, nil, 3)
    task.spawn(function()
        local ok, result = pcall(function()
            return CommF:InvokeServer("BlackbeardReward", action, "2")
        end)
        local deadline = os.clock() + 2
        local after = fragmentCount()
        while state.Alive and ok and before and (not after or after >= before) and os.clock() < deadline do
            task.wait(0.1)
            after = fragmentCount()
        end
        fragmentPurchaseBusy = false
        if not state.Alive then return end
        if not ok then
            showNotice(label .. " purchase failed", Red, 4)
        elseif before and after and after < before then
            showNotice(label .. " purchased", nil, 4)
        elseif result == true or result == 1 or result == "1" then
            showNotice(label .. " purchased", nil, 4)
        elseif type(result) == "string" and result ~= "" then
            showNotice(result, Red, 5)
        else
            showNotice(label .. " was not purchased", Red, 4)
        end
    end)
end

local REDEEM_CODES = {
    "EASTEREXP",
    "fudd10",
    "fudd10_V2",
    "Chandler",
    "BIGNEWS",
    "KITT_RESET",
    "Sub2UncleKizaru",
    "SUB2GAMERROBOT_RESET1",
    "Sub2Fer999",
    "Enyu_is_Pro",
    "JCWK",
    "StarcodeHEO",
    "MagicBUS",
    "KittGaming",
    "Sub2CaptainMaui",
    "Sub2OfficialNoobie",
    "TheGreatAce",
    "Sub2NoobMaster123",
    "Sub2Daigrock",
    "Axiore",
    "StrawHatMaine",
    "TantaiGaming",
    "Bluxxy",
    "SUB2GAMERROBOT_EXP1"
}

local codeClaimBusy = false
local function claimAllCodes()
    if codeClaimBusy then
        contextNotice("CodeClaimBusy", "Codes are already being processed", Red, 3, 2)
        return
    end
    local redeem = Remotes:FindFirstChild("Redeem")
    if not redeem or not redeem:IsA("RemoteFunction") then
        contextNotice("CodeRedeemMissing", "The code redemption service is unavailable", Red, 4, 3)
        return
    end
    codeClaimBusy = true
    showNotice("Claiming codes", nil, 3)
    task.spawn(function()
        local processed, failed = 0, 0
        for _, code in ipairs(REDEEM_CODES) do
            if not state.Alive then break end
            local ok = pcall(function()
                redeem:InvokeServer(code)
            end)
            processed = processed + 1
            if not ok then failed = failed + 1 end
            task.wait(0.2)
        end
        codeClaimBusy = false
        if not state.Alive then return end
        if failed > 0 then
            showNotice(string.format("Codes processed: %d | Requests failed: %d", processed, failed), Red, 5)
        else
            showNotice(string.format("Codes processed: %d", processed), nil, 4)
        end
    end)
end

local function queueSpecialRequest(key, owner, callback, request)
    if state.SpecialRequestBusy[key] then return false end
    local throttleKey = key .. "RequestNext"
    if os.clock() < (state.SpecialData[throttleKey] or 0) then return false end
    state.SpecialData[throttleKey] = os.clock() + 1.5
    state.SpecialRequestBusy[key] = true
    task.spawn(function()
        local ok, result = pcall(request)
        state.SpecialRequestBusy[key] = nil
        if state.Alive and (not owner or state.SpecialOwner == owner) then callback(ok, result) end
    end)
    return true
end

local function setSpecialStatus(text)
    state.SpecialStatus = tostring(text or "Idle")
end

local function clearSpecialFarm(owner)
    if owner and state.SpecialOwner ~= owner then return end
    if state.SpecialFarm then
        state.SpecialFarm = nil
        invalidateFarmRuntime("", 0)
    end
end

local function setSpecialFarm(owner, name, boss, target, quest, useQuest, options)
    if state.SpecialOwner ~= owner or not name then return end
    name = normalizeEnemyName(name)
    local spamRemote = type(options) == "table" and options.SpamRemote == true
    local groupNames = type(options) == "table" and options.GroupNames or nil
    local groupAll = type(options) == "table" and options.GroupAll == true
    local groupOrigin = type(options) == "table" and options.GroupOrigin or nil
    local groupRange = type(options) == "table" and tonumber(options.GroupRange) or nil
    local current = state.SpecialFarm
    local changed = not current or current.Owner ~= owner or current.Name ~= name or current.Boss ~= (boss == true)
        or current.Target ~= target or current.Quest ~= quest or current.UseQuest ~= (useQuest == true)
        or current.SpamRemote ~= spamRemote or current.GroupNames ~= groupNames or current.GroupAll ~= groupAll
        or current.GroupOrigin ~= groupOrigin or current.GroupRange ~= groupRange
    if not changed then return end
    state.SpecialFarm = {
        Owner = owner,
        Name = name,
        Boss = boss == true,
        Target = target,
        Quest = quest,
        UseQuest = useQuest == true,
        SpamRemote = spamRemote,
        GroupNames = groupNames,
        GroupAll = groupAll,
        GroupOrigin = groupOrigin,
        GroupRange = groupRange
    }
    invalidateFarmRuntime("", 0)
end

local function setSpecialTravel(owner, position, name, object, mode)
    if state.SpecialOwner ~= owner or typeof(position) ~= "Vector3" then return false end
    local hadSpecialFarm = state.SpecialFarm ~= nil
    clearSpecialFarm(owner)
    if not hadSpecialFarm and state.TravelOwner ~= owner then
        invalidateFarmRuntime("", 0)
    end
    if state.TravelOwner ~= owner or not state.TravelTarget or (state.TravelTarget - position).Magnitude > 1 then
        state.TravelSerial = state.TravelSerial + 1
        state.TravelBudget = 0
    end
    state.TravelTarget = position
    state.TravelName = name or "Second Sea target"
    state.TravelMode = mode or "farmSpecial"
    state.TravelObject = object
    state.TravelOwner = owner
    return true
end

local function findEnemyNames(root, names, bossesOnly)
    local folder = workspace:FindFirstChild("Enemies")
    if not folder or not root then return nil end
    local wanted = {}
    for _, name in ipairs(names) do wanted[normalizeEnemyName(name)] = true end
    local best, bestDistance
    for _, model in ipairs(folder:GetChildren()) do
        local normalized = normalizeEnemyName(model.Name)
        local part = getPart(model)
        local humanoid = getHumanoid(model)
        if wanted[normalized] and (not bossesOnly or isBoss(model)) and part and humanoid and humanoid.Health > 0 then
            local distance = (part.Position - root.Position).Magnitude
            if not bestDistance or distance < bestDistance then best, bestDistance = model, distance end
        end
    end
    return best
end


local function activeRaidId()
    local raidId = LocalPlayer:GetAttribute("IslandRaiding")
    if raidId == nil or raidId == false then return nil end
    return raidId
end

local function raidIslandCluster(root)
    local origin = workspace:FindFirstChild("_WorldOrigin")
    local locations = origin and origin:FindFirstChild("Locations")
    local raidId = activeRaidId()
    if not locations or not root or raidId == nil then return nil, {} end
    local candidates, nearest, nearestDistance = {}, nil, nil
    for _, part in ipairs(locations:GetChildren()) do
        local index = part:IsA("BasePart") and tonumber(part.Name:match("^[Ii]sland%s*(%d+)$")) or nil
        if index then
            candidates[#candidates + 1] = { Part = part, Index = index }
            local distance = (part.Position - root.Position).Magnitude
            if not nearestDistance or distance < nearestDistance then
                nearest, nearestDistance = part, distance
            end
        end
    end
    if not nearest then return nil, {} end

    if state.SpecialData.RaidClusterId ~= raidId then
        state.SpecialData.RaidClusterId = raidId
        state.SpecialData.RaidClusterAnchor = nil
    end
    local anchor = state.SpecialData.RaidClusterAnchor
    if not anchor then
        -- Island locations are global. Wait until the server has placed this
        -- character by its own raid before binding to one of the clusters.
        if nearestDistance > 8000 then return nil, {} end
        anchor = nearest.Position
        state.SpecialData.RaidClusterAnchor = anchor
    end

    local cluster = {}
    for _, entry in ipairs(candidates) do
        if (entry.Part.Position - anchor).Magnitude <= 12000 then
            cluster[#cluster + 1] = entry
        end
    end
    local anchorPart, anchorDistance
    for _, entry in ipairs(cluster) do
        local distance = (entry.Part.Position - anchor).Magnitude
        if not anchorDistance or distance < anchorDistance then
            anchorPart, anchorDistance = entry.Part, distance
        end
    end
    return anchorPart, cluster
end

FarmRuntime.RaidContextActive = function(root)
    return root ~= nil and activeRaidId() ~= nil
end

FarmRuntime.RaidIslandFive = function(root)
    if not root then return nil end
    local _, islands = raidIslandCluster(root)
    for _, island in ipairs(islands) do
        if island.Index == 5 and (root.Position - island.Part.Position).Magnitude <= 3000 then
            return island.Part
        end
    end
    return nil
end

FarmRuntime.RaidBossTarget = function(root)
    local island = FarmRuntime.RaidIslandFive(root)
    if not island then return nil end
    local best, bestPart, bestLoaded, bestNamed, bestHealth, bestDistance
    local function scan(container, loaded)
        if not container then return end
        for _, model in ipairs(container:GetChildren()) do
            if model:IsA("Model") then
                local part, humanoid = getPart(model), getHumanoid(model)
                if part and humanoid and humanoid.Health > 0 and (part.Position - island.Position).Magnitude <= 2500 then
                    local named = isBoss(model) and 1 or 0
                    local maximumHealth = math.max(0, humanoid.MaxHealth)
                    local distance = (part.Position - root.Position).Magnitude
                    if not best
                        or named > bestNamed
                        or (named == bestNamed and maximumHealth > bestHealth)
                        or (named == bestNamed and maximumHealth == bestHealth and loaded and not bestLoaded)
                        or (named == bestNamed and maximumHealth == bestHealth and loaded == bestLoaded and distance < bestDistance)
                    then
                        best, bestPart, bestLoaded = model, part, loaded
                        bestNamed, bestHealth, bestDistance = named, maximumHealth, distance
                    end
                end
            end
        end
    end
    scan(workspace:FindFirstChild("Enemies"), true)
    scan(ReplicatedStorage, false)
    return best, bestPart, bestLoaded, bestNamed == 1
end

local function nearestRaidEnemy(root, targetIsland)
    local folder = workspace:FindFirstChild("Enemies")
    local raidId = activeRaidId()
    if not folder or not root or raidId == nil then return nil end
    local _, islands = raidIslandCluster(root)
    if #islands == 0 then return nil end
    local best, bestDistance
    for _, model in ipairs(folder:GetChildren()) do
        local part, humanoid = getPart(model), getHumanoid(model)
        local modelRaid = model:GetAttribute("IslandRaiding")
        local belongsToRaid = modelRaid ~= nil and modelRaid == raidId
        if part and modelRaid == nil then
            for _, island in ipairs(islands) do
                if (part.Position - island.Part.Position).Magnitude <= 2500 then
                    belongsToRaid = true
                    break
                end
            end
        end
        if part and targetIsland and (part.Position - targetIsland.Position).Magnitude > 2500 then
            belongsToRaid = false
        end
        if part and humanoid and humanoid.Health > 0 and belongsToRaid then
            local distance = (part.Position - root.Position).Magnitude
            if not bestDistance or distance < bestDistance then best, bestDistance = model, distance end
        end
    end
    return best
end

FarmRuntime.StoredRaidTarget = function(root, targetIsland)
    if not root then return nil, nil end
    local raidId = activeRaidId()
    if raidId == nil then return nil, nil end
    local _, islands = raidIslandCluster(root)
    if #islands == 0 then return nil, nil end
    local best, bestPart, bestDistance
    for _, model in ipairs(ReplicatedStorage:GetChildren()) do
        if model:IsA("Model") then
            local part, humanoid = getPart(model), getHumanoid(model)
            if part and humanoid and humanoid.Health > 0 then
                local modelRaid = model:GetAttribute("IslandRaiding")
                local belongsToRaid = modelRaid ~= nil and modelRaid == raidId
                if modelRaid == nil then
                    for _, island in ipairs(islands) do
                        if (part.Position - island.Part.Position).Magnitude <= 2500 then
                            belongsToRaid = true
                            break
                        end
                    end
                end
                if targetIsland and (part.Position - targetIsland.Position).Magnitude > 2500 then
                    belongsToRaid = false
                end
                if belongsToRaid then
                    local distance = (part.Position - root.Position).Magnitude
                    if not bestDistance or distance < bestDistance then
                        best, bestPart, bestDistance = model, part, distance
                    end
                end
            end
        end
    end
    return best, bestPart
end

local function nearestAnyEnemy(root)
    local folder = workspace:FindFirstChild("Enemies")
    if not folder or not root then return nil end
    local best, bestDistance
    for _, model in ipairs(folder:GetChildren()) do
        local part, humanoid = getPart(model), getHumanoid(model)
        if part and humanoid and humanoid.Health > 0 and not isBoss(model) then
            local distance = (part.Position - root.Position).Magnitude
            if not bestDistance or distance < bestDistance then best, bestDistance = model, distance end
        end
    end
    return best
end

local function worldTool(names)
    local wanted = {}
    for _, name in ipairs(names) do wanted[string.lower(name)] = true end
    for _, instance in ipairs(workspace:GetChildren()) do
        if wanted[string.lower(instance.Name)] and getPart(instance) then return instance end
    end
    return nil
end

FarmRuntime.PirateRaid = {
    Owner = "AutoPirateRaid",
    Radius = 1500,
    CastleFallback = Vector3.new(-5436.61, 815.64, -2701.66)
}

FarmRuntime.PirateRaidCastle = function()
    local origin = workspace:FindFirstChild("_WorldOrigin")
    local locations = origin and origin:FindFirstChild("Locations")
    local castle = locations and (locations:FindFirstChild("Castle on the Sea") or locations:FindFirstChild("Castle On The Sea"))
    local part = getPart(castle)
    return part and part.Position or FarmRuntime.PirateRaid.CastleFallback, castle
end

FarmRuntime.FindPirateRaidEnemy = function(root)
    local center, castle = FarmRuntime.PirateRaidCastle()
    local folder = workspace:FindFirstChild("Enemies")
    if not folder then return nil, 0, center, castle end

    local best, bestDistance, count = nil, nil, 0
    for _, model in ipairs(folder:GetChildren()) do
        local part, humanoid = getPart(model), getHumanoid(model)
        local lowered = string.lower(normalizeEnemyName(model.Name))
        local excluded = string.find(lowered, "rip_indra", 1, true) ~= nil
        if not excluded and part and humanoid and humanoid.Health > 0
            and (part.Position - center).Magnitude <= FarmRuntime.PirateRaid.Radius
        then
            count = count + 1
            local distance = root and (part.Position - root.Position).Magnitude or 0
            if not bestDistance or distance < bestDistance then
                best, bestDistance = model, distance
            end
        end
    end

    state.PirateRaidLastCount = count
    if count >= 2 then state.PirateRaidDetectedUntil = os.clock() + 12 end
    return best, count, center, castle
end

FarmRuntime.PirateRaidActive = function(root)
    local _, count = FarmRuntime.FindPirateRaidEnemy(root)
    return count >= 2 or os.clock() < state.PirateRaidDetectedUntil
end

local function specialModeRequirement(setting)
    if setting == "AutoPirateRaid" then
        if game.PlaceId ~= SEA_PLACE_IDS.Third then
            return false, "Pirate Raids are only available in the Third Sea", false
        end
        local _, humanoid, root = getCharacter(LocalPlayer)
        if not root or not humanoid or humanoid.Health <= 0 then
            return false, "Your character is not ready", true
        end
        if FarmRuntime.PirateRaidActive(root) then return true, nil, false end
        return false, "No Pirate Raid is active", true
    end
    if setting == "AutoSaber" then
        if game.PlaceId ~= SEA_PLACE_IDS.First then
            return false, "The Saber puzzle is only available in the First Sea", false
        end
        if playerLevel() < 200 then
            return false, "You need Level 200 for the Saber puzzle", true
        end
        return true, nil, false
    end
    if setting == "RaidAutoClear" then
        local _, humanoid, root = getCharacter(LocalPlayer)
        if not root or not humanoid or humanoid.Health <= 0 then
            return false, "Your character is not ready", true
        end
        if not FarmRuntime.RaidContextActive(root) then
            return false, "You are not currently in a raid", true
        end
        return true, nil, false
    end
    if setting == "AutoDoughKing" then
        if game.PlaceId ~= SEA_PLACE_IDS.Third then
            return false, "Dough King is only available in the Third Sea", false
        end
        local _, humanoid, root = getCharacter(LocalPlayer)
        if not root or not humanoid or humanoid.Health <= 0 then
            return false, "Your character is not ready", true
        end
        return true, nil, false
    end
    if setting == "AutoTyrant" or setting == "AutoCakePrince" or setting == "AutoEliteHunter" then
        if game.PlaceId ~= SEA_PLACE_IDS.Third then
            local feature = setting == "AutoTyrant" and "The Tyrant"
                or setting == "AutoCakePrince" and "Cake Prince"
                or "Elite Hunter"
            return false, feature .. " is only available in the Third Sea", false
        end
        local _, humanoid, root = getCharacter(LocalPlayer)
        if not root or not humanoid or humanoid.Health <= 0 then
            return false, "Your character is not ready", true
        end
        return true, nil, false
    end
    if game.PlaceId ~= SEA_PLACE_IDS.Second then
        return false, "This option only works in the Second Sea", false
    end
    local _, humanoid, root = getCharacter(LocalPlayer)
    if not root or not humanoid or humanoid.Health <= 0 then
        return false, "Your character is not ready", true
    end
    local level = playerLevel()
    if setting == "AutoFactory" then
        if not findEnemyNames(root, { "Core" }, false) then
            return false, "The Factory isn't being raided", true
        end
    elseif setting == "AutoBartilo" and level < 850 then
        return false, "You need Level 850 for the Bartilo quest", true
    elseif setting == "AutoRaceV2" and level < 850 then
        return false, "You need Level 850 for Race V2", true
    elseif setting == "AutoRaceV3" and level < 1000 then
        return false, "You need Level 1000 for Race V3", true
    elseif setting == "AutoGhoul" then
        if string.lower(currentRace()) == "ghoul" then
            return false, "You already have the Ghoul race", false
        end
        if level < 1000 then
            return false, "You need Level 1000 for the Ghoul race", true
        end
    elseif setting == "AutoCyborg" and string.lower(currentRace()) == "cyborg" then
        return false, "You already have the Cyborg race", false
    elseif setting == "AutoSea3" and level < 1500 then
        return false, "You need Level 1500 for the Third Sea", true
    elseif setting == "AutoDropGoal" then
        local goal = Settings.DropGoal
        local definition = dropGoals[goal]
        if not definition then return false, "Choose a valid drop goal", false end
        if findOwnedTool(goal) or table.find(state.RecentDrops, goal) then
            return false, "You already have " .. tostring(goal), false
        end
        if not findEnemyNames(root, { definition.Target }, definition.Boss) then
            return false, definition.Target .. " is not spawned", true
        end
    end
    return true, nil, false
end

local function activateSpecialOwner(setting)
    if state.SpecialOwner == setting then return end
    local previous = state.SpecialOwner
    if previous then
        clearSpecialFarm(previous)
        if state.TravelOwner == previous then stopTravel() end
    end
    state.SpecialOwner = setting
    state.SpecialData = {}
    if setting == "AutoDoughKing" then
        state.ChestIslandSearchReadyAt = 0
        state.DoughCounterNextAt = 0
    end
    state.BartiloPlate = 1
    state.BartiloPuzzleNoclip = false
    state.SaberPuzzleNoclip = setting == "AutoSaber"
    state.SpecialNextCheck = 0
    setSpecialStatus(setting and "Starting" or "Idle")
end
FarmRuntime.ActivateSpecialOwner = activateSpecialOwner

local function setSpecialMode(setting, enabled)
    if enabled then
        local ready, reason, canWait = specialModeRequirement(setting)
        if not ready and not canWait then
            Settings[setting] = false
            local blockedControl = SecondSeaControls[setting]
            if blockedControl and blockedControl.Set then
                task.defer(function() pcall(function() blockedControl:Set(false) end) end)
            end
            contextNotice("Blocked:" .. tostring(setting), reason, Red, 4, 3)
            return false
        end
        if setting == "AutoCakePrince" or setting == "AutoDoughKing" then
            Settings.AutoSpawnCakePrince = false
            Settings.AutoSpawnDoughKing = false
            state.CakeSpawnReady = false
            task.defer(function()
                for _, control in ipairs({ state.AutoSpawnCakePrinceControl, state.AutoSpawnDoughKingControl }) do
                    if control and control.Set then pcall(function() control:Set(false) end) end
                end
            end)
        end
        Settings[setting] = true
        if setting == "AutoTyrant" or setting == "AutoCakePrince" or setting == "AutoDoughKing" or setting == "AutoEliteHunter" then
            for _, other in ipairs({ "AutoTyrant", "AutoCakePrince", "AutoDoughKing", "AutoEliteHunter" }) do
                if other ~= setting and Settings[other] then
                    Settings[other] = false
                    local otherControl = SecondSeaControls[other]
                    if otherControl and otherControl.Set then
                        task.defer(function() pcall(function() otherControl:Set(false) end) end)
                    end
                end
            end
        end
        if Settings.AutoSea2 then
            Settings.AutoSea2 = false
            if AutoSea2Control and AutoSea2Control.Set then pcall(function() AutoSea2Control:Set(false) end) end
        end
        if ready then
            activateSpecialOwner(setting)
        else
            setSpecialStatus(reason)
            local waitingMessage
            if setting == "AutoFactory" then
                waitingMessage = Settings.AutoFarm
                    and (reason .. ". Auto Farm is already enabled and will continue while waiting")
                    or (reason .. ". Factory Assistant is waiting")
            else
                waitingMessage = Settings.AutoFarm
                    and (reason .. ". Auto Farm will continue while waiting")
                    or (reason .. ". Waiting")
            end
            contextNotice("Waiting:" .. tostring(setting), waitingMessage, Red, 5, 8)
        end
    elseif state.SpecialOwner == setting then
        Settings[setting] = false
        if setting == "AutoSaber" then state.SaberPuzzleNoclip = false end
        activateSpecialOwner(nil)
    else
        Settings[setting] = false
    end
    return true
end

local function finishSpecialMode(owner, message)
    Settings[owner] = false
    if owner == "AutoBartilo" then state.BartiloPuzzleNoclip = false end
    if owner == "AutoSaber" then state.SaberPuzzleNoclip = false end
    if state.SpecialOwner == owner then
        clearSpecialFarm(owner)
        state.SpecialOwner = nil
        state.SpecialData = {}
        if state.TravelOwner == owner then stopTravel() end
    end
    local control = SecondSeaControls[owner]
    if control and control.Set then task.defer(function() pcall(function() control:Set(false) end) end) end
    if message then showNotice(message, nil, 5) end
end

local function pollSpecialValue(owner, key, interval, request)
    local now = os.clock()
    local nextAt = state.SpecialData[key .. "Next"] or 0
    if now < nextAt then return end
    state.SpecialData[key .. "Next"] = now + interval
    queueSpecialRequest(key, owner, function(ok, result)
        if ok then
            state.SpecialData[key] = result
            state.SpecialData[key .. "Received"] = true
            state.SpecialData[key .. "Error"] = nil
        else
            state.SpecialData[key .. "Received"] = false
            state.SpecialData[key .. "Error"] = tostring(result)
        end
    end, request)
end

local TYRANT_OWNER = "AutoTyrant"
local TYRANT_FALLBACK = Vector3.new(-16641.5, 213.3, 435.4)
local TYRANT_RADIUS = 3800

local function tyrantOrigin()
    local origin = workspace:FindFirstChild("_WorldOrigin")
    local locations = origin and origin:FindFirstChild("Locations")
    local tiki = locations and locations:FindFirstChild("Tiki Outpost")
    return tiki and tiki:IsA("BasePart") and tiki.Position or TYRANT_FALLBACK, tiki
end

local function findTyrantBoss(root)
    local folder = workspace:FindFirstChild("Enemies")
    if not folder then return nil end
    local best, bestDistance
    for _, model in ipairs(folder:GetChildren()) do
        local name = string.lower(normalizeEnemyName(model.Name))
        local part, humanoid = getPart(model), getHumanoid(model)
        if string.find(name, "tyrant", 1, true) and part and humanoid and humanoid.Health > 0
        then
            local distance = root and (part.Position - root.Position).Magnitude or 0
            if not bestDistance or distance < bestDistance then
                best, bestDistance = model, distance
            end
        end
    end
    return best
end

local function findTikiEnemy(root, center)
    local current = state.SpecialData.TyrantLastMob
    local currentPart, currentHumanoid = getPart(current), getHumanoid(current)
    if current and current.Parent and currentPart and currentHumanoid and currentHumanoid.Health > 0
        and (currentPart.Position - center).Magnitude <= TYRANT_RADIUS
    then
        return current
    end
    local folder = workspace:FindFirstChild("Enemies")
    if not folder then return nil end
    local best, bestDistance
    for _, model in ipairs(folder:GetChildren()) do
        local part, humanoid = getPart(model), getHumanoid(model)
        if part and humanoid and humanoid.Health > 0 and not isBoss(model)
            and (part.Position - center).Magnitude <= TYRANT_RADIUS
        then
            local distance = root and (part.Position - root.Position).Magnitude or 0
            if not bestDistance or distance < bestDistance then
                best, bestDistance = model, distance
            end
        end
    end
    return best
end

local function tyrantEyesReady(center)
    if state.SpecialData.TyrantEyesReady then return true end
    local now = os.clock()
    if now < (state.SpecialData.TyrantEyeScanAt or 0) then return false end
    state.SpecialData.TyrantEyeScanAt = now + 0.25
    local map = workspace:FindFirstChild("Map")
    local tiki = map and map:FindFirstChild("TikiOutpost")
    local island = tiki and tiki:FindFirstChild("IslandModel")
    local chunks = island and island:FindFirstChild("IslandChunks")
    local chunkE = chunks and chunks:FindFirstChild("E")
    if not island then return false end
    local eyes = {
        island:FindFirstChild("Eye1"),
        island:FindFirstChild("Eye2"),
        chunkE and chunkE:FindFirstChild("Eye3"),
        chunkE and chunkE:FindFirstChild("Eye4")
    }
    local activeEyes = 0
    for _, eye in ipairs(eyes) do
        if eye and eye:IsA("BasePart") and eye.Transparency < 0.5
            and (eye.Position - center).Magnitude <= TYRANT_RADIUS
        then
            local color = eye.Color
            if color.R >= 0.45 and color.R > color.G * 1.25 and color.R > color.B * 1.2 then
                activeEyes = activeEyes + 1
            end
        end
    end
    state.SpecialData.TyrantEyeCount = activeEyes
    if activeEyes == 4 then state.SpecialData.TyrantEyesReady = true end
    return state.SpecialData.TyrantEyesReady == true
end

local function updateTyrantAutomation(root)
    local center, location = tyrantOrigin()
    local boss = findTyrantBoss(root)
    if boss then
        state.SpecialData.TyrantBossSeen = true
        state.SpecialData.TyrantPhase = "Boss"
        setSpecialStatus("Defeating Tyrant of the Skies")
        setSpecialFarm(TYRANT_OWNER, boss.Name, true, boss, nil, false, { SpamRemote = true })
        return
    end
    if state.SpecialData.TyrantBossSeen then
        finishSpecialMode(TYRANT_OWNER, "Tyrant of the Skies defeated")
        return
    end

    local lastMob = state.SpecialData.TyrantLastMob
    if lastMob then
        local lastHumanoid = getHumanoid(lastMob)
        if not lastMob.Parent or (lastHumanoid and lastHumanoid.Health <= 0) then
            state.SpecialData.TyrantKills = (state.SpecialData.TyrantKills or 0) + 1
            state.SpecialData.TyrantLastMob = nil
        end
    end

    local eyesReady = tyrantEyesReady(center)
    local kills = state.SpecialData.TyrantKills or 0
    if eyesReady then
        state.SpecialData.TyrantPhase = "Pots"
        clearSpecialFarm(TYRANT_OWNER)
        if state.TravelOwner == TYRANT_OWNER then stopTravel() end
        setSpecialStatus("Break the pots to summon the Tyrant")
        if not state.SpecialData.TyrantManualPotNotice then
            state.SpecialData.TyrantManualPotNotice = true
            showNotice("Break the Tiki pots to summon the Tyrant", nil, 6)
        end
        return
    end

    state.SpecialData.TyrantPhase = "Kills"
    local enemy = findTikiEnemy(root, center)
    if enemy then
        state.SpecialData.TyrantLastMob = enemy
        local activeEyes = state.SpecialData.TyrantEyeCount or 0
        local killStatus = activeEyes > 0 and (tostring(activeEyes) .. "/4 eyes")
            or (kills < 300 and (tostring(kills) .. "/300") or "waiting for eyes")
        setSpecialStatus("Defeating Tiki enemies (" .. killStatus .. ")")
        setSpecialFarm(TYRANT_OWNER, enemy.Name, false, enemy, nil, false, {
            SpamRemote = true,
            GroupAll = true,
            GroupOrigin = center,
            GroupRange = 1200
        })
        return
    end
    clearSpecialFarm(TYRANT_OWNER)
    setSpecialStatus("Waiting for Tiki enemies")
    if (root.Position - center).Magnitude > 350 then
        setSpecialTravel(TYRANT_OWNER, center + Vector3.new(0, 18, 0), "Tiki Outpost", location, "farmTyrant")
    elseif state.TravelOwner == TYRANT_OWNER then
        stopTravel()
    end
end

FarmRuntime.CakePrince = {
    Owner = "AutoCakePrince",
    EnemyNames = { "Cookie Crafter", "Cake Guard", "Baking Staff" },
    GroupClusters = {
        ["Cookie Crafter"] = { "Cookie Crafter" },
        ["Cake Guard"] = { "Cake Guard" },
        ["Baking Staff"] = { "Baking Staff" }
    },
    MamaFallback = Vector3.new(-2137.667, 69.331, -12326.238),
    BossFallback = Vector3.new(-2089.866, 4536.924, -14800.007)
}

FarmRuntime.SetCakePrinceCounter = function(text)
    local label = state.CakePrinceCounterLabel
    local value = tostring(text or "Checking")
    if value == "checking..." then value = "Checking"
    elseif value == "resetting" then value = "Resetting"
    elseif value == "unavailable" then value = "Unavailable"
    elseif value == "0 - boss active" then value = "Boss active"
    elseif value == "0 - portal open" then value = "Portal open" end
    if label then pcall(function()
        if label.Parent then label.Text = "Enemies Remaining: " .. value end
    end) end
end

function FarmRuntime.CakePrince.FindBoss(root)
    local folder = workspace:FindFirstChild("Enemies")
    if not folder then return nil end
    local best, bestDistance
    for _, model in ipairs(folder:GetChildren()) do
        local part, humanoid = getPart(model), getHumanoid(model)
        local name = string.lower(normalizeEnemyName(model.Name))
        if part and humanoid and humanoid.Health > 0 and string.find(name, "cake prince", 1, true) then
            local distance = root and (part.Position - root.Position).Magnitude or 0
            if not bestDistance or distance < bestDistance then
                best, bestDistance = model, distance
            end
        end
    end
    return best
end

FarmRuntime.ApplyCakePrinceCounterReply = function(result)
    local reply = tostring(result or "")
    local lower = string.lower(reply)
    local remaining = tonumber(string.match(lower, "(%d+)%s+enemies?")) or tonumber(string.match(reply, "(%d+)"))
    local text
    if remaining then
        text = tostring(remaining)
    elseif string.find(lower, "open the portal now", 1, true)
        or string.find(lower, "portal", 1, true)
        or string.find(lower, "spawn", 1, true)
    then
        text = "Portal open"
    end
    if text then
        state.CakeCounterLastText = text
        FarmRuntime.SetCakePrinceCounter(text)
    elseif state.CakeCounterLastText then
        FarmRuntime.SetCakePrinceCounter(state.CakeCounterLastText)
    else
        FarmRuntime.SetCakePrinceCounter("Checking")
    end
end

FarmRuntime.RefreshCakePrinceCounter = function(force)
    if not state.CakePrinceCounterLabel then return end
    if game.PlaceId ~= SEA_PLACE_IDS.Third then return end
    local now = os.clock()
    if not force and now < state.CakeCounterNextAt then return end
    state.CakeCounterNextAt = now + ((Settings.AutoCakePrince and state.SpecialOwner == FarmRuntime.CakePrince.Owner) and 0.5 or 2)
    local _, _, root = getCharacter(LocalPlayer)
    if FarmRuntime.CakePrince.FindBoss(root) then
        state.CakeCounterLastText = "Boss active"
        FarmRuntime.SetCakePrinceCounter(state.CakeCounterLastText)
        return
    end
    if Settings.AutoCakePrince and state.SpecialOwner == FarmRuntime.CakePrince.Owner then
        if state.SpecialData.CakeProgress ~= nil then
            FarmRuntime.ApplyCakePrinceCounterReply(state.SpecialData.CakeProgress)
        elseif state.CakeCounterLastText then
            FarmRuntime.SetCakePrinceCounter(state.CakeCounterLastText)
        else
            FarmRuntime.SetCakePrinceCounter("Checking")
        end
        return
    end
    if state.CakeCounterBusy then return end
    state.CakeCounterBusy = true
    task.spawn(function()
        local ok, result = pcall(function() return CommF:InvokeServer("CakePrinceSpawner", true) end)
        state.CakeCounterBusy = false
        if not state.Alive then return end
        if ok then
            FarmRuntime.ApplyCakePrinceCounterReply(result)
        elseif state.CakeCounterLastText then
            FarmRuntime.SetCakePrinceCounter(state.CakeCounterLastText)
        else
            FarmRuntime.SetCakePrinceCounter("Checking")
        end
    end)
end

FarmRuntime.SetCakeLandAutoSpawn = function(target, enabled)
    local field = target == "Dough King" and "AutoSpawnDoughKing" or "AutoSpawnCakePrince"
    local otherField = target == "Dough King" and "AutoSpawnCakePrince" or "AutoSpawnDoughKing"
    local control = target == "Dough King" and state.AutoSpawnDoughKingControl or state.AutoSpawnCakePrinceControl
    local otherControl = target == "Dough King" and state.AutoSpawnCakePrinceControl or state.AutoSpawnDoughKingControl

    if enabled and game.PlaceId ~= SEA_PLACE_IDS.Third then
        Settings[field] = false
        task.defer(function()
            if control and control.Set then pcall(function() control:Set(false) end) end
        end)
        contextNotice("CakeLandSpawnSea", target .. " can only be spawned in the Third Sea", Red, 4, 2)
        return
    end

    Settings[field] = enabled == true
    if enabled then
        Settings[otherField] = false
        FarmRuntime.SetSecondSeaMode("AutoCakePrince", false)
        FarmRuntime.SetSecondSeaMode("AutoDoughKing", false)
        task.defer(function()
            if otherControl and otherControl.Set then pcall(function() otherControl:Set(false) end) end
            for _, mode in ipairs({ "AutoCakePrince", "AutoDoughKing" }) do
                local modeControl = SecondSeaControls[mode]
                if modeControl and modeControl.Set then pcall(function() modeControl:Set(false) end) end
            end
        end)
        state.CakeSpawnPollAt = 0
        state.CakeSpawnRemaining = nil
        state.CakeSpawnReady = false
        state.CakeSpawnSpamAt = 0
        state.CakeSpawnSpamInFlight = 0
        state.CakeSpawnHadSweetChalice = false
        state.CakeSpawnAwaitUntil = 0
        showNotice("Watching for " .. target .. " spawn", nil, 3)
    else
        state.CakeSpawnReady = false
        state.CakeSpawnRemaining = nil
        state.CakeSpawnHadSweetChalice = false
        state.CakeSpawnAwaitUntil = 0
    end
end

FarmRuntime.StopCakeLandAutoSpawn = function(target, message)
    local field = target == "Dough King" and "AutoSpawnDoughKing" or "AutoSpawnCakePrince"
    local control = target == "Dough King" and state.AutoSpawnDoughKingControl or state.AutoSpawnCakePrinceControl
    Settings[field] = false
    state.CakeSpawnReady = false
    state.CakeSpawnRemaining = nil
    state.CakeSpawnHadSweetChalice = false
    state.CakeSpawnAwaitUntil = 0
    task.defer(function()
        if control and control.Set then pcall(function() control:Set(false) end) end
    end)
    if message then showNotice(message, nil, 4) end
end

FarmRuntime.UpdateCakeLandAutoSpawn = function(root)
    local target = Settings.AutoSpawnDoughKing and "Dough King"
        or Settings.AutoSpawnCakePrince and "Cake Prince"
        or nil
    if not target or game.PlaceId ~= SEA_PLACE_IDS.Third or not root then return end

    if findEnemyNames(root, { target }, true) then
        FarmRuntime.StopCakeLandAutoSpawn(target, target .. " spawned")
        return
    end

    local now = os.clock()
    if target == "Dough King" and state.CakeSpawnHadSweetChalice
        and not findOwnedTool("Sweet Chalice") and not findOwnedTool("Cake Chalice")
    then
        if state.CakeSpawnAwaitUntil == 0 then state.CakeSpawnAwaitUntil = now + 12 end
        if now >= state.CakeSpawnAwaitUntil then
            FarmRuntime.StopCakeLandAutoSpawn(target, "Sweet Chalice was used; waiting for Dough King")
        end
        return
    end

    if now >= state.CakeSpawnPollAt and not state.CakeSpawnPollBusy then
        state.CakeSpawnPollAt = now + 0.2
        state.CakeSpawnPollBusy = true
        task.spawn(function()
            local ok, result = pcall(function() return CommF:InvokeServer("CakePrinceSpawner", true) end)
            state.CakeSpawnPollBusy = false
            if not state.Alive or not ok then return end
            local reply = tostring(result or "")
            local lower = string.lower(reply)
            local remaining = tonumber(string.match(lower, "(%d+)%s+enemies?")) or tonumber(string.match(reply, "(%d+)"))
            if remaining ~= nil then
                state.CakeSpawnRemaining = remaining
                FarmRuntime.SetCakePrinceCounter(remaining)
            end
            if (remaining ~= nil and remaining <= 1)
                or string.find(lower, "open the portal now", 1, true)
            then
                state.CakeSpawnReady = true
            end
        end)
    end

    if not state.CakeSpawnReady then return end
    if target == "Dough King" then
        local chalice = findOwnedTool("Sweet Chalice") or findOwnedTool("Cake Chalice")
        if not chalice then
            contextNotice("CakeLandSpawnChalice", "Auto Spawn Dough King needs a Sweet Chalice", Red, 4, 4)
            return
        end
        state.CakeSpawnHadSweetChalice = true
    elseif findOwnedTool("Sweet Chalice") or findOwnedTool("Cake Chalice") then
        contextNotice("CakeLandSpawnCakeChalice", "Store or remove the Sweet Chalice before spawning Cake Prince", Red, 4, 4)
        return
    end

    if now < state.CakeSpawnSpamAt or state.CakeSpawnSpamInFlight >= 3 then return end
    state.CakeSpawnSpamAt = now + 0.04
    state.CakeSpawnSpamInFlight = state.CakeSpawnSpamInFlight + 1
    task.spawn(function()
        pcall(function() CommF:InvokeServer("CakePrinceSpawner") end)
        state.CakeSpawnSpamInFlight = math.max(0, state.CakeSpawnSpamInFlight - 1)
    end)
end

function FarmRuntime.CakePrince.NearestReference(root, names)
    if not root then return nil end
    local wanted, best, bestDistance = {}, nil, nil
    for _, name in ipairs(names) do
        wanted[normalizeEnemyName(name)] = true
        local spawn = nearestEnemySpawn(root, name)
        if spawn then
            local distance = (spawn.Position - root.Position).Magnitude
            if not bestDistance or distance < bestDistance then
                best, bestDistance = spawn, distance
            end
        end
    end
    local folder = ReplicatedStorage:FindFirstChild("FortBuilderReplicatedSpawnPositionsFolder")
    if folder then
        for _, instance in ipairs(folder:GetDescendants()) do
            if wanted[normalizeEnemyName(instance.Name)] then
                local part = instance:IsA("BasePart") and instance or (instance:IsA("Model") and getPart(instance) or nil)
                if part then
                    local distance = (part.Position - root.Position).Magnitude
                    if not bestDistance or distance < bestDistance then
                        best, bestDistance = part, distance
                    end
                end
            end
        end
    end
    return best
end

function FarmRuntime.CakePrince.MamaReference()
    local npcs = ReplicatedStorage:FindFirstChild("NPCs")
    local mama = npcs and npcs:FindFirstChild("drip_mama")
    local part = mama and getPart(mama)
    return part and part.Position or FarmRuntime.CakePrince.MamaFallback, mama
end

function FarmRuntime.CakePrince.Update(root)
    local cake = FarmRuntime.CakePrince
    local owner = cake.Owner
    local now = os.clock()
    state.SpecialData.BlockNormalFarm = true
    if FarmRuntime.UpdateCakeLandSafety and FarmRuntime.UpdateCakeLandSafety(owner, root, "Cake Prince") then return end

    local boss = cake.FindBoss(root)
    if boss then
        FarmRuntime.SetCakePrinceCounter("Boss active")
        state.SpecialData.CakeBossSeen = true
        state.SpecialData.CakePortalOpened = nil
        if state.TravelOwner == owner then stopTravel() end
        setSpecialStatus("Defeating Cake Prince")
        setSpecialFarm(owner, boss.Name, true, boss, nil, false, { SpamRemote = true })
        return
    end

    if state.SpecialData.CakeBossSeen then
        state.SpecialData.CakeBossSeen = nil
        state.SpecialData.CakeProgress = nil
        state.SpecialData.CakeProgressNext = 0
        clearSpecialFarm(owner)
        FarmRuntime.SetCakePrinceCounter("resetting")
        showNotice("Cake Prince defeated", nil, 4)
    end

    if state.SpecialData.CakePortalOpened then
        FarmRuntime.SetCakePrinceCounter("Portal open")
        if now - (state.SpecialData.CakePortalOpenedAt or now) <= 20 then
            clearSpecialFarm(owner)
            local spawn = cake.NearestReference(root, { "Cake Prince" })
            local destination = (spawn and spawn.Position or cake.BossFallback) + Vector3.new(0, 8, 0)
            setSpecialStatus("Waiting for Cake Prince")
            setSpecialTravel(owner, destination, "Cake Prince", spawn, "farmCakePrince")
            return
        end
        state.SpecialData.CakePortalOpened = nil
        state.SpecialData.CakeProgress = nil
        state.SpecialData.CakeProgressNext = 0
    end

    pollSpecialValue(owner, "CakeProgress", 1.25, function()
        return CommF:InvokeServer("CakePrinceSpawner", true)
    end)

    local reply = tostring(state.SpecialData.CakeProgress or "")
    local lower = string.lower(reply)
    local remaining = tonumber(string.match(lower, "(%d+)%s+enemies?")) or tonumber(string.match(reply, "(%d+)"))
    local portalReady = string.find(lower, "open the portal now", 1, true) ~= nil

    if portalReady then
        FarmRuntime.SetCakePrinceCounter(0)
        clearSpecialFarm(owner)
        local mamaPosition, mama = cake.MamaReference()
        if (root.Position - mamaPosition).Magnitude > 28 then
            setSpecialStatus("Going to Drip Mama")
            setSpecialTravel(owner, mamaPosition + Vector3.new(0, 4, 0), "Drip Mama", mama, "farmCakePrince")
            return
        end
        if state.TravelOwner == owner then stopTravel() end
        setSpecialStatus("Opening Cake Prince portal")
        if now >= (state.SpecialData.CakeOpenNext or 0) then
            state.SpecialData.CakeOpenNext = now + 4
            queueSpecialRequest("CakeOpen", owner, function(ok)
                if not ok then
                    contextNotice("CakePrinceOpenFailed", "Could not open the Cake Prince portal; retrying", Red, 4, 5)
                    return
                end
                state.SpecialData.CakePortalOpened = true
                state.SpecialData.CakePortalOpenedAt = os.clock()
                state.SpecialData.CakeProgress = nil
                state.SpecialData.CakeProgressNext = 0
                showNotice("Cake Prince portal opened", nil, 4)
            end, function()
                return CommF:InvokeServer("CakePrinceSpawner")
            end)
        end
        return
    end

    if remaining and remaining > 0 then
        FarmRuntime.SetCakePrinceCounter(remaining)
        local enemy = state.SpecialFarm and state.SpecialFarm.Owner == owner and state.SpecialFarm.Target or nil
        local enemyValid = enemy and validFarmTarget(enemy)
        local enemyAllowed = false
        if enemyValid then
            local normalized = normalizeEnemyName(enemy.Name)
            for _, name in ipairs(cake.EnemyNames) do
                if normalized == normalizeEnemyName(name) then enemyAllowed = true; break end
            end
        end
        if not enemyAllowed then enemy = findEnemyNames(root, cake.EnemyNames, false) end
        if enemy then
            if state.TravelOwner == owner then stopTravel() end
            setSpecialStatus("Farming Cake enemies (" .. tostring(remaining) .. " left)")
            setSpecialFarm(owner, enemy.Name, false, enemy, nil, false, {
                SpamRemote = true,
                GroupNames = cake.GroupClusters[normalizeEnemyName(enemy.Name)]
            })
            return
        end
        clearSpecialFarm(owner)
        local spawn = cake.NearestReference(root, cake.EnemyNames)
        local destination = (spawn and spawn.Position or cake.MamaFallback) + Vector3.new(0, math.max(8, Settings.FarmDistance), 0)
        setSpecialStatus("Waiting for Cake enemies (" .. tostring(remaining) .. " left)")
        setSpecialTravel(owner, destination, "Cake Land", spawn, "farmCakePrince")
        return
    end

    if string.find(lower, "spawn", 1, true) or string.find(lower, "portal", 1, true) then
        state.SpecialData.CakePortalOpened = true
        state.SpecialData.CakePortalOpenedAt = now
        return
    end

    clearSpecialFarm(owner)
    if state.TravelOwner == owner then stopTravel() end
    FarmRuntime.SetCakePrinceCounter(state.SpecialData.CakeProgressError and "Unavailable" or "Checking")
    setSpecialStatus(state.SpecialData.CakeProgressError and "Cake Prince check failed; retrying" or "Checking Cake Prince progress")
end

FarmRuntime.DoughKing = {
    Owner = "AutoDoughKing",
    EnemyNames = FarmRuntime.CakePrince.EnemyNames,
    GroupClusters = FarmRuntime.CakePrince.GroupClusters,
    CocoaEnemyNames = { "Cocoa Warrior", "Chocolate Bar Battler", "Sweet Thief", "Candy Rebel" },
    CocoaGroupClusters = {
        ["Cocoa Warrior"] = { "Cocoa Warrior" },
        ["Chocolate Bar Battler"] = { "Chocolate Bar Battler" },
        ["Sweet Thief"] = { "Sweet Thief" },
        ["Candy Rebel"] = { "Candy Rebel" }
    },
    BossFallback = FarmRuntime.CakePrince.BossFallback
}

FarmRuntime.SetDoughKingCounter = function(text)
    state.DoughCounterLastText = tostring(text or "Checking")
    local label = state.DoughKingCounterLabel
    if label then pcall(function()
        FarmRuntime.SetCakePrinceCounter(state.DoughCounterLastText)
    end) end
end

FarmRuntime.SetDoughKingCocoa = function(count)
    local label = state.DoughKingCocoaLabel
    if label then pcall(function()
        if label.Parent then
            label.Text = count == nil and "Conjured Cocoa: Checking" or ("Conjured Cocoa: " .. tostring(count) .. "/10")
        end
    end) end
end

FarmRuntime.RefreshDoughKingStatus = function(force)
    if not state.DoughKingCocoaLabel then return end
    local now = os.clock()
    if not force and now < state.DoughCounterNextAt then return end
    state.DoughCounterNextAt = now + 2
    FarmRuntime.SetDoughKingCocoa(FarmRuntime.MaterialCount("Conjured Cocoa"))
    if Settings.AutoDoughKing and state.SpecialOwner == FarmRuntime.DoughKing.Owner then
        local progress = state.SpecialData.DoughProgress
        if progress ~= nil then
            local reply = tostring(progress)
            local remaining = tonumber(string.match(string.lower(reply), "(%d+)%s+enemies?")) or tonumber(string.match(reply, "(%d+)"))
            if remaining then FarmRuntime.SetDoughKingCounter(remaining) end
        end
    elseif not state.DoughCounterLastText then
        FarmRuntime.SetDoughKingCounter("Checking")
    end
end

function FarmRuntime.DoughKing.FindBoss(root)
    return findEnemyNames(root, { "Dough King" }, true)
end

function FarmRuntime.DoughKing.FindThreat(root)
    if not root or not Settings.DoughKingPlayerSafety then return nil end
    if LocalPlayer:GetAttribute("PvpDisabled") == true or LocalPlayer:GetAttribute("InSafeZone") == true then return nil end
    local best, bestDistance
    local radius = math.max(25, tonumber(Settings.DoughKingSafetyRange) or 250)
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player:GetAttribute("PvpDisabled") ~= true and player:GetAttribute("InSafeZone") ~= true then
            local _, humanoid, playerRoot = getCharacter(player)
            if humanoid and humanoid.Health > 0 and playerRoot then
                local distance = (playerRoot.Position - root.Position).Magnitude
                if distance <= radius and (not bestDistance or distance < bestDistance) then
                    best, bestDistance = player, distance
                end
            end
        end
    end
    return best, bestDistance
end

FarmRuntime.UpdateCakeLandSafety = function(owner, root, activityName)
    local threat, distance = FarmRuntime.DoughKing.FindThreat(root)
    if not threat then
        if state.SpecialData.CakeLandRetreating then
            state.SpecialData.CakeLandRetreating = nil
            state.SpecialData.CakeLandRetreatPosition = nil
            if state.TravelMode == "farmCakeRetreat" then stopTravel() end
            showNotice("Player clear - resuming " .. tostring(activityName or "Cake Land"), Green, 3)
        end
        return false
    end
    if not state.SpecialData.CakeLandRetreating then
        state.SpecialData.CakeLandRetreating = true
        state.SpecialData.CakeLandRetreatPosition = Vector3.new(
            root.Position.X,
            root.Position.Y + math.max(100, tonumber(Settings.DoughKingRetreatHeight) or 500),
            root.Position.Z
        )
        showNotice(tostring(threat.Name) .. " is nearby with PvP on - retreating", Red, 5)
    end
    clearSpecialFarm(owner)
    setSpecialStatus("Player safety retreat (" .. tostring(math.floor((distance or 0) + 0.5)) .. " studs)")
    setSpecialTravel(owner, state.SpecialData.CakeLandRetreatPosition, "safe Cake Land height", threat, "farmCakeRetreat")
    return true
end

function FarmRuntime.DoughKing.SearchChests(root)
    local owner = FarmRuntime.DoughKing.Owner
    local chest = findNearestChest(root, true, 1800)
    local part = getPart(chest)
    if part then
        setSpecialStatus("Searching chests for God's Chalice")
        setSpecialTravel(owner, part.Position, "God's Chalice chest", chest, "doughChest")
        return true
    end
    if os.clock() < state.ChestIslandSearchReadyAt then
        setSpecialStatus("Checking this area for God's Chalice")
        return true
    end
    local position, islandKey, islandName = FarmRuntime.FindChestIslandDestination(root)
    if position then
        setSpecialStatus("Searching " .. tostring(islandName) .. " for God's Chalice")
        setSpecialTravel(owner, position + Vector3.new(0, 4, 0), tostring(islandName) .. " chests", islandKey, "doughChestIsland")
        return true
    end
    setSpecialStatus("Waiting for chests to respawn")
    return false
end

function FarmRuntime.DoughKing.Update(root)
    local dough = FarmRuntime.DoughKing
    local owner = dough.Owner
    local now = os.clock()
    state.SpecialData.BlockNormalFarm = true
    local cocoa = FarmRuntime.MaterialCount("Conjured Cocoa")
    FarmRuntime.SetDoughKingCocoa(cocoa)
    if FarmRuntime.UpdateCakeLandSafety(owner, root, "Dough King") then return end

    local boss = dough.FindBoss(root)
    if boss then
        state.SpecialData.DoughBossSeen = true
        FarmRuntime.SetDoughKingCounter("0 - boss active")
        if state.TravelOwner == owner then stopTravel() end
        setSpecialStatus("Defeating Dough King")
        setSpecialFarm(owner, boss.Name, true, boss, nil, false, { SpamRemote = true })
        return
    end
    if state.SpecialData.DoughBossSeen then
        finishSpecialMode(owner, "Dough King defeated")
        return
    end

    local sweetChalice = findOwnedTool("Sweet Chalice") or findOwnedTool("Cake Chalice")
    if not sweetChalice and state.SpecialData.DoughSpawnRequestedAt then
        local elapsed = now - state.SpecialData.DoughSpawnRequestedAt
        if elapsed <= 45 then
            clearSpecialFarm(owner)
            local destination = dough.BossFallback + Vector3.new(0, 8, 0)
            setSpecialStatus("Waiting for Dough King")
            setSpecialTravel(owner, destination, "Dough King", nil, "farmDoughKing")
            return
        end
        state.SpecialData.DoughSpawnRequestedAt = nil
        contextNotice("DoughKingSpawnTimeout", "Dough King spawn was not confirmed; rebuilding the requirements", Red, 5, 8)
    end

    if not sweetChalice then
        if cocoa == nil or cocoa < 10 then
            local enemy = state.SpecialFarm and state.SpecialFarm.Owner == owner and state.SpecialFarm.Target or nil
            local allowed = false
            if enemy and validFarmTarget(enemy) then
                local normalized = normalizeEnemyName(enemy.Name)
                for _, name in ipairs(dough.CocoaEnemyNames) do
                    if normalized == normalizeEnemyName(name) then allowed = true; break end
                end
            end
            if not allowed then enemy = findEnemyNames(root, dough.CocoaEnemyNames, false) end
            if enemy then
                if state.TravelOwner == owner then stopTravel() end
                setSpecialStatus("Farming Conjured Cocoa (" .. tostring(cocoa or 0) .. "/10)")
                setSpecialFarm(owner, enemy.Name, false, enemy, nil, false, {
                    SpamRemote = true,
                    GroupNames = dough.CocoaGroupClusters[normalizeEnemyName(enemy.Name)]
                })
                return
            end
            clearSpecialFarm(owner)
            local spawn = FarmRuntime.CakePrince.NearestReference(root, dough.CocoaEnemyNames)
            local destination = (spawn and spawn.Position or FarmRuntime.CakePrince.MamaFallback)
                + Vector3.new(0, math.max(8, Settings.FarmDistance), 0)
            setSpecialStatus("Finding Conjured Cocoa enemies (" .. tostring(cocoa or 0) .. "/10)")
            setSpecialTravel(owner, destination, "Chocolate Land", spawn, "farmDoughCocoa")
            return
        end
        local godsChalice = findOwnedTool("God's Chalice")
        if not godsChalice then
            clearSpecialFarm(owner)
            dough.SearchChests(root)
            return
        end
        clearSpecialFarm(owner)
        if state.TravelOwner == owner then stopTravel() end
        setSpecialStatus("Buying Sweet Chalice")
        if now >= (state.SpecialData.DoughCraftNext or 0) then
            state.SpecialData.DoughCraftNext = now + 4
            queueSpecialRequest("DoughCraft", owner, function(ok, result)
                if findOwnedTool("Sweet Chalice") or findOwnedTool("Cake Chalice") then
                    showNotice("Sweet Chalice obtained", espColor(Settings.FruitColor), 4)
                    state.SpecialData.DoughProgress = nil
                    state.SpecialData.DoughProgressNext = 0
                elseif not ok then
                    contextNotice("DoughCraftFailed", "Sweet Chalice purchase failed; retrying", Red, 4, 6)
                elseif result ~= nil then
                    contextNotice("DoughCraftReply", tostring(result), Muted, 4, 6)
                end
            end, function() return CommF:InvokeServer("SweetChaliceNpc") end)
        end
        return
    end

    pollSpecialValue(owner, "DoughProgress", 1.25, function()
        return CommF:InvokeServer("CakePrinceSpawner", true)
    end)
    local reply = tostring(state.SpecialData.DoughProgress or "")
    local lower = string.lower(reply)
    local remaining = tonumber(string.match(lower, "(%d+)%s+enemies?")) or tonumber(string.match(reply, "(%d+)"))
    local portalReady = string.find(lower, "open the portal now", 1, true) ~= nil
        or (remaining ~= nil and remaining <= 0)

    if (remaining and remaining > 0) or not portalReady then
        if remaining then FarmRuntime.SetDoughKingCounter(remaining) end
        local enemy = state.SpecialFarm and state.SpecialFarm.Owner == owner and state.SpecialFarm.Target or nil
        local allowed = false
        if enemy and validFarmTarget(enemy) then
            local normalized = normalizeEnemyName(enemy.Name)
            for _, name in ipairs(dough.EnemyNames) do
                if normalized == normalizeEnemyName(name) then allowed = true; break end
            end
        end
        if not allowed then enemy = findEnemyNames(root, dough.EnemyNames, false) end
        if enemy then
            if state.TravelOwner == owner then stopTravel() end
            setSpecialStatus(remaining and ("Preparing Dough King (" .. tostring(remaining) .. " left)") or "Farming Cake Land enemies")
            setSpecialFarm(owner, enemy.Name, false, enemy, nil, false, {
                SpamRemote = true,
                GroupNames = dough.GroupClusters[normalizeEnemyName(enemy.Name)]
            })
            return
        end
        clearSpecialFarm(owner)
        local spawn = FarmRuntime.CakePrince.NearestReference(root, dough.EnemyNames)
        local destination = (spawn and spawn.Position or FarmRuntime.CakePrince.MamaFallback) + Vector3.new(0, math.max(8, Settings.FarmDistance), 0)
        setSpecialStatus(remaining and ("Waiting for Cake Land enemies (" .. tostring(remaining) .. " left)") or "Finding Cake Land enemies")
        setSpecialTravel(owner, destination, "Cake Land", spawn, "farmDoughKing")
        return
    end

    if portalReady then
        FarmRuntime.SetDoughKingCounter(0)
        clearSpecialFarm(owner)
        if state.TravelOwner == owner then stopTravel() end
        setSpecialStatus("Summoning Dough King")
        if now >= (state.SpecialData.DoughSpawnNext or 0) then
            state.SpecialData.DoughSpawnNext = now + 1.5
            queueSpecialRequest("DoughSpawn", owner, function(ok, result)
                if ok then
                    state.SpecialData.DoughSpawnRequestedAt = os.clock()
                    showNotice("Dough King summon requested", nil, 4)
                else
                    contextNotice("DoughSpawnFailed", "Dough King could not be summoned; retrying", Red, 4, 6)
                end
            end, function() return CommF:InvokeServer("CakePrinceSpawner") end)
        end
        return
    end

    clearSpecialFarm(owner)
    if state.TravelOwner == owner then stopTravel() end
    setSpecialStatus(state.SpecialData.DoughProgressError and "Dough King check failed; retrying" or "Checking Dough King progress")
end

local ELITE_OWNER = "AutoEliteHunter"
local ELITE_NAMES = { "Deandre", "Diablo", "Urban" }

local function eliteQuestTarget(snapshot)
    if not snapshot or not snapshot.Active then return nil end
    for _, name in ipairs(ELITE_NAMES) do
        if snapshot.Tasks and snapshot.Tasks[normalizeEnemyName(name)] then return name end
    end
    return nil
end

local function findEliteTarget(root, selected)
    if selected then return findEnemyNames(root, { selected }, false) end
    return findEnemyNames(root, ELITE_NAMES, false)
end

local function findStoredElite(selected)
    local wanted = selected and { selected } or ELITE_NAMES
    for _, name in ipairs(wanted) do
        local model = ReplicatedStorage:FindFirstChild(name)
        local part = model and getPart(model)
        local humanoid = model and getHumanoid(model)
        if model and part and (not humanoid or humanoid.Health > 0) then
            return model, part
        end
    end
    return nil, nil
end

local function rememberEliteReply(result)
    local reply = tostring(result or "")
    local lower = string.lower(reply)
    for _, name in ipairs(ELITE_NAMES) do
        if string.find(lower, string.lower(name), 1, true) then
            state.SpecialData.EliteAssignedName = name
            break
        end
    end
    local island = string.match(reply, "[Ll]ast seen near%s+([^%.]+)")
    if island then
        state.SpecialData.EliteIsland = string.match(island, "^%s*(.-)%s*$")
    end
end

local function queueEliteRequest(key, delay, request)
    if os.clock() < (state.SpecialData.EliteNextRequestAt or 0) then return false end
    state.SpecialData.EliteNextRequestAt = os.clock() + delay
    return queueSpecialRequest(key, ELITE_OWNER, function(ok, result)
        state.SpecialData.EliteLastReply = ok and tostring(result or "") or "Request failed"
        if not ok then
            contextNotice("EliteHunterRequest", "Elite Hunter request failed; retrying", Red, 4, 6)
            return
        end
        rememberEliteReply(result)
        if key == "ElitePoll" or key == "EliteAccept" then
            local reply = string.lower(tostring(result or ""))
            local unavailable = string.find(reply, "come back later", 1, true)
                or string.find(reply, "don't have", 1, true)
                or string.find(reply, "no elite", 1, true)
                or string.find(reply, "not available", 1, true)
            if unavailable then
                setSpecialStatus("Waiting for an Elite Hunter quest")
                contextNotice("Waiting:AutoEliteHunter", "No elite is currently available; checking again", Muted, 4, 8)
            end
        end
    end, request)
end

local function updateEliteHunterAutomation(root)
    state.SpecialData.BlockNormalFarm = true
    local snapshot = currentQuestSnapshot()
    local questTarget = eliteQuestTarget(snapshot)
    local target = findEliteTarget(root, questTarget)

    if questTarget then
        if target then
            if state.TravelOwner == ELITE_OWNER then stopTravel() end
            setSpecialStatus("Defeating " .. questTarget)
            setSpecialFarm(ELITE_OWNER, target.Name, false, target)
            return
        end
        clearSpecialFarm(ELITE_OWNER)
        local stored, storedPart = findStoredElite(questTarget)
        if storedPart then
            local island = state.SpecialData.EliteIsland
            setSpecialStatus("Travelling to " .. questTarget .. (island and (" near " .. island) or ""))
            setSpecialTravel(
                ELITE_OWNER,
                storedPart.Position + Vector3.new(0, math.max(8, Settings.FarmDistance), 0),
                questTarget,
                stored,
                "farmEliteSearch"
            )
        else
            if state.TravelOwner == ELITE_OWNER then stopTravel() end
            setSpecialStatus("Locating " .. questTarget)
            queueEliteRequest("EliteLocate", 3, function()
                return CommF:InvokeServer("EliteHunter")
            end)
        end
        return
    end

    state.SpecialData.EliteAssignedName = nil
    state.SpecialData.EliteIsland = nil
    clearSpecialFarm(ELITE_OWNER)
    if snapshot.Active then
        setSpecialStatus("Clearing the current quest")
        queueEliteRequest("EliteAbandon", 1, function()
            return CommF:InvokeServer("AbandonQuest")
        end)
        return
    end

    if target then
        setSpecialStatus("Accepting the Elite Hunter quest")
        queueEliteRequest("EliteAccept", 1.5, function()
            return CommF:InvokeServer("EliteHunter")
        end)
        return
    end

    setSpecialStatus("Checking for an Elite Hunter quest")
    queueEliteRequest("ElitePoll", 4, function()
        return CommF:InvokeServer("EliteHunter")
    end)
end

local function updateFactoryAutomation(root)
    local owner = "AutoFactory"
    local core = findEnemyNames(root, { "Core" }, false)
    if core then
        state.SpecialData.FactorySeen = true
        setSpecialStatus("Attacking Factory Core")
        setSpecialFarm(owner, core.Name, false, core)
        return
    end
    clearSpecialFarm(owner)
    if state.TravelOwner == owner then stopTravel() end
    setSpecialStatus("The Factory isn't being raided")
end

local function updatePirateRaidAutomation(root)
    local owner = "AutoPirateRaid"
    local enemy, count, center, castle = FarmRuntime.FindPirateRaidEnemy(root)
    if enemy then
        state.PirateRaidDetectedUntil = os.clock() + 12
        if state.TravelOwner == owner then stopTravel() end
        setSpecialStatus("Clearing Pirate Raid (" .. tostring(count) .. " remaining)")
        setSpecialFarm(owner, enemy.Name, false, enemy, nil, false, {
            SpamRemote = true,
            GroupAll = true,
            GroupOrigin = center,
            GroupRange = FarmRuntime.PirateRaid.Radius
        })
        return
    end

    clearSpecialFarm(owner)
    if os.clock() < state.PirateRaidDetectedUntil then
        if (root.Position - center).Magnitude > 120 then
            setSpecialStatus("Waiting for the next Pirate Raid wave")
            setSpecialTravel(owner, center + Vector3.new(0, 8, 0), "Castle on the Sea", castle, "farmPirateRaid")
        else
            if state.TravelOwner == owner then stopTravel() end
            setSpecialStatus("Waiting for the next Pirate Raid wave")
        end
    else
        if state.TravelOwner == owner then stopTravel() end
        setSpecialStatus("Waiting for a Pirate Raid")
    end
end

local bartiloQuest = { Id = "BartiloQuest", Tier = 1, Level = 850, Name = "Swan Pirates", Target = "Swan Pirate", Count = 50 }
local bartiloJeremyFallback = Vector3.new(2203.77, 448.97, 752.73)

local function bartiloJeremyDestination(root)
    local cached = state.SpecialData.BartiloJeremySpawn
    if cached and cached.Parent and cached:IsA("BasePart") then return cached.Position, cached end
    local spawn = nearestEnemySpawn(root, "Jeremy")
    if not spawn then
        local origin = workspace:FindFirstChild("_WorldOrigin")
        local folder = origin and origin:FindFirstChild("EnemySpawns")
        local bestDistance
        if folder then
            for _, part in ipairs(folder:GetDescendants()) do
                if part:IsA("BasePart") and normalizeEnemyName(part:GetAttribute("DisplayName") or part.Name) == "Jeremy" then
                    local distance = root and (part.Position - root.Position).Magnitude or 0
                    if not bestDistance or distance < bestDistance then
                        spawn, bestDistance = part, distance
                    end
                end
            end
        end
    end
    if spawn then
        state.SpecialData.BartiloJeremySpawn = spawn
        return spawn.Position, spawn
    end
    return bartiloJeremyFallback, nil
end

local function touchBartiloPlate(root, plate)
    if root and plate and plate:IsA("BasePart") and firetouchinterest then
        pcall(function()
            firetouchinterest(root, plate, 0)
            firetouchinterest(root, plate, 1)
        end)
    end
end

local function updateBartiloAutomation(root)
    local owner = "AutoBartilo"
    if playerLevel() < 850 then
        state.BartiloPuzzleNoclip = false
        clearSpecialFarm(owner)
        setSpecialStatus("You need Level 850 for the Bartilo quest")
        return
    end
    pollSpecialValue(owner, "Bartilo", 1.5, function() return CommF:InvokeServer("BartiloQuestProgress", "Bartilo") end)
    if state.SpecialData.BartiloError then
        state.BartiloPuzzleNoclip = false
        clearSpecialFarm(owner)
        setSpecialStatus("Could not check the Bartilo quest")
        contextNotice("Waiting:AutoBartiloRemote", "Could not check the Bartilo quest; retrying", Red, 4, 8)
        return
    end
    local progress = tonumber(state.SpecialData.Bartilo)
    if progress == nil then setSpecialStatus("Checking Bartilo progress"); return end
    state.BartiloPuzzleNoclip = progress == 2
    if progress >= 3 then finishSpecialMode(owner, "Bartilo quest completed"); return end
    if progress == 0 then
        local snapshot = currentQuestSnapshot()
        if snapshot.Active and snapshot.Id == "BartiloQuest" then
            setSpecialStatus("Defeating Swan Pirates")
            setSpecialFarm(owner, "Swan Pirate", false, nil, bartiloQuest, true)
            return
        end
        if snapshot.Active then
            clearSpecialFarm(owner)
            setSpecialStatus("Clearing the current quest")
            queueSpecialRequest("BartiloAbandon", owner, function() state.SpecialData.BartiloNext = 0 end,
                function() return CommF:InvokeServer("AbandonQuest") end)
            return
        end
        local npc = findSpecialNpc("Bartilo")
        local destination = npc and getPart(npc).Position or sea2Location("Café")
        if destination and (root.Position - destination).Magnitude > 10 then
            setSpecialStatus("Moving to Bartilo")
            setSpecialTravel(owner, destination + Vector3.new(0, 3, 0), "Bartilo", npc)
        else
            clearSpecialFarm(owner)
            if state.TravelOwner == owner then stopTravel() end
            setSpecialStatus("Accepting Bartilo quest")
            queueSpecialRequest("BartiloStart", owner, function(ok)
                if ok then state.SpecialData.BartiloNext = 0 end
            end, function() return CommF:InvokeServer("StartQuest", "BartiloQuest", 1) end)
        end
        return
    end
    if progress == 1 then
        if not state.SpecialData.BartiloJeremyReady then
            clearSpecialFarm(owner)
            local npc = findSpecialNpc("Bartilo")
            local npcPart = npc and getPart(npc)
            local destination = npcPart and npcPart.Position or sea2Location("Café")
            if destination and (root.Position - destination).Magnitude > 10 then
                setSpecialStatus("Returning to Bartilo")
                setSpecialTravel(owner, destination + Vector3.new(0, 3, 0), "Bartilo", npc)
            else
                if state.TravelOwner == owner then stopTravel() end
                setSpecialStatus("Speaking to Bartilo")
                queueSpecialRequest("BartiloJeremyStart", owner, function(ok)
                    if ok then
                        state.SpecialData.BartiloJeremyReady = true
                        state.SpecialData.BartiloNext = 0
                    else
                        contextNotice("Waiting:BartiloJeremy", "Could not continue the Bartilo quest; retrying", Red, 4, 6)
                    end
                end, function() return CommF:InvokeServer("BartiloQuestProgress", "Bartilo") end)
            end
            return
        end
        local jeremy = findEnemyNames(root, { "Jeremy" }, true)
        if jeremy then
            setSpecialStatus("Defeating Jeremy")
            setSpecialFarm(owner, "Jeremy", true, jeremy)
            return
        end
        clearSpecialFarm(owner)
        local destination, spawn = bartiloJeremyDestination(root)
        if (root.Position - destination).Magnitude > 35 then
            setSpecialStatus("Moving to Jeremy")
            setSpecialTravel(owner, destination + Vector3.new(0, 8, 0), "Jeremy", spawn)
        else
            if state.TravelOwner == owner then stopTravel() end
            setSpecialStatus("Waiting for Jeremy")
        end
        return
    end
    if progress == 2 then
        clearSpecialFarm(owner)
        local index = state.BartiloPlate
        if index > 8 then
            if not state.SpecialData.BartiloPuzzleCompletedAt then
                state.SpecialData.BartiloPuzzleCompletedAt = os.clock()
                state.SpecialData.BartiloNext = 0
            elseif os.clock() - state.SpecialData.BartiloPuzzleCompletedAt >= 5 then
                state.BartiloPlate = 1
                state.SpecialData.BartiloPlateRouteStage = "Rise"
                state.SpecialData.BartiloPlateTouchIndex = nil
                state.SpecialData.BartiloPlateReadyAt = nil
                state.SpecialData.BartiloPuzzleCompletedAt = nil
                state.SpecialData.BartiloNext = 0
                contextNotice("Waiting:BartiloPuzzle", "The Colosseum puzzle did not confirm; retrying the sequence", Red, 5, 6)
            end
            if state.TravelOwner == owner then stopTravel() end
            setSpecialStatus("Confirming Colosseum puzzle")
            return
        end

        local plates = workspace:FindFirstChild("Map")
        plates = plates and plates:FindFirstChild("Dressrosa")
        plates = plates and plates:FindFirstChild("BartiloPlates")
        local plate = plates and plates:FindFirstChild("Plate" .. tostring(index), true)
        if not plate or not plate:IsA("BasePart") then
            if state.TravelOwner == owner then stopTravel() end
            setSpecialStatus("Waiting for Colosseum plates")
            contextNotice("Waiting:BartiloPlates", "The Colosseum plates are not loaded yet", Red, 4, 8)
            return
        end

        setSpecialStatus("Opening Colosseum " .. tostring(index) .. "/8")
        local stage = state.SpecialData.BartiloPlateRouteStage or "Rise"
        local safeY = math.max(plate.Position.Y + 35, 52)
        if stage == "Rise" then
            local destination = Vector3.new(root.Position.X, safeY, root.Position.Z)
            if math.abs(root.Position.Y - safeY) <= 2 then
                if state.TravelOwner == owner then stopTravel() end
                state.SpecialData.BartiloPlateRouteStage = "Cross"
            else
                setSpecialTravel(owner, destination, "Above Colosseum")
            end
            return
        end

        if stage == "Cross" then
            local destination = Vector3.new(plate.Position.X, safeY, plate.Position.Z)
            if (root.Position - destination).Magnitude <= 3 then
                if state.TravelOwner == owner then stopTravel() end
                state.SpecialData.BartiloPlateRouteStage = "Descend"
            else
                setSpecialTravel(owner, destination, "Above Plate " .. tostring(index))
            end
            return
        end

        local position = plate.Position + Vector3.new(0, 2, 0)
        if (root.Position - position).Magnitude > 3 then
            setSpecialTravel(owner, position, "Plate " .. tostring(index), plate)
            return
        end

        if state.TravelOwner == owner then stopTravel() end
        root.AssemblyLinearVelocity = Vector3.zero
        root.CFrame = CFrame.new(position) * (root.CFrame - root.Position)
        if state.SpecialData.BartiloPlateTouchIndex ~= index then
            state.SpecialData.BartiloPlateTouchIndex = index
            state.SpecialData.BartiloPlateReadyAt = os.clock() + 0.8
            touchBartiloPlate(root, plate)
        elseif os.clock() >= (state.SpecialData.BartiloPlateReadyAt or 0) then
            touchBartiloPlate(root, plate)
            state.BartiloPlate = index + 1
            state.SpecialData.BartiloPlateRouteStage = "Rise"
            state.SpecialData.BartiloPlateTouchIndex = nil
            state.SpecialData.BartiloPlateReadyAt = nil
            state.SpecialData.BartiloNext = 0
        end
    end
end

FarmRuntime.FindRaceV2Flower = function(index, root)
    local aliases = index == 1
        and { "Flower1", "Flower 1", "BlueFlower", "Blue Flower" }
        or { "Flower2", "Flower 2", "RedFlower", "Red Flower" }
    local cached = state.SpecialData["RaceFlower" .. tostring(index)]
    local cachedPart = getPart(cached)
    if cachedPart and cachedPart:IsDescendantOf(workspace) and cachedPart.Transparency < 0.95 then
        return cached, cachedPart
    end

    state.SpecialData["RaceFlower" .. tostring(index)] = nil
    for _, alias in ipairs(aliases) do
        local object = workspace:FindFirstChild(alias, true)
        local part = getPart(object)
        if part and part:IsDescendantOf(workspace) and part.Transparency < 0.95
            and (not LocalPlayer.Character or not part:IsDescendantOf(LocalPlayer.Character))
        then
            state.SpecialData["RaceFlower" .. tostring(index)] = object
            return object, part
        end
    end

    local wanted = index == 1 and "flower1" or "flower2"
    local best, bestPart, bestDistance
    for _, object in ipairs(workspace:GetDescendants()) do
        local compactName = string.lower(object.Name):gsub("[^%w]", "")
        if compactName == wanted or (index == 1 and compactName == "blueflower")
            or (index == 2 and compactName == "redflower")
        then
            local part = getPart(object)
            if part and part:IsDescendantOf(workspace) and part.Transparency < 0.95
                and (not LocalPlayer.Character or not part:IsDescendantOf(LocalPlayer.Character))
            then
                local distance = root and (part.Position - root.Position).Magnitude or 0
                if not bestDistance or distance < bestDistance then
                    best, bestPart, bestDistance = object, part, distance
                end
            end
        end
    end
    state.SpecialData["RaceFlower" .. tostring(index)] = best
    return best, bestPart
end

FarmRuntime.CollectRaceV2Flower = function(owner, root, index, colorName)
    local object, part = FarmRuntime.FindRaceV2Flower(index, root)
    if not object or not part then
        if state.TravelOwner == owner and state.TravelMode == "farmRaceFlower"
            and state.SpecialData.RaceFlowerTravelIndex == index
        then
            stopTravel()
            state.SpecialData.RaceFlowerTravelIndex = nil
        end
        return false
    end

    clearSpecialFarm(owner)
    local destination = part.Position + Vector3.new(0, 2.25, 0)
    state.SpecialData.RaceFlowerTravelIndex = index
    if (root.Position - destination).Magnitude > 3 then
        setSpecialStatus("Moving to " .. colorName .. " Flower")
        setSpecialTravel(owner, destination, colorName .. " Flower", object, "farmRaceFlower")
    else
        if state.TravelOwner == owner then stopTravel() end
        root.AssemblyLinearVelocity = Vector3.zero
        touchTravelObject(root, object)
        state.SpecialData.RaceFlowerTouchAt = os.clock()
        setSpecialStatus("Collecting " .. colorName .. " Flower")
    end
    return true
end

local function updateRaceV2Automation(root)
    local owner = "AutoRaceV2"
    if playerLevel() < 850 then clearSpecialFarm(owner); setSpecialStatus("You need Level 850 for Race V2"); return end
    pollSpecialValue(owner, "Alchemist", 1.5, function() return CommF:InvokeServer("Alchemist", "1") end)
    if state.SpecialData.AlchemistError then
        clearSpecialFarm(owner)
        setSpecialStatus("Could not check Race V2 progress")
        contextNotice("Waiting:AutoRaceV2Remote", "Could not check Race V2 progress; retrying", Red, 4, 8)
        return
    end
    local progress = tonumber(state.SpecialData.Alchemist)
    if progress == nil then setSpecialStatus("Checking Race V2 progress"); return end
    if progress == -2 then finishSpecialMode(owner, "Race V2 completed"); return end
    if progress == 5 then finishSpecialMode(owner, "Your current race cannot use the Alchemist"); return end
    local npc = findSpecialNpc("Alchemist")
    local destination = npc and getPart(npc).Position or sea2Location("Green Zone")
    if progress == 0 then
        clearSpecialFarm(owner)
        if destination and (root.Position - destination).Magnitude > 10 then
            setSpecialStatus("Moving to Alchemist")
            setSpecialTravel(owner, destination + Vector3.new(0, 3, 0), "Alchemist", npc)
        else
            if state.TravelOwner == owner then stopTravel() end
            setSpecialStatus("Starting flower quest")
            queueSpecialRequest("AlchemistStart", owner, function() state.SpecialData.AlchemistNext = 0 end,
                function() return CommF:InvokeServer("Alchemist", "2") end)
        end
        return
    end
    if progress == 1 then
        local flowerOne = findOwnedTool("Flower 1")
        local flowerTwo = findOwnedTool("Flower 2")
        local flowerThree = findOwnedTool("Flower 3")
        local travellingIndex = state.SpecialData.RaceFlowerTravelIndex
        if travellingIndex and ((travellingIndex == 1 and flowerOne) or (travellingIndex == 2 and flowerTwo)) then
            if state.TravelOwner == owner and state.TravelMode == "farmRaceFlower" then stopTravel() end
            state.SpecialData.RaceFlowerTravelIndex = nil
        end
        if not flowerOne and FarmRuntime.CollectRaceV2Flower(owner, root, 1, "Blue") then
            return
        end
        if not flowerTwo and FarmRuntime.CollectRaceV2Flower(owner, root, 2, "Red") then
            return
        end
        if not flowerThree then
            if state.TravelOwner == owner and state.TravelMode == "farmRaceFlower" then stopTravel() end
            local enemy = nearestAnyEnemy(root)
            if enemy then
                setSpecialStatus("Farming Yellow Flower")
                setSpecialFarm(owner, enemy.Name, false, enemy)
            else
                clearSpecialFarm(owner)
                setSpecialStatus("Waiting for an enemy for Yellow Flower")
            end
        elseif flowerOne and flowerTwo then
            clearSpecialFarm(owner)
            if state.TravelOwner == owner then stopTravel() end
            state.SpecialData.AlchemistNext = 0
            setSpecialStatus("Confirming flowers")
        else
            clearSpecialFarm(owner)
            local missing = not flowerOne and not flowerTwo and "Blue or Red"
                or not flowerOne and "Blue"
                or "Red"
            setSpecialStatus("Waiting for " .. missing .. " Flower to spawn")
        end
        return
    end
    if progress == 2 then
        clearSpecialFarm(owner)
        if destination and (root.Position - destination).Magnitude > 10 then
            setSpecialStatus("Returning to Alchemist")
            setSpecialTravel(owner, destination + Vector3.new(0, 3, 0), "Alchemist", npc)
        else
            if state.TravelOwner == owner then stopTravel() end
            setSpecialStatus("Buying Race V2")
            queueSpecialRequest("AlchemistBuy", owner, function(ok, result)
                if ok and result == -2 then finishSpecialMode(owner, "Race V2 completed") else state.SpecialData.AlchemistNext = 0 end
            end, function() return CommF:InvokeServer("Alchemist", "3") end)
        end
    end
end

local function updateRaceV3Automation(root)
    local owner = "AutoRaceV3"
    if playerLevel() < 1000 then clearSpecialFarm(owner); setSpecialStatus("You need Level 1000 for Race V3"); return end
    pollSpecialValue(owner, "Wenlock", 1.5, function() return CommF:InvokeServer("Wenlocktoad", "1") end)
    if state.SpecialData.WenlockError then
        clearSpecialFarm(owner)
        setSpecialStatus("Could not check Race V3 progress")
        contextNotice("Waiting:AutoRaceV3Remote", "Could not check Race V3 progress; retrying", Red, 4, 8)
        return
    end
    local progress = tonumber(state.SpecialData.Wenlock)
    if progress == nil then
        clearSpecialFarm(owner)
        if state.SpecialRequestBusy.Wenlock then
            setSpecialStatus("Checking Race V3 progress")
        else
            setSpecialStatus("Complete Race V2 before starting Race V3")
            contextNotice("RaceV3Prerequisite", "Complete Race V2 before starting Race V3", Red, 5, 8)
        end
        return
    end
    if progress == -2 then finishSpecialMode(owner, "Race V3 is already unlocked"); return end
    if progress == -1 then
        clearSpecialFarm(owner)
        setSpecialStatus("You need $2,000,000 for Race V3")
        contextNotice("RaceV3Money", "You need $2,000,000 for Race V3", Red, 5, 8)
        return
    end
    if progress == 0 then
        clearSpecialFarm(owner)
        setSpecialStatus("Starting Race V3 quest")
        queueSpecialRequest("WenlockStart", owner, function()
            state.SpecialData.WenlockNext = 0
            state.SpecialData.WenlockInfoNext = 0
        end, function() return CommF:InvokeServer("Wenlocktoad", "2") end)
        return
    end
    if progress == 2 then
        clearSpecialFarm(owner)
        setSpecialStatus("Buying Race V3")
        queueSpecialRequest("WenlockBuy", owner, function(ok)
            if ok then
                state.SpecialData.WenlockNext = 0
                task.delay(1, function()
                    if state.Alive and Settings.AutoRaceV3 then state.SpecialData.WenlockNext = 0 end
                end)
            end
        end, function() return CommF:InvokeServer("Wenlocktoad", "3") end)
        return
    end
    if progress ~= 1 then
        clearSpecialFarm(owner)
        setSpecialStatus("Race V3 is unavailable for the current race")
        return
    end

    pollSpecialValue(owner, "WenlockInfo", 2, function() return CommF:InvokeServer("Wenlocktoad", "info") end)
    local race = string.lower(currentRace())
    if race == "human" then
        local target = findEnemyNames(root, { "Diamond", "Jeremy", "Fajita" }, true)
        if target then
            setSpecialStatus("Completing Human V3 requirement")
            setSpecialFarm(owner, target.Name, true, target)
        else
            clearSpecialFarm(owner)
            setSpecialStatus("Waiting for Diamond, Jeremy, or Fajita")
        end
        return
    end

    clearSpecialFarm(owner)
    local taskText = tostring(state.SpecialData.WenlockInfo or "Complete your race requirement")
    if race == "rabbit" or race == "mink" then
        setSpecialStatus("Race V3: collect 30 chests")
        contextNotice("RaceV3Task", "Race V3 requires collecting 30 chests", Muted, 5, 8)
    elseif race == "shark" or race == "fishman" then
        setSpecialStatus("Race V3: defeat a Sea Beast")
        contextNotice("RaceV3Task", "Race V3 requires defeating a Sea Beast", Muted, 5, 8)
    elseif race == "angel" or race == "skypiea" then
        setSpecialStatus("Race V3: defeat another Angel player")
        contextNotice("RaceV3Task", "Race V3 requires defeating another Angel player", Muted, 5, 8)
    elseif race == "ghoul" then
        setSpecialStatus("Race V3: defeat five players")
        contextNotice("RaceV3Task", "Race V3 requires defeating five players", Muted, 5, 8)
    elseif race == "cyborg" then
        setSpecialStatus("Race V3: give a physical fruit")
        contextNotice("RaceV3Task", "Race V3 requires giving a physical fruit to arowe", Muted, 5, 8)
    else
        setSpecialStatus(taskText)
    end
end

local function highestRaidIsland(root)
    local best, bestIndex
    local _, islands = raidIslandCluster(root)
    for _, island in ipairs(islands) do
        if not bestIndex or island.Index > bestIndex then
            best, bestIndex = island.Part, island.Index
        end
    end
    return best, bestIndex
end

local function updateRaidAutomation(root)
    local owner = "RaidAutoClear"
    if not FarmRuntime.RaidContextActive(root) then
        clearSpecialFarm(owner)
        if state.TravelOwner == owner then stopTravel() end
        state.SpecialData.RaidHoldPosition = nil
        state.SpecialData.RaidIslandIndex = nil
        state.SpecialData.RaidClusterAnchor = nil
        state.SpecialData.RaidClusterId = nil
        state.SpecialData.RaidRetreating = nil
        state.SpecialData.RaidRetreatPosition = nil
        setSpecialStatus("You are not currently in a raid")
        return
    end
    local _, ownedIslands = raidIslandCluster(root)
    if #ownedIslands == 0 then
        clearSpecialFarm(owner)
        if state.TravelOwner == owner then stopTravel() end
        state.SpecialData.RaidHoldPosition = nil
        state.SpecialData.RaidIslandIndex = nil
        setSpecialStatus("Waiting for your raid island")
        return
    end
    if state.RaidStartedAt <= 0 then state.RaidStartedAt = os.clock() end
    local _, humanoid = getCharacter(LocalPlayer)
    if Settings.RaidLowHealthRetreat and humanoid and humanoid.Health > 0 then
        local maximumHealth = math.max(1, humanoid.MaxHealth)
        local triggerHealth = math.min(math.max(1, Settings.RaidRetreatHealth), maximumHealth * 0.9)
        local resumeHealth = math.min(maximumHealth, triggerHealth + math.max(250, maximumHealth * 0.1))
        if not state.SpecialData.RaidRetreating and humanoid.Health <= triggerHealth then
            state.SpecialData.RaidRetreating = true
            state.SpecialData.RaidRetreatPosition = nil
            showNotice("Low health - retreating to the sky", Red, 4)
        elseif state.SpecialData.RaidRetreating and humanoid.Health >= resumeHealth then
            state.SpecialData.RaidRetreating = nil
            state.SpecialData.RaidRetreatPosition = nil
            if state.TravelMode == "farmRaidRetreat" then stopTravel() end
            showNotice("Health recovered - resuming raid", Green, 4)
        end
        if state.SpecialData.RaidRetreating then
            clearSpecialFarm(owner)
            local retreatPosition = state.SpecialData.RaidRetreatPosition
            if not retreatPosition then
                local island = highestRaidIsland(root)
                local basePosition = island and island.Position or root.Position
                retreatPosition = Vector3.new(
                    basePosition.X,
                    math.max(root.Position.Y, basePosition.Y + math.max(100, Settings.RaidRetreatHeight)),
                    basePosition.Z
                )
                state.SpecialData.RaidRetreatPosition = retreatPosition
            end
            setSpecialStatus("Recovering health in the sky")
            setSpecialTravel(owner, retreatPosition, "safe raid height", nil, "farmRaidRetreat")
            return
        end
    elseif state.SpecialData.RaidRetreating then
        state.SpecialData.RaidRetreating = nil
        state.SpecialData.RaidRetreatPosition = nil
        if state.TravelMode == "farmRaidRetreat" then stopTravel() end
    end
    local island, islandIndex = highestRaidIsland(root)
    if island and islandIndex then
        local previousIndex = state.SpecialData.RaidIslandIndex
        if previousIndex ~= islandIndex then
            state.SpecialData.RaidIslandIndex = islandIndex
            state.SpecialData.RaidHoldPosition = nil
            clearSpecialFarm(owner)
            if previousIndex and islandIndex > previousIndex then
                showNotice("Raid Island " .. tostring(islandIndex) .. " unlocked", espColor(Settings.SeaColor), 4)
            end
        end
        local islandHold = island.Position + Vector3.new(0, math.max(18, Settings.FarmDistance), 0)
        state.SpecialData.RaidHoldPosition = islandHold
    end
    if Settings.RaidTargetBoss then
        local boss, bossPart, loaded, confirmed = FarmRuntime.RaidBossTarget(root)
        if boss and bossPart then
            if loaded then
                if state.TravelOwner == owner then stopTravel() end
                setSpecialStatus("Targeting " .. normalizeEnemyName(boss.Name))
                setSpecialFarm(owner, boss.Name, confirmed, boss)
            else
                clearSpecialFarm(owner)
                setSpecialStatus("Moving to " .. normalizeEnemyName(boss.Name))
                setSpecialTravel(
                    owner,
                    bossPart.Position + Vector3.new(0, math.max(8, Settings.FarmDistance), 0),
                    boss.Name,
                    boss,
                    "farmRaidBoss"
                )
            end
            return
        end
    end
    local enemy
    local lockedTarget = state.SpecialFarm and state.SpecialFarm.Owner == owner and state.SpecialFarm.Target or nil
    local lockedValid, lockedPart = validFarmTarget(lockedTarget)
    if lockedValid and (not island or (lockedPart.Position - island.Position).Magnitude <= 2500) then
        enemy = lockedTarget
    else
        enemy = nearestRaidEnemy(root, island)
    end
    if enemy then
        if state.TravelOwner == owner then stopTravel() end
        setSpecialStatus("Clearing " .. normalizeEnemyName(enemy.Name))
        setSpecialFarm(owner, enemy.Name, false, enemy, nil, false, island and {
            GroupAll = true,
            GroupOrigin = island.Position,
            GroupRange = 2500
        } or nil)
        return
    end
    clearSpecialFarm(owner)
    local storedEnemy, storedPart = FarmRuntime.StoredRaidTarget(root, island)
    if storedPart then
        setSpecialStatus("Moving to " .. normalizeEnemyName(storedEnemy.Name))
        setSpecialTravel(
            owner,
            storedPart.Position + Vector3.new(0, math.max(8, Settings.FarmDistance), 0),
            storedEnemy.Name,
            storedEnemy,
            "farmRaidSearch"
        )
        return
    end
    if not island then
        local holdPosition = state.SpecialData.RaidHoldPosition or root.Position
        state.SpecialData.RaidHoldPosition = holdPosition
        setSpecialTravel(owner, holdPosition, "raid position", nil, "farmRaidHold")
        setSpecialStatus("Waiting for the next raid island")
        return
    end
    local holdPosition = island.Position + Vector3.new(0, math.max(18, Settings.FarmDistance), 0)
    state.SpecialData.RaidHoldPosition = holdPosition
    if (root.Position - holdPosition).Magnitude > 2 then
        setSpecialStatus("Moving to " .. island.Name)
    else
        setSpecialStatus("Waiting for enemies on " .. island.Name)
    end
    setSpecialTravel(owner, holdPosition, island.Name, island, "farmRaidHold")
end

local function updateDropGoalAutomation(root)
    local owner = "AutoDropGoal"
    local goal = Settings.DropGoal
    local definition = dropGoals[goal]
    if not definition then finishSpecialMode(owner, "Choose a valid drop goal"); return end
    if findOwnedTool(goal) or table.find(state.RecentDrops, goal) then finishSpecialMode(owner, goal .. " obtained"); return end
    local target = findEnemyNames(root, { definition.Target }, definition.Boss)
    if target then
        setSpecialStatus("Farming " .. goal)
        setSpecialFarm(owner, target.Name, definition.Boss, target)
        return
    end
    clearSpecialFarm(owner)
    setSpecialStatus("Waiting for " .. definition.Target)
end

local function updateSea3Automation(root)
    local owner = "AutoSea3"
    if playerLevel() < 1500 then clearSpecialFarm(owner); setSpecialStatus("You need Level 1500 for the Third Sea"); return end
    pollSpecialValue(owner, "ZCheck", 1.5, function() return CommF:InvokeServer("ZQuestProgress", "Check") end)
    pollSpecialValue(owner, "ZZou", 1.5, function() return CommF:InvokeServer("ZQuestProgress", "Zou") end)
    if state.SpecialData.ZCheckError or state.SpecialData.ZZouError then
        clearSpecialFarm(owner)
        setSpecialStatus("Could not check Third Sea progress")
        contextNotice("Waiting:AutoSea3Remote", "Could not check Third Sea progress; retrying", Red, 4, 8)
        return
    end
    local check, zou = tonumber(state.SpecialData.ZCheck), tonumber(state.SpecialData.ZZou)
    if zou == 0 then
        clearSpecialFarm(owner)
        if state.SpecialData.ZTravelCharacter == LocalPlayer.Character then
            setSpecialStatus("Waiting for Third Sea transfer")
            contextNotice("Waiting:TravelZou", "Third Sea transfer requested; it will not be repeated", Muted, 4, 8)
            return
        end
        state.SpecialData.ZTravelCharacter = LocalPlayer.Character
        setSpecialStatus("Entering Third Sea")
        queueSpecialRequest("TravelZou", owner, function(ok)
            if ok then
                showNotice("Entering Third Sea", nil, 5)
            else
                contextNotice("TravelZouFailed", "Third Sea transfer failed; toggle Auto Third Sea to retry", Red, 5, 4)
            end
        end, function() return CommF:InvokeServer("TravelZou") end)
        return
    end
    if check == 0 then
        local target = findEnemyNames(root, { "rip_indra", "rip_indra True Form" }, false)
        if target then
            setSpecialStatus("Defeating rip_indra")
            -- This quest instance is tagged BasicMob and has no Boss attribute,
            -- so boss-only reacquisition rejects it before combat can begin.
            setSpecialFarm(owner, target.Name, false, target)
            return
        end
        clearSpecialFarm(owner)
        if state.SpecialData.ZBeginCharacter == LocalPlayer.Character then
            setSpecialStatus("Waiting for rip_indra")
            return
        end
        state.SpecialData.ZBeginCharacter = LocalPlayer.Character
        setSpecialStatus("Going to rip_indra")
        queueSpecialRequest("ZBegin", owner, function(ok)
            state.SpecialData.ZCheckNext = 0
            state.SpecialData.ZZouNext = 0
            if not ok then
                contextNotice("ZBeginFailed", "Could not start the rip_indra quest; toggle Auto Third Sea to retry", Red, 5, 4)
            end
        end, function() return CommF:InvokeServer("ZQuestProgress", "Begin") end)
        return
    end
    if check == 1 then
        clearSpecialFarm(owner)
        setSpecialStatus("Third Sea unlocked - waiting for Mr. Captain")
        contextNotice("Waiting:Sea3Captain", "Third Sea unlocked; waiting for Mr. Captain transfer", Muted, 4, 8)
        return
    end
    if check == nil then
        setSpecialStatus("Checking Third Sea progress")
    else
        clearSpecialFarm(owner)
        setSpecialStatus("Defeat Don Swan before starting the Third Sea quest")
        contextNotice("Waiting:AutoSea3DonSwan", "Defeat Don Swan before starting the Third Sea quest", Red, 5, 10)
    end
end

local shipEnemies = { "Ship Deckhand", "Ship Engineer", "Ship Steward", "Ship Officer" }
local function updateGhoulAutomation(root)
    local owner = "AutoGhoul"
    if string.lower(currentRace()) == "ghoul" then finishSpecialMode(owner, "Ghoul race acquired"); return end
    if playerLevel() < 1000 then clearSpecialFarm(owner); setSpecialStatus("You need Level 1000 for the Ghoul race"); return end
    pollSpecialValue(owner, "Ectoplasm", 1.5, function() return CommF:InvokeServer("Ectoplasm", "Check") end)
    pollSpecialValue(owner, "GhoulCheck", 2, function() return CommF:InvokeServer("Ectoplasm", "BuyCheck", 4) end)
    if state.SpecialData.EctoplasmError or state.SpecialData.GhoulCheckError then
        clearSpecialFarm(owner)
        setSpecialStatus("Could not check the Ghoul race requirements")
        contextNotice("Waiting:AutoGhoulRemote", "Could not check the Ghoul race requirements; retrying", Red, 4, 8)
        return
    end
    local ectoplasm = tonumber(state.SpecialData.Ectoplasm) or 0
    local torch = findOwnedTool("Hellfire Torch")
    local buyCheck = tonumber(state.SpecialData.GhoulCheck)
    if torch and ectoplasm >= 100 then
        clearSpecialFarm(owner)
        setSpecialStatus("Buying Ghoul race")
        local action = buyCheck == 1 and "Change" or "Buy"
        queueSpecialRequest("GhoulBuy", owner, function(ok, result)
            if ok and tonumber(result) == 1 then
                finishSpecialMode(owner, "Ghoul race acquired")
            else
                state.SpecialData.GhoulCheckNext = 0
                state.SpecialData.EctoplasmNext = 0
            end
        end, function() return CommF:InvokeServer("Ectoplasm", action, 4) end)
        return
    end
    local captain = findEnemyNames(root, { "Cursed Captain" }, true)
    if captain then
        setSpecialStatus("Defeating Cursed Captain")
        setSpecialFarm(owner, captain.Name, true, captain)
        return
    end
    if ectoplasm < 100 then
        local enemy = findEnemyNames(root, shipEnemies, false)
        if enemy then
            setSpecialStatus("Farming Ectoplasm " .. tostring(ectoplasm) .. "/100")
            setSpecialFarm(owner, enemy.Name, false, enemy)
            return
        end
    end
    clearSpecialFarm(owner)
    local ship = sea2Location("Cursed Ship")
    if ship and (root.Position - ship).Magnitude > 80 then
        setSpecialStatus(ectoplasm < 100 and "Moving to Cursed Ship" or "Waiting for Cursed Captain")
        setSpecialTravel(owner, ship + Vector3.new(0, 8, 0), "Cursed Ship")
    else
        setSpecialStatus(ectoplasm < 100 and ("Waiting for ship enemies " .. tostring(ectoplasm) .. "/100") or "Waiting for Cursed Captain")
    end
end

local cyborgButtonFallback = Vector3.new(-5553.21, 224.32, -5930.35)

local function cyborgButton()
    local map = workspace:FindFirstChild("Map")
    local circle = map and map:FindFirstChild("CircleIsland")
    local summon = circle and circle:FindFirstChild("RaidSummon")
    local button = summon and summon:FindFirstChild("Button", true)
    local detector = button and button:FindFirstChildWhichIsA("ClickDetector", true)
    return detector, detector and detector.Parent
end

local cyborgItemNames = {
    Fist = "Fist of Darkness",
    Brain = "Core Brain",
    Chip = "Microchip"
}

FarmRuntime.DetectCyborgFistInserted = function(check)
    local code = tonumber(check)
    if (code and code > 0) or check == true then return true end
    local function meaningful(value)
        if type(value) == "boolean" then return value end
        if type(value) == "number" then return value > 0 end
        if type(value) == "string" then
            value = string.lower(value)
            return value == "true" or value == "inserted" or value == "complete" or value == "completed" or value == "1"
        end
        return false
    end
    local roots = { LocalPlayer:FindFirstChild("Data") }
    local map = workspace:FindFirstChild("Map")
    local circle = map and map:FindFirstChild("CircleIsland")
    local summon = circle and circle:FindFirstChild("RaidSummon")
    roots[#roots + 1] = summon
    for _, root in ipairs(roots) do
        if root then
            local instances = { root }
            for _, instance in ipairs(root:GetDescendants()) do instances[#instances + 1] = instance end
            for _, instance in ipairs(instances) do
                local name = string.lower(instance.Name)
                local relevant = string.find(name, "fist", 1, true) or string.find(name, "cyborg", 1, true)
                if relevant and instance:IsA("ValueBase") and meaningful(instance.Value) then return true end
                for attribute, value in pairs(instance:GetAttributes()) do
                    local attributeName = string.lower(attribute)
                    if (string.find(attributeName, "fist", 1, true) or string.find(attributeName, "cyborg", 1, true))
                        and meaningful(value)
                    then
                        return true
                    end
                end
            end
        end
    end
    return false
end

local function useCyborgItem(root, kind, tool, status)
    local owner = "AutoCyborg"
    local detector, part = cyborgButton()
    local destination = part and part.Position or cyborgButtonFallback
    if (root.Position - destination).Magnitude > 9 then
        setSpecialStatus("Moving to the Secret Laboratory")
        setSpecialTravel(owner, destination + Vector3.new(0, 3, 0), "Secret Laboratory", part)
        return
    end
    clearSpecialFarm(owner)
    if state.TravelOwner == owner then stopTravel() end
    if not detector or not fireclickdetector then
        setSpecialStatus("Laboratory control unavailable")
        contextNotice("CyborgLabControl", "The Secret Laboratory control is unavailable", Red, 5, 6)
        return
    end
    local character, humanoid = getCharacter(LocalPlayer)
    if not character or not humanoid then return end
    local data = state.SpecialData
    if data.CyborgTool ~= tool or data.CyborgToolKind ~= kind then
        data.CyborgTool = tool
        data.CyborgToolKind = kind
        data.CyborgToolAttempts = 0
        data.CyborgToolReadyAt = os.clock() + 0.65
        data.CyborgToolNextAt = 0
    end
    setSpecialStatus(status)
    if tool.Parent ~= character then
        if os.clock() >= (data.CyborgToolNextAt or 0) then
            pcall(function() humanoid:EquipTool(tool) end)
            data.CyborgToolReadyAt = os.clock() + 0.65
            data.CyborgToolNextAt = os.clock() + 0.9
        end
        return
    end
    if os.clock() < (data.CyborgToolReadyAt or 0) or os.clock() < (data.CyborgToolNextAt or 0) then return end
    local ok = pcall(fireclickdetector, detector)
    data.CyborgToolAttempts = (data.CyborgToolAttempts or 0) + 1
    data.CyborgToolNextAt = os.clock() + (data.CyborgToolAttempts >= 3 and 5 or 1.5)
    if not ok or data.CyborgToolAttempts >= 3 then
        contextNotice("CyborgItem:" .. kind, ok and (cyborgItemNames[kind] .. " was not accepted; retrying") or "Laboratory interaction failed", Red, 4, 5)
    end
end

local function updateCyborgAutomation(root)
    local owner = "AutoCyborg"
    if string.lower(currentRace()) == "cyborg" then
        finishSpecialMode(owner, "Cyborg race acquired")
        return
    end
    pollSpecialValue(owner, "CyborgCheck", 1.5, function()
        return CommF:InvokeServer("CyborgTrainer", "Check")
    end)
    if state.SpecialData.CyborgCheckError then
        clearSpecialFarm(owner)
        setSpecialStatus("Could not check Cyborg progress")
        contextNotice("Waiting:AutoCyborgRemote", "Could not check Cyborg progress; retrying", Red, 4, 8)
        return
    end
    if not state.SpecialData.CyborgInitialCheckComplete then
        clearSpecialFarm(owner)
        if state.TravelOwner == owner then stopTravel() end
        if not state.SpecialData.CyborgCheckReceived then
            setSpecialStatus("Checking Cyborg progress")
            return
        end
        state.SpecialData.CyborgFistInserted = FarmRuntime.DetectCyborgFistInserted(state.SpecialData.CyborgCheck)
        state.SpecialData.CyborgInitialCheckComplete = true
        setSpecialStatus(state.SpecialData.CyborgFistInserted and "Fist already inserted" or "Fist required")
    end

    local previousKind = state.SpecialData.CyborgToolKind
    local previousName = previousKind and cyborgItemNames[previousKind]
    if previousName and not findOwnedTool(previousName) then
        if previousKind == "Fist" then
            state.SpecialData.CyborgFistInserted = true
            showNotice("Fist of Darkness inserted", nil, 4)
        elseif previousKind == "Brain" then
            showNotice("Core Brain inserted", nil, 4)
            state.SpecialData.CyborgCheckNext = 0
        elseif previousKind == "Chip" then
            state.SpecialData.CyborgOrderWaitUntil = os.clock() + 8
        end
        state.SpecialData.CyborgTool = nil
        state.SpecialData.CyborgToolKind = nil
        state.SpecialData.CyborgToolAttempts = 0
    end

    local check = state.SpecialData.CyborgCheck
    if tonumber(check) == 2 then
        finishSpecialMode(owner, "Cyborg race acquired")
        return
    end
    local checkCode = tonumber(check)
    if (checkCode and checkCode > 0) or check == true then
        clearSpecialFarm(owner)
        if state.TravelOwner == owner then stopTravel() end
        local fragments = fragmentCount()
        if fragments and fragments < 2500 then
            setSpecialStatus("Need 2500 Fragments to buy Cyborg")
            contextNotice("CyborgFragments", "You need 2500 Fragments to buy Cyborg", Red, 5, 8)
            return
        end
        setSpecialStatus("Buying Cyborg race")
        queueSpecialRequest("CyborgBuy", owner, function(ok, result)
            if ok and tonumber(result) == 1 then
                finishSpecialMode(owner, "Cyborg race acquired")
            elseif ok and tonumber(result) == 2 then
                contextNotice("CyborgBuyFunds", "You need 2500 Fragments to buy Cyborg", Red, 5, 6)
            else
                state.SpecialData.CyborgCheckNext = 0
            end
        end, function() return CommF:InvokeServer("CyborgTrainer", "Buy") end)
        return
    end

    local brain = findOwnedTool("Core Brain")
    if brain then
        useCyborgItem(root, "Brain", brain, "Inserting Core Brain")
        return
    end

    local fist = findOwnedTool("Fist of Darkness")
    if fist and not state.SpecialData.CyborgFistInserted then
        if findOwnedTool("Microchip") then
            clearSpecialFarm(owner)
            setSpecialStatus("Remove the Microchip before inserting the Fist")
            contextNotice("CyborgFistChip", "Use or remove the Microchip before inserting the Fist of Darkness", Red, 6, 8)
            return
        end
        useCyborgItem(root, "Fist", fist, "Inserting Fist of Darkness")
        return
    end

    if not state.SpecialData.CyborgFistInserted then
        clearSpecialFarm(owner)
        local chest = findNearestChest(root, true)
        local chestPart = getPart(chest)
        if chestPart then
            setSpecialStatus("Collecting chests for Fist of Darkness")
            setSpecialTravel(owner, chestPart.Position, "Chest", chest, "cyborgChest")
            return
        end
        if state.TravelOwner == owner then stopTravel() end
        setSpecialStatus("Waiting for a chest")
        contextNotice("Waiting:CyborgFist", "No uncollected chest is currently available", Muted, 5, 10)
        return
    end

    local order = findEnemyNames(root, { "Order" }, true)
    if order then
        setSpecialStatus("Defeating Order")
        setSpecialFarm(owner, order.Name, true, order)
        return
    end
    clearSpecialFarm(owner)
    if os.clock() < (state.SpecialData.CyborgOrderWaitUntil or 0) then
        setSpecialStatus("Waiting for Order")
        return
    end

    local chip = findOwnedTool("Microchip")
    if chip then
        useCyborgItem(root, "Chip", chip, "Starting Order raid")
        return
    end

    if state.TravelOwner == owner then stopTravel() end
    local fragments = fragmentCount()
    if fragments and fragments < 1000 then
        setSpecialStatus("Need 1000 Fragments for a Microchip")
        contextNotice("CyborgChipFragments", "You need 1000 Fragments for an Order Microchip", Red, 5, 8)
        return
    end
    setSpecialStatus("Buying Order Microchip")
    queueSpecialRequest("CyborgChipBuy", owner, function(ok, result)
        local code = tonumber(result)
        if ok and code == 1 then
            showNotice("Order Microchip acquired", nil, 4)
        elseif ok and code == 2 then
            state.SpecialData.CyborgOrderWaitUntil = 0
        elseif ok and code == 0 then
            contextNotice("CyborgChipFunds", "You need 1000 Fragments for an Order Microchip", Red, 5, 6)
        else
            contextNotice("CyborgChipBuyFailed", "Could not buy an Order Microchip; retrying", Red, 4, 6)
        end
    end, function() return CommF:InvokeServer("BlackbeardReward", "Microchip", "2") end)
end

local SABER_OWNER = "AutoSaber"
local SABER_TORCH_FALLBACK = Vector3.new(-1679.26, 20.49, 170.77)
local SABER_BURN_FALLBACK = Vector3.new(1120.51, 3.35, 4388.72)
local SABER_CUP_FALLBACK = Vector3.new(1109.47, 4.2, 4402.89)
local SABER_WATER_FALLBACK = Vector3.new(1397.23, 37.35, -1320.85)
local SABER_SICK_MAN_FALLBACK = Vector3.new(1503.4, 77.35, -1297.55)
local SABER_RICH_MAN_FALLBACK = Vector3.new(-939.34, 26.03, 4114.77)
local SABER_MOB_FALLBACK = Vector3.new(-2880.72, 8.7, 5430.85)
local SABER_RELIC_FALLBACK = Vector3.new(-1462.29, 44.91, 45.2)
local SABER_BOSS_FALLBACK = Vector3.new(-1527.2, 38.1, -33.16)

local function saberMapInstance(...)
    local current = workspace:FindFirstChild("Map")
    for _, name in ipairs({ ... }) do
        current = current and current:FindFirstChild(name)
    end
    return current
end

local function saberNpcPosition(name, fallback)
    for _, folder in ipairs({ workspace:FindFirstChild("NPCs"), ReplicatedStorage:FindFirstChild("NPCs") }) do
        local npc = folder and folder:FindFirstChild(name)
        if npc then
            local part = getPart(npc)
            if part then return part.Position, npc end
            local floor = npc:GetAttribute("FloorPos")
            if typeof(floor) == "Vector3" then return floor + Vector3.new(0, 3, 0), npc end
        end
    end
    return fallback, nil
end

local function saberRefresh(delay)
    state.SpecialData.SaberProgress = nil
    state.SpecialData.SaberProgressNext = os.clock() + (tonumber(delay) or 0.35)
    state.SpecialData.SaberReadyAt = os.clock() + (tonumber(delay) or 0.35)
end

local function saberTravel(root, destination, name, radius, object)
    radius = tonumber(radius) or 5
    if (root.Position - destination).Magnitude > radius then
        setSpecialStatus("Moving to " .. name)
        setSpecialTravel(SABER_OWNER, destination, name, object)
        return false
    end
    if state.TravelOwner == SABER_OWNER then stopTravel() end
    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero
    return true
end

local function saberEquip(tool)
    local character, humanoid = getCharacter(LocalPlayer)
    if not character or not humanoid or not tool then return false end
    if tool.Parent == character then return true end
    pcall(function() humanoid:EquipTool(tool) end)
    state.SpecialData.SaberReadyAt = os.clock() + 0.5
    return false
end

local function saberTouch(root, part)
    if not root or not part or not part:IsA("BasePart") then return end
    if firetouchinterest then
        pcall(function()
            firetouchinterest(root, part, 0)
            firetouchinterest(root, part, 1)
        end)
    end
end

local function saberRequest(key, action, argument)
    return queueSpecialRequest("Saber" .. key, SABER_OWNER, function(ok)
        if not ok then
            contextNotice("SaberRequest:" .. key, "The Saber puzzle step failed; retrying", Red, 4, 6)
        end
        saberRefresh(0.45)
    end, function()
        if argument ~= nil then return CommF:InvokeServer("ProQuestProgress", action, argument) end
        return CommF:InvokeServer("ProQuestProgress", action)
    end)
end

local function updateSaberAutomation(root)
    if playerLevel() < 200 then
        clearSpecialFarm(SABER_OWNER)
        setSpecialStatus("You need Level 200 for the Saber puzzle")
        return
    end
    if os.clock() < (state.SpecialData.SaberReadyAt or 0) then return end
    pollSpecialValue(SABER_OWNER, "SaberProgress", 0.8, function()
        return CommF:InvokeServer("ProQuestProgress")
    end)
    if state.SpecialData.SaberProgressError then
        clearSpecialFarm(SABER_OWNER)
        setSpecialStatus("Could not check Saber puzzle progress")
        contextNotice("SaberProgressError", "Could not check the Saber puzzle; retrying", Red, 4, 7)
        return
    end
    local progress = state.SpecialData.SaberProgress
    if type(progress) ~= "table" then
        setSpecialStatus("Checking Saber puzzle progress")
        return
    end
    if progress.KilledShanks == true then
        finishSpecialMode(SABER_OWNER, "Saber puzzle completed")
        return
    end

    local questPlates = saberMapInstance("Jungle", "QuestPlates")
    local plateProgress = type(progress.Plates) == "table" and progress.Plates or {}
    local nextPlate, nextButton
    for index = 1, 5 do
        local plate = questPlates and questPlates:FindFirstChild("Plate" .. tostring(index))
        local button = plate and plate:FindFirstChild("Button")
        local pressed = plateProgress[index] == true or (button and button.BrickColor == BrickColor.new("Camo"))
        if not pressed then
            nextPlate, nextButton = index, button
            break
        end
    end
    if nextPlate then
        clearSpecialFarm(SABER_OWNER)
        if not nextButton or not nextButton:IsA("BasePart") then
            setSpecialStatus("Waiting for Jungle plate " .. tostring(nextPlate))
            return
        end
        local destination = nextButton.Position + Vector3.new(0, 2.5, 0)
        if saberTravel(root, destination, "Jungle plate " .. tostring(nextPlate), 3.5, nextButton) then
            setSpecialStatus("Activating Jungle plate " .. tostring(nextPlate))
            saberTouch(root, nextButton)
            saberRefresh(0.55)
        end
        return
    end

    if progress.UsedTorch ~= true then
        clearSpecialFarm(SABER_OWNER)
        local torch = findOwnedTool("Torch")
        if not torch then
            local worldTorch = saberMapInstance("Jungle", "Torch")
            local torchPart = getPart(worldTorch)
            local destination = (torchPart and torchPart.Position or SABER_TORCH_FALLBACK) + Vector3.new(0, 2.25, 0)
            if saberTravel(root, destination, "the Jungle torch", 3.5, worldTorch) then
                setSpecialStatus("Collecting the torch")
                saberTouch(root, torchPart)
                saberRefresh(0.75)
            end
            return
        end
        if not saberEquip(torch) then setSpecialStatus("Equipping the torch"); return end
        local burn = saberMapInstance("Desert", "Burn")
        local burnPart = burn and (burn:FindFirstChild("Fire") or burn:FindFirstChildWhichIsA("BasePart"))
        local destination = (burnPart and burnPart.Position or SABER_BURN_FALLBACK) + Vector3.new(0, 3, 0)
        if saberTravel(root, destination, "the Desert wall", 4, burnPart) then
            setSpecialStatus("Burning the Desert wall")
            saberTouch(root, burnPart)
            saberRefresh(0.8)
        end
        return
    end

    if progress.UsedCup ~= true then
        clearSpecialFarm(SABER_OWNER)
        local cup = findOwnedTool("Cup")
        if not cup then
            local worldCup = saberMapInstance("Desert", "Cup")
            local cupPart = getPart(worldCup)
            local destination = (cupPart and cupPart.Position or SABER_CUP_FALLBACK) + Vector3.new(0, 2.25, 0)
            if saberTravel(root, destination, "the Desert cup", 3.5, worldCup) then
                setSpecialStatus("Collecting the cup")
                saberTouch(root, cupPart)
                saberRequest("GetCup", "GetCup")
            end
            return
        end
        if not saberEquip(cup) then setSpecialStatus("Equipping the cup"); return end
        local handle = cup:FindFirstChild("Handle") or cup:FindFirstChildWhichIsA("BasePart")
        local empty = handle and handle:FindFirstChild("TouchInterest") ~= nil
        if empty then
            if saberTravel(root, SABER_WATER_FALLBACK, "the Frozen Village spring", 5, handle) then
                setSpecialStatus("Filling the cup")
                saberRequest("FillCup", "FillCup", cup)
            end
            return
        end
        local sickPosition, sickNpc = saberNpcPosition("Sick Man", SABER_SICK_MAN_FALLBACK)
        if saberTravel(root, sickPosition, "Sick Man", 9, sickNpc) then
            setSpecialStatus("Giving the cup to Sick Man")
            saberRequest("SickMan", "SickMan")
        end
        return
    end

    if progress.TalkedSon ~= true then
        clearSpecialFarm(SABER_OWNER)
        local richPosition, richNpc = saberNpcPosition("Rich Man", SABER_RICH_MAN_FALLBACK)
        if saberTravel(root, richPosition, "Rich Man", 9, richNpc) then
            setSpecialStatus("Speaking to Rich Man")
            saberRequest("RichSonStart", "RichSon")
        end
        return
    end

    if progress.KilledMob ~= true then
        local mob = findEnemyNames(root, { "Mob Leader" }, true)
        if mob then
            setSpecialStatus("Defeating Mob Leader")
            setSpecialFarm(SABER_OWNER, "Mob Leader", true, mob)
            return
        end
        clearSpecialFarm(SABER_OWNER)
        local spawn = nearestEnemySpawn(root, "Mob Leader")
        local destination = (spawn and spawn.Position or SABER_MOB_FALLBACK) + Vector3.new(0, 7, 0)
        if saberTravel(root, destination, "Mob Leader", 25, spawn) then setSpecialStatus("Waiting for Mob Leader") end
        return
    end

    if progress.UsedRelic ~= true then
        clearSpecialFarm(SABER_OWNER)
        local relic = findOwnedTool("Relic")
        if not relic then
            local richPosition, richNpc = saberNpcPosition("Rich Man", SABER_RICH_MAN_FALLBACK)
            if saberTravel(root, richPosition, "Rich Man", 9, richNpc) then
                setSpecialStatus("Collecting the relic")
                saberRequest("RichSonRelic", "RichSon")
            end
            return
        end
        if not saberEquip(relic) then setSpecialStatus("Equipping the relic"); return end
        local final = saberMapInstance("Jungle", "Final")
        local socket = final and (final:FindFirstChild("Handle", true) or final:FindFirstChildWhichIsA("BasePart", true))
        local destination = socket and socket.Position or SABER_RELIC_FALLBACK
        if saberTravel(root, destination, "the Jungle relic door", 4, socket) then
            setSpecialStatus("Placing the relic")
            saberTouch(root, socket)
            saberRequest("PlaceRelic", "PlaceRelic")
        end
        return
    end

    local saberExpert = findEnemyNames(root, { "Saber Expert" }, true)
    if saberExpert then
        state.SpecialData.SaberBossSeen = true
        setSpecialStatus("Defeating Saber Expert")
        setSpecialFarm(SABER_OWNER, "Saber Expert", true, saberExpert)
        return
    end
    clearSpecialFarm(SABER_OWNER)
    if state.SpecialData.SaberBossSeen then
        setSpecialStatus("Confirming Saber Expert defeat")
        saberRequest("ConfirmDefeat", "PlaceRelic")
        return
    end
    local spawn = nearestEnemySpawn(root, "Saber Expert")
    local destination = (spawn and spawn.Position or SABER_BOSS_FALLBACK) + Vector3.new(0, 7, 0)
    if saberTravel(root, destination, "Saber Expert", 25, spawn) then
        setSpecialStatus("Waiting for Saber Expert")
    end
end

local function updateSecondSeaAutomation(root)
    local firstSeaSaber = game.PlaceId == SEA_PLACE_IDS.First and Settings.AutoSaber
    local raidRequested = Settings.RaidAutoClear
    local thirdSeaTyrant = game.PlaceId == SEA_PLACE_IDS.Third and Settings.AutoTyrant
    local thirdSeaCakePrince = game.PlaceId == SEA_PLACE_IDS.Third and Settings.AutoCakePrince
    local thirdSeaDoughKing = game.PlaceId == SEA_PLACE_IDS.Third and Settings.AutoDoughKing
    local thirdSeaElite = game.PlaceId == SEA_PLACE_IDS.Third and Settings.AutoEliteHunter
    local thirdSeaPirateRaid = game.PlaceId == SEA_PLACE_IDS.Third and Settings.AutoPirateRaid
    if game.PlaceId ~= SEA_PLACE_IDS.Second and not firstSeaSaber and not raidRequested and not thirdSeaTyrant and not thirdSeaCakePrince and not thirdSeaDoughKing and not thirdSeaElite and not thirdSeaPirateRaid then
        if state.SpecialOwner then activateSpecialOwner(nil) end
        return
    end
    if os.clock() - state.SpecialLastUpdate < 0.08 then return end
    state.SpecialLastUpdate = os.clock()

    local owner, waitingReason
    for _, setting in ipairs(specialModes) do
        if Settings[setting] then
            local ready, reason, canWait = specialModeRequirement(setting)
            if ready then
                owner = setting
                break
            elseif canWait and not waitingReason then
                waitingReason = reason
            elseif not canWait then
                Settings[setting] = false
                local blockedSetting = setting
                local control = SecondSeaControls[blockedSetting]
                if control and control.Set then
                    task.defer(function() pcall(function() control:Set(false) end) end)
                end
                contextNotice("Blocked:" .. blockedSetting, reason, Red, 4, 5)
            end
        end
    end

    if owner ~= state.SpecialOwner then
        local previous = state.SpecialOwner
        if previous == "AutoFactory" and Settings.AutoFactory then
            contextNotice("FactoryEnded", "The Factory raid has ended; waiting for the next one", Muted, 4, 8)
        elseif previous == "AutoPirateRaid" and Settings.AutoPirateRaid then
            contextNotice("PirateRaidEnded", "The Pirate Raid has ended; waiting for the next one", Muted, 4, 8)
        elseif previous == "RaidAutoClear" and Settings.RaidAutoClear then
            contextNotice("RaidEnded", "The raid has ended; waiting for the next one", Muted, 4, 8)
            state.RaidStartedAt = 0
        end
        activateSpecialOwner(owner)
    end
    if not owner then
        setSpecialStatus(waitingReason or "Idle")
        return
    end

    if owner == "AutoPirateRaid" then updatePirateRaidAutomation(root)
    elseif owner == "AutoSaber" then updateSaberAutomation(root)
    elseif owner == "AutoTyrant" then updateTyrantAutomation(root)
    elseif owner == "AutoCakePrince" then FarmRuntime.CakePrince.Update(root)
    elseif owner == "AutoDoughKing" then FarmRuntime.DoughKing.Update(root)
    elseif owner == "AutoEliteHunter" then updateEliteHunterAutomation(root)
    elseif owner == "AutoCyborg" then updateCyborgAutomation(root)
    elseif owner == "AutoFactory" then updateFactoryAutomation(root)
    elseif owner == "AutoBartilo" then updateBartiloAutomation(root)
    elseif owner == "AutoRaceV2" then updateRaceV2Automation(root)
    elseif owner == "AutoRaceV3" then updateRaceV3Automation(root)
    elseif owner == "RaidAutoClear" then updateRaidAutomation(root)
    elseif owner == "AutoDropGoal" then updateDropGoalAutomation(root)
    elseif owner == "AutoSea3" then updateSea3Automation(root)
    elseif owner == "AutoGhoul" then updateGhoulAutomation(root)
    end
end

local function checkLegendaryDealer(notify)
    if state.DealerCheckBusy then return end
    state.DealerCheckBusy = true
    task.spawn(function()
        local ok, result = pcall(function() return CommF:InvokeServer("LegendarySwordDealer", "1") end)
        state.DealerCheckBusy = false
        if not state.Alive then return end
        local available = ok and type(result) == "string" and result ~= ""
        if notify or available ~= state.DealerAvailable or (available and result ~= state.DealerSword) then
            if available then showNotice("Legendary Sword Dealer: " .. result, nil, 6)
            elseif notify then showNotice("Legendary Sword Dealer is not here", Muted, 4) end
        end
        state.DealerAvailable = available
        state.DealerSword = available and result or nil
        state.DealerLastCheck = os.clock()
    end)
end

local function dealerHint()
    task.spawn(function()
        local ok, ready = pcall(function() return CommF:InvokeServer("Manager", "1") end)
        if not state.Alive then return end
        if not ok or ready ~= 0 then showNotice("Manager hint is unavailable", Red, 4); return end
        local hintOk, hint = pcall(function() return CommF:InvokeServer("Manager", "2") end)
        showNotice(hintOk and tostring(hint) or "Manager hint is unavailable", hintOk and nil or Red, 7)
    end)
end

local function travelToDealer()
    local npc = findSpecialNpc("Legendary Sword Dealer")
    local part = getPart(npc)
    if not part then showNotice("Legendary Sword Dealer is not spawned", Red, 4); return end
    beginTravel(part.Position + Vector3.new(0, 3, 0), "Legendary Sword Dealer")
end

local function buyLegendarySword()
    task.spawn(function()
        local ok, result = pcall(function() return CommF:InvokeServer("LegendarySwordDealer", "2") end)
        if ok and result == 1 then showNotice("Legendary sword purchased", nil, 5)
        elseif ok and result == 0 then showNotice("You need $2,000,000", Red, 5)
        elseif ok and result == 2 then showNotice("You already own this sword", Muted, 5)
        else showNotice("Legendary Sword Dealer is unavailable", Red, 5) end
        checkLegendaryDealer(false)
    end)
end

local function buyRaidChip()
    if game.PlaceId ~= SEA_PLACE_IDS.Second and game.PlaceId ~= SEA_PLACE_IDS.Third then
        contextNotice("RaidSeaRequired", "Raid chips are only available in the Second and Third Sea", Red, 5, 3)
        return
    end
    task.spawn(function()
        local ok, result = pcall(function() return CommF:InvokeServer("RaidsNpc", "Select", Settings.RaidType) end)
        if ok and result == 1 then showNotice(Settings.RaidType .. " raid chip acquired", nil, 4)
        elseif ok and result == 0 then showNotice("Raid chip requirements are not met", Red, 5)
        elseif ok and result == 2 then showNotice("You already have a raid chip", Muted, 4)
        else showNotice("Raid chip unavailable", Red, 4) end
    end)
end

local function startRaid()
    if game.PlaceId ~= SEA_PLACE_IDS.Second and game.PlaceId ~= SEA_PLACE_IDS.Third then
        contextNotice("RaidSeaRequired", "Raids are only available in the Second and Third Sea", Red, 5, 3)
        return
    end
    local map = workspace:FindFirstChild("Map")
    local summon = map and (map:FindFirstChild("RaidSummon2", true) or map:FindFirstChild("RaidSummon", true))
    local button = summon and summon:FindFirstChild("Button")
    local detector = button and button:FindFirstChildWhichIsA("ClickDetector", true)
    if not detector or not fireclickdetector then showNotice("Raid button unavailable", Red, 4); return end
    local ok = pcall(fireclickdetector, detector)
    showNotice(ok and "Raid start requested" or "Raid start failed", ok and nil or Red, 4)
    if ok then
        task.delay(4, function()
            if state.Alive and LocalPlayer:GetAttribute("IslandRaiding") == nil then
                contextNotice("RaidStartFailed", "The raid did not start; you may need a raid chip", Red, 5, 4)
            end
        end)
    end
end

return {
    Update = updateSecondSeaAutomation,
    SetMode = setSpecialMode,
    Status = function() return state.SpecialStatus end,
    RaidTypes = raidTypes,
    DropGoals = dropGoals,
    CheckDealer = checkLegendaryDealer,
    DealerHint = dealerHint,
    TravelDealer = travelToDealer,
    BuyLegendarySword = buyLegendarySword,
    BuyRaidChip = buyRaidChip,
    StartRaid = startRaid
}
end)()

local seaBeastRuntime = (function()
local seaBeastSkillKeys = {
    Enum.KeyCode.Z,
    Enum.KeyCode.X,
    Enum.KeyCode.C,
    Enum.KeyCode.V
}

local function seaBeastHealth(model)
    if not model then return nil end
    local humanoid = model:FindFirstChildOfClass("Humanoid")
    if humanoid then return humanoid.Health, humanoid.MaxHealth end
    local health = model:FindFirstChild("Health")
    if health and health:IsA("ValueBase") then
        local maximum = health:IsA("IntConstrainedValue") and health.MaxValue
            or health:IsA("DoubleConstrainedValue") and health.MaxValue
            or model:GetAttribute("MaxHealth")
        return tonumber(health.Value), tonumber(maximum)
    end
    return nil
end

local function validSeaBeast(model)
    local folder = workspace:FindFirstChild("SeaBeasts")
    local part = getPart(model)
    local health = seaBeastHealth(model)
    return folder and model and model.Parent == folder and part and health and health > 0, part, health
end

local function nearestSeaBeast(root)
    local folder = workspace:FindFirstChild("SeaBeasts")
    if not folder or not root then return nil end
    local best, bestDistance
    for _, model in ipairs(folder:GetChildren()) do
        local valid, part = validSeaBeast(model)
        if valid then
            local distance = (part.Position - root.Position).Magnitude
            if not bestDistance or distance < bestDistance then
                best, bestDistance = model, distance
            end
        end
    end
    return best
end

local function setSeaBeastSailing(enabled)
    if state.SeaBeastDriving == enabled then return end
    state.SeaBeastDriving = enabled
    pcall(function()
        farmVirtualInput:SendKeyEvent(enabled, Enum.KeyCode.W, false, game)
    end)
end

local function ownedSeaBeastBoat(root, maxDistance)
    local boats = workspace:FindFirstChild("Boats")
    if not boats then return nil end
    local best, bestDistance
    for _, boat in ipairs(boats:GetChildren()) do
        if boat:IsA("Model") and boat:GetAttribute("IsBoat") == true then
            local ownerObject = boat:FindFirstChild("Owner")
            local ownerValue = ownerObject and ownerObject:IsA("ObjectValue") and ownerObject.Value or nil
            local ownerId = boat:GetAttribute("OwnerId")
            local ownerName = boat:GetAttribute("Owner")
            local isOwned = ownerValue == LocalPlayer
                or ownerValue == LocalPlayer.Character
                or ownerId == LocalPlayer.UserId
                or tostring(ownerId) == tostring(LocalPlayer.UserId)
                or ownerName == LocalPlayer.Name
            if isOwned then
                local seat = boat:FindFirstChildWhichIsA("VehicleSeat", true)
                local position = seat and seat.Position or boat:GetPivot().Position
                local distance = root and (position - root.Position).Magnitude or 0
                if not bestDistance or distance < bestDistance then
                    best, bestDistance = boat, distance
                end
            end
        end
    end
    if best and maxDistance and bestDistance > maxDistance then return nil, bestDistance end
    return best, bestDistance
end

local function nearestBoatSpawn(root)
    local origin = workspace:FindFirstChild("_WorldOrigin")
    local spawns = origin and origin:FindFirstChild("BoatSpawns")
    if not spawns or not root then return nil end
    local best, bestDistance
    for _, spawnPart in ipairs(spawns:GetChildren()) do
        if spawnPart:IsA("BasePart") then
            local distance = (spawnPart.Position - root.Position).Magnitude
            if not bestDistance or distance < bestDistance then
                best, bestDistance = spawnPart, distance
            end
        end
    end
    return best, bestDistance
end

local function openWaterDirection(position)
    local origin = workspace:FindFirstChild("_WorldOrigin")
    local spawns = origin and origin:FindFirstChild("BoatSpawns")
    local centre, count = Vector3.zero, 0
    if spawns then
        for _, spawnPart in ipairs(spawns:GetChildren()) do
            if spawnPart:IsA("BasePart") then
                centre = centre + Vector3.new(spawnPart.Position.X, 0, spawnPart.Position.Z)
                count = count + 1
            end
        end
    end
    if count > 0 then centre = centre / count end
    local direction = Vector3.new(position.X, 0, position.Z) - centre
    if direction.Magnitude < 1 then direction = Vector3.new(0, 0, -1) end
    return direction.Unit
end

local function restoreSeaBeastBoatCollision()
    for part, canCollide in pairs(state.SeaBeastBoatCollision) do
        if part and part.Parent then
            pcall(function() part.CanCollide = canCollide end)
        end
        state.SeaBeastBoatCollision[part] = nil
    end
    state.SeaBeastNoClipBoat = nil
end

local function setSeaBeastBoatCollision(boat, disabled)
    if not disabled or not boat then
        restoreSeaBeastBoatCollision()
        return
    end
    if state.SeaBeastNoClipBoat and state.SeaBeastNoClipBoat ~= boat then
        restoreSeaBeastBoatCollision()
    end
    state.SeaBeastNoClipBoat = boat
    for _, part in ipairs(boat:GetDescendants()) do
        if part:IsA("BasePart") then
            if state.SeaBeastBoatCollision[part] == nil then
                state.SeaBeastBoatCollision[part] = part.CanCollide
            end
            part.CanCollide = false
        end
    end
end

local function stopSeaBeastHunt(leaveSeat)
    setSeaBeastSailing(false)
    local boat = state.SeaBeastBoat
    local seat = boat and boat:FindFirstChildWhichIsA("VehicleSeat", true)
    if seat then pcall(function() seat.ThrottleFloat = 0 end) end
    if leaveSeat then
        local _, humanoid = getCharacter(LocalPlayer)
        if humanoid and humanoid.SeatPart then humanoid.Sit = false end
    end
    state.SeaBeastBoat = nil
    state.SeaBeastHuntStartedAt = 0
    state.SeaBeastNextSeatAt = 0
    state.SeaBeastLastBoatStep = 0
    restoreSeaBeastBoatCollision()
end

local function clearSeaBeastTarget()
    stopSeaBeastHunt(true)
    if state.TravelOwner == "seaBeast" then stopTravel() end
    state.SeaBeastTarget = nil
    state.SeaBeastTool = nil
    state.SeaBeastActive = false
    state.SeaBeastNextSkillAt = 0
    state.SeaBeastNextEquipAt = 0
    state.SeaBeastSkillIndex = 0
    state.SeaBeastLastBoatStep = 0
end

local function resolveSeaBeastWeapon()
    local loaded, reason = loadFarmCombatModules()
    if not loaded then return nil, reason end
    local character = LocalPlayer.Character
    local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
    local selected = Settings.SeaBeastWeapon
    local candidates, seen = {}, {}
    local priorities = { ["Blox Fruit"] = 1, Sword = 2, Melee = 3 }
    local function scan(container)
        if not container then return end
        for _, tool in ipairs(container:GetChildren()) do
            if tool:IsA("Tool") and not seen[tool] and CollectionService:HasTag(tool, "WeaponTool") then
                seen[tool] = true
                local okName, weaponName = pcall(function() return farmCombatUtil:GetWeaponName(tool) end)
                local okData, weaponData = false, nil
                if okName and type(weaponName) == "string" then
                    okData, weaponData = pcall(function() return farmCombatUtil:GetWeaponData(weaponName) end)
                end
                local category = okData and type(weaponData) == "table" and normalizeWeaponCategory(weaponData.WeaponType) or nil
                if category and category ~= "Gun" and (selected == "Auto" or category == selected) then
                    candidates[#candidates + 1] = {
                        Tool = tool,
                        Category = category,
                        Equipped = tool.Parent == character,
                        Mastery = toolMasteryLevel(tool)
                    }
                end
            end
        end
    end
    scan(character)
    scan(backpack)
    table.sort(candidates, function(a, b)
        if a.Equipped ~= b.Equipped then return a.Equipped end
        if selected == "Auto" and priorities[a.Category] ~= priorities[b.Category] then
            return (priorities[a.Category] or 99) < (priorities[b.Category] or 99)
        end
        if a.Mastery ~= b.Mastery then return a.Mastery > b.Mastery end
        return string.lower(a.Tool.Name) < string.lower(b.Tool.Name)
    end)
    return candidates[1], candidates[1] and nil or (selected == "Auto" and "No skill weapon is available" or ("No " .. tostring(selected) .. " weapon is available"))
end

local function setSeaBeastTravel(position, target)
    if state.TravelOwner ~= "seaBeast" or state.TravelObject ~= target then
        state.TravelBudget = 0
        state.TravelSerial = state.TravelSerial + 1
    end
    state.TravelTarget = position
    state.TravelName = target.Name
    state.TravelMode = "seaBeast"
    state.TravelObject = target
    state.TravelOwner = "seaBeast"
end

FarmRuntime.GrandBrigadeName = function()
    local teamName = string.lower(tostring(LocalPlayer.Team and LocalPlayer.Team.Name or ""))
    return string.find(teamName, "marine", 1, true) and "MarineGrandBrigade" or "PirateGrandBrigade"
end

local function updateSeaBeastHunt(root, purpose)
    local searchingMirage = purpose == "Mirage"
    local searchingIsland = purpose == "Island"
    local searchKey = searchingIsland and "Island" or (searchingMirage and "Mirage" or "SeaBeast")
    local searchName = searchingIsland and tostring(Settings.IslandFinderTarget) or (searchingMirage and "Mirage Island" or "a Sea Beast")
    local searchSpeed = searchingIsland and Settings.IslandFinderSpeed or Settings.SeaBeastTravelSpeed
    local enabled = searchingIsland and Settings.IslandFinderAutoFind
        or searchingMirage and Settings.AutoMirage
        or (not searchingIsland and not searchingMirage and Settings.SeaBeastAutoHunt)
    if not enabled then
        stopSeaBeastHunt(false)
        if not searchingIsland and not searchingMirage then
            contextNotice("Waiting:SeaBeast", "Waiting for a Sea Beast to spawn", Muted, 4, 10)
        end
        return false
    end

    local boat = ownedSeaBeastBoat(root, 300)
    if not boat then
        stopSeaBeastHunt(false)
        local spawnPart, distance = nearestBoatSpawn(root)
        if not spawnPart then
            contextNotice(searchKey .. "BoatSpawn", "No boat spawn is available in this sea", Red, 5, 8)
            return false
        end
        if distance > 12 then
            setSeaBeastTravel(spawnPart.Position + Vector3.new(0, 3, 0), spawnPart)
            contextNotice(searchKey .. "BoatTravel", "Travelling to a boat spawn", Muted, 3, 8)
            return true
        end
        if state.TravelOwner == "seaBeast" then stopTravel() end
        if not state.SeaBeastBoatRequestBusy and os.clock() >= state.SeaBeastNextBoatAt then
            state.SeaBeastBoatRequestBusy = true
            state.SeaBeastNextBoatAt = os.clock() + 4
            task.spawn(function()
                local ok, result = pcall(function() return CommF:InvokeServer("BuyBoat", FarmRuntime.GrandBrigadeName()) end)
                state.SeaBeastBoatRequestBusy = false
                if searchingMirage and not Settings.AutoMirage then return end
                if searchingIsland and not Settings.IslandFinderAutoFind then return end
                if not searchingMirage and not searchingIsland and not Settings.AutoSeaBeast then return end
                if not ok then
                    contextNotice(searchKey .. "BoatRemote", "Could not request a Grand Brigade; retrying", Red, 4, 8)
                elseif result == 2 then
                    contextNotice(searchKey .. "BoatBlocked", "Boat spawn is obstructed; move nearby boats and retry", Red, 5, 8)
                elseif result ~= 1 then
                    contextNotice(searchKey .. "BoatFailed", "Grand Brigade request was rejected; you may need $4,000", Red, 5, 8)
                else
                    showNotice("Grand Brigade ready - searching for " .. searchName, espColor(Settings.SeaColor), 4)
                end
            end)
        end
        return true
    end

    if state.TravelOwner == "seaBeast" then stopTravel() end
    state.SeaBeastBoat = boat
    setSeaBeastBoatCollision(boat, searchingIsland)
    local seat = boat:FindFirstChildWhichIsA("VehicleSeat", true)
    local _, humanoid = getCharacter(LocalPlayer)
    if not seat or not humanoid then
        contextNotice(searchKey .. "BoatSeat", "The hunting boat has no usable driver seat", Red, 5, 8)
        return true
    end
    if humanoid.SeatPart ~= seat then
        setSeaBeastSailing(false)
        if os.clock() >= state.SeaBeastNextSeatAt then
            state.SeaBeastNextSeatAt = os.clock() + 1.25
            root.CFrame = seat.CFrame * CFrame.new(0, 2.5, 0)
            pcall(function() seat:Sit(humanoid) end)
        end
        contextNotice(searchKey .. "Boarding", "Boarding the boat to search for " .. searchName, Muted, 3, 8)
        return true
    end

    if state.SeaBeastHuntStartedAt == 0 then
        state.SeaBeastHuntStartedAt = os.clock()
        local pivot = boat:GetPivot()
        local direction = openWaterDirection(pivot.Position)
        pcall(function() boat:PivotTo(CFrame.lookAt(pivot.Position, pivot.Position + direction)) end)
        showNotice("Sailing to find " .. searchName, espColor(Settings.SeaColor), 4)
    end
    local now = os.clock()
    local elapsed = state.SeaBeastLastBoatStep > 0 and math.clamp(now - state.SeaBeastLastBoatStep, 0, 0.1) or 0
    state.SeaBeastLastBoatStep = now
    local boatCanMove = searchingIsland or FarmRuntime.AutomationMovementReady("boat:" .. searchKey, elapsed)
    if searchingMirage then
        pcall(function() seat.ThrottleFloat = boatCanMove and 1 or 0 end)
        setSeaBeastSailing(boatCanMove)
    else
        pcall(function() seat.ThrottleFloat = 0 end)
        setSeaBeastSailing(false)
        if elapsed > 0 and boatCanMove then
            pcall(function()
                local pivot = boat:GetPivot()
                local direction = Vector3.new(pivot.LookVector.X, 0, pivot.LookVector.Z)
                if direction.Magnitude < 0.01 then direction = openWaterDirection(pivot.Position) end
                direction = direction.Unit
                local position = pivot.Position + direction * (searchSpeed * elapsed)
                boat:PivotTo(CFrame.lookAt(position, position + direction))
            end)
        end
    end
    contextNotice("Waiting:" .. searchKey .. "Sail", "Searching open water for " .. searchName .. " at " .. tostring(math.floor(searchSpeed)) .. " studs/s", Muted, 4, 12)
    return true
end

local function fireSeaBeastSkill(part)
    if state.SeaBeastKeyBusy or os.clock() < state.SeaBeastNextSkillAt then return end
    local camera = workspace.CurrentCamera
    if not camera or not part then return end
    state.SeaBeastSkillIndex = state.SeaBeastSkillIndex % #seaBeastSkillKeys + 1
    local key = seaBeastSkillKeys[state.SeaBeastSkillIndex]
    local direction = part.Position - camera.CFrame.Position
    if direction.Magnitude > 0.01 then
        camera.CFrame = camera.CFrame:Lerp(CFrame.lookAt(camera.CFrame.Position, part.Position), 0.65)
    end
    local point, visible = camera:WorldToViewportPoint(part.Position)
    local x = visible and math.clamp(point.X, 2, camera.ViewportSize.X - 2) or camera.ViewportSize.X * 0.5
    local y = visible and math.clamp(point.Y, 2, camera.ViewportSize.Y - 2) or camera.ViewportSize.Y * 0.5
    state.SeaBeastKeyBusy = true
    state.SeaBeastNextSkillAt = os.clock() + math.max(0.15, Settings.SeaBeastSkillDelay)
    task.spawn(function()
        local moved = pcall(function() farmVirtualInput:SendMouseMoveEvent(x, y, game) end)
        local pressed = moved and pcall(function() farmVirtualInput:SendKeyEvent(true, key, false, game) end)
        if pressed then task.wait(0.08) end
        pcall(function() farmVirtualInput:SendKeyEvent(false, key, false, game) end)
        state.SeaBeastKeyBusy = false
    end)
end

local function updateSeaBeastAutomation(root)
    if not Settings.AutoSeaBeast then
        if state.SeaBeastActive or state.TravelOwner == "seaBeast" then clearSeaBeastTarget() end
        return false
    end
    local valid, part = validSeaBeast(state.SeaBeastTarget)
    if not valid then
        local previous = state.SeaBeastTarget
        state.SeaBeastTarget = nearestSeaBeast(root)
        valid, part = validSeaBeast(state.SeaBeastTarget)
        if valid and state.SeaBeastTarget ~= previous then
            showNotice("Sea Beast detected - boat search stopped", espColor(Settings.SeaColor), 6)
            state.SeaBeastTool = nil
        end
    end
    if not valid then
        state.SeaBeastTarget = nil
        state.SeaBeastTool = nil
        state.SeaBeastActive = false
        return updateSeaBeastHunt(root)
    end
    stopSeaBeastHunt(true)
    state.SeaBeastActive = true
    local target = state.SeaBeastTarget
    local desired = part.Position + Vector3.new(0, math.clamp(Settings.SeaBeastHoverHeight, 35, 120), 0)
    setSeaBeastTravel(desired, target)
    root.AssemblyLinearVelocity = Vector3.zero
    if (root.Position - desired).Magnitude > 7 then return true end

    local info = state.SeaBeastTool
    if not info or not info.Tool or not ownsFarmTool(info.Tool) or (Settings.SeaBeastWeapon ~= "Auto" and info.Category ~= Settings.SeaBeastWeapon) then
        local reason
        info, reason = resolveSeaBeastWeapon()
        state.SeaBeastTool = info
        if not info then
            contextNotice("SeaBeastWeapon", reason or "No usable weapon is available", Red, 5, 6)
            return true
        end
    end
    local character, humanoid = getCharacter(LocalPlayer)
    if not character or not humanoid then return true end
    if info.Tool.Parent ~= character then
        if os.clock() >= state.SeaBeastNextEquipAt then
            state.SeaBeastNextEquipAt = os.clock() + 1
            pcall(function() humanoid:EquipTool(info.Tool) end)
        end
        return true
    end
    fireSeaBeastSkill(part)
    return true
end

return {
    Update = updateSeaBeastAutomation,
    Clear = clearSeaBeastTarget,
    Nearest = nearestSeaBeast,
    Sail = updateSeaBeastHunt,
    StopSail = stopSeaBeastHunt,
    RestoreBoat = restoreSeaBeastBoatCollision
}
end)()

FarmRuntime.FightingStyles = (function()
local styles = {
    ["Dark Step"] = {
        Sea = 1, Cost = "$150,000", Check = { "BuyBlackLeg", true }, Buy = { "BuyBlackLeg" },
        Teachers = { "Dark Step Teacher" }, Locations = { "Pirate Village" },
        Fallback = Vector3.new(-1133, 36, 4199)
    },
    ["Electric"] = {
        Sea = 1, Cost = "$500,000", Check = { "BuyElectro", true }, Buy = { "BuyElectro" },
        Teachers = { "Mad Scientist" }, Locations = { "Skylands" },
        Fallback = Vector3.new(-5014, 320, -972), UseFallback = true,
        CloudSearchPoints = {
            Vector3.new(-5075, 262, -844),
            Vector3.new(-4070, 1070, -550)
        },
        SearchPoints = {
            Vector3.new(-5014, 320, -972),
            Vector3.new(-4631, 40, -519),
            Vector3.new(-5207, 545, -348)
        }
    },
    ["Water Kung Fu"] = {
        Sea = 1, Cost = "$750,000", Check = { "BuyFishmanKarate", true }, Buy = { "BuyFishmanKarate" },
        Teachers = { "Water Kung-fu Teacher", "Water Kung Fu Teacher" }, Locations = { "Underwater City" },
        Fallback = Vector3.new(61700, 50, 1025), UseFallback = true, RequiresFishmanEntrance = true
    },
    ["Dragon Breath"] = {
        Sea = 2, Cost = "1,500 Fragments", Check = { "BlackbeardReward", "DragonClaw", "1" }, Buy = { "BlackbeardReward", "DragonClaw", "2" },
        Teachers = { "Sabi" }, Locations = { "Kingdom of Rose" },
        Fallback = Vector3.new(-2440, 80, -3219)
    },
    ["Superhuman"] = {
        Sea = 2, Cost = "$3,000,000", Check = { "BuySuperhuman", true }, Buy = { "BuySuperhuman" },
        Teachers = { "Martial Arts Master" }, Locations = { "Snow Mountain" },
        Fallback = Vector3.new(752, 448, -5277)
    },
    ["Death Step"] = {
        Sea = 2, Cost = "$2,500,000 + 5,000 Fragments", Check = { "BuyDeathStep", true }, Buy = { "BuyDeathStep" },
        Teachers = { "Phoeyu, the Reformed" }, Locations = { "Ice Castle" },
        Fallback = Vector3.new(5505, 80, -6178)
    },
    ["Sharkman Karate"] = {
        Sea = 2, Cost = "$2,500,000 + 5,000 Fragments", Check = { "BuySharkmanKarate", true }, Buy = { "BuySharkmanKarate" },
        Teachers = { "Daigrock, the Sharkman" }, Locations = { "Forgotten Island" },
        Fallback = Vector3.new(-3050, 280, -10178)
    },
    ["Electric Claw"] = {
        Sea = 3, Cost = "$3,000,000 + 5,000 Fragments", Check = { "BuyElectricClaw", true }, Buy = { "BuyElectricClaw" },
        Teachers = { "Previous Hero" }, Locations = { "Floating Turtle" },
        Fallback = Vector3.new(-12528, 372, -8658)
    },
    ["Dragon Talon"] = {
        Sea = 3, Cost = "$3,000,000 + 5,000 Fragments", Check = { "BuyDragonTalon", true }, Buy = { "BuyDragonTalon" },
        Teachers = { "Uzoth", "Dragon Talon Sage" }, Locations = { "Hydra Island", "Haunted Castle" },
        Fallback = Vector3.new(5756, 650, -282)
    },
    ["Godhuman"] = {
        Sea = 3, Cost = "$5,000,000 + 5,000 Fragments", Check = { "BuyGodhuman", true }, Buy = { "BuyGodhuman" },
        Teachers = { "Ancient Monk" }, Locations = { "Floating Turtle" },
        Fallback = Vector3.new(-12528, 372, -8658)
    },
    ["Sanguine Art"] = {
        Sea = 3, Cost = "$5,000,000 + 5,000 Fragments", Check = { "BuySanguineArt", true }, Buy = { "BuySanguineArt" },
        Teachers = { "Shafi" }, Locations = { "Tiki Outpost" },
        Fallback = Vector3.new(-16234, 50, 438)
    }
}
local names = {
    [1] = { "Dark Step", "Electric", "Water Kung Fu" },
    [2] = { "Dragon Breath", "Superhuman", "Death Step", "Sharkman Karate" },
    [3] = { "Electric Claw", "Dragon Talon", "Godhuman", "Sanguine Art" }
}

local function cleanMessage(value)
    return tostring(value):gsub("<[^>]+>", ""):gsub("%s+", " ")
end

local function invoke(arguments)
    return pcall(function()
        return CommF:InvokeServer(table.unpack(arguments))
    end)
end

local requestBusy = false
local nextAutoCheckAt = 0
local purchase = {
    Serial = 0,
    Name = nil,
    Automatic = false,
    Stage = nil,
    StartedAt = 0,
    WaitUntil = 0,
    LastRouteAt = 0,
    PointIndex = 1,
    CloudSearchIndex = 1,
    CloudTarget = nil,
    CloudTargetAt = 0,
    CloudVisited = {},
    CloudClicks = 0,
    CloudClickBusy = false,
    CloudNextAttackAt = 0,
    CloudNextQuestCheckAt = 0,
    CloudQuestCheckPending = false,
    CloudQuestState = nil
}

local function normalized(value)
    return string.lower(tostring(value or "")):gsub("[^%w]", "")
end

local function sameName(value, candidates)
    local key = normalized(value)
    for _, candidate in ipairs(candidates or {}) do
        if key == normalized(candidate) then return true end
    end
    return false
end

local function findTeacher(style)
    local npcs = workspace:FindFirstChild("NPCs")
    if not npcs then return nil, nil end
    for _, npc in ipairs(npcs:GetChildren()) do
        if sameName(npc.Name, style.Teachers) then
            local part = getPart(npc)
            if part then return npc, part end
        end
    end
    return nil, nil
end

local function storedTeacherPosition(style)
    local npcs = ReplicatedStorage:FindFirstChild("NPCs")
    if not npcs then return nil end
    local bestPosition, bestDistance
    for _, npc in ipairs(npcs:GetChildren()) do
        if sameName(npc.Name, style.Teachers) then
            local part = getPart(npc)
            if part then
                local distance = style.Fallback and (part.Position - style.Fallback).Magnitude or 0
                if not bestPosition or distance < bestDistance then
                    bestPosition = part.Position + Vector3.new(0, 3, 0)
                    bestDistance = distance
                end
            end
        end
    end
    return bestPosition
end

local function locationPosition(style)
    local teacherPosition = storedTeacherPosition(style)
    if teacherPosition then return teacherPosition end
    if style.SearchPoints and #style.SearchPoints > 0 then
        return style.SearchPoints[math.clamp(purchase.PointIndex, 1, #style.SearchPoints)]
    end
    if style.UseFallback then return style.Fallback end
    local origin = workspace:FindFirstChild("_WorldOrigin")
    local locations = origin and origin:FindFirstChild("Locations")
    local best, bestDistance
    if locations then
        for _, marker in ipairs(locations:GetChildren()) do
            if marker:IsA("BasePart") and sameName(marker.Name, style.Locations) then
                local distance = style.Fallback and (marker.Position - style.Fallback).Magnitude or 0
                if not best or distance < bestDistance then
                    best = marker.Position + Vector3.new(0, 40, 0)
                    bestDistance = distance
                end
            end
        end
    end
    return best or style.Fallback
end

local function insideFishmanArea(root)
    return root and (root.Position - Vector3.new(61380, 20, 1222)).Magnitude <= 7000
end

local function fishmanStyleEntrance()
    local origin = workspace:FindFirstChild("_WorldOrigin")
    local locations = origin and origin:FindFirstChild("Locations")
    if locations then
        for _, marker in ipairs(locations:GetChildren()) do
            if marker:IsA("BasePart") and normalized(marker.Name) == "whirlpool" then
                return Vector3.new(marker.Position.X, math.max(marker.Position.Y + 80, 60), marker.Position.Z)
            end
        end
    end
    return fishmanEntrance
end

local function clearPurchase()
    purchase.Serial = purchase.Serial + 1
    purchase.Name = nil
    purchase.Automatic = false
    purchase.Stage = nil
    purchase.StartedAt = 0
    purchase.WaitUntil = 0
    purchase.LastRouteAt = 0
    purchase.PointIndex = 1
    purchase.CloudSearchIndex = 1
    purchase.CloudTarget = nil
    purchase.CloudTargetAt = 0
    purchase.CloudVisited = {}
    purchase.CloudClicks = 0
    purchase.CloudClickBusy = false
    purchase.CloudNextAttackAt = 0
    purchase.CloudNextQuestCheckAt = 0
    purchase.CloudQuestCheckPending = false
    purchase.CloudQuestState = nil
    if state.TravelMode == "farmStyle" then stopTravel() end
end

local function currentStyleName()
    if game.PlaceId == SEA_PLACE_IDS.First then return Settings.Sea1FightingStyle end
    if game.PlaceId == SEA_PLACE_IDS.Second then return Settings.Sea2FightingStyle end
    if game.PlaceId == SEA_PLACE_IDS.Third then return Settings.Sea3FightingStyle end
    return nil
end

local function setAutoBuy(enabled)
    Settings.AutoBuyFightingStyle = enabled == true
    nextAutoCheckAt = 0
    if not enabled and purchase.Name and purchase.Automatic then clearPurchase() end
end

local function stopAutoBuy()
    Settings.AutoBuyFightingStyle = false
    nextAutoCheckAt = 0
    if FightingStyleAutoControl and FightingStyleAutoControl.Set then
        task.defer(function()
            pcall(function() FightingStyleAutoControl:Set(false) end)
        end)
    end
end

local function startPurchase(name, automatic, stage)
    local style = styles[name]
    if not style then
        showNotice("Choose a fighting style first", Red, 4)
        return false
    end
    if purchase.Name or requestBusy then
        if not automatic then showNotice("A fighting style request is already running", Muted, 3) end
        return false
    end
    if state.TravelTarget then stopTravel() end
    invalidateFarmRuntime("", 0)
    purchase.Serial = purchase.Serial + 1
    purchase.Name = name
    purchase.Automatic = automatic == true
    purchase.Stage = stage or (style.RequiresFishmanEntrance and "entrance" or "teacher")
    purchase.StartedAt = os.clock()
    purchase.WaitUntil = 0
    purchase.LastRouteAt = 0
    purchase.PointIndex = 1
    purchase.CloudSearchIndex = 1
    purchase.CloudTarget = nil
    purchase.CloudTargetAt = 0
    purchase.CloudVisited = {}
    purchase.CloudClicks = 0
    purchase.CloudClickBusy = false
    purchase.CloudNextAttackAt = 0
    purchase.CloudNextQuestCheckAt = 0
    purchase.CloudQuestCheckPending = false
    purchase.CloudQuestState = stage == "electricCloud" and 1 or nil
    if stage == "electricCloud" then
        showNotice("Searching Skylands for a charged cloud", nil, 5)
    else
        showNotice("Going to " .. tostring(style.Teachers[1]), nil, 4)
    end
    return true
end

local function showCheckResult(name, style, ok, result)
    if not ok then
        showNotice("Could not check " .. name, Red, 4)
    elseif type(result) == "string" then
        showNotice(cleanMessage(result), Red, 6)
    elseif result == 1 then
        showNotice(name .. " is already owned", Green, 4)
    elseif result == 3 then
        showNotice("Requirements for " .. name .. " are not met", Red, 5)
    elseif result == 4 and name == "Electric Claw" then
        showNotice("Complete the Previous Hero time trial first", Red, 5)
    else
        showNotice(name .. " is available - " .. style.Cost, Green, 5)
    end
end

local function showElectricQuestState(ok, result)
    if not ok then
        showNotice("Could not check the Electric quest", Red, 4)
    elseif result == 0 or result == 5 then
        showNotice("Electric requires the Mad Scientist's Lightning Bolt quest", Red, 6)
    elseif result == 1 then
        showNotice("Destroy a flashing dark cloud in Skylands to get a Lightning Bolt", Muted, 7)
    else
        showNotice("Lightning Bolt ready - return to the Mad Scientist", Green, 5)
    end
end

local function showBuyResult(name, ok, result)
    if not ok then
        showNotice("Could not buy or equip " .. name, Red, 4)
    elseif type(result) == "string" then
        showNotice(cleanMessage(result), Red, 6)
    elseif result == 1 then
        showNotice(name .. " purchased or equipped", Green, 5)
    elseif name == "Electric" and result == 0 then
        showNotice("A Lightning Bolt is required for Electric", Red, 5)
    elseif name == "Electric" and result == 3 then
        showNotice("You need $500,000 for Electric", Red, 5)
    elseif name == "Electric" and result == 4 then
        showNotice("Leave combat before buying Electric", Red, 5)
    elseif result == 0 then
        showNotice("Not enough money, Fragments, or required items", Red, 5)
    elseif result == 2 then
        showNotice(name .. " is already owned", Muted, 4)
    elseif result == 3 then
        showNotice("Requirements for " .. name .. " are not met", Red, 5)
    elseif result == 4 and name == "Electric Claw" then
        showNotice("Complete the Previous Hero time trial first", Red, 5)
    else
        showNotice("The game rejected the " .. name .. " purchase", Red, 5)
    end
end

local function checkStyle(name)
    local style = styles[name]
    if not style then
        showNotice("Choose a fighting style first", Red, 4)
        return false
    end
    if requestBusy then
        showNotice("A fighting style request is already running", Muted, 3)
        return false
    end
    showNotice("Checking " .. name, nil, 3)
    requestBusy = true
    task.spawn(function()
        local ok, result
        if name == "Electric" then
            ok, result = invoke({ "ElectroQuestState" })
        else
            ok, result = invoke(style.Check)
        end
        requestBusy = false
        if state.Alive then
            if name == "Electric" then showElectricQuestState(ok, result)
            else showCheckResult(name, style, ok, result) end
        end
    end)
    return true
end

local function buyStyle(name)
    local style = styles[name]
    if not style then
        showNotice("Choose a fighting style first", Red, 4)
        return false
    end
    if requestBusy or purchase.Name then
        showNotice("A fighting style request is already running", Muted, 3)
        return false
    end
    return startPurchase(name, false)
end

local function electricCloudParts(root)
    local folder = workspace:FindFirstChild("CloudPieces")
    local clouds = {}
    if folder then
        for _, instance in ipairs(folder:GetDescendants()) do
            if instance:IsA("BasePart") and instance.Parent then
                clouds[#clouds + 1] = instance
            end
        end
    end
    table.sort(clouds, function(a, b)
        local aDistance = root and (root.Position - a.Position).Magnitude or 0
        local bDistance = root and (root.Position - b.Position).Magnitude or 0
        return aDistance < bDistance
    end)
    return clouds
end

local function activeLightningCloud(clouds)
    local origin = workspace:FindFirstChild("_WorldOrigin")
    local cache = origin and origin:FindFirstChild("LightningCache")
    if not cache then return nil end
    local best, bestDistance
    for _, bolt in ipairs(cache:GetDescendants()) do
        if bolt:IsA("BasePart") then
            local position = bolt.Position
            if math.abs(position.X) < 1000000 and math.abs(position.Y) < 1000000 and math.abs(position.Z) < 1000000 then
                for _, cloud in ipairs(clouds) do
                    local distance = (position - cloud.Position).Magnitude
                    if distance <= 180 and (not best or distance < bestDistance) then
                        best = cloud
                        bestDistance = distance
                    end
                end
            end
        end
    end
    return best
end

local function darkElectricCloud(clouds)
    local best, bestBrightness
    for _, cloud in ipairs(clouds) do
        local color = cloud.Color
        local brightness = color.R + color.G + color.B
        if brightness < 2.45 and (not best or brightness < bestBrightness) then
            best = cloud
            bestBrightness = brightness
        end
    end
    return best
end

local function resetElectricCloudTarget(visited)
    local target = purchase.CloudTarget
    if visited and target and target.Parent then purchase.CloudVisited[target] = true end
    purchase.CloudTarget = nil
    purchase.CloudTargetAt = 0
    purchase.CloudClicks = 0
    purchase.CloudNextAttackAt = 0
end

local function enterElectricCloudStage()
    if state.TravelMode == "farmStyle" then stopTravel() end
    purchase.Stage = "electricCloud"
    purchase.StartedAt = os.clock()
    purchase.WaitUntil = 0
    purchase.LastRouteAt = 0
    purchase.CloudSearchIndex = 1
    purchase.CloudVisited = {}
    purchase.CloudQuestState = 1
    purchase.CloudNextQuestCheckAt = 0
    purchase.CloudQuestCheckPending = false
    resetElectricCloudTarget(false)
    showNotice("Searching Skylands for a charged cloud", nil, 5)
end

local function checkElectricCloudQuest(now)
    if purchase.CloudQuestCheckPending or now < purchase.CloudNextQuestCheckAt then return end
    purchase.CloudQuestCheckPending = true
    purchase.CloudNextQuestCheckAt = now + 2.5
    local serial = purchase.Serial
    task.spawn(function()
        local ok, result = invoke({ "ElectroQuestState" })
        if purchase.Serial ~= serial or purchase.Stage ~= "electricCloud" then return end
        purchase.CloudQuestCheckPending = false
        if ok then
            purchase.CloudQuestState = result
        else
            contextNotice("ElectricCloudQuestCheck", "Could not check the Lightning Bolt; retrying", Red, 4, 8)
        end
    end)
end

local function clickElectricCloud(root, cloud, now)
    if purchase.CloudClickBusy or now < purchase.CloudNextAttackAt then return end
    local character, humanoid = getCharacter(LocalPlayer)
    if not character or not humanoid or humanoid.Health <= 0 then return end
    local info, reason = resolveFarmWeapon("Melee")
    if not info then info, reason = resolveFarmWeapon("Auto") end
    if not info then
        contextNotice("ElectricCloudWeapon", reason or "No weapon is available for the charged cloud", Red, 5, 8)
        return
    end
    if info.Tool.Parent ~= character then
        pcall(function() humanoid:EquipTool(info.Tool) end)
        purchase.CloudNextAttackAt = now + 0.5
        return
    end
    local camera = workspace.CurrentCamera
    if not camera then return end
    local point = Vector2.new(math.max(1, camera.ViewportSize.X - 24), math.floor(camera.ViewportSize.Y * 0.5))
    local serial = purchase.Serial
    purchase.CloudClickBusy = true
    purchase.CloudNextAttackAt = now + 0.14
    purchase.CloudClicks = purchase.CloudClicks + 1
    task.spawn(function()
        pcall(function() info.Tool:Activate() end)
        local pressed = pcall(function()
            farmVirtualInput:SendMouseButtonEvent(point.X, point.Y, 0, true, game, 0)
        end)
        if pressed then task.wait(0.04) end
        pcall(function()
            farmVirtualInput:SendMouseButtonEvent(point.X, point.Y, 0, false, game, 0)
        end)
        if purchase.Serial == serial then purchase.CloudClickBusy = false end
    end)
end

local function updateElectricCloud(root, style, now)
    checkElectricCloudQuest(now)
    if purchase.CloudQuestState ~= nil and purchase.CloudQuestState ~= 1 then
        if state.TravelMode == "farmStyle" then stopTravel() end
        resetElectricCloudTarget(false)
        purchase.Stage = "teacher"
        purchase.WaitUntil = 0
        purchase.LastRouteAt = 0
        showNotice("Lightning Bolt found - returning to the Mad Scientist", Green, 5)
        return true
    end

    local clouds = electricCloudParts(root)
    local lightningTarget = activeLightningCloud(clouds)
    local darkTarget = darkElectricCloud(clouds)
    local priorityTarget = lightningTarget or darkTarget
    if priorityTarget and purchase.CloudTarget ~= priorityTarget then
        resetElectricCloudTarget(false)
        purchase.CloudTarget = priorityTarget
        purchase.CloudTargetAt = now
        purchase.CloudVisited[priorityTarget] = nil
        contextNotice("ElectricChargedCloud", "Charged cloud found", Green, 3, 3)
    end

    if purchase.CloudTarget and not purchase.CloudTarget.Parent then resetElectricCloudTarget(false) end
    if not purchase.CloudTarget then
        for _, cloud in ipairs(clouds) do
            if not purchase.CloudVisited[cloud] then
                purchase.CloudTarget = cloud
                purchase.CloudTargetAt = now
                break
            end
        end
    end

    local cloud = purchase.CloudTarget
    if not cloud then
        if #clouds > 0 then
            purchase.CloudVisited = {}
            purchase.CloudSearchIndex = purchase.CloudSearchIndex % #style.CloudSearchPoints + 1
        end
        local searchPoint = style.CloudSearchPoints[purchase.CloudSearchIndex]
        if (root.Position - searchPoint).Magnitude > 25 then
            if now >= purchase.LastRouteAt or state.TravelMode ~= "farmStyle" then
                purchase.LastRouteAt = now + 0.5
                beginTravel(searchPoint, "Skylands storm clouds", "farmStyle", nil, true)
            end
        else
            if state.TravelMode == "farmStyle" then stopTravel() end
            if purchase.WaitUntil == 0 then purchase.WaitUntil = now + 4 end
            if now >= purchase.WaitUntil then
                purchase.WaitUntil = 0
                purchase.CloudSearchIndex = purchase.CloudSearchIndex % #style.CloudSearchPoints + 1
            end
        end
        return true
    end

    local desired = cloud.Position + Vector3.new(0, -math.max(0, cloud.Size.Y * 0.5 - 5), 0)
    local distance = (root.Position - desired).Magnitude
    if distance > 5 then
        if now >= purchase.LastRouteAt or state.TravelMode ~= "farmStyle" or state.TravelObject ~= cloud then
            purchase.LastRouteAt = now + 0.35
            beginTravel(desired, "charged cloud", "farmStyle", cloud, true)
        end
        return true
    end

    if state.TravelMode == "farmStyle" then stopTravel() end
    root.CFrame = CFrame.new(desired) * (root.CFrame - root.Position)
    root.AssemblyLinearVelocity = Vector3.zero
    clickElectricCloud(root, cloud, now)
    if not priorityTarget and (purchase.CloudClicks >= 18 or now - purchase.CloudTargetAt >= 3.5) then
        resetElectricCloudTarget(true)
    end
    return true
end

local function updatePurchase(root)
    local name = purchase.Name
    local style = name and styles[name]
    if not style then return false end
    local now = os.clock()
    if purchase.Automatic and (not Settings.AutoBuyFightingStyle or currentStyleName() ~= name) then
        clearPurchase()
        return false
    end
    local timeout = purchase.Stage == "electricCloud" and 900 or 180
    if now - purchase.StartedAt > timeout then
        local wasCloudHunt = purchase.Stage == "electricCloud"
        clearPurchase()
        showNotice(wasCloudHunt and "No charged cloud was found" or ("Could not reach the " .. tostring(style.Teachers[1])), Red, 5)
        return false
    end
    if not root then return true end

    if name == "Electric" and purchase.Stage == "electricCloud" then
        return updateElectricCloud(root, style, now)
    end

    if style.RequiresFishmanEntrance and not insideFishmanArea(root) then
        if purchase.Stage == "entranceDrop" then
            if now < purchase.WaitUntil then return true end
            clearPurchase()
            showNotice("The Whirlpool did not move you to Underwater City", Red, 5)
            return false
        end
        purchase.Stage = "entrance"
        local entrance = fishmanStyleEntrance()
        local entranceDistance = (root.Position - entrance).Magnitude
        if entranceDistance <= 3 then
            if state.TravelMode == "farmStyle" then stopTravel() end
            purchase.Stage = "entranceDrop"
            purchase.WaitUntil = now + 9
            root.AssemblyLinearVelocity = Vector3.zero
        elseif now >= purchase.LastRouteAt then
            purchase.WaitUntil = 0
            purchase.LastRouteAt = now + 0.5
            beginTravel(entrance, "Underwater City entrance", "farmStyle", nil, true)
        end
        return true
    end

    if purchase.Stage ~= "teacher" then
        purchase.Stage = "teacher"
        purchase.WaitUntil = 0
    end
    local teacher, teacherPart = findTeacher(style)
    if teacherPart then
        local distance = (root.Position - teacherPart.Position).Magnitude
        if distance > 10 then
            if now >= purchase.LastRouteAt or state.TravelMode ~= "farmStyle" or state.TravelObject ~= teacher then
                purchase.LastRouteAt = now + 0.35
                beginTravel(teacherPart.Position + Vector3.new(0, 3, 0), style.Teachers[1], "farmStyle", teacher, true)
            end
            return true
        end
        if state.TravelMode == "farmStyle" then stopTravel() end
        if requestBusy then return true end
        purchase.Stage = "buying"
        requestBusy = true
        local serial = purchase.Serial
        task.spawn(function()
            task.wait(0.35)
            if name == "Electric" then
                local questOk, questState = invoke({ "ElectroQuestState" })
                if purchase.Serial ~= serial then requestBusy = false; return end
                if not questOk then
                    requestBusy = false
                    clearPurchase()
                    showNotice("Could not check the Electric quest", Red, 5)
                    return
                end
                if questState == 0 or questState == 5 then
                    local acceptOk, acceptResult = invoke({ "AcceptElectroQuest" })
                    requestBusy = false
                    if purchase.Serial ~= serial then return end
                    if acceptOk and acceptResult == 1 then
                        enterElectricCloudStage()
                    else
                        clearPurchase()
                        showNotice("The Mad Scientist did not start the Electric quest", Red, 6)
                    end
                    return
                elseif questState == 1 then
                    requestBusy = false
                    enterElectricCloudStage()
                    return
                elseif questState == 4 then
                    local deliverOk, deliverResult = invoke({ "DeliverLightningBolt" })
                    if purchase.Serial ~= serial then requestBusy = false; return end
                    if not deliverOk or deliverResult ~= 1 then
                        requestBusy = false
                        clearPurchase()
                        showNotice("The Lightning Bolt could not be delivered", Red, 6)
                        return
                    end
                    task.wait(0.25)
                end
            elseif name == "Water Kung Fu" then
                local accessOk, hasAccess = invoke({ "CheckFishmanKarate" })
                if purchase.Serial ~= serial then requestBusy = false; return end
                if not accessOk or not hasAccess then
                    requestBusy = false
                    clearPurchase()
                    showNotice("The Water Kung Fu chamber is not unlocked yet", Red, 6)
                    return
                end
            end
            local ok, result = invoke(style.Buy)
            requestBusy = false
            if purchase.Serial ~= serial then return end
            local wasAutomatic = purchase.Automatic
            clearPurchase()
            if not state.Alive then return end
            if wasAutomatic and ok and (result == 1 or result == 2) then stopAutoBuy() end
            showBuyResult(name, ok, result)
        end)
        return true
    end

    local staging = locationPosition(style)
    if not staging then
        clearPurchase()
        showNotice("Could not find the island for " .. name, Red, 5)
        return false
    end
    local distance = (root.Position - staging).Magnitude
    if distance > 80 then
        if now >= purchase.LastRouteAt or state.TravelMode ~= "farmStyle" then
            purchase.LastRouteAt = now + 0.5
            beginTravel(staging, style.Locations[1], "farmStyle", nil, true)
        end
    else
        if state.TravelMode == "farmStyle" then stopTravel() end
        if purchase.WaitUntil == 0 then purchase.WaitUntil = now + 10 end
        if now >= purchase.WaitUntil then
            if style.SearchPoints and purchase.PointIndex < #style.SearchPoints then
                purchase.PointIndex = purchase.PointIndex + 1
                purchase.WaitUntil = 0
                purchase.LastRouteAt = 0
            else
                clearPurchase()
                showNotice(style.Teachers[1] .. " did not load near " .. style.Locations[1], Red, 6)
                return false
            end
        end
    end
    return true
end

local function updateAutoBuy(root)
    if purchase.Name then return updatePurchase(root) end
    if not Settings.AutoBuyFightingStyle or requestBusy or os.clock() < nextAutoCheckAt then return false end
    local name = currentStyleName()
    local style = styles[name]
    if not style then
        stopAutoBuy()
        showNotice("Choose a fighting style first", Red, 4)
        return false
    end
    nextAutoCheckAt = os.clock() + 4
    requestBusy = true
    task.spawn(function()
        if name == "Electric" then
            local questOk, questState = invoke({ "ElectroQuestState" })
            requestBusy = false
            if not state.Alive or not Settings.AutoBuyFightingStyle then return end
            if not questOk then
                contextNotice("AutoElectricQuest", "Could not check the Electric quest; retrying", Red, 4, 8)
            elseif questState == 1 then
                if currentStyleName() == name then startPurchase(name, true, "electricCloud") end
            elseif currentStyleName() == name then
                startPurchase(name, true)
            end
            return
        end
        local checkOk, checkResult = invoke(style.Check)
        if not state.Alive or not Settings.AutoBuyFightingStyle then
            requestBusy = false
            return
        end
        if not checkOk then
            requestBusy = false
            contextNotice("AutoStyleCheck", "Could not check " .. name .. "; retrying", Red, 4, 8)
            return
        end
        if type(checkResult) == "string" or checkResult == 3 or (checkResult == 4 and name == "Electric Claw") then
            requestBusy = false
            local message = type(checkResult) == "string" and cleanMessage(checkResult)
                or checkResult == 4 and "Complete the Previous Hero time trial first"
                or "Requirements for " .. name .. " are not met"
            contextNotice("AutoStyleWaiting:" .. name, message, Red, 5, 10)
            return
        end
        if currentStyleName() ~= name then
            requestBusy = false
            nextAutoCheckAt = 0
            return
        end
        requestBusy = false
        if not state.Alive or not Settings.AutoBuyFightingStyle then return end
        startPurchase(name, true)
    end)
    return false
end

return {
    Names = names,
    Check = checkStyle,
    Buy = buyStyle,
    Update = updateAutoBuy,
    SetAuto = setAutoBuy,
    Clear = clearPurchase
}
end)()

FarmRuntime.ClearTravel = clearFarmTravel
FarmRuntime.Invalidate = invalidateFarmRuntime
FarmRuntime.InvalidateSea2 = invalidateSea2Runtime
FarmRuntime.IsTravelMode = isFarmTravelMode
FarmRuntime.MasteryLevel = masteryLevel
FarmRuntime.OwnsTool = ownsFarmTool
FarmRuntime.ResolveWeapon = resolveFarmWeapon
FarmRuntime.ProcessClick = processFarmClick
FarmRuntime.Update = updateAutoFarm
FarmRuntime.UpdateSea2 = updateAutoSea2
FarmRuntime.UpdateSecondSea = secondSeaRuntime.Update
FarmRuntime.UpdateSeaBeast = seaBeastRuntime.Update
FarmRuntime.ClearSeaBeast = seaBeastRuntime.Clear
FarmRuntime.NearestSeaBeast = seaBeastRuntime.Nearest
FarmRuntime.SeaBeastSail = seaBeastRuntime.Sail
FarmRuntime.StopSeaBeastSail = seaBeastRuntime.StopSail
FarmRuntime.RestoreSeaBoatCollision = seaBeastRuntime.RestoreBoat
FarmRuntime.SetSecondSeaMode = secondSeaRuntime.SetMode
FarmRuntime.SpecialStatus = secondSeaRuntime.Status
FarmRuntime.RaidTypes = secondSeaRuntime.RaidTypes
FarmRuntime.DropGoals = secondSeaRuntime.DropGoals
FarmRuntime.CheckDealer = secondSeaRuntime.CheckDealer
FarmRuntime.DealerHint = secondSeaRuntime.DealerHint
FarmRuntime.TravelDealer = secondSeaRuntime.TravelDealer
FarmRuntime.BuyLegendarySword = secondSeaRuntime.BuyLegendarySword
FarmRuntime.BuyRaidChip = secondSeaRuntime.BuyRaidChip
FarmRuntime.StartRaid = secondSeaRuntime.StartRaid
end

FarmRuntime.RaceAbilityNames = {
    "Last Resort",
    "Agility",
    "Water Body",
    "Heavenly Blood",
    "Heightened Senses",
    "Energy Core",
    "Primordial Reign"
}

FarmRuntime.RaceV3AbilityTool = function()
    local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
    local character = LocalPlayer.Character
    for _, name in ipairs(FarmRuntime.RaceAbilityNames) do
        local tool = character and character:FindFirstChild(name) or nil
        tool = tool or (backpack and backpack:FindFirstChild(name) or nil)
        if tool and tool:IsA("Tool") then return tool end
    end
    return nil
end

FarmRuntime.RaceV3ThreatNearby = function(root, range)
    if not root then return false end
    local farmPart = getPart(state.FarmTarget)
    local farmHumanoid = getHumanoid(state.FarmTarget)
    if farmPart and farmHumanoid and farmHumanoid.Health > 0 and (farmPart.Position - root.Position).Magnitude <= range then
        return true
    end
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and not isAlly(player) then
            local character, humanoid, playerRoot = getCharacter(player)
            if character and humanoid and playerRoot and humanoid.Health > 0
                and (playerRoot.Position - root.Position).Magnitude <= range
            then
                return true
            end
        end
    end
    return false
end

FarmRuntime.UpdateRaceV3Ability = function()
    if not Settings.AutoRaceV3Ability then
        state.RaceAbilityMissingNotified = false
        return
    end
    local _, humanoid, root = getCharacter(LocalPlayer)
    if not humanoid or not root or humanoid.Health <= 0 then return end
    local tool = FarmRuntime.RaceV3AbilityTool()
    if not tool then
        if not state.RaceAbilityMissingNotified then
            state.RaceAbilityMissingNotified = true
            contextNotice("RaceV3AbilityMissing", "Unlock Race V3 before enabling its ability", Red, 5, 10)
        end
        return
    end
    state.RaceAbilityMissingNotified = false
    if tool.Enabled == false or os.clock() < state.RaceAbilityNextAt then return end

    local trigger = Settings.RaceV3AbilityTrigger
    local shouldActivate = trigger == "When Ready"
    if trigger == "Low Health" then
        local healthPercent = humanoid.MaxHealth > 0 and humanoid.Health / humanoid.MaxHealth * 100 or 100
        shouldActivate = healthPercent <= Settings.RaceV3AbilityHealth
    elseif trigger == "Enemy Nearby" then
        shouldActivate = FarmRuntime.RaceV3ThreatNearby(root, Settings.RaceV3AbilityRange)
    elseif trigger == "While Farming" then
        local targetHumanoid = getHumanoid(state.FarmTarget)
        shouldActivate = targetHumanoid ~= nil and targetHumanoid.Health > 0
    end
    if not shouldActivate then return end

    state.RaceAbilityNextAt = os.clock() + math.clamp(Settings.RaceV3AbilityRetryDelay, 2, 30)
    local remote = Remotes:FindFirstChild("CommE")
    local ok = remote and pcall(function() remote:FireServer("ActivateAbility") end)
    if not ok then
        contextNotice("RaceV3AbilityFailed", "Race V3 ability activation failed; retrying", Red, 4, 8)
    end
end

FarmRuntime.UpdateStats = function()
    if not Settings.AutoStats or state.AutoStatsBusy or os.clock() < state.AutoStatsNextAt then return end
    state.AutoStatsNextAt = os.clock() + 0.4

    local data = LocalPlayer:FindFirstChild("Data")
    local pointsValue = data and data:FindFirstChild("Points")
    local statsFolder = data and data:FindFirstChild("Stats")
    local points = pointsValue and tonumber(pointsValue.Value) or 0
    if not statsFolder or points <= 0 then return end

    local selected = Settings.AutoStatSelection
    if type(selected) ~= "table" or #selected == 0 then
        contextNotice("AutoStatsSelection", "Choose at least one stat to balance", Red, 4, 6)
        return
    end

    local entries, seen = {}, {}
    for _, displayName in ipairs(selected) do
        local remoteName = displayName == "Blox Fruit" and "Demon Fruit" or displayName
        if not seen[remoteName] then
            seen[remoteName] = true
            local statFolder = statsFolder:FindFirstChild(remoteName)
            local levelValue = statFolder and statFolder:FindFirstChild("Level")
            if levelValue then
                entries[#entries + 1] = {
                    Name = remoteName,
                    DisplayName = displayName,
                    Level = tonumber(levelValue.Value) or 0
                }
            end
        end
    end
    if #entries == 0 then
        contextNotice("AutoStatsUnavailable", "The selected stats are unavailable", Red, 4, 6)
        return
    end

    table.sort(entries, function(a, b)
        if a.Level ~= b.Level then return a.Level < b.Level end
        return a.Name < b.Name
    end)

    local allocations = {}
    local remaining = math.floor(points)
    local balancedCount = 1
    while balancedCount < #entries and remaining > 0 do
        local gap = math.max(0, entries[balancedCount + 1].Level - entries[balancedCount].Level)
        if gap == 0 then
            balancedCount = balancedCount + 1
        else
            local cost = gap * balancedCount
            if cost <= remaining then
                for index = 1, balancedCount do
                    allocations[entries[index]] = (allocations[entries[index]] or 0) + gap
                    entries[index].Level = entries[index].Level + gap
                end
                remaining = remaining - cost
                balancedCount = balancedCount + 1
            else
                local share = math.floor(remaining / balancedCount)
                local extra = remaining % balancedCount
                for index = 1, balancedCount do
                    allocations[entries[index]] = (allocations[entries[index]] or 0) + share + (index <= extra and 1 or 0)
                end
                remaining = 0
            end
        end
    end
    if remaining > 0 then
        local share = math.floor(remaining / #entries)
        local extra = remaining % #entries
        for index, entry in ipairs(entries) do
            allocations[entry] = (allocations[entry] or 0) + share + (index <= extra and 1 or 0)
        end
    end

    state.AutoStatsBusy = true
    task.spawn(function()
        local before = tonumber(pointsValue.Value) or points
        local requested = false
        for _, entry in ipairs(entries) do
            local amount = allocations[entry] or 0
            if amount > 0 and Settings.AutoStats and state.Alive then
                requested = true
                pcall(function() CommF:InvokeServer("AddPoint", entry.Name, amount) end)
                task.wait(0.08)
            end
        end
        task.wait(0.2)
        state.AutoStatsBusy = false
        state.AutoStatsNextAt = os.clock() + 0.35
        if requested and Settings.AutoStats and pointsValue.Parent and (tonumber(pointsValue.Value) or before) >= before then
            contextNotice("AutoStatsRejected", "Stat points were not accepted; waiting before retrying", Red, 4, 4)
            state.AutoStatsNextAt = os.clock() + 3
        end
    end)
end

local function storableFruitTool(instance)
    if not instance or not instance:IsA("Tool") or CollectionService:HasTag(instance, "WeaponTool") then return false end
    local originalName = instance:GetAttribute("OriginalName")
    local hasEatRemote = instance:FindFirstChild("EatRemote", true) ~= nil
    local hasFruitMarker = instance:FindFirstChild("Fruit", true) ~= nil
    local namedFruit = string.find(string.lower(instance.Name), "fruit", 1, true) ~= nil
    return type(originalName) == "string" and originalName ~= "" and (hasEatRemote or hasFruitMarker or namedFruit)
end

local function fruitToolDisplayName(instance)
    if not storableFruitTool(instance) then return nil end
    return formatFruitName(instance:GetAttribute("OriginalName") or instance.Name)
end

local function fruitMatchesOverride(instance)
    local displayName = fruitToolDisplayName(instance)
    return state.FruitOverrideActive
        and displayName ~= nil
        and string.lower(displayName) == string.lower(tostring(state.FruitOverrideName or ""))
end

local function clearFruitOverride(resumeFarm)
    local wasActive = state.FruitOverrideActive
    state.FruitOverrideActive = false
    state.FruitOverrideObject = nil
    state.FruitOverrideName = nil
    state.FruitOverrideStartedAt = 0
    state.FruitOverrideMissingAt = 0
    state.FruitOverrideReachedAt = 0
    if state.TravelOwner == "fruit" then stopTravel() end
    if wasActive and resumeFarm ~= false and Settings.AutoFarm then
        FarmRuntime.Invalidate("", 0.15)
    end
end

local function startFruitOverride(root, fruit)
    local part = getPart(fruit)
    if not root or not part or not part:IsDescendantOf(workspace) then return false end
    local displayName = formatFruitName(fruit)
    if state.FruitOverrideActive and state.FruitOverrideObject == fruit then return true end
    clearFruitOverride(false)
    state.FruitOverrideActive = true
    state.FruitOverrideObject = fruit
    state.FruitOverrideName = displayName
    state.FruitOverrideStartedAt = os.clock()
    if Settings.AutoFarm then FarmRuntime.Invalidate("", 0) end
    if beginTravel(part.Position, displayName .. " Fruit", "fruit", fruit, true) then
        showNotice("Collecting " .. displayName .. " Fruit", espColor(Settings.FruitColor), 4)
        return true
    end
    clearFruitOverride(true)
    return false
end

local queueFruitStore

local function findOverrideFruitTool()
    for _, container in ipairs({ LocalPlayer.Character, LocalPlayer:FindFirstChildOfClass("Backpack") }) do
        if container then
            for _, instance in ipairs(container:GetChildren()) do
                if fruitMatchesOverride(instance) then return instance end
            end
        end
    end
    return nil
end

local function updateFruitOverride(root)
    if not Settings.AutoFruit then
        clearFruitOverride(true)
        return false
    end
    if not state.FruitOverrideActive then
        local fruit = findNearestFruit(root, true)
        return fruit and startFruitOverride(root, fruit) or false
    end

    local fruit = state.FruitOverrideObject
    local part = getPart(fruit)
    if part and part:IsDescendantOf(workspace) then
        local rarest = findNearestFruit(root, false)
        if rarest and rarest ~= fruit
            and FarmRuntime.FruitPriorityRank(rarest) < FarmRuntime.FruitPriorityRank(fruit)
        then
            return startFruitOverride(root, rarest)
        end
        state.FruitOverrideMissingAt = 0
        if state.TravelOwner ~= "fruit" or state.TravelObject ~= fruit then
            beginTravel(part.Position, tostring(state.FruitOverrideName) .. " Fruit", "fruit", fruit, true)
        end
        return true
    end

    if state.FruitOverrideMissingAt == 0 then state.FruitOverrideMissingAt = os.clock() end
    local tool = findOverrideFruitTool()
    if tool then
        queueFruitStore(tool)
        return true
    end
    if os.clock() - state.FruitOverrideMissingAt >= 8 then
        contextNotice("FruitPickup", "Fruit pickup could not be confirmed; resuming Auto Farm", Red, 4, 8)
        clearFruitOverride(true)
        return false
    end
    return true
end

queueFruitStore = function(instance)
    local overrideStore = fruitMatchesOverride(instance)
    if (not Settings.AutoStoreFruit and not overrideStore) or not storableFruitTool(instance) then return end
    local lastAttempt = state.FruitStoreAttempts[instance]
    if lastAttempt and os.clock() - lastAttempt < 4 then return end
    state.FruitStoreAttempts[instance] = os.clock()
    task.delay(0.35, function()
        local stillOverride = fruitMatchesOverride(instance)
        if not state.Alive or (not Settings.AutoStoreFruit and not stillOverride) or not storableFruitTool(instance) then return end
        if instance.Parent ~= LocalPlayer.Character and instance.Parent ~= LocalPlayer:FindFirstChildOfClass("Backpack") then return end
        local originalName = instance:GetAttribute("OriginalName")
        local ok, result = pcall(function()
            return CommF:InvokeServer("StoreFruit", originalName, instance)
        end)
        if not state.Alive then return end
        if ok and result == true then
            showNotice(formatFruitName(originalName) .. " stored", espColor(Settings.FruitColor), 4)
            if stillOverride then clearFruitOverride(true) end
        elseif ok and type(result) == "number" then
            showNotice(formatFruitName(originalName) .. " storage is full", Red, 5)
            if stillOverride then clearFruitOverride(true) end
        elseif instance.Parent then
            state.FruitStoreAttempts[instance] = nil
        end
    end)
end

local function rememberOwnedTools(container)
    if not container then return end
    for _, child in ipairs(container:GetChildren()) do
        if child:IsA("Tool") then state.KnownTools[child] = true end
    end
end

local function recordDrop(instance)
    if not state.DropReady or not instance or not instance:IsA("Tool") then return end
    if state.KnownTools[instance] then return end
    state.KnownTools[instance] = true
    table.insert(state.RecentDrops, 1, instance.Name)
    while #state.RecentDrops > 8 do table.remove(state.RecentDrops) end
    if Settings.FarmDropAlerts then showNotice("Item obtained: " .. instance.Name, nil, 5) end
    if Settings.AutoWeaponGoal and string.lower(instance.Name) == string.lower(Settings.WeaponGoal) then
        Settings.AutoWeaponGoal = false
        FarmRuntime.Invalidate("", 0)
        if WeaponGoalControl and WeaponGoalControl.Set then
            task.defer(function() pcall(function() WeaponGoalControl:Set(false) end) end)
        end
        showNotice(Settings.WeaponGoal .. " obtained", nil, 5)
    elseif Settings.AutoWeaponGoal and Settings.WeaponGoal == "Rengoku" and string.lower(instance.Name) == "hidden key" then
        Settings.AutoWeaponGoal = false
        FarmRuntime.Invalidate("", 0)
        if WeaponGoalControl and WeaponGoalControl.Set then
            task.defer(function() pcall(function() WeaponGoalControl:Set(false) end) end)
        end
        showNotice("Hidden Key obtained - open the Rengoku chest in Ice Castle", nil, 6)
    end
end

local function farmInventoryChanged(instance)
    if not instance or not instance:IsA("Tool") then return end
    state.FarmInventoryVersion = state.FarmInventoryVersion + 1
    local selected = state.FarmTool
    task.defer(function()
        if not state.Alive or (not Settings.AutoFarm and not Settings.AutoBosses and not Settings.AutoMaterial and not Settings.AutoWeaponGoal and not state.SpecialFarm) then return end
        if instance == selected and FarmRuntime.OwnsTool(selected) then return end
        FarmRuntime.Invalidate("Inventory changed", 0.15)
    end)
end

local function bindFarmCharacter(character)
    if not character then return end
    rememberOwnedTools(character)
    connect(character.ChildAdded, function(instance)
        recordDrop(instance)
        queueFruitStore(instance)
        farmInventoryChanged(instance)
    end)
    connect(character.ChildRemoved, farmInventoryChanged)
    local humanoid = character:FindFirstChildOfClass("Humanoid") or character:WaitForChild("Humanoid", 5)
    if humanoid then
        connect(humanoid.Died, function()
            state.AimTarget = nil
            FarmRuntime.Invalidate("Waiting for character", 1)
            FarmRuntime.InvalidateSea2(1)
        end)
    end
end

rebuildFarmData()
local FarmEnemyNames = farmEnemyNames()
local BossNames = getBossNames()
Settings.SelectedIsland = Settings.SelectedIsland or IslandNames[1]
Settings.SelectedBoss = Settings.SelectedBoss or BossNames[1]
Settings.FarmBoss = Settings.FarmBoss or BossNames[1]

local function travelToIsland(useHome)
    local buttonKey = useHome and "islandHome" or "island"
    if state.TravelTarget and state.TravelButtonKey == buttonKey then
        stopTravel("Travel stopped")
        return
    end
    local _, _, root = getCharacter(LocalPlayer)
    local position, island = FarmRuntime.ResolveIsland(Settings.SelectedIsland, root)
    if not island or not position then
        showNotice("Island unavailable", Red, 3)
        return
    end
    beginTravel(position + Vector3.new(0, 5, 0), island.Name, useHome and "manualHome" or "manual", island, false, buttonKey)
end

local function travelToBoss()
    if state.TravelTarget and state.TravelButtonKey == "boss" then
        stopTravel("Travel stopped")
        return
    end
    local _, _, root = getCharacter(LocalPlayer)
    local boss = findNearestBoss(root, Settings.SelectedBoss)
    local part = getPart(boss)
    if not part then
        showNotice("Selected boss is not spawned", Red, 3)
        return
    end
    beginTravel(part.Position + Vector3.new(0, 6, 0), boss.Name, "manual", boss, false, "boss")
end

local function travelToFruit()
    if state.TravelTarget and state.TravelButtonKey == "fruit" then
        stopTravel("Travel stopped")
        return
    end
    local _, _, root = getCharacter(LocalPlayer)
    local fruit = findNearestFruit(root, false, true)
    local part = getPart(fruit)
    if not part then
        showNotice("No physical fruit found", Red, 3)
        return
    end
    beginTravel(part.Position + Vector3.new(0, 3, 0), formatFruitName(fruit) .. " Fruit", "manual", fruit, false, "fruit")
end

local function travelToChest()
    if state.TravelTarget and state.TravelButtonKey == "chest" then
        stopTravel("Travel stopped")
        return
    end
    local _, _, root = getCharacter(LocalPlayer)
    local chest = findNearestChest(root)
    local part = getPart(chest)
    if not part then
        showNotice("No chest found", Red, 3)
        return
    end
    beginTravel(part.Position + Vector3.new(0, 4, 0), "Nearest Chest", "manual", chest, false, "chest")
end

local function fetchServers(lowest)
    local url = "https://games.roblox.com/v1/games/" .. tostring(game.PlaceId) .. "/servers/Public?sortOrder=Asc&limit=100"
    local ok, body = pcall(function() return game:HttpGet(url) end)
    if not ok then return nil end
    local decodedOk, payload = pcall(HttpService.JSONDecode, HttpService, body)
    if not decodedOk or type(payload) ~= "table" or type(payload.data) ~= "table" then return nil end
    local choices = {}
    for _, server in ipairs(payload.data) do
        if server.id ~= game.JobId and tonumber(server.playing) and tonumber(server.maxPlayers) and server.playing < server.maxPlayers then
            choices[#choices + 1] = server
        end
    end
    if #choices == 0 then return nil end
    if lowest then table.sort(choices, function(a, b) return a.playing < b.playing end) end
    return lowest and choices[1] or choices[math.random(1, #choices)]
end

local function serverHop(lowest)
    showNotice(lowest and "Finding low-player server" or "Finding another server", Accent, 4)
    task.spawn(function()
        local server = fetchServers(lowest)
        if not server then
            showNotice("No suitable server found", Red, 4)
            return
        end
        pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer) end)
    end)
end

FarmRuntime.ServerHop = serverHop

local function rejoin(restoreSession)
    if restoreSession then
        local prepared, prepareError = FarmRuntime.Session.PrepareTeleport()
        if not prepared then
            state.AutoRejoinBusy = false
            state.AutoRejoinAt = os.clock() + 60
            showNotice("Rejoin setup failed: " .. tostring(prepareError or "Unknown error"), Red, 5)
            return false
        end
    end
    state.AutoRejoinBusy = true
    task.spawn(function()
        local ok = pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer) end)
        if not ok and state.Alive then
            state.AutoRejoinBusy = false
            state.AutoRejoinAt = os.clock() + 60
            if not Settings.AutoRejoin30 then FarmRuntime.Session.ClearPending() end
            showNotice("Rejoin failed; retrying in one minute", Red, 5)
        end
    end)
    return true
end

connect(TeleportService.TeleportInitFailed, function(player)
    if player ~= LocalPlayer or not state.AutoRejoinBusy then return end
    state.AutoRejoinBusy = false
    state.AutoRejoinAt = Settings.AutoRejoin30 and (os.clock() + 60) or 0
    if not Settings.AutoRejoin30 then FarmRuntime.Session.ClearPending() end
    showNotice("Rejoin failed; retrying in one minute", Red, 5)
end)

FarmRuntime.FindEvent = function(eventName)
    local definition = FarmRuntime.EventDefinitions[eventName]
    if not definition then return nil, "Choose a valid event" end
    if definition.Place and definition.Place ~= game.PlaceId then
        local seaName = definition.Place == SEA_PLACE_IDS.First and "First Sea"
            or definition.Place == SEA_PLACE_IDS.Second and "Second Sea"
            or "Third Sea"
        return nil, eventName .. " is only available in the " .. seaName
    end

    local wanted = {}
    for _, name in ipairs(definition.Enemies or {}) do wanted[normalizeEnemyName(name)] = true end
    for _, folderName in ipairs({ "Enemies", "SeaBeasts", "SeaEvents" }) do
        local folder = workspace:FindFirstChild(folderName)
        if folder then
            for _, instance in ipairs(folder:GetChildren()) do
                if wanted[normalizeEnemyName(instance.Name)] then
                    local humanoid = getHumanoid(instance)
                    if not humanoid or humanoid.Health > 0 then return instance end
                end
            end
        end
    end
    for _, folderName in ipairs(definition.Folders or {}) do
        local folder = workspace:FindFirstChild(folderName)
        if folder and #folder:GetChildren() > 0 then return folder:GetChildren()[1] end
    end

    local origin = workspace:FindFirstChild("_WorldOrigin")
    local locations = origin and origin:FindFirstChild("Locations")
    if locations then
        for _, location in ipairs(locations:GetChildren()) do
            for _, name in ipairs(definition.Locations or {}) do
                if string.lower(location.Name) == string.lower(name) then return location end
            end
        end
    end
    return nil, eventName .. " is not active in this server"
end

FarmRuntime.CheckEvent = function(notify)
    local found, reason = FarmRuntime.FindEvent(Settings.EventName)
    if found then
        if notify or state.EventFound ~= found or state.EventFoundName ~= Settings.EventName then
            showNotice(Settings.EventName .. " found in this server", nil, 5)
        end
        state.EventFound = found
        state.EventFoundName = Settings.EventName
        return true, found
    end
    state.EventFound = nil
    state.EventFoundName = nil
    if notify then contextNotice("EventFinderCheck", reason, Red, 4, 2) end
    return false, reason
end

FarmRuntime.UpdateEventFinder = function()
    if not Settings.EventFinder or os.clock() < state.EventNextCheckAt then return end
    state.EventNextCheckAt = os.clock() + 1
    local found, reason = FarmRuntime.CheckEvent(false)
    if found then return end
    local definition = FarmRuntime.EventDefinitions[Settings.EventName]
    if definition and definition.Place and definition.Place ~= game.PlaceId then
        contextNotice("EventFinderSea", reason, Red, 4, 8)
        return
    end
    if Settings.EventAutoHop and os.clock() >= state.EventNextHopAt then
        state.EventNextHopAt = os.clock() + math.max(10, Settings.EventHopDelay)
        showNotice("Searching another server for " .. Settings.EventName, nil, 4)
        serverHop(true)
    end
end

FarmRuntime.SpecialIslandNames = { "Kitsune Island", "Mirage Island", "Prehistoric Island" }

FarmRuntime.SpecialIslandAliases = {
    ["Kitsune Island"] = { "Kitsune Island", "KitsuneIsland", "Kitsune Shrine", "KitsuneShrine" },
    ["Mirage Island"] = { "Mirage Island", "MirageIsland", "Mystic Island", "MysticIsland" },
    ["Prehistoric Island"] = { "Prehistoric Island", "PrehistoricIsland" }
}

FarmRuntime.SpecialIslandPosition = function(instance)
    if not instance then return nil end
    if instance:IsA("BasePart") then return instance.Position end
    if instance:IsA("Model") then
        local ok, pivot = pcall(function() return instance:GetPivot() end)
        if ok then return pivot.Position end
    end
    return nil
end

FarmRuntime.FindSpecialIsland = function(name)
    local aliases = FarmRuntime.SpecialIslandAliases[name]
    if not aliases then return nil end
    local origin = workspace:FindFirstChild("_WorldOrigin")
    local roots = {
        { Instance = origin and origin:FindFirstChild("Locations"), Source = "Workspace locations" },
        { Instance = workspace:FindFirstChild("Map"), Source = "Workspace map" },
        { Instance = workspace:FindFirstChild("SeaEvents"), Source = "Workspace sea events" }
    }
    for _, rootInfo in ipairs(roots) do
        local root = rootInfo.Instance
        if root then
            for _, alias in ipairs(aliases) do
                local instance = root:FindFirstChild(alias, true)
                local position = FarmRuntime.SpecialIslandPosition(instance)
                if position then return instance, position, rootInfo.Source end
            end
        end
    end
    return nil
end

FarmRuntime.LocateSpecialIsland = function(notify)
    local name = Settings.IslandFinderTarget
    local island, position, source = FarmRuntime.FindSpecialIsland(name)
    if island then
        local _, _, root = getCharacter(LocalPlayer)
        local distance = root and math.floor((position - root.Position).Magnitude + 0.5) or nil
        if notify then
            showNotice(name .. " found" .. (distance and (" - " .. tostring(distance) .. " studs") or ""), Green, 6)
        end
        return island, position, source
    end
    if notify then contextNotice("IslandFinderMissing", name .. " has not been found yet", Muted, 4, 2) end
    return nil
end

FarmRuntime.RefreshIslandFinderButton = function()
    local control = state.IslandFinderButtonControl
    if control and control.SetText then
        control:SetText(Settings.IslandFinderAutoFind and "Stop Finding" or "Find Island")
    end
end

FarmRuntime.StopIslandSearch = function(syncControl, notify)
    local wasFinding = Settings.IslandFinderAutoFind
    Settings.IslandFinderAutoFind = false
    state.IslandFinderNextScanAt = 0
    if state.TravelOwner == "seaBeast" then stopTravel() end
    if FarmRuntime.RestoreSeaBoatCollision then FarmRuntime.RestoreSeaBoatCollision() end
    if not Settings.AutoSeaBeast and not Settings.AutoMirage then FarmRuntime.StopSeaBeastSail(true) end
    if syncControl ~= false and state.IslandFinderAutoControl and state.IslandFinderAutoControl.Set then
        task.defer(function()
            pcall(function() state.IslandFinderAutoControl:Set(false) end)
        end)
    end
    FarmRuntime.RefreshIslandFinderButton()
    if notify and wasFinding then showNotice("Island search stopped", Muted, 3) end
end

FarmRuntime.StartIslandSearch = function(syncControl)
    local wasFinding = Settings.IslandFinderAutoFind
    Settings.IslandFinderAutoFind = true
    state.IslandFinderFound = nil
    state.IslandFinderFoundName = Settings.IslandFinderTarget
    state.IslandFinderNextScanAt = 0
    if syncControl ~= false and state.IslandFinderAutoControl and state.IslandFinderAutoControl.Set then
        task.defer(function()
            pcall(function() state.IslandFinderAutoControl:Set(true) end)
        end)
    end
    if not wasFinding or syncControl ~= false then
        showNotice("Spawning a Grand Brigade to find " .. tostring(Settings.IslandFinderTarget), espColor(Settings.SeaColor), 4)
    end
    FarmRuntime.RefreshIslandFinderButton()
end

FarmRuntime.ToggleIslandSearch = function()
    if Settings.IslandFinderAutoFind then
        FarmRuntime.StopIslandSearch(true, true)
    else
        FarmRuntime.StartIslandSearch(true)
    end
end

FarmRuntime.TravelSpecialIsland = function()
    if state.TravelTarget and state.TravelButtonKey == "specialIsland" then
        stopTravel("Travel stopped")
        return
    end
    local island, position = FarmRuntime.LocateSpecialIsland(false)
    if not island or not position then
        FarmRuntime.StartIslandSearch()
        return
    end
    state.IslandFinderTravelActive = true
    if not beginTravel(position + Vector3.new(0, 5, 0), Settings.IslandFinderTarget, "farmIsland", island, false, "specialIsland") then
        state.IslandFinderTravelActive = false
    end
end

FarmRuntime.UpdateIslandFinder = function(root)
    if not root then return false end
    if state.IslandFinderTravelActive then
        if state.TravelTarget and state.TravelButtonKey == "specialIsland" then return true end
        if os.clock() < state.IslandFinderTravelPendingUntil then return true end
        state.IslandFinderTravelActive = false
    end
    local autoFinding = Settings.IslandFinderAutoFind
    if not Settings.IslandFinderAlerts and not autoFinding then return false end
    if os.clock() < state.IslandFinderNextScanAt then
        return autoFinding and FarmRuntime.SeaBeastSail(root, "Island") == true or false
    end
    state.IslandFinderNextScanAt = os.clock() + 1.25
    local name = Settings.IslandFinderTarget
    if state.IslandFinderFoundName ~= name then
        state.IslandFinderFound = nil
        state.IslandFinderFoundName = name
    end
    local island, position = FarmRuntime.FindSpecialIsland(name)
    if island then
        if island ~= state.IslandFinderFound then
            state.IslandFinderFound = island
            showNotice(name .. " found - " .. tostring(math.floor((position - root.Position).Magnitude + 0.5)) .. " studs", Green, 7)
        end
        if autoFinding then
            Settings.IslandFinderAutoFind = false
            state.IslandFinderTravelActive = true
            state.IslandFinderTravelPendingUntil = os.clock() + 2
            FarmRuntime.StopSeaBeastSail(true)
            if state.TravelOwner == "seaBeast" then stopTravel() end
            if state.IslandFinderAutoControl and state.IslandFinderAutoControl.Set then
                task.defer(function()
                    pcall(function() state.IslandFinderAutoControl:Set(false) end)
                end)
            end
            FarmRuntime.RefreshIslandFinderButton()
            task.spawn(function()
                task.wait(0.15)
                if not state.Alive or not island.Parent then
                    state.IslandFinderTravelActive = false
                    return
                end
                local _, humanoid, liveRoot = getCharacter(LocalPlayer)
                if not liveRoot then
                    state.IslandFinderTravelActive = false
                    return
                end
                if humanoid then
                    humanoid.Sit = false
                    humanoid.Jump = true
                    pcall(function() humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end)
                end
                task.wait(0.1)
                local livePosition = FarmRuntime.SpecialIslandPosition(island)
                if livePosition then
                    if not beginTravel(livePosition + Vector3.new(0, 5, 0), name, "farmIsland", island, false, "specialIsland") then
                        state.IslandFinderTravelActive = false
                    end
                else
                    state.IslandFinderTravelActive = false
                end
            end)
            return true
        end
    elseif not island and state.IslandFinderFound then
        state.IslandFinderFound = nil
        showNotice(name .. " is no longer available", Red, 5)
    end
    if autoFinding then return FarmRuntime.SeaBeastSail(root, "Island") == true end
    return false
end

FarmRuntime.V4Runtime = (function()
local function v4StageMessage(stage)
    local messages = {
        [0] = "Defeat rip_indra before starting Race V4",
        [1] = "Speak to the Sealed King and begin the Great Tree step",
        [2] = "Go to the top of the Great Tree and enter the Temple of Time",
        [3] = "Return to the Sealed King and continue the quest",
        [4] = "Find Mirage Island during a full moon and obtain the Blue Gear",
        [5] = "Temple access unlocked - complete your race trial during a full moon"
    }
    return messages[tonumber(stage)] or ("Race V4 stage: " .. tostring(stage or "Unknown"))
end

local function mirageKey(value)
    return string.lower(tostring(value or "")):gsub("[^%w]", "")
end

local function isMirageName(value)
    local key = mirageKey(value)
    return key == "mirageisland" or key == "mysticisland"
end

local function findMirageIsland()
    local map = workspace:FindFirstChild("Map")
    local origin = workspace:FindFirstChild("_WorldOrigin")
    local locations = origin and origin:FindFirstChild("Locations")
    local seaEvents = workspace:FindFirstChild("SeaEvents")
    local mapIsland, marker, eventIsland
    local function scan(root, kind)
        if not root then return end
        for _, instance in ipairs(root:GetChildren()) do
            if isMirageName(instance.Name) then
                if kind == "map" then mapIsland = instance
                elseif kind == "location" then marker = instance
                else eventIsland = instance end
            end
        end
    end
    scan(map, "map")
    scan(locations, "location")
    scan(seaEvents, "event")
    return mapIsland or eventIsland or marker, marker
end

local function highestSurface(instance)
    if not instance then return nil, nil end
    local best, bestTop
    local function consider(part, strict)
        if not part:IsA("BasePart") then return end
        if strict and (not part.CanCollide or part.Transparency >= 0.98) then return end
        local top = part.Position.Y + part.Size.Y * 0.5
        if not bestTop or top > bestTop then
            best, bestTop = part, top
        end
    end
    if instance:IsA("BasePart") then consider(instance, true) end
    for _, part in ipairs(instance:GetDescendants()) do consider(part, true) end
    if not best then
        if instance:IsA("BasePart") then consider(instance, false) end
        for _, part in ipairs(instance:GetDescendants()) do consider(part, false) end
    end
    if best then return best, Vector3.new(best.Position.X, bestTop + 3, best.Position.Z) end
    if instance:IsA("Model") then
        local ok, pivot = pcall(instance.GetPivot, instance)
        if ok then return nil, pivot.Position + Vector3.new(0, 60, 0) end
    end
    return nil, nil
end

local function findMirageDealer(island)
    local npcs = workspace:FindFirstChild("NPCs")
    local dealer = npcs and npcs:FindFirstChild("Advanced Fruit Dealer")
    local dealerPart = getPart(dealer)
    if not dealerPart or not dealerPart:IsDescendantOf(workspace) then return nil end
    if island then
        local islandPart = getPart(island)
        if islandPart and (dealerPart.Position - islandPart.Position).Magnitude > 6000 then return nil end
    end
    return dealer
end

local function findBlueGear(island)
    if not island then return nil end
    local best
    local function consider(instance)
        local key = mirageKey(instance.Name)
        if key ~= "bluegear" and key ~= "gear" and not string.find(key, "bluegear", 1, true) then return end
        local part = getPart(instance)
        if not part or not part:IsDescendantOf(workspace) then return end
        local visible = part.Transparency < 0.98 or part:FindFirstChildWhichIsA("TouchTransmitter", true) ~= nil
        if visible and (key == "bluegear" or not best) then best = instance end
    end
    consider(island)
    for _, instance in ipairs(island:GetDescendants()) do consider(instance) end
    return best
end

local function greatTreeTarget()
    local map = workspace:FindFirstChild("Map")
    local tree = map and map:FindFirstChild("Great Tree")
    local _, highest = highestSurface(tree)
    if highest then return highest, tree end
    local origin = workspace:FindFirstChild("_WorldOrigin")
    local locations = origin and origin:FindFirstChild("Locations")
    if locations then
        for _, marker in ipairs(locations:GetChildren()) do
            if string.lower(marker.Name) == "great tree" and marker:IsA("BasePart") then
                return marker.Position + Vector3.new(0, 8, 0), marker
            end
        end
    end
    return nil, nil
end

local function faceMoonCamera()
    local camera = workspace.CurrentCamera
    if not camera then return false end
    local direction = Lighting:GetMoonDirection()
    if direction.Magnitude <= 0 then return false end
    camera.CFrame = CFrame.lookAt(camera.CFrame.Position, camera.CFrame.Position + direction * 1000)
    return true
end

local function pressV4Key(key)
    task.spawn(function()
        pcall(function() farmVirtualInput:SendKeyEvent(true, key, false, game) end)
        task.wait(0.08)
        pcall(function() farmVirtualInput:SendKeyEvent(false, key, false, game) end)
    end)
end

local function moonReady()
    local clock = Lighting.ClockTime
    return Lighting:GetAttribute("MoonPhase") == 5 and (clock >= 18 or clock < 5)
end

FarmRuntime.CheckRaceV4 = function()
    if game.PlaceId ~= SEA_PLACE_IDS.Third then
        contextNotice("RaceV4Sea", "Race V4 is only available in the Third Sea", Red, 5, 3)
        return
    end
    task.spawn(function()
        local ok, progress = pcall(function() return CommF:InvokeServer("RaceV4Progress", "Check") end)
        if ok then showNotice(v4StageMessage(progress), nil, 7)
        else showNotice("Could not check Race V4 progress", Red, 5) end
    end)
end

FarmRuntime.RaceV4Action = function(action, label)
    if game.PlaceId ~= SEA_PLACE_IDS.Third then
        contextNotice("RaceV4Sea", "Race V4 is only available in the Third Sea", Red, 5, 3)
        return
    end
    task.spawn(function()
        local ok, result = pcall(function() return CommF:InvokeServer("RaceV4Progress", action) end)
        if ok then
            local message = type(result) == "string" and result or (label or ("Race V4: " .. tostring(action)))
            showNotice(tostring(message):gsub("<[^>]+>", ""):gsub("%s+", " "), Green, 5)
        else
            showNotice("Race V4 action failed: " .. tostring(label or action), Red, 5)
        end
    end)
end

FarmRuntime.LocateMirage = function(notify)
    local island, marker = findMirageIsland()
    state.MirageFound = island
    state.MirageMarker = marker
    if notify then
        if island then
            local _, _, root = getCharacter(LocalPlayer)
            local part = getPart(island) or getPart(marker)
            local distance = root and part and math.floor((root.Position - part.Position).Magnitude + 0.5) or nil
            showNotice("Mirage Island found" .. (distance and (" - " .. distance .. " studs away") or ""), Green, 6)
        else
            showNotice("Mirage Island is not active in this server", Red, 5)
        end
    end
    return island, marker
end

FarmRuntime.LocateMirageDealer = function(notify)
    local island = FarmRuntime.LocateMirage(false)
    local dealer = findMirageDealer(island)
    state.MirageDealer = dealer
    if notify then
        local _, _, root = getCharacter(LocalPlayer)
        local part = getPart(dealer)
        if part then
            local distance = root and math.floor((root.Position - part.Position).Magnitude + 0.5) or nil
            showNotice("Advanced Fruit Dealer found" .. (distance and (" - " .. distance .. " studs away") or ""), Green, 6)
        else
            showNotice("Advanced Fruit Dealer is not currently available", Red, 5)
        end
    end
    return dealer
end

FarmRuntime.LocateBlueGear = function(notify)
    local island = FarmRuntime.LocateMirage(false)
    local gear = findBlueGear(island)
    state.MirageGear = gear
    if notify then
        local _, _, root = getCharacter(LocalPlayer)
        local part = getPart(gear)
        if part then
            local distance = root and math.floor((root.Position - part.Position).Magnitude + 0.5) or nil
            showNotice("Blue Gear found" .. (distance and (" - " .. distance .. " studs away") or ""), Blue, 6)
        else
            showNotice("Blue Gear is not currently visible", Red, 5)
        end
    end
    return gear
end

FarmRuntime.TravelGreatTree = function()
    local position, tree = greatTreeTarget()
    if not position then showNotice("Great Tree is unavailable", Red, 4); return end
    beginTravel(position, "Great Tree top", "farmV4", tree)
end

FarmRuntime.TravelMirage = function(highest)
    local island, marker = FarmRuntime.LocateMirage(false)
    if not island then showNotice("Mirage Island is not active", Red, 4); return end
    local position
    if highest then
        local _, highestPosition = highestSurface(island)
        position = highestPosition
    end
    if not position then
        local part = getPart(island) or getPart(marker)
        position = part and part.Position + Vector3.new(0, 8, 0) or nil
    end
    if not position then showNotice("Could not resolve the Mirage Island position", Red, 4); return end
    beginTravel(position, highest and "Mirage highest point" or "Mirage Island", "farmMirage", island)
end

FarmRuntime.TravelMirageDealer = function()
    local dealer = FarmRuntime.LocateMirageDealer(false)
    local part = getPart(dealer)
    if not part then showNotice("Advanced Fruit Dealer is not currently available", Red, 5); return end
    beginTravel(part.Position + Vector3.new(0, 3, 0), "Advanced Fruit Dealer", "farmMirageDealer", dealer)
end

FarmRuntime.FaceMoon = function(activate)
    if not faceMoonCamera() then showNotice("The moon direction is unavailable", Red, 4); return end
    if activate then
        if not moonReady() then
            showNotice("A full moon at night is required to resonate", Red, 5)
            return
        end
        pressV4Key(Enum.KeyCode.T)
        showNotice("Race ability activated toward the moon", nil, 4)
    else
        showNotice("Camera aligned with the moon", nil, 3)
    end
end

FarmRuntime.MoonStatus = function()
    local phase = Lighting:GetAttribute("MoonPhase")
    local clock = Lighting.ClockTime
    local dayState = (clock >= 18 or clock < 5) and "Night" or "Day"
    showNotice((phase == 5 and "Full Moon" or ("Moon phase " .. tostring(phase or "Unknown"))) .. " | " .. dayState, phase == 5 and Green or Muted, 5)
end

FarmRuntime.CollectBlueGear = function()
    local gear = FarmRuntime.LocateBlueGear(false)
    local part = getPart(gear)
    if not part then showNotice("Blue Gear is not currently visible", Red, 5); return end
    state.MirageGear = gear
    beginTravel(part.Position + Vector3.new(0, 2, 0), "Blue Gear", "farmMirageGear", gear)
end

FarmRuntime.UpdateMirage = function(root)
    if not Settings.AutoMirage and not Settings.MirageDealerESP and not Settings.MirageGearESP
    then
        if state.TravelMode == "farmMirage" or state.TravelMode == "farmMirageGear" or state.TravelMode == "farmMirageDealer" then stopTravel() end
        hideGroup(state.WorldDrawings[state.MirageDealer])
        hideGroup(state.WorldDrawings[state.MirageGear])
        state.MirageFound = nil
        state.MirageMarker = nil
        state.MirageDealer = nil
        state.MirageGear = nil
        return false
    end
    if game.PlaceId ~= SEA_PLACE_IDS.Third then return false end
    local now = os.clock()
    if now >= state.MirageNextScanAt then
        state.MirageNextScanAt = now + 0.5
        local previousDealer = state.MirageDealer
        local previousGear = state.MirageGear
        local island, marker = findMirageIsland()
        state.MirageFound = island
        state.MirageMarker = marker
        state.MirageDealer = findMirageDealer(island)
        state.MirageGear = findBlueGear(island)
        if previousDealer and previousDealer ~= state.MirageDealer then hideGroup(state.WorldDrawings[previousDealer]) end
        if previousGear and previousGear ~= state.MirageGear then hideGroup(state.WorldDrawings[previousGear]) end
    end

    local island = state.MirageFound
    if not island or not island.Parent then
        if state.TravelMode == "farmMirage" or state.TravelMode == "farmMirageGear" or state.TravelMode == "farmMirageDealer" then stopTravel() end
        if Settings.AutoMirage then
            contextNotice("Waiting:Mirage", "Waiting for Mirage Island", Muted, 4, 10)
            if Settings.MirageAutoHop and now >= state.MirageNextHopAt then
                state.MirageNextHopAt = now + math.max(15, Settings.MirageHopDelay)
                showNotice("Searching another server for Mirage Island", nil, 4)
                serverHop(true)
            end
            return FarmRuntime.SeaBeastSail(root, "Mirage") == true
        end
        return false
    end
    if state.SeaBeastDriving then FarmRuntime.StopSeaBeastSail(true) end
    if state.TravelOwner == "seaBeast" then stopTravel() end
    if not Settings.AutoMirage then return false end

    local gear = state.MirageGear
    local gearPart = getPart(gear)
    if Settings.MirageAutoGear and gearPart and gearPart:IsDescendantOf(workspace) then
        local target = gearPart.Position + Vector3.new(0, 2, 0)
        if (root.Position - target).Magnitude > 3 then
            if state.TravelMode ~= "farmMirageGear" or state.TravelObject ~= gear
                or not state.TravelTarget or (state.TravelTarget - target).Magnitude > 1 then
                beginTravel(target, "Blue Gear", "farmMirageGear", gear, true)
            end
        else
            if state.TravelMode == "farmMirageGear" then stopTravel() end
            touchTravelObject(root, gear)
        end
        return true
    end

    local _, highest = highestSurface(island)
    if Settings.MirageAutoTravel and highest then
        if (root.Position - highest).Magnitude > 4 then
            if state.TravelMode ~= "farmMirage" or state.TravelObject ~= island
                or not state.TravelTarget or (state.TravelTarget - highest).Magnitude > 1 then
                beginTravel(highest, "Mirage highest point", "farmMirage", island, true)
            end
            return true
        end
        if state.TravelMode == "farmMirage" then stopTravel() end
        root.AssemblyLinearVelocity = Vector3.zero
    end

    if Settings.MirageAutoMoon then
        if highest and (root.Position - highest).Magnitude > 8 then
            contextNotice("MirageMoonPosition", "Reach the highest point before moon resonance", Muted, 4, 8)
        elseif moonReady() then
            faceMoonCamera()
            if now >= state.MirageNextAbilityAt then
                state.MirageNextAbilityAt = now + 3
                pressV4Key(Enum.KeyCode.T)
                contextNotice("MirageMoonResonance", "Attempting moon resonance", Green, 3, 4)
            end
        else
            contextNotice("MirageFullMoon", "Mirage found - waiting for a full moon at night", Muted, 5, 10)
        end
    end
    return true
end

FarmRuntime.UpdateRaceV4 = function()
    if not Settings.AutoRaceV4 or game.PlaceId ~= SEA_PLACE_IDS.Third
        or state.RaceV4Busy or os.clock() < state.RaceV4NextAt then return end
    state.RaceV4Busy = true
    state.RaceV4NextAt = os.clock() + 3
    task.spawn(function()
        local ok, progress = pcall(function() return CommF:InvokeServer("RaceV4Progress", "Check") end)
        local stage = tonumber(progress)
        if ok and stage == 1 and Settings.AutoRaceV4 then
            pcall(function() CommF:InvokeServer("RaceV4Progress", "Begin") end)
            contextNotice("RaceV4Progress", v4StageMessage(2), Muted, 5, 8)
        elseif ok and stage == 3 and Settings.AutoRaceV4 then
            pcall(function() CommF:InvokeServer("RaceV4Progress", "Continue") end)
            contextNotice("RaceV4Progress", v4StageMessage(4), Muted, 5, 8)
        elseif ok and stage == 0 then
            contextNotice("RaceV4Progress", v4StageMessage(0), Red, 5, 8)
        elseif ok and stage == 2 then
            contextNotice("RaceV4Progress", v4StageMessage(2), Muted, 5, 8)
        elseif ok and stage == 4 then
            contextNotice("RaceV4Progress", v4StageMessage(4), Muted, 5, 8)
        elseif ok and stage and stage >= 5 then
            contextNotice("RaceV4Progress", v4StageMessage(5), Muted, 5, 8)
        elseif not ok then
            contextNotice("RaceV4Remote", "Could not check Race V4 progress; retrying", Red, 4, 8)
        end
        state.RaceV4Busy = false
    end)
end

FarmRuntime.ActivateRaceV4 = function()
    local character = LocalPlayer.Character
    local energy = character and character:FindFirstChild("RaceEnergy")
    if not energy then
        showNotice("Race V4 is not unlocked", Red, 4)
    elseif energy.Value < 1 then
        showNotice("Race energy is not full", Red, 4)
    else
        pressV4Key(Enum.KeyCode.Y)
        showNotice("Race V4 activation requested", nil, 3)
    end
end

return true
end)()

local function inputMatches(input, binding)
    return typeof(binding) == "EnumItem" and (input.KeyCode == binding or input.UserInputType == binding)
end

local FlightControl
local NoclipControl

connect(UserInputService.InputBegan, function(input, processed)
    if processed then return end
    if inputMatches(input, Settings.FlightKey) then
        if FlightControl and FlightControl.Set then FlightControl:Set(not Settings.Flight) else Settings.Flight = not Settings.Flight end
    end
    if inputMatches(input, Settings.NoclipKey) then
        if NoclipControl and NoclipControl.Set then
            NoclipControl:Set(not Settings.Noclip)
        else
            Settings.Noclip = not Settings.Noclip
            if not Settings.Noclip and not state.TravelTarget then restoreCollision() end
        end
    end
end)

connect(UserInputService.JumpRequest, function()
    if not Settings.InfiniteJump then return end
    local _, humanoid = getCharacter(LocalPlayer)
    if humanoid then humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
end)

connect(LocalPlayer.Idled, function()
    if not Settings.AntiAFK then return end
    pcall(function()
        game:GetService("VirtualUser"):CaptureController()
        game:GetService("VirtualUser"):ClickButton2(Vector2.new())
    end)
end)

local backpack = LocalPlayer:WaitForChild("Backpack")
rememberOwnedTools(backpack)
rememberOwnedTools(LocalPlayer.Character)
connect(backpack.ChildAdded, function(instance)
    recordDrop(instance)
    queueFruitStore(instance)
    farmInventoryChanged(instance)
end)
connect(backpack.ChildRemoved, farmInventoryChanged)
bindFarmCharacter(LocalPlayer.Character)
state.DropReady = true
for _, container in ipairs({ backpack, LocalPlayer.Character }) do
    if container then
        for _, instance in ipairs(container:GetChildren()) do queueFruitStore(instance) end
    end
end

connect(Players.PlayerRemoving, removePlayer)

connect(workspace.ChildAdded, function(instance)
    task.defer(function()
        if not state.Alive or not instance.Parent then return end
        if physicalFruit(instance) then
            state.Fruits[instance] = true
            if Settings.AutoFruit and autoFruitAllowed(instance) and state.TravelOwner == "chest" then stopTravel() end
            if Settings.FruitAlerts then
                showNotice(formatFruitName(instance) .. " Fruit spawned", espColor(Settings.FruitColor), 7)
            end
        end
    end)
end)

connect(workspace.DescendantAdded, function(instance)
    if instance:IsA("BasePart") and string.find(string.lower(instance.Name), "chest", 1, true) then cacheChest(instance) end
    if instance:IsA("TouchTransmitter") and instance.Parent then cacheChest(instance.Parent) end
    if instance:IsA("BasePart") then
        local origin = workspace:FindFirstChild("_WorldOrigin")
        local spawnFolder = origin and origin:FindFirstChild("EnemySpawns")
        if spawnFolder and instance:IsDescendantOf(spawnFolder) then
            local name = normalizeEnemyName(instance:GetAttribute("DisplayName") or instance.Name)
            if name ~= "" then
                state.EnemySpawns[name] = state.EnemySpawns[name] or {}
                state.EnemySpawns[name][#state.EnemySpawns[name] + 1] = instance
            end
        end
    end
    if Settings.LowQuality then task.defer(disableEffect, instance) end
end)

connect(ReplicatedStorage.DescendantAdded, function(instance)
    if instance:IsA("BasePart") and string.find(string.lower(instance.Name), "chest", 1, true) then cacheChest(instance) end
    if instance:IsA("TouchTransmitter") and instance.Parent then cacheChest(instance.Parent) end
end)

connect(CollectionService:GetInstanceAddedSignal("WorldChest"), cacheChest)

local enemiesFolder = workspace:FindFirstChild("Enemies")
if enemiesFolder then
    connect(enemiesFolder.ChildAdded, function(instance)
        task.defer(function()
            if state.Alive and instance.Parent and isBoss(instance) and Settings.BossESP then showNotice(instance.Name .. " spawned", espColor(Settings.BossColor), 6) end
        end)
    end)
    connect(enemiesFolder.ChildRemoved, removeWorld)
end

for _, folderName in ipairs({ "SeaBeasts", "SeaEvents" }) do
    local folder = workspace:FindFirstChild(folderName)
    if folder then
        connect(folder.ChildAdded, function(instance)
            if Settings.SeaAlerts then showNotice(instance.Name .. " appeared", espColor(Settings.SeaColor), 6) end
        end)
        connect(folder.ChildRemoved, removeWorld)
    end
end

connect(LocalPlayer.CharacterAdded, function(character)
    state.AimTarget = nil
    if FarmRuntime.StopFishing then FarmRuntime.StopFishing(true) end
    stopTravel()
    restoreCollision()
    FarmRuntime.Invalidate("", 1)
    FarmRuntime.InvalidateSea2(1)
    bindFarmCharacter(character)
    task.delay(1, function()
        if state.Alive then
            setCameraShake(Settings.NoCameraShake)
            rememberOwnedTools(character)
        end
    end)
end)

connect(RunService.Stepped, function()
    if not state.Alive then return end
    local character = LocalPlayer.Character
    setCharacterCollision(character, Settings.Noclip or Settings.IslandFinderAutoFind or state.TravelTarget ~= nil or state.BartiloPuzzleNoclip or state.SaberPuzzleNoclip)
end)

connect(RunService.Heartbeat, function(deltaTime)
    if not state.Alive then return end
    local heartbeatNow = os.clock()
    if heartbeatNow >= state.AutoRejoinCheckAt then
        state.AutoRejoinCheckAt = heartbeatNow + 1
        if Settings.AutoRejoin30 then
            if state.AutoRejoinAt <= 0 then
                state.AutoRejoinAt = heartbeatNow + 1800
            elseif heartbeatNow >= state.AutoRejoinAt and not state.AutoRejoinBusy then
                showNotice("Rejoining server", nil, 3)
                if rejoin(true) then return end
            end
        else
            state.AutoRejoinAt = 0
        end
    end
    for enemyRoot, entry in pairs(state.FarmFruitM1Targets) do
        local stabilizeUntil = type(entry) == "table" and entry.Until or entry
        if heartbeatNow >= (tonumber(stabilizeUntil) or 0) or not enemyRoot.Parent or enemyRoot.Anchored then
            state.FarmFruitM1Targets[enemyRoot] = nil
        else
            pcall(function()
                enemyRoot.AssemblyLinearVelocity = Vector3.zero
                enemyRoot.AssemblyAngularVelocity = Vector3.zero
                local holdPosition = Settings.FarmAutoGroup and state.FarmGroupDestination
                    or (type(entry) == "table" and entry.Position)
                local rotation = type(entry) == "table" and entry.Rotation or (enemyRoot.CFrame - enemyRoot.Position)
                if holdPosition then
                    enemyRoot.CFrame = CFrame.new(holdPosition) * rotation
                end
            end)
        end
    end
    local camera = workspace.CurrentCamera
    local character, _, root = getCharacter(LocalPlayer)
    FarmRuntime.UpdateStats()
    FarmRuntime.UpdateAutoBait(false)
    FarmRuntime.UpdateRaceV3Ability()
    FarmRuntime.RefreshCakePrinceCounter(false)
    FarmRuntime.RefreshDoughKingStatus(false)
    FarmRuntime.UpdateCakeLandAutoSpawn(root)
    local fightingStyleBusy = FarmRuntime.FightingStyles.Update(root)
    FarmRuntime.UpdateEventFinder()
    if root then
        local islandFinderBusy = FarmRuntime.UpdateIslandFinder(root) == true
        local seaBeastBusy = false
        local specialPauseFarm = false
        local mirageBusy = FarmRuntime.UpdateMirage(root) == true
        local sea2ProgressionBusy = Settings.AutoSea2 and game.PlaceId == SEA_PLACE_IDS.First and playerLevel() >= 700
        if islandFinderBusy then
            if state.FruitOverrideActive then clearFruitOverride(false) end
        elseif fightingStyleBusy then
            if state.FruitOverrideActive then clearFruitOverride(false) end
            if state.SeaBeastActive or state.TravelOwner == "seaBeast" then FarmRuntime.ClearSeaBeast() end
        elseif mirageBusy then
            if state.FruitOverrideActive then clearFruitOverride(false) end
        elseif sea2ProgressionBusy then
            if state.FruitOverrideActive then clearFruitOverride(false) end
            if state.SeaBeastActive then FarmRuntime.ClearSeaBeast() end
            FarmRuntime.UpdateSea2(root)
        else
            FarmRuntime.UpdateSecondSea(root)
            specialPauseFarm = (state.SpecialOwner == "AutoTyrant"
                    and state.SpecialData.TyrantPhase == "Pots")
                or state.SpecialData.BlockNormalFarm == true
            local activityBusy = state.SpecialFarm ~= nil
                or (state.SpecialOwner ~= nil and state.TravelOwner == state.SpecialOwner)
            if activityBusy or specialPauseFarm then
                if state.FruitOverrideActive then clearFruitOverride(false) end
                if state.SeaBeastActive or state.TravelOwner == "seaBeast" then FarmRuntime.ClearSeaBeast() end
                if state.SpecialFarm or not specialPauseFarm then
                    FarmRuntime.Update(root)
                end
            else
                seaBeastBusy = FarmRuntime.UpdateSeaBeast(root)
                if seaBeastBusy then
                    if state.FruitOverrideActive then clearFruitOverride(false) end
                else
                    updateFruitOverride(root)
                    if not state.FruitOverrideActive then
                        FarmRuntime.Update(root)
                    end
                end
            end
        end
        local specialGroupActive = Settings.FarmAutoGroup and state.SpecialFarm
            and (state.SpecialFarm.GroupAll or type(state.SpecialFarm.GroupNames) == "table")
        if not islandFinderBusy and not fightingStyleBusy and not seaBeastBusy and not mirageBusy
            and not sea2ProgressionBusy and not state.FruitOverrideActive
            and (not specialPauseFarm or specialGroupActive)
        then
            FarmRuntime.UpdateFarmGroup(root)
        elseif state.FarmGroupDestination then
            FarmRuntime.ClearFarmGroup()
        end
        local specialBusy = state.SpecialFarm ~= nil
            or (state.SpecialOwner ~= nil and state.TravelOwner == state.SpecialOwner)
            or fightingStyleBusy
            or islandFinderBusy
            or mirageBusy
            or specialPauseFarm
        if state.TravelTarget and (state.TravelMode == "fruit" or state.TravelMode == "chest" or state.TravelMode == "cyborgChest" or state.TravelMode == "farmEnemy" or state.TravelMode == "farmBoss" or state.TravelMode == "farmMirageGear") and not autoTravelObjectValid() then
            stopTravel()
        end
        if state.TravelTarget then
            local offset = state.TravelTarget - root.Position
            local distance = offset.Magnitude
            if distance <= 1 then
                local mode, object, name = state.TravelMode, state.TravelObject, state.TravelName
                root.CFrame = CFrame.new(state.TravelTarget) * (root.CFrame - root.Position)
                if mode == "chest" or mode == "cyborgChest" or mode == "doughChest" then
                    state.ChestAttempts[object] = os.clock()
                    local positionKey = FarmRuntime.ChestPositionKey(object)
                    if positionKey then state.ChestPositionAttempts[positionKey] = os.clock() end
                    touchTravelObject(root, FarmRuntime.ResolveLiveChest(object) or object)
                elseif mode == "chestIsland" or mode == "doughChestIsland" then
                    state.ChestIslandAttempts[tostring(object)] = os.clock()
                    state.ChestIslandSearchReadyAt = os.clock() + 1.5
                elseif mode == "fruit" then
                    state.FruitAttempts[object] = os.clock()
                    touchTravelObject(root, object)
                elseif mode == "farmMirageGear" then
                    touchTravelObject(root, object)
                end
                if mode == "farmEnemy" or mode == "farmBoss" or mode == "farmRaidHold" or mode == "farmRaidRetreat" or mode == "farmCakeRetreat" or mode == "seaBeast" then
                    root.AssemblyLinearVelocity = Vector3.zero
                elseif mode == "manualHome" then
                    stopTravel()
                    task.spawn(function()
                        local ok, result = pcall(function() return CommF:InvokeServer("SetSpawnPoint") end)
                        if not state.Alive then return end
                        if not ok or result == -1 then
                            showNotice("Home point could not be set here", Red, 4)
                        elseif result == 0 then
                            showNotice("Only Pirates can set a home point", Red, 4)
                        else
                            showNotice("Home point set - teleporting home", nil, 3)
                            task.wait(0.25)
                            pcall(function() CommF:InvokeServer("TeleportToSpawn", true) end)
                        end
                    end)
                else
                    stopTravel(mode == "manual" and ("Arrived at " .. tostring(name or "target")) or nil)
                end
                if mode == "fruit" then
                    local reachedFruit = object and formatFruitName(object) or "Physical"
                    if not state.FruitOverrideActive or state.FruitOverrideReachedAt == 0 then
                        showNotice("Reached " .. reachedFruit .. " Fruit", espColor(Settings.FruitColor), 3)
                    end
                    if state.FruitOverrideActive then state.FruitOverrideReachedAt = os.clock() end
                end
            else
                root.AssemblyLinearVelocity = Vector3.zero
                local waypoint = FarmRuntime.SafeTravelWaypoint(root, state.TravelTarget, state.TravelMode)
                local moveOffset = waypoint - root.Position
                local moveDistance = moveOffset.Magnitude
                local speed = (state.TravelMode == "chest" or state.TravelMode == "cyborgChest" or state.TravelMode == "chestIsland") and Settings.AutoChestSpeed
                    or state.TravelMode == "fruit" and Settings.AutoFruitSpeed
                    or state.TravelMode == "seaBeast" and (Settings.IslandFinderAutoFind and Settings.IslandFinderSpeed or Settings.SeaBeastTravelSpeed)
                    or state.TravelMode == "farmIsland" and Settings.IslandFinderSpeed
                    or FarmRuntime.IsTravelMode(state.TravelMode) and Settings.FarmTravelSpeed
                    or Settings.TravelSpeed
                if moveDistance > 0.01 then
                    if state.TravelMode == "farmIsland"
                        or FarmRuntime.AutomationMovementReady(state.TravelOwner or state.TravelMode, deltaTime)
                    then
                        moveInOneStudSteps(root, moveOffset.Unit, speed, deltaTime, "TravelBudget", moveDistance)
                    else
                        root.AssemblyLinearVelocity = Vector3.zero
                        root.AssemblyAngularVelocity = Vector3.zero
                    end
                end
            end
        elseif Settings.Flight and camera and not sea2ProgressionBusy and not specialBusy then
            root.AssemblyLinearVelocity = Vector3.zero
            local direction = flightDirection(camera)
            if direction.Magnitude > 0 then
                moveInOneStudSteps(root, direction, Settings.FlightSpeed, deltaTime, "FlightBudget")
            else
                state.FlightBudget = 0
            end
        else
            state.FlightBudget = 0
        end
        updateWaterWalk(character, root)
        if not state.TravelTarget and not state.FruitOverrideActive and not sea2ProgressionBusy and not specialBusy and not seaBeastBusy then
            updateAutoCollection(root)
        end
    elseif state.TravelTarget then
        stopTravel()
    end
    if FarmEnabledControl and FarmEnabledControl.Get and FarmEnabledControl.Set and os.clock() >= state.FarmToggleSyncAt then
        state.FarmToggleSyncAt = os.clock() + 0.25
        local visualEnabled
        local readOk = pcall(function() visualEnabled = FarmEnabledControl:Get() end)
        if readOk then
            if visualEnabled ~= Settings.AutoFarm then
                pcall(function() FarmEnabledControl:Set(Settings.AutoFarm) end)
            end
            if FarmEnabledControl.Refresh then
                pcall(function() FarmEnabledControl:Refresh() end)
            end
        end
    end
    if os.clock() >= state.SpecialToggleSyncAt then
        state.SpecialToggleSyncAt = os.clock() + 0.25
        for setting, control in pairs(SecondSeaControls) do
            if control and control.Get and control.Set and Settings[setting] ~= nil then
                local visualEnabled
                local readOk = pcall(function() visualEnabled = control:Get() end)
                if readOk and visualEnabled ~= Settings[setting] then
                    pcall(function() control:Set(Settings[setting]) end)
                end
                if control.Refresh then pcall(function() control:Refresh() end) end
            end
        end
    end
    applyAura()
    if os.clock() - state.LastHitboxScan >= 0.2 then
        state.LastHitboxScan = os.clock()
        updateHitboxes(root)
    end
    if os.clock() - state.LastChestScan >= 0.75 then
        state.LastChestScan = os.clock()
        local previous = state.NearestChestInstance
        state.NearestChestInstance = Settings.NearestChest and findNearestChest(root) or nil
        if previous and previous ~= state.NearestChestInstance then hideGroup(state.WorldDrawings[previous]) end
    end
end)

connect(RunService.RenderStepped, function(deltaTime)
    if not state.Alive then return end
    local camera = workspace.CurrentCamera
    if not camera then return end
    local _, _, root = getCharacter(LocalPlayer)
    updatePlayerESP(camera, root)
    updateWorldESP(camera, root)
    updateAimbot(camera, root, deltaTime)
    updateOverlays(camera)
    updateNotificationAccents()
end)

refreshFruits()
refreshStock(false)
setCameraShake(false)
captureLighting()

task.spawn(function()
    while state.Alive do
        refreshFruits()
        if Settings.Fullbright or Settings.NoFog or Settings.LowQuality then applyLighting() end
        task.wait(1)
    end
end)

task.spawn(function()
    while state.Alive do
        task.wait(60)
        if state.Alive then refreshStock(true) end
    end
end)

task.spawn(function()
    while state.Alive do
        if game.PlaceId == SEA_PLACE_IDS.Second and Settings.DealerTracker and os.clock() - state.DealerLastCheck >= 15 then
            FarmRuntime.CheckDealer(false)
        end
        task.wait(1)
    end
end)

local function releaseVirtualInputs()
    local request = state.FarmClickRequest
    local point = request and request.Point or Vector2.new(1, 1)
    pcall(function()
        farmVirtualInput:SendMouseButtonEvent(point.X, point.Y, 0, false, game, 0)
    end)
    for _, key in ipairs({
        Enum.KeyCode.W,
        Enum.KeyCode.Z,
        Enum.KeyCode.X,
        Enum.KeyCode.C,
        Enum.KeyCode.V,
        Enum.KeyCode.F,
        Enum.KeyCode.T
    }) do
        pcall(function() farmVirtualInput:SendKeyEvent(false, key, false, game) end)
    end
    state.FarmClickRequest = nil
    state.FarmSkillBusy = false
    state.SeaBeastKeyBusy = false
end

local function cleanup()
    if state.Cleaned then return end
    state.Cleaned = true
    if FarmRuntime.StopFishing then FarmRuntime.StopFishing(true) end
    state.Alive = false

    for _, connection in ipairs(state.Connections) do
        pcall(function() connection:Disconnect() end)
    end
    state.Connections = {}

    if FarmRuntime.FightingStyles and FarmRuntime.FightingStyles.Clear then FarmRuntime.FightingStyles.Clear() end
    if FarmRuntime.ClearSeaBeast then FarmRuntime.ClearSeaBeast() end
    if FarmRuntime.ClearFarmGroup then FarmRuntime.ClearFarmGroup() end

    for key, value in pairs(Settings) do
        if type(value) == "boolean" then Settings[key] = false end
    end
    state.BartiloPuzzleNoclip = false
    state.SaberPuzzleNoclip = false
    state.SpecialOwner = nil
    state.SpecialFarm = nil
    state.SpecialRequestBusy = {}
    state.SpecialData = {}
    state.FarmSkillToken = state.FarmSkillToken + 1
    state.FarmClickSerial = state.FarmClickSerial + 1
    state.TravelSerial = state.TravelSerial + 1
    state.FarmQuestRequestId = state.FarmQuestRequestId + 1
    state.Sea2RequestId = state.Sea2RequestId + 1

    clearFruitOverride(false)
    FarmRuntime.Invalidate("", 0)
    FarmRuntime.InvalidateSea2(0)
    FarmRuntime.ClearTravel()
    stopTravel()
    releaseVirtualInputs()
    if state.CancelTasks then state.CancelTasks() end
    restoreAllExpanded()
    restoreCollision()
    setCameraShake(false)
    restoreQuality()
    restoreLighting()

    local _, _, root = getCharacter(LocalPlayer)
    if root then
        pcall(function()
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
        end)
    end
    if state.WaterPart then pcall(function() state.WaterPart:Destroy() end) end
    state.WaterPart = nil

    for _, visual in pairs(state.VisualHeads) do pcall(function() visual:Destroy() end) end
    for _, highlight in pairs(state.Highlights) do pcall(function() highlight:Destroy() end) end
    for _, adornment in pairs(state.Adornments) do pcall(function() adornment:Destroy() end) end
    for _, notification in ipairs(state.Notifications) do
        if notification.Holder then pcall(function() notification.Holder:Destroy() end) end
    end
    if state.NotificationGui then pcall(function() state.NotificationGui:Destroy() end) end
    for _, object in ipairs(state.Drawings) do removeDrawing(object) end

    state.Drawings = {}
    state.PlayerDrawings = {}
    state.WorldDrawings = {}
    state.Highlights = {}
    state.Adornments = setmetatable({}, { __mode = "k" })
    state.VisualHeads = setmetatable({}, { __mode = "k" })
    state.Expanded = setmetatable({}, { __mode = "k" })
    state.Collision = setmetatable({}, { __mode = "k" })
    state.DisabledEffects = setmetatable({}, { __mode = "k" })
    state.Notifications = {}
    state.ContextNotices = {}
    state.NotificationGui = nil
    state.NotificationContainer = nil
    state.StockPanel = nil
    state.StockStroke = nil
    state.StockAccent = nil
    state.StockTitle = nil
    state.StockCount = nil
    state.StockList = nil
    state.StockPriceLabels = {}
    state.StockVisible = false
    state.UIReady = false
    state.SpecialToggleSyncAt = 0
    state.Fruits = {}
    state.PhysicalFruitChoiceIds = setmetatable({}, { __mode = "k" })
    state.PhysicalFruitChoiceNextId = 0
    state.PhysicalFruitChoiceMap = {}
    state.PhysicalFruitChoiceObject = nil
    state.PhysicalFruitChoiceControl = nil
    state.PhysicalFruitChoiceRefreshing = false
    state.PhysicalFruitChoiceSignature = nil
    state.PhysicalFruitCountLabel = nil
    state.DoughKingCocoaLabel = nil
    state.DoughKingCounterLabel = nil
    state.FruitRollBusy = false
    state.Chests = setmetatable({}, { __mode = "k" })
    state.ChestAttempts = setmetatable({}, { __mode = "k" })
    state.ChestPositionAttempts = {}
    state.FruitAttempts = setmetatable({}, { __mode = "k" })
    state.FruitStoreAttempts = setmetatable({}, { __mode = "k" })
    state.KnownTools = setmetatable({}, { __mode = "k" })
    state.TravelButtons = {}
    state.QuestDefinitions = nil
    state.GuideModule = nil
    state.GuideDataModule = nil
    state.QuestCatalog = {}
    state.QuestGivers = {}
    state.EnemySpawns = {}
    state.FarmTarget = nil
    state.FarmTool = nil
    state.FarmGroupMembers = setmetatable({}, { __mode = "k" })
    state.FarmGroupDestination = nil
    state.FarmGroupTargetName = nil
    state.FarmFruitM1Targets = setmetatable({}, { __mode = "k" })
    state.Sea2Target = nil
    state.Sea2Tool = nil
    state.SeaBeastTarget = nil
    state.SeaBeastTool = nil
    state.SeaBeastBoat = nil
    state.MirageFound = nil
    state.MirageMarker = nil
    state.MirageDealer = nil
    state.MirageGear = nil
    state.IslandFinderFound = nil
    state.IslandFinderFoundName = nil
    state.IslandFinderAutoControl = nil
    state.IslandFinderTravelActive = false
    state.IslandFinderTravelPendingUntil = 0
    state.EventFound = nil

    if environment.bob_lol_blox_fruits and environment.bob_lol_blox_fruits.State == state then
        environment.bob_lol_blox_fruits = nil
    end
    environment.bob_lol_blox_fruits_boot_error = nil
end

local function fullUnload()
    cleanup()
    pcall(function()
        if UI.Unload then UI:Unload() else UI:Destroy() end
    end)
end

environment.bob_lol_blox_fruits = {
    State = state,
    Settings = Settings,
    Session = FarmRuntime.Session,
    Compatibility = FarmRuntime.ObfuscationCompatibility,
    RefreshStock = refreshStock,
    Notify = showNotice,
    BeginTravel = beginTravel,
    StopTravel = stopTravel,
    SpecialControls = SecondSeaControls,
    Unload = fullUnload
}

local Window = UI:CreateWindow({
    Title = "bob.lol | Blox Fruits",
    Preset = "Amber",
    Width = 760,
    Height = 520,
    TabLayout = "Sidebar",
    SidebarWidth = 142,
    SidebarFooterKey = "F1",
    SidebarFooterText = "Toggle",
    ScrollSidebar = true,
    CollapseToHeader = true,
    CollapseHeaderWidth = 270,
    RefinedHeader = true,
    SliderRoundness = 1,
    OnClose = fullUnload,
    ToggleKey = Enum.KeyCode.F1
})

if #state.FruitCatalog == 0 then
    state.FruitCatalog = {
        "Blade", "Blizzard", "Bomb", "Buddha", "Control", "Creation", "Dark", "Diamond", "Dough", "Dragon",
        "Eagle", "Flame", "Gas", "Ghost", "Gravity", "Ice", "Kitsune", "Light", "Lightning", "Love", "Magma",
        "Magnet", "Mammoth", "Pain", "Phoenix", "Portal", "Quake", "Rocket", "Rubber", "Sand", "Shadow", "Smoke",
        "Sound", "Spider", "Spike", "Spin", "Spirit", "Spring", "T-Rex", "Tiger", "Venom", "Yeti"
    }
end

do
local Combat = Window:AddTab({ Name = "Combat", Group = "General" })
local AimSection = Combat:AddSection("Aimbot", "left")
local TargetSection = Combat:AddSection("Targeting", "left")
local HitboxSection = Combat:AddSection("Hitbox Targets", "right")
local HitboxSettings = Combat:AddSection("Hitbox Size", "right")
local CombatUtility = Combat:AddSection("Utility", "right")

AimSection:AddToggle("Aimbot", Settings.Aimbot, UI:Bind(Settings, "Aimbot", function() state.AimTarget = nil end))
AimSection:AddKeybind("Aim Key", Settings.AimKey, UI:Bind(Settings, "AimKey"))
AimSection:AddSlider("FOV", 25, 600, Settings.AimFov, UI:Bind(Settings, "AimFov"), "[value]")
AimSection:AddSlider("Smoothness", 1, 12, Settings.AimSmoothness, UI:Bind(Settings, "AimSmoothness"), "[value]")
AimSection:AddSlider("Prediction", 0, 300, Settings.AimPrediction, UI:Bind(Settings, "AimPrediction"), "[value]ms")
local fovToggle = AimSection:AddToggle("Show FOV", Settings.ShowFov, UI:Bind(Settings, "ShowFov"))
fovToggle:AddColorPicker("FOV Color", Settings.FovColor, UI:Bind(Settings, "FovColor"))

TargetSection:AddDropdown("Aim Part", { "Head", "UpperTorso", "HumanoidRootPart" }, Settings.AimPart, UI:Bind(Settings, "AimPart", function() state.AimTarget = nil end))
TargetSection:AddToggle("Visibility Check", Settings.AimVisibleOnly, UI:Bind(Settings, "AimVisibleOnly", function() state.AimTarget = nil end))
TargetSection:AddToggle("Ally Check", Settings.AimAllyCheck, UI:Bind(Settings, "AimAllyCheck", function() state.AimTarget = nil end))
TargetSection:AddToggle("Sticky Target", Settings.AimSticky, UI:Bind(Settings, "AimSticky"))
TargetSection:AddSlider("Max Distance", 100, 10000, Settings.AimMaxDistance, UI:Bind(Settings, "AimMaxDistance"), "[value]m")

local hitboxToggle = HitboxSection:AddToggle("Hitbox Expander", Settings.Hitbox, function(value)
    Settings.Hitbox = value
    if not value then restoreAllExpanded() end
end)
hitboxToggle:AddColorPicker("Wireframe Color", Settings.HitboxColor, UI:Bind(Settings, "HitboxColor"))
HitboxSection:AddToggle("Players", Settings.HitboxPlayers, UI:Bind(Settings, "HitboxPlayers"))
HitboxSection:AddToggle("Enemies", Settings.HitboxEnemies, UI:Bind(Settings, "HitboxEnemies"))
HitboxSection:AddToggle("Bosses", Settings.HitboxBosses, UI:Bind(Settings, "HitboxBosses"))
HitboxSettings:AddToggle("Uniform Size", Settings.HitboxUniform, UI:Bind(Settings, "HitboxUniform"))
HitboxSettings:AddSlider("Uniform", 1, 10, Settings.HitboxSize, UI:Bind(Settings, "HitboxSize"), "[value]")
HitboxSettings:AddSlider("X", 1, 10, Settings.HitboxX, UI:Bind(Settings, "HitboxX"), "[value]")
HitboxSettings:AddSlider("Y", 1, 10, Settings.HitboxY, UI:Bind(Settings, "HitboxY"), "[value]")
HitboxSettings:AddSlider("Z", 1, 10, Settings.HitboxZ, UI:Bind(Settings, "HitboxZ"), "[value]")
HitboxSettings:AddToggle("Wireframe", Settings.HitboxWireframe, UI:Bind(Settings, "HitboxWireframe"))
HitboxSettings:AddSlider("Range", 100, 4000, Settings.HitboxDistance, UI:Bind(Settings, "HitboxDistance"), "[value]m")

CombatUtility:AddToggle("Auto Aura", Settings.AutoAura, UI:Bind(Settings, "AutoAura"))
CombatUtility:AddToggle("No Camera Shake", Settings.NoCameraShake, setCameraShake)
end

do
local Visuals = Window:AddTab({ Name = "Visuals", Group = "General" })
local PlayerSection = Visuals:AddSection("Player ESP", "left")
local PlayerDetailsSection = Visuals:AddSection("Player Details", "left")
local EnemySection = Visuals:AddSection("Enemy ESP", "right")
local WorldSection = Visuals:AddSection("World ESP", "right")
local VisualColorSection = Visuals:AddSection("Colors", "right")

local playerToggle = PlayerSection:AddToggle("Player ESP", Settings.PlayerESP, UI:Bind(Settings, "PlayerESP"))
playerToggle:AddColorPicker("Enemy Color", Settings.PlayerColor, UI:Bind(Settings, "PlayerColor"))
PlayerSection:AddToggle("Boxes", Settings.PlayerBoxes, UI:Bind(Settings, "PlayerBoxes"))
PlayerSection:AddToggle("Names", Settings.PlayerNames, UI:Bind(Settings, "PlayerNames"))
PlayerSection:AddToggle("Health Bar", Settings.PlayerHealth, UI:Bind(Settings, "PlayerHealth"))
PlayerSection:AddToggle("Distance", Settings.PlayerDistance, UI:Bind(Settings, "PlayerDistance"))
PlayerDetailsSection:AddToggle("Equipment", Settings.PlayerEquipment, UI:Bind(Settings, "PlayerEquipment"))
PlayerDetailsSection:AddToggle("Tracers", Settings.PlayerTracers, UI:Bind(Settings, "PlayerTracers"))
PlayerDetailsSection:AddToggle("Chams", Settings.PlayerChams, UI:Bind(Settings, "PlayerChams"))
PlayerDetailsSection:AddSlider("Max Distance (0 = Infinite)", 0, 10000, Settings.PlayerMaxDistance, UI:Bind(Settings, "PlayerMaxDistance"), "[value]m")

EnemySection:AddToggle("Nearby Enemies", Settings.EnemyESP, UI:Bind(Settings, "EnemyESP"))
EnemySection:AddToggle("Bosses", Settings.BossESP, UI:Bind(Settings, "BossESP"))
EnemySection:AddToggle("Boxes", Settings.EnemyBoxes, UI:Bind(Settings, "EnemyBoxes"))
EnemySection:AddToggle("Health Bar", Settings.EnemyHealth, UI:Bind(Settings, "EnemyHealth"))
EnemySection:AddToggle("Distance", Settings.EnemyDistance, UI:Bind(Settings, "EnemyDistance"))
EnemySection:AddSlider("Max Distance", 100, 5000, Settings.EnemyMaxDistance, UI:Bind(Settings, "EnemyMaxDistance"), "[value]m")

WorldSection:AddToggle("Sea Events", Settings.SeaESP, UI:Bind(Settings, "SeaESP"))
WorldSection:AddToggle("Sea Event Alerts", Settings.SeaAlerts, UI:Bind(Settings, "SeaAlerts"))
WorldSection:AddToggle("Nearest Chest", Settings.NearestChest, UI:Bind(Settings, "NearestChest"))

VisualColorSection:AddColorPicker("Ally", Settings.AllyColor, UI:Bind(Settings, "AllyColor"))
VisualColorSection:AddToggle("Use Accent Color", Settings.ESPUseAccent, UI:Bind(Settings, "ESPUseAccent"))
VisualColorSection:AddColorPicker("Enemy NPC", Settings.EnemyColor, UI:Bind(Settings, "EnemyColor"))
VisualColorSection:AddColorPicker("Boss", Settings.BossColor, UI:Bind(Settings, "BossColor"))
VisualColorSection:AddColorPicker("Sea Event", Settings.SeaColor, UI:Bind(Settings, "SeaColor"))
VisualColorSection:AddColorPicker("Chest", Settings.ChestColor, UI:Bind(Settings, "ChestColor"))
end

local Movement = Window:AddTab({ Name = "Movement", Group = "General" })
local FlightSection = Movement:AddSection("Flight", "left")
local CharacterSection = Movement:AddSection("Character", "right")

FlightControl = FlightSection:AddToggle("CFrame Flight", Settings.Flight, UI:Bind(Settings, "Flight"))
FlightSection:AddKeybind("Flight Key", Settings.FlightKey, UI:Bind(Settings, "FlightKey"))
FlightSection:AddSlider("Speed", 25, 200, Settings.FlightSpeed, UI:Bind(Settings, "FlightSpeed"), "[value] studs/s")
FlightSection:AddLabel("WASD + Space / Left Ctrl")

NoclipControl = CharacterSection:AddToggle("Noclip", Settings.Noclip, function(value)
    Settings.Noclip = value
    if not value and not state.TravelTarget then restoreCollision() end
end)
CharacterSection:AddKeybind("Noclip Key", Settings.NoclipKey, UI:Bind(Settings, "NoclipKey"))
CharacterSection:AddToggle("Water Walk", Settings.WaterWalk, UI:Bind(Settings, "WaterWalk"))
CharacterSection:AddToggle("Infinite Jump", Settings.InfiniteJump, UI:Bind(Settings, "InfiniteJump"))

local Travel = Window:AddTab({ Name = "Travel", Group = "General" })
local IslandSection = Travel:AddSection("Island Travel", "left")
local TargetTravelSection = Travel:AddSection("Target Travel", "right")

IslandSection:AddDropdown("Island", IslandNames, Settings.SelectedIsland, UI:Bind(Settings, "SelectedIsland"))
IslandSection:AddSlider("Travel Speed", 25, 200, Settings.TravelSpeed, UI:Bind(Settings, "TravelSpeed"), "[value] studs/s")
state.TravelButtons.island = { Control = IslandSection:AddButton("Travel to Island", travelToIsland), Text = "Travel to Island" }
state.TravelButtons.islandHome = { Control = IslandSection:AddButton("Set Home + Teleport", function() travelToIsland(true) end), Text = "Set Home + Teleport" }

TargetTravelSection:AddDropdown("Boss", BossNames, Settings.SelectedBoss, UI:Bind(Settings, "SelectedBoss"))
state.TravelButtons.boss = { Control = TargetTravelSection:AddButton("Travel to Boss", travelToBoss), Text = "Travel to Boss" }
state.TravelButtons.fruit = { Control = TargetTravelSection:AddButton("Travel to Physical Fruit", travelToFruit), Text = "Travel to Physical Fruit" }
state.TravelButtons.chest = { Control = TargetTravelSection:AddButton("Travel to Nearest Chest", travelToChest), Text = "Travel to Nearest Chest" }

FarmRuntime.RefreshTravelButtons = function()
    for key, entry in pairs(state.TravelButtons) do
        local control = entry.Control
        if control and control.SetText then
            control:SetText(state.TravelTarget and state.TravelButtonKey == key and "Stop Travel" or entry.Text)
        end
    end
end
FarmRuntime.RefreshTravelButtons()

local Farm = Window:AddTab({ Name = "Farm", Group = "Automation" })
local FarmAutomation = Farm:AddSection("Auto Farm", "left")
local FarmTargets = Farm:AddSection("Target & Position", "left")
local FarmDrops = Farm:AddSection("Loot & Goals", "left")
local FarmCombat = Farm:AddSection("Combat & Travel", "right")
local FarmCollection = Farm:AddSection("Collection", "right")
local FarmMastery = Farm:AddSection("Mastery", "right")

task.spawn(function()
    while state.Alive do
        FarmRuntime.ProcessClick()
        task.wait(0.01)
    end
end)

FarmCollection:AddToggle("Auto Get Chests", Settings.AutoChest, function(value)
    Settings.AutoChest = value
    if not value and state.TravelOwner == "chest" then stopTravel() end
    if value then
        state.ChestIslandAttempts = {}
        state.ChestIslandSearchReadyAt = 0
        local _, _, root = getCharacter(LocalPlayer)
        if not findNearestChest(root, false, 1800) then
            contextNotice("Searching:AutoChest", "No nearby chest; searching the closest island", Muted, 4, 8)
        else
            showNotice("Auto chest enabled", nil, 2.5)
        end
    else
        showNotice("Auto chest disabled", nil, 2.5)
    end
end)
FarmCollection:AddSlider("Chest Speed", 25, 200, Settings.AutoChestSpeed, UI:Bind(Settings, "AutoChestSpeed"), "[value] studs/s")
FarmCollection:AddToggle("Auto Buy Bait", Settings.AutoBuyBait, function(value)
    Settings.AutoBuyBait = value
    state.BaitBuyNextAt = 0
    if value then
        FarmRuntime.UpdateAutoBait(true)
        showNotice("Auto buy bait enabled", nil, 2.5)
    else
        showNotice("Auto buy bait disabled", nil, 2.5)
    end
end)
FarmCollection:AddToggle("Auto Fish", Settings.AutoFish, function(value)
    Settings.AutoFish = value
    if value then
        local rod = FarmRuntime.FindFishingRod and FarmRuntime.FindFishingRod()
        if not rod then
            contextNotice("Waiting:AutoFishRod", "Auto Fish will start after you get a fishing rod", Red, 4, 3)
            return
        end
        if not FarmRuntime.FishingBaitReady or not FarmRuntime.FishingBaitReady() then
            if Settings.AutoBuyBait then
                FarmRuntime.UpdateAutoBait(true)
                contextNotice("Waiting:AutoFishBait", "Auto Fish is buying or equipping bait", Muted, 4, 3)
            else
                contextNotice("Waiting:AutoFishBait", "Auto Fish will start after you equip fishing bait", Red, 4, 3)
            end
            return
        end
        state.FishingNextActionAt = 0
        showNotice("Auto fish enabled", nil, 2.5)
    else
        if FarmRuntime.StopFishing then FarmRuntime.StopFishing(true) end
        showNotice("Auto fish disabled", nil, 2.5)
    end
end)
FarmEnabledControl = FarmAutomation:AddToggle("Auto Farm", Settings.AutoFarm, function(value)
    Settings.AutoFarm = value
    state.FarmLastUpdate = 0
    state.FarmLastAttack = 0
    if value then
        if FarmRuntime.StopFishing then FarmRuntime.StopFishing(true) end
        local _, humanoid, root = getCharacter(LocalPlayer)
        if not root or not humanoid or humanoid.Health <= 0 then
            Settings.AutoFarm = false
            task.defer(function()
                if FarmEnabledControl and FarmEnabledControl.Set then pcall(function() FarmEnabledControl:Set(false) end) end
            end)
            contextNotice("Blocked:AutoFarmCharacter", "Your character is not ready", Red, 4, 3)
            return
        end
        local weapon, weaponError = FarmRuntime.ResolveWeapon()
        if not weapon then
            Settings.AutoFarm = false
            task.defer(function()
                if FarmEnabledControl and FarmEnabledControl.Set then pcall(function() FarmEnabledControl:Set(false) end) end
            end)
            contextNotice("Blocked:AutoFarmWeapon", weaponError or "No valid weapon was found", Red, 4, 3)
            return
        end
        if Settings.FarmAttackMethod == "Remote" and weapon.Category == "Gun" then
            Settings.AutoFarm = false
            task.defer(function()
                if FarmEnabledControl and FarmEnabledControl.Set then pcall(function() FarmEnabledControl:Set(false) end) end
            end)
            contextNotice("Blocked:AutoFarmGun", "Remote attacks do not support Guns; choose Click", Red, 5, 3)
            return
        end
        stopTravel()
        FarmRuntime.Invalidate("", 0)
        showNotice("Auto farm enabled", nil, 2.5)
    else
        FarmRuntime.Invalidate("", 0)
        showNotice("Auto farm disabled", nil, 2.5)
    end
end)

FarmAutomation:AddDropdown("Mode", { "Level", "Mastery", "Boss" }, Settings.FarmMode, function(value)
    Settings.FarmMode = value or "Level"
    FarmRuntime.Invalidate("", 0)
end)
FarmAutomation:AddToggle("Auto Quest", Settings.FarmAutoQuest, UI:Bind(Settings, "FarmAutoQuest", function()
    FarmRuntime.Invalidate("", 0)
end))
FarmAutomation:AddToggle("Auto Travel", Settings.FarmAutoTravel, UI:Bind(Settings, "FarmAutoTravel", function(value)
    if not value and FarmRuntime.IsTravelMode(state.TravelMode) then stopTravel() end
    FarmRuntime.Invalidate(value and "" or "Auto Travel is disabled", 0)
end))
FarmAutomation:AddButton("Show Farm Status", function()
    local using = state.FarmWeaponInfo and state.FarmWeaponInfo.DisplayName or "None"
    local warning = state.FarmWarning ~= "" and (" | " .. state.FarmWarning) or ""
    showNotice(state.FarmPhase .. " | " .. using .. " | " .. Settings.FarmAttackMethod .. warning, nil, 5)
end)

FarmTargets:AddDropdown("Enemy", FarmEnemyNames, Settings.FarmEnemy, UI:Bind(Settings, "FarmEnemy", function()
    FarmRuntime.Invalidate("", 0)
end))
FarmRuntime.UpdateFarmPositionControls = function()
    local visible = Settings.FarmPosition == "Square"
    if state.FarmSquareSizeControl and state.FarmSquareSizeControl.SetVisible then
        state.FarmSquareSizeControl:SetVisible(visible)
    end
    if state.FarmCornerTimeControl and state.FarmCornerTimeControl.SetVisible then
        state.FarmCornerTimeControl:SetVisible(visible)
    end
end
FarmTargets:AddDropdown("Position", { "Above", "Behind", "Front", "Square" }, Settings.FarmPosition, function(value)
    Settings.FarmPosition = value or "Above"
    FarmRuntime.UpdateFarmPositionControls()
end)
FarmTargets:AddSlider("Distance", 3, 50, Settings.FarmDistance, UI:Bind(Settings, "FarmDistance"), "[value] studs")
state.FarmSquareSizeControl = FarmTargets:AddSlider("Square Size", 4, 30, Settings.FarmSquareSize, UI:Bind(Settings, "FarmSquareSize"), "[value] studs")
state.FarmCornerTimeControl = FarmTargets:AddSlider("Corner Time", 0.2, 3, Settings.FarmSquareCornerTime, UI:Bind(Settings, "FarmSquareCornerTime"), "[value]s")
FarmRuntime.UpdateFarmPositionControls()
FarmTargets:AddToggle("Auto Group", Settings.FarmAutoGroup, function(value)
    Settings.FarmAutoGroup = value
    if not value then FarmRuntime.ClearFarmGroup() end
end)

FarmDrops:AddToggle("Item Alerts", Settings.FarmDropAlerts, UI:Bind(Settings, "FarmDropAlerts"))
FarmDrops:AddButton("Recent Items", function()
    local text = #state.RecentDrops > 0 and table.concat(state.RecentDrops, ", ") or "No new items"
    showNotice(text, nil, 5)
end)
FarmDrops:AddButton("Clear Recent", function()
    table.clear(state.RecentDrops)
end)

if game.PlaceId == SEA_PLACE_IDS.Second then
    local DropGoalNames = {}
    for name in pairs(FarmRuntime.DropGoals) do
        DropGoalNames[#DropGoalNames + 1] = name
    end
    table.sort(DropGoalNames)
    FarmDrops:AddDropdown("Drop Goal", DropGoalNames, Settings.DropGoal, UI:Bind(Settings, "DropGoal", function()
        if Settings.AutoDropGoal then
            FarmRuntime.SetSecondSeaMode("AutoDropGoal", true)
        end
    end))
    SecondSeaControls.AutoDropGoal = FarmDrops:AddToggle("Farm Until Obtained", Settings.AutoDropGoal, function(value)
        FarmRuntime.SetSecondSeaMode("AutoDropGoal", value)
    end)
end

FarmCombat:AddDropdown("Weapon", { "Auto", "Melee", "Sword", "Gun", "Blox Fruit" }, Settings.FarmWeapon, UI:Bind(Settings, "FarmWeapon", function()
    FarmRuntime.Invalidate("", 0)
end))
FarmCombat:AddDropdown("Attack Method", { "Click", "Remote" }, Settings.FarmAttackMethod, UI:Bind(Settings, "FarmAttackMethod", function()
    FarmRuntime.Invalidate("", 0)
end))
FarmCombat:AddSlider({
    name = "Attack Delay",
    min = 0.05,
    max = 1,
    default = Settings.FarmAttackDelay,
    increment = 0.05,
    value = "[value]s",
    callback = UI:Bind(Settings, "FarmAttackDelay")
})
FarmCombat:AddSlider("Travel Speed", 25, 200, Settings.FarmTravelSpeed, UI:Bind(Settings, "FarmTravelSpeed"), "[value] studs/s")
FarmCombat:AddLabel("Shared by bosses, raids, and progression")

FarmMastery:AddDropdown("Weapon Type", { "Melee", "Sword", "Gun", "Blox Fruit" }, Settings.FarmMasteryType, UI:Bind(Settings, "FarmMasteryType", function()
    FarmRuntime.Invalidate("", 0)
end))
FarmMastery:AddSlider("Stop At", 1, 600, Settings.FarmMasteryGoal, UI:Bind(Settings, "FarmMasteryGoal"), "[value]")
FarmMastery:AddButton("Current Mastery", function()
    showNotice(Settings.FarmMasteryType .. ": " .. tostring(FarmRuntime.MasteryLevel(Settings.FarmMasteryType)), nil, 4)
end)
FarmMastery:AddToggle("Mastery Finisher", Settings.MasteryFinisher, UI:Bind(Settings, "MasteryFinisher", function()
    FarmRuntime.Invalidate("", 0)
end))
FarmMastery:AddDropdown("Finisher Weapon", { "Melee", "Sword", "Gun", "Blox Fruit" }, Settings.MasteryFinisherType, UI:Bind(Settings, "MasteryFinisherType", function()
    FarmRuntime.Invalidate("", 0)
end))
FarmMastery:AddSlider("Finish Below", 5, 50, Settings.MasteryFinisherHealth, UI:Bind(Settings, "MasteryFinisherHealth"), "[value]% health")

do
    local Bosses = Window:AddTab({ Name = "Bosses", Group = "Automation" })
    local BossFarmSection = Bosses:AddSection("Boss Farm", "left")
    local CakeLandSection = Bosses:AddSection("Cake Land", "left")
    local CakeSafetySection = Bosses:AddSection("Cake Land Safety", "right")
    local WorldBossSection = Bosses:AddSection("World Bosses", "right")
    local BossSearchSection = Bosses:AddSection("Server Hop", "right")

    BossFarmSection:AddToggle("Auto Farm Level Bosses", Settings.AutoBosses, function(value)
        Settings.AutoBosses = value
        state.BossNextHopAt = 0
        FarmRuntime.Invalidate("", 0)
        showNotice(value and "Boss farm enabled" or "Boss farm disabled", nil, 3)
    end)
    BossFarmSection:AddDropdown("Selected Boss", BossNames, Settings.FarmBoss, UI:Bind(Settings, "FarmBoss", function()
        FarmRuntime.Invalidate("", 0)
    end))
    BossFarmSection:AddToggle("Accept Level Boss Quests", Settings.BossUseQuest, UI:Bind(Settings, "BossUseQuest", function()
        FarmRuntime.Invalidate("", 0)
    end))
    BossFarmSection:AddToggle("Accept Selected Boss Quest", Settings.FarmBossQuest, UI:Bind(Settings, "FarmBossQuest", function()
        FarmRuntime.Invalidate("", 0)
    end))
    BossFarmSection:AddToggle("Bosses During Level Farm", Settings.FarmLevelBosses, UI:Bind(Settings, "FarmLevelBosses", function()
        FarmRuntime.Invalidate("", 0)
    end))
    BossFarmSection:AddLabel("Uses Farm combat + travel settings")

    SecondSeaControls.AutoCakePrince = CakeLandSection:AddToggle("Auto Cake Prince", Settings.AutoCakePrince, function(value)
        FarmRuntime.SetSecondSeaMode("AutoCakePrince", value)
        FarmRuntime.SetCakePrinceCounter(state.CakeCounterLastText or "Checking")
        if not value then FarmRuntime.RefreshCakePrinceCounter(true) end
    end)

    SecondSeaControls.AutoDoughKing = CakeLandSection:AddToggle("Auto Dough King", Settings.AutoDoughKing, function(value)
        local modeOk, accepted = pcall(FarmRuntime.SetSecondSeaMode, "AutoDoughKing", value)
        if not modeOk then accepted = Settings.AutoDoughKing == value end
        if value and accepted == false then Settings.AutoDoughKing = false end
        task.defer(function()
            local control = SecondSeaControls.AutoDoughKing
            if control and control.Set then pcall(function() control:Set(Settings.AutoDoughKing) end) end
            pcall(function() FarmRuntime.RefreshDoughKingStatus(true) end)
        end)
    end)
    state.AutoSpawnCakePrinceControl = CakeLandSection:AddToggle("Auto Spawn Cake Prince", Settings.AutoSpawnCakePrince, function(value)
        FarmRuntime.SetCakeLandAutoSpawn("Cake Prince", value)
    end)
    state.AutoSpawnDoughKingControl = CakeLandSection:AddToggle("Auto Spawn Dough King", Settings.AutoSpawnDoughKing, function(value)
        FarmRuntime.SetCakeLandAutoSpawn("Dough King", value)
    end)
    state.CakePrinceCounterLabel = CakeLandSection:AddLabel("Enemies Remaining: Checking")
    state.DoughKingCocoaLabel = nil
    state.DoughKingCounterLabel = state.CakePrinceCounterLabel
    if game.PlaceId ~= SEA_PLACE_IDS.Third then
        pcall(function() state.CakePrinceCounterLabel.Visible = false end)
    end
    CakeLandSection:AddLabel("Uses Farm combat + travel settings")
    FarmRuntime.RefreshDoughKingStatus(true)

    CakeSafetySection:AddToggle("Player Safety", Settings.DoughKingPlayerSafety, function(value)
        Settings.DoughKingPlayerSafety = value
        if not value then
            state.SpecialData.CakeLandRetreating = nil
            state.SpecialData.CakeLandRetreatPosition = nil
            if state.TravelMode == "farmCakeRetreat" then stopTravel() end
        end
    end)
    CakeSafetySection:AddSlider("Player Range", 50, 1000, Settings.DoughKingSafetyRange, UI:Bind(Settings, "DoughKingSafetyRange"), "[value] studs")
    CakeSafetySection:AddSlider("Retreat Height", 100, 1500, Settings.DoughKingRetreatHeight, UI:Bind(Settings, "DoughKingRetreatHeight", function()
        state.SpecialData.CakeLandRetreatPosition = nil
    end), "[value] studs")

    SecondSeaControls.AutoTyrant = WorldBossSection:AddToggle("Auto Tyrant", Settings.AutoTyrant, function(value)
        FarmRuntime.SetSecondSeaMode("AutoTyrant", value)
    end)
    SecondSeaControls.AutoEliteHunter = WorldBossSection:AddToggle("Auto Elite Hunter", Settings.AutoEliteHunter, function(value)
        FarmRuntime.SetSecondSeaMode("AutoEliteHunter", value)
    end)

    BossSearchSection:AddToggle("Auto Server Hop", Settings.BossAutoHop, function(value)
        Settings.BossAutoHop = value
        state.BossNextHopAt = 0
        if value and not Settings.AutoBosses then
            contextNotice("BossHopFarm", "Enable Auto Farm Level Bosses to start searching", Muted, 4, 2)
        end
    end)
    BossSearchSection:AddSlider("Hop Delay", 10, 90, Settings.BossHopDelay, UI:Bind(Settings, "BossHopDelay", function()
        state.BossNextHopAt = 0
    end), "[value]s")
    BossSearchSection:AddButton("Server Hop Now", function() serverHop(true) end)
end

do
    local Stats = Window:AddTab({ Name = "Stats", Group = "Automation" })
    local AutoStatsSection = Stats:AddSection("Auto Stats", "left")
    local AllocationSection = Stats:AddSection("Allocate Points", "right")
    local statChoices = { "Melee", "Defense", "Sword", "Gun", "Blox Fruit" }

    AutoStatsSection:AddToggle("Auto Stats", Settings.AutoStats, function(value)
        Settings.AutoStats = value
        state.AutoStatsNextAt = 0
        if value then
            local data = LocalPlayer:FindFirstChild("Data")
            local points = data and data:FindFirstChild("Points")
            if type(Settings.AutoStatSelection) ~= "table" or #Settings.AutoStatSelection == 0 then
                contextNotice("AutoStatsSelection", "Choose at least one stat to balance", Red, 4, 1)
            elseif not points or points.Value <= 0 then
                showNotice("Auto Stats enabled - waiting for points", nil, 3)
            else
                showNotice("Auto Stats enabled", nil, 3)
            end
        else
            showNotice("Auto Stats disabled", nil, 2.5)
        end
    end)
    AutoStatsSection:AddLabel("Points are split evenly across the enabled stats")

    for _, statName in ipairs(statChoices) do
        local selectedName = statName
        AllocationSection:AddToggle(selectedName, table.find(Settings.AutoStatSelection, selectedName) ~= nil, function(value)
            local selected = Settings.AutoStatSelection
            local index = table.find(selected, selectedName)
            if value and not index then
                selected[#selected + 1] = selectedName
            elseif not value and index then
                table.remove(selected, index)
            end
            state.AutoStatsNextAt = 0
            if #selected == 0 then
                contextNotice("AutoStatsSelection", "Choose at least one stat to balance", Red, 4, 1)
            end
        end)
    end
end

do
    local Fruits = Window:AddTab({ Name = "Fruits", Group = "Automation" })
    local FruitCollection = Fruits:AddSection("Auto Collection", "left")
    local FruitActions = Fruits:AddSection("Actions", "left")
    local FruitESPSection = Fruits:AddSection("Fruit ESP", "left")
    local FruitStockSection = Fruits:AddSection("Stock Alerts", "right")
    local FruitStockBuySection = Fruits:AddSection("Buy from Stock", "right")
    local FruitMapSection = Fruits:AddSection("Fruits on Map", "right")
    local AutoFruitChoices = {}
    local fallbackRanks = {}
    for index, fruitName in ipairs(AUTO_FRUIT_PRIORITY) do
        AutoFruitChoices[index] = fruitName
        fallbackRanks[fruitName] = index
    end
    table.sort(AutoFruitChoices, function(a, b)
        local aPrice, bPrice = state.FruitPrices[a], state.FruitPrices[b]
        if aPrice and bPrice and aPrice ~= bPrice then return aPrice > bPrice end
        return (fallbackRanks[a] or math.huge) < (fallbackRanks[b] or math.huge)
    end)

    FruitCollection:AddToggle("Auto Get Physical Fruits", Settings.AutoFruit, function(value)
        Settings.AutoFruit = value
        if not value then clearFruitOverride(true) end
        if value then
            local _, _, root = getCharacter(LocalPlayer)
            if not findNearestFruit(root) then
                local filtered = #(Settings.AutoFruitWantedFruits or {}) > 0
                contextNotice("Waiting:AutoFruit", filtered and "No selected fruit is currently spawned; waiting for one" or "No physical fruit is currently spawned; waiting for one", Muted, 4, 8)
            else
                showNotice("Auto fruit enabled", nil, 2.5)
            end
        else
            showNotice("Auto fruit disabled", nil, 2.5)
        end
    end)
    FruitCollection:AddMultiDropdown("Wanted Fruits", AutoFruitChoices, Settings.AutoFruitWantedFruits, UI:Bind(Settings, "AutoFruitWantedFruits", function()
        local travellingFruit = state.TravelMode == "fruit" and state.TravelObject
        if travellingFruit and not autoFruitAllowed(travellingFruit) then
            if state.FruitOverrideActive then clearFruitOverride(true) else stopTravel() end
        end
    end))
    FruitCollection:AddSlider("Travel Speed", 25, 200, Settings.AutoFruitSpeed, UI:Bind(Settings, "AutoFruitSpeed"), "[value] studs/s")
    FruitCollection:AddToggle("Auto Store Fruits", Settings.AutoStoreFruit, function(value)
        Settings.AutoStoreFruit = value
        if value then
            local queued = 0
            for _, container in ipairs({ LocalPlayer:FindFirstChildOfClass("Backpack"), LocalPlayer.Character }) do
                if container then
                    for _, instance in ipairs(container:GetChildren()) do
                        if storableFruitTool(instance) then
                            queued = queued + 1
                            queueFruitStore(instance)
                        end
                    end
                end
            end
            if queued == 0 and state.UIReady then
                contextNotice("Waiting:AutoStoreFruit", "No physical fruit is in your inventory; waiting for one", Muted, 4, 8)
            end
        end
    end)
    FruitActions:AddButton("Travel to Nearest Fruit", travelToFruit)
    FruitActions:AddButton("Roll Fruit", FarmRuntime.RollFruit)

    FruitESPSection:AddToggle("Physical Fruit ESP", Settings.FruitESP, UI:Bind(Settings, "FruitESP"))
    FruitESPSection:AddToggle("Spawn Alerts", Settings.FruitAlerts, UI:Bind(Settings, "FruitAlerts"))
    FruitESPSection:AddSlider("Max Distance (0 = Infinite)", 0, 10000, Settings.FruitMaxDistance, UI:Bind(Settings, "FruitMaxDistance"), "[value]m")
    FruitESPSection:AddColorPicker("ESP Color", Settings.FruitColor, UI:Bind(Settings, "FruitColor"))

    FruitStockSection:AddToggle("Stock Overlay", Settings.StockOverlay, UI:Bind(Settings, "StockOverlay"))
    FruitStockSection:AddToggle("Specific Fruit Alerts", Settings.StockNotifications, UI:Bind(Settings, "StockNotifications"))
    FruitStockSection:AddMultiDropdown("Alert Fruits", state.FruitCatalog, Settings.StockWantedFruits, UI:Bind(Settings, "StockWantedFruits"))
    FruitStockSection:AddSlider("Useful Price", 100000, 15000000, Settings.StockMinimumPrice, UI:Bind(Settings, "StockMinimumPrice"), "$[value]")
    FruitStockBuySection:AddDropdown("Fruit", state.FruitCatalog, Settings.StockBuyFruit, function(value)
        Settings.StockBuyFruit = value
        state.AutoStockNextAt = 0
        if state.DragonTypeControl and state.DragonTypeControl.SetVisible then
            state.DragonTypeControl:SetVisible(value == "Dragon")
        end
        if Settings.AutoBuyStock then task.defer(function() buyStockFruit(true) end) end
    end)
    state.DragonTypeControl = FruitStockBuySection:AddDropdown("Dragon Type", { "West", "East" }, Settings.StockDragonType, UI:Bind(Settings, "StockDragonType"))
    if state.DragonTypeControl and state.DragonTypeControl.SetVisible then
        state.DragonTypeControl:SetVisible(Settings.StockBuyFruit == "Dragon")
    end
    FruitStockBuySection:AddToggle("Auto Buy Selected", Settings.AutoBuyStock, function(value)
        Settings.AutoBuyStock = value
        state.AutoStockNextAt = 0
        if value then
            task.defer(function() buyStockFruit(true) end)
            showNotice("Watching stock for " .. tostring(Settings.StockBuyFruit), nil, 3)
        end
    end)
    FruitStockBuySection:AddButton("Buy From Stock", buyStockFruit)
    FruitStockBuySection:AddButton("Open Dealer", FarmRuntime.OpenFruitDealer)
    FruitStockBuySection:AddButton("Refresh Stock", function()
        if refreshStock(false) then
            showNotice("Fruit stock refreshed", espColor(Settings.FruitColor), 3)
        end
    end)

    state.PhysicalFruitChoiceControl = FruitMapSection:AddDropdown("Fruit on Map", { "No physical fruits" }, "No physical fruits", function(value)
        if state.PhysicalFruitChoiceRefreshing then return end
        state.PhysicalFruitChoiceObject = state.PhysicalFruitChoiceMap[value]
    end)
    state.PhysicalFruitCountLabel = FruitMapSection:AddLabel("On map: 0")
    state.TravelButtons.physicalFruitMap = {
        Control = FruitMapSection:AddButton("Travel to Selected Fruit", FarmRuntime.TravelSelectedPhysicalFruit),
        Text = "Travel to Selected Fruit"
    }
    FruitMapSection:AddButton("Refresh List", function() FarmRuntime.RefreshPhysicalFruitChoices(true) end)
    FarmRuntime.RefreshPhysicalFruitChoices(true)
    FarmRuntime.RefreshTravelButtons()
end

FarmRuntime.AddGoalSections = function(progressTab)
    local materialSection = progressTab:AddSection("Materials", "left")
    local materialChoices = {}
    for name, definition in pairs(FarmRuntime.MaterialTargets) do
        if definition[game.PlaceId] then materialChoices[#materialChoices + 1] = name end
    end
    table.sort(materialChoices)
    if not table.find(materialChoices, Settings.MaterialGoal) then Settings.MaterialGoal = materialChoices[1] end
    Settings.AutoWeaponGoal = false

    materialSection:AddDropdown("Material", materialChoices, Settings.MaterialGoal, function(value)
        Settings.MaterialGoal = value
        FarmRuntime.Invalidate("", 0)
    end)
    MaterialFarmControl = materialSection:AddToggle("Auto Material Farm", Settings.AutoMaterial, function(value)
        Settings.AutoMaterial = value
        if value and Settings.AutoWeaponGoal then
            Settings.AutoWeaponGoal = false
            if WeaponGoalControl and WeaponGoalControl.Set then pcall(function() WeaponGoalControl:Set(false) end) end
        end
        FarmRuntime.Invalidate("", 0)
        showNotice(value and ("Farming " .. tostring(Settings.MaterialGoal)) or "Material farm disabled", nil, 3)
    end)
end

local function addFightingStyleAutoBuy(section)
    FightingStyleAutoControl = section:AddToggle("Auto Buy Selected", Settings.AutoBuyFightingStyle, function(value)
        FarmRuntime.FightingStyles.SetAuto(value)
        if value then
            showNotice("Waiting to buy the selected fighting style", nil, 3)
        end
    end)
end

if game.PlaceId == SEA_PLACE_IDS.First then
    local Progress = Window:AddTab({ Name = "Progression", Group = "Automation" })
    local SeaUnlock = Progress:AddSection("Sea Unlock", "left")
    local SaberQuest = Progress:AddSection("Saber", "left")
    local FightingStyles = Progress:AddSection("Fighting Styles", "right")

    AutoSea2Control = SeaUnlock:AddToggle("Auto Second Sea", Settings.AutoSea2, function(value)
        if value and Settings.AutoSaber then
            FarmRuntime.SetSecondSeaMode("AutoSaber", false)
            local saberControl = SecondSeaControls.AutoSaber
            if saberControl and saberControl.Set then
                task.defer(function() pcall(function() saberControl:Set(false) end) end)
            end
        end
        Settings.AutoSea2 = value
        if value then
            FarmRuntime.InvalidateSea2(0)
            if playerLevel() < 700 then
                local message = Settings.AutoFarm
                    and "You need Level 700 for the Second Sea. Auto Farm will continue while waiting"
                    or "You need Level 700 for the Second Sea"
                contextNotice("Waiting:AutoSea2", message, Red, 5, 8)
                return
            end
            stopTravel()
            showNotice("Second Sea progression started", nil, 3)
        else
            FarmRuntime.InvalidateSea2(0)
        end
    end)
    SecondSeaControls.AutoSaber = SaberQuest:AddToggle("Auto Saber Puzzle", Settings.AutoSaber, function(value)
        FarmRuntime.SetSecondSeaMode("AutoSaber", value)
    end)
    FightingStyles:AddDropdown("Style", FarmRuntime.FightingStyles.Names[1], Settings.Sea1FightingStyle, UI:Bind(Settings, "Sea1FightingStyle"))
    FightingStyles:AddButton("Check Requirements", function() FarmRuntime.FightingStyles.Check(Settings.Sea1FightingStyle) end)
    FightingStyles:AddButton("Buy / Equip", function() FarmRuntime.FightingStyles.Buy(Settings.Sea1FightingStyle) end)
    addFightingStyleAutoBuy(FightingStyles)
    FarmRuntime.AddGoalSections(Progress)
elseif game.PlaceId == SEA_PLACE_IDS.Second then
    local Progress = Window:AddTab({ Name = "Progression", Group = "Automation" })
    local Questlines = Progress:AddSection("Questlines", "left")
    local FightingStyles = Progress:AddSection("Fighting Styles", "left")
    local SeaUnlock = Progress:AddSection("Third Sea", "right")

    SecondSeaControls.AutoBartilo = Questlines:AddToggle("Auto Bartilo Quest", Settings.AutoBartilo, function(value)
        FarmRuntime.SetSecondSeaMode("AutoBartilo", value)
    end)

    SecondSeaControls.AutoSea3 = SeaUnlock:AddToggle("Auto Third Sea", Settings.AutoSea3, function(value)
        FarmRuntime.SetSecondSeaMode("AutoSea3", value)
    end)
    FightingStyles:AddDropdown("Style", FarmRuntime.FightingStyles.Names[2], Settings.Sea2FightingStyle, UI:Bind(Settings, "Sea2FightingStyle"))
    FightingStyles:AddButton("Check Requirements", function() FarmRuntime.FightingStyles.Check(Settings.Sea2FightingStyle) end)
    FightingStyles:AddButton("Buy / Equip", function() FarmRuntime.FightingStyles.Buy(Settings.Sea2FightingStyle) end)
    addFightingStyleAutoBuy(FightingStyles)
    FarmRuntime.AddGoalSections(Progress)
elseif game.PlaceId == SEA_PLACE_IDS.Third then
    local Progress = Window:AddTab({ Name = "Progression", Group = "Automation" })
    local FightingStyles = Progress:AddSection("Fighting Styles", "left")
    FightingStyles:AddDropdown("Style", FarmRuntime.FightingStyles.Names[3], Settings.Sea3FightingStyle, UI:Bind(Settings, "Sea3FightingStyle"))
    FightingStyles:AddButton("Check Requirements", function() FarmRuntime.FightingStyles.Check(Settings.Sea3FightingStyle) end)
    FightingStyles:AddButton("Buy / Equip", function() FarmRuntime.FightingStyles.Buy(Settings.Sea3FightingStyle) end)
    addFightingStyleAutoBuy(FightingStyles)
    FarmRuntime.AddGoalSections(Progress)
end

do
    local Race = Window:AddTab({ Name = "Race", Group = "Automation" })
    local Evolution = Race:AddSection("V2 / V3", "left")
    local SpecialRaces = Race:AddSection("Special Races", "left")
    local Ability = Race:AddSection("V3 Ability", "right")

    SecondSeaControls.AutoRaceV2 = Evolution:AddToggle("Auto Race V2", Settings.AutoRaceV2, function(value)
        FarmRuntime.SetSecondSeaMode("AutoRaceV2", value)
    end)
    SecondSeaControls.AutoRaceV3 = Evolution:AddToggle("Auto Race V3", Settings.AutoRaceV3, function(value)
        FarmRuntime.SetSecondSeaMode("AutoRaceV3", value)
    end)

    SecondSeaControls.AutoGhoul = SpecialRaces:AddToggle("Auto Ghoul Race", Settings.AutoGhoul, function(value)
        FarmRuntime.SetSecondSeaMode("AutoGhoul", value)
    end)
    SecondSeaControls.AutoCyborg = SpecialRaces:AddToggle("Auto Cyborg Race", Settings.AutoCyborg, function(value)
        FarmRuntime.SetSecondSeaMode("AutoCyborg", value)
    end)
    Ability:AddToggle("Auto Enable V3 Ability", Settings.AutoRaceV3Ability, function(value)
        Settings.AutoRaceV3Ability = value
        state.RaceAbilityNextAt = 0
        state.RaceAbilityMissingNotified = false
        if value and not FarmRuntime.RaceV3AbilityTool() then
            contextNotice("RaceV3AbilityMissing", "Unlock Race V3 before enabling its ability", Red, 5, 2)
        end
    end)
    Ability:AddDropdown("Trigger", { "When Ready", "Low Health", "Enemy Nearby", "While Farming" }, Settings.RaceV3AbilityTrigger, UI:Bind(Settings, "RaceV3AbilityTrigger", function()
        state.RaceAbilityNextAt = 0
    end))
    Ability:AddSlider("Health Below", 5, 100, Settings.RaceV3AbilityHealth, UI:Bind(Settings, "RaceV3AbilityHealth"), "[value]%")
    Ability:AddSlider("Enemy Range", 25, 500, Settings.RaceV3AbilityRange, UI:Bind(Settings, "RaceV3AbilityRange"), "[value] studs")
    Ability:AddSlider("Retry Delay", 2, 30, Settings.RaceV3AbilityRetryDelay, UI:Bind(Settings, "RaceV3AbilityRetryDelay"), "[value]s")
end

do
    local Islands = Window:AddTab({ Name = "Islands", Group = "World" })
    local Finder = Islands:AddSection("Island Finder", "left")
    local Search = Islands:AddSection("Server Search", "right")

    Finder:AddDropdown("Island", FarmRuntime.SpecialIslandNames, Settings.IslandFinderTarget, function(value)
        Settings.IslandFinderTarget = value
        state.IslandFinderFound = nil
        state.IslandFinderFoundName = value
        state.IslandFinderNextScanAt = 0
        if Settings.IslandFinderAutoFind then FarmRuntime.StartIslandSearch() end
    end)
    Finder:AddToggle("Selected Island Alerts", Settings.IslandFinderAlerts, function(value)
        Settings.IslandFinderAlerts = value
        state.IslandFinderNextScanAt = 0
    end)
    state.IslandFinderAutoControl = Finder:AddToggle("Auto Find Island", Settings.IslandFinderAutoFind, function(value)
        if value then
            FarmRuntime.StartIslandSearch(false)
        else
            FarmRuntime.StopIslandSearch(false, false)
        end
    end)
    Finder:AddSlider("Speed", 25, 500, Settings.IslandFinderSpeed, UI:Bind(Settings, "IslandFinderSpeed"), "[value] studs/s")
    state.IslandFinderButtonControl = Finder:AddButton("Find Island", FarmRuntime.ToggleIslandSearch)
    FarmRuntime.RefreshIslandFinderButton()
    state.TravelButtons.specialIsland = { Control = Finder:AddButton("Travel to Island", FarmRuntime.TravelSpecialIsland), Text = "Travel to Island" }
    Search:AddButton("Server Hop", function() serverHop(false) end)
    Search:AddButton("Low-Player Server", function() serverHop(true) end)
end

do
    local Mirage = Window:AddTab({ Name = "Mirage", Group = "World" })
    local Locator = Mirage:AddSection("Island", "left")
    local Objects = Mirage:AddSection("Objects", "left")
    local ESP = Mirage:AddSection("ESP", "right")
    local Moon = Mirage:AddSection("Moon", "right")

    Locator:AddButton("Travel to Mirage", function() FarmRuntime.TravelMirage(false) end)
    Locator:AddButton("Travel to Highest Point", function() FarmRuntime.TravelMirage(true) end)

    Objects:AddButton("Find Dealer", function() FarmRuntime.LocateMirageDealer(true) end)
    Objects:AddButton("Travel to Dealer", FarmRuntime.TravelMirageDealer)
    Objects:AddButton("Find Blue Gear", function() FarmRuntime.LocateBlueGear(true) end)
    Objects:AddButton("Travel to Blue Gear", FarmRuntime.CollectBlueGear)

    ESP:AddToggle("Dealer", Settings.MirageDealerESP, UI:Bind(Settings, "MirageDealerESP", function()
        state.MirageNextScanAt = 0
    end))
    ESP:AddToggle("Blue Gear", Settings.MirageGearESP, UI:Bind(Settings, "MirageGearESP", function()
        state.MirageNextScanAt = 0
    end))
    ESP:AddToggle("Boxes", Settings.MirageESPBoxes, UI:Bind(Settings, "MirageESPBoxes"))
    ESP:AddToggle("Distance", Settings.MirageESPDistance, UI:Bind(Settings, "MirageESPDistance"))
    ESP:AddColorPicker("Dealer Color", Settings.MirageDealerColor, UI:Bind(Settings, "MirageDealerColor"))
    ESP:AddColorPicker("Blue Gear Color", Settings.MirageGearColor, UI:Bind(Settings, "MirageGearColor"))

    Moon:AddButton("Check Moon", FarmRuntime.MoonStatus)
    Moon:AddButton("Face Moon", function() FarmRuntime.FaceMoon(false) end)
end

do
    local Raids = Window:AddTab({ Name = "Raids", Group = "World" })
    local RaidSetupSection = Raids:AddSection("Raid Setup", "left")
    local RaidAutomationSection = Raids:AddSection("Raid Automation", "left")
    local RaidSafetySection = Raids:AddSection("Raid Safety", "left")
    local WorldEventsSection = Raids:AddSection("World Events", "right")
    local SeaBeastSection = Raids:AddSection("Sea Beasts", "right")

    RaidSetupSection:AddDropdown("Raid Type", FarmRuntime.RaidTypes, Settings.RaidType, UI:Bind(Settings, "RaidType"))
    RaidSetupSection:AddButton("Buy Raid Chip", FarmRuntime.BuyRaidChip)
    RaidSetupSection:AddButton("Start Raid", FarmRuntime.StartRaid)
    SecondSeaControls.RaidAutoClear = RaidAutomationSection:AddToggle("Auto Clear Raid", Settings.RaidAutoClear, function(value)
        FarmRuntime.SetSecondSeaMode("RaidAutoClear", value)
    end)
    local raidTargetBossControl
    raidTargetBossControl = RaidAutomationSection:AddToggle("Target Boss on Island 5", Settings.RaidTargetBoss, UI:Bind(Settings, "RaidTargetBoss", function()
        state.SpecialData.RaidHoldPosition = nil
        if Settings.RaidAutoClear then clearSpecialFarm("RaidAutoClear") end
        task.defer(function()
            if raidTargetBossControl and raidTargetBossControl.Refresh then raidTargetBossControl:Refresh() end
        end)
    end))
    SecondSeaControls.RaidTargetBoss = raidTargetBossControl
    RaidAutomationSection:AddLabel("Uses Farm combat + travel settings")

    RaidSafetySection:AddToggle("Low Health Retreat", Settings.RaidLowHealthRetreat, function(value)
        Settings.RaidLowHealthRetreat = value
        if not value then
            state.SpecialData.RaidRetreating = nil
            state.SpecialData.RaidRetreatPosition = nil
            if state.TravelMode == "farmRaidRetreat" then stopTravel() end
        end
    end)
    RaidSafetySection:AddSlider("Retreat Health", 250, 30000, Settings.RaidRetreatHealth, UI:Bind(Settings, "RaidRetreatHealth"), "[value] HP")
    RaidSafetySection:AddSlider("Retreat Height", 100, 1500, Settings.RaidRetreatHeight, UI:Bind(Settings, "RaidRetreatHeight", function()
        state.SpecialData.RaidRetreatPosition = nil
    end), "[value] studs")

    SecondSeaControls.AutoFactory = WorldEventsSection:AddToggle("Factory Assistant", Settings.AutoFactory, function(value)
        FarmRuntime.SetSecondSeaMode("AutoFactory", value)
    end)
    SecondSeaControls.AutoPirateRaid = WorldEventsSection:AddToggle("Auto Pirate Raid", Settings.AutoPirateRaid, function(value)
        FarmRuntime.SetSecondSeaMode("AutoPirateRaid", value)
    end)

    SeaBeastSection:AddToggle("Auto Kill Sea Beasts", Settings.AutoSeaBeast, function(value)
        Settings.AutoSeaBeast = value
        if not value then
            FarmRuntime.ClearSeaBeast()
            showNotice("Sea Beast Hunter disabled", nil, 3)
        elseif FarmRuntime.NearestSeaBeast(select(3, getCharacter(LocalPlayer))) then
            showNotice("Sea Beast Hunter enabled", nil, 3)
        elseif Settings.SeaBeastAutoHunt then
            FarmRuntime.ClearSeaBeast()
            showNotice("Searching for a Sea Beast", nil, 3)
        else
            contextNotice("Waiting:SeaBeast", "Sea Beast Hunter enabled - waiting for a spawn", Muted, 4, 5)
        end
    end)
    SeaBeastSection:AddToggle("Find When None", Settings.SeaBeastAutoHunt, function(value)
        Settings.SeaBeastAutoHunt = value
        if value and Settings.AutoSeaBeast then
            FarmRuntime.ClearSeaBeast()
            showNotice("Searching for a Sea Beast", nil, 3)
        elseif value then
            contextNotice("Waiting:SeaBeastFind", "Enable Auto Kill Sea Beasts to start searching", Muted, 4, 5)
        elseif state.SeaBeastDriving or state.TravelOwner == "seaBeast" then
            FarmRuntime.ClearSeaBeast()
        end
    end)
    SeaBeastSection:AddDropdown("Weapon", { "Auto", "Blox Fruit", "Sword", "Melee" }, Settings.SeaBeastWeapon, UI:Bind(Settings, "SeaBeastWeapon", function()
        state.SeaBeastTool = nil
    end))
    SeaBeastSection:AddSlider("Hover Height", 35, 120, Settings.SeaBeastHoverHeight, UI:Bind(Settings, "SeaBeastHoverHeight"), "[value] studs")
    SeaBeastSection:AddSlider("Travel Speed", 25, 300, Settings.SeaBeastTravelSpeed, UI:Bind(Settings, "SeaBeastTravelSpeed"), "[value] studs/s")
    SeaBeastSection:AddSlider({
        name = "Skill Delay",
        min = 0.15,
        max = 1.5,
        default = Settings.SeaBeastSkillDelay,
        increment = 0.05,
        value = "[value]s",
        callback = UI:Bind(Settings, "SeaBeastSkillDelay")
    })
end

do
    local Misc = Window:AddTab({ Name = "Misc", Group = "System" })
    local ServerSection = Misc:AddSection("Server", "left")
    local FragmentSection = Misc:AddSection("Fragments", "left")
    local EnvironmentSection = Misc:AddSection("Environment", "right")
    local SessionSection = Misc:AddSection("Session", "right")
    local CodesSection = Misc:AddSection("Codes", "right")

    if game.PlaceId == SEA_PLACE_IDS.Second then
        local DealerSection = Misc:AddSection("Legendary Dealer", "left")
        DealerSection:AddToggle("Spawn Alerts", Settings.DealerTracker, UI:Bind(Settings, "DealerTracker"))
        DealerSection:AddButton("Check Dealer", function() FarmRuntime.CheckDealer(true) end)
        DealerSection:AddButton("Manager Hint", FarmRuntime.DealerHint)
        DealerSection:AddButton("Travel to Dealer", FarmRuntime.TravelDealer)
        DealerSection:AddButton("Buy Current Sword", FarmRuntime.BuyLegendarySword)
    end

    ServerSection:AddButton("Server Hop", function() serverHop(false) end)
    ServerSection:AddButton("Low-Player Server", function() serverHop(true) end)
    ServerSection:AddButton("Rejoin", function() rejoin(true) end)

    FragmentSection:AddButton("Buy Stat Refund", function()
        buyFragmentReward("Refund", "Stat Refund", 2500)
    end)
    FragmentSection:AddButton("Buy Race Reroll", function()
        buyFragmentReward("Reroll", "Race Reroll", 3000)
    end)

    CodesSection:AddButton("Claim All Codes", claimAllCodes)

    EnvironmentSection:AddToggle("Fullbright", Settings.Fullbright, function(value)
        Settings.Fullbright = value
        applyLighting()
    end)
    EnvironmentSection:AddToggle("No Fog", Settings.NoFog, function(value)
        Settings.NoFog = value
        applyLighting()
    end)
    EnvironmentSection:AddToggle("Low Quality", Settings.LowQuality, setLowQuality)

    SessionSection:AddToggle("Anti-AFK", Settings.AntiAFK, UI:Bind(Settings, "AntiAFK"))
    state.AutoRejoinControl = SessionSection:AddToggle("Rejoin Every 30 Minutes", Settings.AutoRejoin30, function(value)
        Settings.AutoRejoin30 = value
        state.AutoRejoinBusy = false
        state.AutoRejoinAt = value and (os.clock() + 1800) or 0
        if not value then
            FarmRuntime.Session.ClearPending()
            return
        end
        local cached, cacheError = FarmRuntime.Session.CacheSource()
        if not cached then
            Settings.AutoRejoin30 = false
            state.AutoRejoinAt = 0
            task.defer(function()
                if state.AutoRejoinControl and state.AutoRejoinControl.Set then
                    pcall(function() state.AutoRejoinControl:Set(false) end)
                end
            end)
            showNotice("Auto rejoin unavailable: " .. tostring(cacheError or "Source cache failed"), Red, 5)
        end
    end)
end

Window:AddSettingsTab({
    DefaultConfig = "blox-fruits",
    Group = "System",
    ShowCornerRadius = false,
    OnUnload = cleanup
})

Window:Init()
state.UIReady = true
showNotice("Blox Fruits loaded", nil, 3)
end, __bob_traceback)
local __bob_environment = (getgenv and getgenv()) or _G
__bob_environment.bob_lol_blox_fruits_boot_error = __bob_ok and nil or __bob_error
]========]
__bob_environment["bob_lol_blox_fruits_source"] = __bob_source
local __bob_loader = __bob_outer_capability("loadstring") or __bob_outer_capability("load")
if type(__bob_loader) ~= "function" then
    __bob_environment["bob_lol_blox_fruits_boot_error"] = "Runtime compiler unavailable"
    return
end
local __bob_chunk, __bob_compile_error = __bob_loader(__bob_source, "@bob_lol_blox_fruits")
if type(__bob_chunk) ~= "function" then
    __bob_environment["bob_lol_blox_fruits_boot_error"] = tostring(__bob_compile_error)
    return
end
local __bob_debug = __bob_outer_capability("debug")
local __bob_handler = tostring
if type(__bob_debug) == "table" and type(__bob_debug.traceback) == "function" then
    __bob_handler = __bob_debug.traceback
end
local __bob_ok, __bob_error = xpcall(__bob_chunk, __bob_handler)
if __bob_ok then
    __bob_environment["bob_lol_blox_fruits_boot_error"] = nil
else
    __bob_environment["bob_lol_blox_fruits_boot_error"] = tostring(__bob_error)
end
