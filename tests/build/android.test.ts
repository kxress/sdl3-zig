import { copy } from "@std/fs/copy";
import { assertStringIncludes } from "@std/assert";
import { command, run } from "./support.ts";

const repository = `${import.meta.dirname}/../..`;
const fixture = `${import.meta.dirname}/fixtures/android`;
const androidProject = `${repository}/vendor/SDL3/android-project`;
const defaultSdk = `${repository}/.zig-cache/android-sdk`;
const sdk = Deno.env.get("ANDROID_SDK_ROOT") ?? Deno.env.get("ANDROID_HOME") ?? defaultSdk;
const ndk = Deno.env.get("ANDROID_NDK_ROOT") ?? `${sdk}/ndk/28.2.13676358`;
const javaHome = Deno.env.get("JAVA_HOME") ?? `${defaultSdk}/jdk`;
const adb = `${sdk}/platform-tools/adb`;
const aapt = `${sdk}/build-tools/35.0.1/aapt`;

Deno.test("Android builds a Zig SDL consumer and packages an APK", async () => {
  const required = [
    `${javaHome}/bin/java`,
    `${ndk}/build/cmake/android.toolchain.cmake`,
    `${sdk}/platforms/android-35/android.jar`,
    adb,
    aapt,
  ];
  const missing: string[] = [];
  for (const path of required) {
    try {
      await Deno.stat(path);
    } catch {
      missing.push(path);
    }
  }
  if (missing.length > 0) {
    throw new Error(
      `Android fixture prerequisites are missing. Install Android SDK platform 35, ` +
        `NDK 28.2.13676358, and JDK 17, or set ANDROID_SDK_ROOT, ANDROID_NDK_ROOT, ` +
        `and JAVA_HOME. Missing:\n${missing.join("\n")}`,
    );
  }

  const work = await Deno.makeTempDir({ dir: `${repository}/.zig-cache`, prefix: "android-test-" });
  try {
    const cache = `${work}/zig-cache`;
    const project = `${work}/android-project`;
    const tmp = `${work}/tmp`;
    await Deno.mkdir(tmp, { recursive: true });
    await copy(androidProject, project);
    await Deno.mkdir(`${project}/app/libs/arm64-v8a`, { recursive: true });
    await Deno.mkdir(`${project}/app/src/main/java/com/example/sdl3`, { recursive: true });
    await copy(
      `${fixture}/MainActivity.java`,
      `${project}/app/src/main/java/com/example/sdl3/MainActivity.java`,
    );
    await Deno.writeTextFile(
      `${project}/app/jni/CMakeLists.txt`,
      "cmake_minimum_required(VERSION 3.22.1)\nproject(android_packaging_stub C)\nadd_library(android_packaging_stub SHARED empty.c)\n",
    );
    await Deno.writeTextFile(
      `${project}/app/jni/empty.c`,
      "void android_packaging_stub(void) {}\n",
    );

    const manifest = `${project}/app/src/main/AndroidManifest.xml`;
    const manifestText = await Deno.readTextFile(manifest);
    await Deno.writeTextFile(
      manifest,
      manifestText.replace(
        'android:name="SDLActivity"',
        'android:name="com.example.sdl3.MainActivity"',
      ),
    );
    await Deno.writeTextFile(`${project}/local.properties`, `sdk.dir=${sdk}\n`);

    const env = {
      ...Deno.env.toObject(),
      ANDROID_HOME: sdk,
      ANDROID_SDK_ROOT: sdk,
      JAVA_HOME: javaHome,
      TMPDIR: tmp,
      GRADLE_USER_HOME: `${work}/gradle-home`,
    };
    for (
      const [target, abi] of [
        ["aarch64-linux-android", "arm64-v8a"],
        ["x86_64-linux-android", "x86_64"],
      ] as const
    ) {
      const targetOutput = `${work}/zig-output-${abi}`;
      await run("zig", [
        "build",
        `-Dtarget=${target}`,
        "-Doptimize=ReleaseSmall",
        `-Dandroid_ndk=${ndk}`,
        `-Dsource_cmake_toolchain=${ndk}/build/cmake/android.toolchain.cmake`,
        "-p",
        targetOutput,
        "--cache-dir",
        `${cache}/${abi}/local`,
        "--global-cache-dir",
        `${cache}/${abi}/global`,
      ], { cwd: fixture, env, stdout: "inherit", stderr: "inherit" });
      await Deno.stat(`${targetOutput}/lib/libmain.so`);
      if (abi === "arm64-v8a") {
        await copy(`${targetOutput}/lib/libmain.so`, `${project}/app/libs/${abi}/libmain.so`);
      }
    }

    await run("bash", ["gradlew", "--no-daemon", "assembleDebug", "-PBUILD_WITH_CMAKE"], {
      cwd: project,
      env,
      stdout: "inherit",
      stderr: "inherit",
    });
    const apk = `${project}/app/build/outputs/apk/debug/app-debug.apk`;
    const listing = await toolCommand(aapt, ["list", apk], { env });
    if (!listing.success) throw new Error(new TextDecoder().decode(listing.stderr));
    const files = new TextDecoder().decode(listing.stdout);
    assertStringIncludes(files, "lib/arm64-v8a/libmain.so");

    const devices = await toolCommand(adb, ["devices"], { env });
    const connected = new TextDecoder().decode(devices.stdout)
      .split("\n")
      .some((line) => line.endsWith("\tdevice"));
    if (connected) {
      await runTool(adb, ["install", "-r", apk], { env, stdout: "inherit", stderr: "inherit" });
      await runTool(adb, [
        "shell",
        "am",
        "start",
        "-n",
        "org.libsdl.app/com.example.sdl3.MainActivity",
      ], {
        env,
        stdout: "inherit",
        stderr: "inherit",
      });
    } else {
      console.info("Android APK execution skipped: adb reports no connected device or emulator.");
    }
  } finally {
    await Deno.remove(work, { recursive: true });
  }
});

async function toolCommand(
  executable: string,
  args: string[],
  options: Parameters<typeof command>[2] = {},
): Promise<Deno.CommandOutput> {
  return await command(
    "bash",
    ["-c", 'tool="$1"; shift; exec "$tool" "$@"', "android-tool", executable, ...args],
    options,
  );
}

async function runTool(
  executable: string,
  args: string[],
  options: Parameters<typeof run>[2] = {},
): Promise<void> {
  await run(
    "bash",
    ["-c", 'tool="$1"; shift; exec "$tool" "$@"', "android-tool", executable, ...args],
    options,
  );
}
