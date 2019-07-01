md-to-pdf
=========

Script for converting markdown files to PDF using a generic preprocessor `pp` and `LaTeX`.

The generic preprocessor `pp` is a "text preprocessor design for Pandoc (and more generally Markdown and reStructuredText)".
For more information on `pp` visit [https://github.com/CDSoft/pp](https://github.com/CDSoft/pp).

## YAML Metadata

The following is an example of a YAML metadata put in a separate file named `metadata.md`.

~~~
title: Title
subtitle: |
    | Subtitle
    |
client: Client Name
author: Author Single
email: email@address.com
version: Version 0.1.0
date: December 2017
distribution: |
    | Private; distribution limited to company use only.
    |
    | For private use; distribution limited to executive level only.
    | This is an optional second line.
    | Approved for public release and unlimited distribution.
    |
copyright: Copyright \textcopyright\space2017 [company]
licenseimage: cc_by_nc_sa_40.eps
license: CC BY-NC-SA 4.0

licensetext: This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License (CC BY-NC-SA 4.0). You are free to copy, reproduce, distribute, display, and make adaptations of this work for non-commercial purposes provided that you give appropriate credit. To view a copy of this license, visit [http://creativecommons.org/licenses/by-nc-sa/4.0/legalcode](http://creativecommons.org/licenses/by-nc-sa/4.0/legalcode).

license_attribution: "Please cite the work as follows: [company]. [year]. [title]: [subtitle]. License: Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License CC BY-NC-SA 4.0."

license_translations: "If you create a translation of this work, please add the following disclaimer along with the attribution: This translation was not created by Codespheare. The original authors shall not be liable for any content or error in this translation."

license_adaptations: "If you create an adaptation of this work, please add the following disclaimer along with the attribution: This is an adaptation of an original work by [company]. Views and opinions expressed in the adaptation are the sole responsibility of the author or authors of the adaptation and are not endorsed by the original authors."

licenselink: "http://creativecommons.org/licenses/by-nc-sa/4.0/](http://creativecommons.org/licenses/by-nc-sa/4.0/"
source: The source is available at [link name](url).
dedication: |
    | Dedication here.
    | If the dedication page is not necessary, rename or delete the key from the source YAML information.
    |
~~~

Documents with multiple authors are defined as follows:

~~~
author:
  - name: Author One
    email: email@address.com
  - name: Author Two
    email: email@address.com
~~~

## Document Contents

Document contents may be put into a single file or multiple files.
Putting the chapter number as prefix to the chapter name helps reflect the document structure in the filesystem.
