import { assertEquals, assertThrows } from "@std/assert";
import {
  type DeclarationAttributeRecord,
  parseClangAttributeJson,
} from "../../scripts/codegen/clang-attributes.ts";
import { repositoryRoot } from "../../scripts/utils/paths.ts";

function fixtureJson(): string {
  return JSON.stringify({
    kind: "TranslationUnitDecl",
    inner: [
      {
        id: "process-local-2",
        kind: "FunctionDecl",
        name: "PATTERN_Format",
        loc: { file: "include/attributes.h", line: 12, col: 5 },
        inner: [
          {
            id: "attr-2",
            kind: "FormatAttr",
            dialect: "printf",
            formatParameter: 2,
            firstVariadicParameter: 3,
          },
          { id: "attr-1", kind: "AlwaysInlineAttr" },
          { id: "attr-3", kind: "WarnUnusedResultAttr" },
        ],
      },
      {
        id: "process-local-1",
        kind: "FunctionDecl",
        name: "PATTERN_AssertReport",
        loc: { file: "include/attributes.h", line: 20, col: 1 },
        inner: [{ kind: "AnalyzerNoReturnAttr" }],
      },
      {
        kind: "FunctionDecl",
        name: "PATTERN_NoReturn",
        loc: { file: "include/attributes.h", line: 21, col: 1 },
        inner: [{ kind: "NoReturnAttr" }],
      },
      {
        kind: "FunctionDecl",
        name: "system_helper",
        loc: { file: "/usr/include/helper.h", line: 4 },
        inner: [{ kind: "NoReturnAttr" }],
      },
    ],
  });
}

function record(name: string): DeclarationAttributeRecord {
  const result = parseClangAttributeJson(fixtureJson(), { publicFilePrefixes: ["include/"] });
  return result.find((item) => item.cName === name)!;
}

Deno.test("normalizes typed Clang attributes with stable source identity", () => {
  const result = parseClangAttributeJson(fixtureJson(), { publicFilePrefixes: ["include/"] });
  assertEquals(result.map((item) => item.cName), [
    "PATTERN_Format",
    "PATTERN_AssertReport",
    "PATTERN_NoReturn",
  ]);
  assertEquals(record("PATTERN_Format").semantics, {
    linkage: "default",
    inline: "always",
    returnFlow: "normal",
    resultUse: "should_use",
    format: { dialect: "printf", formatParameter: 1, firstVariadicParameter: 2 },
  });
  assertEquals(record("PATTERN_AssertReport").semantics.returnFlow, "analyzer_no_return");
  assertEquals(record("PATTERN_NoReturn").semantics.returnFlow, "no_return");
});

Deno.test("rejects malformed and zero-based FormatAttr arguments with source context", () => {
  const malformed = JSON.stringify({
    kind: "TranslationUnitDecl",
    inner: [{
      kind: "FunctionDecl",
      name: "PATTERN_BadFormat",
      loc: { file: "include/attributes.h", line: 42 },
      inner: [{ kind: "FormatAttr", dialect: "printf", formatParameter: 0, firstArg: 2 }],
    }],
  });
  assertThrows(
    () => parseClangAttributeJson(malformed, { publicFilePrefixes: ["include/"] }),
    Error,
    "PATTERN_BadFormat at include/attributes.h:42",
  );
});

Deno.test("recovers format contracts from real Clang macro expansion locations", async () => {
  const fixture = `${repositoryRoot}/tests/codegen/fixtures/attributes.h`;
  const output = await new Deno.Command("clang", {
    args: ["-Xclang", "-ast-dump=json", "-fsyntax-only", "-x", "c", fixture],
  }).output();
  assertEquals(output.success, true);
  const records = parseClangAttributeJson(new TextDecoder().decode(output.stdout), {
    defaultSourceFile: fixture,
    sourceTextByFile: { [fixture]: await Deno.readTextFile(fixture) },
  });
  assertEquals(
    records.filter((record) =>
      record.cName === "attributes_printf" || record.cName === "attributes_scanf"
    ).map((record) => [
      record.cName,
      record.semantics.format,
    ]),
    [
      ["attributes_printf", { dialect: "printf", formatParameter: 0, firstVariadicParameter: 1 }],
      ["attributes_scanf", { dialect: "scanf", formatParameter: 0, firstVariadicParameter: 1 }],
    ],
  );
});

