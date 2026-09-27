
if not game:IsLoaded() then game.Loaded:Wait(); end;
local INSTANCE_KEY = "wh_combined_instance";
do
    local prev = getgenv()[INSTANCE_KEY];
    if type(prev) == "table" and type(prev.stop) == "function" then
        pcall(function() prev.stop("replaced"); end);
    end;
    getgenv()[INSTANCE_KEY] = { stop = nil };
end;

local KeySystem = (function()
    getgenv().wh_keys = getgenv().wh_keys or {
        "freekey8x1dfi19dfjs", -- used
        "freekeyu7fgdkjd89dm", -- maksim
        "freekeyk9m2p7x4v1q8", -- clear
        "freekey3b8z0v2w9k1n", -- clear
        "freekey7p4m1q9x2r8c", -- clear
        "freekeyf6t3j8k1v5m9", -- clear
        "freekey9w2x5c8v1b4n", -- clear
        "freekeyd1k8m4p7z2q0", -- clear
        "freekey4v9r1t6x3j8b", -- clear
        "freekeyz8m2c5v9k1p4", -- clear
        "freekey2q7x4w1b9r3n", -- clear
        "freekey6k1v8m3p0z5t", -- clear
        "freekeyx9r4b2n8c1v7" -- clear
    };
    local VALID_KEYS = getgenv().wh_keys;

    -- trims whitespace and ignores case, so "  Key-1 " still works
    local function keyMatches(input)
        local typed = string.lower(string.gsub(input or "", "^%s*(.-)%s*$", "%1"));
        if typed == "" then return false; end;
        for _, key in next, VALID_KEYS do
            if string.lower(string.gsub(key, "^%s*(.-)%s*$", "%1")) == typed then return true; end;
        end;
        return false;
    end;

    local KEY_ACCENT = Color3.fromRGB(150, 0, 255);
    local KEY_TEXT = Color3.fromRGB(235, 235, 240);
    local KEY_MUTED = Color3.fromRGB(150, 150, 160);
    local KEY_BG = Color3.fromRGB(20, 20, 24);
    local KEY_FIELD = Color3.fromRGB(34, 34, 40);
    local KEY_RED = Color3.fromRGB(255, 90, 90);
    local KEY_LINE = Color3.fromRGB(255, 255, 255); -- white border
    local KEY_FONT = Enum.Font.Code; -- roblox's mono face, closest to Plex
    local KEY_BORDER = 0.7; -- thin

    -- tiny self-contained menu, deliberately a lot smaller than the main linoria window
    local function buildKeyGate()
        local player = game:GetService("Players").LocalPlayer;
        local screen = Instance.new("ScreenGui");
        screen.Name = "KeyGate";
        screen.ResetOnSpawn = false;
        screen.IgnoreGuiInset = true;
        screen.DisplayOrder = 999;
        screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling;

        local host = nil;
        local ok = pcall(function() host = game:GetService("CoreGui"); end);
        if not (ok and host) then host = player and player:WaitForChild("PlayerGui"); end;
        screen.Parent = host;

        local panel = Instance.new("Frame");
        panel.Name = "Panel";
        panel.AnchorPoint = Vector2.new(0.5, 0.5);
        panel.Position = UDim2.fromScale(0.5, 0.5);
        panel.Size = UDim2.fromOffset(400, 196);
        panel.BackgroundColor3 = KEY_BG;
        panel.BorderSizePixel = 0;
        panel.Parent = screen;
        local stroke = Instance.new("UIStroke"); -- sharp corners, thin white border
        stroke.Color = KEY_LINE; stroke.Thickness = KEY_BORDER; stroke.Transparency = 0.15; stroke.Parent = panel;

        local function label(y, h, text, size, color, bold)
            local l = Instance.new("TextLabel");
            l.AnchorPoint = Vector2.new(0.5, 0);
            l.Position = UDim2.new(0.5, 0, 0, y);
            l.Size = UDim2.fromOffset(360, h);
            l.BackgroundTransparency = 1;
            l.Text = text;
            l.TextSize = size;
            l.TextColor3 = color;
            l.Font = KEY_FONT;
            l.TextXAlignment = Enum.TextXAlignment.Center;
            l.Parent = panel;
            return l;
        end;

        label(20, 24, "aimwhere, key req. ask owner", 16, KEY_TEXT, true);
        label(46, 16, "paste ur key to load script", 11, KEY_MUTED, false);

        local box = Instance.new("TextBox");
        box.Name = "KeyBox";
        box.AnchorPoint = Vector2.new(0.5, 0);
        box.Position = UDim2.new(0.5, 0, 0, 78);
        box.Size = UDim2.fromOffset(360, 34);
        box.BackgroundColor3 = KEY_FIELD;
        box.BorderSizePixel = 0;
        box.PlaceholderText = "key here";
        box.PlaceholderColor3 = KEY_MUTED;
        box.Text = "";
        box.TextSize = 13;
        box.TextColor3 = KEY_TEXT;
        box.Font = KEY_FONT;
        box.ClearTextOnFocus = true;
        box.Parent = panel;
        local boxStroke = Instance.new("UIStroke");
        boxStroke.Color = KEY_LINE; boxStroke.Thickness = KEY_BORDER; boxStroke.Transparency = 0.3; boxStroke.Parent = box;

        local button = Instance.new("TextButton");
        button.Name = "Unlock";
        button.AnchorPoint = Vector2.new(0.5, 0);
        button.Position = UDim2.new(0.5, 0, 0, 122);
        button.Size = UDim2.fromOffset(360, 34);
        button.BackgroundColor3 = Color3.fromRGB(255, 255, 255); -- white button
        button.BorderSizePixel = 0;
        button.Text = "check key & load";
        button.TextSize = 13;
        button.TextColor3 = KEY_BG;
        button.Font = KEY_FONT;
        button.AutoButtonColor = true;
        button.Parent = panel;
        local status = label(162, 16, "", 11, KEY_RED, false);
        status.Visible = false;

        return { screen = screen, box = box, button = button, status = status, panel = panel };
    end;

    local gate = buildKeyGate();
    local done = false;
    local function submit()
        if done then return; end;
        if keyMatches(gate.box.Text) then
            done = true;
        else
            gate.status.Text = "wrong one try again";
            gate.status.Visible = true;
            gate.box.Text = "";
        end;
    end;
    gate.button.MouseButton1Click:Connect(submit);
    gate.box.FocusLost:Connect(submit);
    pcall(function()
        game:GetService("UserInputService").InputBegan:Connect(function(input)
            if input and input.UserInputType == Enum.UserInputType.Keyboard
                and (input.KeyCode == Enum.KeyCode.Return or input.KeyCode == Enum.KeyCode.KeypadEnter) then
                submit();
            end;
        end);
    end);

    local deadline = os.clock() + 300;
    while not done and os.clock() < deadline do task.wait(0.05); end;
    gate.screen:Destroy();
    if not done then
        warn("aimwhere: key required");
        return nil;
    end;
    task.wait(2); -- short beat so the key menu is gone before the main menu pops
    return {
        keys = VALID_KEYS,
        matches = keyMatches,
        build = buildKeyGate,
    };
end)();

if not KeySystem then
    return warn("aimwhere: key required");
end;

local cloneref = cloneref or function(i) return i; end;
local clonefunction = clonefunction or function(f: (...any) -> ...any) return f; end;
local newcclosure = newcclosure or clonefunction;
local executor = identifyexecutor and identifyexecutor() or "Your executor";

if not (hookfunction and Drawing) then
    return warn(executor .. " is missing " .. (not hookfunction and "hookfunction " or "") .. (not Drawing and "Drawing " or ""));
end;

local RS = cloneref(game:GetService("ReplicatedStorage"));
local Players = cloneref(game:GetService("Players"));
local UIS = cloneref(game:GetService("UserInputService"));
local VIM = cloneref(game:GetService("VirtualInputManager"));
local RunService = cloneref(game:GetService("RunService"));

local plr = Players.LocalPlayer;
local Connections = {};
local Running = true;

local cam = workspace.CurrentCamera;
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    cam = workspace.CurrentCamera;
end);

--======================== SETTINGS ========================
getgenv().wh_silent_aim = true;
getgenv().wh_fov_size = 200;
-- 205m is hardcoded: aiming has NO distance limit, only the triggerbot stops shooting past it
local MAX_TRIGGER_DISTANCE = 205; -- metres
getgenv().wh_whitelist = {}; -- { [playerName] = true } never targeted by any combat feature
getgenv().wh_wallcheck = false;
getgenv().wh_aim_unseen = true; -- fire at the locked target even when no part passes the visibility raycast
getgenv().wh_fov_toggle = true;
getgenv().wh_fov_center = true;
getgenv().wh_fov_color = Color3.fromRGB(150, 0, 255); -- purple
getgenv().wh_tracers = true;
getgenv().wh_tracer_color = Color3.fromRGB(150, 0, 255);
-- lighting control (full ambient/outdoor/fog/brightness/exposure/effects control)
getgenv().wh_lighting_enabled = false;
getgenv().wh_lighting_ambient_enabled = true; -- master checkbox for the ambient color pickers
getgenv().wh_lighting_ambient = Color3.new(1, 1, 1);
getgenv().wh_lighting_outdoor_ambient = Color3.new(1, 1, 1);
getgenv().wh_lighting_brightness = 3;
getgenv().wh_lighting_clocktime = 14;
getgenv().wh_lighting_fog_enabled = true; -- master checkbox for fog controls
getgenv().wh_lighting_fog_end = 100000;
getgenv().wh_lighting_fog_start = 0;
getgenv().wh_lighting_fog_color = Color3.fromRGB(191, 191, 191); -- roblox default fog color
getgenv().wh_lighting_exposure = 0; -- exposure compensation (-3 to 3)
getgenv().wh_lighting_global_shadows = false;
getgenv().wh_lighting_post_effects = false;
getgenv().wh_lighting_atmosphere = false;
getgenv().wh_lighting_env_diffuse = 1;
getgenv().wh_lighting_env_specular = 1;
getgenv().wh_lighting_celestial_intensity = 1;
getgenv().wh_lighting_ambient_intensity = 1;

getgenv().wh_target_npcs = true;
getgenv().wh_tracer_beams = true;
getgenv().wh_tracer_barrel = true; -- start tracers at the gun's barrel (Silencer/Muzzle/Barrel part)
getgenv().wh_beam_color = Color3.fromRGB(255, 170, 0); -- orange
getgenv().wh_beam_lifetime = 0.6;

getgenv().wh_third_person = false;
getgenv().wh_third_person_distance = 6; -- studs behind the character
getgenv().wh_remove_arms = false; -- hides the weapon rig's arms/hands
getgenv().wh_weapon_charm = false; -- reskins the weapon in your view
getgenv().wh_weapon_material = "Neon"; -- material applied to the weapon
getgenv().wh_weapon_color = Color3.fromRGB(255, 0, 90); -- colour applied to the weapon
getgenv().wh_weapon_reflectance = 0; -- 0 = matte, 1 = mirror
getgenv().wh_weapon_transparency = 0; -- 0 = solid
getgenv().wh_wc_speed = 22;
getgenv().wh_fov = 70; -- camera field of view
getgenv().wh_fov_enabled = false;
getgenv().wh_wallclimb = false;

getgenv().wh_head_expand = false;
getgenv().wh_head_size = 2;
getgenv().wh_head_transparency = 0.5;

getgenv().wh_ragebot = false; -- 360 targeting (skip FOV check)
getgenv().wh_triggerbot = false;
getgenv().wh_trigger_delay = 0.12; -- seconds between auto shots
getgenv().wh_tpkill = false;

getgenv().wh_debug_hook = false; -- prints what the bullet hook decides on every shot
getgenv().wh_hitlogs = false; -- notify per shot: hit / kill / miss


-- player ESP (ported from esp.lua)
getgenv().wh_esp_toggle = true;
getgenv().wh_esp_npcs = true;
getgenv().wh_esp_players_only = false; -- when true, only real players get an ESP box
getgenv().wh_esp_ignore_bots = false; -- skip characters living in workspace:IngameBots
getgenv().wh_esp_corpses = true; -- also draw esp on dead bodies in workspace:Containers
getgenv().wh_esp_corpses_hide_name = false; -- corpse name row toggle
getgenv().wh_esp_maxdistance = 200; -- metres (0 = infinite)
getgenv().wh_esp_font = "Plex"; -- UI / System / Plex / Monospace
getgenv().wh_esp_fontsize = 13;
getgenv().wh_esp_box = true;
getgenv().wh_esp_box_color = Color3.new(1, 1, 1);
getgenv().wh_esp_box_thickness = 2; -- border width in pixels (0 hides the border)
getgenv().wh_esp_box_fill = false;
getgenv().wh_esp_box_fill_color = Color3.new(1, 1, 1);
getgenv().wh_esp_box_fill_transparency = 0.5;
getgenv().wh_esp_box_outline = false;
getgenv().wh_esp_box_outline_color = Color3.new();
getgenv().wh_esp_box_outline_thickness = 4;
getgenv().wh_esp_names = true;
getgenv().wh_esp_names_color = Color3.new(1, 1, 1);
getgenv().wh_esp_names_outline = true;
getgenv().wh_esp_displayname = false;
getgenv().wh_esp_displayname_color = Color3.new(1, 1, 1);
getgenv().wh_esp_distance = true;
getgenv().wh_esp_distance_color = Color3.new(1, 1, 1);
getgenv().wh_esp_weapon = true;
getgenv().wh_esp_weapon_color = Color3.new(1, 1, 1);
getgenv().wh_esp_health = true;
getgenv().wh_esp_health_text = false;
getgenv().wh_esp_health_color_top = Color3.new(0, 1, 0);
getgenv().wh_esp_health_color_bottom = Color3.new(1, 0, 0);
getgenv().wh_esp_health_thickness = 2;
getgenv().wh_esp_charms = false; -- CS2 style through-wall highlight
getgenv().wh_esp_charms_visible_color = Color3.fromRGB(120, 255, 120); -- colour when a body part is visible
getgenv().wh_esp_charms_hidden_color = Color3.fromRGB(255, 70, 70); -- colour when nothing is visible
getgenv().wh_esp_charms_transparency = 0.5;

-- gun mods (each one is independent, see the GunMods table)
getgenv().wh_no_recoil = true;
getgenv().wh_no_camera_rising = true;
getgenv().wh_no_spread = true;
getgenv().wh_no_bulletdrop = true;

-- distance conversion shared by the ESP labels and the silent-aim max-distance filter
local STUDS_PER_METER = 3.57;

-- every Drawing this script owns, so unload can wipe them all in one go
local drawings = {};
local function createObj(kind, args)
    local obj = Drawing.new(kind);
    for i, v in next, args do obj[i] = v; end;
    table.insert(drawings, obj);
    return obj;
end;
local function removeDrawings()
    for _, o in next, drawings do pcall(function() o:Remove(); end); end;
    table.clear(drawings);
end;

