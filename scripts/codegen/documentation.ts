export function renderDocComment(comment: string): string[] {
  const lines = formatDocumentationMarkdown(
    comment.replace(/\r/g, "").split("\n").map((line) => line.trimEnd()),
  );
  while (lines[0] === "") lines.shift();
  while (lines.at(-1) === "") lines.pop();
  return lines.map((line) => line.length > 0 ? `/// ${line}` : "///");
}

export function appendDocumentationParagraph(
  documentation: string[],
  paragraph: string,
): void {
  if (documentation.length > 0 && documentation.at(-1) !== "///") documentation.push("///");
  documentation.push(paragraph);
}

function formatDocumentationMarkdown(sourceLines: string[]): string[] {
  const lines = separateDocumentationSummary(splitInlineCodeFences(sourceLines));
  const formatted: string[] = [];
  let inCodeBlock = false;

  for (let index = 0; index < lines.length;) {
    const line = lines[index];
    if (inCodeBlock || !isDocumentationField(line)) {
      formatted.push(line);
      const wasCodeBlock = inCodeBlock;
      inCodeBlock = toggleCodeBlock(line, inCodeBlock);
      if (wasCodeBlock && !inCodeBlock && index + 1 < lines.length && lines[index + 1] !== "") {
        formatted.push("");
      }
      index += 1;
      continue;
    }

    const fields: string[] = [];
    while (index < lines.length) {
      const field = lines[index];
      if (!inCodeBlock && isDocumentationField(field)) {
        fields.push(...documentationFields(field));
        inCodeBlock = toggleCodeBlock(field, inCodeBlock);
        index += 1;
        continue;
      }
      if (field === "") {
        index += 1;
        continue;
      }
      break;
    }

    const fieldLines = formatDocumentationFields(fields);
    const nestedParameters = fields.length === 1 && isParametersField(fields[0]) &&
      index < lines.length && isMarkdownListItem(lines[index]);

    while (formatted.at(-1) === "") formatted.pop();
    if (formatted.length > 0) formatted.push("");
    formatted.push(...fieldLines);
    if (nestedParameters) {
      while (index < lines.length) {
        const parameter = lines[index];
        if (isMarkdownListItem(parameter)) {
          formatted.push(`  ${parameter}`);
          index += 1;
          continue;
        }
        if (parameter === "") {
          index += 1;
          continue;
        }
        break;
      }
    }
    if (index < lines.length && lines[index] !== "") formatted.push("");
  }

  return formatted;
}

function separateDocumentationSummary(lines: string[]): string[] {
  const summary = lines.findIndex((line) => line !== "");
  if (
    summary < 0 ||
    summary + 1 >= lines.length ||
    lines[summary + 1] === "" ||
    isDocumentationField(lines[summary]) ||
    lines[summary].startsWith("```") ||
    lines[summary].startsWith("- ") ||
    lines[summary + 1].startsWith("```") ||
    lines[summary + 1].startsWith("- ")
  ) {
    return lines;
  }
  return [...lines.slice(0, summary + 1), "", ...lines.slice(summary + 1)];
}

function splitInlineCodeFences(lines: string[]): string[] {
  return lines.flatMap((line) => {
    const parts = line.split(/(```[^\s`]*)/).filter(Boolean);
    return parts.length > 1 ? parts.map((part) => part.trim()) : [line];
  });
}

function isDocumentationField(line: string): boolean {
  return /^\*\*[^*\n]+:\*\*(?:\s|$)/.test(line);
}

function documentationFields(line: string): string[] {
  return line.split(/(?=\*\*[^*\n]+:\*\*(?:\s|$))/).filter(Boolean);
}

function formatDocumentationFields(fields: string[]): string[] {
  const result: string[] = [];
  let previousKind: "alert" | "metadata" | undefined;
  for (const field of fields) {
    const kind = isAlertField(field) ? "alert" : "metadata";
    if (previousKind && previousKind !== kind) result.push("");
    result.push(kind === "alert" ? `> ${field}` : `- ${field}`);
    previousKind = kind;
  }
  return result;
}

function isAlertField(field: string): boolean {
  return /^\*\*(?:Attention|Bug|Deprecated|Important|Note|Warning):\*\*/i.test(field);
}

function isParametersField(field: string): boolean {
  return /^\*\*Parameters:\*\*/i.test(field);
}

function isMarkdownListItem(line: string): boolean {
  return /^(?:[-*+] |\d{1,9}[.)] )/.test(line);
}

function toggleCodeBlock(line: string, inCodeBlock: boolean): boolean {
  return (line.match(/```/g)?.length ?? 0) % 2 === 0 ? inCodeBlock : !inCodeBlock;
}
