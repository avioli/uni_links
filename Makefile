.PHONY: help

OBJC_SOURCES := $(shell find . \( -path './example/ios/Runner*' -o -path './ios/Classes/*' \) -a \( -name '*.h' -o -name '*.m' \))
JAVA_SOURCES := $(shell find . -name '*.java')
DART_SOURCES := $(shell find . -name '*.dart')

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

format: format-java format-objective-c format-dart ## Formats all java, objective-c and dart files

format-java: $(JAVA_SOURCES) ## Format Java files (*.java)
	google-java-format -a --replace $^

format-objective-c: $(OBJC_SOURCES) ## Format Objective-C header and implementation files (*.h, *.m)
	clang-format -i --style=Google $^

format-dart: $(DART_SOURCES) ## Format Dart files (*.dart)
	flutter format $^
