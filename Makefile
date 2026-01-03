.DEFAULT_GOAL := help
STOW_DIR := opencode
TARGET := $(HOME)/.config/opencode
STOW := $(shell command -v stow 2>/dev/null)
SUPERPOWERS_URL := https://github.com/obra/superpowers.git
SUPERPOWERS_DIR := $(HOME)/.config/opencode/superpowers

.PHONY: help
help: ## Display this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-25s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ Installation

.PHONY: check
check: ## Verify setup
	@test -d $(STOW_DIR) || (echo "Error: $(STOW_DIR) directory not found" && exit 1)
ifdef STOW
	@echo "✓ Using stow: $(STOW)"
	@test -f .stowrc || (echo "Warning: .stowrc not found")
else
	@echo "⚠ stow not found - will use ln -s instead"
endif
	@echo "✓ Setup verified"

.PHONY: install
install: check ## Install opencode configuration
	@mkdir -p $(TARGET)
ifdef STOW
	@echo "Installing with stow..."
	@stow */ || (echo "✗ Stow failed - check for conflicts" && exit 1)
else
	@echo "Installing with ln -s..."
	@$(MAKE) -s install-ln
endif
	@echo "✓ Installation complete"

.PHONY: install-ln
install-ln: ## Install using ln -s (internal)
	@mkdir -p $(TARGET)
	@for dir in $(STOW_DIR)/*/; do \
		package=$$(basename "$$dir"); \
		target_link="$(TARGET)/$$package"; \
		if [ -e "$$target_link" ] && [ ! -L "$$target_link" ]; then \
			echo "  ✗ $$package exists and is not a symlink - skipping"; \
		else \
			ln -sfn "$(CURDIR)/$$dir" "$$target_link"; \
			echo "  ✓ $$package"; \
		fi; \
	done

.PHONY: uninstall
uninstall: ## Uninstall opencode configuration
ifdef STOW
	@echo "Uninstalling with stow..."
	@stow -D */ 2>/dev/null || true
else
	@echo "Removing symlinks..."
	@$(MAKE) -s uninstall-ln
endif
	@echo "✓ Uninstallation complete"

.PHONY: uninstall-ln
uninstall-ln: ## Uninstall using rm (internal)
	@for dir in $(STOW_DIR)/*/; do \
		package=$$(basename "$$dir"); \
		target_link="$(TARGET)/$$package"; \
		if [ -L "$$target_link" ]; then \
			echo "  Removing $$package..."; \
			rm -f "$$target_link"; \
		fi; \
	done

.PHONY: restow
restow: ## Restow opencode configuration
ifdef STOW
	@echo "Restowing with stow..."
	@stow -R */ || (echo "✗ Restow failed - check for conflicts" && exit 1)
else
	@echo "Refreshing symlinks..."
	@$(MAKE) -s uninstall-ln install-ln
endif
	@echo "✓ Restow complete"

##@ Superpowers
.PHONY: git-check
git-check: ## Check git exclusion status
	@if [ -d "$(STOW_DIR)/superpowers" ]; then \
		if ! grep -q "superpowers" .gitignore 2>/dev/null; then \
			echo "⚠ WARNING: superpowers directory exists but not in .gitignore"; \
			echo "  Run 'make gitignore-superpowers' to fix this"; \
		else \
			echo "✓ Superpowers properly excluded from git"; \
		fi; \
	fi

.PHONY: gitignore-superpowers
gitignore-superpowers: ## Add superpowers to .gitignore
	@if grep -q "superpowers" .gitignore 2>/dev/null; then \
		echo "✓ Superpowers already in .gitignore"; \
	else \
		echo "" >> .gitignore; \
		echo "# OpenCode superpowers extension (external git repo)" >> .gitignore; \
		echo "opencode/superpowers/" >> .gitignore; \
		echo "✓ Added superpowers to .gitignore"; \
	fi

.PHONY: install-superpowers
install-superpowers: ## Install obra's superpowers extension
	@echo "Installing superpowers..."
	@if [ -d "$(SUPERPOWERS_DIR)" ]; then \
		echo "⚠ Superpowers already installed at $(SUPERPOWERS_DIR)"; \
		echo "  Run 'make update-superpowers' to update or 'make uninstall-superpowers' to remove"; \
		exit 1; \
	fi
	@mkdir -p $(TARGET)
	@echo "Cloning superpowers repository..."
	@git clone $(SUPERPOWERS_URL) $(SUPERPOWERS_DIR) || (echo "✗ Failed to clone superpowers" && exit 1)
	@$(MAKE) -s gitignore-superpowers
	@echo "✓ Superpowers installed successfully"
	@echo ""
	@echo "Next steps:"
	@echo "  1. Restart OpenCode Server"
	@echo "  2. Superpowers will be available in your extensions"

