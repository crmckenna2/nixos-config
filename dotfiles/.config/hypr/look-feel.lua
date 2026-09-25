-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.config({

  general = {

    layout = "scrolling",

    gaps_in = 5,
    gaps_out = 10,

    border_size = 3,

  },

  decoration = {

    rounding = 0,
    rounding_power = 0,

    blur = {
      enabled = true,
      size = 3,
      passes = 1,
      vibrancy = 0.1696,
    },

    shadow = {
      enabled = true,
      range = 4,
      render_power = 3,
    },
    
  },

  scrolling = {
    fullscreen_on_one_column = true,
    wrap_swapcol = false,
    wrap_focus = false,
  },

  animations = {
    enabled = false,
  },

})
