CPP_DIR = addons/native_bridge/cpp
BUILD_DIR = build

# detect number of CPU cores
NPROC := $(shell sysctl -n hw.ncpu 2>/dev/null || nproc 2>/dev/null || echo 4)

.PHONY: build-macos build-linux build-windows build-ios build-tvos build-android create-build-dir clean

help:
	@echo "Usage:"
	@echo "  make build-macos"
	@echo "  make build-linux"
	@echo "  make build-windows"
	@echo "  make build-ios"
	@echo "  make build-tvos"
	@echo "  make build-android"
	@echo "  make create-build-dir"
	@echo "  make clean"
	@echo ""
	@echo "Parallel builds enabled: $(NPROC) jobs"

create-build-dir:
	mkdir -p $(BUILD_DIR)
	echo "" > $(BUILD_DIR)/.gdignore

build-macos:
	@make create-build-dir
	cmake -S $(CPP_DIR) -B $(BUILD_DIR)/macos -DCMAKE_BUILD_TYPE=Debug
	cmake --build $(BUILD_DIR)/macos --config Debug -j $(NPROC)

build-linux:
	@make create-build-dir
	cmake -S $(CPP_DIR) -B $(BUILD_DIR)/linux -DCMAKE_BUILD_TYPE=Debug
	cmake --build $(BUILD_DIR)/linux --config Debug -j $(NPROC)

build-windows:
	@make create-build-dir
	cmake -S $(CPP_DIR) -B $(BUILD_DIR)/windows -DCMAKE_BUILD_TYPE=Debug
	cmake --build $(BUILD_DIR)/windows --config Debug -j $(NPROC)

build-ios:
	@make create-build-dir
	@echo "TODO - Need to add iOS build support"

build-tvos:
	@make create-build-dir
	@echo "TODO - Need to add tvOS build support"

build-android:
	@make create-build-dir
	@echo "TODO - Need to add Android build support"

clean:
	rm -rf $(BUILD_DIR)
	rm -rf addons/native_bridge/bin/*
