import pathlib
import re
from typing import Match


def _strip_comments(text: str) -> str:
    return re.sub(r"(?<!\\)%.*", "", text)


def _convert_block_math(match: Match[str]) -> str:
    content = match.group(1).strip()
    return f"\n$$\n{content}\n$$\n"


def _convert_align_math(match: Match[str]) -> str:
    content = match.group(1).strip()
    return f"\n$$\n\\begin{{aligned}}\n{content}\n\\end{{aligned}}\n$$\n"


def _replace_cites(text: str) -> str:
    def repl(match: Match[str]) -> str:
        refs = [r.strip() for r in match.group(1).split(",")]
        return "(" + ", ".join(refs) + ")"

    return re.sub(r"\\cite[a-zA-Z]*\{([^}]*)\}", repl, text)


def latex_to_markdown(src: pathlib.Path, dst: pathlib.Path) -> None:
    text = src.read_text(encoding="utf-8")
    text = _strip_comments(text)

    # Remove preamble / metadata
    text = re.sub(r"\\documentclass.*?\n", "", text, flags=re.S)
    text = re.sub(r"\\usepackage(?:\[[^\]]*\])?\{[^}]*\}\s*", "", text)
    text = re.sub(r"\\begin{document}", "", text)
    text = re.sub(r"\\end{document}", "", text)
    text = re.sub(r"\\geometry\{[^}]*\}", "", text)
    text = re.sub(r"\\theoremstyle\{[^}]*\}", "", text)
    text = re.sub(r"\\newtheorem\{[^}]*\}.*\n", "", text)
    text = re.sub(r"\\title\{[^}]*\}", "", text)
    text = re.sub(r"\\author\{[^}]*\}", "", text)
    text = re.sub(r"\\date\{[^}]*\}", "", text)
    text = text.replace(r"\maketitle", "")
    text = re.sub(r"\\begin{abstract}", "\n**Abstract.** ", text)
    text = text.replace(r"\end{abstract}", "")

    # Replace environments with headers/emphasis
    text = re.sub(r"\\begin{theorem}", "\n**Theorem.**", text)
    text = re.sub(r"\\end{theorem}", "", text)
    text = re.sub(r"\\begin{proposition}", "\n**Proposition.**", text)
    text = re.sub(r"\\end{proposition}", "", text)
    text = re.sub(r"\\begin{definition}", "\n**Definition.**", text)
    text = re.sub(r"\\end{definition}", "", text)
    text = re.sub(r"\\begin{proof}", "\n**Proof.**", text)
    text = re.sub(r"\\end{proof}", "", text)

    # Headings
    text = re.sub(r"\\section\{([^}]*)\}", r"\n# \1\n", text)
    text = re.sub(r"\\subsection\{([^}]*)\}", r"\n## \1\n", text)
    text = re.sub(r"\\subsubsection\{([^}]*)\}", r"\n### \1\n", text)

    # Math environments
    text = re.sub(r"\\begin{equation}\s*(.*?)\\end{equation}", _convert_block_math, text, flags=re.S)
    text = re.sub(r"\\begin{align}\s*(.*?)\\end{align}", _convert_align_math, text, flags=re.S)
    text = re.sub(r"\\\[\s*(.*?)\\\]", _convert_block_math, text, flags=re.S)

    # Lists
    text = re.sub(r"\\begin{enumerate}", "", text)
    text = re.sub(r"\\end{enumerate}", "", text)
    text = re.sub(r"\\begin{itemize}", "", text)
    text = re.sub(r"\\end{itemize}", "", text)
    text = re.sub(r"\\item", "\n- ", text)

    # Labels and references
    text = re.sub(r"\\label\{([^}]*)\}", "", text)
    text = re.sub(r"~", " ", text)
    text = re.sub(r"\\eqref\{([^}]*)\}", r"(\1)", text)
    text = re.sub(r"\\ref\{([^}]*)\}", r"(\1)", text)

    # Simplify label names inside parentheses
    text = re.sub(r"\(eq:([A-Za-z0-9_\-:]+)\)", r"(\1)", text)
    text = re.sub(r"\(sec:([A-Za-z0-9_\-:]+)\)", r"(\1)", text)
    text = re.sub(r"\(prop:([A-Za-z0-9_\-:]+)\)", r"(\1)", text)
    text = re.sub(r"\(theorem:([A-Za-z0-9_\-:]+)\)", r"(\1)", text)
    text = re.sub(r"\(fig:([A-Za-z0-9_\-:]+)\)", r"(\1)", text)
    text = re.sub(r"Eq\.\s*\(([^)]+)\)", r"Equation (\1)", text)
    text = re.sub(r"Section\s*\(([^)]+)\)", r"Section (\1)", text)

    # Citations
    text = _replace_cites(text)

    # Inline formatting
    text = re.sub(r"\\emph\{([^}]*)\}", r"*\1*", text)
    text = re.sub(r"\\textbf\{([^}]*)\}", r"**\1**", text)
    text = re.sub(r"\\textit\{([^}]*)\}", r"*\1*", text)
    text = re.sub(r"\\left", "", text)
    text = re.sub(r"\\right", "", text)
    text = text.replace("``", '"').replace("''", '"')

    # Remove unintended indentation
    text = re.sub(r"\n\s+([A-Za-z0-9\\\$\#])", r"\n\1", text)

    # Collapse blank lines
    text = re.sub(r"\n{3,}", "\n\n", text)

    dst.write_text(text.strip() + "\n", encoding="utf-8")


if __name__ == "__main__":
    src = pathlib.Path("Unification_of_Scale_Invariant_and_Consciousness_Model.tex")
    dst = pathlib.Path("Unification_of_Scale_Invariant_and_Consciousness_Model.md")
    latex_to_markdown(src, dst)
