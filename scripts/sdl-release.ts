import { runCommand } from "./utils/command.ts";
import { prebuiltTargets, windowsOptionalArchitectures } from "./distribution-policy.ts";
import { repositoryRoot } from "./utils/paths.ts";

export { windowsOptionalArchitectures };

export interface WindowsOptionalRuntime {
  dlls: string[];
  licenses: string[];
}

export type PrebuiltSource = "upstream" | "release" | false;
export type PrebuiltKind = "shared" | "static";

export interface SdlComponent {
  id: string;
  key: string;
  version: string;
  vendorId: string;
  libraryName?: string;
  pkgConfigName: string;
  prebuilt: PrebuiltSource;
  prebuiltKind?: PrebuiltKind;
  sourceBuildDirectory?: string;
  macosOptionalFrameworks?: string[];
  windowsOptionalRuntime?: WindowsOptionalRuntime;
}

export interface SdlRelease {
  sdlVersion: string;
  components: SdlComponent[];
}

type ComponentDefinition = Omit<SdlComponent, "version"> & {
  sourceArtifact?: string;
};
type MiseTool = {
  active: boolean;
  install_path: string;
  installed: boolean;
  version: string;
};

const miseEnvironment = "sdl";
const bindingRevision: number = 9;

const definitions: ComponentDefinition[] = [
  { id: "SDL3", key: "sdl", vendorId: "SDL3", pkgConfigName: "sdl3", prebuilt: "upstream" },
  {
    id: "SDL3_test",
    key: "test",
    vendorId: "SDL3",
    pkgConfigName: "SDL3_test",
    prebuilt: "release",
    prebuiltKind: "static",
    sourceArtifact: "http:sdl-source",
  },
  {
    id: "ControllerImage",
    key: "controller_image",
    vendorId: "ControllerImage",
    libraryName: "controllerimage",
    pkgConfigName: "ControllerImage",
    prebuilt: "release",
    prebuiltKind: "static",
    sourceArtifact: "http:controller-image-source",
    sourceBuildDirectory: "ControllerImage",
  },
  {
    id: "SDL3_shadercross",
    key: "shadercross",
    vendorId: "SDL3_shadercross",
    pkgConfigName: "SDL3_shadercross",
    prebuilt: "release",
    prebuiltKind: "shared",
    sourceArtifact: "http:sdl-shadercross-source",
  },
  {
    id: "SDL3_image",
    key: "image",
    vendorId: "SDL3_image",
    pkgConfigName: "SDL3_image",
    prebuilt: "upstream",
    macosOptionalFrameworks: ["avif", "jxl", "png", "webp"],
    windowsOptionalRuntime: {
      dlls: [
        "libavif-16.dll",
        "libpng16-16.dll",
        "libtiff-6.dll",
        "libwebp-7.dll",
        "libwebpdemux-2.dll",
        "libwebpmux-3.dll",
      ],
      licenses: [
        "LICENSE.aom.txt",
        "LICENSE.avif.txt",
        "LICENSE.dav1d.txt",
        "LICENSE.libpng.txt",
        "LICENSE.tiff.txt",
        "LICENSE.webp.txt",
      ],
    },
  },
  {
    id: "SDL3_ttf",
    key: "ttf",
    vendorId: "SDL3_ttf",
    pkgConfigName: "SDL3_ttf",
    prebuilt: "upstream",
  },
  {
    id: "SDL3_mixer",
    key: "mixer",
    vendorId: "SDL3_mixer",
    pkgConfigName: "SDL3_mixer",
    prebuilt: "upstream",
    macosOptionalFrameworks: ["gme", "ogg", "opus", "wavpack", "xmp"],
    windowsOptionalRuntime: {
      dlls: [
        "libgme.dll",
        "libogg-0.dll",
        "libopus-0.dll",
        "libopusfile-0.dll",
        "libwavpack-1.dll",
        "libxmp.dll",
      ],
      licenses: [
        "LICENSE.gme.txt",
        "LICENSE.ogg-vorbis.txt",
        "LICENSE.opus.txt",
        "LICENSE.opusfile.txt",
        "LICENSE.wavpack.txt",
        "LICENSE.xmp.txt",
      ],
    },
  },
  {
    id: "SDL3_net",
    key: "net",
    vendorId: "SDL3_net",
    pkgConfigName: "SDL3_net",
    prebuilt: "upstream",
  },
];

