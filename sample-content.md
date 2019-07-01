# Introduction

\epigraph{\slshape{
    Discovery is the ability to be puzzled by simple things.\\
}}{\slshape{--- Noam Chomsky (1928--\space\space\space\space)\\American linguist}}

\noindent This booklet describes the conversion of markdown files to `.pdf` files.

\index{Pandoc}

[__Pandoc__](http://pandoc.org) is a tool written in
[Haskell](https://www.haskell.org) by John MacFarlane since 2006 for
converting from one markup format to another. Pandoc understands an
extended and slightly revised version of John Gruber's [Markdown] syntax.
These extensions and revisions are necessary to provide multiple output
formats aimed by Pandoc's design.

\index{TeX}

__TeX__[^TeX] is a typesetting program, originally written by Donald Knuth
at Stanford University in 1978--1979. "_TeX [is] a new typesetting system
intended for the creation of beautiful books--and especially for books that
contain a lot of mathematics. By preparing a manuscript in TeX format, you
will be telling a computer exactly how the manuscript is to be transformed
into pages whose typographic quality is comparable to that of the world's
finest printers._"[^TeXbook]

\index{LaTeX}

__LaTeX__[^LaTeX] is a user interface for TeX providing a simpler way of
using the power of TeX without diving into the language details. It was
designed by Leslie Lamport at Digital Equipment Corporation (DEC) in 1985
to automate all the common tasks of document preparation.

[__Markdown__](http://daringfireball.net/projects/markdown/) is a
plain text format for writing structured documents based on conventions.
It was developed by John Gruber (with help from Aaron Swartz) and released
in 2004. Gruber wrote in his website: "_The overriding design goal for
Markdown's formatting syntax is to make it as readable as possible. The
idea is that a Markdown-formatted document should be publishable as-is, as
plain text, without looking like it's been marked up with tags or formatting
instructions._"

[^TeX]: Add `todo` here.
[^LaTeX]: Add `todo` here.
[^TeXbook]: Donald E. Knuth. The TeXbook, Volume A of Computers and Typesetting.
Addison-Wesley, Reading, MA, USA, 1986. ISBN 0-201-13447-0.
The definitive user's guide and complete reference manual for TeX.

# Pandoc and Markdown

\epigraph{\slshape{
    I have not failed.\\
    I've just found 10,000 ways that won't work.
}}{\slshape{--- Thomas Edison (1847--1931)\\American inventor}}

## YAML Metadata

YAML[^YAML] Ain't Markup Language (abbreviated as YAML) is a cross-language, Unicode-based data serialization language designed to be human-friendly that works well with modern programming languages for common everyday tasks.

YAML metadata

Create a two-line title by using the pipe character `|`. The YAML metadata
should be declared exactly like the following:

~~~
title: |
  | Title on First Line
  | Title on Second Line
  |
~~~

Block notation using the pipe character `|` treats each newline literally.
The extra pipe character at the end is sometimes necessary so LaTeX will
space the last line vertically equal with the previous lines.

It can also be used when a subtitle is present to add vertical space between
the title and the subtitle.

~~~
title: This is the Title
subtitle: |
  | This is the Subtitle
  |
~~~

Client name.

~~~
client: client name
~~~

Single author and email.

~~~
author: author name
email: email@address.com
~~~

Multiple authors are defined like the following:

~~~
author:
  - name: Author One
    email: email@address.com
  - name: Author Two
    email: email@address.com
~~~

[^YAML]: YAML Version 1.2 at [http://yaml.org/spec/1.2/spec.html](http://yaml.org/spec/1.2/spec.html).

## Chapter Epigraph

Quotation on every chapter at the upper right below the chapter title.
Provide the `text` and `author`. It is necessary to add `\noindent` on the
succeeding paragraph so it flushes the first line of the first paragraph to
the left which is the default for Anglo-American publishers.[^AngloAmericanPublishers]

The syntax is `\epigraph{text}{author}`.

The following raw TeX is the epigraph for this chapter.

~~~
\epigraph{\slshape{
    I have not failed.\\
    I've just found 10,000 ways that won't work.
}}{\slshape{--- Thomas Edison}}

\noindent <Paragraph text...>
~~~

[^AngloAmericanPublishers]: LaTeX Wikibooks, June 2016, Chapter 7 Paragraph Formatting, p. 77.

## Paragraph

To continue a paragraph after a fenced code block or a list, use `\noindent`
at the beginning of the text. The command instructs the `LaTeX` engine not
to indent the text.

~~~
\noindent Paragraph continuation...
~~~

## Quote Block

A block of text may be specified as a quote block by starting each line of text with a greater than (`>`) character and an optional space.
The greater than (`>`) character may be placed up to three (3) spaces from the left margin.
There must be a blank line after the end of the block of text.

~~~
> This is a block quote.
> Lorem ipsum dolor sit amet, consectetuer adipiscing elit.
> Ut purus elit, vestibulum ut, placerat ac, adipiscing vitae, felis.
> Curabitur dictum gravida mauris.
~~~

> This is a block quote.
> Lorem ipsum dolor sit amet, consectetuer adipiscing elit.
> Ut purus elit, vestibulum ut, placerat ac, adipiscing vitae, felis.
> Curabitur dictum gravida mauris.

Among the block elements that can be contained in a block quote are other
block quotes. That is, block quotes can be nested:

    > This is a block quote.
    > Lorem ipsum dolor sit amet, consectetuer adipiscing elit.
    > Ut purus elit, vestibulum ut, placerat ac, adipiscing vitae, felis.
    > Curabitur dictum gravida mauris.
    >
    > > A block quote within a block quote.
    > > Lorem ipsum dolor sit amet, consectetuer adipiscing elit.
    > > Ut purus elit, vestibulum ut, placerat ac, adipiscing vitae, felis.
    > > Curabitur dictum gravida mauris.

> This is a block quote.
> Lorem ipsum dolor sit amet, consectetuer adipiscing elit.
> Ut purus elit, vestibulum ut, placerat ac, adipiscing vitae, felis.
> Curabitur dictum gravida mauris.
>
> > A block quote within a block quote.
> > Lorem ipsum dolor sit amet, consectetuer adipiscing elit.
> > Ut purus elit, vestibulum ut, placerat ac, adipiscing vitae, felis.
> > Curabitur dictum gravida mauris.

If the `>` character is followed by an optional space, that space will be
considered part of the block quote marker and not part of the indentation
of the contents.  Thus, to put an indented code block in a block quote,
you need five spaces after the `>` like the following:

~~~
> This is a block quote and the following is a code block indented
> with five spaces.
>
>     int main() {
>         std::cout << "Hello world!\n";
>         return 0;
>     }
~~~

> This is a block quote and the following code block is indented with five
> spaces.
>
>     int main() {
>         std::cout << "Hello world!\n";
>         return 0;
>     }

## Lists

Lists are created using an asterisk (`*`), a plus (`+`) or a hyphen (`-`)
at the beginning of a list item. Lists may be nested by indenting the inner
lists using four (4) spaces.

~~~
* List item one
    * Nested list one
    * Nested list two
* List item two
    - Nested list one
    - Nested list two
        - More nested list one
        - More nested list two
            - Third nested list one
            - Third nested list two
    - Nested list three
~~~

The markdown above will produce the following "compact" list.

* List item one
    * Nested list one
    * Nested list two
* List item two
    - Nested list one
    - Nested list two
        - More nested list one
        - More nested list two
            - Third nested list one
            - Third nested list two
    - Nested list three

If a "loose" list is desired, follow each list item with a blank line.

* one

* two

* three

### List Item ###

A list item may contain multiple paragraphs and other block-level content.
However, subsequent paragraphs must be preceded by a blank line and indented
four (4) spaces. A _code block_ may be displayed under a list item as a
_fenced code block_ which must also be preceded by a blank line, indented
four (4) spaces.

~~~
* First paragraph. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.
Ut purus elit, vestibulum ut, placerat ac, adipiscing vitae, felis. Curabitur
dictum gravida mauris. Nam arcu libero, nonummy eget, consectetuer id,
vulputate a, magna.

    Second paragraph. Lorem ipsum dolor sit amet, consectetuer adipiscing
    elit. Ut purus elit, vestibulum ut, placerat ac, adipiscing vitae,
    felis. Curabitur dictum gravida mauris. Nam arcu libero, nonummy eget,
    consectetuer id, vulputate a, magna.

* Second item paragraph with a code block. Lorem ipsum dolor sit amet,
consectetuer adipiscing elit. Ut purus elit, vestibulum ut, placerat ac,
adipiscing vitae, felis. Curabitur dictum gravida mauris. Nam arcu libero,
nonummy eget, consectetuer id, vulputate a, magna.

    ~~~
    Put your source code here
    ...
    ~~~
~~~

The following is a sample output of the markdown code above.

* First paragraph. Lorem ipsum dolor sit amet, consectetuer adipiscing
elit. Ut purus elit, vestibulum ut, placerat ac, adipiscing vitae, felis.
Curabitur dictum gravida mauris. Nam arcu libero, nonummy eget, consectetuer
id, vulputate a, magna.

    Second paragraph. Lorem ipsum dolor sit amet, consectetuer adipiscing
    elit. Ut purus elit, vestibulum ut, placerat ac, adipiscing vitae,
    felis. Curabitur dictum gravida mauris. Nam arcu libero, nonummy eget,
    consectetuer id, vulputate a, magna.

* Second item paragraph with a code block. Lorem ipsum dolor sit amet,
consectetuer adipiscing elit. Ut purus elit, vestibulum ut, placerat ac,
adipiscing vitae, felis. Curabitur dictum gravida mauris. Nam arcu libero,
nonummy eget, consectetuer id, vulputate a, magna.

    ~~~
    #include <iostream>
    int main() {
        std::cout << "Hello world!";
        return 0;
    }
    ~~~

As noted above, Markdown allows you to write list items "lazily," instead
of indenting continuation lines. However, if there are multiple paragraphs
or other blocks in a list item, the first line of each must be indented.

    + A lazy, lazy, list
    item.

    + Another one; this looks
    bad but is legal.

        Second paragraph of second
    list item.

**Note:**  Although the four-space rule for continuation paragraphs
comes from the official [Markdown syntax guide], the reference
implementation, `Markdown.pl`, does not follow it. So pandoc will give
different results than `Markdown.pl` when authors have indented
continuation paragraphs fewer than four spaces.

The [Markdown syntax guide] is not explicit whether the four-space
rule applies to *all* block-level content in a list item; it only
mentions paragraphs and code blocks. But it implies that the rule
applies to all block-level content (including nested lists), and
pandoc interprets it that way.

[Markdown syntax guide]: http://daringfireball.net/projects/markdown/syntax#list

## Numbered List

The special list marker `@` can be used for sequentially numbered
examples. The first list item with a `@` marker will be numbered '1',
the next '2', and so on, throughout the document. The numbered examples
need not occur in a single list; each new list using `@` will take up
where the last stopped. So, for example:

(@)  My first example will be numbered (1).
(@)  My second example will be numbered (2).

Explanation of examples.

(@)  My third example will be numbered (3).


Numbered examples can be labeled and referred to elsewhere in the
document:

~~~
(@good)  This is a good example.

As (@good) illustrates, ...
~~~

(@good)  This is a good example.

As (@good) illustrates, ...

## Definition List

Term 1
: First paragraph. Lorem ipsum dolor sit amet, consectetuer adipiscing
  elit. Ut purus elit, vestibulum ut, placerat ac, adipiscing vitae,
  felis. Curabitur dictum gravida mauris.
: Second paragraph. Lorem ipsum dolor sit amet, consectetuer adipiscing
  elit. Ut purus elit, vestibulum ut, placerat ac, adipiscing vitae,
  felis. Curabitur dictum gravida mauris.

    ~~~
    int main() {
        printf("Hello world\n");
    }
    ~~~

: Third paragraph. Lorem ipsum dolor sit amet, consectetuer adipiscing
  elit. Ut purus elit, vestibulum ut, placerat ac, adipiscing vitae,
  felis. Curabitur dictum gravida mauris.

Term 2
~ First paragraph.
~ Second paragraph.

Term 3
  ~ First paragraph.
  ~ Second paragraph.

The definition list above is written in markdown as below. Paragraph
delimiter may be a colon (`:`) or a tilde. The start of the
paragraph delimiter may be indented up to two (2) space characters as
in the _Term 3_ definition.

~~~
Term 1
: First paragraph...
: Second paragraph...

    ~~~
    int main() {
        printf("Hello world\n");
    }
    ~~~

: Third paragraph...

Term 2
~ First paragraph.
~ Second paragraph.

Term 3
  ~ First paragraph.
  ~ Second paragraph.
~~~

## Footnotes

Footnotes are generated using a caret (`^`) followed by an identifier wrapped between square brackets.
Footnote identifiers could be a number or text but may not contain spaces, tabs, or newlines.
Text footnote identifiers are converted to a number and is ordered automatically.

The following markdown shows how to define a footnote reference and its corresponding note.

~~~
At the end of this text is a numbered footnote reference.[^1] Here is a
footnote reference using text for easier reading and referencing.[^longnote]

[^1]: Here is the note.
[^longnote]: Long note with subsequent paragraphs. Subsequent paragraphs are
indented following a blank line to show that they belong to the previous footnote.

    This is the second paragraph for this footnote.
~~~

At the end of this text is a numbered footnote reference.[^1]
footnote reference using text for easier reading and referencing.[^longnote]

[^1]: Here is the note.
[^longnote]: Long note with subsequent paragraphs. Subsequent paragraphs
are indented to show that they belong to the previous footnote.

    This is the second paragraph for this footnote.

### Hyperlinks as Footnotes

Hyperlinks are automatically converted to footnotes. Here is a hyperlink to
John Gruber's [Markdown site](http://daringfireball.net/projects/markdown/).
There is no need to manually define the note as it is automatically generated
from the hyperlink.

~~~
Hyperlinks are automatically converted to footnotes. Here is a hyperlink to
John Gruber's [Markdown site](http://daringfireball.net/projects/markdown/).
There is no need to manually define the note as it is automatically generated
from the hyperlink.
~~~

### Inline Footnotes

Footnotes can also be inlined. Here is an inline note.^[Inlined notes are
easier to write, since you don't have to pick an identifier and move down
to type the note.]

~~~
Footnotes can also be inlined. Here is an inline note.^[Inlined notes are
easier to write, since you don't have to pick an identifier and move down
to type the note.]
~~~

## Table

\lipsum[2]

## Code Blocks

A _code block_ is a block of text treated as verbatim text. Code blocks in
markdown are usually indented by four spaces or one tab character. Code
blocks must be separated from surrounding text by blank lines.

The following code block example is a short C++ program code.

~~~
#include <iostream>
int main() {
    std::cout << "Hello world!";
    return 0;
}
~~~

\noindent It is encoded in markdown like below. Note that the code block is indented.

        #include <iostream>
        int main() {
            std::cout << "Hello world!";
            return 0;
        }

### Fenced Code Blocks

In addition to standard indented code blocks, Pandoc supports *fenced* code
blocks. _Fenced code blocks_ begin with a row of three or more tilde or back
tick characters and end with a row of the same characters that must be at
least as long as the starting row. Everything between these lines is treated
as code. No indentation is necessary.

The example C++ code block above may be written:

    ~~~
    #include <iostream>
    int main() {
        std::cout << "Hello world!";
        return 0;
    }
    ~~~

Like regular code blocks, fenced code blocks must be separated from
the surrounding text by blank lines.
Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Ut purus elit, vestibulum ut, placerat ac, adipiscing vitae, felis. Curabitur dictum gravida mauris.

### Fenced Code Attributes

_Attributes_ may be attached to fenced or backticked code blocks and is
written like the following:

    ~~~{.cpp .numberLines startFrom="800"}
    #include <iostream>
    int main() {
        std::cout << "Hello world!";
        return 0;
    }
    ~~~

\noindent The code above is rendered with syntax highlighted using the C++
syntax and displayed with line numbers starting from 100.

~~~{.cpp .numberLines startFrom="800"}
#include <iostream>
int main() {
    std::cout << "Hello world!";
    return 0;
}
~~~

# TeX/LaTeX

The system configuration.

~~~
/usr/share/texmf
/usr/share/texmf-dist

/var/lib/texmf
~~~

Installed Packages are in: /var/lib/texmf/arch/installedpkgs/*.pkgs

~~~
$ texconfig conf
~~~

Will output, binaries found by search $PATH, active configuration files, font map files and kpathsea variables.

## Manual Installation

You should not manually install files into `/usr/share/texmf-dist/tex/latex/<package name>/*`.
Instead, install local `.sty` files in `TEXMFLOCAL` if they should be available to all users, or into `TEXMFHOME` if they are specific to you.
Use `kpsewhich -var TEXMFLOCAL` to get the local directory and install into `<local directory>/tex/latex/<package name>/`.
The `TEXMFHOME` directory will automatically be searched when TeX tools are executed.
If you use `TEXMFLOCAL`, you need to update the database in order for the files to be found.

### Install .sty Files

TeX Live (and teTeX) uses its own directory indexes (files named ls-R), and you need to refresh them after you copy something into one of the TeX trees or TeX can not see them. The command is `mktexlsr`. The `texhash` command is a symbolic link of `mktexlsr`. The command `texconfig rehash` simply calls `mktexlsr`. The command `texconfig-sys` is a symbolic link that wraps the `texconfig` command.

~~~
$ mktexlsr --help
Usage: mktexlsr [OPTION]... [DIR]...

Rebuild ls-R filename databases used by TeX.  If one or more arguments
DIRS are given, these are used as the directories in which to build
ls-R. Else all directories in the search path for ls-R files
($TEXMFDBS) are used.
~~~

A command line program to search through these indexes is `kpsewhich`.
Hence you can check that TeX can find a particular file by running

~~~
kpsewhich <filename.sty>
~~~

The output should be the full path to that file.

Alternatively, `.sty` files that are intended only for a particular user should go in the `<home>/texmf/` tree.
For instance, the latex package `wrapfig` consists of the file `wrapfig.sty` and would go in `<home>/texmf/tex/latex/wrapfig/wrapfig.sty`.
There is no need to run `mktexlsr` or equivalent because `<home>/texmf` is searched every time `tex` is run.

## Typeface

The default typeface in LaTeX is Computer Modern (CM).
This typeface was designed by Donald Knuth for use with TeX because it is a book face, and he designed TeX originally for typesetting books.
Because it is one of the very few book typefaces with a comprehensive set of fonts, including a full suite of mathematics, it has remained the default.
Until recently, the mathematical symbols for Times in wordprocessors were a commercial product which is often unavailable to users of free software. [^AnIntroductionToTypeSettingWithLatex2011]

The following showcases the current fonts used in this document.

Roman font
: current Roman family is Bitstream Charter (bch).
: \fontfamily{bch}\selectfont Lorem ipsum dolor sit amet, _consectetuer adipiscing elit_. Ut purus elit, vestibulum ut, placerat ac, adipiscing vitae, felis. __Curabitur dictum gravida mauris__. Nam arcu libero, nonummy eget, consectetuer id, vulputate a, magna. Donec vehicula augue eu neque. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas.

\fontfamily{\rmdefault}\selectfont

Sans serif font
: current Sans serif family is Latin Modern Sans Serif (lmss).
: \fontfamily{lmss}\selectfont Lorem ipsum dolor sit amet, _consectetuer adipiscing elit_. Ut purus elit, vestibulum ut, placerat ac, adipiscing vitae, felis. __Curabitur dictum gravida mauris__. Nam arcu libero, nonummy eget, consectetuer id, vulputate a, magna. Donec vehicula augue eu neque. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas.

\fontfamily{\rmdefault}\selectfont

Typewriter font
: current Typewriter font is Inconsolata (zi4).
: \fontfamily{zi4}\selectfont Lorem ipsum dolor sit amet, _consectetuer adipiscing elit_. Ut purus elit, vestibulum ut, placerat ac, adipiscing vitae, felis. __Curabitur dictum gravida mauris__. Nam arcu libero, nonummy eget, consectetuer id, vulputate a, magna. Donec vehicula augue eu neque. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas.

The following commands load the packages and set the default fonts to be used:

~~~
\usepackage{charter}
\usepackage[varl,scaled=1.0]{zi4}

\renewcommand*\rmdefault{bch}
\renewcommand*\sfdefault{cmss}
\renewcommand*\ttdefault{zi4}
~~~

### Serif Fonts

#### Computer Modern Roman (cmr)

\fontfamily{cmr}\selectfont
Lorem ipsum dolor sit amet, _consectetuer adipiscing elit_. Ut purus elit, vestibulum ut, placerat ac, adipiscing vitae, felis. __Curabitur dictum gravida mauris__. Nam arcu libero, nonummy eget, consectetuer id, vulputate a, magna. Donec vehicula augue eu neque. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas.

#### Bitstream Charter

\fontfamily{bch}\selectfont
Bitstream Charter was designed by Matthew Carter for display on low resolution devices, and is useful for many applications, including bookwork.
The fontfamily name is bch.

Lorem ipsum dolor sit amet, _consectetuer adipiscing elit_. Ut purus elit, vestibulum ut, placerat ac, adipiscing vitae, felis. __Curabitur dictum gravida mauris__. Nam arcu libero, nonummy eget, consectetuer id, vulputate a, magna. Donec vehicula augue eu neque. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas.

#### Palatino

\fontfamily{ppl}\selectfont
Palatino was designed by Hermann Zapf and is one of the most popular typefaces today.
The fontfamily name is ppl.

Lorem ipsum dolor sit amet, _consectetuer adipiscing elit_. Ut purus elit, vestibulum ut, placerat ac, adipiscing vitae, felis. __Curabitur dictum gravida mauris__. Nam arcu libero, nonummy eget, consectetuer id, vulputate a, magna. Donec vehicula augue eu neque. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas.

#### Utopia

\fontfamily{put}\selectfont
Utopia was designed by Robert Slimbach and combines Transitional features and contemporary details.
The fontfamily name is put .

Lorem ipsum dolor sit amet, _consectetuer adipiscing elit_. Ut purus elit, vestibulum ut, placerat ac, adipiscing vitae, felis. __Curabitur dictum gravida mauris__. Nam arcu libero, nonummy eget, consectetuer id, vulputate a, magna. Donec vehicula augue eu neque. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas.

#### New Century Schoolbook

\fontfamily{pnc}\selectfont
New Century Schoolbook was designed by Morris Benton for ATF (American Type Founders) in the early 20th century.
As its name implies it was designed for maximum legibility in schoolbooks.
The fontfamily name is pnc.

Lorem ipsum dolor sit amet, _consectetuer adipiscing elit_. Ut purus elit, vestibulum ut, placerat ac, adipiscing vitae, felis. __Curabitur dictum gravida mauris__. Nam arcu libero, nonummy eget, consectetuer id, vulputate a, magna. Donec vehicula augue eu neque. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas.

#### Times Roman

\fontfamily{ptm}\selectfont
Times Roman is Linotype's version of the Times New Roman face designed by Stanley Morison for the Monotype Corporation for printing The Times newspaper.
The fontfamily name is ptm.

Lorem ipsum dolor sit amet, _consectetuer adipiscing elit_. Ut purus elit, vestibulum ut, placerat ac, adipiscing vitae, felis. __Curabitur dictum gravida mauris__. Nam arcu libero, nonummy eget, consectetuer id, vulputate a, magna. Donec vehicula augue eu neque. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas.

#### Nimbus Roman

\fontfamily{unm}\selectfont
Lorem ipsum dolor sit amet, _consectetuer adipiscing elit_. Ut purus elit, vestibulum ut, placerat ac, adipiscing vitae, felis. __Curabitur dictum gravida mauris__. Nam arcu libero, nonummy eget, consectetuer id, vulputate a, magna. Donec vehicula augue eu neque. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas.

#### ITC Bookman

\fontfamily{pbk}\selectfont
ITC Bookman was originally sold in 1860 by the Miller & Richard foundry in Scotland; it was designed by Alexander Phemister.
The ITC revival is by Ed Benguiat.
The fontfamily name is pbk.

Lorem ipsum dolor sit amet, _consectetuer adipiscing elit_. Ut purus elit, vestibulum ut, placerat ac, adipiscing vitae, felis. __Curabitur dictum gravida mauris__. Nam arcu libero, nonummy eget, consectetuer id, vulputate a, magna. Donec vehicula augue eu neque. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas.

#### Pandora

\fontfamily{panr}\selectfont
Lorem ipsum dolor sit amet, _consectetuer adipiscing elit_. Ut purus elit, vestibulum ut, placerat ac, adipiscing vitae, felis. __Curabitur dictum gravida mauris__. Nam arcu libero, nonummy eget, consectetuer id, vulputate a, magna. Donec vehicula augue eu neque. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas.

#### URW Antiqua

\fontfamily{uaq}\selectfont
Lorem ipsum dolor sit amet, _consectetuer adipiscing elit_. Ut purus elit, vestibulum ut, placerat ac, adipiscing vitae, felis. __Curabitur dictum gravida mauris__. Nam arcu libero, nonummy eget, consectetuer id, vulputate a, magna. Donec vehicula augue eu neque. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas.

### Sans Serif Fonts

#### Latin Modern Sans Serif

\fontfamily{lmss}\selectfont
Lorem ipsum dolor sit amet, _consectetuer adipiscing elit_. Ut purus elit, vestibulum ut, placerat ac, adipiscing vitae, felis. __Curabitur dictum gravida mauris__. Nam arcu libero, nonummy eget, consectetuer id, vulputate a, magna. Donec vehicula augue eu neque. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas.

#### Computer Modern Sans Serif (cmss)

\fontfamily{cmss}\selectfont
Lorem ipsum dolor sit amet, _consectetuer adipiscing elit_. Ut purus elit, vestibulum ut, placerat ac, adipiscing vitae, felis. __Curabitur dictum gravida mauris__. Nam arcu libero, nonummy eget, consectetuer id, vulputate a, magna. Donec vehicula augue eu neque. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas.

#### Computer Modern Bright Sans Serif

\fontfamily{cmbr}\selectfont
Lorem ipsum dolor sit amet, _consectetuer adipiscing elit_. Ut purus elit, vestibulum ut, placerat ac, adipiscing vitae, felis. __Curabitur dictum gravida mauris__. Nam arcu libero, nonummy eget, consectetuer id, vulputate a, magna. Donec vehicula augue eu neque. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas.

#### Helvetica

\fontfamily{phv}\selectfont
Helvetica was originally designed for the Haas foundry in Switzerland by Max Miedinger; it was later extended by the Stempel foundry and further refined by Linotype.
The fontfamily name is phv.

Lorem ipsum dolor sit amet, _consectetuer adipiscing elit_. Ut purus elit, vestibulum ut, placerat ac, adipiscing vitae, felis. __Curabitur dictum gravida mauris__. Nam arcu libero, nonummy eget, consectetuer id, vulputate a, magna. Donec vehicula augue eu neque. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas.

#### Bera Sans

\fontfamily{fvs}\selectfont
Lorem ipsum dolor sit amet, _consectetuer adipiscing elit_. Ut purus elit, vestibulum ut, placerat ac, adipiscing vitae, felis. __Curabitur dictum gravida mauris__. Nam arcu libero, nonummy eget, consectetuer id, vulputate a, magna. Donec vehicula augue eu neque. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas.

#### Iwona

\fontfamily{iwona}\selectfont
Lorem ipsum dolor sit amet, _consectetuer adipiscing elit_. Ut purus elit, vestibulum ut, placerat ac, adipiscing vitae, felis. __Curabitur dictum gravida mauris__. Nam arcu libero, nonummy eget, consectetuer id, vulputate a, magna. Donec vehicula augue eu neque. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas.

#### Kurier

\fontfamily{kurier}\selectfont
Lorem ipsum dolor sit amet, _consectetuer adipiscing elit_. Ut purus elit, vestibulum ut, placerat ac, adipiscing vitae, felis. __Curabitur dictum gravida mauris__. Nam arcu libero, nonummy eget, consectetuer id, vulputate a, magna. Donec vehicula augue eu neque. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas.

### Typewriter Fonts

#### Computer Modern Typewriter (cmtt)

\fontfamily{cmtt}\selectfont
Lorem ipsum dolor sit amet, _consectetuer adipiscing elit_. Ut purus elit, vestibulum ut, placerat ac, adipiscing vitae, felis. __Curabitur dictum gravida mauris__. Nam arcu libero, nonummy eget, consectetuer id, vulputate a, magna. Donec vehicula augue eu neque. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas.

\noindent 12345678901234567890123456789012345678901234567890123456789012345678901234567890

#### Courier

\fontfamily{pcr}\selectfont
Courier is a monospaced font that was originally designed by Howard Kettler at IBM and then later redrawn by Adrian Frutiger.
The fontfamily name is pcr .

Lorem ipsum dolor sit amet, _consectetuer adipiscing elit_. Ut purus elit, vestibulum ut, placerat ac, adipiscing vitae, felis. __Curabitur dictum gravida mauris__. Nam arcu libero, nonummy eget, consectetuer id, vulputate a, magna. Donec vehicula augue eu neque. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas.

\noindent 12345678901234567890123456789012345678901234567890123456789012345678901234567890

#### Bera Mono

\fontfamily{fvm}\selectfont
Lorem ipsum dolor sit amet, _consectetuer adipiscing elit_. Ut purus elit, vestibulum ut, placerat ac, adipiscing vitae, felis. __Curabitur dictum gravida mauris__. Nam arcu libero, nonummy eget, consectetuer id, vulputate a, magna. Donec vehicula augue eu neque. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas.

\noindent 12345678901234567890123456789012345678901234567890123456789012345678901234567890

#### Inconsolata

\fontfamily{zi4}\selectfont
Lorem ipsum dolor sit amet, _consectetuer adipiscing elit_. Ut purus elit, vestibulum ut, placerat ac, adipiscing vitae, felis. __Curabitur dictum gravida mauris__. Nam arcu libero, nonummy eget, consectetuer id, vulputate a, magna. Donec vehicula augue eu neque. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas.

\noindent 12345678901234567890123456789012345678901234567890123456789012345678901234567890

#### Latin Modern

\fontfamily{lmtt}\selectfont
Lorem ipsum dolor sit amet, _consectetuer adipiscing elit_. Ut purus elit, vestibulum ut, placerat ac, adipiscing vitae, felis. __Curabitur dictum gravida mauris__. Nam arcu libero, nonummy eget, consectetuer id, vulputate a, magna. Donec vehicula augue eu neque. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas.

\noindent 12345678901234567890123456789012345678901234567890123456789012345678901234567890

[^AnIntroductionToTypeSettingWithLatex2011]: An Introduction to TypeSetting with Latex, 2011

\appendix

# Files

## Markdown File

## Latex Template

Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Ut purus elit, vestibulum ut, placerat ac, adipiscing vitae, felis. Curabitur dictum gravida mauris. Nam arcu libero, nonummy eget, consectetuer id, vulputate a, magna. Donec vehicula augue eu neque. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Mauris ut leo. Cras viverra metus rhoncus sem. Nulla et lectus vestibulum urna fringilla ultrices. Phasellus eu tellus sit amet tortor gravida placerat. Integer sapien est, iaculis in, pretium quis, viverra ac, nunc. Praesent eget sem vel leo ultrices bibendum. Aenean faucibus. Morbi dolor nulla, malesuada eu, pulvinar at, mollis ac, nulla. Curabitur auctor semper nulla. Donec varius orci eget risus. Duis nibh mi, congue eu, accumsan eleifend, sagittis quis, diam. Duis eget orci sit amet orci dignissim rutrum.

## Build Script

~~~
#!/bin/bash
if [ "$1" = "--help" ]; then
    echo "build_a4 <input> <template> <output>"
    exit
fi
inputfile=${1:-"test.md"}"
template=${2:-"test_book_a4.tex"}
outputfile=${3:-"output_a4.pdf"}
pandoc ${inputfile}                    \
       --template=${template}          \
       -f markdown+raw_tex+footnotes   \
       -t latex                        \
       -o ${outputfile}                \
       --pdf-engine=xelatex            \
       --toc                           \
       --top-level-division=chapter
~~~
