#!/usr/bin/bash -e

cd "${0%/*}"/..

function check {
	idx=$1
	shift
	set +e
	$2 >/dev/null 2>/dev/null

	r="$?"
	set -e
	if [ $r -ne "$1" ]; then
		echo "failed on:"
		echo "$2"
		echo "error code $r"
		echo ""
		echo "normal run failed on test ${idx}"
		exit -1
	fi
}


check 101 0 "./exampleSargparse"
check 102 0 "./exampleSargparse add"
check 103 0 "./exampleSargparse my_command"
check 104 1 "./exampleSargparse blub"
check 105 0 "./exampleSargparse --help"
check 106 0 "./exampleSargparse --bash_completion"
check 107 1 "./exampleSargparse --invalid"
check 108 0 "./exampleSargparse add file1 file2 -- file3 file4"

check 110 1 "./exampleSargparse --mySection.integer"
check 111 0 "./exampleSargparse --mySection.integer 0"
check 112 1 "./exampleSargparse --mySection.integer 0 0"
check 113 1 "./exampleSargparse --mySection.integer 0.5"
check 114 1 "./exampleSargparse --mySection.integer blub"

check 120 1 "./exampleSargparse --mySection.string"
check 121 0 "./exampleSargparse --mySection.string blub"
check 122 1 "./exampleSargparse --mySection.string blub blub"

check 130 1 "./exampleSargparse --mySection.double"
check 131 0 "./exampleSargparse --mySection.double 0"
check 132 1 "./exampleSargparse --mySection.double 0 0"
check 133 0 "./exampleSargparse --mySection.double 0.5"
check 134 1 "./exampleSargparse --mySection.double blub"

check 140 0 "./exampleSargparse --mySection.flag"
check 141 1 "./exampleSargparse --mySection.flag blub"
check 142 0 "./exampleSargparse --mySection.flag true"
check 143 0 "./exampleSargparse --mySection.flag false"

check 144 0 "./exampleSargparse --mySection.flag my_command"
check 145 0 "./exampleSargparse --mySection.flag false my_command"
check 146 0 "./exampleSargparse --mySection.flag --mySection.string blubn"
check 147 0 "./exampleSargparse --mySection.flag false --mySection.string blubn"

check 200 1 "./exampleSargparse --mySection.file"
check 201 0 "./exampleSargparse --mySection.file blub"
check 202 1 "./exampleSargparse --mySection.file blub blub"

check 210 1 "./exampleSargparse --mySection.path"
check 211 0 "./exampleSargparse --mySection.path blub"
check 212 1 "./exampleSargparse --mySection.path blub blub"

check 220 1 "./exampleSargparse --mySection.cpp_file"
check 221 0 "./exampleSargparse --mySection.cpp_file blub"
check 222 1 "./exampleSargparse --mySection.cpp_file blub blub"

check 300 0 "./exampleSargparse --mySection.multi_files"
check 301 0 "./exampleSargparse --mySection.multi_files blub"
check 302 0 "./exampleSargparse --mySection.multi_files blub blub"
check 303 0 "./exampleSargparse --mySection.multi_files -- blub blub"

check 310 0 "./exampleSargparse --mySection.multi_paths"
check 311 0 "./exampleSargparse --mySection.multi_paths blub"
check 312 0 "./exampleSargparse --mySection.multi_paths blub blub"
check 313 0 "./exampleSargparse --mySection.multi_paths -- blub blub"

check 320 0 "./exampleSargparse --mySection.multi_cpp_files"
check 321 0 "./exampleSargparse --mySection.multi_cpp_files blub"
check 322 0 "./exampleSargparse --mySection.multi_cpp_files blub blub"
check 323 0 "./exampleSargparse --mySection.multi_cpp_files -- blub blub"

check 400 1 "./exampleSargparse --my_enum"
check 401 0 "./exampleSargparse --my_enum Bar"
check 402 0 "./exampleSargparse --my_enum Foo"
check 403 1 "./exampleSargparse --my_enum Blub"
check 404 1 "./exampleSargparse --my_enum Bar Bar"
check 405 1 "./exampleSargparse --my_enum Bar Foo"




echo "normal tests passed"
exit 0
