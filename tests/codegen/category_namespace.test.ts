import { assertEquals } from "@std/assert";
import { extractHeaderDocumentation } from "../../scripts/codegen/doxygen.ts";
import { ZigNaming } from "../../scripts/codegen/naming.ts";
import { categoryNamespaceName, resolveNamespaceCollision } from "../../scripts/codegen/render.ts";

Deno.test("header categories retain their title and prose", () => {
  const documentation = extractHeaderDocumentation(
    "SDL_IOStream.h",
    `/**
 * # CategoryIOStream
 *
 * SDL streams read and write data.
 */
#ifndef SDL_IOStream_h_
`,
  );
  assertEquals(documentation, {
    header: "SDL_IOStream.h",
    category: "CategoryIOStream",
    comment: "SDL streams read and write data.",
  });
});

Deno.test("category namespaces use Zig field names and undocumented headers stay at root", () => {
  const naming = new ZigNaming([], ["SDL_"]);
  assertEquals(categoryNamespaceName("CategoryIOStream", naming), "ioStream");
  assertEquals(categoryNamespaceName("", naming), "");
});

Deno.test("a category namespace colliding with a public declaration stays at root", () => {
  assertEquals(resolveNamespaceCollision("init", ["init", "quit"]), "");
  assertEquals(resolveNamespaceCollision("ioStream", ["init", "quit"]), "ioStream");
});
