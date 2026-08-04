export type PrebuiltFamily = "mingw" | "msvc" | "macos";
export type WindowsPrebuiltFamily = Exclude<PrebuiltFamily, "macos">;
export type DistributionMode = "none" | "system" | "prebuilt" | "source";
export type Linkage = "static" | "shared";
export type PrebuiltOs = "windows" | "macos";
export type PrebuiltAbi = "gnu" | "msvc" | null;

export interface PrebuiltTarget {
  os: PrebuiltOs;
  abi: PrebuiltAbi;
  arch: "x86" | "x86_64" | "aarch64";
  family: PrebuiltFamily;
  packageFamily: "windows-gnu" | "windows-msvc" | "macos";
  upstreamArch: string;
}

/** The complete set of package-local prebuilt target directories. */
export const prebuiltTargets: readonly PrebuiltTarget[] = [
  {
    os: "windows",
    abi: "gnu",
    arch: "x86",
    family: "mingw",
    packageFamily: "windows-gnu",
    upstreamArch: "i686-w64-mingw32",
  },
  {
    os: "windows",
    abi: "gnu",
    arch: "x86_64",
    family: "mingw",
    packageFamily: "windows-gnu",
    upstreamArch: "x86_64-w64-mingw32",
  },
  {
    os: "windows",
    abi: "msvc",
    arch: "x86",
    family: "msvc",
    packageFamily: "windows-msvc",
    upstreamArch: "x86",
  },
  {
    os: "windows",
    abi: "msvc",
    arch: "x86_64",
    family: "msvc",
    packageFamily: "windows-msvc",
    upstreamArch: "x64",
  },
  {
    os: "windows",
    abi: "msvc",
    arch: "aarch64",
    family: "msvc",
    packageFamily: "windows-msvc",
    upstreamArch: "arm64",
  },
  {
    os: "macos",
    abi: null,
    arch: "x86_64",
    family: "macos",
    packageFamily: "macos",
    upstreamArch: "",
  },
  {
    os: "macos",
    abi: null,
    arch: "aarch64",
    family: "macos",
    packageFamily: "macos",
    upstreamArch: "",
  },
];

export const distributionPolicy = {
  modes: [
    "none",
    "system",
    "prebuilt",
    "source",
  ] as const satisfies readonly DistributionMode[],
  prebuilt: { linkage: "shared" as Linkage },
  system: { linkages: ["static", "shared"] as const satisfies readonly Linkage[] },
  source: { linkages: ["static", "shared"] as const satisfies readonly Linkage[] },
};

export const windowsOptionalArchitectures: Record<"mingw" | "msvc", string[]> = {
  mingw: prebuiltTargets
    .filter((target) => target.family === "mingw")
    .map((target) => target.arch),
  msvc: prebuiltTargets
    .filter((target) => target.family === "msvc" && target.arch !== "aarch64")
    .map((target) => target.arch),
};

export function prebuiltTargetsFor(family: PrebuiltFamily): PrebuiltTarget[] {
  return prebuiltTargets.filter((target) => target.family === family);
}

export function findPrebuiltTarget(
  os: string,
  abi: string | null,
  arch: string,
): PrebuiltTarget | undefined {
  return prebuiltTargets.find((target) =>
    target.os === os && target.abi === abi && target.arch === arch
  );
}

export function targetName(target: Pick<PrebuiltTarget, "os" | "abi" | "arch">): string {
  return [target.arch, target.os, target.abi].filter(Boolean).join("-");
}
