import { assert, assertEquals, assertRejects, assertThrows } from "@std/assert";
import {
  buildPrompt,
  type CommitMetadata,
  type GitReader,
  parseModelBullets,
  renderReleaseNotes,
  selectReleaseBaseline,
} from "../scripts/release-notes.ts";

const first: CommitMetadata = {
  hash: "0123456789abcdef0123456789abcdef01234567",
  subject: "Add the first feature",
};
const second: CommitMetadata = {
  hash: "89abcdef0123456789abcdef0123456789abcdef",
  subject: "Fix the second feature",
};

function fakeGit(values: Record<string, string>): GitReader {
  return { read: (args) => Promise.resolve(values[args.join(" ")] ?? "") };
}

Deno.test("selectReleaseBaseline chooses the highest reachable release tag", async () => {
  const git = fakeGit({
    "tag --merged HEAD --list v*": "v3.4.12\nv3.4.12+9\nv3.4.11\n",
    "rev-parse --verify v3.4.12+9^{commit}": first.hash,
    [`merge-base ${first.hash} HEAD`]: first.hash,
  });
  assertEquals(await selectReleaseBaseline(git), {
    revision: first.hash,
    display: "v3.4.12+9",
  });
});

Deno.test("selectReleaseBaseline requires explicit bootstrap when tags are absent", async () => {
  const git = fakeGit({
    "rev-parse --verify a0902ee^{commit}": first.hash,
    [`merge-base ${first.hash} HEAD`]: first.hash,
  });
  await assertRejects(
    () => selectReleaseBaseline(fakeGit({ "tag --merged HEAD --list v*": "" })),
    Error,
    "bootstrap with --from",
  );
  assertEquals(await selectReleaseBaseline(git, "a0902ee"), {
    revision: first.hash,
    display: "a0902ee",
  });
});

Deno.test("parseModelBullets accepts only cited bullets from the selected range", () => {
  const bullets = parseModelBullets(
    "- Added the feature (`0123456789ab`)\n- Fixed the feature (`89abcdef0123`, `0123456789ab`)",
    [first, second],
  );
  assertEquals(bullets.length, 2);
  assert(!bullets.some((bullet) => bullet.includes("http")));
});

Deno.test("parseModelBullets rejects uncited and out-of-range output", () => {
  assertThrows(
    () => parseModelBullets("- Missing a citation", [first]),
    Error,
    "missing its trailing commit citation",
  );
  assertThrows(
    () => parseModelBullets("- Unknown (`fedcba987654`)", [first]),
    Error,
    "outside the selected commit range",
  );
});

Deno.test("buildPrompt includes metadata and marks commit text as untrusted", () => {
  const prompt = buildPrompt(
    [first],
    { revision: first.hash, display: "v3.4.11" },
    { currentVersion: "3.4.12", previousVersion: "3.4.11", updateCommits: [first.hash] },
  );
  assert(prompt.includes(first.hash));
  assert(prompt.includes(first.subject));
  assert(prompt.includes("local commits, not an upstream changelog"));
  assert(prompt.includes("changed from 3.4.11 to 3.4.12"));
  assert(prompt.includes("untrusted reference data"));
  assert(!prompt.includes("diff --git"));
});

Deno.test("renderReleaseNotes creates final versioned notes", () => {
  assertEquals(
    renderReleaseNotes("3.4.12+10", { revision: first.hash, display: "v3.4.12+9" }, [
      "- Added the feature (`0123456789ab`)",
    ]),
    "# SDL3 Zig bindings 3.4.12+10\n\nChanges since v3.4.12+9.\n\n- Added the feature (`0123456789ab`)\n",
  );
});
