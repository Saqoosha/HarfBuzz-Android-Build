set -e


HARFBUZZ_VERSION="11.1.0"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
SRC_DIR="$PROJECT_DIR/src/harfbuzz"
BUILD_DIR="$PROJECT_DIR/build/macos-arm64"
INSTALL_DIR="$PROJECT_DIR/libs/macos-arm64"

echo "=== HarfBuzz macOS arm64 Build Configuration ==="
echo "HarfBuzz version: $HARFBUZZ_VERSION"
echo "Target architecture: arm64"
echo "Project directory: $PROJECT_DIR"
echo "Source directory: $SRC_DIR"
echo "Build directory: $BUILD_DIR"
echo "Install directory: $INSTALL_DIR"
echo "==========================================="

if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "Error: This script must be run on macOS."
    exit 1
fi

for cmd in cmake; do
    if ! command -v $cmd &> /dev/null; then
        echo "Error: $cmd is required but not found. Please install it and try again."
        exit 1
    fi
done

if [ ! -d "$SRC_DIR" ]; then
    echo "HarfBuzz source not found at $SRC_DIR"
    echo "Please make sure the HarfBuzz submodule is initialized with: git submodule update --init --recursive"
    exit 1
fi

mkdir -p "$BUILD_DIR"
mkdir -p "$INSTALL_DIR"

echo "Building HarfBuzz for macOS arm64..."

export CFLAGS="-arch arm64 -isysroot $(xcrun --sdk macosx --show-sdk-path)"
export CXXFLAGS="-arch arm64 -isysroot $(xcrun --sdk macosx --show-sdk-path)"
export LDFLAGS="-arch arm64"

cd "$BUILD_DIR"

cmake "$SRC_DIR" \
    -DCMAKE_OSX_ARCHITECTURES="arm64" \
    -DCMAKE_BUILD_TYPE=Release \
    -DHB_HAVE_FREETYPE=OFF \
    -DHB_HAVE_GLIB=OFF \
    -DHB_HAVE_ICU=OFF \
    -DHB_HAVE_GRAPHITE2=OFF \
    -DHB_HAVE_CORETEXT=ON \
    -DBUILD_SHARED_LIBS=OFF \
    -DCMAKE_MACOSX_RPATH=ON \
    -DBUILD_FRAMEWORK=OFF \
    -DCMAKE_INSTALL_PREFIX="$INSTALL_DIR"

cmake --build . --config Release
cmake --install .

echo "HarfBuzz for macOS arm64 built successfully."

mkdir -p "$PROJECT_DIR/libs/macos-arm64"

find "$INSTALL_DIR" -name "*.a" -exec cp {} "$PROJECT_DIR/libs/macos-arm64/" \;

echo "Verifying library architecture..."
for lib in "$PROJECT_DIR/libs/macos-arm64/"*.a; do
    if [ -f "$lib" ]; then
        echo "Checking: $lib"
        lipo -info "$lib"
    fi
done

echo "Static libraries for macOS arm64 are available in $PROJECT_DIR/libs/macos-arm64/"
