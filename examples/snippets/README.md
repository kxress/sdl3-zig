# Small API snippets

These snippets show the lifetime rule shared by the typed callback facades: the userdata and the
callback bundle must remain at a stable address until SDL has stopped invoking the callback.

## Callback userdata

```zig
const Callback = sdl.audio_api.StreamCallback(MyState);
var state = MyState{};
var callback = Callback.init(&state, .{ .get = onGet, .put = onPut });
defer callback.deinit();
try stream.setGetCallback(callback.callback(), callback.userdata());
```

Keep `state` and `callback` alive for the complete stream lifetime. Do not pass pointers to a
temporary callback bundle or to a local value that will move after registration.

## Ownership handoff

```zig
var bytes = try allocator.alloc(u8, 4096);
defer allocator.free(bytes);
try stream.putData(bytes);
```

Use the copying API when the source buffer is short-lived. Use a no-copy API only when its release
callback owns the buffer and can outlive every asynchronous consumer.
