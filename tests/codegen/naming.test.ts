import { assertEquals } from "@std/assert";
import { uniqueIdentifier, ZigNaming } from "../../scripts/codegen/naming.ts";

Deno.test("naming maps generic API identifiers into valid Zig names", () => {
  const naming = new ZigNaming(["PATTERN_GetHTTP2Value", "PATTERN_type"], ["PATTERN_"]);

  assertEquals(naming.functionName("PATTERN_GetHTTP2Value"), "getHttp2Value");
  assertEquals(naming.typeName("PATTERN_HTTP2Value"), "Http2Value");
  assertEquals(naming.valueName("PATTERN_type"), "type_");
  assertEquals(naming.fieldName("HTTP2_VALUE"), "http2_value");
});

Deno.test("naming assigns deterministic distinct names to collisions", () => {
  const used = new Set<string>();

  assertEquals(uniqueIdentifier("value", used), "value");
  assertEquals(uniqueIdentifier("value", used), "value_2");
  assertEquals(uniqueIdentifier("value", used), "value_3");
});

Deno.test("naming trims shared enum prefixes without colliding", () => {
  const naming = new ZigNaming(["PATTERN_MODE_FAST", "PATTERN_MODE_SAFE"], ["PATTERN_"]);

  assertEquals(
    [...naming.enumTagNames("PATTERN_Mode", ["PATTERN_MODE_FAST", "PATTERN_MODE_SAFE"])],
    [["PATTERN_MODE_FAST", "fast"], ["PATTERN_MODE_SAFE", "safe"]],
  );
});
