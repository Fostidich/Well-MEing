# Configurations
HOST ?= 0.0.0.0
PORT ?= 8000

# Variables
VENV ?= venv
PYTHON = $(VENV)/bin/python
PIP = $(VENV)/bin/pip
UVICORN = $(VENV)/bin/uvicorn

# Directories
SRC = main.py
REQ = requirements.txt

# Default target
.PHONY: all
all: install run

# List commands
.PHONY: help
help:
	@echo "Available commands:"
	@echo "  make                      - Install and run"
	@echo "  make install              - Install dependencies"
	@echo "  make run                  - Run the server"
	@echo "  make lint                 - Format code"
	@echo "  make clean                - Remove venv and cache"
	@echo "  make update-requirements  - Update requirements.txt"
	@echo "  make help                 - Show this help panel"

# Create a virtual environment
.PHONY: venv
venv:
	python3 -m venv $(VENV)

# Ensure venv exists before updating requirements
.PHONY: update-requirements
update-requirements: venv
	$(PIP) freeze > $(REQ)

# Install dependencies
.PHONY: install
install: venv
	$(PIP) install -r $(REQ)

# Run the server
.PHONY: run
run: install
	$(UVICORN) main:app --host $(HOST) --port $(PORT) --reload

# Linting
.PHONY: lint
lint: install
	$(PYTHON) -m black $(SRC)
	$(PYTHON) -m isort $(SRC)

# Clean the environment
.PHONY: clean
clean:
	rm -rf $(VENV) __pycache__
