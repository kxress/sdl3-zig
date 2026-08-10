/**
 * Open every catalog example in order, waiting for each one to be closed.
 *
 * Close the current example window to advance to the next one. If an example
 * fails to build or start, press Enter to continue or Ctrl+C to stop.
 *
 * Usage:
 *   deno run --allow-read --allow-run=zig scripts/run-examples.ts
 *   deno run --allow-read --allow-run=zig scripts/run-examples.ts --filter 'raylib-*'
 *   deno run --allow-read --allow-run=zig scripts/run-examples.ts --start-at sdl-demo-snake
 *   deno run --allow-read --allow-write --allow-run=zig scripts/run-examples.ts --test
 */

import { dirname, fromFileUrl } from "@std/path";

const scriptDirectory = dirname(fromFileUrl(import.meta.url));
const repository = dirname(scriptDirectory);

// Minimal vertex shader used by the catalog smoke test. It is deliberately kept as words so the
// fixture remains platform-independent when Deno writes it to a temporary file.
const testShaderSpirv = new Uint8Array(
  new Uint32Array([
    0x07230203,
    0x00010000,
    0,
    12,
    0,
    0x00020011,
    1,
    0,
    0x0003000e,
    0,
    1,
    0x0004000f,
    0,
    7,
    0x6e69616d,
    0x00030047,
    8,
    11,
    0x00020013,
    2,
    0x00030021,
    3,
    2,
    0x00030016,
    4,
    32,
    0x00040017,
    5,
    4,
    4,
    0x00040020,
    6,
    3,
    5,
    0x0004003b,
    6,
    8,
    3,
    0x0004002b,
    4,
    9,
    0,
    0x0006002c,
    5,
    10,
    9,
    9,
    9,
    9,
    0x00050036,
    2,
    7,
    0,
    3,
    0x000200f8,
    11,
    0x0003003e,
    8,
    10,
    0x000100fd,
    0x00010038,
  ]).buffer,
);

interface Options {
  filter: string;
  startAt?: string;
  test: boolean;
}

function parseOptions(args: string[]): Options {
  let filter = "*";
  let startAt: string | undefined;
  let test = false;

  for (let index = 0; index < args.length; index += 1) {
    const argument = args[index];
    if (argument === "--") {
      continue;
    } else if (argument === "--filter") {
      filter = args[++index] ?? "";
    } else if (argument === "--start-at") {
      startAt = args[++index];
    } else if (argument === "--test") {
      test = true;
    } else if (argument === "--help" || argument === "-h") {
      console.log(
        "Usage: deno run --allow-read --allow-write --allow-run=zig scripts/run-examples.ts [options]",
      );
      console.log("  --filter <glob>       Only run matching example names (default: *)");
      console.log("  --start-at <name>     Begin at this example in catalog order");
      console.log(
        "  --test                Smoke-test startup and close each example automatically",
      );
      Deno.exit(0);
    } else {
      throw new Error(`Unknown argument '${argument}'. Use --help for usage.`);
    }
  }
  return { filter, startAt, test };
}

function globRegExp(glob: string): RegExp {
  const escaped = glob.replace(/[.+^${}()|[\]\\]/g, "\\$&");
  return new RegExp(`^${escaped.replaceAll("*", ".*").replaceAll("?", ".")}$`);
}

async function runCommand(
  args: string[],
  output: "piped" | "inherit",
  signal?: AbortSignal,
) {
  const command = new Deno.Command("zig", {
    args,
    cwd: repository,
    stdout: output,
    stderr: output,
    signal,
  });
  return await command.output();
}

async function listExamples(): Promise<string[]> {
  const result = await runCommand(["build", "examples-list"], "piped");
  if (!result.success) {
    throw new Error(`Could not list examples (zig exit code ${result.code}).`);
  }

  const output = new TextDecoder().decode(result.stdout);
  return [...output.matchAll(/^\s{4}(\S+)\s+examples[\\/]/gm)].map((match) => match[1]);
}

