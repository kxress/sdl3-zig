const zigKeywords = new Set([
  "addrspace",
  "align",
  "allowzero",
  "and",
  "anyframe",
  "anytype",
  "asm",
  "async",
  "await",
  "break",
  "callconv",
  "catch",
  "comptime",
  "const",
  "continue",
  "defer",
  "else",
  "enum",
  "errdefer",
  "error",
  "export",
  "extern",
  "fn",
  "f16",
  "f32",
  "f64",
  "f80",
  "f128",
  "for",
  "if",
  "inline",
  "i8",
  "i16",
  "i32",
  "i64",
  "i128",
  "noalias",
  "noinline",
  "null",
  "nosuspend",
  "opaque",
  "or",
  "orelse",
  "packed",
  "promise",
  "pub",
  "resume",
  "return",
  "struct",
  "suspend",
  "switch",
  "test",
  "true",
  "threadlocal",
  "type",
  "try",
  "union",
  "unreachable",
  "undefined",
  "u8",
  "u16",
  "u32",
  "u64",
  "u128",
  "usize",
  "isize",
  "void",
  "usingnamespace",
  "var",
  "volatile",
  "while",
  "xor",
]);

const seedWords = [
  "add",
  "api",
  "ascii",
  "audio",
  "avx",
  "bmp",
  "cancel",
  "color",
  "context",
  "cpu",
  "crc",
  "create",
  "data",
  "device",
  "display",
  "dnd",
  "dpi",
  "driver",
  "dxbc",
  "dxil",
  "egl",
  "event",
  "file",
  "format",
  "free",
  "gdk",
  "get",
  "gl",
  "gpu",
  "guid",
  "hdr",
  "hid",
  "icc",
  "id",
  "ime",
  "index",
  "io",
  "jpeg",
  "json",
  "led",
  "load",
  "max",
  "metal",
  "min",
  "mmx",
  "mode",
  "ms",
  "msl",
  "ns",
  "op",
  "peek",
  "pixel",
  "png",
  "pos",
  "profile",
  "quit",
  "read",
  "renderer",
  "rgb",
  "rgba",
  "rle",
  "rw",
  "shader",
  "simd",
  "size",
  "spirv",
  "sse",
  "state",
  "stream",
  "surface",
  "texture",
  "thread",
  "tls",
  "type",
  "ucs",
  "url",
  "usb",
  "utf",
  "value",
  "video",
  "vulkan",
  "wav",
  "window",
  "write",
  "x11",
  "ycbcr",
  "yuv",
];

export class ZigNaming {
  readonly #lexicon = new Set(seedWords);
  readonly #apiPrefixWords: string[][];

  constructor(sourceNames: Iterable<string>, apiPrefixes: string[] = ["SDL_"]) {
    this.#apiPrefixWords = apiPrefixes.map((prefix) => this.words(prefix));
    for (const sourceName of sourceNames) {
      for (const segment of sourceName.split("_")) {
        if (!/[a-z]/.test(segment)) continue;
        for (const word of splitMixedCase(segment)) {
          if (word.length > 2) this.#lexicon.add(word.toLowerCase());
        }
      }
    }
  }

  typeName(cName: string): string {
    return this.#identifier(pascalCase(this.#withoutApiPrefix(cName)));
  }

  functionName(cName: string): string {
    return this.#identifier(camelCase(this.#withoutApiPrefix(cName)));
  }

  valueName(cName: string): string {
    return this.#identifier(this.#withoutApiPrefix(cName).join("_"));
  }

  fieldName(cName: string): string {
    return this.#identifier(this.words(cName).join("_"));
  }

  parameterName(cName: string): string {
    return this.fieldName(cName);
  }

