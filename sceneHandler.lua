local sceneHandler = {}
sceneHandler.Scenes = {}
sceneHandler.currentScene = "none"

--[[
Create scenes for your game.
]]
function sceneHandler:createScenes(scenes)
    for name, scene in pairs(scenes) do
        if not self.Scenes[string.lower(name)] then
            self.Scenes[string.lower(name)] = scene
        end
    end
end

--[[
Create states for your scenes and for your states.
]]
function sceneHandler:createStates(sceneName, states)
    local functions = {}

    functions.states = {}
    functions._stateFunctions = {}
    functions.currentState = "none"
    
    --[[
    Sets the current state to a state you've created.
    ]]
    function functions:changeState(stateName)
        if stateName then
            if not self.states[string.lower(stateName)] then
                return
            end
            if self.currentState == string.lower(stateName) then
                return
            end
            self.currentState = string.lower(stateName)
            if self._stateFunctions[string.lower(stateName)] and self._stateFunctions[string.lower(stateName)].onload then
                self._stateFunctions[string.lower(stateName)].onload()
            end
        else
            self.currentState = "none"
        end
    end
    
    --[[
    Gets the current state of a scene or a state
    if stateName has a value it will return a boolean
    if not it will return the current state
    ]]
    function functions:getCurrentState(stateName)
        if stateName then
            if stateName == self.currentState then
                return true
            else
                return false
            end
        else
            return self.currentState
        end
    end

    --[[
    Loads all functions only their name
    ]]
    function functions:loadFunctions(funcName, ...)
        for stateName, properties in pairs(self._stateFunctions) do
            if properties[funcName] and string.lower(self.currentState) == stateName then
                properties[funcName](... or nil)
            end
        end
    end

    --[[
    Makes functions for your states
    ]]
    function functions:stateFunctions(stateName)
        if self._stateFunctions[string.lower(stateName)] then
            return self._stateFunctions[string.lower(stateName)]
        end
        local properties = {}
        properties.functions = {}

        --[[
        Adds a function
        ]]
        function properties:addFunction(funcName, func)
            if properties.functions[funcName] then
                return
            end
            properties.functions[funcName] = func
        end

        --[[
        Gets the function by its name
        ]]
        function properties:getFunctionName(funcName)
            if properties.functions[funcName] then
                return properties.functions[funcName]
            end
            return nil
        end

        self._stateFunctions[string.lower(stateName)] = properties.functions
        return properties
    end

    --[[
    Adds data to a state
    if there is a state or not it will add data to it
    ]]
    function functions:addData(stateName, values, valueName)
        local data = self.states[string.lower(stateName)]
        if not data then
            data = {}
        end

        local function addData(data, values)
            for name, value in pairs(values) do
                if not data[string.lower(name)] then
                    if type(value) == "function" then
                        print("WARNING! FUNCTIONS WITH SELF IN THEM WILL PROBABLY NOT WORK WHEN USED!")
                    end
                    if type(name) == "string" then
                        data[string.lower(name)] = value
                    else
                        data[name.."Value"] = value
                    end
                end
            end
        end

        if not valueName then
            if type(values) == "table" then
                addData(data, values)
            else
                table.insert(data, values)
            end
        else
            if not data[valueName] then
                data[valueName] = {}
            end
            
            addData(data[valueName], values)
        end
    end

    --[[
    Sets all of the data
    ]]
    function functions:setAllData(data, stateName)
        if stateName then
            if self.states[string.lower(stateName)] then
                self:addData(stateName, data)
            end
        else
            for name, values in pairs(data) do
                if self.states[string.lower(name)] then
                    self:addData(name, values)
                end
            end
        end
    end

    --[[
    Gets data from a state (if there is one)
    ]]
    function functions:getData(stateName, valueName)
        if self.states[string.lower(stateName)] and self.states[string.lower(stateName)][valueName] then
            if type(valueName) == "string" then
                return self.states[string.lower(stateName)][valueName]
            else
                return self.states[string.lower(stateName)][valueName.."Value"]
            end
        else
            return nil
        end
    end

    --[[
    It will get all of the values from their name
    ]]
    function functions:getAllValueByNames(valueName, valueType)
        local values = {}

        for name, value in pairs(self.states) do
            values[string.lower(name)] = {}
            if self.states[string.lower(name)][string.lower(valueName)] == string.lower(valueName) then
                if valueType then
                    if type(value) == string.lower(valueType) then
                        table.insert(values[string.lower(name)], value)
                    end
                else
                    table.insert(values[string.lower(name)], value)
                end
            end
        end

        return values
    end

    local function createStates(stored, states)
        for stateName, data in pairs(states) do
            local name = stateName
            local useDataAsName = false
            if type(name) == "number" then
                name = data
                useDataAsName = false
            end
    
            if not stored.states[string.lower(name)] then
                stored.states[string.lower(name)] = {}
                if not useDataAsName then
                    if data then
                        if type(data) == "table" then
                            stored:addData(name, unpack(data))
                        else
                            stored:addData(name, data)
                        end
                    end
                end
            end
        end
    end

    createStates(functions, states)
    return functions
end

--[[
Must be the last line of love.load
]]
function sceneHandler:load()
    for name, scene in pairs(self.Scenes) do
        if scene.load then
            scene:load()
        end
        if self.currentScene ~= string.lower(name) then
            if scene.unload then
                scene:unload()
            end
        end
    end
end

--[[
Put this in love.update
]]
function sceneHandler:update(dt)
    for name, scene in pairs(self.Scenes) do
        if string.lower(self.currentScene) == string.lower(name) then
            if scene.update then
                scene:update(dt)
            end
        end
    end
end

--[[
Put this in love.draw between background and ui
]]
function sceneHandler:draw()
    for name, scene in pairs(self.Scenes) do
        if string.lower(self.currentScene) == string.lower(name) then
            if scene.draw then
                scene:draw()
            end
        end
    end
end

--[[
Put this in love.draw under background and draw
]]
function sceneHandler:ui()
    for name, scene in pairs(self.Scenes) do
        if string.lower(self.currentScene) == string.lower(name) then
            if scene.ui then
                scene:ui()
            end
        end
    end
end

--[[
For custom functions that can be found in love2d's library
]]
function sceneHandler:getFunctionName(funcName, ...)
    for name, scene in pairs(self.Scenes) do
        if string.lower(self.currentScene) == string.lower(name) then
            if scene[funcName] then
                scene[funcName](...)
            end
        end
    end
end

--[[
Put this in love.draw over draw and ui
]]
function sceneHandler:background()
    for name, scene in pairs(self.Scenes) do
        if string.lower(self.currentScene) == string.lower(name) then
            if scene.background then
                scene:background()
            end
        end
    end
end

--[[
Changes the scene
]]
function sceneHandler:changeScene(sceneName)
    if not self.Scenes[string.lower(sceneName)] or self.currentScene == string.lower(sceneName) then
        return
    end
    local ogScene = self.Scenes[self.currentScene]
    if ogScene then
        if ogScene.unload then
            ogScene:unload()
        end
    end
    
    self.currentScene = string.lower(sceneName)
    if self.Scenes[self.currentScene].onload then
        self.Scenes[self.currentScene]:onload()
    end
end

return sceneHandler
