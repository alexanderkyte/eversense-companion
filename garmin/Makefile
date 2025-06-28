# Makefile for Eversense Companion Garmin Apps
# Requires Garmin Connect IQ SDK to be installed

# Default device for building
DEVICE ?= vivoactive4

# Output filenames
WATCHFACE_OUTPUT = EversenseWatchface.prg
DATAFIELD_OUTPUT = EversenseDataField.prg

# SDK path (adjust as needed)
SDK_PATH ?= $(HOME)/garmin/connectiq-sdk

# Compiler
MONKEYC = $(SDK_PATH)/bin/monkeyc

# Default target
all: build

# Build both apps
build: build-watchface build-datafield

# Build the watchface
build-watchface:
	@echo "Building Eversense Companion Watchface for $(DEVICE)..."
	$(MONKEYC) \
		-m manifest.xml \
		-z resources/ \
		-o $(WATCHFACE_OUTPUT) \
		-d $(DEVICE) \
		-w \
		--package-app eversense-watchface

# Build the datafield
build-datafield:
	@echo "Building Eversense Glucose Data Field for $(DEVICE)..."
	$(MONKEYC) \
		-m manifest.xml \
		-z resources/ \
		-o $(DATAFIELD_OUTPUT) \
		-d $(DEVICE) \
		-w \
		--package-app eversense-datafield

# Build for all supported devices
build-all:
	@echo "Building for all supported devices..."
	@for device in vivoactive4 vivoactive4s venu venu2 venu2s fenix6 fenix6s fenix6x forerunner245; do \
		echo "Building watchface for $$device..."; \
		$(MONKEYC) -m manifest.xml -z resources/ -o EversenseWatchface-$$device.prg -d $$device -w --package-app eversense-watchface; \
		echo "Building datafield for $$device..."; \
		$(MONKEYC) -m manifest.xml -z resources/ -o EversenseDataField-$$device.prg -d $$device -w --package-app eversense-datafield; \
	done

# Clean build artifacts
clean:
	rm -f *.prg
	rm -f *.debug
	rm -rf dist/
	rm -rf test-screenshots/
	rm -rf test-output/
	rm -rf screenshots/

# Run tests for both apps
test: test-watchface test-datafield

# Verify no network traffic during testing
verify-no-network:
	@echo "Verifying no network traffic during testing..."
	./verify-no-network.sh

# Run comprehensive tests with screenshots and network verification
test-all: verify-no-network
	@echo "Running comprehensive test suite..."
	./test.sh $(DEVICE)

# Run tests for watchface only
test-watchface: build-watchface
	@echo "Testing watchface functionality..."
	./test.sh $(DEVICE) watchface

# Run tests for datafield only
test-datafield: build-datafield
	@echo "Testing datafield functionality..."
	./test.sh $(DEVICE) datafield

# Generate screenshots for all scenarios
screenshots:
	@echo "Generating screenshots for $(DEVICE)..."
	./screenshot.sh $(DEVICE)

# Generate screenshots for all devices
screenshots-all:
	@echo "Generating screenshots for all devices..."
	@for device in vivoactive4 fenix6 venu2; do \
		echo "Generating screenshots for $$device..."; \
		./screenshot.sh $$device; \
	done

# Run watchface in simulator (legacy target)
sim-watchface: build-watchface
	@echo "Starting watchface simulator for $(DEVICE)..."
	$(SDK_PATH)/bin/connectiq &
	$(SDK_PATH)/bin/monkeydo $(WATCHFACE_OUTPUT) $(DEVICE)

# Run datafield in simulator (legacy target)  
sim-datafield: build-datafield
	@echo "Starting datafield simulator for $(DEVICE)..."
	$(SDK_PATH)/bin/connectiq &
	$(SDK_PATH)/bin/monkeydo $(DATAFIELD_OUTPUT) $(DEVICE)

# Package for distribution
package: build-all
	@echo "Creating distribution package..."
	mkdir -p dist
	cp *.prg dist/
	cp README.md dist/
	tar -czf eversense-garmin-companion.tar.gz dist/
	@echo "Package created: eversense-garmin-companion.tar.gz"

# Docker build - builds for all devices in a containerized environment
docker-build:
	@echo "Building Garmin apps using Docker..."
	docker build -t eversense-garmin-builder .
	docker run --rm -v $(PWD)/dist:/workspace/dist eversense-garmin-builder
	@echo "Docker build complete! Artifacts in ./dist/"

# Docker package - same as docker-build but ensures clean state
docker-package: clean
	@echo "Clean Docker build for distribution..."
	docker build --no-cache -t eversense-garmin-builder .
	docker run --rm -v $(PWD)/dist:/workspace/dist eversense-garmin-builder

# Install SDK (helper target)
install-sdk:
	@echo "Please download and install the Connect IQ SDK from:"
	@echo "https://developer.garmin.com/connect-iq/sdk/"
	@echo "Then set SDK_PATH environment variable or update this Makefile"

# Help
help:
	@echo "Available targets:"
	@echo "  build          - Build both watchface and datafield for default device ($(DEVICE))"
	@echo "  build-watchface - Build watchface only"
	@echo "  build-datafield - Build datafield only"
	@echo "  build-all      - Build both apps for all supported devices"
	@echo "  clean          - Remove build artifacts and test outputs"
	@echo "  sim-watchface  - Run watchface in simulator"
	@echo "  sim-datafield  - Run datafield in simulator"
	@echo "  test           - Run tests for both apps"
	@echo "  test-all       - Run comprehensive test suite with screenshots and network verification"
	@echo "  test-watchface - Test watchface functionality"
	@echo "  test-datafield - Test datafield functionality"
	@echo "  verify-no-network - Verify no network traffic during testing"
	@echo "  screenshots    - Generate screenshots for current device"
	@echo "  screenshots-all - Generate screenshots for all devices"
	@echo "  package        - Create distribution package"
	@echo "  docker-build   - Build using Docker (recommended for CI/CD)"
	@echo "  docker-package - Clean Docker build for distribution"
	@echo "  help           - Show this help"
	@echo ""
	@echo "Variables:"
	@echo "  DEVICE    - Target device (default: $(DEVICE))"
	@echo "  SDK_PATH  - Path to Connect IQ SDK"

.PHONY: all build build-watchface build-datafield build-all clean sim-watchface sim-datafield test test-all test-watchface test-datafield verify-no-network screenshots screenshots-all package docker-build docker-package install-sdk help