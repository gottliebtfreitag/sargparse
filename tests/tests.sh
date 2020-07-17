#!/usr/bin/bash -e

cd "${0%/*}"/..

idx=0

function check {
	idx=$(expr $idx + 1)
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

check "${completeResult}" = "$(./exampleSargparse --bash_completion)" 
check "${completeResult}" = "$(./exampleSargparse \"\" --bash_completion)"
check "${completeResult}" = "$(./exampleSargparse '' --bash_completion)"

check "${completeResult}" = "$(./exampleSargparse '-' --bash_completion)"
check "${completeResult}" = "$(./exampleSargparse '--' --bash_completion)"
check "${completeResult}" = "$(./exampleSargparse '--' --bash_completion)"
check "${completeResult}" = "$(./exampleSargparse '--my' --bash_completion)"
check "${completeResult}" = "$(./exampleSargparse '--my_enum' --bash_completion)"
check $'Bar\nFoo' = "$(./exampleSargparse '--my_enum' '' --bash_completion)"


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


check "${completeResult}" = "$(./exampleSargparse 'my_c' --bash_completion)"
check "${completeResult}" = "$(./exampleSargparse 'my_command' --bash_completion)"
check "${my_command_Result}" = "$(./exampleSargparse 'my_command' '' --bash_completion)"

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


check "${completeResult}" = "$(./exampleSargparse 'add' --bash_completion)"
check " -f " = "$(./exampleSargparse 'add' '' --bash_completion)"
check "${add_Result}" = "$(./exampleSargparse 'add' '-' --bash_completion)"
check " -f " = "$(./exampleSargparse 'add' 'x' --bash_completion)"
check "${add_Result}" = "$(./exampleSargparse 'add' '--' --bash_completion)"
check " -f " = "$(./exampleSargparse 'add' '--' ''  --bash_completion)"



echo "tests passed"
exit 0
