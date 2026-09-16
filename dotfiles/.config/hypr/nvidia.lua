-- Set up Nvidia environment variables
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")

--  Allow electron apps to use Nvdia drivers
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
