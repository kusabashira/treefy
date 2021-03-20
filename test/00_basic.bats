#!/usr/bin/env bats

readonly treefy=$BATS_TEST_DIRNAME/../treefy
readonly tmpdir=$BATS_TEST_DIRNAME/../tmp
readonly stdout=$BATS_TEST_DIRNAME/../tmp/stdout
readonly stderr=$BATS_TEST_DIRNAME/../tmp/stderr
readonly exitcode=$BATS_TEST_DIRNAME/../tmp/exitcode

setup() {
  if [[ $BATS_TEST_NUMBER == 1 ]]; then
    mkdir -p -- "$tmpdir"
  fi
}

teardown() {
  if [[ ${#BATS_TEST_NAMES[@]} == $BATS_TEST_NUMBER ]]; then
    rm -rf -- "$tmpdir"
  fi
}

check() {
  printf "%s\n" "" > "$stdout"
  printf "%s\n" "" > "$stderr"
  printf "%s\n" "0" > "$exitcode"
  "$@" > "$stdout" 2> "$stderr" || printf "%s\n" "$?" > "$exitcode"
}

@test 'treefy: print usage if "--help" passed' {
  check "$treefy" --help
  [[ $(cat "$exitcode") == 0 ]]
  [[ $(cat "$stdout") =~ ^usage ]]
}

@test 'treefy: print error if unknown option passed' {
  check "$treefy" --test
  [[ $(cat "$exitcode") == 1 ]]
  [[ $(cat "$stderr") =~ ^'treefy: Unknown option' ]]
}

@test 'treefy: print error if nonexistent file' {
  check "$treefy" CuSWcqBEzfbCikCcTdgkC9Br0vKl0wN4Ln_EDmYgqq1aA9DCtXAJiNCsyGImMh6K76eDFkmLSZzZU5S9
  [[ $(cat "$exitcode") == 1 ]]
  [[ $(cat "$stderr") =~ ^'treefy: Can'"'"'t open' ]]
}

@test 'treefy: treefy indented text' {
  src=$(printf "%s\n" $'
  XXX
  \tYYY
  \tZZZ
  ' | sed -e '1d' -e 's/^  //')
  dst=$(printf "%s\n" $'
  XXX
  |-- YYY
  `-- ZZZ
  ' | sed -e '1d' -e 's/^  //')

  check "$treefy" <<< "$src"
  [[ $(cat "$exitcode") == 0 ]]
  [[ $(cat "$stdout") == $dst ]]
}

@test 'treefy: treefy multi indented text' {
  src=$(printf "%s\n" $'
  AAA
  \tBBB
  \t\tCCC
  \t\t\tDDD
  \tEEE
  \tFFF
  \t\tGGG
  \t\tHHH
  III
  JJJ
  ' | sed -e '1d' -e 's/^  //')
  dst=$(printf "%s\n" $'
  AAA
  |-- BBB
  |   `-- CCC
  |       `-- DDD
  |-- EEE
  `-- FFF
      |-- GGG
      `-- HHH
  III
  JJJ
  ' | sed -e '1d' -e 's/^  //')

  check "$treefy" <<< "$src"
  [[ $(cat "$exitcode") == 0 ]]
  [[ $(cat "$stdout") == $dst ]]
}

@test 'treefy: fail if indent depth increased two or more at a time' {
  src=$(printf "%s\n" $'
  AAA
  \tBBB
  \t\t\tCCC
  ' | sed -e '1d' -e 's/^  //')

  check "$treefy" <<< "$src"
  [[ $(cat "$exitcode") == 1 ]]
  [[ $(cat "$stderr") =~ ^'treefy: indent depth increased two or more at a time' ]]
}

@test 'treefy: fail if a node found which does not have a parent' {
  src=$(printf "%s\n" $'
  \tAAA
  \tBBB
  \tCCC
  ' | sed -e '1d' -e 's/^  //')

  check "$treefy" <<< "$src"
  [[ $(cat "$exitcode") == 1 ]]
  [[ $(cat "$stderr") =~ ^'treefy: a node found which doesn'"'"'t have a parent' ]]
}

@test 'treefy: change indent string if "-i" passed' {
  src=$(printf "%s\n" $'
  AAA
    BBB
      CCC
        DDD
    EEE
    FFF
      GGG
      HHH
  III
  JJJ
  ' | sed -e '1d' -e 's/^  //')
  dst=$(printf "%s\n" $'
  AAA
  |-- BBB
  |   `-- CCC
  |       `-- DDD
  |-- EEE
  `-- FFF
      |-- GGG
      `-- HHH
  III
  JJJ
  ' | sed -e '1d' -e 's/^  //')

  check "$treefy" -i '  ' <<< "$src"
  [[ $(cat "$exitcode") == 0 ]]
  [[ $(cat "$stdout") == $dst ]]
}

@test 'treefy: change indent string if "--indent-string" passed' {
  src=$(printf "%s\n" $'
  AAA
    BBB
      CCC
        DDD
    EEE
    FFF
      GGG
      HHH
  III
  JJJ
  ' | sed -e '1d' -e 's/^  //')
  dst=$(printf "%s\n" $'
  AAA
  |-- BBB
  |   `-- CCC
  |       `-- DDD
  |-- EEE
  `-- FFF
      |-- GGG
      `-- HHH
  III
  JJJ
  ' | sed -e '1d' -e 's/^  //')

  check "$treefy" --indent-string '  ' <<< "$src"
  [[ $(cat "$exitcode") == 0 ]]
  [[ $(cat "$stdout") == $dst ]]
}

@test 'treefy: add margin if "-m" passed' {
  src=$(printf "%s\n" $'
  AAA
  \tBBB
  \t\tCCC
  \t\t\tDDD
  \tEEE
  \tFFF
  \t\tGGG
  \t\tHHH
  III
  JJJ
  ' | sed -e '1d' -e 's/^  //')
  dst=$(printf "%s\n" $'
  AAA
  |
  |-- BBB
  |   |
  |   `-- CCC
  |       |
  |       `-- DDD
  |
  |-- EEE
  |
  `-- FFF
      |
      |-- GGG
      |
      `-- HHH

  III

  JJJ
  ' | sed -e '1d' -e 's/^  //')

  check "$treefy" -m 1 <<< "$src"
  [[ $(cat "$exitcode") == 0 ]]
  [[ $(cat "$stdout") == $dst ]]
}

@test 'treefy: add margin if "--margin" passed' {
  src=$(printf "%s\n" $'
  AAA
  \tBBB
  \t\tCCC
  \t\t\tDDD
  \tEEE
  \tFFF
  \t\tGGG
  \t\tHHH
  III
  JJJ
  ' | sed -e '1d' -e 's/^  //')
  dst=$(printf "%s\n" $'
  AAA
  |
  |-- BBB
  |   |
  |   `-- CCC
  |       |
  |       `-- DDD
  |
  |-- EEE
  |
  `-- FFF
      |
      |-- GGG
      |
      `-- HHH

  III

  JJJ
  ' | sed -e '1d' -e 's/^  //')

  check "$treefy" -m 1 <<< "$src"
  [[ $(cat "$exitcode") == 0 ]]
  [[ $(cat "$stdout") == $dst ]]
}

# vim: ft=bash
