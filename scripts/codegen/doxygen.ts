import { XMLParser } from "fast-xml-parser";
import { runCommand } from "../utils/command.ts";
import { attribute, numberAttribute, object, type XmlObject } from "./xml.ts";

export interface Documentation {
  name: string;
  kind: string;
  header: string;
  line?: number;
  signature: string;
  comment: string;
  parameters: string[];
}

export interface HeaderDocumentation {
  header: string;
  category: string;
  comment: string;
}

interface DoxygenOptions {
  inputDirectory: string;
  outputDirectory: string;
  apiPrefixes: string[];
  projectName: string;
  predefined: string[];
}

const orderedParser = new XMLParser({
  attributeNamePrefix: "@_",
  ignoreAttributes: false,
  parseAttributeValue: false,
  parseTagValue: false,
  trimValues: false,
  processEntities: false,
  preserveOrder: true,
});

export async function collectDoxygenDocumentation(
  options: DoxygenOptions,
): Promise<{ documentation: Documentation[]; headerDocumentation: HeaderDocumentation[] }> {
  await Deno.mkdir(options.outputDirectory, { recursive: true });
  const configPath = `${options.outputDirectory}/Doxyfile`;
  await Deno.writeTextFile(configPath, renderDoxygenConfig(options));
  const doxygenOutput = await runCommand("doxygen", [configPath]);
  const unresolvedApiReferences = doxygenOutput.stderr.split("\n").filter((line) =>
    /warning:.*(?:unable to resolve reference|explicit link request.*could not be resolved)/i.test(
      line,
    ) &&
    [...line.matchAll(/['"`]([A-Za-z_][A-Za-z0-9_]*)['"`]/g)].some((match) =>
      options.apiPrefixes.some((prefix) => match[1].startsWith(prefix))
    )
  );
  if (unresolvedApiReferences.length > 0) {
    throw new Error(
      `Doxygen reported unresolved configured API references:\n${
        unresolvedApiReferences.join("\n")
      }`,
    );
  }

  const xmlDirectory = `${options.outputDirectory}/xml`;
  const documentation: Documentation[] = [];
  const indexDocument = orderedParser.parse(
    await Deno.readTextFile(`${xmlDirectory}/index.xml`),
  ) as unknown[];
  const compoundFiles = [
    ...new Set(
      findOrderedElements(indexDocument, "compound")
        .map((compound) => orderedAttribute(compound, "refid"))
        .filter(Boolean)
        .map((refid) => `${refid}.xml`),
    ),
  ].sort();
  for (const filename of compoundFiles) {
    const xml = await Deno.readTextFile(`${xmlDirectory}/${filename}`);
    documentation.push(...parseCompoundDocument(orderedParser.parse(xml) as unknown[]));
  }

  documentation.sort((left, right) =>
    left.name.localeCompare(right.name) ||
    left.kind.localeCompare(right.kind) ||
    left.header.localeCompare(right.header) ||
    (left.line ?? 0) - (right.line ?? 0) ||
    left.signature.localeCompare(right.signature)
  );

  return {
    documentation,
    headerDocumentation: await collectHeaderDocumentation(options.inputDirectory),
  };
}

async function collectHeaderDocumentation(inputDirectory: string): Promise<HeaderDocumentation[]> {
  const headers: HeaderDocumentation[] = [];
  for await (const entry of walkHeaders(inputDirectory)) {
    const source = await Deno.readTextFile(entry);
    const documentation = extractHeaderDocumentation(entry, source);
    if (documentation) headers.push(documentation);
  }
  return headers.sort((left, right) => left.header.localeCompare(right.header));
}

export function extractHeaderDocumentation(
  headerPath: string,
  source: string,
): HeaderDocumentation | undefined {
  const categoryComment = source.match(
    /\/\*\*\s*\n\s*\*\s*#\s+(Category[A-Za-z0-9_]+)\s*\n([\s\S]*?)\*\//,
  );
  if (!categoryComment) return undefined;
  const comment = categoryComment[2]
    .split("\n")
    .map((line) => line.replace(/^\s*\* ?/, "").trimEnd())
    .join("\n")
    .trim();
  if (!comment) return undefined;
  return {
    header: headerPath.replaceAll("\\", "/").split("/").at(-1)!,
    category: categoryComment[1],
    comment,
  };
}

async function* walkHeaders(directory: string): AsyncGenerator<string> {
  for await (const entry of Deno.readDir(directory)) {
    const path = `${directory}/${entry.name}`;
    if (entry.isDirectory) yield* walkHeaders(path);
    else if (entry.isFile && entry.name.endsWith(".h")) yield path;
  }
}

function renderDoxygenConfig(options: DoxygenOptions): string {
  return [
    `PROJECT_NAME = ${quoteConfigPath(options.projectName)}`,
    `INPUT = ${quoteConfigPath(options.inputDirectory)}`,
    "FILE_PATTERNS = *.h",
    "RECURSIVE = YES",
    `OUTPUT_DIRECTORY = ${quoteConfigPath(options.outputDirectory)}`,
    "GENERATE_HTML = NO",
    "GENERATE_LATEX = NO",
    "GENERATE_XML = YES",
    "XML_OUTPUT = xml",
    "QUIET = YES",
    "WARNINGS = YES",
    "WARN_IF_UNDOCUMENTED = NO",
    "EXTRACT_ALL = YES",
    "EXTRACT_STATIC = YES",
    "ENABLE_PREPROCESSING = YES",
    "MACRO_EXPANSION = NO",
    "EXPAND_ONLY_PREDEF = YES",
    "SKIP_FUNCTION_MACROS = NO",
    `PREDEFINED = ${options.predefined.map(quoteConfigValue).join(" ")}`,
    'ALIASES += threadsafety="**Thread safety:**"',
    "",
  ].join("\n");
}

function quoteConfigValue(value: string): string {
  return `"${value.replaceAll("\\", "\\\\").replaceAll('"', '\\"')}"`;
}

function parseCompoundDocument(
  document: unknown[],
): Documentation[] {
  const result: Documentation[] = [];
  for (const compound of findOrderedElements(document, "compounddef")) {
    const contents = orderedContents(compound, "compounddef");
    const compoundName = orderedText(contents, "compoundname");
    const compoundKind = orderedAttribute(compound, "kind");
    const compoundLocation = orderedElements(contents, "location")[0];
    const compoundComment = orderedDescription(contents);
    if (
      compoundName && compoundComment &&
      (compoundKind === "struct" || compoundKind === "union" || compoundKind === "class")
    ) {
      result.push({
        name: stripRecordPrefix(compoundName),
        kind: compoundKind,
        header: locationFile(compoundLocation),
        line: orderedNumberAttribute(compoundLocation, "line"),
        signature: compoundName,
        comment: compoundComment,
        parameters: [],
      });
    }

    for (const section of orderedElements(contents, "sectiondef")) {
      for (const member of orderedElements(orderedContents(section, "sectiondef"), "memberdef")) {
        const memberContents = orderedContents(member, "memberdef");
        const name = orderedText(memberContents, "name");
        if (!name) continue;
        const kind = orderedAttribute(member, "kind");
        const location = orderedElements(memberContents, "location")[0];
        const parameters = orderedElements(memberContents, "param").map(renderParameter);
        const args = orderedText(memberContents, "argsstring");
        const definition = orderedText(memberContents, "definition");
        result.push({
          name,
          kind,
          header: locationFile(location),
          line: orderedNumberAttribute(location, "line"),
          signature: `${definition}${args}`.trim(),
          comment: orderedDescription(memberContents),
          parameters,
        });

        for (const value of orderedElements(memberContents, "enumvalue")) {
          const valueContents = orderedContents(value, "enumvalue");
          const valueName = orderedText(valueContents, "name");
          if (!valueName) continue;
          result.push({
            name: valueName,
            kind: "enumvalue",
            header: locationFile(location),
            line: orderedNumberAttribute(location, "line"),
            signature: valueName,
            comment: orderedDescription(valueContents),
            parameters: [],
          });
        }
      }
    }
  }
  return result;
}

function orderedDescription(contents: unknown[]): string {
  const paragraphs = [
    ...orderedTagContents(contents, "briefdescription"),
    ...orderedTagContents(contents, "detaileddescription"),
  ].map(renderOrderedRichText).map((part) => part.trim()).filter(Boolean);
  return [...new Set(paragraphs)].join("\n\n");
}

function orderedElements(values: unknown, wantedTag: string): XmlObject[] {
  const items = Array.isArray(values) ? values : [values];
  return items.flatMap((value) => {
    const record = object(value);
    return record && wantedTag in record ? [record] : [];
  });
}

function orderedContents(element: XmlObject, tag: string): unknown[] {
  const contents = element[tag];
  return Array.isArray(contents) ? contents : [contents];
}

function orderedText(contents: unknown[], tag: string): string {
  const element = orderedElements(contents, tag)[0];
  return element ? plainOrderedText(orderedContents(element, tag)).trim() : "";
}

function orderedTagContents(values: unknown[], wantedTag: string): unknown[][] {
  return orderedElements(values, wantedTag).map((element) => orderedContents(element, wantedTag));
}

function renderOrderedRichText(value: unknown): string {
  if (typeof value === "string" || typeof value === "number") return String(value);
  if (Array.isArray(value)) return normalizeMarkdown(value.map(renderOrderedRichText).join(""));
  const record = object(value);
  if (!record) return "";
  if (record["#text"] !== undefined) return String(record["#text"]);

  const pieces: string[] = [];
  for (const [tag, children] of Object.entries(record)) {
    if (tag === ":@" || tag === "#text") continue;
    const rendered = renderOrderedRichText(children).trim();
    if (!rendered && tag !== "sp" && tag !== "linebreak") continue;
    switch (tag) {
      case "computeroutput":
        pieces.push(`\`${rendered}\``);
        break;
      case "bold":
        pieces.push(`**${rendered}**`);
        break;
      case "emphasis":
        pieces.push(`*${rendered}*`);
        break;
      case "ulink": {
        const url = orderedAttribute(record, "url");
        pieces.push(url ? `[${rendered}](${url})` : rendered);
        break;
      }
      case "programlisting":
        pieces.push(`\n\n\`\`\`c\n${plainOrderedText(children).trim()}\n\`\`\`\n\n`);
        break;
      case "itemizedlist":
      case "orderedlist":
        pieces.push(`\n${renderOrderedList(children, tag === "orderedlist")}\n`);
        break;
      case "parameterlist":
        pieces.push(`\n\n${renderOrderedParameterList(record, children)}\n\n`);
        break;
      case "simplesect": {
        const kind = orderedAttribute(record, "kind");
        const label = simpleSectionLabel(kind);
        pieces.push(label ? `\n\n**${label}:** ${rendered}\n\n` : rendered);
        break;
      }
      case "xrefsect":
        pieces.push(`\n\n${rendered}\n\n`);
        break;
      case "sp":
        pieces.push(" ");
        break;
      case "linebreak":
        pieces.push("\n");
        break;
      default:
        pieces.push(rendered);
    }
  }
  return normalizeMarkdown(pieces.join(""));
}

function renderOrderedList(value: unknown, ordered: boolean): string {
  const items = findOrderedTag(value, "listitem");
  return items.map((item, index) => {
    const marker = ordered ? `${index + 1}.` : "-";
    return `${marker} ${renderOrderedRichText(item).trim()}`;
  }).join("\n");
}

function renderOrderedParameterList(record: XmlObject, value: unknown): string {
  const kind = orderedAttribute(record, "kind");
  const label = kind === "retval"
    ? "Return values"
    : kind === "exception"
    ? "Errors"
    : "Parameters";
  const items = findOrderedTag(value, "parameteritem").map((item) => {
    const names = findOrderedTag(item, "parametername")
      .map((name) => plainOrderedText(name).trim())
      .filter(Boolean)
      .map((name) => `\`${name}\``)
      .join(", ");
    const descriptions = findOrderedTag(item, "parameterdescription")
      .map(renderOrderedRichText)
      .map((description) => description.trim())
      .filter(Boolean)
      .join(" ");
    return `- ${names}${names && descriptions ? ": " : ""}${descriptions}`;
  });
  return `**${label}:**\n${items.join("\n")}`;
}

function findOrderedTag(value: unknown, wantedTag: string): unknown[] {
  return findOrderedElements(value, wantedTag).map((element) => element[wantedTag]);
}

function findOrderedElements(value: unknown, wantedTag: string): XmlObject[] {
  const matches: unknown[] = [];
  const visit = (item: unknown): void => {
    if (Array.isArray(item)) {
      for (const child of item) visit(child);
      return;
    }
    const record = object(item);
    if (!record) return;
    for (const [tag, children] of Object.entries(record)) {
      if (tag === wantedTag) {
        matches.push(record);
      } else if (tag !== ":@" && tag !== "#text") {
        visit(children);
      }
    }
  };
  visit(value);
  return matches as XmlObject[];
}

function plainOrderedText(value: unknown): string {
  if (typeof value === "string" || typeof value === "number") return String(value);
  if (Array.isArray(value)) return value.map(plainOrderedText).join("");
  const record = object(value);
  if (!record) return "";
  if (record["#text"] !== undefined) return String(record["#text"]);
  return Object.entries(record)
    .filter(([tag]) => tag !== ":@")
    .map(([, child]) => plainOrderedText(child))
    .join("");
}

function simpleSectionLabel(kind: string): string {
  switch (kind) {
    case "return":
      return "Returns";
    case "since":
      return "Since";
    case "see":
      return "See also";
    case "note":
      return "Note";
    case "warning":
      return "Warning";
    case "pre":
      return "Precondition";
    case "post":
      return "Postcondition";
    default:
      return "";
  }
}

function orderedAttribute(value: XmlObject, name: string): string {
  const attributes = object(value[":@"]);
  return attribute(attributes, name);
}

function orderedNumberAttribute(value: XmlObject | undefined, name: string): number | undefined {
  return numberAttribute(value ? object(value[":@"]) : undefined, name, { positive: true });
}

function renderParameter(value: XmlObject): string {
  const contents = orderedContents(value, "param");
  const type = orderedText(contents, "type");
  const name = orderedText(contents, "declname") || orderedText(contents, "defname");
  return `${type}${name ? ` ${name}` : ""}`.trim();
}

function normalizeMarkdown(value: string): string {
  return value
    .replaceAll("&lt;", "<")
    .replaceAll("&gt;", ">")
    .replaceAll("&quot;", '"')
    .replaceAll("&apos;", "'")
    .replaceAll("&amp;", "&")
    .replace(/[ \t]+/g, " ")
    .replace(/ *\n */g, "\n")
    .replace(/\n{3,}/g, "\n\n")
    .trim();
}

function stripRecordPrefix(name: string): string {
  return name.replace(/^(?:struct|union)_/, "");
}

function locationFile(location: XmlObject | undefined): string {
  return location
    ? orderedAttribute(location, "declfile") || orderedAttribute(location, "file")
    : "";
}

function quoteConfigPath(path: string): string {
  return `"${path.replaceAll("\\", "/").replaceAll('"', '\\"')}"`;
}
