import { assert, assertEquals } from "@std/assert";

const aliases = [
  "errors",
  "value",
  "ownership",
  "geometry",
  "pixels",
  "blend",
  "keycode",
  "scancode",
  "guid",
  "version",
  "time",
  "power",
  "pen",
  "touch",
  "joystick",
  "mouse",
  "keyboard",
  "gamepad",
  "sensor",
  "net",
  "gpu",
  "message_box",
  "ttf",
  "mixer",
  "haptic",
  "video",
  "dialog",
  "process",
  "render",
  "surface",
  "surface_image",
  "audio",
  "camera",
  "io_stream",
  "async_io",
  "filesystem",
  "properties",
  "storage",
  "timer",
  "tray",
  "thread",
  "mutex",
  "image",
  "metal",
  "vulkan",
  "assert",
  "clipboard",
  "events",
  "hints",
  "log",
  "system",
  "app",
  "shader_assets",
  "extras",
];

const directAliases = [
  "core",
  "assert",
  "async_io",
  "atomic",
  "audio",
  "camera",
  "events",
  "filesystem",
  "gamepad",
  "gpu",
  "image",
  "joystick",
  "mixer",
  "mutex",
  "net",
  "pixels",
  "properties",
  "render",
  "surface",
  "thread",
  "ttf",
  "timer",
  "tray",
  "video",
  "vulkan",
];

const canonicalAliases = ["async_io", "io_stream", "blend_mode", "hid_api", "message_box"];

function declarationCount(source: string, name: string): number {
  return [...source.matchAll(new RegExp(`^pub const ${name}(?:\\s|=)`, "gm"))].length;
}

Deno.test("public facade aliases compile through the package root", async () => {
  const root = await Deno.readTextFile("src/root.zig");
  for (const alias of aliases) assert(root.includes(`pub const ${alias}`), alias);
  for (const alias of directAliases) {
    assertEquals(declarationCount(root, alias), 1, `${alias} must be declared exactly once`);
  }
  for (const alias of canonicalAliases) {
    assertEquals(declarationCount(root, alias), 1, `${alias} must be declared exactly once`);
  }
  const result = await new Deno.Command("zig", {
    args: ["build"],
    stdout: "piped",
    stderr: "piped",
  }).output();
  assertEquals(result.code, 0, new TextDecoder().decode(result.stderr));
});
