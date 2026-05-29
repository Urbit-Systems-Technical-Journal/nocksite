"""Pygments lexers for the Nock family of languages.

- NockLexer: the Nock combinator calculus (handwritten from the spec usage).
- HoonLexer: ported from pkova/hoon-grammar (MIT, Pyry Kovanen 2022),
  the TextMate grammar bundled by github-linguist for source.hoon.

Registered with Sphinx via the `setup` hook so fenced code blocks tagged
```nock and ```hoon are syntax-highlighted instead of raising
"Pygments lexer name '<lang>' is not known" warnings.
"""

from pygments.lexer import RegexLexer
from pygments.token import (
    Comment,
    Keyword,
    Name,
    Number,
    Operator,
    Punctuation,
    String,
    Text,
)


class NockLexer(RegexLexer):
    name = "Nock"
    aliases = ["nock"]
    filenames = ["*.nock"]

    tokens = {
        "root": [
            (r"[ \t]+", Text),
            (r"\r?\n", Text),
            (r"::.*?$", Comment.Single),
            (r"[\[\]]", Punctuation),
            (r"(?:->|→|↦|↣)", Operator),
            (r"[*/?=]", Operator),
            (r"<[^>\n]+>", Name.Variable),
            (r"\+\d+", Name.Builtin),
            (r"\d+(?:\.\d+)*", Number.Integer),
            (r"[a-zA-Z_][a-zA-Z0-9_-]*", Name),
            (r".", Text),
        ],
    }


# Rune regex transcribed from pkova/hoon-grammar's hoon.tmLanguage:
# each two-char rune is a leading glyph followed by one of its allowed seconds.
_HOON_RUNES = (
    r"\.[\^\+\*=\?]"
    r"|![><:\.=\?!]"
    r"|=[>|:,\.\-\^<+;/~\*\?]"
    r"|\?[>|:\.\-\^<\+&~=@!]"
    r"|\|[\$_%:\.\-\^~\*=@\?]"
    r"|\+[|\$\+\*]"
    r"|:[_\-\^\+~\*]"
    r"|%[_:\.\-\^\+~\*=]"
    r"|\^[|:\.\-\+&~\*=\?]"
    r"|\$[|_%:<>\-\^&~@=\?]"
    r"|;[:<\+;\/~\*=]"
    r"|~[>|\$_%<\+\/&=\?!]"
    r"|--|=="
)


class HoonLexer(RegexLexer):
    name = "Hoon"
    aliases = ["hoon"]
    filenames = ["*.hoon"]

    tokens = {
        "root": [
            (r"::.*?$", Comment.Single),
            (r'\s*"""', String.Double, "doqbloq"),
            (r"\s*'''", String.Double, "soqbloq"),
            (r'"', String.Double, "tape"),
            (r"'", String.Single, "cord"),
            (r"\+\+  [a-z](?:[a-z0-9-]*[a-z0-9])?", Name.Function),
            (r"[a-z](?:[a-z0-9-]*[a-z0-9])?(?==)", Name.Attribute),
            (r"%[a-z](?:[a-z0-9-]*[a-z0-9])?", Name.Constant),
            (r"@(?:[a-z0-9-]*[a-z0-9])?|\*", Keyword.Type),
            (_HOON_RUNES, Keyword),
            (r"[ \t]+", Text),
            (r"\r?\n", Text),
            (r".", Text),
        ],
        "doqbloq": [
            (r'\s*"""', String.Double, "#pop"),
            (r"[^\"]+", String.Double),
            (r'"', String.Double),
        ],
        "soqbloq": [
            (r"\s*'''", String.Double, "#pop"),
            (r"[^']+", String.Double),
            (r"'", String.Double),
        ],
        "tape": [
            (r'\\.', String.Escape),
            (r'[^"\\]+', String.Double),
            (r'"', String.Double, "#pop"),
        ],
        "cord": [
            (r"\\.", String.Escape),
            (r"[^'\\]+", String.Single),
            (r"'", String.Single, "#pop"),
        ],
    }


def setup(app):
    app.add_lexer("nock", NockLexer)
    app.add_lexer("hoon", HoonLexer)
    return {"version": "0.2", "parallel_read_safe": True}
