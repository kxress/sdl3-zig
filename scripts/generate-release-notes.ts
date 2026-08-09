import { runCommand } from "./utils/command.ts";
import { repositoryRoot } from "./utils/paths.ts";
import {
  buildPrompt,
  collectCommits,
  collectSdlBaselineChange,
  type GitReader,
  loadPackageVersion,
  parseModelBullets,
  renderReleaseNotes,
  selectReleaseBaseline,
} from "./release-notes.ts";

const git: GitReader = {
  read: async (args) => (await runCommand("git", args, { cwd: repositoryRoot })).stdout,
};

if (import.meta.main) {
  const explicitRevision = parseArgs(Deno.args);
  const baseline = await selectReleaseBaseline(git, explicitRevision);
  const commits = await collectCommits(git, baseline);
  const sdlChange = await collectSdlBaselineChange(git, baseline);
  const output = await runCodex(buildPrompt(commits, baseline, sdlChange));
  const bullets = parseModelBullets(output, commits);
  const notes = renderReleaseNotes(await loadPackageVersion(), baseline, bullets);
  await Deno.writeTextFile(`${repositoryRoot}/RELEASE_NOTES.md`, notes);
  console.log(
    `Generated RELEASE_NOTES.md from ${commits.length} commits since ${baseline.display}.`,
  );
}

function parseArgs(args: string[]): string | undefined {
  if (args.length === 0) return undefined;
  if (args.length === 2 && args[0] === "--from" && args[1]) return args[1];
  throw new Error("usage: generate-release-notes.ts [--from <previous-release-commit>]");
}

async function runCodex(prompt: string): Promise<string> {
  let child: Deno.ChildProcess;
  try {
    child = new Deno.Command("codex", {
      args: [
        "exec",
        "--ephemeral",
        "--sandbox",
        "read-only",
        "--model",
        "gpt-5.6-luna",
        "--config",
        'model_reasoning_effort="low"',
        "--color",
        "never",
        "-",
      ],
      cwd: repositoryRoot,
      stdin: "piped",
      stdout: "piped",
      stderr: "piped",
    }).spawn();
  } catch (error) {
    throw new Error(`Unable to start Codex: ${error instanceof Error ? error.message : error}`);
  }

  const writer = child.stdin.getWriter();
  await writer.write(new TextEncoder().encode(prompt));
  await writer.close();
  const result = await child.output();
  const stdout = new TextDecoder().decode(result.stdout).trim();
  const stderr = new TextDecoder().decode(result.stderr).trim();
  if (!result.success) {
    throw new Error(`Codex exited with code ${result.code}${stderr ? `:\n${stderr}` : ""}`);
  }
  if (!stdout) throw new Error("Codex returned empty release notes");
  return stdout;
}
