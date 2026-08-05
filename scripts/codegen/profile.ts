export interface PublicSymbol {
  cName: string;
  path: string;
  kind: string;
}

/** Generator-owned metadata for a public wrapper that accepts a caller allocator. */
export interface OwnershipSymbol {
  cName: string;
  path: string;
  transformation: string;
  retainsAllocator: boolean;
  releasesSourceBeforeReturn: true;
}

export interface PublicReference {
  cName: string;
  kind: string;
}

export interface PublicApi {
  moduleName: string;
  symbolPrefixes: string[];
  symbols: PublicSymbol[];
  references: PublicReference[];
  ownership: OwnershipSymbol[];
}

export interface CoverageExclusion {
  names: string[];
  reason: string;
}

export type CoverageHandling =
  | "direct"
  | "indirect"
  | "semantic"
  | "additive"
  | "unrepresentable";

export type CoverageEvidenceKind =
  | "generated"
  | "policy"
  | "wrapper"
  | "normalized_effect"
  | "validation"
  | "test"
  | "additive_facility";

export interface CoverageEvidence {
  kind: CoverageEvidenceKind;
  source: string;
  targets: string[];
  detail: string;
}

export interface CoveragePolicy {
  cName: string;
  status: "intentional" | "limitation";
  handling: Exclude<CoverageHandling, "direct">;
  reason: string;
  evidence: CoverageEvidence[];
}

export function materializeCoveragePolicies(
  exclusions: CoverageExclusion[],
  targets: string[],
): CoveragePolicy[] {
  return exclusions.flatMap((exclusion) =>
    exclusion.names.map((cName) => {
      const handling = coverageHandling(cName);
      const kind = handling === "indirect"
        ? "wrapper"
        : handling === "semantic"
        ? "normalized_effect"
        : handling === "additive"
        ? "additive_facility"
        : "policy";
      const detail = handling === "indirect"
        ? "Application inventory: not observed; consumption: generated thread-creation wrappers; " +
          "no standalone hook name is emitted."
        : handling === "semantic"
        ? "Application inventory: not observed; consumption: generator policy/metadata rather than " +
          "a consumer-facing declaration."
        : handling === "additive"
        ? "Application inventory: not observed; consumption: reserved for the SDL-aware assertion " +
          "adapter disposition; the macro remains intentionally excluded."
        : "Application inventory: not observed; consumption: not applicable; " + exclusion.reason;
      return {
        cName,
        status: "intentional" as const,
        handling,
        reason: exclusion.reason,
        evidence: [{ kind, source: cName, targets: [...targets].sort(), detail }],
      };
    })
  );
}

function coverageHandling(cName: string): Exclude<CoverageHandling, "direct"> {
  if (cName === "SDL_BeginThreadFunction" || cName === "SDL_EndThreadFunction") return "indirect";
  if (
    cName === "SDL_PRINTF_VARARG_FUNC" || cName === "SDL_PRINTF_VARARG_FUNCV" ||
    cName === "SDL_SCANF_VARARG_FUNC" || cName === "SDL_SCANF_VARARG_FUNCV"
  ) return "semantic";
  // SDL's six assertion macros are intentionally rejected as unrepresentable.
  // They require C's per-call-site static SDL_AssertData, token stringification,
  // and macro-level elision.  Keeping this classification explicit prevents a
  // future generator change from accidentally treating a bool-taking helper as
  // an equivalent additive adapter.
  if (
    cName === "SDL_assert" || cName === "SDL_assert_release" ||
    cName === "SDL_assert_paranoid" || cName === "SDL_assert_always" ||
    cName === "SDL_enabled_assert" || cName === "SDL_disabled_assert"
  ) {
    return "unrepresentable";
  }
  if (
    cName === "SDL_ANALYZER_NORETURN" || cName === "SDL_DECLSPEC" ||
    cName === "SDL_DEPRECATED" || cName === "SDL_FALLTHROUGH" ||
    cName === "SDL_FORCE_INLINE" || cName === "SDL_INLINE" ||
    cName === "SDL_NODISCARD" || cName === "SDL_NORETURN" ||
    cName === "SDL_RESTRICT" || cName === "SDL_UNUSED"
  ) return "semantic";
  return "unrepresentable";
}

export interface ConstantFamily {
  prefix: string;
  typedef: string;
}

export interface MacroTypeAlias {
  name: string;
  type: string;
}

export interface LocalAllocatorProfile {
  provider: "local";
  malloc: string;
  realloc: string;
  free: string;
  alignedAlloc: string;
  alignedFree: string;
  setMemoryFunctions?: string;
  getNumAllocations?: string;
  alignmentGuarantee?: "sdl_bounded";
}

/**
 * A declaration-level allocation contract recovered from SDL's public attributes.
 *
 * Parameter indexes are zero-based, matching DeclarationSemantics after Clang's
 * one-based C attribute arguments have been normalized.  This metadata is used
 * only to validate generator planning and release selection; it never creates an
 * aliasing or ownership promise for callers.
 */
export interface AllocationContract {
  cName: string;
  mallocLike?: boolean;
  allocationSize?: number[];
  alignment?: number;
  releaseFunction?: string;
}

/**
 * A function-like macro whose consumer wrapper needs a hand-written Zig body.
 *
 * The renderer selects the implementation by this typed kind; the C names stay
 * in the library profile so coverage and ownership inventories do not depend on
 * renderer-local name lists.
 */
export interface ManualFunctionMacro {
  cName: string;
  kind: "iconv_utf8_locale" | "iconv_utf8_ucs2" | "iconv_utf8_ucs4" | "iconv_wchar_utf8";
  ownership?: {
    transformation: string;
    retainsAllocator: boolean;
    releasesSourceBeforeReturn: true;
  };
}

export interface DependencyAllocatorProfile {
  provider: "dependency";
  importName: string;
  publicPath: string;
  free: string;
}

export type AllocatorProfile = LocalAllocatorProfile | DependencyAllocatorProfile;

export type ErrorProfile =
  | { provider: "local" }
  | { provider: "dependency"; importName: string; publicPath: string };

export interface LibraryProfile {
  moduleName: string;
  displayName: string;
  abiImportName: string;
  symbolPrefixes: string[];
  dependencies: string[];
  error: ErrorProfile;
  allocator: AllocatorProfile;
  releaseFunctions: string[];
  allocationContracts?: AllocationContract[];
  manualFunctionMacros?: ManualFunctionMacro[];
  headerPrefixes: string[];
  rootHeaders: string[];
  namespaceStrategy: NamespaceStrategy;
  constantFamilies?: ConstantFamily[];
  macroPrefixes?: string[];
  macroNamePrefixes?: string[];
  macroTypeAliases?: MacroTypeAlias[];
  coverageExclusions?: CoverageExclusion[];
  coveragePolicies?: CoveragePolicy[];
}

export type NamespaceStrategy =
  | { kind: "header_stem" }
  | { kind: "documented_category" };
