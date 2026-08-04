import { assertRejects } from "@std/assert";
import { verifyDetachedSignature } from "../scripts/source-signature.ts";

interface Key {
  home: string;
  fingerprint: string;
}

Deno.test("source signature verification rejects bad, missing, expired, and untrusted signatures", async () => {
  const temporary = await Deno.makeTempDir({ prefix: "sdl-source-signatures-" });
  try {
    const archive = `${temporary}/source.tar.gz`;
    await Deno.writeTextFile(archive, "SDL source signature fixture\n");
    const trusted = await generateKey(temporary, "Trusted SDL release key", undefined);
    const untrusted = await generateKey(temporary, "Untrusted release key", undefined);
    const expired = await generateKey(temporary, "Expired release key", 946684800);
    const keyring = `${temporary}/trusted.gpg`;
    await gpg(trusted.home, ["--output", keyring, "--export", trusted.fingerprint]);

    const validSignature = `${temporary}/valid.sig`;
    await sign(trusted, archive, validSignature);
    await verifyDetachedSignature(keyring, validSignature, archive);

    const badSignature = `${temporary}/bad.sig`;
    await Deno.copyFile(validSignature, badSignature);
    const badBytes = await Deno.readFile(badSignature);
    badBytes[badBytes.length - 1] ^= 1;
    await Deno.writeFile(badSignature, badBytes);
    await assertRejects(
      () => verifyDetachedSignature(keyring, badSignature, archive),
      Error,
    );
    await assertRejects(
      () => verifyDetachedSignature(keyring, `${temporary}/missing.sig`, archive),
      Error,
    );

    const untrustedSignature = `${temporary}/untrusted.sig`;
    await sign(untrusted, archive, untrustedSignature);
    await assertRejects(
      () => verifyDetachedSignature(keyring, untrustedSignature, archive),
      Error,
    );

    const expiredKeyring = `${temporary}/expired.gpg`;
    await gpg(expired.home, ["--output", expiredKeyring, "--export", expired.fingerprint]);
    const expiredSignature = `${temporary}/expired.sig`;
    await sign(expired, archive, expiredSignature, 946684800);
    await assertRejects(
      () => verifyDetachedSignature(expiredKeyring, expiredSignature, archive),
      Error,
    );
  } finally {
    await Deno.remove(temporary, { recursive: true });
  }
});

async function generateKey(base: string, name: string, fakeTime: number | undefined): Promise<Key> {
  const home = `${base}/${name.replaceAll(" ", "-")}`;
  await Deno.mkdir(home, { recursive: true, mode: 0o700 });
  await gpg(home, [
    ...(fakeTime === undefined ? [] : ["--faked-system-time", String(fakeTime)]),
    "--quick-generate-key",
    `${name} <${name.toLowerCase().replaceAll(" ", "-")}@example.invalid>`,
    "rsa2048",
    "sign",
    "1d",
  ]);
  const listing = await gpg(home, ["--with-colons", "--list-secret-keys"]);
  const fingerprint = listing.stdout.split("\n")
    .map((line) => line.split(":"))
    .find((fields) => fields[0] === "fpr")?.[9];
  if (!fingerprint) throw new Error(`could not determine fingerprint for ${name}`);
  return { home, fingerprint };
}

async function sign(
  key: Key,
  archive: string,
  signature: string,
  fakeTime?: number,
): Promise<void> {
  await gpg(key.home, [
    ...(fakeTime === undefined ? [] : ["--faked-system-time", String(fakeTime)]),
    "--local-user",
    key.fingerprint,
    "--detach-sign",
    "--output",
    signature,
    archive,
  ]);
}

async function gpg(home: string, args: string[]): Promise<{ stdout: string }> {
  const result = await new Deno.Command("gpg", {
    args: [
      "--batch",
      "--no-options",
      "--pinentry-mode",
      "loopback",
      "--passphrase",
      "",
      "--homedir",
      home,
      ...args,
    ],
    stdout: "piped",
    stderr: "piped",
  }).output();
  if (!result.success) {
    throw new Error(new TextDecoder().decode(result.stderr));
  }
  return { stdout: new TextDecoder().decode(result.stdout) };
}
