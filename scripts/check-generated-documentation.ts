export function validateGeneratedDocumentation(
  sources: ReadonlyMap<string, string> | Iterable<readonly [string, string]>,
): void {
  const violations: string[] = [];
  for (const [path, source] of sources) {
    for (const [lineNumber, line] of source.split("\n").entries()) {
      if (!line.trimStart().startsWith("///")) continue;
      if (/\*\/\s+(?:extern|typedef|static|SDL_DECLSPEC)\b/.test(line)) {
        violations.push(`${path}:${lineNumber + 1}: embedded C declaration fragment`);
      }
      if (/\[(Category[A-Za-z0-9_]+)\]\(\1\)/.test(line)) {
        violations.push(`${path}:${lineNumber + 1}: unresolved local category link`);
      }
      if (/\(C macro\)(?! outside this module)/.test(line)) {
        violations.push(`${path}:${lineNumber + 1}: unresolved C macro reference`);
      }
      if (/__CODEGEN_DOC_REF_[A-Za-z0-9_]+__/.test(line)) {
        violations.push(`${path}:${lineNumber + 1}: unresolved generator reference marker`);
      }
    }
  }
  if (violations.length > 0) {
    throw new Error(`Generated documentation validation failed:\n${violations.join("\n")}`);
  }
}
