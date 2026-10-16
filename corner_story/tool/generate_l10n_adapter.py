"""Regenerate literal-to-ARB lookup after editing the ARB catalogues."""
import json
import pathlib

root = pathlib.Path(__file__).resolve().parents[1]
l10n = root / "lib/l10n"
catalogue = json.loads((l10n / "app_en.arb").read_text(encoding="utf-8"))
adapter = l10n / "corner_l10n.dart"
source = adapter.read_text(encoding="utf-8")
cases = [
    f"      {value!r} => strings.{key},"
    for key, value in catalogue.items()
    if not key.startswith("@")
]
begin = source.index("    final translated = switch (source) {")
end = source.index("    if (translated != null) return translated;", begin)
source = (
    source[:begin]
    + "    final translated = switch (source) {\n"
    + "\n".join(cases)
    + "\n      _ => null,\n    };\n"
    + source[end:]
)
adapter.write_text(source, encoding="utf-8")
print(f"Generated {len(cases)} text lookups")
