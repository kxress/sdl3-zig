import { relative, resolve } from "@std/path";
import { codegenConfiguration } from "./codegen/config.ts";
import { repositoryRoot } from "./utils/paths.ts";

const manifestName = ".sdl3-docs.json";
const versionPattern = /^\d+\.\d+\.\d+(?:\+\d+)?$/;
const commitPattern = /^[0-9a-f]{40}$/;

export interface DocumentationManifest {
  format: 1;
  package_version: string;
  release_tag: string;
  commit: string;
  version_path: string;
  latest_path: "latest";
  content_sha256: string;
  coverage_sha256: string;
  coverage_identity_count: number;
  links: DocumentationLink[];
}

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

export function validateManifest(
  manifest: DocumentationManifest,
  expectedTag?: string,
  expectedCommit?: string,
): void {
  if (manifest.format !== 1 || !versionPattern.test(manifest.package_version)) {
    throw new Error("Documentation artifact has invalid version metadata");
  }
  if (manifest.release_tag !== `v${manifest.package_version}`) {
    throw new Error("Documentation artifact release tag does not match its package version");
  }
  if (expectedTag && manifest.release_tag !== expectedTag) {
    throw new Error(`Documentation artifact has wrong release tag: ${manifest.release_tag}`);
  }
  if (!commitPattern.test(manifest.commit)) {
    throw new Error("Documentation artifact has invalid commit metadata");
  }
  if (expectedCommit && manifest.commit !== expectedCommit) {
    throw new Error("Documentation artifact was built from a different commit");
  }
  if (manifest.version_path !== manifest.release_tag || manifest.latest_path !== "latest") {
    throw new Error("Documentation artifact has invalid version paths");
  }
  if (
    !/^[0-9a-f]{64}$/.test(manifest.content_sha256) ||
    !/^[0-9a-f]{64}$/.test(manifest.coverage_sha256)
  ) {
    throw new Error("Documentation artifact has invalid content hashes");
  }
  if (
    !Number.isSafeInteger(manifest.coverage_identity_count) || manifest.coverage_identity_count < 1
  ) {
    throw new Error("Documentation artifact has invalid coverage metadata");
  }
  if (manifest.links.length !== codegenConfiguration.libraries.length) {
    throw new Error("Documentation artifact is missing a library cross-link");
  }
  for (const link of manifest.links) {
    if (
      !link.module || !link.ergonomic_path || link.c_headers.length === 0 ||
      link.upstream_headers.length !== link.c_headers.length || !link.upstream_symbols
    ) {
      throw new Error(`Documentation artifact has incomplete links for ${link.module}`);
    }
  }
}

export async function packageDocumentation(options: {
  input: string;
  output: string;
  existing?: string;
  tag: string;
  commit: string;
}): Promise<DocumentationManifest> {
  const input = resolve(options.input);
  const output = resolve(options.output);
  const existing = options.existing ? resolve(options.existing) : undefined;
  const packageSource = await Deno.readTextFile(`${repositoryRoot}/build.zig.zon`);
  const coverageSource = await Deno.readTextFile(`${repositoryRoot}/api_coverage.json`);
  const version = packageVersion(packageSource);
  const expectedTag = `v${version}`;
  if (options.tag !== expectedTag) {
    throw new Error(`Release tag ${options.tag} does not match package version ${version}`);
  }
  if (!commitPattern.test(options.commit)) throw new Error("Release commit must be a full SHA-1");
  validateCoverageJson(coverageSource);
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
  const manifest: DocumentationManifest = {
    format: 1,
    package_version: version,
    release_tag: expectedTag,
    commit: options.commit,
    version_path: expectedTag,
    latest_path: "latest",
    content_sha256: await contentHash(output),
    coverage_sha256: await sha256(new TextEncoder().encode(coverageSource)),
    coverage_identity_count:
      (JSON.parse(coverageSource) as { identities: unknown[] }).identities.length,
    links,
  };
  validateManifest(manifest, expectedTag, options.commit);
  await Deno.writeTextFile(`${output}/${manifestName}`, `${JSON.stringify(manifest, null, 2)}\n`);
  return manifest;
}