  enumTagNames(enumName: string, valueNames: string[]): Map<string, string> {
    const words = valueNames.map((name) => this.words(name));
    const common = words.length > 1 ? commonPrefix(words) : [];
    const enumWords = this.#withoutApiPrefix(enumName);
    const result = new Map<string, string>();
    const used = new Set<string>();

    for (let index = 0; index < valueNames.length; index++) {
      let valueWords = words[index];
      if (common.length > 0 && common.length < valueWords.length) {
        valueWords = valueWords.slice(common.length);
      } else {
        valueWords = dropPrefix(valueWords, ["sdl"]);
        const shared = sharedPrefixLength(valueWords, enumWords);
        if (shared > 0 && shared < valueWords.length) valueWords = valueWords.slice(shared);
      }
      if (valueWords.length === 0) valueWords = ["value", String(index)];
      result.set(
        valueNames[index],
        uniqueIdentifier(this.#identifier(valueWords.join("_")), used),
      );
    }
    return result;
  }

  words(value: string): string[] {
    const words: string[] = [];
    for (const segment of value.split(/_+/).filter(Boolean)) {
      if (/^[A-Z0-9]+$/.test(segment)) {
        words.push(...this.#splitUppercase(segment));
      } else {
        words.push(...splitMixedCase(segment).map((word) => word.toLowerCase()));
      }
    }
    return combineNumericWords(words);
  }

  #withoutApiPrefix(value: string): string[] {
    const words = this.words(value);
    for (const prefix of this.#apiPrefixWords) {
      const stripped = dropPrefix(words, prefix);
      if (stripped.length !== words.length) return stripped;
    }
    return words;
  }

  #splitUppercase(value: string): string[] {
    const parts = value.match(/[A-Z]+|[0-9]+/g) ?? [value];
    return combineNumericWords(parts.flatMap((part) => {
      if (/^[0-9]+$/.test(part)) return [part];
      return segmentWord(part.toLowerCase(), this.#lexicon);
    }));
  }

  #identifier(value: string): string {
    let identifier = value.replace(/[^A-Za-z0-9_]/g, "_");
    if (!/^[A-Za-z_]/.test(identifier)) identifier = `_${identifier}`;
    if (zigKeywords.has(identifier)) identifier = `${identifier}_`;
    return identifier;
  }
}

export function uniqueIdentifier(value: string, used: Set<string>): string {
  let candidate = value;
  const base = candidate;
  let suffix = 2;
  while (used.has(candidate)) candidate = `${base}_${suffix++}`;
  used.add(candidate);
  return candidate;
}

function splitMixedCase(value: string): string[] {
  return value.match(/[A-Z]+(?=[A-Z][a-z]|[0-9]|$)|[A-Z]?[a-z]+|[0-9]+/g) ?? [value];
}

function segmentWord(value: string, lexicon: Set<string>): string[] {
  if (lexicon.has(value)) return [value];

  const best: Array<string[] | undefined> = Array(value.length + 1).fill(undefined);
  best[0] = [];
  for (let end = 1; end <= value.length; end++) {
    for (let start = 0; start < end; start++) {
      const prefix = best[start];
      const word = value.slice(start, end);
      if (!prefix || !lexicon.has(word)) continue;
      const candidate = [...prefix, word];
      const current = best[end];
      if (
        !current ||
        candidate.length < current.length ||
        (candidate.length === current.length && candidate.join("_") < current.join("_"))
      ) {
        best[end] = candidate;
      }
    }
  }
  return best[value.length] ?? [value];
}

function pascalCase(words: string[]): string {
  return words.map(capitalize).join("");
}

function camelCase(words: string[]): string {
  if (words.length === 0) return "";
  return words[0] + words.slice(1).map(capitalize).join("");
}

function capitalize(value: string): string {
  return value.length === 0 ? value : value[0].toUpperCase() + value.slice(1);
}

function commonPrefix(values: string[][]): string[] {
  if (values.length === 0) return [];
  const first = values[0];
  let length = first.length;
  for (const value of values.slice(1)) {
    length = Math.min(length, sharedPrefixLength(first, value));
  }
  return first.slice(0, length);
}

function sharedPrefixLength(left: string[], right: string[]): number {
  let index = 0;
  while (index < left.length && index < right.length && left[index] === right[index]) index++;
  return index;
}

function dropPrefix(value: string[], prefix: string[]): string[] {
  return sharedPrefixLength(value, prefix) === prefix.length ? value.slice(prefix.length) : value;
}

function combineNumericWords(words: string[]): string[] {
  const result: string[] = [];
  for (const word of words) {
    if (/^[0-9]+$/.test(word) && result.length > 0) result[result.length - 1] += word;
    else if (word.length === 1 && /[0-9]$/.test(result.at(-1) ?? "")) {
      result[result.length - 1] += word;
    } else result.push(word);
  }
  return result;
}
