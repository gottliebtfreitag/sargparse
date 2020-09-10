#!/usr/bin/bash -e

cd "${0%/*}"/..

function check {
	idx=$1
	shift
	set +e
	test "$1" "$2" "$3"

	r="$?"
	set -e
	if [ $r -ne 0 ]; then
		echo "failed on:"
		echo "$1" "$2" "$3"
		echo "error code $r"
		echo ""
		echo "tests failed on test ${idx}"
		exit -1
	fi
}
completeResult='--help
--man
--mySection.cpp_file
--mySection.double
--mySection.file
--mySection.flag
--mySection.integer
--mySection.multi_cpp_files
--mySection.multi_files
--mySection.multi_paths
--mySection.path
--mySection.string
--my_enum
add
my_command'

check 101 "${completeResult}" = "$(./exampleSargparse --bash_completion)" 
check 102 "${completeResult}" = "$(./exampleSargparse \"\" --bash_completion)"
check 103 "${completeResult}" = "$(./exampleSargparse '' --bash_completion)"

check 104 "${completeResult}" = "$(./exampleSargparse '-' --bash_completion)"
check 105 "${completeResult}" = "$(./exampleSargparse '--' --bash_completion)"
check 106 "${completeResult}" = "$(./exampleSargparse '--' --bash_completion)"
check 107 "${completeResult}" = "$(./exampleSargparse '--my' --bash_completion)"
check 108 "${completeResult}" = "$(./exampleSargparse '--my_enum' --bash_completion)"
check 109 $'Bar\nFoo' = "$(./exampleSargparse '--my_enum' '' --bash_completion)"


my_command_Result=$'--help
--man
--mySection.cpp_file
--mySection.double
--mySection.file
--mySection.flag
--mySection.integer
--mySection.multi_cpp_files
--mySection.multi_files
--mySection.multi_paths
--mySection.path
--mySection.string
--my_enum
--print_hello
--words_to_print'


check 201 "${completeResult}" = "$(./exampleSargparse 'my_c' --bash_completion)"
check 202 "${completeResult}" = "$(./exampleSargparse 'my_command' --bash_completion)"
check 203 "${my_command_Result}" = "$(./exampleSargparse 'my_command' '' --bash_completion)"

add_Result=$'--help
--man
--mySection.cpp_file
--mySection.double
--mySection.file
--mySection.flag
--mySection.integer
--mySection.multi_cpp_files
--mySection.multi_files
--mySection.multi_paths
--mySection.path
--mySection.string
--my_enum'


check 301 "${completeResult}" = "$(./exampleSargparse 'add' --bash_completion)"
check 302 " -f " = "$(./exampleSargparse 'add' '' --bash_completion)"
check 303 "${add_Result}" = "$(./exampleSargparse 'add' '-' --bash_completion)"
check 304 " -f " = "$(./exampleSargparse 'add' 'x' --bash_completion)"
check 305 "${add_Result}" = "$(./exampleSargparse 'add' '--' --bash_completion)"
check 306 " -f " = "$(./exampleSargparse 'add' '--' ''  --bash_completion)"
check 307 "${add_Result}" = "$(./exampleSargparse 'add' 'file' '--' --bash_completion)"
check 308 " -f " = "$(./exampleSargparse 'add' 'file' '--' ''  --bash_completion)"



check 401 "${completeResult}" = "$(./exampleSargparse '--mySection.integer' --bash_completion)"
check 402 "" = "$(./exampleSargparse '--mySection.integer' '' --bash_completion)"
check 403 "" = "$(./exampleSargparse '--mySection.string' '' --bash_completion)"
check 404 "" = "$(./exampleSargparse '--mySection.double' '' --bash_completion)"


flag_Result=$'--help
--man
--mySection.cpp_file
--mySection.double
--mySection.file
--mySection.flag
--mySection.integer
--mySection.multi_cpp_files
--mySection.multi_files
--mySection.multi_paths
--mySection.path
--mySection.string
--my_enum
add
false
my_command
true'

check 501 "${completeResult}" = "$(./exampleSargparse '--mySection.flag' --bash_completion)"
check 502 "${flag_Result}" = "$(./exampleSargparse '--mySection.flag' '' --bash_completion)"


check 601 "${completeResult}" = "$(./exampleSargparse '--mySection.file' --bash_completion)"
check 602 " -f " = "$(./exampleSargparse '--mySection.file' '' --bash_completion)"
check 603 "${completeResult}" = "$(./exampleSargparse '--mySection.file' 'file' '' --bash_completion)"

check 604 "${completeResult}" = "$(./exampleSargparse '--mySection.path' --bash_completion)"
check 605 " -d " = "$(./exampleSargparse '--mySection.path' '' --bash_completion)"
check 606 "${completeResult}" = "$(./exampleSargparse '--mySection.path' 'dir' '' --bash_completion)"

check 607 "${completeResult}" = "$(./exampleSargparse '--mySection.cpp_file' --bash_completion)"
check 608 " -f .cpp" = "$(./exampleSargparse '--mySection.cpp_file' '' --bash_completion)"
check 609 "${completeResult}" = "$(./exampleSargparse '--mySection.cpp_file' 'file' '' --bash_completion)"

check 610 "${completeResult}" = "$(./exampleSargparse '--mySection.multi_files' --bash_completion)"
check 611 " -f " = "$(./exampleSargparse '--mySection.multi_files' '' --bash_completion)"
check 612 " -f " = "$(./exampleSargparse '--mySection.multi_files' 'file' '' --bash_completion)"
check 613 " -f " = "$(./exampleSargparse '--mySection.multi_files' '--' '' --bash_completion)"
check 614 "${completeResult}" = "$(./exampleSargparse '--mySection.multi_files' 'file' '-' --bash_completion)"
check 615 " -f " = "$(./exampleSargparse '--mySection.multi_files' 'file' '--' '' --bash_completion)"

check 620 "${completeResult}" = "$(./exampleSargparse '--mySection.multi_paths' --bash_completion)"
check 621 " -d " = "$(./exampleSargparse '--mySection.multi_paths' '' --bash_completion)"
check 622 " -d " = "$(./exampleSargparse '--mySection.multi_paths' 'dir' '' --bash_completion)"
check 623 " -d " = "$(./exampleSargparse '--mySection.multi_paths' '--' '' --bash_completion)"
check 624 "${completeResult}" = "$(./exampleSargparse '--mySection.multi_paths' 'path' '-' --bash_completion)"
check 625 " -d " = "$(./exampleSargparse '--mySection.multi_paths' 'path' '--' '' --bash_completion)"

check 631 "${completeResult}" = "$(./exampleSargparse '--mySection.multi_cpp_files' --bash_completion)"
check 632 " -f .cpp" = "$(./exampleSargparse '--mySection.multi_cpp_files' '' --bash_completion)"
check 633 " -f .cpp" = "$(./exampleSargparse '--mySection.multi_cpp_files' 'file' '' --bash_completion)"
check 634 " -f .cpp" = "$(./exampleSargparse '--mySection.multi_cpp_files' '--' '' --bash_completion)"
check 635 "${completeResult}" = "$(./exampleSargparse '--mySection.multi_cpp_files' 'file' '-' --bash_completion)"
check 636 " -f .cpp" = "$(./exampleSargparse '--mySection.multi_cpp_files' 'file' '--' '' --bash_completion)"


echo "tests passed"
exit 0
