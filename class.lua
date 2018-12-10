local util = require "util"
local warning = util.warning
local writing_allowed = util.writing_allowed

return function(classes)

    local FORBIDDEN_OPERATORS = {
	    __index = true,
        __newindex = true,
        __mode = true,
        __gc = true
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

    local function check_class_exists(class)
        if not classes[class] then
            error("Referencing non existing class "..class, 3)
        end
    end

    local function check_if_interfaces_are_implemented(className)
        local classdef = classes[className]
        local interfaces = classdef.implements

        if type(classdef.implements) == "string" then
            interfaces = { classdef.implements }
        end

        local interfaceDef
        for _, interface in pairs(interfaces) do
            check_class_exists(interface)
            interfaceDef = classes[interface]

            for funcName, funcDef in pairs(interfaceDef.publicFuncDefs) do
                if not classdef.publicFuncDefs[funcName] then
                    local varNames = ""

                    for _, varName in pairs(funcDef.vars) do
                        varNames = varNames..varName..", "
                    end

                    varNames = string.sub( varNames, 0, string.len(varNames) - 2)

                    error("Class "..className.." does not implement abstract method: function "..funcName.."("..varNames..")", 3)
                end
            end
        end
    end


    local func_storage = nil

    local public_mt = {}

    public_mt.__index = function(t, k)
        local classdefName = rawget(t, "classdefName")
        local classdef = classes[classdefName]
        local public = classdef.publicFuncDefs[k]

        if public then
            local private_obj = rawget(t, "private_obj")
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

    public_mt.__newindex = function(t, k, v)
        local classdefName = rawget(t, "classdefName")
        local classdef = classes[classdefName]

        local static_member = classdef.staticDefs[k]
        if static_member then
            classdef.staticDefs[k] = v
        elseif writing_allowed() then
            rawset(t, k, v)
            warning("Setting keys for classes from outside is not intended. Objects will not be able to use new keys.")
        else
            error([[

            Trying to write new index to object.
            Writing is not permitted by default, because __newindex is required for the library.
            You can enable writing to objects with allow_writing_to_objects(true), e.g. for busted tests.
            Other usages may break the library.
            ]])
        end
    end;

    local function has_operator(object, operator)
        local classdefName = rawget(object, "classdefName")
        local classdef = classes[classdefName]
        return classdef.operators[operator]
    end

    public_mt.__add = function(lhs, rhs)
        if not has_operator(lhs, "__add") then
            return
        end

        local private_obj = rawget(lhs, "private_obj")
        return private_obj:__add(rhs)
    end

    public_mt.__sub = function(lhs, rhs)
        if not has_operator(lhs, "__sub") then
            return
        end

        local private_obj = rawget(lhs, "private_obj")
        return private_obj:__sub(rhs)
    end

    public_mt.__mul = function(lhs, rhs)
        if not has_operator(lhs, "__mul") then
            return
        end

        local private_obj = rawget(lhs, "private_obj")
        return private_obj:__mul(rhs)
    end

    public_mt.__div = function(lhs, rhs)
        if not has_operator(lhs, "__div") then
            return
        end

        local private_obj = rawget(lhs, "private_obj")
        return private_obj:__div(rhs)
    end

    public_mt.__pow = function(lhs, rhs)
        if not has_operator(lhs, "__pow") then
            return
        end

        local private_obj = rawget(lhs, "private_obj")
        return private_obj:__pow(rhs)
    end

    public_mt.__concat = function(lhs, rhs)
        local self_obj, other, inverse
        if type(lhs) == "table" and lhs.getClass then
            self_obj = lhs
            other = rhs
            inverse = false
        elseif type(rhs) == "table" and rhs.getClass then
            self_obj = rhs
            other = lhs
            inverse = true
        end

        if has_operator(self_obj, "__concat") then 
            local private_obj = rawget(self_obj, "private_obj")
            return private_obj:__concat(other, inverse)
        end
    end

    public_mt.__unm = function(obj)
        if not has_operator(obj, "__unm") then
            return
        end

        local private_obj = rawget(obj, "private_obj")
        return private_obj:__unm()
    end

    public_mt.__tostring = function(obj)
        if not has_operator(obj, "__tostring") then
            return
        end

        local private_obj = rawget(obj, "private_obj")
        return private_obj:__tostring()
    end

    public_mt.__call = function(obj, ...)
        if not has_operator(obj, "__call") then
            return
        end

        local private_obj = rawget(obj, "private_obj")
        return private_obj:__call(...)
    end

    public_mt.__metatable = false

    local function wrapper_function(t, ...)
        local private_obj = t
        local meta_private = rawget(t, "private_obj")
        if meta_private then
            private_obj = meta_private
        end

        return func_storage(private_obj, ...)
    end

    local private_mt = {}

    private_mt.__index = function(t, k)
        local classdefName = rawget(t, "classdefName")
        local classdef = classes[classdefName]

        local func = classdef.privateFuncDefs[k] or classdef.operators[k]
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

    private_mt.__newindex = function(t, k, v)
        local classdefName = rawget(t, "classdefName")
        local classdef = classes[classdefName]

        if classdef.staticDefs[k] then
            classdef.staticDefs[k] = v
            return
        end
        rawset(t, k, v)
    end


    local function class_body(tab)

        local className = classes.currentDef
        local classdef = classes[className]

        local class_mt = {}
        class_mt.__index = function(_, k)
            return classdef.staticDefs[k]
        end

        if classdef.extends then
            check_class_exists(classdef.extends)
        end

        if classdef.implements then
            check_if_interfaces_are_implemented(className)
        end

        class_mt.__call = function(t, ...)
            local private_obj = {
                classdefName = t.className,
            }

            local public_obj = {
                private_obj = private_obj,
                classdefName = t.className,
            }

            setmetatable(private_obj, private_mt)

            if classdef.extends then
                local super = import(classdef.extends)(...)
                private_obj.super = super
            end

            local constructor = classdef.publicFuncDefs.constructor
            if constructor then
                constructor(private_obj, ...)
            end

            return setmetatable(public_obj, public_mt)
        end

        classdef.class = setmetatable({className = className}, class_mt)
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