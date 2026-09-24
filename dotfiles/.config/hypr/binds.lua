---------------------
---- KEYBINDINGS ----
---------------------

-- Define the keys that bind directly to a workspace
local workspace_keys = {"U", "I", "O", "P", "BRACKETLEFT", "BRACKETRIGHT"}

-- Define commands to be executed by keybinds
local launcher_cmd = "uwsm app -- fuzzel '--launch-prefix=uwsm app --'"
local exit_hyprland_cmd = "uwsm stop"
local raise_volume_cmd = "wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
local lower_volume_cmd = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
local mute_volume_cmd = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
local mute_mic_cmd = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
local raise_brightness_cmd = "brightnessctl -e4 -n2 set 5%+"
local lower_brightness_cmd = "brightnessctl -e4 -n2 set 5%-"
local player_next_cmd = "playerctl next"
local play_pause_cmd = "playerctl play-pause"
local player_previous_cmd = "playerctl previous"
local screenshot_cmd = 'grim -g "$(slurp)" $(xdg-user-dir PICTURES)/$(date +"%b-%d-%Y--%-H:%M:%S-screenshot.png")'

-- Miscellaneous keybinds 
hl.bind("SUPER + SPACE", hl.dsp.exec_cmd(launcher_cmd))
hl.bind("SUPER + SLASH", hl.dsp.window.close({}))
hl.bind("SUPER + ALT + SLASH", hl.dsp.exec_cmd(exit_hyprland_cmd))
hl.bind("SUPER + PERIOD", hl.dsp.workspace.toggle_special("scratchpad"))
hl.bind("SUPER + ALT + PERIOD", hl.dsp.window.move({workspace = "special:scratchpad"}))
hl.bind("SUPER + F", hl.dsp.window.fullscreen({mode = "maximized", action = "toggle"}))
hl.bind("SUPER + ALT + F", hl.dsp.window.fullscreen({mode = "fullscreen", action = "toggle"}))

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
for workspace_num, key in ipairs(workspace_keys) do
  hl.bind("SUPER + " .. key, hl.dsp.focus({workspace = workspace_num}))
  hl.bind("SUPER + ALT + " .. key, hl.dsp.window.move({workspace = workspace_num}))
end

-- Top row keybinds
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
hl.bind("PRINT", hl.dsp.exec_cmd(screenshot_cmd), {locked = true})


-----------------------
---- WINDOWS RULES ----
-----------------------

-- Prevent windows from maximizing themselves
hl.window_rule({
  name  = "suppress-maximize-events",
  match = { class = ".*" },
  suppress_event = "maximize",
})

-- Fix some dragging issues with XWayland
hl.window_rule({
  name  = "fix-xwayland-drags",
  match = {
    class = "^$",
    title = "^$",
    xwayland = true,
    float = true,
    fullscreen = false,
    pin = false,
  },
  no_focus = true,
})
