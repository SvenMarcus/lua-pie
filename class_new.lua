local util = require "util"
local warning = util.warning
local writing_allowed = util.writing_allowed

return function(classes)

    local FORBIDDEN_OPERATORS = {
	    __index = true,
	    __newindex = true
	}


    local function import(name)
	    return classes[name].class
	end

	local function extends(name)
	    classes[classes.currentDef].extends = name
	end

	local function private(tab)
	    local classdef = classes[classes.currentDef]
	    if classdef.isInterface then
	        error("Modifier 'private' not allowed in interfaces", 2)
	    end

	    for key, value in pairs(tab) do
	        if type(value) == "function" then
	            classdef.privateFuncDefs[key] = value
	        elseif type(value) == "table" and value.abstract_function then
	            error("Abstract methods are currently only allowed in interfaces", 2)
	        else
	            error("Currently only functions in private definitions are supported", 2)
	        end
	    end
	end

	local function public(tab)
	    local classdef = classes[classes.currentDef]
	    if classdef.isInterface then
	        error("Modifier 'public' not allowed in interfaces", 2)
	    end

	    for key, value in pairs(tab) do
	        if type(value) == "function" then
                classdef.publicFuncDefs[key] = value
                classdef.privateFuncDefs[key] = value
	        elseif type(value) == "table" and value.abstract_function then
	            error("Abstract methods are currently only allowed in interfaces", 2)
	        else
	            error("Currently only functions in public definitions are supported", 2)
	        end
	    end
	end

	local function static(tab)
	    for key, value in pairs(tab) do
	        classes[classes.currentDef].staticDefs[key] = value
	    end
	end

	local function operators(tab)
	    for key, value in pairs(tab) do
	        if type(value) ~= "function" then
	            error("Operator must be function", 2)
	        elseif FORBIDDEN_OPERATORS[key] then
	            error("Operator "..tostring(key).." is not allowed for classes.", 2)
	        else
	            classes[classes.currentDef].operators[key] = value
	        end
	    end
    end

    local function in_super(classdef, key)
	    if classdef.extends then
	        return classes[classdef.extends].publicFuncDefs[key] ~= nil
	    end
	    return false
    end


    local func_storage = nil

    local __index_public = function(t, k)
        local mt = getmetatable(t)
        local classdefName = mt.classdefName
        local classdef = classes[classdefName]
        local public = classdef.publicFuncDefs[k]

        if public then
            local private_obj = mt.private_obj
            return private_obj[k]
        end

        local static = classdef.staticDefs[k]
        if static then
            return static
        end

        local private = classdef.privateFuncDefs[k]
        if private then
            error("Trying to access private method "..tostring(k), 2)
        end

        error("Trying to access non existing member "..tostring(k), 2)
    end

    local __metatable_public = false

    local function wrapper_function(t, ...)
        local private_obj = t
        local meta_private = getmetatable(t).private_obj
        if meta_private then
            private_obj = meta_private
        end

        return func_storage(private_obj, ...)
    end

    local __index_private = function(t, k)
        local mt = getmetatable(t)
        local classdefName = mt.classdefName
        local classdef = classes[classdefName]

        local func = classdef.privateFuncDefs[k]
        if func then
            func_storage = func
            return wrapper_function
        end

        local static = classdef.staticDefs[k]
        if static then
            return static
        end

        return rawget(t, k)
    end


    local function class_body(tab)

        local className = classes.currentDef
        local classdef = classes[className]

        local class_mt = {}
        class_mt.__index = function(t, k)
            return classdef.staticDefs[k]
        end

        class_mt.__call = function(_, ...)
            local private_obj = {}
            local public_obj = {}

            local private_obj_mt = {
                classdefName = className,
                __index = __index_private
            }

            local public_obj_mt = {
                private_obj = private_obj,
                classdefName = className,
                __index = __index_public
            }

            setmetatable(private_obj, private_obj_mt)

            local constructor = classdef.publicFuncDefs.constructor
            if constructor then
                constructor(private_obj, ...)
            end

            return setmetatable(public_obj, public_obj_mt)
        end

        classdef.class = setmetatable({}, class_mt)
        classes.currentDef = nil

        return classdef.class
    end


    local function class(name)
        classes.currentDef = name
	    classes[classes.currentDef] = {
	        staticDefs = {
				getClass = function()
					return name
				end
	        },
	        privateFuncDefs = {},
	        publicFuncDefs = {},
	        operators = {},
	        extends = nil,
	        class = nil
        }

        return class_body
    end

    return {
		import = import,
	    static = static,
	    private = private,
	    public = public,
	    operators = operators,
	    extends = extends,
	    class = class
	}
end