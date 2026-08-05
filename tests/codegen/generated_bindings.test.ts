import {
  assertGeneratedBindingsMatch,
  assertGeneratedCoverageReportMatch,
} from "../../scripts/check-generated-bindings.ts";
import { generateRepositoryBindings } from "../../scripts/generate-bindings.ts";
import { run } from "../build/support.ts";

Deno.test("committed generated bindings match a clean regeneration", async () => {
  const temporary = await Deno.makeTempDir({ prefix: "sdl-generated-bindings-" });
  const ownershipFixture = `${import.meta.dirname}/../build/fixtures/allocator_bridge`;
  const ownershipConsumer = `${ownershipFixture}/generated_ownership.zig`;
  try {
    const generated = await generateRepositoryBindings({
      outputRoot: temporary,
      coverageOutput: `${temporary}/COVERAGE.md`,
    });
    await assertGeneratedBindingsMatch(temporary);
    await assertGeneratedCoverageReportMatch(temporary);

    const sdlOwnership = generated.get("sdl")?.ownership ?? [];
    if (sdlOwnership.length !== 50) {
      throw new Error(`expected 50 SDL allocator wrappers, got ${sdlOwnership.length}`);
    }
    for (const item of sdlOwnership) {
      if (!item.path || !item.releasesSourceBeforeReturn) {
        throw new Error(`incomplete ownership inventory for ${item.cName}`);
      }
      if (
        ![
          "owned_output_byte_slice",
          "owned_variadic_string",
          "owned_string",
          "owned_byte_slice",
          "owned_slice",
        ].includes(item.transformation)
      ) {
        throw new Error(`allocator wrapper ${item.cName} has no ownership transform`);
      }
    }
    await Deno.writeTextFile(ownershipConsumer, renderOwnershipConsumer(sdlOwnership));
    await run("zig", ["build", "ownership-check"], { cwd: ownershipFixture });
  } finally {
    await Deno.remove(ownershipConsumer).catch(() => {});
    await Deno.remove(temporary, { recursive: true });
  }
});

function renderOwnershipConsumer(
  ownership: ReadonlyArray<{
    path: string;
    transformation: string;
    retainsAllocator: boolean;
  }>,
): string {
  const checks = ownership.map((item) => {
    const functionPath = `sdl.${item.path}`;
    return `    assertOwnership(${functionPath}, ${item.retainsAllocator}, &allocators);`;
  });
  return [
    'const std = @import("std");',
    'const sdl = @import("sdl");',
    "",
    "fn assertOwnership(comptime function: anytype, comptime retains_allocator: bool, allocators: []const std.mem.Allocator) void {",
    '    const function_info = @typeInfo(@TypeOf(function)).@"fn";',
    '    const first = function_info.params[0].type orelse @compileError("missing allocator parameter");',
    '    if (first != std.mem.Allocator) @compileError("allocator is not the first parameter");',
    "    for (allocators) |allocator| {",
    "        const accepted: first = allocator;",
    "        _ = accepted;",
    "    }",
    "    if (retains_allocator) {",
    '        const return_type = function_info.return_type orelse @compileError("missing return type");',
    "        const payload = switch (@typeInfo(return_type)) {",
    "            .error_union => |error_union| error_union.payload,",
    "            else => return_type,",
    "        };",
    '        if (!@hasDecl(payload, "deinit")) @compileError("owning result lost deinit");',
    "    }",
    "}",
    "",
    'test "all generated allocator wrappers accept every documented allocator family" {',
    "    var fixed_storage: [4096]u8 = undefined;",
    "    var fixed = std.heap.FixedBufferAllocator.init(&fixed_storage);",
    "    var stack = std.heap.stackFallback(4096, sdl.allocator);",
    "    const allocators = [_]std.mem.Allocator{",
    "        std.testing.allocator,",
    "        sdl.allocator,",
    "        fixed.allocator(),",
    "        stack.get(),",
    "    };",
    "    for (allocators) |_| {}",
    ...checks,
    "}",
    "",
    'test "raw ABI remains available for documented limitations" {',
    "    _ = sdl.c.SDL_swprintf;",
    "    _ = sdl.c.SDLTest_LogMessage;",
    "}",
    "",
  ].join("\n");
}
