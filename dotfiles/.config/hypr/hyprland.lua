----------------------------
---- DETERMINE THE HOST ----
----------------------------
local f = io.open("/etc/hostname", "r")
local HOSTNAME = f:read("*a"):gsub("%s+", "")
f:close()

-----------------------
---- OTHER MODULES ----
-----------------------

require("binds")
require("input-output")
require("look-feel")
require("colors")

-----------------
---- STARTUP ----
-----------------

hl.on("hyprland.start", function ()

  -- Start a foot server
  hl.exec_cmd("uwsm app -- foot --server")

end)


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


-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")


-----------------------
----- PERMISSIONS -----
-----------------------

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Permissions/
-- Please note permission changes here require a Hyprland restart and are not applied on-the-fly
-- for security reasons

-- hl.config({
--   ecosystem = {
--     enforce_permissions = true,
--   },
-- })

-- hl.permission("/usr/(bin|local/bin)/grim", "screencopy", "allow")
-- hl.permission("/usr/(lib|libexec|lib64)/xdg-desktop-portal-hyprland", "screencopy", "allow")
-- hl.permission("/usr/(bin|local/bin)/hyprpm", "plugin", "allow")


----------------
----  MISC  ----
----------------

hl.config({
  misc = {
    force_default_wallpaper = 1,
    disable_hyprland_logo   = false,
    },
})
