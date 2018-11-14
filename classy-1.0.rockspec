package = "classy"
version = "1.0"
source = {
   url = "git://github.com/SvenMarcus/classy",
   tag = "v1.0",
}
description = {
   summary = "A class library with encapsulation, inheritance and polymorphism.",
   detailed = [[
      Classy is a class library that supports private, public and static methods. Attributes are defined in the constructor and are private by default.
      It is also possible to implement metamethods for classes. Performance is a focus of classy. While object instantiation is more expensive than regular metatable based objects, its perfomance when calling methods is close to the native metatable implementation.
   ]],
   homepage = "http://github.com/SvenMarcus/classy",
   license = "MIT/X11"
}
dependencies = {
   "lua >= 5.1, < 5.4"
}

build = {
   type = "builtin",
   modules = {
         classy = "classy.lua"
   },
   copy_directories = { "doc" }
}