export async function validateDocumentationArtifact(
  root: string,
  expectedTag?: string,
  expectedCommit?: string,
): Promise<DocumentationManifest> {
  const directory = resolve(root);
  const manifest = JSON.parse(
    await Deno.readTextFile(`${directory}/${manifestName}`),
  ) as DocumentationManifest;
  validateManifest(manifest, expectedTag, expectedCommit);
  await requireDirectory(`${directory}/${manifest.version_path}`, "versioned documentation");
  await requireDirectory(`${directory}/${manifest.latest_path}`, "latest documentation");
  if (!await exists(`${directory}/index.html`)) {
    throw new Error("Documentation artifact lacks index.html");
  }
  await validateLocalLinks(directory);
  const actualHash = await contentHash(directory);
  if (actualHash !== manifest.content_sha256) {
    throw new Error("Documentation artifact content does not match its manifest");
  }
  return manifest;
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

function validateCoverageJson(source: string): void {
  const coverage = JSON.parse(source) as { format?: number; identities?: unknown[] };
  if (coverage.format !== 1 || !coverage.identities || coverage.identities.length === 0) {
    throw new Error("Coverage ledger is missing or invalid");
  }
}

async function contentHash(root: string): Promise<string> {
  const entries: string[] = [];
  for await (const path of filePaths(root)) {
    const relativePath = relative(root, path).replaceAll("\\", "/");
    if (relativePath === manifestName) continue;
    const bytes = await Deno.readFile(path);
    entries.push(`${relativePath}\0${await sha256(bytes)}`);
  }
  entries.sort();
  return sha256(new TextEncoder().encode(`${entries.join("\n")}\n`));
}

async function* filePaths(directory: string): AsyncGenerator<string> {
  for await (const entry of Deno.readDir(directory)) {
    const path = `${directory}/${entry.name}`;
    if (entry.isDirectory) yield* filePaths(path);
    else if (entry.isFile) yield path;
  }
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

async function validateLocalLinks(root: string): Promise<void> {
  const index = await Deno.readTextFile(`${root}/index.html`);
  for (const match of index.matchAll(/\bhref="([^"]+)"/g)) {
    const href = match[1].split(/[?#]/, 1)[0];
    if (!href || href.startsWith("#") || /^[a-z][a-z0-9+.-]*:/i.test(href)) continue;
    const target = `${root}/${href.replace(/^\//, "")}`;
    const path = href.endsWith("/") ? target.slice(0, -1) : target;
    if (!await exists(path)) throw new Error(`Documentation artifact has a broken link: ${href}`);
  }
}

async function exists(path: string): Promise<boolean> {
  return await Deno.stat(path).then(() => true).catch(() => false);
}

async function removeIfPresent(path: string): Promise<void> {
  if (await exists(path)) await Deno.remove(path, { recursive: true });
}

async function sha256(bytes: Uint8Array): Promise<string> {
  const input = new Uint8Array(bytes.byteLength);
  input.set(bytes);
  return [...new Uint8Array(await crypto.subtle.digest("SHA-256", input.buffer))]
    .map((byte) => byte.toString(16).padStart(2, "0")).join("");
}

function escapeHtml(value: string): string {
  return value.replaceAll("&", "&amp;").replaceAll("<", "&lt;").replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;");
}

function usage(): never {
  throw new Error(
    "usage: package-documentation.ts <package|validate> --root <path> [--existing <path>] " +
      "[--tag <tag> --commit <sha>]",
  );
}

function argument(name: string): string | undefined {
  const index = Deno.args.indexOf(name);
  return index < 0 ? undefined : Deno.args[index + 1];
}

if (import.meta.main) {
  const command = Deno.args[0];
  const root = argument("--root");
  if (!root || !["package", "validate"].includes(command)) usage();
  if (command === "validate") {
    await validateDocumentationArtifact(root, argument("--tag"), argument("--commit"));
  } else {
    const tag = argument("--tag");
    const commit = argument("--commit");
    const output = argument("--output");
    if (!tag || !commit || !output) usage();
    await packageDocumentation({
      input: root,
      output,
      existing: argument("--existing"),
      tag,
      commit,
    });
  }
}
