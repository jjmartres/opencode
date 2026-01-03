# Simple Makefile for MCP server repositories
# Clone, build, and manage multiple MCP server Docker containers
# Configuration is read from mcps.json file

# Configuration file
CONFIG_FILE := mcps.json

# Build directory for all repositories
BUILD_DIR := .build

# Colors for output
GREEN := \033[32m
YELLOW := \033[33m
BLUE := \033[34m
RED := \033[31m
BOLD := \033[1m
RESET := \033[0m

# Default target
.PHONY: all
all: build

# Help
.PHONY: help
help:
	@echo "$(BOLD)Simple MCP Servers Docker Builder$(RESET)"
	@echo ""
	@echo "$(BOLD)Available Commands:$(RESET)"
	@echo "  $(GREEN)build$(RESET)        - Clone repositories and build all Docker containers"
	@echo "  $(GREEN)clean$(RESET)        - Remove all cloned repositories from $(BUILD_DIR)"
	@echo "  $(GREEN)clean-images$(RESET) - Remove all built Docker images"
	@echo "  $(GREEN)clean-all$(RESET)    - Remove repositories and Docker images"
	@echo ""
	@echo "$(BOLD)Configuration:$(RESET)"
	@echo "  Edit $(CONFIG_FILE) to add/remove repositories"
	@echo "  Specify 'branch' or 'tag' for each repository (defaults to 'main')"
	@echo "  Docker images are tagged with branch/tag name: repo:branch"
	@echo "  All repositories are cloned into: $(BUILD_DIR)/"
	@echo ""
	@echo "$(BOLD)Requirements:$(RESET)"
	@echo "  - jq (for parsing JSON configuration)"
	@echo "  - git (for cloning repositories)"
	@echo "  - docker (for building containers)"

# Build all containers
.PHONY: build
build:
	@echo "$(BOLD)Building all MCP server containers...$(RESET)"
	@if ! command -v jq > /dev/null 2>&1; then \
		echo "$(RED)Error: jq is not installed$(RESET)"; \
		echo "Please install jq: https://jqlang.github.io/jq/download/"; \
		exit 1; \
	fi
	@if [ ! -f "$(CONFIG_FILE)" ]; then \
		echo "$(RED)Error: $(CONFIG_FILE) not found$(RESET)"; \
		echo "Please create $(CONFIG_FILE) with your repository configuration"; \
		exit 1; \
	fi
	@mkdir -p $(BUILD_DIR)
	@for repo_data in $$(grep -v '^[[:space:]]*\/\/' $(CONFIG_FILE) | jq -r '.repositories[] | "\(.name),\(.url),\(.image)"'); do \
		name=$$(echo "$$repo_data" | cut -d',' -f1); \
		url=$$(echo "$$repo_data" | cut -d',' -f2); \
		image=$$(echo "$$repo_data" | cut -d',' -f3); \
		repo_path="$(BUILD_DIR)/$$name"; \
		echo ""; \
		echo "$(BLUE)Processing $$name...$(RESET)"; \
		if [ ! -d "$$repo_path" ]; then \
			echo "$(YELLOW)Cloning $$name into $$repo_path...$(RESET)"; \
			git clone $$url $$repo_path; \
		else \
			echo "$(YELLOW)Repository $$name already exists, pulling latest...$(RESET)"; \
			cd $$repo_path && git pull && cd - > /dev/null; \
		fi; \
		if [ -f "$$repo_path/Dockerfile" ]; then \
			echo "$(YELLOW)Building Docker image $$image...$(RESET)"; \
			cd $$repo_path && docker build -t $$image . && cd - > /dev/null; \
			echo "$(GREEN)✓ Successfully built $$image$(RESET)"; \
		else \
			dockerfile_path=$$(find $$repo_path -name "Dockerfile" -type f | head -1); \
			if [ -n "$$dockerfile_path" ]; then \
				dockerfile_dir=$$(dirname $$dockerfile_path); \
				echo "$(YELLOW)Found Dockerfile in $$dockerfile_dir, building...$(RESET)"; \
				cd $$dockerfile_dir && docker build -t $$image . && cd - > /dev/null; \
				echo "$(GREEN)✓ Successfully built $$image$(RESET)"; \
			else \
				echo "$(RED)✗ No Dockerfile found for $$name$(RESET)"; \
			fi; \
		fi; \
	done
	@echo ""
	@echo "$(BOLD)Build process completed!$(RESET)"

# Clean repositories
.PHONY: clean
clean:
	@if ! command -v jq > /dev/null 2>&1; then \
		echo "$(RED)Error: jq is not installed$(RESET)"; \
		echo "Please install jq: https://jqlang.github.io/jq/download/"; \
		exit 1; \
	fi
	@if [ ! -f "$(CONFIG_FILE)" ]; then \
		echo "$(RED)Error: $(CONFIG_FILE) not found$(RESET)"; \
		echo "Please create $(CONFIG_FILE) with your repository configuration"; \
		exit 1; \
	fi
	@echo "$(BLUE)Removing all cloned repositories from $(BUILD_DIR)...$(RESET)"
	@if [ -d "$(BUILD_DIR)" ]; then \
		for repo_data in $$(grep -v '^[[:space:]]*\/\/' $(CONFIG_FILE) | jq -r '.repositories[] | "\(.name),\(.url),\(.image)"'); do \
			name=$$(echo "$$repo_data" | cut -d',' -f1); \
			repo_path="$(BUILD_DIR)/$$name"; \
			if [ -d "$$repo_path" ]; then \
				rm -rf "$$repo_path"; \
				echo "$(GREEN)✓ Removed $$repo_path$(RESET)"; \
			fi; \
		done; \
		if [ -z "$$(ls -A $(BUILD_DIR) 2>/dev/null)" ]; then \
			rmdir "$(BUILD_DIR)"; \
			echo "$(GREEN)✓ Removed empty $(BUILD_DIR) directory$(RESET)"; \
		fi; \
	else \
		echo "$(YELLOW)Build directory $(BUILD_DIR) does not exist$(RESET)"; \
	fi
	@echo "$(BOLD)Repository cleanup completed!$(RESET)"

# Clean Docker images
.PHONY: clean-images
clean-images:
	@if ! command -v jq > /dev/null 2>&1; then \
		echo "$(RED)Error: jq is not installed$(RESET)"; \
		echo "Please install jq: https://jqlang.github.io/jq/download/"; \
		exit 1; \
	fi
	@if [ ! -f "$(CONFIG_FILE)" ]; then \
		echo "$(RED)Error: $(CONFIG_FILE) not found$(RESET)"; \
		echo "Please create $(CONFIG_FILE) with your repository configuration"; \
		exit 1; \
	fi
	@echo "$(BLUE)Removing all built Docker images...$(RESET)"
	@for repo_data in $$(grep -v '^[[:space:]]*\/\/' $(CONFIG_FILE) | jq -r '.repositories[] | "\(.name),\(.url),\(.image)"'); do \
		image=$$(echo "$$repo_data" | cut -d',' -f3); \
		if [ -n "$$(docker images -q $$image 2>/dev/null)" ]; then \
			docker rmi $$image; \
			echo "$(GREEN)✓ Removed $$image$(RESET)"; \
		fi; \
	done
	@echo "$(BOLD)All Docker images removed!$(RESET)"

# Clean everything
.PHONY: clean-all
clean-all: clean clean-images
	@echo "$(BOLD)Complete cleanup finished!$(RESET)"
