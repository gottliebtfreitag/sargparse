#pragma once

#include <filesystem>
#include "Parameter.h"

namespace sargp {

/*struct File final : std::filesystem::path {
	using std::filesystem::path::path;
};

struct Directory final : std::filesystem::path {
	using std::filesystem::path::path;
};*/

enum class File { Single, Multi };
inline auto completeFile(std::string extension = "", File file = File::Single) {
	return [file, extension](std::vector<std::string> const& c) -> std::pair<bool, std::set<std::string>> {
		if (file == File::Single and c.size() > 1 or c.empty()) {
			return {true, {}};
		}
		if (c.empty() or c.back().empty()) {
			if (extension.empty()) {
				return {false, {" -f "}};
			}
			return {false, {" -f *" + extension, " -d "}};
		}
		if (extension.empty()) {
			return {false, {" -f " + c.back()}};
		}
		return {false, {" -f " + c.back() + "*" + extension, " -d " + c.back()}};
	};
}
inline auto completeDirectory(File file = File::Single) {
	return [file](std::vector<std::string> const& c) -> std::pair<bool, std::set<std::string>> {
		if (file == File::Single and c.size() > 1 or c.empty()) {
			return {true, {}};
		}

		if (c.empty()) {
			return {false, {" -d "}};
		}
		return {false, {" -d " + c.back()}};
	};
}

}