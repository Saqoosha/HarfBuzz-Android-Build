set -e


HARFBUZZ_VERSION="11.1.0"
NDK_VERSION="r26c"
ANDROID_API_LEVEL=21
ABIS=("arm64-v8a" "armeabi-v7a")
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
SRC_DIR="$PROJECT_DIR/src/harfbuzz"
BUILD_DIR="$PROJECT_DIR/build"
INSTALL_DIR="$PROJECT_DIR/libs"
NDK_DIR="$PROJECT_DIR/android-ndk-$NDK_VERSION"

echo "=== HarfBuzz Android Build Configuration ==="
echo "HarfBuzz version: $HARFBUZZ_VERSION"
echo "Android NDK version: $NDK_VERSION"
echo "Android API level: $ANDROID_API_LEVEL"
echo "Target ABIs: ${ABIS[*]}"
echo "Project directory: $PROJECT_DIR"
echo "Source directory: $SRC_DIR"
echo "Build directory: $BUILD_DIR"
echo "Install directory: $INSTALL_DIR"
echo "==========================================="

if [ ! -d "$NDK_DIR" ]; then
    echo "Downloading Android NDK $NDK_VERSION..."
    cd "$PROJECT_DIR"
    
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        NDK_PLATFORM="linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        NDK_PLATFORM="darwin"
    else
        echo "Unsupported OS: $OSTYPE"
        exit 1
    fi
    
    NDK_URL="https://dl.google.com/android/repository/android-ndk-$NDK_VERSION-$NDK_PLATFORM.zip"
    wget "$NDK_URL" -O "android-ndk-$NDK_VERSION.zip"
    unzip -q "android-ndk-$NDK_VERSION.zip"
    rm "android-ndk-$NDK_VERSION.zip"
    echo "Android NDK $NDK_VERSION installed successfully."
fi

if [ ! -d "$SRC_DIR" ]; then
    echo "HarfBuzz source not found at $SRC_DIR"
    echo "Please make sure the HarfBuzz submodule is initialized with: git submodule update --init --recursive"
    exit 1
fi

mkdir -p "$BUILD_DIR"
mkdir -p "$INSTALL_DIR"

for ABI in "${ABIS[@]}"; do
    echo "Building HarfBuzz for $ABI..."
    
    case "$ABI" in
        "arm64-v8a")
            ARCH="aarch64"
            TOOLCHAIN="aarch64-linux-android"
            ;;
        "armeabi-v7a")
            ARCH="arm"
            TOOLCHAIN="arm-linux-androideabi"
            ;;
        *)
            echo "Unsupported ABI: $ABI"
            exit 1
            ;;
    esac
    
    BUILD_ABI_DIR="$BUILD_DIR/$ABI"
    INSTALL_ABI_DIR="$INSTALL_DIR/$ABI"
    mkdir -p "$BUILD_ABI_DIR"
    mkdir -p "$INSTALL_ABI_DIR"
    
    TOOLCHAIN_BIN="$NDK_DIR/toolchains/llvm/prebuilt/$NDK_PLATFORM-x86_64/bin"
    CC="$TOOLCHAIN_BIN/$ARCH-linux-android$ANDROID_API_LEVEL-clang"
    CXX="$TOOLCHAIN_BIN/$ARCH-linux-android$ANDROID_API_LEVEL-clang++"
    AR="$TOOLCHAIN_BIN/llvm-ar"
    RANLIB="$TOOLCHAIN_BIN/llvm-ranlib"
    STRIP="$TOOLCHAIN_BIN/llvm-strip"
    
    cd "$BUILD_ABI_DIR"
    
    cmake "$SRC_DIR" \
        -DCMAKE_TOOLCHAIN_FILE="$NDK_DIR/build/cmake/android.toolchain.cmake" \
        -DANDROID_ABI="$ABI" \
        -DANDROID_PLATFORM="android-$ANDROID_API_LEVEL" \
        -DCMAKE_BUILD_TYPE=Release \
        -DHB_HAVE_FREETYPE=OFF \
        -DHB_HAVE_GLIB=OFF \
        -DHB_HAVE_ICU=OFF \
        -DHB_HAVE_GRAPHITE2=OFF \
        -DBUILD_SHARED_LIBS=OFF \
        -DCMAKE_INSTALL_PREFIX="$INSTALL_ABI_DIR"
    
    cmake --build . --config Release
    cmake --install .
    
    echo "HarfBuzz for $ABI built successfully."
    
    mkdir -p "$PROJECT_DIR/libs/$ABI"
    find "$INSTALL_ABI_DIR" -name "*.a" -exec cp {} "$PROJECT_DIR/libs/$ABI/" \;
    
    echo "Static libraries for $ABI copied to $PROJECT_DIR/libs/$ABI/"
done

echo "HarfBuzz build completed successfully for all ABIs."
echo "Static libraries are available in $PROJECT_DIR/libs/"
