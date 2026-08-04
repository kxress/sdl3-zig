export interface PublicSymbol {
  cName: string;
  path: string;
  kind: string;
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
}

export interface ConstantFamily {
  prefix: string;
  typedef: string;
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
  headerPrefixes: string[];
  rootHeaders: string[];
  namespaceStrategy: NamespaceStrategy;
  constantFamilies?: ConstantFamily[];
}

export type NamespaceStrategy =
  | { kind: "header_stem" }
  | { kind: "documented_category" };
