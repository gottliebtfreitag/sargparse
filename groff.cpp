#include "Parameter.h"
#include "ArgumentParsing.h"

#include <string>
#include <iostream>
#include <stdlib.h>
#include <unistd.h>

namespace sargp
{

namespace {
    
void printManPage();
auto manPage = Flag("man", "show a man compatible help for the active (sub) command(s)", printManPage);

void printManPage() {
    auto commands = getActiveCommands();
    Command* activeCommand = commands.back();
    std::string command_names = std::accumulate(next(begin(commands)), end(commands), std::string{}, [](std::string const& l, Command const* c) {
        return l + " " + c->getName();
    });
	std::string groff = ".TH man 1\n.SH NAME\n" + command_names + "\n";
    groff += ".SH SYNOPSIS\n" + command_names;
    if (not activeCommand->getSubCommands().empty()) {
        groff += " [subcommand]...";
    }
    if (not activeCommand->getParameters().empty()) {
        groff += " [arguments]...";
    }
    groff += "\n.SH DESCRIPTION\n" + activeCommand->getDescription() + "\n";

	auto const & subCommands = activeCommand->getSubCommands();
	if (not subCommands.empty()) { // if there is at least one subcommand
		groff += ".SH SUB COMMANDS\n";
		for (auto const& subC : subCommands) {
            groff += ".TP\n\\fB" + subC->getName() + "\\fR\n" + subC->getDescription() + "\n";
		}
		groff += "\n";
	}

    Command const* command = activeCommand;
    while (command->getParentCommand()) {
        if (not command->getParameters().empty()) {
            groff += ".SH OPTIONS FOR " + command->getName() + "\n";
            for (ParameterBase const* param : command->getParameters()) {
                groff += ".TP\n";
                groff += "\\fR--" + param->getArgName() + "\\fR\n";
                groff += param->describe() + "\n";
            }
        }
        command = command->getParentCommand();
    }
    if (not command->getParameters().empty()) {
        groff += ".SH GLOBAL OPTIONS\n";
        for (ParameterBase const* param : command->getParameters()) {
            groff += ".TP\n";
            groff += "\\fR--" + param->getArgName() + "\\fR\n";
            groff += param->describe() + "\n";
        }
    }

    char tmp_file_name[] = "groff_tempfileXXXXXX";
    int fd = mkstemp(tmp_file_name);
    if (fd == -1) {
        throw std::runtime_error("cannot create tempfile" + std::string{std::strerror(errno)});
    }

    std::array<char, 4096> absPath{'\0'};
    std::string procPat = "/proc/self/fd/" + std::to_string(fd);
    int r = readlink(procPat.c_str(), absPath.data(), absPath.size());
    if (r == -1 || r == static_cast<int>(absPath.size())) {
        throw std::runtime_error("cannot do readlink");
    }

    std::size_t written{0};
    while (written < groff.size()) {
        int w = ::write(fd, groff.data() + written, groff.size() - written);
        if (w <= 0) {
            break;
        }
        written += w;
    }

    int e = ::execlp("man", "-l", absPath.data(), nullptr);

    exit(e);
}

}
}