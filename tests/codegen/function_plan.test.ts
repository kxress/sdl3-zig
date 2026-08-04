import { assertEquals } from "@std/assert";
import { createFunctionPlan, type FunctionFacts } from "../../scripts/codegen/function-plan.ts";

function facts(overrides: Partial<FunctionFacts> = {}): FunctionFacts {
  return {
    arguments: [],
    returnId: "void",
    sliceRelationships: [],
    outputValues: [],
    ownedVariadicString: false,
    borrowedResourceResult: false,
    variadic: false,
    ...overrides,
  };
}

Deno.test("function plans hide pointer-count bookkeeping for borrowed slices", () => {
  const plan = createFunctionPlan(facts({
    arguments: [{ name: "items", type: "pointer" }, { name: "count", type: "usize" }],
    sliceRelationships: [{ countIndex: 1, pointerIndexes: [0] }],
    borrowedSlice: { countIndex: 1, elementType: "u8" },
  }));

  assertEquals(plan.transformation, {
    kind: "borrowed_slice",
    info: { countIndex: 1, elementType: "u8" },
  });
  assertEquals(plan.hiddenParameterIndexes, [1]);
});

Deno.test("function plans prioritize structured output results over lower-level transforms", () => {
  const output = {
    kind: "value" as const,
    index: 1,
    argument: { name: "result", type: "pointer" },
    publicType: "Result",
    targetId: "result-type",
  };
  const plan = createFunctionPlan(facts({
    arguments: [{ name: "items", type: "pointer" }, output.argument, {
      name: "count",
      type: "usize",
    }],
    sliceRelationships: [{ countIndex: 2, pointerIndexes: [0] }],
    outputResult: { mode: "value_error", outputs: [output] },
    ownedByteSliceCountIndex: 2,
  }));

  assertEquals(plan.transformation, {
    kind: "output_result",
    info: { mode: "value_error", outputs: [output] },
  });
  assertEquals(plan.hiddenParameterIndexes, [2, 1]);
});

Deno.test("function plans preserve ownership before applying slice ergonomics", () => {
  const plan = createFunctionPlan(facts({
    arguments: [{ name: "count", type: "usize" }],
    ownedArray: {
      kind: "resources",
      countIndex: 0,
      elementId: "handle",
      resourceName: "Handle",
    },
    borrowedSlice: { countIndex: 0, elementType: "Handle" },
  }));

  assertEquals(plan.transformation, {
    kind: "owned_slice",
    info: {
      kind: "resources",
      countIndex: 0,
      elementId: "handle",
      resourceName: "Handle",
    },
  });
  assertEquals(plan.hiddenParameterIndexes, [0]);
});
