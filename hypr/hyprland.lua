--  _   _                  _                 _
-- | | | |_   _ _ __  _ __| | __ _ _ __   __| |
-- | |_| | | | | '_ \| '__| |/ _` | '_ \ / _` |
-- |  _  | |_| | |_) | |  | | (_| | | | | (_| |
-- |_| |_|\__, | .__/|_|  |_|\__,_|_| |_|\__,_|
--        |___/|_|
--
-- -----------------------------------------------------
-- Lua port of hyprland.conf. Returns a single config table:
--   * config keywords  -> nested tables (input.touchpad.natural_scroll)
--   * repeated keywords (monitor, env, exec-once, bezier, animation)
--     -> arrays of strings/tables
--   * `$vars` -> plain Lua locals, interpolated with .. instead
--
-- Keybinds still live in keybinds.conf and are pulled in via `source`.

-- Variables that were `$terminal` etc. are just locals now.
local terminal = "alacritty" -- kitty
local file_manager = "thunar"
local menu = "rofi -show drun -replace -i"

return {
  -- See https://wiki.hyprland.org/Configuring/Monitors/
  monitor = {
    "eDP-1, 2560x1600@165, 0x0, 1", -- ,preferred,auto,auto
    -- "HDMI-A-1, 1920x1080@60, -1920x0, 1", -- , mirror, eDP-2
    "HDMI-A-1, 1920x1080@60, -1920x0, 1", -- , mirror, eDP-2
    "DP-1, 2560x1440@60, -2560x0, 1", -- , mirror, eDP-2
  },

  -- Executes at startup
  ["exec-once"] = {
    "pamixer -m",
    "pactl set-source-mute 1 true",
    "dunst", -- Load Dunst Notification Manager
    "hypridle", -- Using hypridle to start hyprlock
    "wl-paste --watch cliphist store", -- Load cliphist history
    "hyprpaper", -- Initialize waypaper
    -- Launch Waybar
    "waybar -c .config/waybar/config.jsonc -s .config/waybar/style.css",
    "hyprctl setcursor Bibata-Modern-Ice 24",
    -- xdg-desktop-portal-hyprland can get environment variables from systemd
    -- "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP",
  },

  -- Environment variables
  env = {
    "XCURSOR_SIZE,24",
    "QT_QPA_PLATFORMTHEME,qt6ct",
    "ELECTRON_OZONE_PLATFORM_HINT,auto",
    -- Nvidia env vars (aquamarine backend, RTX 5070 on card2/eDP-1)
    "AQ_DRM_DEVICES,/dev/dri/card2",
    "LIBVA_DRIVER_NAME,nvidia",
    "XDG_SESSION_TYPE,wayland",
    "__GLX_VENDOR_LIBRARY_NAME,nvidia",
    "NVD_BACKEND,direct",
  },

  input = {
    kb_layout = "dk",
    kb_variant = "",
    kb_model = "",
    kb_options = "",
    kb_rules = "",

    follow_mouse = 2,

    touchpad = {
      natural_scroll = true,
    },

    sensitivity = 0, -- -1.0 to 1.0, 0 means no modification.
  },

  general = {
    gaps_in = 3,
    gaps_out = 0,
    border_size = 0,
    ["col.active_border"] = "rgba(33ccffee) rgba(00ff99ee) 45deg",
    ["col.inactive_border"] = "rgba(595959aa)",

    layout = "dwindle",

    -- Please see https://wiki.hyprland.org/Configuring/Tearing/ before you turn this on
    allow_tearing = false,
  },

  decoration = {
    rounding = 0,

    blur = {
      enabled = false,
      size = 3,
      passes = 1,
    },
    -- active_opacity = 1.0,
    -- inactive_opacity = 0.6,
  },

  animations = {
    enabled = false,

    bezier = {
      "myBezier, 0.05, 0.9, 0.1, 1.05",
    },

    animation = {
      "windows, 1, 7, myBezier",
      "windowsOut, 1, 7, default, popin 80%",
      "border, 1, 10, default",
      "borderangle, 1, 8, default",
      "fade, 1, 7, default",
      "workspaces, 1, 6, default",
    },
  },

  dwindle = {
    -- See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
    -- master switch for pseudotiling; enabling is bound to mainMod + P in keybinds.conf
    -- pseudotile = true,
    preserve_split = true, -- you probably want this
  },

  master = {
    -- See https://wiki.hyprland.org/Configuring/Master-Layout/ for more
    -- new_is_master = true,
  },

  gestures = {},

  cursor = {
    no_hardware_cursors = true,
  },

  misc = {
    force_default_wallpaper = 0, -- Set to 0 or 1 to disable the anime mascot wallpapers
    disable_hyprland_logo = true,
  },

  -- Example windowrule v1
  -- windowrule = { "float, ^(kitty)$" },
  -- Example windowrule v2
  -- windowrulev2 = { "float,class:^(kitty)$,title:^(kitty)$" },
  -- See https://wiki.hyprland.org/Configuring/Window-Rules/ for more
  -- windowrulev2 = { "suppressevent maximize, class:.*" }, -- You'll probably like this.

  -- layerrule = { "blur, rofi" },

  ------------------------------------------
  ---------------- Keybinds ----------------
  ------------------------------------------

  source = {
    "~/.config/hypr/keybinds.conf",
  },

  -- Unused here, but kept so the launcher vars stay documented alongside
  -- the binds that reference them in keybinds.conf.
  _vars = {
    terminal = terminal,
    fileManager = file_manager,
    menu = menu,
  },
}
