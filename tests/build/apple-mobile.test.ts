import { copy } from "@std/fs/copy";
import { relative } from "@std/path";
import { assert } from "@std/assert";
import { artifactName, installArtifacts, loadSdlRelease } from "../../scripts/sdl-release.ts";
import { command, run, withTempDirectory } from "./support.ts";

const fixture = `${import.meta.dirname}/fixtures/apple_mobile`;
const components = ["sdl", "image", "ttf", "mixer", "net"] as const;

const slices = [
  {
    name: "ios-device",
    zigTarget: "aarch64-ios",
    xcframework: "ios-arm64",
    clangTarget: "arm64-apple-ios11.0",
    sdk: "iphoneos",
  },
  {
    name: "ios-arm64-simulator",
    zigTarget: "aarch64-ios-simulator",
    xcframework: "ios-arm64_x86_64-simulator",
    clangTarget: "arm64-apple-ios11.0-simulator",
    sdk: "iphonesimulator",
  },
  {
    name: "ios-x86_64-simulator",
    zigTarget: "x86_64-ios-simulator",
    xcframework: "ios-arm64_x86_64-simulator",
    clangTarget: "x86_64-apple-ios11.0-simulator",
    sdk: "iphonesimulator",
  },
  {
    name: "tvos-device",
    zigTarget: "aarch64-tvos",
    xcframework: "tvos-arm64",
    clangTarget: "arm64-apple-tvos11.0",
    sdk: "appletvos",
  },
  {
    name: "tvos-arm64-simulator",
    zigTarget: "aarch64-tvos-simulator",
    xcframework: "tvos-arm64_x86_64-simulator",
    clangTarget: "arm64-apple-tvos11.0-simulator",
    sdk: "appletvsimulator",
  },
  {
    name: "tvos-x86_64-simulator",
    zigTarget: "x86_64-tvos-simulator",
    xcframework: "tvos-arm64_x86_64-simulator",
    clangTarget: "x86_64-apple-tvos11.0-simulator",
    sdk: "appletvsimulator",
  },
] as const;

Deno.test({
  name: "Apple mobile bindings and pinned XCFramework slices compile and link",
  ignore: Deno.build.os !== "darwin",
  async fn() {
    await withTempDirectory("sdl-apple-mobile-", async (temporary) => {
      const release = await loadSdlRelease();
      const releaseComponents = release.components.filter((component) =>
        components.includes(component.key as (typeof components)[number])
      );
      const installations = await installArtifacts(
        releaseComponents.map((component) => artifactName(component, "macos")),
      );
      const extracted = new Map<string, string>();

      for (const component of releaseComponents) {
        const installation = installations.get(artifactName(component, "macos"));
        assert(installation !== undefined, `missing pinned macOS artifact for ${component.id}`);
        const destination = `${temporary}/upstream/${component.key}`;
        await Deno.mkdir(destination, { recursive: true });
        await run("7zz", [
          "x",
          "-y",
          `-o${destination}`,
          `${installation}/${component.id}-${component.version}.dmg`,
        ]);
        extracted.set(component.key, `${destination}/${component.id}`);
      }

      const consumer = `${temporary}/binding-consumer`;
      await copy(fixture, consumer);
      await Deno.writeTextFile(
        `${consumer}/build.zig.zon`,
        `.{
    .name = .sdl3_apple_mobile_consumer,
    .version = "0.0.0",
    .fingerprint = 0xf1d8b5bd89c7c2c0,
    .minimum_zig_version = "0.16.0",
    .dependencies = .{
        .sdl3 = .{ .path = "${relative(consumer, Deno.cwd()).replaceAll("\\", "/")}" },
    },
    .paths = .{ "build.zig", "build.zig.zon", "main.zig", "main.c" },
}
`,
      );

      for (const slice of slices) {
        const sdkPath = await showSdkPath(slice.sdk);
        const sliceDirectory = `${temporary}/slices/${slice.name}`;
        await Deno.mkdir(sliceDirectory, { recursive: true });
        await compileBinding(consumer, slice.zigTarget, sliceDirectory);

        const frameworkPaths = components.map((key) => {
          const component = releaseComponents.find((candidate) => candidate.key === key)!;
          return `${extracted.get(key)}/${component.id}.xcframework/${slice.xcframework}`;
        });
        await linkCConsumer(slice, sdkPath, frameworkPaths, sliceDirectory);

        if (slice.name === "ios-arm64-simulator") {
          await simulatorLifecycleSmoke(frameworkPaths, sliceDirectory);
        }
      }
    });
  },
});

