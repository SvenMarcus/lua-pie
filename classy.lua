--- Classes in Lua
-- @module classy

local WARNINGS = true
local ALLOW_WRITING = false

local classes = {
    currentDef = nil
}

---
-- @section functions

--- Toggle displaying of warnings.
-- @function show_warnings
-- @tparam boolean bool Whether or not to show warnings
local function show_warnings(bool)
    WARNINGS = bool
end

--- Toggle writing to objects.
-- @function allow_writing_to_objects
-- @tparam boolean bool Whether or not objects may be written to
local function allow_writing_to_objects(bool)
    ALLOW_WRITING = bool
end

--- Show a warning when warnings are enabled.
-- @local warning
-- @tparam string warning The warning message.
local function warning(warning)
    if WARNINGS then
        print("** WARNING! "..warning.." **")
    end
end

--- Imports a class.
-- @function import
-- @tparam string name The name of the class to import
local function import(name)
    return classes[name].class
end

--- Extends a with another class
-- @function extends
-- @tparam string name The name of the class to extend with
local function extends(name)
    classes[classes.currentDef].extends = name
end

--- Defines private methods in a class definition.
-- @function private
-- @tparam table tab A table containing private function definitions
-- @usage
-- private {
--    my_func = function(self, args)
--    end
-- }
local function private(tab)
    for key, value in pairs(tab) do
        if type(value) == "function" then
            classes[classes.currentDef].privateFuncDefs[key] = value
        else
            error("Currently only functions in private definitions are supported")
        end
    end
end

--- Defines public methods in a class definition.
-- @function public
-- @tparam table tab A table containing public function definitions
-- @usage
-- public {
--    my_func = function(self, args)
--    end
-- }
local function public(tab)
    for key, value in pairs(tab) do
        if type(value) == "function" then
            classes[classes.currentDef].publicFuncDefs[key] = value
        else
            error("Currently only functions in public definitions are supported")
        end
    end
end

--- Defines static methods in a class definition.
-- @function static
-- @tparam table tab A table containing static function definitions or variables
-- @usage
-- static {
--    my_var = 5;
--    my_func = function(self, args)
--    end
-- }
local function static(tab)
    for key, value in pairs(tab) do
        classes[classes.currentDef].staticDefs[key] = value
    end
end

--- Returns whether or not a public function is defined in the parent class.
-- @local in_super
local function in_super(classdef, key)
    if classdef.extends then
        return classes[classdef.extends].publicFuncDefs[key] ~= nil
    end
    return false
end

--- Creates a new class.
-- @function class
-- @tparam string name The class name
-- @usage
-- classy.class {
--   -- todo: write
-- }
local function class(name)
    classes.currentDef = name
    classes[classes.currentDef] = {
        staticDefs = {},
        privateFuncDefs = {},
        publicFuncDefs = {},
        extends = nil,
        class = nil
    }

    return function(_)

        local classdef = classes[name]

        classes[name].class = setmetatable( {}, {
            __index = classdef.staticDefs,

            __call = function(_, ...)

                    local privateObj = {}

                    local super
                    if classdef.extends then
                        local superClass = import(classdef.extends)
                        super = superClass(...)
                        privateObj.super = super
                    end

                    local private_mt = {}

                    local function wrapperFunction(_, ...)
                        return private_mt.func(privateObj, ...)
                    end

                    private_mt.__index = function(t, k)
                        local member = classdef.privateFuncDefs[k] or classdef.publicFuncDefs[k]
                        if member then
                            if type(member) == "function" then
                                private_mt.func = member
                                return wrapperFunction
                            end
                        else
                            member = classdef.staticDefs[k]
                            if member then
                                return member
                            end
                        end

                        return rawget(t, k)
                    end

                    private_mt.__newindex = function(t, k, v)
                        if classdef.staticDefs[k] then
                            classdef.staticDefs[k] = v
                            return
                        end
                        rawset(t, k, v)
                    end

                    setmetatable(privateObj, private_mt)

                    local public_mt = {
                        __index = function(_, k)
                            local static_member = classdef.staticDefs[k]
                            local isPublic = classdef.publicFuncDefs[k] ~= nil
                            local isPrivate = classdef.privateFuncDefs[k] ~= nil

                            if (isPublic or static_member) and not isPrivate then
                                return privateObj[k]
                            elseif isPrivate then
                                error("Trying to access private member "..tostring(k))
                            elseif in_super(classdef, k) then
                                return rawget(privateObj, "super")[k]
                            else
                                error("Trying to access non existing member "..tostring(k))
                            end
                        end;
                        __newindex = function(t, k, v)
                            local static_member = classdef.staticDefs[k]
                            if static_member then
                                classdef.staticDefs[k] = v
                            elseif ALLOW_WRITING then
                                rawset(t, k, v)
                                warning("Setting keys for classes from outside is not intended. Objects will not be able to use new keys.")
                            end
                        end;
                    }

                    local publicObj = setmetatable({}, public_mt)

                    local constructor = classdef.publicFuncDefs.constructor
                    if constructor then
                        constructor(privateObj, ...)
                    end

                    return publicObj
                end
        })

        classes.currentDef = nil
    end
end

return {
    show_warnings = show_warnings,
    allow_writing_to_objects = allow_writing_to_objects,
    static = static,
    private = private,
    public = public,
    extends = extends,
    class = class,
    import = import
}
