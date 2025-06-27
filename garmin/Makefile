# Makefile for Eversense Companion Garmin Watchface
# Requires Garmin Connect IQ SDK to be installed

# Default device for building
DEVICE ?= vivoactive4

# Output filename
OUTPUT = EversenseWatchface.prg

# SDK path (adjust as needed)
SDK_PATH ?= $(HOME)/garmin/connectiq-sdk

# Compiler
MONKEYC = $(SDK_PATH)/bin/monkeyc

# Default target
all: build

# Build the watchface
build:
	@echo "Building Eversense Companion Watchface for $(DEVICE)..."
	$(MONKEYC) \
		-m manifest.xml \
		-z resources/ \
		-o $(OUTPUT) \
		-d $(DEVICE) \
		-w

# Build for all supported devices
build-all:
	@echo "Building for all supported devices..."
	@for device in vivoactive4 vivoactive4s venu venu2 venu2s fenix6 fenix6s fenix6x forerunner245; do \
		echo "Building for $$device..."; \
		$(MONKEYC) -m manifest.xml -z resources/ -o EversenseWatchface-$$device.prg -d $$device -w; \
	done

# Clean build artifacts
clean:
	rm -f *.prg
	rm -f *.debug

# Run in simulator
sim: build
	@echo "Starting simulator for $(DEVICE)..."
	$(SDK_PATH)/bin/connectiq &
	$(SDK_PATH)/bin/monkeydo $(OUTPUT) $(DEVICE)

# Package for distribution
package: build-all
	@echo "Creating distribution package..."
	mkdir -p dist
	cp *.prg dist/
	cp README.md dist/
	tar -czf eversense-garmin-watchface.tar.gz dist/
	@echo "Package created: eversense-garmin-watchface.tar.gz"

# Install SDK (helper target)
install-sdk:
	@echo "Please download and install the Connect IQ SDK from:"
	@echo "https://developer.garmin.com/connect-iq/sdk/"
	@echo "Then set SDK_PATH environment variable or update this Makefile"

# Help
help:
	@echo "Available targets:"
	@echo "  build     - Build for default device ($(DEVICE))"
	@echo "  build-all - Build for all supported devices"
	@echo "  clean     - Remove build artifacts"
	@echo "  sim       - Run in simulator"
	@echo "  package   - Create distribution package"
	@echo "  help      - Show this help"
	@echo ""
	@echo "Variables:"
	@echo "  DEVICE    - Target device (default: $(DEVICE))"
	@echo "  SDK_PATH  - Path to Connect IQ SDK"

.PHONY: all build build-all clean sim package install-sdk help