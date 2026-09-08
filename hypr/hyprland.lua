--  _   _                  _                 _
-- | | | |_   _ _ __  _ __| | __ _ _ __   __| |
-- | |_| | | | | '_ \| '__| |/ _` | '_ \ / _` |
-- |  _  | |_| | |_) | |  | | (_| | | | | (_| |
-- |_| |_|\__, | .__/|_|  |_|\__,_|_| |_|\__,_|
--        |___/|_|
--
-- -----------------------------------------------------
-- Lua port of the old hyprland.conf (hyprlang is deprecated since 0.55).
-- API reference: /usr/share/hypr/stubs/hl.meta.lua
-- Example config: /usr/share/hypr/hyprland.lua


------------------
---- MONITORS ----
------------------

-- See https://wiki.hypr.land/configuring/core/monitors/
hl.monitor({ output = "eDP-1",    mode = "2560x1600@165", position = "0x0",     scale = 1 })
hl.monitor({ output = "HDMI-A-1", mode = "1920x1080@60",  position = "-1920x0", scale = 1 })
hl.monitor({ output = "DP-1",     mode = "2560x1440@60",  position = "-2560x0", scale = 1 })
-- Fallback for unlisted connectors (DP-9 is on the dGPU)
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })


---------------------
---- MY PROGRAMS ----
---------------------

-- These used to be $terminal / $fileManager / $menu. Plain Lua locals now;
-- passed to keybinds.lua at the bottom of this file.
local programs = {
    terminal    = "alacritty", -- kitty
    fileManager = "thunar",
    menu        = "rofi -show drun -replace -i",
}


-------------------
---- AUTOSTART ----
-------------------

-- The old `exec-once = ...` lines. See
-- https://wiki.hypr.land/configuring/core/autostart/
hl.on("hyprland.start", function()
    hl.exec_cmd("pamixer -m")
    hl.exec_cmd("pactl set-source-mute 1 true")
    -- Load Dunst Notification Manager
    hl.exec_cmd("dunst")
    -- Using hypridle to start hyprlock
    hl.exec_cmd("hypridle")
    -- Load cliphist history
    hl.exec_cmd("wl-paste --watch cliphist store")
    -- Initialize wallpaper daemon
    hl.exec_cmd("hyprpaper")
    -- Launch Waybar
    hl.exec_cmd("waybar -c .config/waybar/config.jsonc -s .config/waybar/style.css")
    hl.exec_cmd("hyprctl setcursor Bibata-Modern-Ice 24")
    -- xdg-desktop-portal-hyprland can get environment variables from systemd
    -- hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
end)


-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

hl.env("XCURSOR_SIZE", "24")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
-- card2 = AMD iGPU (eDP-1), card1 = NVIDIA dGPU (DP-9).
-- List both or external outputs are invisible; first entry renders.
-- hl.env("AQ_DRM_DEVICES", "/dev/dri/card2") -- old
hl.env("AQ_DRM_DEVICES", "/dev/dri/card2:/dev/dri/card1")
-- Needs libva-nvidia-driver (not installed); the override also stops
-- libva from auto-selecting radeonsi.
-- hl.env("LIBVA_DRIVER_NAME", "nvidia") -- old
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
-- hl.env("NVD_BACKEND", "direct") -- old


---------------
---- INPUT ----
---------------

hl.config({
    input = {
        kb_layout  = "dk",
        kb_variant = "",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",

        follow_mouse = 2,

        sensitivity = 0, -- -1.0 to 1.0, 0 means no modification.

        touchpad = {
            natural_scroll = true,
        },
    },

    cursor = {
        no_hardware_cursors = true,
    },
})


-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.config({
    general = {
        gaps_in     = 3,
        gaps_out    = 0,
        border_size = 0,

        col = {
            -- Was: rgba(33ccffee) rgba(00ff99ee) 45deg
            active_border   = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 },
            inactive_border = "rgba(595959aa)",
        },

        layout = "dwindle",

        -- See https://wiki.hypr.land/configuring/advanced-configuration/tearing/
        allow_tearing = false,
    },

    decoration = {
        rounding = 0,

        blur = {
            enabled = false,
            size    = 3,
            passes  = 1,
        },
        -- active_opacity   = 1.0,
        -- inactive_opacity = 0.6,
    },

    animations = {
        enabled = false,
    },

    dwindle = {
        -- See https://wiki.hypr.land/configuring/layouts/dwindle-layout/
        -- pseudotile: master switch for pseudotiling, bound to mainMod + P in keybinds.lua
        preserve_split = true, -- you probably want this
    },

    misc = {
        force_default_wallpaper = 0,    -- Set to 0 or 1 to disable the anime mascot wallpapers
        disable_hyprland_logo   = true,
    },
})

-- Kept from the old config for when animations get switched back on; inert
-- while animations.enabled = false above.
hl.curve("myBezier", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })

hl.animation({ leaf = "windows",     enabled = true, speed = 7,  bezier = "myBezier" })
hl.animation({ leaf = "windowsOut",  enabled = true, speed = 7,  bezier = "default", style = "popin 80%" })
hl.animation({ leaf = "border",      enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 8,  bezier = "default" })
hl.animation({ leaf = "fade",        enabled = true, speed = 7,  bezier = "default" })
hl.animation({ leaf = "workspaces",  enabled = true, speed = 6,  bezier = "default" })


--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- See https://wiki.hypr.land/configuring/core/window-rules/
-- hl.window_rule({
--     name  = "float-kitty",
--     match = { class = "^(kitty)$", title = "^(kitty)$" },
--     float = true,
-- })
-- hl.window_rule({
--     name  = "suppress-maximize-events",
--     match = { class = ".*" },
--     suppress_event = "maximize",
-- })

-- hl.layer_rule({ name = "blur-rofi", match = { namespace = "rofi" }, blur = true })


------------------------------------------
---------------- Keybinds ----------------
------------------------------------------

-- keybinds.conf became keybinds.lua, which returns a function taking the
-- program table above (Lua locals don't cross file boundaries).
require("keybinds")(programs)