Deno.test("normalizes real return-flow, linkage, inline, unused, and restrict attributes", async () => {
  const fixture = `${repositoryRoot}/tests/codegen/fixtures/attributes.h`;
  const output = await new Deno.Command("clang", {
    args: ["-Xclang", "-ast-dump=json", "-fsyntax-only", "-x", "c", fixture],
  }).output();
  assertEquals(output.success, true);
  const records = parseClangAttributeJson(new TextDecoder().decode(output.stdout), {
    defaultSourceFile: fixture,
    sourceTextByFile: { [fixture]: await Deno.readTextFile(fixture) },
  });
  const byName = new Map(records.map((record) => [record.cName, record]));
  assertEquals(byName.get("attributes_noreturn")?.semantics.returnFlow, "no_return");
  assertEquals(
    byName.get("attributes_analyzer_noreturn")?.semantics.returnFlow,
    "analyzer_no_return",
  );
  assertEquals(byName.get("attributes_always_inline")?.semantics.inline, "always");
  assertEquals(byName.get("attributes_inline_hint")?.semantics.inline, "hint");
  assertEquals(byName.get("attributes_unused")?.semantics.unused, true);
  assertEquals(byName.get("attributes_unused_parameter")?.semantics.unused, true);
  assertEquals(byName.get("attributes_hidden")?.semantics.linkage, "hidden");
  assertEquals(byName.get("attributes_restrict")?.semantics.restrict, true);
  assertEquals(byName.get("attributes_restrict")?.semantics.restrictParameters, [0]);
  assertEquals(
    byName.get("attributes_deprecated")?.semantics.deprecated?.message,
    "use attributes_replacement instead",
  );
  assertEquals(byName.get("attributes_nodiscard")?.semantics.resultUse, "should_use");
  // Fallthrough is a statement-level no-code marker, not a declaration contract. It is
  // intentionally absent from declaration records even though the real AST contains it.
  assertEquals(byName.has("attributes_fallthrough"), false);
});

Deno.test("rejects restrict metadata on a non-pointer parameter with source context", () => {
  const json = JSON.stringify({
    kind: "TranslationUnitDecl",
    inner: [{
      kind: "FunctionDecl",
      name: "PATTERN_BadRestrict",
      loc: { file: "include/attributes.h", line: 80 },
      inner: [{
        kind: "ParmVarDecl",
        type: { qualType: "int restrict" },
      }],
    }],
  });
  assertThrows(
    () => parseClangAttributeJson(json, { publicFilePrefixes: ["include/"] }),
    Error,
    "Invalid restrict metadata for PATTERN_BadRestrict at include/attributes.h:80",
  );
});

Deno.test("normalizes target-specific import and export linkage spellings", () => {
  const json = JSON.stringify({
    kind: "TranslationUnitDecl",
    inner: [
      {
        kind: "FunctionDecl",
        name: "PATTERN_Imported",
        loc: { file: "include/attributes.h", line: 80 },
        inner: [{ kind: "DLLImportAttr" }],
      },
      {
        kind: "FunctionDecl",
        name: "PATTERN_Exported",
        loc: { file: "include/attributes.h", line: 81 },
        inner: [{ kind: "DLLExportAttr" }],
      },
      {
        kind: "FunctionDecl",
        name: "PATTERN_CxxImported",
        loc: { file: "include/attributes.h", line: 82 },
        inner: [{ kind: "CXXDLLImportAttr" }],
      },
    ],
  });
  const records = parseClangAttributeJson(json, { publicFilePrefixes: ["include/"] });
  assertEquals(
    records.map((item) => [item.cName, item.semantics.linkage]),
    [
      ["PATTERN_Imported", "imported"],
      ["PATTERN_Exported", "exported"],
      ["PATTERN_CxxImported", "imported"],
    ],
  );
});

