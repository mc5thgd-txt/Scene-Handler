# Introduction
### Why Scene-Handler?
Scene-Handler provides a quick and easy game state handler for your game, app (idk if someone will do it ;-;) and game engine (probably someone will).

# Functionality
##### Tip: Make a folder for your scenes so that you don't get confused by adding more scenes to your game

## Creating scenes
Create scenes
``` LUA
sceneHandler = require("sceneHandler")

sceneHandler:createScenes({
  ["NAME_OF_YOUR_SCENE"] = require("PATH_TO_YOUR_SCENE")
})
```

Changes the scene
``` LUA
sceneHandler:changeScene("YOUR_SCENE")
```

These functions should be placed in the Love2d's common functions
``` LUA
function love.load()
  --code for loading in
  sceneHandler:load() --Must be the bottom line of the function
  sceneHandler:changeScene("YOUR_SCENE_WHEN_THE_GAME_IS_LOADED")
end

function love.update(dt)
  sceneHandler:update(dt) --Must be in love.update
end

function love.draw()
  --All of these must be in love.draw
  --Must be in order
  sceneHandler:background()
  sceneHandler:draw()
  sceneHandler:ui()
end

function love.ANY_LOVE2D_FUNCTION(VALUE)
  sceneHandler:getFunctionName("ANY_LOVE2D_FUNCTION", VALUE)
end
```

## You can make states for your scenes
