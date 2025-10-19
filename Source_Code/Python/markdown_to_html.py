import html
import pathlib
import re
from typing import List


TEMPLATE = """<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <title>{title}</title>
  <script defer src="https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js"></script>
  <style>
    body {{ font-family: "Segoe UI", Arial, sans-serif; margin: 2rem auto; max-width: 900px; line-height: 1.6; }}
    pre {{ background: #f5f5f5; padding: 1rem; overflow-x: auto; }}
    code {{ font-family: "Fira Code", "Courier New", monospace; }}
    h1, h2, h3 {{ margin-top: 2rem; }}
    ul {{ margin-left: 1.2rem; }}
    .citation {{ color: #555; }}
  </style>
</head>
<body>
{body}
</body>
</html>
"""


def _extract_math_segments(text: str) -> (str, List[str], List[str]):
    block_math: List[str] = []
    inline_math: List[str] = []

    def block_repl(match: re.Match[str]) -> str:
        idx = len(block_math)
        block_math.append(match.group(0))
        return f"@@MATH{idx}@@"

    def inline_repl(match: re.Match[str]) -> str:
        idx = len(inline_math)
        inline_math.append(match.group(0))
        return f"@@IMATH{idx}@@"

    text = re.sub(r"\$\$(.*?)\$\$", block_repl, text, flags=re.S)
    text = re.sub(r"(?<!\$)\$(?!\$)(.*?)(?<!\$)\$(?!\$)", inline_repl, text, flags=re.S)
    return text, block_math, inline_math


def _restore_math(html_text: str, block_math: List[str], inline_math: List[str]) -> str:
    for idx, block in enumerate(block_math):
        placeholder = f"@@MATH{idx}@@"
        wrapped = f"<div>{block}</div>"
        html_text = html_text.replace(f"<p>{placeholder}</p>", wrapped)
        html_text = html_text.replace(placeholder, wrapped)
    for idx, inline in enumerate(inline_math):
        placeholder = f"@@IMATH{idx}@@"
        wrapped = f"<span>{inline}</span>"
        html_text = html_text.replace(placeholder, wrapped)
    return html_text


def _naive_html(md_text: str) -> str:
    lines = md_text.splitlines()
    html_lines: List[str] = []
    in_list = False

    def close_list():
        nonlocal in_list
        if in_list:
            html_lines.append("</ul>")
            in_list = False

    for line in lines:
        stripped = line.strip()
        if not stripped:
            close_list()
            continue
        if stripped.startswith("### "):
            close_list()
            html_lines.append(f"<h3>{html.escape(stripped[4:])}</h3>")
        elif stripped.startswith("## "):
            close_list()
            html_lines.append(f"<h2>{html.escape(stripped[3:])}</h2>")
        elif stripped.startswith("# "):
            close_list()
            html_lines.append(f"<h1>{html.escape(stripped[2:])}</h1>")
        elif stripped.startswith("- "):
            if not in_list:
                html_lines.append("<ul>")
                in_list = True
            html_lines.append(f"<li>{html.escape(stripped[2:])}</li>")
        else:
            close_list()
            html_lines.append(f"<p>{html.escape(line)}</p>")
    close_list()
    return "\n".join(html_lines)


def convert_markdown(md_path: pathlib.Path, html_path: pathlib.Path) -> None:
    raw_text = md_path.read_text(encoding="utf-8")
    text, block_math, inline_math = _extract_math_segments(raw_text)

    title = "Unification of Scale-Invariant Resonant Fields"
    try:
        import markdown  # type: ignore

        body = markdown.markdown(
            text,
            extensions=[
                "fenced_code",
                "tables",
                "sane_lists",
                "toc",
                "md_in_html",
            ],
            output_format="html5",
        )
    except ImportError:
        body = _naive_html(text)

    body = _restore_math(body, block_math, inline_math)
    body = re.sub(r"\(([^()]+?\d{4})\)", r"<span class=\"citation\">(\1)</span>", body)
    full = TEMPLATE.format(title=html.escape(title), body=body)
    html_path.write_text(full, encoding="utf-8")


if __name__ == "__main__":
    md_file = pathlib.Path("Unification_of_Scale_Invariant_and_Consciousness_Model.md")
    html_file = pathlib.Path("Unification_of_Scale_Invariant_and_Consciousness_Model.html")
    convert_markdown(md_file, html_file)
