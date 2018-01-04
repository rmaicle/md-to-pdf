---
title: Markdown to PDF
subtitle: |
    | Using Pandoc and LaTeX
    |
secondsubtitle:
client:
author: Ricardo Maicle
email: rmaicle@gmail.com
version: Version 0.1.0
date: December 2017
copyrightyear: 2017
license: CC BY-NC-SA
licensetext: This work is licensed under the Creative Commons Attribution-NonCommercial- ShareAlike 4.0 International License (CC BY-NC-SA). You are free to copy, reproduce, distribute, display, and make adaptations but you must provide proper attribution. (Fix CC License) To view a copy of this license, visit [http://creativecommons.org/licenses/by-nc-sa/4.0/](http://creativecommons.org/licenses/by-nc-sa/4.0/).
licenselink: "http://creativecommons.org/licenses/by-nc-sa/4.0/](http://creativecommons.org/licenses/by-nc-sa/4.0/"
source: The source is available at [https://www.github.com/rmaicle/mdtopdf](https://www.github.com/rmaicle/mdtopdf)
---

# Introduction

\begin{quotation}\flushright\normalfont\itshape
Now is the time to talk about many things.\\
\sourceatright{-- Anonymous}
\end{quotation}
\vspace{1in}

\noindent This booklet describes the conversion of markdown files to `.pdf` files.

\index{Pandoc}

__Pandoc__ [^Pandoc] is a \index{tool} written in Haskell[^Haskell] by John MacFarlane since 2006 for converting from one markup format to another.
Pandoc understands an extended and slightly revised version of John Gruber's [Markdown] syntax. 
These extensions and revisions are necessary to provide multiple output formats aimed by Pandoc's design.
    
__TeX__ [^TeX] is a typesetting program, originally written by Donald Knuth at Stanford University in 1978--1979.
"_TeX [is] a new typesetting system intended for the creation of beautiful books--and especially for books that contain a lot of mathematics.
By preparing a manuscript in TeX format, you will be telling a computer exactly how the manuscript is to be transformed into pages whose
typographic quality is comparable to that of the world's finest printers._" [^TeXbook]

__LaTeX__ [^LaTeX] is a user interface for TeX providing a simpler way of using the power of TeX without diving into the language details.
It was designed by Leslie Lamport at Digital Equipment Corporation (DEC) in 1985 to automate all the common tasks of document preparation.

__Markdown__ [^Markdown][^Test] is a plain text format for writing structured documents based on conventions.
It was developed by John Gruber (with help from Aaron Swartz) and released in 2004.
Gruber wrote in his website: "_The overriding design goal for Markdown's formatting syntax is to make it as readable as possible.
The idea is that a Markdown-formatted document should be publishable as-is, as plain text, without looking like it's been marked up with tags or formatting instructions._"

[^Pandoc]: http://pandoc.org
[^TeX]: Add `todo` here.
[^LaTeX]: Add `todo` here.
[^Haskell]: https://www.haskell.org
[^TeXbook]: Donald E. Knuth. The TeXbook, Volume A of Computers and Typesetting.
Addison-Wesley, Reading, MA, USA, 1986. ISBN 0-201-13447-0.
The definitive user's guide and complete reference manual for TeX.
[^Markdown]: http://daringfireball.net/projects/markdown/
[^Test]: This is a footnote series test.

# Pandoc and Markdown

## YAML Metadata

Create a two-line title by using the YAML[^YAML] block literal character `|`.
The YAML metadata should be declared exactly like the following:

    title: | 
      | Title on First Line
      | Title on Second Line
      |

Block notation using the pipe character `|` treats each newline literally.
The extra pipe character at the end is sometimes necessary so LaTeX will space the last line vertically equal with the previous lines.

It can also be used when a subtitle is present to add vertical space between the title and the subtitle.

    title: This is the Title
    subtitle: |
      | This is the Subtitle
      |

Multiple authors are defined like the following:

    author:
      - Author One
      - Author Two
      
[^YAML]: This is a footnote.
    
## Paragraph

To continue a paragraph after a fenced code block or a list, use `\noindent` at the beginning of the text.
The command instructs the `LaTeX` engine not to indent the text.

    \noindent Paragraph continuation...

## Quote Block

Markdown uses email conventions for quoting blocks of text.
A block quotation is one or more paragraphs or other block elements
(such as lists or headers), with each line preceded by a `>` character
and an optional space. (The `>` need not start at the left margin, but
it should not be indented more than three spaces.)

    > This is a block quote. This
    > paragraph has two lines.
    >
    > 1. This is a list inside a block quote.
    > 2. Second item.

A "lazy" form, which requires the `>` character only on the first
line of each block, is also allowed:

    > This is a block quote. This
    paragraph has two lines.

    > 1. This is a list inside a block quote.
    2. Second item.

Among the block elements that can be contained in a block quote are
other block quotes. That is, block quotes can be nested:

    > This is a block quote.
    >
    > > A block quote within a block quote.

If the `>` character is followed by an optional space, that space
will be considered part of the block quote marker and not part of
the indentation of the contents.  Thus, to put an indented code
block in a block quote, you need five spaces after the `>`:

    >     code

## Bullet List

A bullet list is a list of items beginning with an asterisk (`*`), a plus (`+`) or a hyphen (`-`).
Bullet lists may be nested by indenting the inner lists using four spaces or one tab character.

    * List item one
        * Nested list one
        * Nested list two
        * Nested list three
    * List item two
        - Nested list one
        - Nested list two
            - More nested list one
            - More nested list two
                - Third nested list one
                - Third nested list two
        - Nested list three
    * List item three
        + Nested list one
        + Nested list two
        + Nested list three
    
* List item one
    * Nested list one
    * Nested list two
    * Nested list three
* List item two
    - Nested list one
    - Nested list two
        - More nested list one
        - More nested list two
            - Third nested list one
            - Third nested list two
    - Nested list three
* List item three
    + Nested list one
    + Nested list two
    + Nested list three

This will produce a "compact" list. If you want a "loose" list, in which
each item is formatted as a paragraph, put spaces between the items:

    * one

    * two

    * three

The bullets need not be flush with the left margin; they may be
indented one, two, or three spaces. The bullet must be followed
by whitespace.

List items look best if subsequent lines are flush with the first
line (after the bullet):

    * here is my first
      list item.
    * and my second.

But Markdown also allows a "lazy" format:

    * here is my first
    list item.
    * and my second.

### The four-space rule ###

A list item may contain multiple paragraphs and other block-level
content. However, subsequent paragraphs must be preceded by a blank line
and indented four spaces or a tab. The list will look better if the first
paragraph is aligned with the rest:

      * First paragraph.

        Continued.

      * Second paragraph. With a code block, which must be indented
        eight spaces:

            { code }

List items may include other lists.  In this case the preceding blank
line is optional.  The nested list must be indented four spaces or
one tab:

    * fruits
        + apples
            - macintosh
            - red delicious
        + pears
        + peaches
    * vegetables
        + broccoli
        + chard

As noted above, Markdown allows you to write list items "lazily," instead of
indenting continuation lines. However, if there are multiple paragraphs or
other blocks in a list item, the first line of each must be indented.

    + A lazy, lazy, list
    item.

    + Another one; this looks
    bad but is legal.

        Second paragraph of second
    list item.

**Note:**  Although the four-space rule for continuation paragraphs
comes from the official [Markdown syntax guide], the reference implementation,
`Markdown.pl`, does not follow it. So pandoc will give different results than
`Markdown.pl` when authors have indented continuation paragraphs fewer than
four spaces.

The [Markdown syntax guide] is not explicit whether the four-space
rule applies to *all* block-level content in a list item; it only
mentions paragraphs and code blocks.  But it implies that the rule
applies to all block-level content (including nested lists), and
pandoc interprets it that way.

  [Markdown syntax guide]:
    http://daringfireball.net/projects/markdown/syntax#list

\lipsum[2]

    +   First
    +   Second:
        -   Fee
        -   Fie
        -   Foe

    +   Third

+   First
+   Second:
    -   Fee
    -   Fie
    -   Foe

+   Third

## Definition List

Term 1
: Lorem ipsum dolor sit amet, consectetuer adipiscing elit.
  Ut purus elit, vestibulum ut, placerat ac, adipiscing vitae, felis.
  Curabitur dictum gravida mauris. Nam arcu libero, nonummy eget, 
  consectetuer id, vulputate a, magna.
: Donec vehicula augue eu neque.

        int main() {
            printf("Hello world\n");
        }
        
: Pellentesque habitant morbi tristique senectus et netus et malesuada
  fames ac turpis egestas.

Term 2
: Lorem ipsum dolor sit amet, consectetuer adipiscing elit.
  Ut purus elit, vestibulum ut, placerat ac, adipiscing vitae, felis.
  Curabitur dictum gravida mauris. Nam arcu libero, nonummy eget, 
  consectetuer id, vulputate a, magna.

: Donec vehicula augue eu neque.
  Pellentesque habitant morbi tristique senectus et netus et malesuada
  fames ac turpis egestas.
        
\lipsum[2]

Term 1
  ~ Lorem ipsum dolor sit amet, consectetuer adipiscing elit.
  Ut purus elit, vestibulum ut, placerat ac, adipiscing vitae, felis.
  Curabitur dictum gravida mauris. Nam arcu libero, nonummy eget, 
  consectetuer id, vulputate a, magna.
  
  ~ Donec vehicula augue eu neque.
  
  ~ Pellentesque habitant morbi tristique senectus et netus et malesuada
  fames ac turpis egestas.

Term 2
  ~ Lorem ipsum dolor sit amet, consectetuer adipiscing elit.
  Ut purus elit, vestibulum ut, placerat ac, adipiscing vitae, felis.
  Curabitur dictum gravida mauris. Nam arcu libero, nonummy eget, 
  consectetuer id, vulputate a, magna.
  Donec vehicula augue eu neque.
  Pellentesque habitant morbi tristique senectus et netus et malesuada
  fames ac turpis egestas.

  ~ Lorem ipsum dolor sit amet, consectetuer adipiscing elit.
  Ut purus elit, vestibulum ut, placerat ac, adipiscing vitae, felis.
  Curabitur dictum gravida mauris. Nam arcu libero, nonummy eget, 
  consectetuer id, vulputate a, magna.
  Donec vehicula augue eu neque.
  Pellentesque habitant morbi tristique senectus et netus et malesuada
  fames ac turpis egestas.

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

    (@good)  This is a good example.

    As (@good) illustrates, ...
    
(@good)  This is a good example.

As (@good) illustrates, ...

## Footnotes

Lorem ipsum dolor sit amet[^footnote1], consectetur adipiscing elit. Curabitur pretium, nisi eget vulputate hendrerit, est felis volutpat ante, et condimentum leo enim quis est. In pretium libero ex, ut fringilla nisl convallis ac. Proin cursus suscipit lectus non bibendum. Vestibulum in ultrices lorem, vel placerat massa. Integer pulvinar felis quis lacus ultrices egestas non nec tortor. Donec molestie velit eget ante consequat molestie.[^footnote2] Nullam interdum scelerisque arcu vitae rutrum.

[^footnote1]: First footnote.
[^footnote2]: Second footnote.

## Inline footnotes

Here is an inline note.^[Inlined notes are easier to write, since you don't have to pick an identifier and move down to type the note.
https://github.com. This provision is sometimes called the "as-if" rule, because an implementation is free to disregard any requirement of this
International Standard as long as the result is as if the requirement had been obeyed, as far as can be determined from the
observable behavior of the program. For instance, an actual implementation need not evaluate part of an expression if it can
deduce that its value is not used and that no side effects affecting the observable behavior of the program are produced.]

\lipsum[1]

## Table

\lipsum[2]

## Code Blocks

The following description was taken from Pandoc's manual.

Pandoc understands an extended and slightly revised version of John Gruber's Markdown syntax.
This is somewhat expected since Markdown was originally designed with HTML generation in mind while pandoc is designed for multiple output formats.

Number of characters that could fit in one line using a monospace font.

    1234567890123456789012345678901234567890123456789012345678901234567890123456
             1         2         3         4         5         6         7

### Extension: `fenced_code_blocks` ####

In addition to standard indented code blocks, pandoc supports
*fenced* code blocks.  These begin with a row of three or more
tildes (`~`) and end with a row of tildes that must be at least as long as
the starting row. Everything between these lines is treated as code. No
indentation is necessary:

    ~~~~~~~
    if (a > 3) {
      moveShip(5 * gravity, DOWN);
    }
    ~~~~~~~

Like regular code blocks, fenced code blocks must be separated
from surrounding text by blank lines.

### Extension: `fenced_code_attributes`

_Attributes_ may be attached to fenced or backticked code blocks.

    ~~~{#mycode .haskell .numberLines startFrom="100"}
    qsort []     = []
    qsort (x:xs) = qsort (filter (< x) xs) ++ [x] ++
                   qsort (filter (>= x) xs)
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
~~~{#mycode .haskell .numberLines startFrom="100"}
qsort []     = []
qsort (x:xs) = qsort (filter (< x) xs) ++ [x] ++
               qsort (filter (>= x) xs)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Here `mycode` is an identifier, `haskell` and `numberLines` are classes, and
`startFrom` is an attribute with value `100`. Some output formats can use this
information to do syntax highlighting. Currently, the only output formats
that uses this information are HTML, LaTeX, Docx, and Ms. If highlighting
is supported for your output format and language, then the code block above
will appear highlighted, with numbered lines. (To see which languages are
supported, type `pandoc --list-highlight-languages`.) Otherwise, the code
block above will appear as follows:

    <pre id="mycode" class="haskell numberLines" startFrom="100">
      <code>
      ...
      </code>
    </pre>

A shortcut form can also be used for specifying the language of
the code block:

    ~~~haskell
    qsort [] = []
    ~~~

This is equivalent to:

    ~~~{.haskell}
    qsort [] = []
    ~~~

If the `fenced_code_attributes` extension is disabled, but
input contains class attribute(s) for the code block, the first
class attribute will be printed after the opening fence as a bare
word.

To prevent all highlighting, use the `--no-highlight` flag.
To set the highlighting style, use `--highlight-style`.
For more information on highlighting, see [Syntax highlighting] in the Pandoc manual.

\lipsum[1]

~~~{.cpp}
class var {
private:
    size_t index;
    static vector<double>  v_dec;
    static vector<string>  v_str;
public:
    var(bool v) :          index(v) { }
    var(size_t v) :        index(v) { }
    var(double v) :        index(v_dec.size()) { v_dec.push_back(v); }
    var(const string &v) : index(v_str.size()) { v_str.push_back(v); }
};
~~~

Here is another source code block example.

    class A {
    public:
        A() { }
        ~A() { }
    }
    int main() {
        constexpr const char * number { "0123456789" };
        std::cout << number << \'\n\';
        return 0;
    }

## Quote Blocks

\index{Quote blocks}
Quote blocks can be created like the following:

    > This is a quote block
    > in multiple lines.
    
> This is a quote block
> in multiple lines.

Quote blocks can also be created lazily like the following:

    > This is a quote block
    in multiple lines.
    
> This is a quote block
in multiple lines.

\begin{quotation}
This is a quotation.
\end{quotation}

## Chapter Epigraph

Quotation on every chapter at the upper right below the chapter title.
Provide the `text` and `author`.
It is necessary to add `\noindent` on the succeeding paragraph so it flushes the first line of the paragraph to the left which is the default for Anglo-American publishers. [^AngloAmericanPublishers]

    \begin{quotation}\flushright\normalfont\itshape
    <text>\\
    \sourceatright{-- <author>}
    \end{quotation}
    \vspace{1in}
    
    \noindent <Paragraph text...>

[^AngloAmericanPublishers]: LaTeX Wikibooks, June 2016, Chapter 7 Paragraph Formatting, p. 77.

# TeX/LaTeX

The system configuration.

    /usr/share/texmf
    /usr/share/texmf-dist

    /var/lib/texmf

Installed Packages are in: /var/lib/texmf/arch/installedpkgs/*.pkgs

    $ texconfig conf
    
Will output, binaries found by search $PATH, active configuration files, font map files and kpathsea variables.

## Manual Installation

You should not manually install files into `/usr/share/texmf-dist/tex/latex/<package name>/*`.
Instead, install local `.sty` files in `TEXMFLOCAL` if they should be available to all users, or into `TEXMFHOME` if they are specific to you.
Use `kpsewhich -var TEXMFLOCAL` to get the local directory and install into `<local directory>/tex/latex/<package name>/`.
The `TEXMFHOME` directory will automatically be searched when TeX tools are executed.
If you use `TEXMFLOCAL`, you need to update the database in order for the files to be found.

### Install .sty Files

TeX Live (and teTeX) uses its own directory indexes (files named ls-R), and you need to refresh them after you copy something into one of the TeX trees or TeX can not see them. The command is `mktexlsr`. The `texhash` command is a symbolic link of `mktexlsr`. The command `texconfig rehash` simply calls `mktexlsr`. The command `texconfig-sys` is a symbolic link that wraps the `texconfig` command.

    $ mktexlsr --help
    Usage: mktexlsr [OPTION]... [DIR]...

    Rebuild ls-R filename databases used by TeX.  If one or more arguments
    DIRS are given, these are used as the directories in which to build
    ls-R. Else all directories in the search path for ls-R files
    ($TEXMFDBS) are used.
    
A command line program to search through these indexes is `kpsewhich`.
Hence you can check that TeX can find a particular file by running

    kpsewhich <filename.sty>
    
The output should be the full path to that file.

Alternatively, `.sty` files that are intended only for a particular user should go in the `~/texmf/` tree.
For instance, the latex package `wrapfig` consists of the file `wrapfig.sty` and would go in `~/texmf/tex/latex/wrapfig/wrapfig.sty`.
There is no need to run `mktexlsr` or equivalent because `~/texmf` is searched every time `tex` is run.

## Typeface

The default typeface in LaTeX is Computer Modern (CM).
This typeface was designed by Donald Knuth for use with TeX because it is a book face, and he designed TeX originally for typesetting books.
Because it is one of the very few book typefaces with a comprehensive set of fonts, including a full suite of mathematics, it has remained the default.
Until recently, the mathematical symbols for Times in wordprocessors were a commercial product which is often unavailable to users of free software. [^AnIntroductionToTypeSettingWithLatex2011]

Charter serif font.
Uses Latin Modern sans serif and typewriter fonts.
Lorem ipsum dolor sit amet, consectetur adipiscing elit.
Curabitur pretium, nisi eget vulputate hendrerit, est felis volutpat ante, et condimentum leo enim quis est.
In pretium libero ex, ut fringilla nisl convallis ac.
Proin cursus suscipit lectus non bibendum.
Vestibulum in ultrices lorem, vel placerat massa.
Integer pulvinar felis quis lacus ultrices egestas non nec tortor.

    \usepackage{charter}
    \renewcommand*\sfdefault{lmss}  % Latin Modern Sans Serif
    \renewcommand*\ttdefault{lmtt}  % Latin Modern Typewriter

### Serif Fonts

#### Computer Modern Roman (cmr)

\fontfamily{cmr}\selectfont
Lorem ipsum dolor sit amet, _consectetuer adipiscing elit_. Ut purus elit, vestibulum ut, placerat ac, adipiscing vitae, felis. __Curabitur dictum gravida mauris__. Nam arcu libero, nonummy eget, consectetuer id, vulputate a, magna. Donec vehicula augue eu neque. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas.

#### Bookman

\fontfamily{pbk}\selectfont
Lorem ipsum dolor sit amet, _consectetuer adipiscing elit_. Ut purus elit, vestibulum ut, placerat ac, adipiscing vitae, felis. __Curabitur dictum gravida mauris__. Nam arcu libero, nonummy eget, consectetuer id, vulputate a, magna. Donec vehicula augue eu neque. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas.

#### Charter

\fontfamily{bch}\selectfont
Lorem ipsum dolor sit amet, _consectetuer adipiscing elit_. Ut purus elit, vestibulum ut, placerat ac, adipiscing vitae, felis. __Curabitur dictum gravida mauris__. Nam arcu libero, nonummy eget, consectetuer id, vulputate a, magna. Donec vehicula augue eu neque. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas.

#### New Century Schoolbook

\fontfamily{pnc}\selectfont
Lorem ipsum dolor sit amet, _consectetuer adipiscing elit_. Ut purus elit, vestibulum ut, placerat ac, adipiscing vitae, felis. __Curabitur dictum gravida mauris__. Nam arcu libero, nonummy eget, consectetuer id, vulputate a, magna. Donec vehicula augue eu neque. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas.

#### Nimbus Roman

\fontfamily{unm}\selectfont
Lorem ipsum dolor sit amet, _consectetuer adipiscing elit_. Ut purus elit, vestibulum ut, placerat ac, adipiscing vitae, felis. __Curabitur dictum gravida mauris__. Nam arcu libero, nonummy eget, consectetuer id, vulputate a, magna. Donec vehicula augue eu neque. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas.

#### Palatino

\fontfamily{ppl}\selectfont
Lorem ipsum dolor sit amet, _consectetuer adipiscing elit_. Ut purus elit, vestibulum ut, placerat ac, adipiscing vitae, felis. __Curabitur dictum gravida mauris__. Nam arcu libero, nonummy eget, consectetuer id, vulputate a, magna. Donec vehicula augue eu neque. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas.

#### Pandora

\fontfamily{panr}\selectfont
Lorem ipsum dolor sit amet, _consectetuer adipiscing elit_. Ut purus elit, vestibulum ut, placerat ac, adipiscing vitae, felis. __Curabitur dictum gravida mauris__. Nam arcu libero, nonummy eget, consectetuer id, vulputate a, magna. Donec vehicula augue eu neque. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas.

#### URW Antiqua

\fontfamily{uaq}\selectfont
Lorem ipsum dolor sit amet, _consectetuer adipiscing elit_. Ut purus elit, vestibulum ut, placerat ac, adipiscing vitae, felis. __Curabitur dictum gravida mauris__. Nam arcu libero, nonummy eget, consectetuer id, vulputate a, magna. Donec vehicula augue eu neque. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas.

### Sans Serif Fonts

#### Computer Modern Sans Serif (cmss)

\fontfamily{cmss}\selectfont
Lorem ipsum dolor sit amet, _consectetuer adipiscing elit_. Ut purus elit, vestibulum ut, placerat ac, adipiscing vitae, felis. __Curabitur dictum gravida mauris__. Nam arcu libero, nonummy eget, consectetuer id, vulputate a, magna. Donec vehicula augue eu neque. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas.

#### Computer Modern Bright Sans Serif

\fontfamily{cmbr}\selectfont
Lorem ipsum dolor sit amet, _consectetuer adipiscing elit_. Ut purus elit, vestibulum ut, placerat ac, adipiscing vitae, felis. __Curabitur dictum gravida mauris__. Nam arcu libero, nonummy eget, consectetuer id, vulputate a, magna. Donec vehicula augue eu neque. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas.

#### Helvetica

\fontfamily{phv}\selectfont
Lorem ipsum dolor sit amet, _consectetuer adipiscing elit_. Ut purus elit, vestibulum ut, placerat ac, adipiscing vitae, felis. __Curabitur dictum gravida mauris__. Nam arcu libero, nonummy eget, consectetuer id, vulputate a, magna. Donec vehicula augue eu neque. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas.

#### Iwona

\fontfamily{iwona}\selectfont
Lorem ipsum dolor sit amet, _consectetuer adipiscing elit_. Ut purus elit, vestibulum ut, placerat ac, adipiscing vitae, felis. __Curabitur dictum gravida mauris__. Nam arcu libero, nonummy eget, consectetuer id, vulputate a, magna. Donec vehicula augue eu neque. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas.

#### Kurier

\fontfamily{kurier}\selectfont
Lorem ipsum dolor sit amet, _consectetuer adipiscing elit_. Ut purus elit, vestibulum ut, placerat ac, adipiscing vitae, felis. __Curabitur dictum gravida mauris__. Nam arcu libero, nonummy eget, consectetuer id, vulputate a, magna. Donec vehicula augue eu neque. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas.

#### Latin Modern Sans Serif

\fontfamily{lmss}\selectfont
Lorem ipsum dolor sit amet, _consectetuer adipiscing elit_. Ut purus elit, vestibulum ut, placerat ac, adipiscing vitae, felis. __Curabitur dictum gravida mauris__. Nam arcu libero, nonummy eget, consectetuer id, vulputate a, magna. Donec vehicula augue eu neque. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas.

### Typewriter Fonts

#### Computer Modern Typewriter (cmtt)

\fontfamily{cmtt}\selectfont
Lorem ipsum dolor sit amet, _consectetuer adipiscing elit_. Ut purus elit, vestibulum ut, placerat ac, adipiscing vitae, felis. __Curabitur dictum gravida mauris__. Nam arcu libero, nonummy eget, consectetuer id, vulputate a, magna. Donec vehicula augue eu neque. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas.

O0123456789 ~()<>;

#### Bera Mono

\fontfamily{fvm}\selectfont
Lorem ipsum dolor sit amet, _consectetuer adipiscing elit_. Ut purus elit, vestibulum ut, placerat ac, adipiscing vitae, felis. __Curabitur dictum gravida mauris__. Nam arcu libero, nonummy eget, consectetuer id, vulputate a, magna. Donec vehicula augue eu neque. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas.

O0123456789 ~()<>;

#### Courier

\fontfamily{pcr}\selectfont
Lorem ipsum dolor sit amet, _consectetuer adipiscing elit_. Ut purus elit, vestibulum ut, placerat ac, adipiscing vitae, felis. __Curabitur dictum gravida mauris__. Nam arcu libero, nonummy eget, consectetuer id, vulputate a, magna. Donec vehicula augue eu neque. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas.

O0123456789 ~()<>;

#### Inconsolata

\fontfamily{zi4}\selectfont
Lorem ipsum dolor sit amet, _consectetuer adipiscing elit_. Ut purus elit, vestibulum ut, placerat ac, adipiscing vitae, felis. __Curabitur dictum gravida mauris__. Nam arcu libero, nonummy eget, consectetuer id, vulputate a, magna. Donec vehicula augue eu neque. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas.

O0123456789 ~()<>;

#### Latin Modern

\fontfamily{lmtt}\selectfont
Lorem ipsum dolor sit amet, _consectetuer adipiscing elit_. Ut purus elit, vestibulum ut, placerat ac, adipiscing vitae, felis. __Curabitur dictum gravida mauris__. Nam arcu libero, nonummy eget, consectetuer id, vulputate a, magna. Donec vehicula augue eu neque. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas.

O0123456789 ~()<>;

#### anttlc

\fontfamily{anttlc}\selectfont
Lorem ipsum dolor sit amet, _consectetuer adipiscing elit_. Ut purus elit, vestibulum ut, placerat ac, adipiscing vitae, felis. __Curabitur dictum gravida mauris__. Nam arcu libero, nonummy eget, consectetuer id, vulputate a, magna. Donec vehicula augue eu neque. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas.

O0123456789 ~()<>;

\fontfamily{bch}\selectfont

[^AnIntroductionToTypeSettingWithLatex2011]: An Introduction to TypeSetting with Latex, 2011

\appendix

# Files

## Markdown File

## Latex Template

\lipsum

## Build Script

    #!/bin/bash
    if [ "$1" = "--help" ]; then
        echo "build_a4 <input> <template> <output>"
        exit
    fi
    inputfile=${1:-"source.md"}"
    template=${2:-"book_a4.tex"}
    outputfile=${3:-"output_a4.pdf"}
    pandoc ${inputfile}                    \
           --template=${template}          \
           -f markdown+raw_tex+footnotes   \
           -t latex                        \
           -o ${outputfile}                \
           --pdf-engine=xelatex            \
           --toc                           \
           --top-level-division=chapter
