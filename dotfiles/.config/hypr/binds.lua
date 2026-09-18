---------------------
---- KEYBINDINGS ----
---------------------

-- Define commands to be executed by keybinds
local launcher_cmd = "fuzzel"
local exit_hyprland_cmd = "command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"
local raise_volume_cmd = "wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
local lower_volume_cmd = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
local mute_volume_cmd = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
local mute_mic_cmd = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
local raise_brightness_cmd = "brightnessctl -e4 -n2 set 5%+"
local lower_brightness_cmd = "brightnessctl -e4 -n2 set 5%-"
local player_next_cmd = "playerctl next"
local play_pause_cmd = "playerctl play-pause"
local player_previous_cmd = "playerctl previous"

-- Miscellaneous keybinds 
hl.bind("SUPER + SPACE", hl.dsp.exec_cmd(launcher_cmd))
hl.bind("MENU", hl.dsp.no_op(""))
hl.bind("MENU + A", hl.dsp.window.close({}))
hl.bind("ALT + MENU + A", hl.dsp.exec_cmd(exit_hyprland_cmd))
hl.bind("MENU + S", hl.dsp.workspace.toggle_special("scratchpad"))
hl.bind("ALT + MENU + S", hl.dsp.window.move({workspace = "special:scratchpad"}))
hl.bind("MENU + F", hl.dsp.window.fullscreen({mode = "maximized", action = "toggle"}))
hl.bind("ALT + MENU + F", hl.dsp.window.fullscreen({mode = "fullscreen", action = "toggle"}))

-- Vim movement
hl.bind("SUPER + H", hl.dsp.focus({direction = "left"}))
hl.bind("SUPER + J", hl.dsp.focus({direction = "down"}))
hl.bind("SUPER + K", hl.dsp.focus({direction = "up"}))
hl.bind("SUPER + L", hl.dsp.focus({direction = "right"}))

hl.bind("SUPER + ALT + H", hl.dsp.window.move({direction = "left"}))
hl.bind("SUPER + ALT + J", hl.dsp.window.move({direction = "down"}))
hl.bind("SUPER + ALT + K", hl.dsp.window.move({direction = "up"}))
hl.bind("SUPER + ALT + L", hl.dsp.window.move({direction = "right"}))

-- Workspace keybinds
hl.bind("SUPER + U", hl.dsp.focus({workspace = "name:U"}))
hl.bind("SUPER + I", hl.dsp.focus({workspace = "name:I"}))
hl.bind("SUPER + O", hl.dsp.focus({workspace = "name:O"}))
hl.bind("SUPER + P", hl.dsp.focus({workspace = "name:P"}))
hl.bind("SUPER + BRACKETLEFT", hl.dsp.focus({workspace = "name:["}))
hl.bind("SUPER + BRACKETRIGHT", hl.dsp.focus({workspace = "name:]"}))

hl.bind("SUPER + ALT + U", hl.dsp.window.move({workspace = "name:U"}))
hl.bind("SUPER + ALT + I", hl.dsp.window.move({workspace = "name:I"}))
hl.bind("SUPER + ALT + O", hl.dsp.window.move({workspace = "name:O"}))
hl.bind("SUPER + ALT + P", hl.dsp.window.move({workspace = "name:P"}))
hl.bind("SUPER + ALT + BRACKETLEFT", hl.dsp.window.move({workspace = "name:["}))
hl.bind("SUPER + ALT + BRACKETRIGHT", hl.dsp.window.move({workspace = "name:]"}))

-- XF86 keybinds
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(raise_volume_cmd), {locked = true, repeating = true})
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(lower_volume_cmd), {locked = true, repeating = true})
hl.bind("XF86AudioMute", hl.dsp.exec_cmd(mute_volume_cmd), {locked = true, repeating = true})
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd(mute_mic_cmd), {locked = true, repeating = true})
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd(raise_brightness_cmd), {locked = true, repeating = true})
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(lower_brightness_cmd), {locked = true, repeating = true})
hl.bind("XF86AudioNext", hl.dsp.exec_cmd(player_next_cmd), {locked = true})
hl.bind("XF86AudioPause", hl.dsp.exec_cmd(play_pause_cmd), {locked = true})
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd(play_pause_cmd), {locked = true})
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd(player_previous_cmd), {locked = true})


--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- and https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

-- Example window rules that are useful

local suppressMaximizeRule = hl.window_rule({
    -- Ignore maximize requests from all apps. You'll probably like this.
    name  = "suppress-maximize-events",
    match = { class = ".*" },

    suppress_event = "maximize",
})
-- suppressMaximizeRule:set_enabled(false)

hl.window_rule({
    -- Fix some dragging issues with XWayland
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },

    no_focus = true,
})

-- Layer rules also return a handle.
-- local overlayLayerRule = hl.layer_rule({
--     name  = "no-anim-overlay",
--     match = { namespace = "^my-overlay$" },
--     no_anim = true,
-- })
-- overlayLayerRule:set_enabled(false)

-- Hyprland-run windowrule
hl.window_rule({
    name  = "move-hyprland-run",
    match = { class = "hyprland-run" },

    move  = "20 monitor_h-120",
    float = true,
})