.PHONY: update-superpowers
update-superpowers: ## Update superpowers to latest version
	@if [ ! -d "$(SUPERPOWERS_DIR)" ]; then \
		echo "✗ Superpowers not installed. Run 'make install-superpowers' first"; \
		exit 1; \
	fi
	@echo "Updating superpowers..."
	@cd $(SUPERPOWERS_DIR) && git pull origin main || (echo "✗ Failed to update superpowers" && exit 1)
	@echo "✓ Superpowers updated successfully"
	@echo "  Restart OpenCode Server to apply changes"

.PHONY: uninstall-superpowers
uninstall-superpowers: ## Uninstall superpowers extension
	@if [ ! -d "$(SUPERPOWERS_DIR)" ]; then \
		echo "⚠ Superpowers not installed"; \
		exit 0; \
	fi
	@echo "Removing superpowers..."
	@rm -rf $(SUPERPOWERS_DIR)
	@echo "✓ Superpowers uninstalled"

.PHONY: superpowers-status
superpowers-status: ## Check superpowers installation status
	@if [ -d "$(SUPERPOWERS_DIR)" ]; then \
		echo "✓ Superpowers installed at: $(SUPERPOWERS_DIR)"; \
		echo ""; \
		cd $(SUPERPOWERS_DIR) && echo "Current branch: $$(git branch --show-current)"; \
		cd $(SUPERPOWERS_DIR) && echo "Latest commit: $$(git log -1 --oneline)"; \
		cd $(SUPERPOWERS_DIR) && echo "Remote status: $$(git fetch && git status -uno | grep 'Your branch')"; \
	else \
		echo "✗ Superpowers not installed"; \
		echo "  Run 'make install-superpowers' to install"; \
	fi

##@ Utilities

.PHONY: status
status: ## Show installation status
	@echo "Installation method: $(if $(STOW),stow,ln -s)"
	@echo "Target: $(TARGET)"
	@echo ""
	@echo "Installed packages:"
	@if [ -d "$(TARGET)" ]; then \
		for link in $(TARGET)/*; do \
			if [ -L "$$link" ]; then \
				target=$$(readlink "$$link"); \
				echo "  ✓ $$(basename $$link) -> $$target"; \
			elif [ -e "$$link" ]; then \
				if [ "$$(basename $$link)" = "superpowers" ]; then \
					echo "  ✓ $$(basename $$link) (superpowers extension)"; \
				else \
					echo "  ⚠ $$(basename $$link) (not a symlink)"; \
				fi; \
			fi; \
		done | sort; \
	else \
		echo "  Not installed"; \
	fi

.PHONY: list
list: ## List available packages
	@echo "Available packages:"
	@ls -d $(STOW_DIR)/*/ 2>/dev/null | sed 's|$(STOW_DIR)/||g; s|/$$||' | sed 's/^/  /' || echo "  None found"

.PHONY: clean
clean: ## Remove broken symlinks in target
	@echo "Cleaning broken symlinks in $(TARGET)..."
	@find $(TARGET) -xtype l -delete 2>/dev/null || true
	@echo "✓ Cleanup complete"

.PHONY: install-all
install-all: install install-superpowers ## Install everything (config + superpowers)
	@echo ""
	@echo "✓ Complete installation finished"

.PHONY: uninstall-all
uninstall-all: uninstall uninstall-superpowers ## Uninstall everything
	@echo ""
	@echo "✓ Complete uninstallation finished"

##@ Pre-commit hooks
.PHONY: install-hooks
install-hooks: ## Install pre-commit hooks
	@command -v pre-commit >/dev/null 2>&1 || \
		(echo "❌ pre-commit not installed. Install with: pip install pre-commit" && exit 1)
	@pre-commit install
	@echo "✓ Pre-commit hooks installed"

.PHONY: uninstall-hooks
uninstall-hooks: ## Uninstall pre-commit hooks
	@pre-commit uninstall
	@echo "✓ Pre-commit hooks uninstalled"

.PHONY: run-hooks
run-hooks: ## Run pre-commit hooks manually
	@pre-commit run --all-files

.PHONY: update-hooks
update-hooks: ## Update pre-commit hooks to latest versions
	@pre-commit autoupdate
	@echo "✓ Pre-commit hooks updated"
