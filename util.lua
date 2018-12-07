-- @module lua-pie
local ALLOW_WRITING = false
local WARNINGS = true


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

return {
	warning = warning,
	show_warnings = show_warnings,
	allow_writing_to_objects = allow_writing_to_objects,
	writing_allowed = writing_allowed
}