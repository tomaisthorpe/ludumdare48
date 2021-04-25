local config = {
  skipSystem = false,
  fullscreen = true,
  borderColor = {9 / 255, 18 / 255, 26 / 255},

  miniPlanetRadius = {
    small = 45,
    medium = 55,
    large = 65,
  },
  planetsPerSystem = 4,
  planetSizes = {
    small = {2000,1600},
    medium = {3000,2400},
    large = {4000,3200},
  },
  physicsDebug = false,

  minimapSize = {200, 160},
  minimapColor = {58 / 255, 118 / 255, 148 / 255, 0.5},
  minimapBorderColor = {58 / 255, 118 / 255, 148 / 255, 1},

  planetTypes = {
    {
      sizes = {'small', 'medium'},
      palette = {
        { 0.6, { 126, 26, { 50, 75 }}},
        { 0.55, { 46, 100, { 75, 80 }}},
        { 0.40, { 200, 77, { 70, 80 }}},
        { 0, { 200, 77, { 50, 60 }}},
      },
      frequencies = {
        { 0.001, 0.35 },
        { 0.002, 0.45 },
        { 0.01, 0.2 },
      },
    },
    {
      sizes = {'medium', 'large'},
      palette = {
        { 0.4, { 26, 54, { 50, 55 }}},
        { 0, { 29, 64, { 40, 50 }}},
      },
      frequencies = {
         { 0.001, 0.5},
         { 0.002, 0.4 },
         { 0.02, 0.1 },
      },
    },
    {
      sizes = {'medium', 'large'},
      palette = {
        { 0.5, { 249, 45, { 50, 55 }}},
        { 0, { 249, 45, { 45, 55 }}},
      },
      frequencies = {
        { 0.0001, 0.6 },
        { 0.05, 0.4 },
      },
    },
    {
      sizes = {'small'},
      palette = {
        { 0.3, { 236, 6, { 60, 70 }}},
        { 0, { 236, 6, {50, 55 }}},
      },
      frequencies = {
        { 0.003, 0.7 },
        { 0.02, 0.3 },
      },
    },
  },
}

return config
