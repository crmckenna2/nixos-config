----------------
---- NVIDIA ----
----------------

-- Configure nvidia settings only for alienix
if HOSTNAME == "alienix" then

  -- Set up Nvidia environment variables
  hl.env("LIBVA_DRIVER_NAME", "nvidia")
  hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")

  -- Allow electron apps to use Nvdia drivers
  hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")

end


--------------------
---- BRIGHTNESS ----
--------------------

-- Brightness commands
local raise_brightness_cmd = "flock -n /tmp/ddcutil.lock ddcutil --bus 3 setvcp 10 + 10"
local lower_brightness_cmd = "flock -n /tmp/ddcutil.lock ddcutil --bus 3 setvcp 10 - 10"

-- LOG keybinds
hl.bind("CTRL + XF86AudioRaiseVolume", hl.dsp.exec_cmd(raise_brightness_cmd), {locked = true, repeating = true})
hl.bind("CTRL + XF86AudioLowerVolume", hl.dsp.exec_cmd(lower_brightness_cmd), {locked = true, repeating = true})