Deno.test("proves target-specific DLL linkage and calling convention stay at the C boundary", async () => {
  const fixture = `${repositoryRoot}/tests/codegen/fixtures/linkage.h`;
  async function recordsFor(target: string) {
    const output = await new Deno.Command("clang", {
      args: [
        "-target",
        target,
        "-Xclang",
        "-ast-dump=json",
        "-fsyntax-only",
        "-x",
        "c",
        fixture,
      ],
    }).output();
    assertEquals(output.success, true);
    const json = new TextDecoder().decode(output.stdout);
    return {
      json,
      records: parseClangAttributeJson(json, {
        defaultSourceFile: fixture,
        publicFilePrefixes: [fixture],
      }),
    };
  }
  const windows = await recordsFor("i686-pc-windows-msvc");
  assertEquals(
    windows.records.map((record) => [record.cName, record.semantics.linkage]),
    [
      ["attributes_link_imported", "imported"],
      ["attributes_link_exported", "exported"],
    ],
  );

  // Clang carries __stdcall in the C function type and decorated symbol name. The Zig
  // convenience surface intentionally does not re-encode this ABI contract; @cImport owns it.
  assertEquals(windows.json.includes('"mangledName": "_attributes_link_imported@4"'), true);
  assertEquals(windows.json.includes("__attribute__((stdcall))"), true);

  // Non-Windows SDL builds use visibility attributes for the same declaration-level contract.
  const linux = await recordsFor("x86_64-unknown-linux-gnu");
  assertEquals(
    linux.records.map((record) => [record.cName, record.semantics.linkage]),
    [
      ["attributes_link_imported", "exported"],
      ["attributes_link_exported", "exported"],
    ],
  );
});

Deno.test("header-only force-inline helpers link from their static body", async () => {
  const fixture = `${repositoryRoot}/tests/codegen/fixtures/attributes.h`;
  const directory = await Deno.makeTempDir({ prefix: "sdl-inline-body-" });
  const source = `${directory}/main.c`;
  const executable = `${directory}/inline-helper`;
  try {
    await Deno.writeTextFile(
      source,
      `#include "${fixture.replaceAll("\\", "/")}"
int main(void) { return attributes_always_inline(41) == 41 ? 0 : 1; }
`,
    );
    const compile = await new Deno.Command("clang", {
      args: ["-std=c11", "-O0", source, "-o", executable],
    }).output();
    assertEquals(compile.success, true, new TextDecoder().decode(compile.stderr));
    // A successful link is the proof: the static inline body supplies the implementation and
    // no SDL linker symbol is needed. Executing the temporary binary would require widening the
    // repository's Deno run allowlist for an untrusted path.
  } finally {
    await Deno.remove(directory, { recursive: true });
  }
});

Deno.test("real NoReturn semantics take precedence over analyzer-only metadata", () => {
  const json = JSON.stringify({
    kind: "TranslationUnitDecl",
    inner: [{
      kind: "FunctionDecl",
      name: "PATTERN_BothReturnAttrs",
      loc: { file: "include/attributes.h", line: 90 },
      type: { qualType: "void (void) __attribute__((noreturn))" },
      inner: [{ kind: "AnalyzerNoReturnAttr" }, { kind: "NoReturnAttr" }],
    }],
  });
  const [result] = parseClangAttributeJson(json, { publicFilePrefixes: ["include/"] });
  assertEquals(result.semantics.returnFlow, "no_return");
});

