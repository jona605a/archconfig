------------------------------------------
---------------- Keybinds ----------------
------------------------------------------

-- Lua port of keybinds.conf. Required from hyprland.lua as
--   require("keybinds")(programs)
-- See https://wiki.hypr.land/configuring/core/binds/
--     https://wiki.hypr.land/configuring/core/dispatchers/

return function(programs)
    local terminal    = programs.terminal
    local fileManager = programs.fileManager
    local menu        = programs.menu

    local mainMod = "SUPER"

    hl.bind(mainMod .. " + Q",         hl.dsp.exec_cmd(terminal), { description = "Open Terminal" })
    -- Open Terminal in the nobodywho nix devshell
    hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.exec_cmd(terminal .. " -e fish -C worknix"))
    hl.bind(mainMod .. " + SHIFT + W", hl.dsp.window.close(), { description = "Kill active window" })
    hl.bind(mainMod .. " + M",         hl.dsp.exit(), { description = "Exit Hyprland" })
    hl.bind(mainMod .. " + E",         hl.dsp.exec_cmd(fileManager), { description = "Open File Manager" })
    hl.bind(mainMod .. " + R",         hl.dsp.exec_cmd(menu), { description = "Open application launcher" })
    hl.bind(mainMod .. " + B",         hl.dsp.exec_cmd("firefox"), { description = "Open Firefox" })
    hl.bind(mainMod .. " + L",         hl.dsp.exec_cmd("hyprlock"), { description = "Lock the screen" })
    hl.bind(mainMod .. " + F",         hl.dsp.window.fullscreen(), { description = "Toggle Fullscreen" })
    hl.bind(mainMod .. " + CTRL + Q",  hl.dsp.exec_cmd("wlogout"), { description = "Start wlogout" })
    hl.bind(mainMod .. " + T",         hl.dsp.window.float({ action = "toggle" }), { description = "Toggle floating" })

    -- Screenshots
    hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("grimblast copy area"), { description = "Screenshot to clipboard" })

    -- Sound control
    hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),   { locked = true })
    hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),    { locked = true, repeating = true })
    hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"),    { locked = true, repeating = true })
    hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })

    -- Brightness control
    hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 10%-"), { locked = true, repeating = true })
    hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl set 10%+"), { locked = true, repeating = true })

    -- Move focus with mainMod + arrow keys
    hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
    hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
    hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
    hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

    -- Switch workspaces with mainMod + [0-9]
    -- Move active window to a workspace with mainMod + SHIFT + [0-9]
    for i = 1, 10 do
        local key = i % 10 -- workspace 10 sits on key 0
        hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
        hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
    end

    -- Example special workspace (scratchpad)
    -- hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
    -- hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

    -- Scroll through existing workspaces with mainMod + scroll
    hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
    hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))
    hl.bind(mainMod .. " + J",          hl.dsp.focus({ workspace = "e-1" }))
    hl.bind(mainMod .. " + K",          hl.dsp.focus({ workspace = "e+1" }))

    -- Move/resize windows with mainMod + LMB/RMB and dragging
    hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
    hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
end
