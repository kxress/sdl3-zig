export async function verifyDetachedSignature(
  keyring: string,
  signature: string,
  archive: string,
): Promise<void> {
  const result = await new Deno.Command("gpgv", {
    args: ["--status-fd=1", "--keyring", keyring, signature, archive],
    stdout: "piped",
    stderr: "piped",
  }).output();
  const status = new TextDecoder().decode(result.stdout);
  if (!result.success || /\[GNUPG:\]\s+(?:EXPKEYSIG|REVKEYSIG|BADSIG)\b/.test(status)) {
    throw new Error(
      new TextDecoder().decode(result.stderr) || "detached signature verification failed",
    );
  }
}