Deno.test("accepts repository-relative Clang expansion paths under absolute public roots", () => {
  const source = "void attributes_printf(const char *fmt, ...) SDL_PRINTF_VARARG_FUNC(1);";
  const json = JSON.stringify({
    kind: "TranslationUnitDecl",
    inner: [{
      kind: "FunctionDecl",
      name: "attributes_printf",
      loc: { file: "vendor/SDL3/include/SDL3/attributes.h", line: 1, col: 1 },
      inner: [{
        kind: "FormatAttr",
        range: {
          begin: {
            expansionLoc: {
              file: "vendor/SDL3/include/SDL3/attributes.h",
              line: 1,
              col: 50,
            },
          },
        },
      }],
    }],
  });
  const [result] = parseClangAttributeJson(json, {
    publicFilePrefixes: ["/workspace/vendor/SDL3/include/SDL3/attributes.h"],
    sourceTextByFile: {
      "/workspace/vendor/SDL3/include/SDL3/attributes.h": source,
    },
  });
  assertEquals(result.semantics.format, {
    dialect: "printf",
    formatParameter: 0,
    firstVariadicParameter: 1,
  });
});

Deno.test("uses an attributed expansion location after parameter locations", () => {
  const header = "void SDLTest_LogAllocations(void);\n" +
    "void SDLTest_Log(const char *fmt, ...) SDL_PRINTF_VARARG_FUNC(1);\n";
  const json = JSON.stringify({
    kind: "TranslationUnitDecl",
    inner: [{
      kind: "FunctionDecl",
      name: "SDLTest_Log",
      loc: { line: 2, col: 6 },
      inner: [
        { kind: "ParmVarDecl", type: { qualType: "const char *" } },
        {
          kind: "FormatAttr",
          range: {
            begin: {
              expansionLoc: {
                file: "vendor/SDL3/include/SDL3/SDL_test_log.h",
                line: 2,
                col: 40,
              },
            },
          },
        },
      ],
    }],
  });
  const [result] = parseClangAttributeJson(json, {
    publicFilePrefixes: ["/workspace/vendor/SDL3/include/SDL3/SDL_test_log.h"],
    sourceTextByFile: {
      "/workspace/vendor/SDL3/include/SDL3/SDL_test_log.h": header,
      "/workspace/vendor/SDL3/include/SDL3/SDL_test_memory.h":
        "void SDLTest_LogAllocations(void);\n".repeat(58),
    },
  });
  assertEquals(result.cName, "SDLTest_Log");
  assertEquals(result.semantics.format?.dialect, "printf");
});

