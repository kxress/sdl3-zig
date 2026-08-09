# Custom IO and allocators

The `io_stream.Interface(UserData)` facade accepts a typed callback table. Put the allocator or file
handle in the userdata object, keep that object stable, and release it after the stream is closed:

```zig
var state = FileState{ .allocator = allocator, .file = file };
var io = io_stream.Interface(FileState).init(&state, callbacks);
var stream = try io.open();
defer stream.deinit();
```

Readers and writers created by the facade retain their allocator for buffered storage. Their
`deinit` method must run before the allocator or userdata is destroyed.
