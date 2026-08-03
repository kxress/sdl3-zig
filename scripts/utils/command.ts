export interface CommandOptions {
  cwd?: string;
  stdout?: "piped" | "inherit";
  stderr?: "piped" | "inherit";
}

export async function runCommand(
  command: string,
  args: string[],
  options: CommandOptions = {},
): Promise<{ stdout: string; stderr: string }> {
  let output: Deno.CommandOutput;
  try {
    output = await new Deno.Command(command, {
      args,
      cwd: options.cwd,
      stdout: options.stdout ?? "piped",
      stderr: options.stderr ?? "piped",
    }).output();
  } catch (error) {
    throw new Error(`Unable to run ${command}: ${error instanceof Error ? error.message : error}`);
  }
  const stdout = options.stdout === "inherit" ? "" : new TextDecoder().decode(output.stdout);
  const stderr = options.stderr === "inherit" ? "" : new TextDecoder().decode(output.stderr);
  if (!output.success) {
    throw new Error(
      `${command} exited with code ${output.code}${stderr.trim() ? `:\n${stderr.trim()}` : ""}`,
    );
  }
  return { stdout, stderr };
}
