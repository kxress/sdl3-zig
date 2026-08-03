export interface XmlObject {
  [key: string]: unknown;
}

export function objects(value: unknown): XmlObject[] {
  const values = Array.isArray(value) ? value : [value];
  return values.filter((item): item is XmlObject =>
    item !== null && typeof item === "object" && !Array.isArray(item)
  );
}

export function object(value: unknown): XmlObject | undefined {
  return objects(value)[0];
}

export function attribute(value: XmlObject | undefined, name: string): string {
  const item = value?.[`@_${name}`];
  return typeof item === "string" || typeof item === "number" ? String(item) : "";
}

export function numberAttribute(
  value: XmlObject | undefined,
  name: string,
  options: { positive?: boolean } = {},
): number | undefined {
  const parsed = Number(attribute(value, name));
  return Number.isFinite(parsed) && (!options.positive || parsed > 0) ? parsed : undefined;
}
