### Issues with Empire at War

When passing game objects (userdata) as arguments to member functions the game seems to "forget" about all functionality the game object has.

Example:
```
class "MyClass" {
  public "constructor" { function(planet)
    self.planetOwner = planet.Get_Owner() -- will throw an error, saying that Get_Owner() is a nil value
  end }
}
```

Moreover after saving and then loading a save game the function environment for the class methods is lost, resulting in `self` being nil.

Both errors seem to be connected to `setfenv()`, therefore a solution that doesn't rely on that function must be found.

### Other issues

The provided example works fine with the regular lua 5.1 compiler, but fails with luajit.
