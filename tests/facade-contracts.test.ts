import { assert, assertStringIncludes } from "@std/assert";

const lifecycle = [
  "timer",
  "tray",
  "process",
  "joystick",
  "gamepad",
  "haptic",
  "hid",
  "sensor",
  "mutex",
  "image",
  "mixer",
  "ttf",
];

Deno.test("resource facades expose explicit lifecycle operations", async () => {
  for (const name of lifecycle) {
    const source = await Deno.readTextFile(`src/${name}_facade.zig`);
    assertStringIncludes(source, "deinit", name);
    assertStringIncludes(source, "pub fn init", name);
  }
});

Deno.test("ownership and callback contracts are documented", async () => {
  const ownership = await Deno.readTextFile("src/ownership.zig");
  const callbacks = await Deno.readTextFile("docs/callback-lifetimes.md");
  assert(ownership.includes("Owned"));
  assert(ownership.includes("Borrowed"));
  assert(callbacks.includes("stable address"));
  assert(callbacks.includes("temporary"));
  assert(ownership.includes("allocator"));
  assert(ownership.includes("deinit"));
});

Deno.test("enum and flag facades retain unknown-value and round-trip coverage", async () => {
  for (const name of ["keycode", "scancode", "blend", "pixels", "power"]) {
    const source = await Deno.readTextFile(`src/${name}_facade.zig`);
    assert(source.includes("fromSdl") || source.includes("fromRaw"), name);
    assert(source.includes("toSdl") || source.includes("toRaw"), name);
  }
  const version = await Deno.readTextFile("src/version_facade.zig");
  assert(version.includes("make") && version.includes("atLeast"));
  const scancode = await Deno.readTextFile("src/scancode_facade.zig");
  assert(scancode.includes("unknown"));
});

Deno.test("callback facades expose userdata and teardown guidance", async () => {
  for (
    const name of [
      "audio",
      "assert",
      "clipboard",
      "events",
      "filesystem",
      "hints",
      "log",
      "system",
      "thread",
    ]
  ) {
    const source = await Deno.readTextFile(`src/${name}_facade.zig`);
    assert(source.includes("UserData"), name);
    assert(source.includes("userdata"), name);
  }
  const docs = await Deno.readTextFile("docs/callback-lifetimes.md");
  assert(docs.includes("Unregister"));
});

Deno.test("migration aliases coexist with generated modules", async () => {
  const root = await Deno.readTextFile("src/root.zig");
  for (const name of ["audio", "events", "gpu", "io_stream", "properties", "shader_assets"]) {
    assert(root.includes(`pub const ${name}_api`), name);
    assert(root.includes(`@import(\"${name}_facade\")`), name);
  }
  assert(root.includes('pub const core = @import("sdl")'));
});
