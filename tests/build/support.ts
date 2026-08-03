import { copy } from "@std/fs/copy";
import { relative } from "@std/path";

const distributionSdlFixture = `${import.meta.dirname}/fixtures/distribution_sdl`;

export interface CommandOptions {
  cwd?: string;
  env?: Record<string, string>;
  stdout?: "inherit" | "piped";
  stderr?: "inherit" | "piped";
}

export async function command(
  executable: string,
  args: string[],
  options: CommandOptions = {},
): Promise<Deno.CommandOutput> {
  return await new Deno.Command(executable, {
    args,
    cwd: options.cwd,
    env: options.env,
    stdout: options.stdout ?? "piped",
    stderr: options.stderr ?? "piped",
  }).output();
}

export async function run(
  executable: string,
  args: string[],
  options: CommandOptions = {},
): Promise<void> {
  const result = await command(executable, args, options);
  if (result.success) return;
  const stderr = options.stderr === "inherit"
    ? "(stderr inherited by parent process)"
    : new TextDecoder().decode(result.stderr);
  throw new Error(`${executable} ${args.join(" ")} exited with code ${result.code}:\n${stderr}`);
}

export function relativePath(fromDirectory: string, destination: string): string {
  return relative(fromDirectory, destination).replaceAll("\\", "/") || ".";
}

export async function withTempDirectory<T>(
  prefix: string,
  action: (path: string) => Promise<T>,
): Promise<T> {
  const path = await Deno.makeTempDir({ prefix });
  try {
    return await action(path);
  } finally {
    await Deno.remove(path, { recursive: true });
  }
}

export async function stageDistributionConsumer(
  temporary: string,
  packageRoot: string,
): Promise<string> {
  const consumer = `${temporary}/consumer`;
  await copy(distributionSdlFixture, consumer);
  await Deno.writeTextFile(
    `${consumer}/build.zig.zon`,
    consumerManifest(relativePath(consumer, packageRoot)),
  );
  return consumer;
}

export async function buildDistributionConsumer(
  consumer: string,
  temporary: string,
  target: string,
  output: string,
  options: string[],
): Promise<void> {
  await run("zig", [
    "build",
    `-Dtarget=${target}`,
    ...options,
    "-p",
    output,
    "--cache-dir",
    `${temporary}/cache/${target}-${output.slice(output.lastIndexOf("/") + 1)}/local`,
    "--global-cache-dir",
    `${temporary}/cache/${target}-${output.slice(output.lastIndexOf("/") + 1)}/global`,
  ], { cwd: consumer, stdout: "inherit", stderr: "inherit" });
}

export async function runWindowsExecutable(
  executable: string,
  cwd: string,
  env?: Record<string, string>,
): Promise<void> {
  await run("cmd", ["/d", "/c", executable], { cwd, env, stdout: "inherit", stderr: "inherit" });
}

function consumerManifest(dependency: string): string {
  return `.{
    .name = .sdl3_distribution_consumer,
    .version = "0.0.0",
    .fingerprint = 0xf2a2ad551e264093,
    .minimum_zig_version = "0.16.0",
    .dependencies = .{
        .sdl3 = .{ .path = "${dependency.replaceAll("\\", "/")}" },
    },
    .paths = .{
        "build.zig",
        "build.zig.zon",
        "image.zig",
        "all.zig",
    },
}
`;
}