export async function loadSdlRelease(): Promise<SdlRelease> {
  const tools = await loadMiseTools();
  const components = definitions.map((definition) => {
    const versions = [
      ...new Set(
        componentArtifactNames(definition).map((name) => requireMiseTool(tools, name).version),
      ),
    ];
    const version = versions[0];
    if (versions.length !== 1 || !/^\d+\.\d+\.\d+$/.test(version)) {
      throw new Error(
        `${definition.id}: artifact versions must be one matching SDL release, found ${
          versions.join(", ")
        }`,
      );
    }
    return { ...definition, version };
  });

  return {
    sdlVersion: components[0].version,
    components,
  };
}

export function releaseVersion(release: SdlRelease): string {
  return bindingRevision === 0 ? release.sdlVersion : `${release.sdlVersion}+${bindingRevision}`;
}

export function packagePaths(release: SdlRelease): string[] {
  return [
    ...new Set([
      "build.zig",
      "build-maintenance.zig",
      "build",
      "build.zig.zon",
      "sdl_metadata.zig",
      "src",
      "examples/build.zig",
      "examples/catalog.zig",
      "examples/environment.zig",
      "examples/list.zig",
      "examples/project.zig",
      "prebuilt",
      ...release.components.map((component) => `vendor/${component.vendorId}`),
      "LICENSE",
      "README.md",
    ]),
  ];
}

export function artifactName(
  component: ComponentDefinition,
  kind: string,
): string {
  const prefix = component.key === "sdl" ? "http:sdl" : `http:sdl-${component.key}`;
  return `${prefix}-${kind}`;
}

function componentArtifactNames(component: ComponentDefinition): string[] {
  return [
    component.sourceArtifact ?? artifactName(component, "source"),
    ...(component.prebuilt === "upstream" ? binaryArtifactNames(component) : []),
  ];
}

export function binaryArtifactNames(component: ComponentDefinition): string[] {
  const names = [...new Set(prebuiltTargets.map((target) => target.family))].map((family) =>
    artifactName(component, family)
  );
  if (component.windowsOptionalRuntime) {
    names.push(
      artifactName(component, "mingw-x86-runtime"),
      artifactName(component, "mingw-x86_64-runtime"),
    );
  }
  return names;
}

export async function installArtifacts(names: Iterable<string>): Promise<Map<string, string>> {
  const requested = [...new Set(names)];
  if (requested.length === 0) return new Map();

  await runMise(["install", ...requested]);
  const tools = await loadMiseTools();
  return new Map(requested.map((name) => {
    const tool = requireMiseTool(tools, name);
    if (!tool.installed || !tool.install_path) {
      throw new Error(`mise did not install ${name}`);
    }
    return [name, tool.install_path];
  }));
}

async function loadMiseTools(): Promise<Map<string, MiseTool>> {
  const parsed = JSON.parse(await runMise(["ls", "--current", "--json"])) as Record<
    string,
    MiseTool[]
  >;
  const tools = new Map<string, MiseTool>();
  for (const [name, candidates] of Object.entries(parsed)) {
    const current = candidates.find((candidate) => candidate.active) ?? candidates[0];
    if (current) tools.set(name, current);
  }
  return tools;
}

function requireMiseTool(tools: Map<string, MiseTool>, name: string): MiseTool {
  const tool = tools.get(name);
  if (!tool) throw new Error(`mise.sdl.toml does not define ${name}`);
  return tool;
}

async function runMise(args: string[]): Promise<string> {
  return (await runCommand("mise", ["--quiet", "-E", miseEnvironment, ...args], {
    cwd: repositoryRoot,
  })).stdout;
}
