export interface FunctionArgument {
  name: string;
  type: string;
}

export interface SliceRelationship {
  countIndex: number;
  pointerIndexes: number[];
}

export type OutputValue =
  | {
    kind: "resource";
    index: number;
    argument: FunctionArgument;
    publicType: string;
    rawName: string;
    recordId: string;
    nullable: boolean;
  }
  | {
    kind: "value";
    index: number;
    argument: FunctionArgument;
    publicType: string;
    targetId: string;
  };

export type FailureMode =
  | "bool"
  | "null"
  | "negative"
  | "zero"
  | { kind: "symbol"; name: string }
  | { kind: "symbols"; names: string[] };

export type OutputResultMode =
  | "bool_error"
  | "bool_optional"
  | "void"
  | "value"
  | "value_error";

export interface OwnedStringRecordInfo {
  recordId: string;
  sourceCName: string;
  valueName: string;
  collectionName: string;
  fields: Array<
    | { kind: "string"; sourceName: string; publicName: string }
    | { kind: "value"; sourceName: string; publicName: string; typeId: string }
  >;
}

export interface BorrowedSliceInfo {
  countIndex: number;
  elementType: string;
}

export type OwnedArrayInfo =
  | {
    kind: "values";
    countIndex: number;
    elementId: string;
  }
  | {
    kind: "pointed_records";
    countIndex: number;
    elementId: string;
  }
  | {
    kind: "resources";
    countIndex: number;
    elementId: string;
    resourceName: string;
  }
  | {
    kind: "strings";
    countIndex?: number;
    elementId: string;
  }
  | {
    kind: "string_records";
    countIndex: number;
    elementId: string;
    record: OwnedStringRecordInfo;
  };

export interface OwnedOutputByteSliceInfo {
  dataIndex: number;
  lengthIndex: number;
  outputs: OutputValue[];
}

export interface OutputResultInfo {
  mode: OutputResultMode;
  outputs: OutputValue[];
}

export interface FunctionFacts {
  arguments: FunctionArgument[];
  returnId: string;
  sliceRelationships: SliceRelationship[];
  failure?: FailureMode;
  outputResultMode?: OutputResultMode;
  outputValues: OutputValue[];
  ownedOutputByteSlice?: OwnedOutputByteSliceInfo;
  outputResult?: OutputResultInfo;
  ownedVariadicString: boolean;
  ownedStringElement?: string;
  ownedByteSliceCountIndex?: number;
  ownedArray?: OwnedArrayInfo;
  borrowedSlice?: BorrowedSliceInfo;
  borrowedResourceResult: boolean;
  variadic: boolean;
}

export type FunctionTransformation =
  | { kind: "owned_output_byte_slice"; info: OwnedOutputByteSliceInfo }
  | { kind: "output_result"; info: OutputResultInfo }
  | { kind: "owned_variadic_string" }
  | { kind: "owned_string"; elementType: string }
  | { kind: "owned_byte_slice"; countIndex: number }
  | { kind: "owned_slice"; info: OwnedArrayInfo }
  | { kind: "borrowed_slice"; info: BorrowedSliceInfo }
  | { kind: "variadic" }
  | { kind: "direct" };

export interface FunctionPlan extends FunctionFacts {
  transformation: FunctionTransformation;
  hiddenParameterIndexes: number[];
}

export function createFunctionPlan(facts: FunctionFacts): FunctionPlan {
  const transformation: FunctionTransformation = facts.ownedOutputByteSlice
    ? { kind: "owned_output_byte_slice", info: facts.ownedOutputByteSlice }
    : facts.outputResult
    ? { kind: "output_result", info: facts.outputResult }
    : facts.ownedVariadicString
    ? { kind: "owned_variadic_string" }
    : facts.ownedStringElement
    ? { kind: "owned_string", elementType: facts.ownedStringElement }
    : facts.ownedByteSliceCountIndex !== undefined
    ? { kind: "owned_byte_slice", countIndex: facts.ownedByteSliceCountIndex }
    : facts.ownedArray
    ? { kind: "owned_slice", info: facts.ownedArray }
    : facts.borrowedSlice
    ? { kind: "borrowed_slice", info: facts.borrowedSlice }
    : facts.variadic
    ? { kind: "variadic" }
    : { kind: "direct" };

  const hidden = new Set(facts.sliceRelationships.map((relationship) => relationship.countIndex));
  if (facts.ownedOutputByteSlice) {
    hidden.add(facts.ownedOutputByteSlice.dataIndex);
    hidden.add(facts.ownedOutputByteSlice.lengthIndex);
    for (const output of facts.ownedOutputByteSlice.outputs) hidden.add(output.index);
  } else if (facts.outputResult) {
    for (const output of facts.outputResult.outputs) hidden.add(output.index);
  }
  if (facts.ownedByteSliceCountIndex !== undefined) {
    hidden.add(facts.ownedByteSliceCountIndex);
  }
  if (facts.ownedArray?.countIndex !== undefined) hidden.add(facts.ownedArray.countIndex);
  if (facts.borrowedSlice) hidden.add(facts.borrowedSlice.countIndex);
  if (facts.ownedVariadicString) hidden.add(0);

  return {
    ...facts,
    transformation,
    hiddenParameterIndexes: [...hidden],
  };
}
