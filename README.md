![Unsupported](https://img.shields.io/badge/development_status-in_progress-green.svg) ![License GPLv3](https://img.shields.io/badge/license-GPLv3-green.svg)


bargraph.sh
====

This script is used for creating a bargraph listing from all the
extensions contained in a dir.<br>


Usage
----

![bargraph-gif](bargraph.gif)

<pre><code>

NAME
    bargraph.sh - show bar graphs of dir file types

SYNOPSIS
    bargraph.sh [OPTION]...

DESCRIPTION
    This script shows a bar graph with the total count
    of files in a dir according to extension.

    -b [character]
            This is to specify what character you want to use to
            draw your bar graphs. If this option is used, place
            the character in quotes (ex: "#").
            Default is "#"

    -d [path]
            This is to specify the path to be used. Need to input
            this for the script to work.

    -e [ext{,ext,ext}]
            This option is to select a single or list of extensions
            to show in the bargraph.
            Usage is either { -e "foo" } for single extension or
            { -e "foo,bar,baz" } for multiple. Always comma separated.

    -h      Show this file (usage).

    -r      Recursive.

    -s      This sorts output according to most files.
            Default is sorted by name.

</code></pre>

Requirements
----

- Bash (https://www.gnu.org/software/bash/)
- GNU Awk (https://www.gnu.org/software/gawk/)
- GNU Sed (https://www.gnu.org/software/sed/)

Todo / Add
----


License and Author
----

Author:: Cesar Bodden (cesar@pissedoffadmins.com)

Copyright:: 2016, Pissedoffadmins.com

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