-- Roblox rejects non-finite numbers in Vector2/Vector3/Color3 ("finite number
-- expected"), and WorldToViewportPoint hands back inf/NaN for geometry behind or on
-- the camera plane. NaN also fails every < / > test, so it would otherwise slip
-- through the off-screen checks and reach Vector2.new.
local function isFinite(v)
    return v == v and v > -math.huge and v < math.huge;
end;

local function isFiniteVec2(v)
    return v ~= nil and isFinite(v.X) and isFinite(v.Y);
end;

-- point the circle sits at + targets are measured from: screen center or cursor
local function centerPoint()
    if getgenv().wh_fov_center then
        return cam.ViewportSize / 2;
    end;
    return UIS:GetMouseLocation();
end;

-- cursor position (Drawing space = window space, no inset correction needed)

-- WorldToViewportPoint coords are already in Drawing space.
-- Points behind / on the camera plane project to inf or NaN, which Vector2.new rejects,
-- so they are mapped to a far-away position: the target simply never wins the FOV check.
local function toScreen(vp)
    if not (isFinite(vp.X) and isFinite(vp.Y)) then
        return Vector2.new(math.huge, math.huge);
    end;
    return Vector2.new(vp.X, vp.Y);
end;

--======================== PLAYER ESP (BillboardGui) ========================
-- Everything is drawn with Roblox GUI (one BillboardGui per target) instead of Drawing
-- objects: the box, the fill/outline, the name, distance, weapon and the health bar are
-- all children of the billboard, which is anchored on the character and sized to match
-- its projected bounding box. Through-wall look comes free with AlwaysOnTop.
-- [model] = { model, hum, head, player, parts, gui... }  (also feeds silent aim + head expander)
local espObjects = {};  -- [model] = entry
local espPlayer = {};   -- [Player] = model  (one box per player, never two)
local watchedPlayers = setmetatable({}, { __mode = "k" });
local headOrig = {}; -- [model] = { size, transparency } originals for head expander

-- Drawing.Fonts is missing on some executors, so fall back to the raw numeric values
local DrawingFonts = Drawing.Fonts or { UI = 1, System = 2, Plex = 3, Monospace = 4 };

local ESP_FONTS = { System = 1, UI = 2, Plex = 3, Monospace = 4 };

-- the 8 corners of a bounding box, used to project it to screen space
local VERTICES = {
    Vector3.new(-1, -1, -1), Vector3.new(-1, 1, -1), Vector3.new(-1, 1, 1), Vector3.new(-1, -1, 1),
    Vector3.new(1, -1, -1), Vector3.new(1, 1, -1), Vector3.new(1, 1, 1), Vector3.new(1, -1, 1),
};

-- used only by the charms to decide visible vs hidden colour, so it keeps its own params
local charmRP = RaycastParams.new();
charmRP.FilterType = Enum.RaycastFilterType.Exclude;
charmRP.IgnoreWater = true;

-- true when at least one ray from the camera reaches the target's head
local function charmTargetVisible(o, camPos)
    local part = o.head;
    if not (part and part.Parent) then return false; end;
    charmRP.FilterDescendantsInstances = { plr.Character, cam };
    local result = workspace:Raycast(camPos, part.Position - camPos, charmRP);
    if not result then return true; end;
    return result.Instance:IsDescendantOf(part.Parent);
end;

local function isBodyPart(name)
    return name == "Head" or name:find("Torso") or name:find("Leg") or name:find("Arm");
end;

-- ONLY the character's own rig parts are used. Anything nested inside the model
-- (Accessory / Backpack / Tool meshes, weapon parts, hats) is deliberately skipped:
-- those parts can sit far away from the body, which stretched the box into the sky.
local function bodyPartsOf(model)
    local list = {};
    for _, part in next, model:GetChildren() do
        if part:IsA("BasePart") and isBodyPart(part.Name) then
            list[#list + 1] = part;
        end;
    end;
    -- odd rigs: fall back to the head/root so the box is still snug instead of giant
    if #list == 0 then
        for _, name in next, { "Head", "HumanoidRootPart" } do
            local part = model:FindFirstChild(name);
            if part and part:IsA("BasePart") then list[#list + 1] = part; end;
        end;
    end;
    return list;
end;

-- world-space bounds of the rig: returns (cframe, size, center)
-- component-wise min/max, written out instead of Vector3.zero.Min / .Max, which are not
-- part of the real Vector3 api and can throw depending on the client
local function v3min(a, b)
    return Vector3.new(math.min(a.X, b.X), math.min(a.Y, b.Y), math.min(a.Z, b.Z));
end

local function v3max(a, b)
    return Vector3.new(math.max(a.X, b.X), math.max(a.Y, b.Y), math.max(a.Z, b.Z));
end

local function getBoundingBox(parts)
    local min, max;
    for i = 1, #parts do
        local part = parts[i];
        if part.Parent then
            local cframe, size = part.CFrame, part.Size;
            min = v3min(min or cframe.Position, (cframe - size * 0.5).Position);
            max = v3max(max or cframe.Position, (cframe + size * 0.5).Position);
        end;
    end;
    if not (min and max) then return nil; end;
    local center = (min + max) * 0.5;
    return CFrame.new(center, Vector3.new(center.X, center.Y, max.Z)), max - min, center;
end;

-- projected screen bounds: returns (minX, minY, maxX, maxY) or nil when unprojectable
local function projectBounds(cframe, size)
    local minX, minY, maxX, maxY;
    for _, v in next, VERTICES do
        local vp = cam:WorldToViewportPoint((cframe + size * 0.5 * v).Position);
        -- geometry behind the camera projects to inf/NaN, which Vector2 would reject
        if not (isFinite(vp.X) and isFinite(vp.Y)) then return nil; end;
        if minX then
            if vp.X < minX then minX = vp.X; end;
            if vp.X > maxX then maxX = vp.X; end;
            if vp.Y < minY then minY = vp.Y; end;
            if vp.Y > maxY then maxY = vp.Y; end;
        else
            minX, maxX, minY, maxY = vp.X, vp.X, vp.Y, vp.Y;
        end;
    end;
    if not (minX and maxX) then return nil; end;
    return minX, minY, maxX, maxY;
end;

-- A model is only a valid ESP target if it is a real character rig: a Humanoid plus a
-- Head and a HumanoidRootPart as DIRECT children. This rejects the junk models that used
-- to get their own floating box (spawn dummies, kill/death clones, map models, wrappers).
local function isCharacterModel(model)
    if not (model and model:IsA("Model") and model.Parent) then return false; end;
    local hum = model:FindFirstChildOfClass("Humanoid");
    if not hum then return false; end;
    local head = model:FindFirstChild("Head");
    local root = model:FindFirstChild("HumanoidRootPart");
    if not (head and head:IsA("BasePart")) then return false; end;
    if not (root and root:IsA("BasePart")) then return false; end;
    return true;
end;

-- nothing nested inside an already-tracked character gets its own entry
-- (accessories, tools, backpacks and view models are all children of something)
local function hasTrackedAncestor(model)
    local p = model.Parent;
    while p and p ~= workspace do
        if espObjects[p] then return true; end;
        if p == cam then return true; end; -- view models live under the camera
        p = p.Parent;
    end;
    return false;
end;

local function containersFolder()
    local c = workspace:FindFirstChild("Containers");
    return c and c:IsA("Folder") and c or c and c:IsA("Model") and c or nil;
end

local function isCorpseModel(model)
    if not (model and model:IsA("Model")) then return false; end;
    local c = containersFolder();
    if c and model:IsDescendantOf(c) and string.find(string.lower(model.Name), "dead", 1, true) then
        return true;
    end;
    return false;
end;

-- corpses can be loose models (no root part), so they only need a humanoid + some parts
local function isCorpseRig(model)
    if not model:FindFirstChildOfClass("Humanoid") then return false; end;
    return #bodyPartsOf(model) > 0;
end

local function getHeldWeapon(model)
    local tool = model:FindFirstChildOfClass("Tool") or model:FindFirstChild("EquippedTool");
    return tool and tool.Name or "None";
end;

local function newLabel(parent, opts)
    local l = Instance.new("TextLabel");
    l.BackgroundTransparency = 1;
    l.Size = UDim2.fromOffset(220, 16);
    l.Font = Enum.Font.Code;
    l.TextSize = getgenv().wh_esp_fontsize or 13;
    l.TextColor3 = Color3.new(1, 1, 1);
    l.TextStrokeTransparency = 0;
    l.TextXAlignment = Enum.TextXAlignment.Center;
    l.Parent = parent;
    for k, v in next, opts or {} do l[k] = v; end;
    return l;
end;

-- Builds the billboard for one character. The gui is sized to the character box PLUS a
-- padding band above and below, and every element is positioned in pixels relative to the
-- gui's centre -- that keeps the box locked on the character while name/distance/weapon
-- sit inside the gui's own rect (a BillboardGui clips whatever falls outside it, which is
-- what made those texts invisible).
-- A BillboardGui CLIPS whatever falls outside its own rect, so the gui is made wide and
-- tall enough for the text (two rows above the box, two below) while the box frame stays
-- centred in it -- centring means widening the gui does not move the box off the player.
local ESP_PAD = 36;     -- pixels reserved above AND below the box
local ESP_TEXT_W = 240; -- minimum gui width so the name/weapon text is never squeezed

local function buildESPGui(model, root)
    local gui = Instance.new("BillboardGui");
    gui.Name = "ESPBox";
    gui.Adornee = root;
    gui.AlwaysOnTop = true;
    gui.Size = UDim2.fromOffset(10, 10);
    gui.StudsOffsetWorldSpace = Vector3.zero;
    gui.ClipsDescendants = false; -- safety net: never clip a label
    gui.Parent = model;

    local outline = Instance.new("Frame");
    outline.Name = "Outline";
    outline.AnchorPoint = Vector2.new(0.5, 0.5);
    outline.Position = UDim2.fromScale(0.5, 0.5);
    outline.Size = UDim2.fromOffset(0, 0);
    outline.BackgroundTransparency = 1;
    outline.BorderSizePixel = 0;
    outline.BorderMode = Enum.BorderMode.Inset;
    outline.BorderColor3 = Color3.new();
    outline.ZIndex = 3;
    outline.Parent = gui;

    local box = Instance.new("Frame");
    box.Name = "Box";
    box.AnchorPoint = Vector2.new(0.5, 0.5);
    box.Position = UDim2.fromScale(0.5, 0.5);
    box.Size = UDim2.fromOffset(0, 0);
    box.BackgroundTransparency = 1;
    box.BorderSizePixel = 0;
    box.BorderColor3 = Color3.new(1, 1, 1);
    box.ZIndex = 4;
    box.Parent = gui;

    local fill = Instance.new("Frame");
    fill.Name = "Fill";
    fill.AnchorPoint = Vector2.new(0.5, 0.5);
    fill.Position = UDim2.fromScale(0.5, 0.5);
    fill.Size = UDim2.fromOffset(0, 0);
    fill.BackgroundColor3 = Color3.new(1, 1, 1);
    fill.BackgroundTransparency = 1;
    fill.BorderSizePixel = 0;
    fill.ZIndex = 2;
    fill.Parent = gui;

    -- health bar on the left edge of the box
    local hpBg = Instance.new("Frame");
    hpBg.Name = "HealthBg";
    hpBg.AnchorPoint = Vector2.new(1, 0);
    hpBg.Position = UDim2.new(0.5, 0, 0.5, 0);
    hpBg.Size = UDim2.fromOffset(3, 0);
    hpBg.BackgroundColor3 = Color3.new(1, 0, 0);
    hpBg.BackgroundTransparency = 0.35;
    hpBg.BorderSizePixel = 0;
    hpBg.ZIndex = 5;
    hpBg.Parent = gui;

    local hpFill = Instance.new("Frame");
    hpFill.Name = "HealthFill";
    hpFill.AnchorPoint = Vector2.new(1, 1);
    hpFill.Position = UDim2.fromScale(1, 1);
    hpFill.Size = UDim2.fromScale(1, 0);
    hpFill.BackgroundColor3 = Color3.new(0, 1, 0);
    hpFill.BackgroundTransparency = 0;
    hpFill.BorderSizePixel = 0;
    hpFill.ZIndex = 6;
    hpFill.Parent = hpBg;

    local displayName = newLabel(gui, {
        Name = "DisplayName", AnchorPoint = Vector2.new(0.5, 1),
        Position = UDim2.new(0.5, 0, 0.5, 0), ZIndex = 7,
    });
    local nameLabel = newLabel(gui, {
        Name = "Name", AnchorPoint = Vector2.new(0.5, 1),
        Position = UDim2.new(0.5, 0, 0.5, 0), ZIndex = 7,
    });
    local distLabel = newLabel(gui, {
        Name = "Dist", AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0), ZIndex = 7,
    });
    local weaponLabel = newLabel(gui, {
        Name = "Weapon", AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0), ZIndex = 7,
    });
    local hpLabel = newLabel(gui, {
        Name = "HealthText", AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0), ZIndex = 7,
    });

    return {
        gui = gui, box = box, fill = fill, outline = outline,
        hpBg = hpBg, hpFill = hpFill, boxW = 0, boxH = 0,
        name = nameLabel, displayName = displayName,
        dist = distLabel, weapon = weaponLabel, hpText = hpLabel,
    };
end;

-- gui sizes are recomputed from the projected character box every frame
local function layoutESP(ui, boxW, boxH)
    if ui.boxW == boxW and ui.boxH == boxH then return; end;
    ui.boxW, ui.boxH = boxW, boxH;
    local half = boxH / 2;
    -- wide + tall enough for the text, and the box stays centred inside it
    ui.gui.Size = UDim2.fromOffset(math.max(boxW, ESP_TEXT_W), boxH + ESP_PAD * 2);
    ui.box.Size = UDim2.fromOffset(boxW, boxH);
    ui.outline.Size = UDim2.fromOffset(boxW, boxH);
    ui.fill.Size = UDim2.fromOffset(boxW, boxH);
    -- one row per label, anchored to the box edges
    ui.name.Position = UDim2.new(0.5, 0, 0.5, -half);
    ui.displayName.Position = UDim2.new(0.5, 0, 0.5, -half - 16);
    ui.dist.Position = UDim2.new(0.5, 0, 0.5, half + 1);
    ui.weapon.Position = UDim2.new(0.5, 0, 0.5, half + 17);
    ui.hpBg.Position = UDim2.new(0.5, -boxW / 2, 0.5, -half);
    ui.hpBg.Size = UDim2.fromOffset(3, boxH);
    ui.hpText.Position = UDim2.new(0.5, -boxW / 2 - 4, 0.5, 0);
end;

