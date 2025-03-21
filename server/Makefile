# Variables
JAR_FILE = $(shell ls target/*.jar)

# Build and format
.PHONY: all
all: format run

# List commands
.PHONY: help
help:
	@echo "Available commands:"
	@echo "  make                      - Run the server for debugging"
	@echo "  make build                - Build the fat jar"
	@echo "  make run-jar              - Run the fat jar"
	@echo "  make run                  - Run the server from source"
	@echo "  make test                 - Run tests"
	@echo "  make format               - Format code"
	@echo "  make clean                - Remove build target files"
	@echo "  make help                 - Show this help panel"

# Build
.PHONY: build
build:
	mvn clean package

# Run
.PHONY: run
run:
	mvn spring-boot:run

# Formatting
.PHONY: format
format:
	mvn formatter:format

# Testing
.PHONY: test
test:
	mvn test

# Clean
.PHONY: clean
clean:
	mvn clean

# Run fat JAR
.PHONY: run-jar
run-jar: build
	java -jar $(JAR_FILE)