function decode(output: Uint8Array): string {
  return new TextDecoder().decode(output).trim();
}

function diagnostic(output: Deno.CommandOutput): string {
  const stderr = decode(output.stderr);
  const stdout = decode(output.stdout);
  return [stderr, stdout].filter((value) => value.length > 0).join("\n\n");
}

async function runTest(name: string): Promise<string | undefined> {
  const pingPath = await Deno.makeTempFile({ prefix: `sdl-example-${name}-`, suffix: ".ping" });
  await Deno.writeTextFile(pingPath, "uninitialized");

  let shaderPath: string | undefined;
  try {
    if (name === "sdl-shader-device-load") {
      shaderPath = await Deno.makeTempFile({ prefix: "sdl-example-test-shader-", suffix: ".spv" });
      await Deno.writeFile(shaderPath, testShaderSpirv);
    }
    const exampleArgs = shaderPath ? ["spirv", shaderPath] : [];
    const commandArgs = ["build", `run-${name}`, "--", ...exampleArgs, "--test-ping", pingPath];
    let output: Deno.CommandOutput | undefined;
    let failure: string | undefined;
    try {
      output = await runCommand(commandArgs, "piped", AbortSignal.timeout(60_000));
    } catch (error) {
      failure = error instanceof Error ? error.message : String(error);
    }

    let ping = "uninitialized";
    try {
      ping = (await Deno.readTextFile(pingPath)).trim();
    } catch (error) {
      failure ??= `could not read test-ping file: ${error}`;
    }

    const details = output ? diagnostic(output) : "";
    if (output && !output.success) {
      failure = details || `zig exited with code ${output.code}`;
    }
    if (ping !== "ok") {
      failure ??= `example did not report ok (status: ${ping || "empty"})`;
    }

    if (failure) {
      const report = details && details !== failure ? `${failure}\n\n${details}` : failure;
      await Deno.writeTextFile(pingPath, report);
    }
    return failure;
  } finally {
    await Deno.remove(pingPath);
    if (shaderPath) await Deno.remove(shaderPath);
  }
}

async function main(): Promise<void> {
  const options = parseOptions(Deno.args);
  const filter = globRegExp(options.filter);
  let names = (await listExamples()).filter((name) => filter.test(name));
  if (names.length === 0) throw new Error(`No examples matched filter '${options.filter}'.`);

  if (options.startAt !== undefined) {
    const startIndex = names.indexOf(options.startAt);
    if (startIndex < 0) {
      throw new Error(`Unknown or filtered-out example '${options.startAt}'.`);
    }
    names = names.slice(startIndex);
  }

  if (options.test) {
    console.log(`Smoke-testing ${names.length} examples in catalog order.\n`);
  } else {
    console.log(`Running ${names.length} examples in catalog order.`);
    console.log("Close each example window to continue; press Ctrl+C to stop.\n");
  }

  const failures: string[] = [];
  for (const [index, name] of names.entries()) {
    console.log(`[${index + 1}/${names.length}] ${name}`);
    if (options.test) {
      const failure = await runTest(name);
      if (failure) {
        failures.push(name);
        console.error(`  FAIL: ${failure}`);
      } else {
        console.log("  ok");
      }
    } else {
      const result = await runCommand(["build", `run-${name}`], "inherit");
      if (!result.success) {
        console.error(`  startup/build exited with code ${result.code}`);
        prompt("  Press Enter to continue, or Ctrl+C to stop");
      }
    }
    console.log();
  }
  if (failures.length > 0) {
    throw new Error(`Example smoke test failures: ${failures.join(", ")}`);
  }
  console.log(options.test ? "Finished the example smoke test." : "Finished the example sequence.");
}

try {
  await main();
} catch (error) {
  console.error(error instanceof Error ? error.message : error);
  Deno.exit(1);
}