-- what is actually being drawn right now: name, owner, part count and world box size.
-- a box far bigger than a character (or a model you don't recognise) shows up here.
local function espReport()
    local lines, count, seen = {}, 0, {};
    for model, o in next, espObjects do
        if not seen[model.Name] then
            seen[model.Name] = true;
            count = count + 1;
            local kind = o.isCorpse and "corpse" or (o.player and o.player.Name or (o.isBot and "bot" or "npc"));
            local _, size, center = getBoundingBox(o.parts); -- getBoundingBox returns (cframe, size, center)
            local sizeText = size and string.format("%.0fx%.0fx%.0f", size.X, size.Y, size.Z) or "?";
            if count <= 8 then
                lines[#lines + 1] = string.format("%s [%s] parts=%d box=%s", model.Name, kind, #o.parts, sizeText);
            end;
        end;
    end;
    return string.format("ESP: %d tracked | %s", count, table.concat(lines, " | "));
end;

local function ApplyESP(model)
    if not Running then return; end;
    if not model or not model:IsA("Model") then return; end;
    if espObjects[model] then return; end;

    local corpse = isCorpseModel(model);
    if corpse then
        if not getgenv().wh_esp_corpses then return; end;
        if not isCorpseRig(model) then return; end;
    else
        if not isCharacterModel(model) then return; end;
        if hasTrackedAncestor(model) then return; end;
    end;

    -- never draw on yourself, your own gear, or the view model
    if plr.Character and (model == plr.Character or model:IsDescendantOf(plr.Character)) then return; end;
    if model:IsDescendantOf(plr.Character) then return; end;

    local player = not corpse and Players:GetPlayerFromCharacter(model) or nil;
    if not corpse then
        if player == plr then return; end;
        if not player then
            if not getgenv().wh_esp_npcs then return; end;
            if getgenv().wh_esp_players_only then return; end;
        end;
        -- bots live in the IngameBots folder and can be filtered out entirely
        if getgenv().wh_esp_ignore_bots and model:IsDescendantOf(bots) then return; end;
    end;

    -- ONE box per player. Games often keep a second model around for the same player
    -- (a clone, a shadow, a death ragdoll); whichever arrives second is dropped so the
    -- same person can never be boxed twice.
    if player then
        local existing = espPlayer[player];
        if existing and existing ~= model then
            local keepExisting = (player.Character ~= model) and (player.Character == existing);
            if keepExisting then return; end;
            CleanupESP(existing); -- the new one is the live character: it wins
        end;
        espPlayer[player] = model;
    end;

    local hum = model:FindFirstChildOfClass("Humanoid");
    local head = model:FindFirstChild("Head") or model.PrimaryPart or hum and hum.Parent;
    local root = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart or head;
    if not (hum and head) then return; end;

    espObjects[model] = {
        model = model, hum = hum, head = head, root = root, player = player, isCorpse = corpse,
        parts = bodyPartsOf(model), isBot = model:IsDescendantOf(bots),
        highlight = nil, gunCache = "", gunCacheTime = 0,
        ui = buildESPGui(model, root),
    };
end;

local function CleanupESP(model)
    local o = espObjects[model];
    if not o then return; end;
    if o.ui and o.ui.gui then pcall(function() o.ui.gui:Destroy(); end); end;
    if o.highlight then pcall(function() o.highlight:Destroy(); end); end;
    if o.player and espPlayer[o.player] == model then espPlayer[o.player] = nil; end;
    espObjects[model] = nil;
    headOrig[model] = nil;
end;

local function UpdateESP()
    if not Running then return; end;
    local g = getgenv();
    local enabled = g.wh_esp_toggle;
    local showNpcs = g.wh_esp_npcs;
    local maxMeters = g.wh_esp_maxdistance or 0;
    local camPos = cam.CFrame.Position;
    local font = ESP_FONTS[g.wh_esp_font] or ESP_FONTS.Plex;
    local fontSize = g.wh_esp_fontsize or 13;

    -- stale models are swept first, so the pass below can assume every entry is live
    for model in next, espObjects do
        if not model:IsDescendantOf(workspace) then
            CleanupESP(model);
        end;
    end;

    for model, o in next, espObjects do
        local ui = o.ui;

        -- a respawn rebuilds the rig: refresh the cached humanoid/head/parts, otherwise the
        -- box keeps being measured from destroyed parts (which is what made it drift).
        -- The entry is kept even while the rig is missing so it comes back on respawn.
        if not o.hum.Parent or not o.head.Parent or not o.root.Parent then
            local hum = model:FindFirstChildOfClass("Humanoid");
            local head = hum and model:FindFirstChild("Head");
            local root = hum and model:FindFirstChild("HumanoidRootPart");
            if hum and head and root then
                o.hum, o.head, o.root = hum, head, root;
                o.parts = bodyPartsOf(model);
                if ui then ui.gui.Adornee = root; ui.boxW, ui.boxH = -1, -1; end; -- force a relayout
            end;
        end;

        local show = enabled and o.hum.Parent ~= nil and o.head.Parent ~= nil
            and (o.hum.Health > 0 or o.isCorpse);
        if show and o.isCorpse and not g.wh_esp_corpses then show = false; end;
        if show and o.isBot and g.wh_esp_ignore_bots then show = false; end;
        if show and o.player == nil and (not showNpcs or g.wh_esp_players_only) then show = false; end;
        if show and o.player and o.player == plr then show = false; end;

        local boxW, boxH;
        if show then
            local cframe, size, center = getBoundingBox(o.parts);
            if not cframe then
                show = false;
            else
                local minX, minY, maxX, maxY = projectBounds(cframe, size);
                if not minX then
                    show = false; -- behind the camera / unprojectable
                elseif maxX < 0 or minX > cam.ViewportSize.X or maxY < 0 or minY > cam.ViewportSize.Y then
                    show = false; -- fully off screen
                else
                    boxW = math.max(math.floor(maxX - minX), 1);
                    boxH = math.max(math.floor(maxY - minY), 1);
                    -- pin the billboard to the world centre of the box, size it in pixels
                    -- and lay the elements out around it
                    layoutESP(ui, boxW, boxH);
                    ui.gui.StudsOffsetWorldSpace = center - o.root.Position;
                end;
            end;
        end;

        if show and maxMeters > 0 then
            local studs = maxMeters * STUDS_PER_METER;
            if (o.head.Position - camPos).Magnitude > studs then show = false; end;
        end;

        if ui then ui.gui.Enabled = show; end;
        if o.highlight then o.highlight.Enabled = show and g.wh_esp_charms; end;
        if show then

            -- colours / styles
            ui.box.BorderColor3 = g.wh_esp_box_color;
            ui.box.BorderSizePixel = g.wh_esp_box and math.max(math.floor(g.wh_esp_box_thickness or 2), 1) or 0;
            ui.box.Visible = g.wh_esp_box;
            ui.fill.Visible = g.wh_esp_box_fill;
            ui.fill.BackgroundColor3 = g.wh_esp_box_fill_color;
            ui.fill.BackgroundTransparency = g.wh_esp_box_fill_transparency;
            ui.outline.Visible = g.wh_esp_box_outline and g.wh_esp_box_outline_thickness > 0;
            ui.outline.BorderColor3 = g.wh_esp_box_outline_color;
            ui.outline.BorderSizePixel = math.max(math.floor(g.wh_esp_box_outline_thickness or 4), 0);

            -- charms: one colour while something is visible, another when fully hidden
            if g.wh_esp_charms then
                if not o.highlight then
                    o.highlight = Instance.new("Highlight");
                    o.highlight.Name = "ESPCharms";
                    o.highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop;
                    o.highlight.OutlineTransparency = 1; -- no outline, the fill is the charm
                    o.highlight.Parent = model;
                end;
                local seen = charmTargetVisible(o, camPos);
                o.highlight.FillColor = seen and g.wh_esp_charms_visible_color or g.wh_esp_charms_hidden_color;
                o.highlight.FillTransparency = math.clamp(g.wh_esp_charms_transparency or 0.5, 0, 1);
            end;

            -- texts: one row each, corpses are labelled "Dead Body"
            for _, key in next, { "name", "displayName", "dist", "weapon", "hpText" } do
                local l = ui[key];
                l.Font = font;
                l.TextSize = fontSize;
                l.TextStrokeTransparency = g.wh_esp_names_outline and 0 or 1;
            end;

            ui.name.Text = o.isCorpse and "Dead Body" or (o.player and o.player.Name or model.Name);
            ui.name.TextColor3 = g.wh_esp_names_color;
            ui.name.Visible = g.wh_esp_names and (o.isCorpse or not g.wh_esp_corpses_hide_name);

            local showDisplay = g.wh_esp_displayname and o.player
                and not o.isCorpse and o.player.DisplayName ~= o.player.Name;
            ui.displayName.Text = showDisplay and o.player.DisplayName or "";
            ui.displayName.TextColor3 = g.wh_esp_displayname_color;
            ui.displayName.Visible = showDisplay and g.wh_esp_names;

            local meters = (o.head.Position - camPos).Magnitude / STUDS_PER_METER;
            ui.dist.Text = math.floor(meters + 0.5) .. "m";
            ui.dist.TextColor3 = g.wh_esp_distance_color;
            ui.dist.Visible = g.wh_esp_distance;

            if os.clock() - o.gunCacheTime > 0.5 then
                o.gunCacheTime = os.clock();
                o.gunCache = getHeldWeapon(model);
            end;
            ui.weapon.Text = o.gunCache;
            ui.weapon.TextColor3 = g.wh_esp_weapon_color;
            ui.weapon.Visible = g.wh_esp_weapon and not o.isCorpse;

            -- health bar
            local pct = math.clamp(o.hum.Health / math.max(o.hum.MaxHealth, 1), 0, 1);
            if not isFinite(pct) then pct = 0; end;
            local col = g.wh_esp_health_color_top:Lerp(g.wh_esp_health_color_bottom, 1 - pct);
            ui.hpBg.Visible = g.wh_esp_health;
            ui.hpBg.Size = UDim2.fromOffset(math.max(math.floor(g.wh_esp_health_thickness or 2), 1), ui.boxH);
            ui.hpFill.Size = UDim2.new(1, 0, pct, 0);
            ui.hpFill.BackgroundColor3 = col;
            ui.hpText.Text = math.floor(o.hum.Health) .. " hp";
            ui.hpText.TextColor3 = col;
            ui.hpText.Visible = g.wh_esp_health_text;
            ui.hpText.Position = UDim2.new(0.5, -(ui.boxW / 2) - 4, 0.5, 0);
        end;
    end;
end;

--======================== SILENT AIM CORE ========================
local sph, bots = workspace:FindFirstChild("SPH_Workspace"), workspace:FindFirstChild("IngameBots");
if not (sph and bots) then
    return warn("Script needs updating (SPH_Workspace / IngameBots not found)");
end;

local s, ac = pcall(require, RS.SPH_Assets.Modules:QueryDescendants("ModuleScript>ModuleScript:not(ModuleScript#Signal, ModuleScript#Table, ModuleScript#TypeDefinitions, ModuleScript#TypeMarshaller)")[1]);
if not s then
    return warn(executor .. " returned an error while trying to require RS.SPH_Assets.Modules...:\n" .. ac);
end;

-- world raycast params for visibility / peek-spot checks (excludes own char + SPH cover mesh)
local rp = RaycastParams.new();
rp.FilterType = Enum.RaycastFilterType.Exclude;
rp.IgnoreWater = true;

--======================== VISIBILITY ========================
-- A part counts as visible from `origin` if a clear line reaches any part of it.
-- Only TWO raycasts per part are needed:
--   1. the point of the part's box closest to us, i.e. the most exposed pixel of it,
--      so a target peeking an arm or a shoulder out of cover is still detected;
--   2. its centre, for targets with a gap straight through them.
-- This replaced the old 1 + 8 sample version, which fired up to 9 raycasts per body part:
-- on a server where most players sit behind cover that is ~30 raycasts per player per
-- scan, several times per frame, and it was the reason ragebot stuttered. The filter
-- table is reused too, so the hot path allocates nothing per call.
local visFilter = { plr.Character, sph };
rp.FilterDescendantsInstances = visFilter;
local filterSetFor = visFilter[1];

local RAY_BUDGET = 900; -- hard cap on raycasts per scan, see scanTargets
local raysUsed = 0;

local isVisible = function(part, origin)
    local char = plr.Character;
    if not (char and part) then return false, nil, nil; end;

    -- Roblox copies FilterDescendantsInstances when the property is assigned, so editing
    -- the table afterwards does nothing: it has to be re-assigned whenever it changes
    -- (respawn, weapon swap, and it also stops pointing at a destroyed character)
    if filterSetFor ~= char or visFilter[2] ~= sph then
        visFilter[1], visFilter[2] = char, sph;
        rp.FilterDescendantsInstances = visFilter;
        filterSetFor = char;
    end;

    local parent = part.Parent;
    local function blocked(pt)
        raysUsed = raysUsed + 1;
        local ok, result = pcall(workspace.Raycast, workspace, origin, pt - origin, rp);
        -- a raycast that errors (a destroyed instance in the filter, a dead part, ...) is
        -- treated as "nothing in the way" rather than blowing up the whole scan
        if not ok or not result then return false, nil, nil; end;
        if result.Instance:IsDescendantOf(parent) then
            return false, result.Instance, result.Position;
        end;
        return true, result.Instance, result.Position;
    end;

    -- closest point of the (oriented) box to us, computed in the part's local space
    local half = part.Size * 0.5;
    local lp = part.CFrame:PointToObjectSpace(origin);
    local cx = lp.X < -half.X and -half.X or (lp.X > half.X and half.X or lp.X);
    local cy = lp.Y < -half.Y and -half.Y or (lp.Y > half.Y and half.Y or lp.Y);
    local cz = lp.Z < -half.Z and -half.Z or (lp.Z > half.Z and half.Z or lp.Z);
    local near = part.CFrame:PointToWorldSpace(Vector3.new(cx, cy, cz));

    local blockedNow, inst, hitPos = blocked(near);
    if not blockedNow then return true, inst, hitPos; end;

    -- centre as a second chance (skip it when the closest point IS the centre)
    if cx ~= 0 or cy ~= 0 or cz ~= 0 then
        blockedNow, inst, hitPos = blocked(part.Position);
        if not blockedNow then return true, inst, hitPos; end;
    end;

    return false, inst, hitPos;
end;

-- "seeded" aim priority: the first VISIBLE part in this order wins
-- (head → torso → hands/arms → legs/feet; covers both R6 and R15 rigs)
local TARGET_PARTS = {
    "Head",
    "UpperTorso", "Torso", "LowerTorso",
    "RightHand", "LeftHand",
    "RightLowerArm", "LeftLowerArm", "Right Arm", "Left Arm",
    "RightUpperArm", "LeftUpperArm",
    "RightFoot", "LeftFoot",
    "RightLowerLeg", "LeftLowerLeg", "Right Leg", "Left Leg",
    "RightUpperLeg", "LeftUpperLeg",
};

-- every candidate: players, SPH bots and (optionally) any NPC model the ESP picked up
local function buildCandidateList()
    local t = table.create(#Players:GetPlayers() + #bots:GetChildren() + 8);
    for _, v in next, Players:GetPlayers() do table.insert(t, v); end;
    for _, v in next, bots:GetChildren() do table.insert(t, v); end;
    if getgenv().wh_target_npcs then
        for m, o in next, espObjects do
            -- player characters and SPH bots are already in the list
            if o.player == nil and not m:IsDescendantOf(bots) then
                table.insert(t, m);
            end;
        end;
    end;
    return t;
end;

-- seeded targeting: scans the body parts in priority order and returns the first one
-- that passes the visibility check. Shared by getTarget and the ragebot target list.
local function pickTargetPart(char, origin)
    for _, name in next, TARGET_PARTS do
        local p = char:FindFirstChild(name);
        if p and p:IsA("BasePart") then
            local vis, _, hitPos = isVisible(p, origin);
            if vis then return p, hitPos or p.Position, true; end;
        end;
    end;
    -- wallcheck fallback: a visible root part (peeking out of cover) still counts
    if getgenv().wh_wallcheck then
        local peek = char.PrimaryPart or char:FindFirstChild("HumanoidRootPart");
        if peek then
            local vis, _, hitPos = isVisible(peek, origin);
            if vis then return peek, hitPos or peek.Position, true; end;
        end;
    end;
    local head = char:FindFirstChild("Head") or char.PrimaryPart;
    return head, head and head.Position or nil, false;
end

--======================== TARGET SCAN (one pass, shared) ========================
-- Silent aim, the triggerbot and the rage readout all need the same thing: who is around
-- us and which of their body parts can be seen. They used to run their own pass each, so
-- one frame cost 2-3 full scans. Now there is a single scan per frame, cached for a
-- fraction of a second so every consumer inside that window reuses it.
-- Entries come back sorted NEAREST FIRST, which is what the rage list shows, and lets the
-- scan stop as soon as it has found the targets it can actually use.
local SCAN_TTL = 0.012; -- seconds a scan is reused (long enough to share within a frame,
                         -- short enough that the next frame always re-checks)
local SCAN_MAX = 3;    -- visible targets the rage mode needs (it shows/locks 3)
local scanCache = { at = -math.huge, rage = nil, list = nil, capped = false, count = 0 };

local function scanTargets(origin, rage)
    local now = os.clock();
    if scanCache.rage == rage and scanCache.list and (now - scanCache.at) < SCAN_TTL then
        return scanCache;
    end;

    local list = {};
    local whitelist = getgenv().wh_whitelist;
    raysUsed = 0;

    for _, v in next, buildCandidateList() do
        if v ~= plr then
            if not (whitelist and whitelist[v.Name]) then -- whitelisted: never target
                local char = v:IsA("Model") and v or v.Character;
                local hum = char and char:FindFirstChildOfClass("Humanoid");
                local root = char and (char.PrimaryPart or char:FindFirstChild("HumanoidRootPart"));
                if char and hum and root and hum.Health > 0 and not char:FindFirstChildOfClass("ForceField") then
                    list[#list+1] = {
                        model = char, root = root, name = v.Name,
                        meters = (root.Position - origin).Magnitude / STUDS_PER_METER,
                    };
                end;
            end;
        end;
    end;
    table.sort(list, function(a, b) return a.meters < b.meters end);

    -- work from the nearest outwards; in rage mode 3 visible targets is all we ever show
    -- or lock, so everything behind them does not need raycasting at all
    local count, capped = 0, false;
    for _, entry in next, list do
        entry.part, entry.pos, entry.visible = pickTargetPart(entry.model, origin);
        if entry.part then
            entry.meters = (entry.part.Position - origin).Magnitude / STUDS_PER_METER;
        end;
        if entry.visible then
            count = count + 1;
            if rage and (count >= SCAN_MAX or raysUsed >= RAY_BUDGET) then
                capped = true;
                break;
            end;
        end;
        if not rage and raysUsed >= RAY_BUDGET then
            capped = true;
            break;
        end;
    end;

    scanCache.at, scanCache.rage = now, rage;
    scanCache.list, scanCache.count, scanCache.capped = list, count, capped;
    return scanCache;
end;

-- the scan is cached for a frame, so the whitelist is re-checked on every read: toggling
-- "never target" takes effect immediately instead of waiting for the next scan
local function entryAllowed(entry)
    local wl = getgenv().wh_whitelist;
    return not (wl and wl[entry.name]);
end;

local getTarget = function(origin)
    if not getgenv().wh_silent_aim then return nil; end;
    -- dead or extracted: there is nobody to shoot, and isVisible() bails out without a
    -- character, which used to leave the tracer drawing to a random player
    local myChar = plr.Character;
    if not (myChar and myChar:FindFirstChildOfClass("Humanoid")) then return nil; end;
    origin = origin or cam.CFrame.Position;
    local rage = getgenv().wh_ragebot; -- 360: skip on-screen + FOV checks
    -- ragebot scans 360° around us, so there is no pixel-radius cap on distance
    local cPart, cDistance, cPos = nil, (rage and math.huge or (getgenv().wh_fov_size or 300)), nil;
    local ncPart, ncDistance, ncPos = nil, (rage and math.huge or (getgenv().wh_fov_size or 300)), nil;
    local visCount = 0; -- how many candidates are currently visible (rage readout + triggerbot)

    for _, entry in next, scanTargets(origin, rage).list do
        local tPart = entry.part or entry.root;
        if tPart and entryAllowed(entry) then
            local pos, onScreen = cam:WorldToViewportPoint(entry.root.Position);
            if rage or onScreen then
                -- first VISIBLE part in priority order (see pickTargetPart)
                if entry.visible then visCount = visCount + 1; end;
                local distance = rage and entry.meters
                    or (toScreen(pos) - centerPoint()).Magnitude;
                if entry.visible then
                    if distance < cDistance then
                        cPart = tPart;
                        cPos = entry.pos or tPart.Position;
                        cDistance = distance;
                    end;
                elseif distance < ncDistance then
                    -- nothing visible on this target: remember it anyway so the UI can show
                    -- "not visible", but the hook will not fire at it
                    ncPart = tPart;
                    ncPos = tPart.Position;
                    ncDistance = distance;
                end;
            end;
        end;
    end;

    if cPart then
        return cPart, cPos, true, visCount, (cPart.Position - origin).Magnitude / STUDS_PER_METER;
    elseif ncPart then
        return ncPart, ncPos, false, 0, (ncPart.Position - origin).Magnitude / STUDS_PER_METER;
    end;
    return nil;
end;

--======================== FOV CIRCLE (Drawing) ========================
local fovCircle = createObj("Circle", {
    Thickness = 1, NumSides = 64, Radius = getgenv().wh_fov_size or 300,
    Filled = false, Visible = true,
});

local TracerLine = createObj("Line", { Thickness = 1.5, Visible = false });

--======================== TARGET STATUS (coloured) ========================
-- The readout under the FOV circle is built out of small text pieces so single WORDS can
-- be coloured while everything else stays white and lowercase:
--   * "visible" turns green as soon as one of the target's body parts is actually reachable
--     (red "not visible" when it is behind cover)
--   * the distance is red at 205m and further, then fades towards green the closer the
--     target gets, reaching fully green at 75m
-- A fixed pool of drawing objects is re-used every frame, laid out by hand (monospace font,
-- so the width of a piece is just characters x size x advance) and centred on the circle.
local COL_WHITE = Color3.fromRGB(235, 235, 235);
local COL_GREEN = Color3.fromRGB(80, 255, 110);
local COL_RED = Color3.fromRGB(255, 70, 70);
local COL_FAR = Color3.fromRGB(255, 70, 70);   -- 205m and further
local COL_NEAR = Color3.fromRGB(60, 255, 90); -- 75m and closer
local NEAR_M = 75;
local FAR_M = 205;
local SEP = "\u{00b7}"; -- middle dot used as the separator between fields
local STATUS_SIZE, STATUS_LH, CHAR_W, GAP = 15, 21, 0.62, 7;
local STATUS_POOL = 48;

local function mixColor(a, b, t)
    t = math.clamp(t, 0, 1);
    return Color3.fromRGB(
        math.floor((a.R + (b.R - a.R) * t) * 255 + 0.5),
        math.floor((a.G + (b.G - a.G) * t) * 255 + 0.5),
        math.floor((a.B + (b.B - a.B) * t) * 255 + 0.5)
    );
end

-- red at 205m, fading to fully green by 75m (green stays for anything closer)
local function distanceColor(meters)
    if meters >= FAR_M then return COL_FAR; end;
    if meters <= NEAR_M then return COL_NEAR; end;
    return mixColor(COL_FAR, COL_NEAR, (FAR_M - meters) / (FAR_M - NEAR_M));
end

-- one line of {text, color} pieces for a single target
local function targetLine(part, meters, vis)
    local model = part and part:FindFirstAncestorOfClass("Model");
    if not model then return nil; end;
    local dist = meters or ((part.Position - cam.CFrame.Position).Magnitude / STUDS_PER_METER);
    local hum = model:FindFirstChildOfClass("Humanoid");
    local held = model:FindFirstChildOfClass("Tool");
    local line = {
        { string.lower(model.Name), COL_WHITE },
        { SEP, COL_WHITE },
        { math.floor(dist + 0.5) .. "m", distanceColor(dist) },
    };
    if hum then
        line[#line+1] = { SEP, COL_WHITE };
        line[#line+1] = { math.floor(hum.Health) .. " hp", COL_WHITE };
    end;
    line[#line+1] = { SEP, COL_WHITE };
    line[#line+1] = { held and string.lower(held.Name) or "no weapon", COL_WHITE };
    if vis ~= nil then
        line[#line+1] = { SEP, COL_WHITE };
        line[#line+1] = { vis and "visible" or "not visible", vis and COL_GREEN or COL_RED };
    end;
    return line;
end

-- ragebot: the 3 closest visible targets off the shared scan, closest first. The top entry
-- is exactly what silent aim locks, because both read the same scan.
local function rageTargets(origin)
    local scan = scanTargets(origin, true);
    local out, listed = {}, 0;
    for _, entry in next, scan.list do
        if entry.visible and entryAllowed(entry) then
            listed = listed + 1;
            if listed <= SCAN_MAX then
                out[#out+1] = { part = entry.part, meters = entry.meters };
            end;
        end;
    end;
    return out, scan.count, scan.capped;
end

local statusPool = {};
for i = 1, STATUS_POOL do
    statusPool[i] = createObj("Text", {
        Size = STATUS_SIZE, Center = false, Outline = true, Font = 3,
        Visible = false, ZIndex = 5,
    });
end;

local function pieceWidth(text)
    return #text * STATUS_SIZE * CHAR_W;
end

-- lays the lines out centred on (cx, cy), first line on top
local function drawStatus(lines, cx, cy)
    local used, top = 0, cy - (#lines * STATUS_LH) / 2;
    for li, line in next, lines do
        if type(line) == "table" then
            local y = top + (li - 1) * STATUS_LH;
            local width = 0;
            for _, piece in next, line do
                width = width + pieceWidth(piece[1]) + GAP;
            end;
            width = width - GAP;
            local x = cx.X - width / 2;
            for _, piece in next, line do
                used = used + 1;
                local obj = statusPool[used];
                if not obj then break; end;
                obj.Text = piece[1];
                obj.Color = piece[2];
                obj.Position = Vector2.new(x, y);
                obj.Visible = true;
                x = x + pieceWidth(piece[1]) + GAP;
            end;
        end;
    end;
    for i = used + 1, STATUS_POOL do
        statusPool[i].Visible = false;
    end;
end

local function hideStatus()
    for _, obj in next, statusPool do
        obj.Visible = false;
    end;
end

--======================== GUN MODS ========================
-- Every mod is its own function with its own backup, so they never overlap and each can be
-- toggled on its own:
--   No Recoil        -> weapon kick only (recoil + gunRecoil vertical/horizontal/punch)
--   No Camera Rising -> the camera climb/shake/aim penalty that comes with shooting
--   No Spread, No Bullet Drop
--
-- A mod walks the weapon's WeaponStats table and zeroes the numeric fields whose names
-- match its patterns, remembering the original value so switching it off restores exactly
-- what was there (per mod, so toggling one never undoes another). Patterns are matched
-- case-insensitively anywhere in a field name, which keeps it working across the different
-- field names weapons use (camShake, cameraRise, recoilPosition, ...).
local GunMods = (function()
    local DEFS = {
        {
            Key = "recoil", Setting = "wh_no_recoil", Text = "No Recoil", Default = true,
            Tooltip = "Removes weapon recoil only (viewmodel kick + camera recoil)",
            Patterns = { "gunrecoil", "vertical", "horizontal", "punch" },
        },
        {
            Key = "camera", Setting = "wh_no_camera_rising", Text = "No Camera Rising", Default = true,
            Tooltip = "Stops the camera from climbing/shaking and the aim penalty when you shoot",
            Patterns = { "camshake", "camerarise", "camerakick", "cameraclimb", "camera",
                "aimreduction", "aimpenalty", "recoilposition", "recoilcam", "climb", "lift" },
        },
        {
            Key = "spread", Setting = "wh_no_spread", Text = "No Spread", Default = true,
            Tooltip = "Removes weapon spread",
            Patterns = { "spread" },
        },
        {
            Key = "drop", Setting = "wh_no_bulletdrop", Text = "No Bullet Drop", Default = true,
            Tooltip = "Bullets fly straight instead of dropping",
            Patterns = { "bulletdrop", "drop", "gravityfactor" },
        },
    };

    -- stats table -> mod key -> path -> { tbl, key, value }
    local backup = setmetatable({}, { __mode = "k" });
    local list = {};

    -- visits every numeric field of the stats table (nested tables included).
    -- `path` keeps the backup key unique per field, so recoil.vertical and
    -- gunRecoil.vertical do not overwrite each other.
    local function walk(tbl, depth, path, visit)
        if type(tbl) ~= "table" or (depth or 0) > 4 then return; end;
        for key, value in next, tbl do
            local childPath = path .. "/" .. tostring(key);
            if type(value) == "number" then
                visit(tbl, key, value, childPath);
            elseif type(value) == "table" then
                walk(value, (depth or 0) + 1, childPath, visit);
            end;
        end;
    end;

    -- matched against the FIELD PATH, not just the leaf name: the values live in nested
    -- tables (sway/amount, anims/reload, camera/rise, recoil/camShake), so the parent's
    -- name is what identifies which mod owns the value.
    local function matches(mod, path)
        local name = string.lower(tostring(path));
        for _, pattern in next, mod.Patterns do
            if string.find(name, pattern, 1, true) then return true; end;
        end;
        return false;
    end;

    -- writes the saved originals back and forgets them
    local function restoreSaved(saved)
        if not saved then return; end;
        for _, entry in next, saved do
            pcall(function() entry.tbl[entry.key] = entry.value; end);
        end;
        table.clear(saved);
    end;

    -- one mod against one weapon's stats: apply it if on, restore it if off
    local function applyModToStats(mod, stats)
        local perStats = backup[stats];
        if not perStats then
            perStats = {};
            backup[stats] = perStats;
        end;
        local saved = perStats[mod.Key];
        if not getgenv()[mod.Setting] then
            restoreSaved(saved);
            perStats[mod.Key] = nil;
            return 0;
        end;
        if not saved then
            saved = {};
            perStats[mod.Key] = saved;
        end;
        local count = 0;
        walk(stats, 0, "", function(tbl, key, value, path)
            if matches(mod, path) then
                if saved[path] == nil then
                    saved[path] = { tbl = tbl, key = key, value = value };
                end;
                tbl[key] = 0;
                count = count + 1;
            end;
        end);
        -- booleans (bulletDrop etc.) are flipped instead of zeroed
        if mod.Key == "drop" then
            for key, value in next, stats do
                if type(value) == "boolean" and matches(mod, "/" .. tostring(key)) then
                    local path = "/" .. tostring(key);
                    if not saved[path] then
                        saved[path] = { tbl = stats, key = key, value = value };
                    end;
                    stats[key] = false;
                end;
            end;
        end;
        return count;
    end;

    -- applies every mod to one weapon's stats
    local function applyAll(stats)
        local n = 0;
        for _, mod in next, list do
            n = n + applyModToStats(mod, stats);
        end;
        return n;
    end;

    -- re-applies (and re-restores) every mod to the tools in the backpack / hands
    local function refresh()
        local plrLocal = game:GetService("Players").LocalPlayer;
        local char = plrLocal.Character;
        local containers = { plrLocal.Backpack, char };
        for _, container in next, containers do
            if container then
                for _, v in next, container:GetChildren() do
                    if v:IsA("Tool") then
                        local sphWeapon = v:FindFirstChild("SPH_Weapon");
                        local ws = sphWeapon and sphWeapon:FindFirstChild("WeaponStats");
                        if ws and ws:IsA("ModuleScript") then
                            local ok, stats = pcall(require, ws);
                            if ok and type(stats) == "table" then applyAll(stats) end;
                        end;
                    end;
                end;
            end;
        end;
    end;

    for _, def in next, DEFS do
        getgenv()[def.Setting] = getgenv()[def.Setting] or def.Default;
        def.Patterns = def.Patterns;
        table.insert(list, def);
    end;

    return {
        list = list,
        applyAll = applyAll,
        refresh = refresh,
        reset = function()
            for _, perStats in next, backup do
                for _, saved in next, perStats do restoreSaved(saved); end;
            end;
            table.clear(backup);
        end,
    };
end)();

local applyWeaponStats = function(ws)
    local stats = require(ws);
    GunMods.applyAll(stats);
end;


-- apply stats to a tool as soon as it enters the backpack/character (pickups, equips, respawns)
local watchedContainers = setmetatable({}, { __mode = "k" });

local applyToTool = function(v)
    if typeof(v) ~= "Instance" then return; end;
    local sphWeapon = v:FindFirstChild("SPH_Weapon");
    local ws = sphWeapon and sphWeapon:FindFirstChild("WeaponStats");
    if ws and ws:IsA("ModuleScript") then
        applyWeaponStats(ws);
    end;
end;

local watchContainer = function(container)
    if not container or watchedContainers[container] then return; end;
    watchedContainers[container] = true;
    table.insert(Connections, container.ChildAdded:Connect(function(v)
        if v:IsA("Tool") then task.defer(applyToTool, v); end;
    end));
end;

local setup = function(char)
    for _, v in next, plr.Backpack:GetChildren() do
        if v:IsA("Tool") and v:FindFirstChild("SPH_Weapon") then
            applyWeaponStats(v.SPH_Weapon.WeaponStats);
        end;
    end;

    local t = char:FindFirstChildOfClass("Tool");
    if t and t:FindFirstChild("SPH_Weapon") then
        applyWeaponStats(t.SPH_Weapon.WeaponStats);
    end;

    watchContainer(plr.Backpack);
    watchContainer(char);
end;

if plr.Character then
    setup(plr.Character);
end;
plr.CharacterAdded:Connect(setup);

--======================== BULLET TRACERS (3D parts) ========================
local Debris = cloneref(game:GetService("Debris"));

--======================== TRACER ORIGIN (gun barrel) ========================
-- The first-person weapon sits at Camera.WeaponRig.Weapon.<WeaponName>.<Barrel>, and most
-- guns name the barrel "Silencer" (e.g. Weapon.SASS.Silencer, Weapon.AK47.Silencer). The
-- weapon folder changes name with every gun, so the barrel is looked up by part name inside
-- whichever weapon is equipped. The result is cached and re-resolved when the rig or the
-- weapon model is swapped (weapon change / respawn). No barrel found -> body/shot origin.
local MUZZLE_NAMES = { "silencer", "muzzle", "barrel" };
local muzzleCache = { rig = nil, weapon = nil, part = nil };

local function getMuzzlePart()
    if not getgenv().wh_tracer_barrel then return nil; end;
    local rig = workspace.CurrentCamera and workspace.CurrentCamera:FindFirstChild("WeaponRig");
    if not rig then
        muzzleCache.part = nil;
        return nil;
    end;
    local weapon = rig:FindFirstChild("Weapon");
    if not weapon then
        muzzleCache.part = nil;
        return nil;
    end;
    -- still the same weapon? reuse the barrel we found last time
    if muzzleCache.rig == rig and muzzleCache.weapon == weapon
        and muzzleCache.part and muzzleCache.part.Parent then
        return muzzleCache.part;
    end;
    muzzleCache.rig, muzzleCache.weapon, muzzleCache.part = rig, weapon, nil;
    for _, wanted in next, MUZZLE_NAMES do
        for _, inst in next, weapon:GetDescendants() do
            if inst:IsA("BasePart") and string.lower(inst.Name) == wanted then
                muzzleCache.part = inst;
                return inst;
            end;
        end;
    end;
    return nil;
end;

-- where a tracer should start: the barrel if we have one, otherwise the body
local function tracerOrigin(fallback)
    local muzzle = getMuzzlePart();
    if muzzle then return muzzle.Position; end;
    local char = plr.Character;
    local root = char and char:FindFirstChild("HumanoidRootPart");
    return (root and root.Position) or fallback;
end;

-- draws a 3D tracer between two world points (core + glow shell, lives for the set time)
local drawBeam = function(a, b, lifetime)
    local dist = (b - a).Magnitude;
    if dist < 0.5 then return; end;
    local life = lifetime or getgenv().wh_beam_lifetime or 0.6;
    local cf = CFrame.lookAt((a + b) / 2, b);
    local color = getgenv().wh_beam_color;

    local glow = Instance.new("Part");
    glow.Anchored = true;
    glow.CanCollide = false;
    glow.CanQuery = false;
    glow.CanTouch = false;
    glow.CastShadow = false;
    glow.Material = Enum.Material.Neon;
    glow.Color = color;
    glow.Transparency = 0.75;
    glow.Size = Vector3.new(0.2, 0.2, dist);
    glow.CFrame = cf;
    glow.Parent = cam;

    local core = Instance.new("Part");
    core.Anchored = true;
    core.CanCollide = false;
    core.CanQuery = false;
    core.CanTouch = false;
    core.CastShadow = false;
    core.Material = Enum.Material.Neon;
    core.Color = color;
    core.Transparency = 0.1;
    core.Size = Vector3.new(0.05, 0.05, dist);
    core.CFrame = cf;
    core.Parent = cam;

    Debris:AddItem(glow, life + 0.1);
    Debris:AddItem(core, life);
end;

--======================== CAMERA (THIRD PERSON) ========================
-- Runs after the game's camera module (Camera + 10) and pulls the camera back behind the
-- character, raycast-clamped so it never clips through walls. The rotation is left
-- completely to the game, so the mouse keeps full control of the view.
local CAM_STEP = "wh_cam_step";

local function applyCamera()
    local g = getgenv();
    local thirdDist = g.wh_third_person and (g.wh_third_person_distance or 0) or 0;
    if thirdDist <= 0 then
        RunService:UnbindFromRenderStep(CAM_STEP);
        return;
    end;
    -- rebinding the same name replaces the previous step, so this is always safe
    RunService:BindToRenderStep(CAM_STEP, Enum.RenderPriority.Camera.Value + 10, function()
        if not Running then return; end;
        local current = workspace.CurrentCamera;
        if not current then return; end;
        local cf = current.CFrame;
        local char = plr.Character;
        local head = char and char:FindFirstChild("Head");
        local origin = head and head.Position or cf.Position;
        local dir = cf.LookVector;
        local target = origin - dir * thirdDist;
        if origin ~= target then
            rp.FilterDescendantsInstances = { char, sph }; -- never clip into ourselves
            local hit = workspace:Raycast(origin, target - origin, rp);
            if hit then target = origin + (hit.Position - origin) * 0.9; end;
        end;
        current.CFrame = CFrame.lookAt(target, target + dir);
    end);
end;

local function clearCamera()
    RunService:UnbindFromRenderStep(CAM_STEP);
end;

local Fov = (function()
-- The game rewrites Camera.FieldOfView every frame, so simply setting it once does
-- nothing. The value is forced back through the property-changed signal, which makes our
-- write the last one of the frame. Re-attached whenever the camera object is replaced.
local fovLock = nil;

local function clearFOV()
    if fovLock then
        pcall(function() fovLock:Disconnect(); end);
        fovLock = nil;
    end;
end

local function applyFOV()
    clearFOV();
    if not getgenv().wh_fov_enabled then return; end;
    local fov = math.clamp(getgenv().wh_fov or 70, 1, 120); -- the engine caps out at 120
    local current = workspace.CurrentCamera;
    if not current then return; end;
    current.FieldOfView = fov;
    fovLock = current:GetPropertyChangedSignal("FieldOfView"):Connect(function()
        local c = workspace.CurrentCamera;
        if c and c.FieldOfView ~= fov then c.FieldOfView = fov; end;
    end);
end

-- camera objects get replaced on respawn, so keep the lock attached to the live one
task.spawn(function()
    while Running do
        task.wait(1);
        if not Running then break; end;
        if getgenv().wh_fov_enabled and workspace.CurrentCamera and fovLock == nil then
            applyFOV();
        end;
    end;
end);

workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    task.defer(applyFOV);
end);

applyFOV();

return { apply = applyFOV, clear = clearFOV };
end)();

Fov.apply();

--======================== REMOVE ARMS ========================
-- IRREVERSIBLE: everything is destroyed outright except the keep-listed parts below.
-- Hiding them was not enough - the parts stayed in the model and the game re-showed or
-- re-created them, which is why the arms kept coming back.
--   WeaponRig       -> keeps Weapon, Clothing, Humanoid, AnimBase
--   StarterCharacter-> keeps Pants, Shirt, Humanoid, torso, legs, feet, head, root
-- A short loop keeps sweeping afterwards, because the rig is rebuilt on weapon swaps and
-- respawns: the game recreates the arms and they are destroyed again.
local Arms = (function()
    local WEAPON_RIG_KEEP = { Weapon = true, Clothing = true, Humanoid = true, AnimBase = true };
    local STARTER_KEEP = {
        Pants = true, Shirt = true, Humanoid = true, LowerTorso = true, UpperTorso = true,
        RightUpperLeg = true, RightLowerLeg = true, LeftLowerLeg = true, LeftUpperLeg = true,
        LeftFoot = true, RightFoot = true, Head = true, HumanoidRootPart = true,
    };

    local function weaponRigModel()
        local camNow = workspace.CurrentCamera;
        return camNow and camNow:FindFirstChild("WeaponRig");
    end

    local function starterCharacter()
        local starter = cloneref(game:GetService("StarterPlayer"));
        return starter and starter:FindFirstChild("StarterCharacter");
    end

    -- true when this instance, or anything between it and `stopAt`, is on the keep list
    local function keptBy(instance, keep, stopAt)
        local node = instance;
        while node and node ~= stopAt do
            if keep[node.Name] then return true; end;
            node = node.Parent;
        end;
        return false;
    end;

    -- destroys every descendant of `root` that is not keep-listed
    local function stripRoot(root, keep)
        if not root then return 0; end;
        local n = 0;
        for _, inst in next, root:GetDescendants() do
            if not keptBy(inst, keep, root) then
                pcall(function() inst:Destroy(); end);
                n = n + 1;
            end;
        end;
        return n;
    end

    local function sweep()
        stripRoot(weaponRigModel(), WEAPON_RIG_KEEP);
        stripRoot(starterCharacter(), STARTER_KEEP);
    end

    task.spawn(function()
        while Running do
            task.wait(0.5);
            if not Running then break; end;
            sweep();
        end;
    end);

    return {
        remove = sweep,
        keptBy = keptBy,
        weaponKeep = WEAPON_RIG_KEEP,
        starterKeep = STARTER_KEEP,
        starterCharacter = starterCharacter,
        weaponRig = weaponRigModel,
    };
end)();

Arms.remove();

--======================== WEAPON CHARMS ========================
-- Reskins the first-person weapon (workspace.CurrentCamera.WeaponRig.Weapon) with any
-- material + colour. Originals are stored so switching it off restores the gun exactly.
local WEAPON_MATERIALS = {
    "None", "Neon", "Glass", "ForceField", "DiamondPlate", "Metal", "Plastic", "SmoothPlastic",
    "Marble", "Slate", "Ice", "Wood", "Sand", "Grass", "Cobblestone", "Concrete", "Rock",
    "Leather", "Acrylic", "Pearl", "CrackedLava", "Lava", "Glacier", "CorrodedMetal", "Dirt",
};
local charmBackup = setmetatable({}, { __mode = "k" });

local function weaponModel()
    local current = workspace.CurrentCamera;
    local rig = current and current:FindFirstChild("WeaponRig");
    return rig and rig:FindFirstChild("Weapon");
end

local function applyWeaponCharm()
    local weapon = weaponModel();
    if not weapon then return; end;
    local g = getgenv();
    local on = g.wh_weapon_charm == true;
    local materialName = g.wh_weapon_material or "Neon";
    local material = materialName ~= "None" and Enum.Material[materialName] or nil;

    for _, part in next, weapon:GetDescendants() do
        if part:IsA("BasePart") then
            if on and material then
                if not charmBackup[part] then
                    charmBackup[part] = {
                        material = part.Material,
                        color = part.Color,
                        reflectance = part.Reflectance,
                        transparency = part.Transparency,
                    };
                end;
                part.Material = material;
                part.Color = g.wh_weapon_color or part.Color;
                part.Reflectance = math.clamp(g.wh_weapon_reflectance or 0, 0, 1);
                part.Transparency = math.clamp(g.wh_weapon_transparency or 0, 0, 1);
            elseif charmBackup[part] then
                local b = charmBackup[part];
                part.Material = b.material;
                part.Color = b.color;
                part.Reflectance = b.reflectance;
                part.Transparency = b.transparency;
                charmBackup[part] = nil;
            end;
        end;
    end;
end;

local function restoreWeaponCharm()
    for part, b in next, charmBackup do
        if part and part.Parent then
            part.Material = b.material;
            part.Color = b.color;
            part.Reflectance = b.reflectance;
            part.Transparency = b.transparency;
        end;
    end;
    table.clear(charmBackup);
end;

task.spawn(function()
    while Running do
        task.wait(1);
        if not Running then break; end;
        applyWeaponCharm();
    end;
end);

applyWeaponCharm();

--======================== HEAD EXPANDER ========================
local function updateHeadExpand()
    if not getgenv().wh_head_expand then return; end;
    local size = Vector3.new(getgenv().wh_head_size, getgenv().wh_head_size, getgenv().wh_head_size);
    local trans = getgenv().wh_head_transparency or 0.5;
    for model in next, espObjects do
        local head = model:FindFirstChild("Head");
        if head and head:IsA("BasePart") then
            if not headOrig[model] then
                headOrig[model] = { size = head.Size, transparency = head.Transparency };
            end;
            head.Size = size;
            head.Transparency = trans;
        end;
    end;
end;

local function restoreHeads()
    for model, orig in next, headOrig do
        local head = model and model:FindFirstChild("Head");
        if head and orig.size then
            head.Size = orig.size;
            head.Transparency = orig.transparency;
        end;
    end;
    table.clear(headOrig);
end;

--======================== WALLCLIMB (always on while enabled) ========================
local wallclimbEnabled = false;
local wcAttachment = nil;
local wcVelocity = nil;

local function destroyWcConstraint()
    if wcVelocity then wcVelocity:Destroy(); wcVelocity = nil; end;
    if wcAttachment then wcAttachment:Destroy(); wcAttachment = nil; end;
end;

local function setWallclimb(on)
    wallclimbEnabled = on;
    if not on then
        destroyWcConstraint();
    end;
end;

-- wallclimb: while enabled, automatically attach when a wall is in front of you
table.insert(Connections, RunService.Heartbeat:Connect(function()
    if not Running then return; end;

    local char = plr.Character;
    local root = char and (char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart);
    if not root then return; end;

    local ray = wallclimbEnabled and workspace:Raycast(root.Position, root.CFrame.LookVector * 3, rp) or nil;

    if ray and not wcVelocity then
        wcAttachment = Instance.new("Attachment");
        wcAttachment.Parent = root;
        wcVelocity = Instance.new("LinearVelocity");
        wcVelocity.Attachment0 = wcAttachment;
        wcVelocity.MaxForce = 1e6;
        wcVelocity.RelativeTo = Enum.ActuatorRelativeTo.World;
        wcVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector;
        wcVelocity.VectorVelocity = Vector3.new(0, getgenv().wh_wc_speed or 22, 0);
        wcVelocity.Parent = root;
    elseif not ray and wcVelocity then
        destroyWcConstraint();
    end;

    if wcVelocity and ray then
        local n = ray.Normal;
        wcVelocity.VectorVelocity = Vector3.new(-n.X * 4, getgenv().wh_wc_speed or 22, -n.Z * 4);
    end;
end));

-- release climb constraint on respawn
table.insert(Connections, plr.CharacterAdded:Connect(function()
    destroyWcConstraint();
end));

--======================== TRIGGERBOT (synthetic click, no mouse1 funcs) ============
local triggerLast = 0;
local function triggerFire()
    local now = os.clock();
    if now - triggerLast < (getgenv().wh_trigger_delay or 0.12) then return; end;
    triggerLast = now;
    -- click where the crosshair is (the FOV circle's origin), not blindly at the mouse
    local pos = centerPoint();
    pcall(function()
        VIM:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 1);
        task.delay(0.03, function()
            pcall(function()
                VIM:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 1);
            end);
        end);
    end);
end;

-- fires when silent-aim has a visible target; in ragebot mode it uses the per-frame
-- rage scan (visCount) since a 360° target can be behind us and off-screen.
-- it also stops past 205m (aiming is still unlimited at any range).
table.insert(Connections, RunService.Heartbeat:Connect(function()
    if not Running then return; end;
    if not (getgenv().wh_triggerbot and getgenv().wh_silent_aim) then return; end;
    local ok, tPart, _, tVis, visCount, meters = pcall(getTarget);
    if ok and tPart and (visCount or 0) > 0 then
        if not getgenv().wh_ragebot and not tVis then
            return;
        end;
        if (meters or 0) > MAX_TRIGGER_DISTANCE then
            return; -- past 205m the trigger stays off (aiming still works)
        end;
        triggerFire();
    end;
end));

--======================== TP KILL ========================
-- Teleports you on top of the currently locked target's head and auto-fires
-- (triggerbot) until that target dies, then returns you to the exact spot you
-- started from. If you turn it off mid-kill, you get returned immediately.
local tpKillTarget = nil;
local tpKillReturn = nil;

local tpKillStop = function()
    local char = plr.Character;
    local root = char and char:FindFirstChild("HumanoidRootPart");
    if tpKillReturn and root then
        root.CFrame = tpKillReturn;
        root.AssemblyLinearVelocity = Vector3.zero;
    end;
    tpKillTarget = nil;
    tpKillReturn = nil;
end;

table.insert(Connections, RunService.Heartbeat:Connect(function()
    if not Running then return; end;
    if not getgenv().wh_tpkill then
        if tpKillTarget then tpKillStop(); end; -- mid-kill disable: return home
        return;
    end;

    local char = plr.Character;
    local root = char and char:FindFirstChild("HumanoidRootPart");
    local myHum = char and char:FindFirstChildOfClass("Humanoid");
    if not (root and myHum and myHum.Health > 0) then return; end;

    -- no target locked yet: grab the current visible silent-aim target
    if not tpKillTarget then
        local ok, tPart, _, tVis = pcall(getTarget);
        if ok and tPart and tVis then
            local m = tPart:FindFirstAncestorOfClass("Model");
            if m and m ~= char and m:FindFirstChildOfClass("Humanoid") then
                tpKillTarget = m;
                tpKillReturn = root.CFrame;
                -- single teleport: stand on top of the target's head ONCE, with the
                -- rotation we started with; after this the position is never forced
                local head = m:FindFirstChild("Head") or m.PrimaryPart;
                if head then
                    root.CFrame = CFrame.new(head.Position + Vector3.new(0, head.Size.Y / 2 + 2.5, 0))
                        * (root.CFrame - root.CFrame.Position);
                end;
            end;
        end;
        return; -- nothing targetable this frame: stay put until one is found
    end;

    -- target dead or gone: return to the original spot and re-arm for the next one
    local hum = tpKillTarget:FindFirstChildOfClass("Humanoid");
    if not tpKillTarget:IsDescendantOf(workspace) or not hum or hum.Health <= 0 then
        tpKillStop();
        return;
    end;

    -- the teleport already happened once at lock time; from here on you can move
    -- freely (walk into a raid etc.) — we only keep auto-firing while the target
    -- is still alive, and pull you back to the saved spot once it dies
    triggerFire();
end));

--======================== HOOK (silent aim bullet redirect) =========================
-- This runs INSIDE the game's own bullet call, so the only rule that matters is: the shot
-- must always go through. Everything here is wrapped so that any mistake at worst leaves
-- the bullet flying exactly the way the game fired it, never a missing projectile:
--   * the target lookup and the direction maths are inside a pcall
--   * old() is called exactly once, and its return value is handed back untouched
--     (the game uses it, so dropping it breaks the shot)
--   * hit logs and tracer beams run AFTER the bullet exists, each in its own pcall
local HitLogs = nil; -- defined further down, once the notify library is loaded
local old;

-- small live status of the hook, shown in the menu so a silent-aim problem can be read
-- off the screen instead of guessed at
local HookStatus = { installed = false, shots = 0, redirects = 0, renderErrors = 0, last = "no shot yet" };

old = clonefunction(hookfunction(rawget(ac, "new"), newcclosure(function(_, origin, __, ___, ...)
    -- only intercept OUR shots; everyone else's (players and bots) pass through untouched
    local mine = false;
    do
        local char = plr.Character;
        local root = char and (char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart);
        if typeof(_) == "Instance" then
            local m = _:FindFirstAncestorOfClass("Model");
            if m == char then
                mine = true;
            elseif m and m:FindFirstChildOfClass("Humanoid") then
                mine = false; -- someone else's / a bot's weapon
            elseif root and typeof(origin) == "Vector3" then
                mine = (origin - root.Position).Magnitude < 15;
            end;
        elseif root and typeof(origin) == "Vector3" then
            mine = (origin - root.Position).Magnitude < 15;
        end;
    end;
    if not mine then
        return old(_, origin, __, ___, ...);
    end;
    HookStatus.shots = HookStatus.shots + 1;

    -- work out whether we redirect, without ever being able to throw out of here
    local part, pos, vis, meters
    pcall(function()
        -- the muzzle is a hand's width away from the camera, but a raycast from it can
        -- disagree (clipping into the gun, a wall the camera clears), so fall back to the
        -- camera origin before deciding there is nothing to shoot
        -- getTarget returns (part, aimPos, visible, visCount, meters) - in that order
        local hitPart, aimPos, seen, _, dist = getTarget(origin);
        if (not hitPart) or (not aimPos) then
            local p2, a2, s2, _, d2 = getTarget();
            if p2 and a2 then
                hitPart, aimPos, seen, dist = p2, a2, s2, d2;
            end;
        end;
        if not hitPart then return end;
        -- only redirect when the target has a VISIBLE part (vis=false = display only,
        -- e.g. someone fully behind cover) - we never shoot at hidden targets.
        -- A visible part is preferred, but when nothing passes the raycast the target is
        -- still damageable in many situations (thin cover, angled walls, servers that do
        -- not lag the shot), so with Aim Unseen on we fire at the locked target anyway
        -- instead of leaving the player to line the crosshair up by hand.
        local fireAnyway = getgenv().wh_aim_unseen;
        if (seen or fireAnyway) and typeof(origin) == "Vector3" and typeof(aimPos) == "Vector3" then
            part, pos, vis, meters = hitPart, aimPos, seen, dist;
        end;
    end);

    local unit;
    if pos then
        local dir = pos - origin;
        local dist = dir.Magnitude;
        -- a zero length direction has no Unit, and a NaN handed to the game's ballistics
        -- is exactly how a projectile silently fails to appear
        if dist > 0.01 and dist < math.huge then
            unit = dir / dist;
        else
            pos = nil;
        end;
    end;

    local result;
    if unit then
        HookStatus.redirects = HookStatus.redirects + 1;
        HookStatus.last = ("redirect %sm"):format(
            tostring(meters ~= nil and math.floor(meters + 0.5) or "?"));
        result = old(_, origin, unit, unit * 9e9, ...);
    else
        if not pos then
            HookStatus.last = "no target" .. (getgenv().wh_aim_unseen and "" or " (aim unseen off)");
        else
            HookStatus.last = "bad direction";
        end;
        result = old(_, origin, __, ___, ...);
    end;

    if getgenv().wh_debug_hook then
        local why = unit and ("redirect -> " .. tostring(pos) .. " (" .. tostring(meters) .. "m)")
            or (not pos and "no target / not visible / aim unseen off" or "degenerate direction");
        print(("[hook] " .. why .. " | vis=" .. tostring(vis) .. " | returned=" .. tostring(result)));
    end;

    -- the bullet exists now, so nothing below can take it away
    if unit then
        if getgenv().wh_tracer_beams then
            pcall(drawBeam, tracerOrigin(origin), pos);
        end;
        if getgenv().wh_hitlogs and HitLogs then
            pcall(HitLogs.note, part, meters, vis); -- resolves later: hit, kill or miss
        end;
    end;
    return result;
end)));

-- did the hook actually replace the game's bullet function? (the menu shows this)
pcall(function()
    HookStatus.installed = type(rawget(ac, "new")) == "function";
end);

--======================== LIGHTING CONTROL =========================
local Lighting = cloneref(game:GetService("Lighting"));
local litOrig = nil;
local litEffects = {}; -- { inst, prop, value, live } backups for effects/sky/atmosphere

-- set a property only if the instance actually has it (guards against
-- properties that do not exist on the game's specific effect instances)
local function trySet(inst, prop, value)
    if not (inst and inst.Parent) then return; end;
    local info = pcall(function() return inst[prop]; end);
    if not info then return; end;
    pcall(function() inst[prop] = value; end);
end;

local function applyToEffect(v)
    if not litOrig then return; end;
    if v:IsA("PostEffect") and not getgenv().wh_lighting_post_effects then
        if not table.find(litEffects, function(e) return e.inst == v; end) then
            table.insert(litEffects, { inst = v, prop = "Enabled", value = v.Enabled, live = true });
        end;
        v.Enabled = false;
    elseif v:IsA("Atmosphere") and not getgenv().wh_lighting_atmosphere then
        if not table.find(litEffects, function(e) return e.inst == v; end) then
            table.insert(litEffects, { inst = v, prop = "Density", value = v.Density, live = true });
        end;
        v.Density = 0;
    elseif v:IsA("Sky") or v:IsA("Clouds") then
        local prop = v:IsA("Sky") and "CelestialBodiesShown" or "Cover";
        if not table.find(litEffects, function(e) return e.inst == v; end) then
            table.insert(litEffects, { inst = v, prop = prop, value = v[prop], live = false });
        end;
        trySet(v, prop, false);
    end;
end;

-- effects that only have lighting-scaling properties (intensity sliders)
local function scanLightingEffects()
    for _, v in next, Lighting:GetDescendants() do
        if v:IsA("BloomEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("SunRaysEffect")
            or v:IsA("DepthOfFieldEffect") or v:IsA("BlurEffect") or v:IsA("Atmosphere")
            or v:IsA("Sky") or v:IsA("Clouds") then
            applyToEffect(v);
        end;
    end;
end;

local function applyLightingValues()
    if not (litOrig and getgenv().wh_lighting_enabled) then return; end;
    local g = getgenv();
    if g.wh_lighting_global_shadows ~= nil then
        Lighting.GlobalShadows = g.wh_lighting_global_shadows;
    end;
    if g.wh_lighting_brightness ~= nil then
        Lighting.Brightness = g.wh_lighting_brightness;
    end;
    if g.wh_lighting_clocktime ~= nil then
        Lighting.ClockTime = g.wh_lighting_clocktime;
    end;
    if g.wh_lighting_exposure ~= nil then
        trySet(Lighting, "ExposureCompensation", g.wh_lighting_exposure);
    end;
    if g.wh_lighting_ambient_enabled then
        Lighting.Ambient = g.wh_lighting_ambient;
        Lighting.OutdoorAmbient = g.wh_lighting_outdoor_ambient;
    end;
    if g.wh_lighting_fog_enabled then
        Lighting.FogColor = g.wh_lighting_fog_color;
        Lighting.FogStart = g.wh_lighting_fog_start;
        Lighting.FogEnd = g.wh_lighting_fog_end;
    end;
    for _, e in next, litEffects do
        if e.inst and e.inst.Parent then
            if e.prop == "CelestialBrightnessScale" then
                e.inst[e.prop] = g.wh_lighting_celestial_intensity;
            elseif e.prop == "EnvironmentDiffuseScale" then
                e.inst[e.prop] = g.wh_lighting_env_diffuse;
            elseif e.prop == "EnvironmentSpecularScale" then
                e.inst[e.prop] = g.wh_lighting_env_specular;
            elseif e.prop == "AmbientIntensity" then
                e.inst[e.prop] = g.wh_lighting_ambient_intensity;
            end;
        end;
    end;
end;

local function applyLighting(on)
    if on and not litOrig then
        litOrig = {
            Ambient = Lighting.Ambient,
            OutdoorAmbient = Lighting.OutdoorAmbient,
            Brightness = Lighting.Brightness,
            ClockTime = Lighting.ClockTime,
            FogColor = Lighting.FogColor,
            FogStart = Lighting.FogStart,
            FogEnd = Lighting.FogEnd,
            GlobalShadows = Lighting.GlobalShadows,
            ExposureCompensation = Lighting.ExposureCompensation,
        };
        scanLightingEffects();
        applyLightingValues();
    elseif not on and litOrig then
        for k, v in next, litOrig do Lighting[k] = v; end;
        for _, e in next, litEffects do
            if e.inst and e.inst.Parent then pcall(function() e.inst[e.prop] = e.value; end); end;
        end;
        table.clear(litEffects);
        litOrig = nil;
    end;
end;

-- re-applies effect instances (needed when the post-effects/atmosphere mode flips)
local function refreshLighting()
    if litOrig then
        applyLighting(false);
        applyLighting(true);
    end;
end;

-- fog/atmosphere/effects the game adds while lighting is enabled get handled too
table.insert(Connections, Lighting.DescendantAdded:Connect(function(v)
    if litOrig then
        task.defer(function()
            if litOrig and v.Parent then applyToEffect(v); end;
        end);
    end;
end));

--======================== LINORIA UI (resilient loader) ========================
-- raw.githubusercontent.com regularly times out / gets blocked, which shows up as
-- "HTTP exception while yielding ... both timeouted". So try a fast CDN first, then the
-- other mirrors, then the executor's request() API, and abort cleanly if all fail.
local httpRequest = (syn and syn.request) or (http and http.request) or http_request or request;

local function fetchSource(url)
    local ok, body = pcall(function() return game:HttpGet(url); end);
    if ok and type(body) == "string" and #body > 2 then return body; end;

    ok, body = pcall(function() return game:HttpGet(url, true); end);
    if ok and type(body) == "string" and #body > 2 then return body; end;

    if httpRequest then
        local ok2, res = pcall(httpRequest, { Url = url, Method = "GET" });
        if ok2 and type(res) == "table" and type(res.Body) == "string" and #res.Body > 2 then
            return res.Body;
        end;
    end;

    return nil;
end;

local LIB_MIRRORS = {
    "https://cdn.jsdelivr.net/gh/violin-suzutsuki/LinoriaLib@main/",
    "https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/",
    "https://raw.githack.com/violin-suzutsuki/LinoriaLib/main/",
};

local function loadRemote(relative)
    local lastErr = "no response";
    for _, base in next, LIB_MIRRORS do
        local ok, src = pcall(fetchSource, base .. relative);
        if ok and src then
            local chunk, err = loadstring(src, relative);
            if chunk then
                local ran, mod = pcall(chunk);
                if ran and mod ~= nil then return mod; end;
                lastErr = tostring(mod);
            else
                lastErr = tostring(err);
            end;
        else
            task.wait(0.1);
        end;
    end;
    warn("Could not load " .. relative .. " (" .. tostring(lastErr) .. ")");
    return nil;
end;

local Library = loadRemote("Library.lua");
if not Library then
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Combined Script",
            Text = "Failed to download LinoriaLib from every mirror. Check your connection / executor HTTP.",
            Duration = 8,
        });
    end);
    return warn("Aborted: UI library unavailable.");
end;

local ThemeManager = loadRemote("addons/ThemeManager.lua");
local SaveManager = loadRemote("addons/SaveManager.lua");

local Window = Library:CreateWindow({
    Title = "aimwhere | desertstorm | 2 step ahead of the game",
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2,
});

local Tabs = {
    Main = Window:AddTab("Main"),
    UISettings = Window:AddTab("UI Settings"),
};

-- Left column: Silent Aim
local SA = Tabs.Main:AddLeftGroupbox("Silent Aim");
SA:AddToggle("SA_Enabled", {
    Text = "Enabled",
    Default = getgenv().wh_silent_aim,
    Callback = function(v) getgenv().wh_silent_aim = v; end,
});
SA:AddSlider("SA_FOV", {
    Text = "FOV Size",
    Default = getgenv().wh_fov_size,
    Min = 20, Max = 800, Rounding = 0, Compact = false,
    Callback = function(v) getgenv().wh_fov_size = v; end;
});
SA:AddToggle("SA_Tracers", {
    Text = "Target Tracer",
    Default = getgenv().wh_tracers,
    Callback = function(v) getgenv().wh_tracers = v; end,
}):AddColorPicker("SA_TracerColor", {
    Default = getgenv().wh_tracer_color,
    Title = "Tracer Color",
    Callback = function(v) getgenv().wh_tracer_color = v; end;
});
SA:AddToggle("SA_FOVCircle", {
    Text = "Show FOV Circle",
    Default = getgenv().wh_fov_toggle,
    Callback = function(v) getgenv().wh_fov_toggle = v; end,
}):AddColorPicker("SA_FOVColor", {
    Default = getgenv().wh_fov_color,
    Title = "FOV Circle Color",
    Callback = function(v) getgenv().wh_fov_color = v; end;
});
SA:AddDropdown("SA_FOVPos", {
    Values = { "Center", "Cursor" },
    Default = "Center",
    Multi = false,
    Text = "FOV Position",
    Callback = function(v)
        getgenv().wh_fov_center = (v == "Center");
    end,
});
SA:AddToggle("SA_WallCheck", {
    Text = "Wall Check",
    Default = getgenv().wh_wallcheck,
    Callback = function(v) getgenv().wh_wallcheck = v; end;
});
SA:AddToggle("SA_AimUnseen", {
    Text = "No SA wallcheck",
    Default = getgenv().wh_aim_unseen,
    Tooltip = "silent aim always aims on target, allowing you to shoot trough wallbangable walls/fences",
    Callback = function(v) getgenv().wh_aim_unseen = v; end;
});
-- live readout of the bullet hook, so a silent-aim problem is visible in the menu

SA:AddToggle("SA_TargetNPCs", {
    Text = "Target NPCs",
    Default = getgenv().wh_target_npcs,
    Callback = function(v) getgenv().wh_target_npcs = v; end;
});
local RagebotToggle = SA:AddToggle("SA_Ragebot", {
    Text = "Ragebot",
    Default = getgenv().wh_ragebot,
    Tooltip = "SA targets everything around you, combined with tb causes mass destruction",
    Callback = function(v) getgenv().wh_ragebot = v; end;
});
RagebotToggle:AddKeyPicker("SA_RagebotKey", {
    Default = "None", -- linoria requires a Default; "None" means no key bound
    SyncToggleState = true,
    Mode = "Toggle",
    Text = "Ragebot",
});
SA:AddToggle("SA_Triggerbot", {
    Text = "Triggerbot",
    Default = getgenv().wh_triggerbot,
    Tooltip = "basically auto shoot, uses vim to emulate mouse",
    Callback = function(v) getgenv().wh_triggerbot = v; end;
}):AddKeyPicker("SA_TriggerbotKey", {
    Default = "None", -- linoria requires a Default; "None" means no key bound
    SyncToggleState = true,
    Mode = "Toggle",
    Text = "Triggerbot",
});
SA:AddSlider("SA_TriggerDelay", {
    Text = "TB Delay",
    Default = getgenv().wh_trigger_delay,
    Min = 0.03, Max = 0.5, Rounding = 2, Compact = false,
    Callback = function(v) getgenv().wh_trigger_delay = v; end;
});

local TPK = Tabs.Main:AddLeftGroupbox("TP Kill");
TPK:AddToggle("TPK_Enabled", {
    Text = "Enabled",
    Default = getgenv().wh_tpkill,
    Callback = function(v)
        getgenv().wh_tpkill = v;
        if not v then tpKillStop(); end;
    end,
}):AddKeyPicker("TPK_Key", {
    Default = "None", -- linoria requires a Default; "None" means no key bound
    SyncToggleState = true,
    Mode = "Toggle",
    Text = "TP Kill",
});

-- Left column: Whitelist
local function currentPlayerNames()
    local names = {};
    for _, p in next, Players:GetPlayers() do
        if p ~= plr then
            names[#names + 1] = p.Name;
        end;
    end;
    table.sort(names);
    return names;
end;

local WL = Tabs.Main:AddLeftGroupbox("Whitelist");
local WhitelistDropdown = WL:AddDropdown("SA_Whitelist", {
    Text = "Never Target",
    Values = currentPlayerNames(),
    Default = {},
    Multi = true,
    AllowNull = true,
    Callback = function(selected) getgenv().wh_whitelist = selected; end,
});
getgenv().wh_whitelist = WhitelistDropdown.Value;

local function refreshWhitelistDropdown()
    local names = currentPlayerNames();
    local old = WhitelistDropdown.Values;
    local changed = (#names ~= #old);
    if not changed then
        for i = 1, #names do
            if names[i] ~= old[i] then changed = true; break; end;
        end;
    end;
    if changed then
        WhitelistDropdown:SetValues(names);
    end;
end;

task.spawn(function()
    while Running do
        task.wait(60);
        if not Running then break; end;
        refreshWhitelistDropdown();
    end;
end);

local Tracers = Tabs.Main:AddLeftGroupbox("Tracers");
Tracers:AddToggle("MANIP_Beams", {
    Text = "Bullet Tracers",
    Default = getgenv().wh_tracer_beams,
    Callback = function(v) getgenv().wh_tracer_beams = v; end;
}):AddColorPicker("MANIP_BeamColor", {
    Default = getgenv().wh_beam_color,
    Title = "Tracer Beam Color",
    Callback = function(v) getgenv().wh_beam_color = v; end;
});
Tracers:AddToggle("MANIP_Barrel", {
    Text = "Start At Barrel",
    Default = getgenv().wh_tracer_barrel,
    Tooltip = "Tracers start at the weapon's Silencer/Muzzle/Barrel part instead of your body. Falls back to the body when the weapon has none.",
    Callback = function(v) getgenv().wh_tracer_barrel = v; end;
});
Tracers:AddSlider("MANIP_Life", {
    Text = "Tracer Lifetime",
    Default = getgenv().wh_beam_lifetime,
    Min = 0.1, Max = 3, Rounding = 2, Compact = false,
    Callback = function(v) getgenv().wh_beam_lifetime = v; end;
});

local HE = Tabs.Main:AddLeftGroupbox("Head");
HE:AddToggle("HE_Enabled", {
    Text = "Head Expander",
    Default = getgenv().wh_head_expand,
    Callback = function(v)
        getgenv().wh_head_expand = v;
        if not v then restoreHeads(); end;
    end,
});
HE:AddSlider("HE_Size", {
    Text = "Expand Size",
    Default = getgenv().wh_head_size,
    Min = 0.5, Max = 25, Rounding = 1, Compact = false,
    Callback = function(v) getgenv().wh_head_size = v; end;
});
HE:AddSlider("HE_Transparency", {
    Text = "Head Transparency",
    Default = getgenv().wh_head_transparency,
    Min = 0, Max = 1, Rounding = 2, Compact = false,
    Tooltip = "0 = fully visible, 1 = invisible",
    Callback = function(v) getgenv().wh_head_transparency = v; end;
});

local CAM = Tabs.Main:AddLeftGroupbox("Camera");
CAM:AddToggle("CAM_Third", {
    Text = "Third Person",
    Default = getgenv().wh_third_person,
    Callback = function(v)
        getgenv().wh_third_person = v;
        applyCamera();
    end;
});
CAM:AddSlider("CAM_ThirdDist", {
    Text = "Third Person Distance",
    Default = getgenv().wh_third_person_distance,
    Min = 1, Max = 25, Rounding = 1, Compact = false,
    Callback = function(v)
        getgenv().wh_third_person_distance = v;
        applyCamera();
    end;
});

local FOV = Tabs.Main:AddRightGroupbox("Change FOV");
FOV:AddSlider("FOV_Value", {
    Text = "Field of View",
    Default = getgenv().wh_fov,
    Min = 30, Max = 120, Rounding = 0, Compact = false,
    Callback = function(v)
        getgenv().wh_fov = v;
        Fov.apply();
    end;
});
FOV:AddToggle("FOV_Enabled", {
    Text = "Enabled",
    Default = getgenv().wh_fov_enabled,
    Callback = function(v)
        getgenv().wh_fov_enabled = v;
        Fov.apply();
    end;
});
FOV:AddButton("FOV_Reset", function()
    getgenv().wh_fov = 70;
    Fov.apply();
    if Library and Library.Notify then Library:Notify("FOV reset to 70", 2); end;
end);

local ARMS = Tabs.Main:AddLeftGroupbox("Remove Arms");
ARMS:AddButton("ARMS_Remove", function()
    Arms.remove();
    if Library and Library.Notify then Library:Notify("Arms removed", 2); end;
end);

local CHARM = Tabs.Main:AddLeftGroupbox("Weapon Charm");
-- the colour picker has to hang off the toggle: groupboxes have no AddColorPicker
local CharmToggle = CHARM:AddToggle("CHARM_Enabled", {
    Text = "Enabled",
    Default = getgenv().wh_weapon_charm,
    Callback = function(v)
        getgenv().wh_weapon_charm = v;
        applyWeaponCharm();
    end;
});
CHARM:AddDropdown("CHARM_Material", {
    Values = WEAPON_MATERIALS,
    Default = getgenv().wh_weapon_material,
    Multi = false,
    Text = "Material",
    Callback = function(v)
        getgenv().wh_weapon_material = v;
        applyWeaponCharm();
    end,
});
CharmToggle:AddColorPicker("CHARM_Color", {
    Default = getgenv().wh_weapon_color,
    Title = "Weapon Colour",
    Callback = function(v)
        getgenv().wh_weapon_color = v;
        applyWeaponCharm();
    end;
});
CHARM:AddSlider("CHARM_Reflectance", {
    Text = "Reflectance",
    Default = getgenv().wh_weapon_reflectance,
    Min = 0, Max = 1, Rounding = 2, Compact = false,
    Tooltip = "idk 0 = matte, 1 = mirror",
    Callback = function(v)
        getgenv().wh_weapon_reflectance = v;
        applyWeaponCharm();
    end;
});
CHARM:AddSlider("CHARM_Transparency", {
    Text = "Transparency",
    Default = getgenv().wh_weapon_transparency,
    Min = 0, Max = 1, Rounding = 2, Compact = false,
    Callback = function(v)
        getgenv().wh_weapon_transparency = v;
        applyWeaponCharm();
    end;
});

local MOVE = Tabs.Main:AddRightGroupbox("Wallclimb");
MOVE:AddToggle("MOVE_Wallclimb", {
    Text = "Enabled",
    Default = getgenv().wh_wallclimb,
    Tooltip = "allow you to climb walls like spiderman",
    Callback = function(v)
        getgenv().wh_wallclimb = v;
        setWallclimb(v);
    end,
}):AddKeyPicker("MOVE_WallclimbKey", {
    Default = "None", -- linoria requires a Default; "None" means no key bound
    SyncToggleState = true,
    Mode = "Toggle",
    Text = "Wallclimb",
    Tooltip = "keybind for wallclimb",
});
MOVE:AddSlider("MOVE_WcSpeed", {
    Text = "Climb Speed",
    Default = getgenv().wh_wc_speed,
    Min = 5, Max = 80, Rounding = 0, Compact = false,
    Callback = function(v) getgenv().wh_wc_speed = v; end;
});

-- Right column: ESP (ported from esp.lua)
local ESP = Tabs.Main:AddRightGroupbox("ESP");
ESP:AddToggle("ESP_Enabled", {
    Text = "Enabled",
    Default = getgenv().wh_esp_toggle,
    Tooltip = "Master one",
    Callback = function(v) getgenv().wh_esp_toggle = v; end;
});
ESP:AddToggle("ESP_NPCs", {
    Text = "NPCs",
    Default = getgenv().wh_esp_npcs,
    Callback = function(v) getgenv().wh_esp_npcs = v; end;
});
ESP:AddToggle("ESP_PlayersOnly", {
    Text = "Players Only",
    Default = getgenv().wh_esp_players_only,
    Callback = function(v) getgenv().wh_esp_players_only = v; end;
});
ESP:AddToggle("ESP_IgnoreBots", {
    Text = "Ignore Bots",
    Default = getgenv().wh_esp_ignore_bots,
    Callback = function(v) getgenv().wh_esp_ignore_bots = v; end;
});
ESP:AddToggle("ESP_Corpses", {
    Text = "Corpse ESP",
    Default = getgenv().wh_esp_corpses,
    Callback = function(v) getgenv().wh_esp_corpses = v; end;
});
ESP:AddToggle("ESP_CorpseName", {
    Text = "Corpse Name",
    Default = getgenv().wh_esp_corpses_hide_name,
    Callback = function(v) getgenv().wh_esp_corpses_hide_name = v; end;
});
ESP:AddSlider("ESP_MaxDist", {
    Text = "Max Distance (meter not mile)",
    Default = getgenv().wh_esp_maxdistance,
    Min = 0, Max = 1000, Rounding = 0, Compact = false,
    Callback = function(v) getgenv().wh_esp_maxdistance = v; end;
});
ESP:AddDropdown("ESP_Font", {
    Values = { "UI", "System", "Plex", "Monospace" },
    Default = getgenv().wh_esp_font,
    Multi = false,
    Text = "Font",
    Callback = function(v) getgenv().wh_esp_font = v; end;
});
ESP:AddSlider("ESP_FontSize", {
    Text = "Font Size",
    Default = getgenv().wh_esp_fontsize,
    Min = 8, Max = 28, Rounding = 0, Compact = false,
    Callback = function(v) getgenv().wh_esp_fontsize = v; end;
});
ESP:AddToggle("ESP_TextOutline", {
    Text = "Text Outline",
    Default = getgenv().wh_esp_names_outline,
    Callback = function(v) getgenv().wh_esp_names_outline = v; end;
});
ESP:AddToggle("ESP_Box", {
    Text = "Box",
    Default = getgenv().wh_esp_box,
    Callback = function(v) getgenv().wh_esp_box = v; end,
}):AddColorPicker("ESP_BoxColor", {
    Default = getgenv().wh_esp_box_color,
    Title = "Box Color",
    Callback = function(v) getgenv().wh_esp_box_color = v; end;
});
ESP:AddSlider("ESP_BoxThickness", {
    Text = "Box Thickness",
    Default = getgenv().wh_esp_box_thickness,
    Min = 0, Max = 8, Rounding = 0, Compact = false,
    Callback = function(v) getgenv().wh_esp_box_thickness = v; end;
});
ESP:AddToggle("ESP_BoxFill", {
    Text = "Box Fill",
    Default = getgenv().wh_esp_box_fill,
    Callback = function(v) getgenv().wh_esp_box_fill = v; end,
}):AddColorPicker("ESP_BoxFillColor", {
    Default = getgenv().wh_esp_box_fill_color,
    Title = "Box Fill Color",
    Callback = function(v) getgenv().wh_esp_box_fill_color = v; end;
});
ESP:AddSlider("ESP_BoxFillTrans", {
    Text = "Box Fill Transparency",
    Default = getgenv().wh_esp_box_fill_transparency,
    Min = 0, Max = 1, Rounding = 2, Compact = false,
    Callback = function(v) getgenv().wh_esp_box_fill_transparency = v; end;
});
ESP:AddToggle("ESP_BoxOutline", {
    Text = "Box Outline",
    Default = getgenv().wh_esp_box_outline,
    Callback = function(v) getgenv().wh_esp_box_outline = v; end,
}):AddColorPicker("ESP_BoxOutlineColor", {
    Default = getgenv().wh_esp_box_outline_color,
    Title = "Box Outline Color",
    Callback = function(v) getgenv().wh_esp_box_outline_color = v; end;
});
ESP:AddSlider("ESP_BoxOutlineThickness", {
    Text = "Outline Thickness",
    Default = getgenv().wh_esp_box_outline_thickness,
    Min = 0, Max = 10, Rounding = 0, Compact = false,
    Callback = function(v) getgenv().wh_esp_box_outline_thickness = v; end;
});
local CharmToggle = ESP:AddToggle("ESP_Charms", {
    Text = "Charms",
    Default = getgenv().wh_esp_charms,
    Callback = function(v) getgenv().wh_esp_charms = v; end,
});
CharmToggle:AddColorPicker("ESP_CharmsVisible", {
    Default = getgenv().wh_esp_charms_visible_color,
    Title = "Visible Colour",
    Callback = function(v) getgenv().wh_esp_charms_visible_color = v; end;
});
CharmToggle:AddColorPicker("ESP_CharmsHidden", {
    Default = getgenv().wh_esp_charms_hidden_color,
    Title = "Hidden Colour",
    Callback = function(v) getgenv().wh_esp_charms_hidden_color = v; end;
});
ESP:AddSlider("ESP_CharmsTrans", {
    Text = "Charms Transparency",
    Default = getgenv().wh_esp_charms_transparency,
    Min = 0, Max = 1, Rounding = 2, Compact = false,
    Callback = function(v) getgenv().wh_esp_charms_transparency = v; end;
});
ESP:AddButton("ESP_Info", function()
    local report = espReport();
    warn(report);
    print(report);
    if Library and Library.Notify then Library:Notify(report, 12); end;
end);

local ESPText = Tabs.Main:AddRightGroupbox("ESP Text");
ESPText:AddToggle("ESP_Names", {
    Text = "Username",
    Default = getgenv().wh_esp_names,
    Callback = function(v) getgenv().wh_esp_names = v; end,
}):AddColorPicker("ESP_NamesColor", {
    Default = getgenv().wh_esp_names_color,
    Title = "Username Color",
    Callback = function(v) getgenv().wh_esp_names_color = v; end;
});
ESPText:AddToggle("ESP_DisplayName", {
    Text = "Display Name",
    Default = getgenv().wh_esp_displayname,
    Callback = function(v) getgenv().wh_esp_displayname = v; end,
}):AddColorPicker("ESP_DisplayNameColor", {
    Default = getgenv().wh_esp_displayname_color,
    Title = "Display Name Color",
    Callback = function(v) getgenv().wh_esp_displayname_color = v; end;
});
ESPText:AddToggle("ESP_Distance", {
    Text = "Distance",
    Default = getgenv().wh_esp_distance,
    Callback = function(v) getgenv().wh_esp_distance = v; end,
}):AddColorPicker("ESP_DistanceColor", {
    Default = getgenv().wh_esp_distance_color,
    Title = "Distance Color",
    Callback = function(v) getgenv().wh_esp_distance_color = v; end;
});
ESPText:AddToggle("ESP_Weapon", {
    Text = "Weapon",
    Default = getgenv().wh_esp_weapon,
    Callback = function(v) getgenv().wh_esp_weapon = v; end,
}):AddColorPicker("ESP_WeaponColor", {
    Default = getgenv().wh_esp_weapon_color,
    Title = "Weapon Color",
    Callback = function(v) getgenv().wh_esp_weapon_color = v; end;
});

local ESPHP = Tabs.Main:AddRightGroupbox("ESP Health");
-- both bar colours hang off the health-bar toggle
local ESPHPBar = ESPHP:AddToggle("ESP_HPBar", {
    Text = "Health Bar",
    Default = getgenv().wh_esp_health,
    Callback = function(v) getgenv().wh_esp_health = v; end,
});
ESPHPBar:AddColorPicker("ESP_HPColorTop", {
    Default = getgenv().wh_esp_health_color_top,
    Title = "Health Color (Full)",
    Callback = function(v) getgenv().wh_esp_health_color_top = v; end;
});
ESPHPBar:AddColorPicker("ESP_HPColorBottom", {
    Default = getgenv().wh_esp_health_color_bottom,
    Title = "Health Color (Empty)",
    Callback = function(v) getgenv().wh_esp_health_color_bottom = v; end;
});
ESPHP:AddSlider("ESP_HPThickness", {
    Text = "Bar Thickness",
    Default = getgenv().wh_esp_health_thickness,
    Min = 1, Max = 8, Rounding = 0, Compact = false,
    Callback = function(v) getgenv().wh_esp_health_thickness = v; end;
});
ESPHP:AddToggle("ESP_HPText", {
    Text = "Health Text",
    Default = getgenv().wh_esp_health_text,
    Callback = function(v) getgenv().wh_esp_health_text = v; end;
});

-- Right column: Gun Mods (one toggle per mod, each fully independent)
local GUNS = Tabs.Main:AddRightGroupbox("Gun Mods");
for _, mod in next, GunMods.list do
    GUNS:AddToggle("GUN_" .. mod.Key, {
        Text = mod.Text,
        Default = getgenv()[mod.Setting],
        Tooltip = mod.Tooltip,
        Callback = function(v)
            getgenv()[mod.Setting] = v;
            GunMods.refresh(); -- re-apply every mod so only this one changes
        end;
    });
end;
GUNS:AddButton("GUN_Reapply", function()
    GunMods.refresh();
    if Library and Library.Notify then Library:Notify("Gun mods re-applied", 2); end;
end);

-- Right column: Lighting
local VIS = Tabs.Main:AddRightGroupbox("Lighting");
VIS:AddToggle("VIS_Lighting", {
    Text = "Enabled",
    Default = getgenv().wh_lighting_enabled,
    Callback = function(v)
        getgenv().wh_lighting_enabled = v;
        applyLighting(v);
    end;
});
VIS:AddSlider("VIS_LBrightness", {
    Text = "Brightness",
    Default = getgenv().wh_lighting_brightness,
    Min = 0, Max = 10, Rounding = 1, Compact = false,
    Callback = function(v)
        getgenv().wh_lighting_brightness = v;
        applyLightingValues();
    end;
});
local AmbientToggle = VIS:AddToggle("VIS_LAmbient", {
    Text = "Ambient",
    Default = getgenv().wh_lighting_ambient_enabled,
    Callback = function(v)
        getgenv().wh_lighting_ambient_enabled = v;
        applyLightingValues();
    end;
});
AmbientToggle:AddColorPicker("VIS_LAmbientIndoor", {
    Default = getgenv().wh_lighting_ambient,
    Title = "Ambient Indoor",
    Callback = function(v)
        getgenv().wh_lighting_ambient = v;
        applyLightingValues();
    end;
});
AmbientToggle:AddColorPicker("VIS_LAmbientOutdoor", {
    Default = getgenv().wh_lighting_outdoor_ambient,
    Title = "Ambient Outdoor",
    Callback = function(v)
        getgenv().wh_lighting_outdoor_ambient = v;
        applyLightingValues();
    end;
});
VIS:AddSlider("VIS_LClock", {
    Text = "Clock Time",
    Default = getgenv().wh_lighting_clocktime,
    Min = 0, Max = 24, Rounding = 1, Compact = false,
    Callback = function(v)
        getgenv().wh_lighting_clocktime = v;
        applyLightingValues();
    end;
});
local FogToggle = VIS:AddToggle("VIS_LFog", {
    Text = "Fog",
    Default = getgenv().wh_lighting_fog_enabled,
    Callback = function(v)
        getgenv().wh_lighting_fog_enabled = v;
        applyLightingValues();
    end;
});
FogToggle:AddColorPicker("VIS_LFogColor", {
    Default = getgenv().wh_lighting_fog_color,
    Title = "Fog Color",
    Callback = function(v)
        getgenv().wh_lighting_fog_color = v;
        applyLightingValues();
    end;
});
VIS:AddSlider("VIS_LFogEnd", {
    Text = "Fog End",
    Default = getgenv().wh_lighting_fog_end,
    Min = 0, Max = 100000, Rounding = 0, Compact = false,
    Tooltip = "who even reads tooltips?",
    Callback = function(v)
        getgenv().wh_lighting_fog_end = v;
        applyLightingValues();
    end;
});
VIS:AddSlider("VIS_LFogStart", {
    Text = "Fog Start",
    Default = getgenv().wh_lighting_fog_start,
    Min = 0, Max = 5000, Rounding = 0, Compact = false,
    Callback = function(v)
        getgenv().wh_lighting_fog_start = v;
        applyLightingValues();
    end;
});
VIS:AddToggle("VIS_LShadows", {
    Text = "Global Shadows",
    Default = getgenv().wh_lighting_global_shadows,
    Callback = function(v)
        getgenv().wh_lighting_global_shadows = v;
        applyLightingValues();
    end;
});
VIS:AddSlider("VIS_LExposure", {
    Text = "Exposure Compensation",
    Default = getgenv().wh_lighting_exposure,
    Min = -3, Max = 3, Rounding = 1, Compact = false,
    Callback = function(v)
        getgenv().wh_lighting_exposure = v;
        applyLightingValues();
    end;
});
VIS:AddToggle("VIS_LPostFX", {
    Text = "Keep Post Effects",
    Default = getgenv().wh_lighting_post_effects,
    Callback = function(v)
        getgenv().wh_lighting_post_effects = v;
        refreshLighting();
    end;
});
VIS:AddToggle("VIS_LAtmosphere", {
    Text = "Keep Atmosphere",
    Default = getgenv().wh_lighting_atmosphere,
    Callback = function(v)
        getgenv().wh_lighting_atmosphere = v;
        refreshLighting();
    end;
});
VIS:AddSlider("VIS_LCelestial", {
    Text = "Celestial Brightness",
    Default = getgenv().wh_lighting_celestial_intensity,
    Min = 0, Max = 5, Rounding = 2, Compact = false,
    Callback = function(v)
        getgenv().wh_lighting_celestial_intensity = v;
        applyLightingValues();
    end;
});
VIS:AddSlider("VIS_LEnvDiffuse", {
    Text = "Env Diffuse Scale",
    Default = getgenv().wh_lighting_env_diffuse,
    Min = 0, Max = 2, Rounding = 2, Compact = false,
    Callback = function(v)
        getgenv().wh_lighting_env_diffuse = v;
        applyLightingValues();
    end;
});
VIS:AddSlider("VIS_LEnvSpecular", {
    Text = "Env Specular Scale",
    Default = getgenv().wh_lighting_env_specular,
    Min = 0, Max = 2, Rounding = 2, Compact = false,
    Callback = function(v)
        getgenv().wh_lighting_env_specular = v;
        applyLightingValues();
    end;
});

--======================== TEARDOWN ========================
-- single cleanup path: the unload button, the library's own OnUnload and the
-- double-execution guard at the top of the file all go through here
local tornDown = false;
local function teardown()
    if tornDown then return; end;
    tornDown = true;
    Running = false;
    setWallclimb(false);
    if tpKillTarget then tpKillStop(); end;
    restoreHeads();
    clearCamera();
    Fov.clear();
    restoreWeaponCharm();
    applyLighting(false);
    for m in next, espObjects do CleanupESP(m); end;
    table.clear(espPlayer);
    removeDrawings(); -- fov circle, tracer line, status text, every ESP drawing
    for _, v in next, Connections do v:Disconnect(); end;
    if getgenv()[INSTANCE_KEY] then getgenv()[INSTANCE_KEY] = nil; end;
end;

-- let the next execution of this file replace this one cleanly
if getgenv()[INSTANCE_KEY] == nil then getgenv()[INSTANCE_KEY] = {}; end;
getgenv()[INSTANCE_KEY].stop = teardown;

-- UI Settings tab
local Menu = Tabs.UISettings:AddLeftGroupbox("Menu");
Menu:AddButton("Unload", function()
    Library:Notify("Unloading script...");
    Library:Toggle();
    task.wait(0.3);
    teardown();
    Library:Unload();
end);
Menu:AddLabel("Menu bind: LeftControl (toggle UI)");
Menu:AddButton("Toggle UI", function() Library:Toggle(); end);

if ThemeManager and SaveManager then
    ThemeManager:SetLibrary(Library);
    SaveManager:SetLibrary(Library);
    ThemeManager:SetFolder("aimwhere");
    SaveManager:SetFolder("aimwhere");
    SaveManager:BuildConfigSection(Tabs.UISettings);
    ThemeManager:ApplyToTab(Tabs.UISettings);
    SaveManager:LoadAutoloadConfig();
end;

-- keep the combat whitelist pointed at the dropdown's table (survives config loads)
getgenv().wh_whitelist = WhitelistDropdown.Value;

Library:OnUnload(function()
    teardown();
end);

Library:Notify("script loaded", 4);

--======================== HIT LOGS ========================
-- Every shot we fire is parked with who it was aimed at, which body part and how far away
-- they were, then resolved a moment later: their health dropping means it landed, zero
-- means a kill, and no change after a short wait means a miss (with a reason).
--   Shot hit bestplayer67 in the head, 210 meters
--   Shot killed bestplayer67 in the head, 210 meters
--   Shot miss bestplayer67, due to "Too far away"   (past the hit range)
--   Shot miss bestplayer67, due to "Not visible"    (no body part was reachable)
--   Shot miss bestplayer67, due to "Unknown"        (went on shooting, no damage landed)
HitLogs = (function()
    local WATCH = 0.7;  -- seconds before an unchanged target counts as a miss
    local FAR = 205;    -- metres: past the hit range, the miss reason is "Too far away"
    local MAX = 24;     -- never hold more than this many undecided shots
    local pending = {};

    local function meters(m)
        return math.floor((m or 0) + 0.5);
    end

    local function notify(text)
        pcall(function() Library:Notify(text, 3); end);
    end

    -- called from the bullet hook, right after we redirect a shot at somebody
    local function note(part, distance, visible)
        if not getgenv().wh_hitlogs or not part then return; end;
        local char = part:FindFirstAncestorOfClass("Model");
        local hum = char and char:FindFirstChildOfClass("Humanoid");
        if not (char and hum) then return; end;
        local player = Players:GetPlayerFromCharacter(char);
        pending[#pending+1] = {
            char = char,
            hum = hum,
            health = hum.Health,
            name = player and player.Name or char.Name or "?",
            part = string.lower(part.Name or "body"),
            meters = meters(distance),
            visible = visible ~= false, -- false = the shot went at a hidden target
            at = os.clock(),
        };
        if #pending > MAX then table.remove(pending, 1) end;
    end

    local function resolve(entry, kind, reason)
        if kind == "killed" then
            notify(("Shot killed %s in the %s, %d meters"):format(entry.name, entry.part, entry.meters));
        elseif kind == "hit" then
            notify(("Shot hit %s in the %s, %d meters"):format(entry.name, entry.part, entry.meters));
        else
            notify(("Shot miss %s, due to \"%s\""):format(entry.name, reason));
        end;
    end

    -- polled from the heartbeat: health down = hit, zero = kill, nothing = miss
    local function tick()
        if not getgenv().wh_hitlogs or #pending == 0 then return; end;
        local now = os.clock();
        for i = #pending, 1, -1 do
            local entry = pending[i];
            local hum = entry.hum;
            if entry.char.Parent == nil or hum.Parent == nil then
                table.remove(pending, i); -- they despawned mid flight, nothing to report
            elseif hum.Health <= 0 then
                table.remove(pending, i);
                resolve(entry, "killed");
            elseif hum.Health < entry.health then
                table.remove(pending, i);
                resolve(entry, "hit");
            elseif now - entry.at >= WATCH then
                table.remove(pending, i);
                -- why it missed: out of range, no body part was reachable, or it just did
                -- not land (they moved, the server disagreed, a wall ate it, ...)
                local reason = if entry.meters > FAR then "Too far away"
                    elseif not entry.visible then "Not visible"
                    else "Unknown";
                resolve(entry, "miss", reason);
            end;
        end;
    end

    return { note = note, tick = tick, count = function() return #pending end };
end)();

--======================== FEEDBACK UI ========================
local FEED = Tabs.Main:AddLeftGroupbox("Feedback");
FEED:AddToggle("HIT_Logs", {
    Text = "Hit Logs",
    Default = getgenv().wh_hitlogs,
    Tooltip = "Notifies every shot: hit, kill, or miss with the reason",
    Callback = function(v) getgenv().wh_hitlogs = v; end;
});

table.insert(Connections, RunService.Heartbeat:Connect(function()
    if not Running then return; end;
    if not getgenv().wh_hitlogs then return; end;
    pcall(HitLogs.tick); -- must never throw inside the game's heartbeat
end));

--======================== RENDER LOOP ========================
-- While we are dead or extracting there is nothing to aim at, and the game takes over
-- both the camera and the cursor, so the whole aim HUD (FOV circle, tracer, status
-- text) is taken down instead of being drawn from a stale or captured cursor. The frame
-- is also wrapped, so a single bad frame can never leave a half drawn line on screen.
local function playerAlive()
    local char = plr.Character;
    if not char then return false; end;
    local hum = char:FindFirstChildOfClass("Humanoid");
    return hum ~= nil and hum.Health > 0;
end;

local function renderFrame()
    if not playerAlive() then
        fovCircle.Visible = false;
        TracerLine.Visible = false;
        hideStatus();
        UpdateESP();
        updateHeadExpand();
        return;
    end;

    fovCircle.Position = centerPoint();
    fovCircle.Radius = getgenv().wh_fov_size or 300;
    -- ragebot targets 360°, the FOV circle is meaningless then and gets hidden
    fovCircle.Visible = (getgenv().wh_fov_toggle and getgenv().wh_silent_aim and not getgenv().wh_ragebot) or false;
    fovCircle.Color = getgenv().wh_fov_color;

    local tPart, _, tVis, _, tMeters = getTarget();

    if getgenv().wh_tracers and getgenv().wh_silent_aim and tPart then
        local sp, onScreen = cam:WorldToViewportPoint(tPart.Position);
        -- the line has to start where the FOV circle actually is. The raw mouse position
        -- is not that: with a centre FOV the circle is in the middle of the screen, and
        -- while dead / extracting the game captures or moves the cursor, which used to drag
        -- the line off into a corner even though the circle looked fine.
        local from = centerPoint();
        if onScreen and isFiniteVec2(sp) and isFiniteVec2(from) then
            local to = toScreen(sp);
            -- a target behind the death camera or far outside the viewport would draw a
            -- line across the whole screen, so only follow it while it is reasonably on it
            local view = cam.ViewportSize;
            if to.X > -view.X and to.X < view.X * 2 and to.Y > -view.Y and to.Y < view.Y * 2 then
                TracerLine.From = from;
                TracerLine.To = to;
                TracerLine.Color = getgenv().wh_tracer_color;
                TracerLine.Visible = true;
            else
                TracerLine.Visible = false;
            end;
        else
            TracerLine.Visible = false;
        end;
    else
        TracerLine.Visible = false;
    end;

    -- status readout under the FOV circle: target data with coloured words, and in rage
    -- mode a list of the 3 closest visible targets (the top one is the one being shot)
    if getgenv().wh_silent_aim and tPart then
        local lines = {};
        if getgenv().wh_ragebot then
            local list, total, capped = rageTargets(cam.CFrame.Position);
            if #list > 0 then
                -- the scan stops once it has 3, so this is what is really shown (the
                -- "+" marks that more targets are out there than the scan bothered to find)
                lines[1] = {
                    { "rage", COL_WHITE }, { SEP, COL_WHITE },
                    { total .. (capped and "+" or "") .. " visible", COL_GREEN },
                };
                for i, entry in next, list do
                    lines[i+1] = targetLine(entry.part, entry.meters, nil);
                end;
            else
                lines[1] = { { "rage", COL_WHITE }, { SEP, COL_WHITE }, { "no targets visible", COL_RED } };
            end;
        else
            lines[1] = targetLine(tPart, tMeters, tVis);
        end;
        local cx = centerPoint();
        local offset = fovCircle.Visible and ((getgenv().wh_fov_size or 300) + 26) or 52;
        drawStatus(lines, cx, cx.Y + offset);
    else
        hideStatus();
    end;

    UpdateESP();
    updateHeadExpand();
end;

table.insert(Connections, RunService.RenderStepped:Connect(function()
    if not Running then return; end;
    local ok, err = pcall(renderFrame);
    if not ok then
        HookStatus.renderErrors = HookStatus.renderErrors + 1;
        TracerLine.Visible = false; -- never leave a stale line behind after an error
        HookStatus.last = "render error: " .. tostring(err);
    end;
end));

--======================== ESP SCANNING ========================
table.insert(Connections, workspace.DescendantAdded:Connect(function(v)
    if Running and v:IsA("Model") then
        task.wait(0.5);
        ApplyESP(v);
    end;
end));

-- corpses live in workspace:Containers and appear there as bodies drop, so that folder
-- gets its own sweep (the regular scan ignores anything without a root part)
local function scanContainers()
    local c = containersFolder();
    if not c then return; end;
    for _, v in next, c:GetDescendants() do
        if v:IsA("Model") and isCorpseModel(v) then ApplyESP(v); end;
    end;
end

-- a plain task, not a connection: Connections holds Disconnectables only
task.spawn(function()
    while Running do
        task.wait(1);
        if not Running then break; end;
        scanContainers();
    end;
end);

for _, v in next, workspace:GetDescendants() do
    if v:IsA("Model") then task.spawn(ApplyESP, v); end;
end;

-- pick up respawns / late joins immediately instead of waiting for the rescan
local function watchPlayer(p)
    if p == plr or watchedPlayers[p] then return; end;
    watchedPlayers[p] = true;
    table.insert(Connections, p.CharacterAdded:Connect(function(char)
        task.defer(function() if char then ApplyESP(char) end end);
    end));
end;
for _, p in next, Players:GetPlayers() do watchPlayer(p); end;
table.insert(Connections, Players.PlayerAdded:Connect(watchPlayer));

-- slow rescan so the esp is self-healing: respawns rebuild the whole rig, players can
-- join late, and a model that only becomes a character later still gets picked up
task.spawn(function()
    while Running do
        task.wait(2);
        if not Running then break; end;
        for _, v in next, workspace:GetDescendants() do
            if v:IsA("Model") and not espObjects[v] then ApplyESP(v); end;
        end;
    end;
end);

--======================== ESP CLEANUP (dead models) ========================
table.insert(Connections, RunService.Heartbeat:Connect(function()
    if not Running then return; end;
    for model in next, espObjects do
        if not model:IsDescendantOf(workspace) then
            CleanupESP(model);
        end;
    end;
end));
