# Assets and UI resources

Use the focused facades to make ownership visible at the call site:

```zig
var properties = try sdl.properties_api.Group.init();
defer properties.deinit();
try properties.set("title", .{ .string = "Example" });

var storage = try sdl.storage_api.Storage.open("example");
defer storage.deinit();
```

Filesystem enumeration callbacks receive borrowed names. Copy a name into caller-owned storage if it
must outlive the callback. Dialog callback paths follow the same rule.
