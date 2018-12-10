-- @module lua-pie
local ALLOW_WRITING = false
local WARNINGS = true

return function(classes)
    local function show_warnings(bool)
        WARNINGS = bool
    end

    local function allow_writing_to_objects(bool)
        ALLOW_WRITING = bool
    end

    local function writing_allowed()
    	return ALLOW_WRITING
    end

    --- Show a warning when warnings are enabled.
    -- @local warning
    -- @tparam string warning The warning message.
    local function warning(warning)
        if WARNINGS then
            print("** WARNING! "..warning.." **")
        end
    end

    local function compare_interface_names(objectClassName, className)
        local interfaces = classes[objectClassName].implements 
        if interfaces then
            for _, interface in pairs(interfaces) do
                if interface == className then
                    return true
                end
            end
        end

        return false
    end

    local function compare_object_entries(objectClassName, className)
        local equals = objectClassName == className
        if equals then
            return true
        end

        equals = compare_interface_names(objectClassName, className)
        if equals then
            return true
        end

        local parent = classes[objectClassName].extends
        equals = parent == className

        return equals
    end

    local function is(object, className)
        local equals
        if type(object) == "table" and object.getClass and type(object.getClass) == "function" then
            local objectClassName = object.getClass()

            while objectClassName do
                equals = compare_object_entries(objectClassName, className)
                if equals then
                    return true
                end

                objectClassName = classes[objectClassName].extends
            end

            return false
        end

        return type(object) == className
    end

    return {
        warning = warning,
        show_warnings = show_warnings,
        allow_writing_to_objects = allow_writing_to_objects,
        writing_allowed = writing_allowed,
        is = is
    }
end