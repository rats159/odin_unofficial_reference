# Zero Values
All types in Odin have a Zero Value. As the name implies, this is the value of the type where every byte is zeroed. There are a few expressions to create a zero value:
- For all types: `{}` will produce the zero value. `x: Foo = {}`, `x: int = {}`, `x: ^int = {}`
- For numeric types, `0` will produce the zero value. `x: int = 0`, `x: quaternion128 = 0`, `x: f32 = 0`
- For `nil`able types, `nil` will produce the zero value. `x: ^int = nil`, `x: []Foo = nil`
For a full list of nilable types, see [Nilable Types](/Types/#nilable-types)