treefy
======

Add branches to the text indented.

```
$ cat src.txt
.
	bin
		compile.sh
	Makefile
	out
		01.png
		02.png
		03.png
	src
		01.kra
		02.kra
		03.kra
$ cat src.txt | treefy
.
|-- bin
|   `-- compile.sh
|-- Makefile
|-- out
|   |-- 01.png
|   |-- 02.png
|   `-- 03.png
`-- src
    |-- 01.kra
    |-- 02.kra
    `-- 03.kra
```

Usage
-----

```
$ treefy [<option(s)>] [<file(s)>]
add branches to the text indented.

options:
  -i, --indent-string=INDENT   use INDENT instead of TAB for indent string
  -m, --margin=N_MARGIN        add N_MARGIN margin between each rows
      --help                   print usage
```

Requirements
------------

- Perl (5.22.0 or later)

Installation
------------

1. Copy `treefy` into your `$PATH`.
2. Make `treefy` executable.

### Example

```
$ curl -L https://raw.githubusercontent.com/kusabashira/treefy/master/treefy > ~/bin/treefy
$ chmod +x ~/bin/treefy
```

Note: In this example, `$HOME/bin` must be included in `$PATH`.

Options
-------

### -i, --indent-string=INDENT

Change the indent string to INDENT. (default: TAB)

```
$ cat src.txt
A
->B
->C
->D
->->E
$ cat src.txt | treefy -i '->'
A
|-- B
|-- C
`-- D
    `-- E
```

### -m, --margin=N\_MARGIN

Add N\_MARGIN margin between each rows. (default: 0)

```
$ cat src.txt
A
	B
	C
	D
		E
$ cat src.txt | treefy -m 1
A
|
|-- B
|
|-- C
|
`-- D
    |
    `-- E
```

### --help

Print usage.

```
$ treefy --help
(Print usage)
```

License
-------

MIT License

Author
------

nil2 <nil2@nil2.org>
