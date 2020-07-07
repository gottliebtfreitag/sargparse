all:
	g++ -std=c++17 exampleSargparse.cpp src/sargparse/*.cpp -o exampleSargparse -isystem src
	echo "try:"
	echo "$ ./exampleSargparse --help"
	echo "$ ./exampleSargparse --man"
	echo "$ ./exampleSargparse my_command"
	echo "$ ./exampleSargparse --my_enum Bar"

test:
	./exampleSargparse --help
	./exampleSargparse --man
	./exampleSargparse my_command
	./exampleSargparse --my_enum Bar
	./exampleSargparse --my_enum Foo
	./exampleSargparse --my_enum Bar
	./exampleSargparse --mySection.flag
	./exampleSargparse --mySection.double 3.5
	./exampleSargparse --mySection.flag --mySection.integer 5
	./exampleSargparse --mySection.string "hallo welt"