async function showSdkPath(sdk: string): Promise<string> {
  const result = await command("xcrun", ["--sdk", sdk, "--show-sdk-path"]);
  if (!result.success) {
    throw new Error(
      `Apple SDK '${sdk}' is unavailable; install Xcode with the iOS/tvOS SDKs before running ` +
        `the Apple mobile fixture.\n${new TextDecoder().decode(result.stderr)}`,
    );
  }
  return new TextDecoder().decode(result.stdout).trim();
}

async function compileBinding(consumer: string, target: string, output: string): Promise<void> {
  await run("zig", [
    "build",
    `-Dtarget=${target}`,
    "-Doptimize=Debug",
    "--cache-dir",
    `${output}/zig-cache`,
    "--global-cache-dir",
    `${output}/zig-global-cache`,
  ], { cwd: consumer, stdout: "inherit", stderr: "inherit" });
}

async function linkCConsumer(
  slice: (typeof slices)[number],
  sdkPath: string,
  frameworkPaths: string[],
  output: string,
): Promise<void> {
  const args = [
    "clang",
    "-target",
    slice.clangTarget,
    "-isysroot",
    sdkPath,
    `${fixture}/main.c`,
    "-o",
    `${output}/apple-mobile-consumer`,
    "-Wl,-rpath,@executable_path/Frameworks",
    "-Wl,-rpath,@loader_path/Frameworks",
  ];
  for (const path of frameworkPaths) args.push("-F", path);
  for (const framework of ["SDL3", "SDL3_image", "SDL3_ttf", "SDL3_mixer", "SDL3_net"]) {
    args.push("-framework", framework);
  }
  await run("xcrun", args, { stdout: "inherit", stderr: "inherit" });
  const loadCommands = await command("xcrun", ["otool", "-l", `${output}/apple-mobile-consumer`]);
  assert(loadCommands.success, "otool could not inspect the linked Apple mobile consumer");
  const loadCommandText = new TextDecoder().decode(loadCommands.stdout);
  assert(loadCommandText.includes("@executable_path/Frameworks"), "executable rpath is missing");
  assert(loadCommandText.includes("@loader_path/Frameworks"), "loader rpath is missing");
}

async function simulatorLifecycleSmoke(
  frameworkPaths: string[],
  output: string,
): Promise<void> {
  const devices = await command("xcrun", ["simctl", "list", "devices", "available", "-j"]);
  if (!devices.success) throw new Error("Unable to enumerate available iOS simulators");
  const listing = JSON.parse(new TextDecoder().decode(devices.stdout)) as {
    devices: Record<string, Array<{ name: string; udid: string; isAvailable: boolean }>>;
  };
  const device = Object.values(listing.devices).flat().find((candidate) =>
    candidate.isAvailable && candidate.name.startsWith("iPhone")
  );
  if (!device) {
    throw new Error("No available iPhone simulator exists for the Apple lifecycle smoke test");
  }

  const booted = await command("xcrun", ["simctl", "list", "devices", "booted"]);
  const wasBooted = new TextDecoder().decode(booted.stdout).includes(device.udid);
  if (!wasBooted) await run("xcrun", ["simctl", "boot", device.udid]);
  try {
    await run("xcrun", ["simctl", "bootstatus", device.udid, "-b"]);
    const app = `${output}/AppleMobileConsumer.app`;
    await Deno.mkdir(`${app}/Frameworks`, { recursive: true });
    await copy(`${output}/apple-mobile-consumer`, `${app}/apple-mobile-consumer`);
    for (const frameworkPath of frameworkPaths) {
      const framework = frameworkPath.slice(frameworkPath.lastIndexOf("/") + 1);
      await copy(
        `${frameworkPath}/${framework}.framework`,
        `${app}/Frameworks/${framework}.framework`,
      );
    }
    await Deno.writeTextFile(
      `${app}/Info.plist`,
      `<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>CFBundleExecutable</key><string>apple-mobile-consumer</string>
<key>CFBundleIdentifier</key><string>org.libsdl.apple-mobile-consumer</string>
<key>CFBundleName</key><string>AppleMobileConsumer</string>
<key>CFBundlePackageType</key><string>APPL</string>
<key>MinimumOSVersion</key><string>11.0</string>
</dict></plist>
`,
    );
    await run("codesign", ["--force", "--deep", "--sign", "-", app]);
    await run("codesign", ["--verify", "--deep", "--strict", app]);
    await run("xcrun", ["simctl", "install", device.udid, app]);
    await run("xcrun", ["simctl", "launch", device.udid, "org.libsdl.apple-mobile-consumer"]);
    await run("xcrun", ["simctl", "terminate", device.udid, "org.libsdl.apple-mobile-consumer"]);
  } finally {
    if (!wasBooted) await run("xcrun", ["simctl", "shutdown", device.udid]);
  }
}