Deno.test("pinned SDL headers inventory every format application", async () => {
  const root = `${repositoryRoot}/vendor/SDL3/include/SDL3`;
  const counts = new Map<string, number>();
  const applications: Array<{ macro: string; index: number }> = [];
  async function visit(directory: string): Promise<void> {
    for await (const entry of Deno.readDir(directory)) {
      const path = `${directory}/${entry.name}`;
      if (entry.isDirectory) await visit(path);
      if (!entry.isFile || !/\.(?:h|hpp)$/.test(entry.name)) continue;
      const text = await Deno.readTextFile(path);
      for (const line of text.split(/\r?\n/)) {
        if (/^\s*(?:#|\/\*|\*|\/\/)/.test(line)) continue;
        const match = line.match(/(SDL_(?:PRINTF|SCANF)_VARARG_FUNCV?)\s*\(\s*(\d+)/);
        if (match) {
          counts.set(match[1], (counts.get(match[1]) ?? 0) + 1);
          applications.push({ macro: match[1], index: Number(match[2]) });
        }
      }
    }
  }
  await visit(root);
  assertEquals(Object.fromEntries(counts), {
    SDL_PRINTF_VARARG_FUNC: 20,
    SDL_PRINTF_VARARG_FUNCV: 5,
    SDL_SCANF_VARARG_FUNC: 1,
    SDL_SCANF_VARARG_FUNCV: 1,
  });
  assertEquals(applications.length, 27);
  for (const application of applications) {
    const expected = {
      SDL_PRINTF_VARARG_FUNC: { dialect: "printf", vaList: false },
      SDL_PRINTF_VARARG_FUNCV: { dialect: "printf", vaList: true },
      SDL_SCANF_VARARG_FUNC: { dialect: "scanf", vaList: false },
      SDL_SCANF_VARARG_FUNCV: { dialect: "scanf", vaList: true },
    }[application.macro];
    if (!expected) throw new Error(`unexpected format macro ${application.macro}`);
    assertEquals(expected.dialect, application.macro.includes("SCANF") ? "scanf" : "printf");
    assertEquals(expected.vaList, application.macro.endsWith("FUNCV"));
    assertEquals(application.index >= 1, true);
  }
});

Deno.test("pinned SDL allocator attributes match configured declaration contracts", async () => {
  const root = `${repositoryRoot}/vendor/SDL3/include/SDL3`;
  const applications: Array<{ macro: string; declaration: string; line: number }> = [];
  async function visit(directory: string): Promise<void> {
    for await (const entry of Deno.readDir(directory)) {
      const path = `${directory}/${entry.name}`;
      if (entry.isDirectory) {
        await visit(path);
        continue;
      }
      if (!entry.isFile || !/\.h$/.test(entry.name)) continue;
      const lines = (await Deno.readTextFile(path)).split(/\r?\n/);
      for (const [index, line] of lines.entries()) {
        if (/^\s*(?:#|\/\*|\*|\/\/)/.test(line)) continue;
        const matches = [...line.matchAll(/\b(SDL_(?:MALLOC|ALIGNED|ALLOC_SIZE2?))\b/g)];
        if (matches.length > 0 && !/\bextern\b/.test(line)) {
          throw new Error(
            `allocator attribute at ${path}:${index + 1} is not a public declaration`,
          );
        }
        for (const match of matches) {
          const declaration = line.match(/\bSDLCALL\s+(SDL_[A-Za-z0-9_]+)\s*\(/)?.[1];
          if (!declaration) {
            throw new Error(
              `allocator attribute ${match[1]} at ${path}:${index + 1} has no declaration`,
            );
          }
          applications.push({ macro: match[1], declaration, line: index + 1 });
        }
      }
    }
  }
  await visit(root);
  assertEquals(applications.map(({ macro, declaration }) => [macro, declaration]), [
    ["SDL_MALLOC", "SDL_malloc"],
    ["SDL_MALLOC", "SDL_calloc"],
    ["SDL_ALLOC_SIZE2", "SDL_calloc"],
    ["SDL_ALLOC_SIZE", "SDL_realloc"],
    ["SDL_MALLOC", "SDL_aligned_alloc"],
    ["SDL_MALLOC", "SDL_strdup"],
    ["SDL_MALLOC", "SDL_strndup"],
  ]);
  // SDL_ALIGNED and SDL_RESTRICT occur only in implementation examples or macro definitions
  // in this release; no public declaration consumes either contract.
  assertEquals(applications.some(({ macro }) => macro === "SDL_ALIGNED"), false);
  assertEquals(applications.some(({ macro }) => macro === "SDL_RESTRICT"), false);
});

Deno.test("normalizes allocation and restrict attributes without process-local IDs", () => {
  const json = JSON.stringify({
    kind: "TranslationUnitDecl",
    inner: [{
      id: "changed-on-every-run",
      kind: "FunctionDecl",
      name: "SDL_allocated",
      loc: { file: "include/attributes.h", line: 31 },
      inner: [
        { id: "alloc-attr", kind: "AllocSizeAttr", range: { begin: { line: 31, col: 1 } } },
        { id: "restrict-attr", kind: "RestrictAttr" },
      ],
    }],
  });
  const [result] = parseClangAttributeJson(json, { publicFilePrefixes: ["include/"] });
  assertEquals(result.semantics.restrict, true);
  assertEquals(result.cName, "SDL_allocated");
});

Deno.test("recovers malloc-like metadata when Clang lowers SDL_MALLOC to RestrictAttr", () => {
  const source = "SDL_MALLOC void *SDL_malloc(size_t size);\n";
  const json = JSON.stringify({
    kind: "TranslationUnitDecl",
    inner: [{
      kind: "FunctionDecl",
      name: "SDL_malloc",
      loc: { file: "include/SDL_stdinc.h", line: 1 },
      type: { qualType: "void *(size_t)" },
      inner: [{
        kind: "RestrictAttr",
        range: { begin: { expansionLoc: { file: "include/SDL_stdinc.h", line: 1 } } },
      }],
    }],
  });
  const [result] = parseClangAttributeJson(json, {
    publicFilePrefixes: ["include/"],
    sourceTextByFile: { "include/SDL_stdinc.h": source },
  });
  assertEquals(result.semantics.mallocLike, true);
  assertEquals(result.semantics.restrict, true);
});

Deno.test("normalizes deprecation guidance alongside result-use intent", () => {
  const json = JSON.stringify({
    kind: "TranslationUnitDecl",
    inner: [{
      kind: "FunctionDecl",
      name: "PATTERN_OldOperation",
      loc: { file: "include/attributes.h", line: 48 },
      inner: [
        {
          kind: "DeprecatedAttr",
          message: "Use the newer operation.",
          replacement: "PATTERN_NewOperation",
        },
        { kind: "NoDiscardAttr" },
      ],
    }],
  });
  const [result] = parseClangAttributeJson(json, { publicFilePrefixes: ["include/"] });
  assertEquals(result.semantics.deprecated, {
    message: "Use the newer operation.",
    replacement: "PATTERN_NewOperation",
  });
  assertEquals(result.semantics.resultUse, "should_use");
});

Deno.test("rejects allocation-size parameters outside the declared function", () => {
  const json = JSON.stringify({
    kind: "TranslationUnitDecl",
    inner: [{
      kind: "FunctionDecl",
      name: "PATTERN_BadAllocation",
      loc: { file: "include/attributes.h", line: 56 },
      inner: [
        { kind: "ParmVarDecl", name: "size" },
        { kind: "AllocSizeAttr", param1: 2 },
      ],
    }],
  });
  assertThrows(
    () => parseClangAttributeJson(json, { publicFilePrefixes: ["include/"] }),
    Error,
    "indices 1 exceed 1 parameters",
  );
});

Deno.test("rejects allocator metadata with a non-pointer result or size parameter", () => {
  const nonPointerResult = JSON.stringify({
    kind: "TranslationUnitDecl",
    inner: [{
      kind: "FunctionDecl",
      name: "PATTERN_BadResult",
      loc: { file: "include/attributes.h", line: 64 },
      type: { qualType: "int (double)" },
      inner: [
        { kind: "ParmVarDecl", type: { qualType: "double" } },
        { kind: "AllocSizeAttr", param1: 1 },
      ],
    }],
  });
  assertThrows(
    () => parseClangAttributeJson(nonPointerResult, { publicFilePrefixes: ["include/"] }),
    Error,
    "non-integer type double",
  );

  const nonPointerReturn = JSON.stringify({
    kind: "TranslationUnitDecl",
    inner: [{
      kind: "FunctionDecl",
      name: "PATTERN_BadReturn",
      loc: { file: "include/attributes.h", line: 72 },
      type: { qualType: "int (int)" },
      inner: [
        { kind: "ParmVarDecl", type: { qualType: "int" } },
        { kind: "AllocSizeAttr", param1: 1 },
      ],
    }],
  });
  assertThrows(
    () => parseClangAttributeJson(nonPointerReturn, { publicFilePrefixes: ["include/"] }),
    Error,
    "function return type int (int) is not a pointer",
  );
});
