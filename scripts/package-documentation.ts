import { resolve } from "@std/path";
import { codegenConfiguration } from "./codegen/config.ts";
import { repositoryRoot } from "./utils/paths.ts";

const versionPattern = /^\d+\.\d+\.\d+(?:\+\d+)?$/;

export interface DocumentationLink {
  module: string;
  display_name: string;
  ergonomic_path: string;
  c_headers: string[];
  upstream_headers: string[];
  upstream_symbols: string;
}

export function packageVersion(source: string): string {
  const match = source.match(/\.version\s*=\s*"([^"]+)"/);
  const version = match?.[1];
  if (!version || !versionPattern.test(version)) {
    throw new Error("build.zig.zon does not contain a valid package version");
  }
  return version;
}

export async function packageDocumentation(options: {
  input: string;
  output: string;
  existing?: string;
  tag: string;
}): Promise<void> {
  const input = resolve(options.input);
  const output = resolve(options.output);
  const existing = options.existing ? resolve(options.existing) : undefined;
  const packageSource = await Deno.readTextFile(`${repositoryRoot}/build.zig.zon`);
  const version = packageVersion(packageSource);
  const expectedTag = `v${version}`;
  if (options.tag !== expectedTag) {
    throw new Error(`Release tag ${options.tag} does not match package version ${version}`);
  }
  await requireDirectory(input, "generated documentation");

  await removeIfPresent(output);
  await Deno.mkdir(output, { recursive: true });
  if (existing && await exists(existing)) await copyTree(existing, output);

  const versionDirectory = `${output}/${expectedTag}`;
  if (await exists(versionDirectory)) {
    throw new Error(`Immutable documentation version already exists: ${expectedTag}`);
  }
  await copyTree(input, versionDirectory);
  await copyTree(input, `${output}/latest`);

  const links = await documentationLinks(expectedTag);
  await Deno.writeTextFile(`${output}/index.html`, renderIndex(version, expectedTag, links));
}

async function documentationLinks(tag: string): Promise<DocumentationLink[]> {
  const refs = await upstreamRefs();
  return codegenConfiguration.libraries.map((library) => {
    const repo = upstreamRepository(library.id);
    const ref = refs.get(library.id);
    if (!ref) throw new Error(`No upstream documentation ref configured for ${library.id}`);
    const sourceRoot = library.id === "ControllerImage" ? "src" : "include";
    const upstreamHeaders = library.headers.map((header) =>
      `https://github.com/${repo}/blob/${ref}/${sourceRoot}/${header}`
    );
    return {
      module: library.profile.moduleName,
      display_name: library.profile.displayName,
      ergonomic_path: `${tag}/`,
      c_headers: library.headers,
      upstream_headers: upstreamHeaders,
      upstream_symbols: `https://github.com/${repo}/search?q=${
        encodeURIComponent(library.profile.symbolPrefixes[0])
      }&type=code`,
    };
  });
}

function upstreamRepository(id: string): string {
  if (id === "ControllerImage") return "icculus/ControllerImage";
  if (id === "SDL3_test") return "libsdl-org/SDL";
  if (id === "SDL3_shadercross") return "libsdl-org/SDL_shadercross";
  return `libsdl-org/${id.replace(/^SDL3_/, "SDL_").replace(/^SDL3$/, "SDL")}`;
}

async function upstreamRefs(): Promise<Map<string, string>> {
  const source = await Deno.readTextFile(`${repositoryRoot}/mise.sdl.toml`);
  const refs = new Map<string, string>();
  const artifactToLibrary: Record<string, string> = {
    "sdl-source": "SDL3",
    "sdl-image-source": "SDL3_image",
    "sdl-ttf-source": "SDL3_ttf",
    "sdl-mixer-source": "SDL3_mixer",
    "sdl-net-source": "SDL3_net",
    "controller-image-source": "ControllerImage",
    "sdl-shadercross-source": "SDL3_shadercross",
  };
  const blockPattern = /\[tools\."http:([^\"]+)"\]\n([\s\S]*?)(?=\n\[tools\.|$)/g;
  for (const match of source.matchAll(blockPattern)) {
    const library = artifactToLibrary[match[1]];
    if (!library) continue;
    const url = match[2].match(/^url\s*=\s*"([^"]+)"/m)?.[1];
    const ref = url?.match(/releases\/download\/([^/]+)\//) ??
      url?.match(/archive\/([^/]+?)(?:\.tar\.gz|\.zip)?(?:\/|$)/);
    if (!ref) throw new Error(`Cannot derive upstream ref from ${match[1]}`);
    refs.set(library, ref[1] ?? ref[2]);
  }
  refs.set("SDL3_test", refs.get("SDL3") ?? "");
  return refs;
}

function renderIndex(version: string, tag: string, links: DocumentationLink[]): string {
  const rows = links.map((link) => {
    const cHeaders = link.c_headers.map((header, index) =>
      `<li><code>${escapeHtml(header)}</code> · <a href="${
        link.upstream_headers[index]
      }">upstream C header</a></li>`
    ).join("");
    return `<tr><th scope="row"><code>${escapeHtml(link.module)}</code></th>` +
      `<td><a href="${tag}/">${escapeHtml(link.display_name)} ergonomic API</a></td>` +
      `<td><ul>${cHeaders}</ul><a href="${link.upstream_symbols}">upstream symbols</a></td></tr>`;
  }).join("\n");
  return `<!doctype html>
<html lang="en"><head><meta charset="utf-8"><title>SDL3 for Zig documentation</title></head>
<body><h1>SDL3 for Zig documentation</h1>
<p>Version <a href="${tag}/">${escapeHtml(version)}</a>; <a href="latest/">latest stable</a>.</p>
<p>Each row links the ergonomic Zig API to its generated C path and upstream symbols.</p>
<table><thead><tr><th>Module</th><th>Zig API</th><th>C and upstream API</th></tr></thead><tbody>
${rows}
</tbody></table></body></html>\n`;
}

async function copyTree(source: string, destination: string): Promise<void> {
  await Deno.mkdir(destination, { recursive: true });
  for await (const entry of Deno.readDir(source)) {
    if (entry.name === ".git") continue;
    const from = `${source}/${entry.name}`;
    const to = `${destination}/${entry.name}`;
    if (entry.isDirectory) await copyTree(from, to);
    else if (entry.isFile) await Deno.copyFile(from, to);
  }
}

async function requireDirectory(path: string, label: string): Promise<void> {
  const info = await Deno.stat(path).catch(() => undefined);
  if (!info?.isDirectory) throw new Error(`Missing ${label}: ${path}`);
}

async function exists(path: string): Promise<boolean> {
  return await Deno.stat(path).then(() => true).catch(() => false);
}

async function removeIfPresent(path: string): Promise<void> {
  if (await exists(path)) await Deno.remove(path, { recursive: true });
}

function escapeHtml(value: string): string {
  return value.replaceAll("&", "&amp;").replaceAll("<", "&lt;").replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;");
}

function usage(): never {
  throw new Error(
    "usage: package-documentation.ts package --root <path> [--existing <path>] --tag <tag>",
  );
}

function argument(name: string): string | undefined {
  const index = Deno.args.indexOf(name);
  return index < 0 ? undefined : Deno.args[index + 1];
}

if (import.meta.main) {
  const command = Deno.args[0];
  const root = argument("--root");
  const tag = argument("--tag");
  const output = argument("--output");
  if (command !== "package" || !root || !tag || !output) usage();
  await packageDocumentation({
    input: root,
    output,
    existing: argument("--existing"),
    tag,
  });
}
