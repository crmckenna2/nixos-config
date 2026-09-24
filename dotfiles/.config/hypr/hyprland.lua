----------------------------
---- DETERMINE THE HOST ----
----------------------------
local hostname = ""
local f = io.open("/etc/hostname", "r")
if (f ~= nil) then
  hostname = f:read("*a"):gsub("%s+", "")
  f:close()
end


-----------------------
---- OTHER MODULES ----
-----------------------

local host_file = "hosts." .. hostname
local _, _ = pcall(require, host_file)

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
