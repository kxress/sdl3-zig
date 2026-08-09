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
 */

import { dirname, fromFileUrl } from "@std/path";

const scriptDirectory = dirname(fromFileUrl(import.meta.url));
const repository = dirname(scriptDirectory);

interface Options {
  filter: string;
  startAt?: string;
}

function parseOptions(args: string[]): Options {
  let filter = "*";
  let startAt: string | undefined;

  for (let index = 0; index < args.length; index += 1) {
    const argument = args[index];
    if (argument === "--") {
      continue;
    } else if (argument === "--filter") {
      filter = args[++index] ?? "";
    } else if (argument === "--start-at") {
      startAt = args[++index];
    } else if (argument === "--help" || argument === "-h") {
      console.log("Usage: deno run --allow-read --allow-run=zig scripts/run-examples.ts [options]");
      console.log("  --filter <glob>       Only run matching example names (default: *)");
      console.log("  --start-at <name>     Begin at this example in catalog order");
      Deno.exit(0);
    } else {
      throw new Error(`Unknown argument '${argument}'. Use --help for usage.`);
    }
  }
  return { filter, startAt };
}

function globRegExp(glob: string): RegExp {
  const escaped = glob.replace(/[.+^${}()|[\]\\]/g, "\\$&");
  return new RegExp(`^${escaped.replaceAll("*", ".*").replaceAll("?", ".")}$`);
}

async function runCommand(args: string[], output: "piped" | "inherit") {
  const command = new Deno.Command("zig", {
    args,
    cwd: repository,
    stdout: output,
    stderr: output,
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

  console.log(`Running ${names.length} examples in catalog order.`);
  console.log("Close each example window to continue; press Ctrl+C to stop.\n");

  for (const [index, name] of names.entries()) {
    console.log(`[${index + 1}/${names.length}] ${name}`);
    const result = await runCommand(["build", `run-${name}`], "inherit");
    if (!result.success) {
      console.error(`  startup/build exited with code ${result.code}`);
      prompt("  Press Enter to continue, or Ctrl+C to stop");
    }
    console.log();
  }
  console.log("Finished the example sequence.");
}

try {
  await main();
} catch (error) {
  console.error(error instanceof Error ? error.message : error);
  Deno.exit(1);
}
