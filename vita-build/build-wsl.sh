#!/bin/bash
# Builds the THPS Vita VPK in WSL. Run from this folder: bash build-wsl.sh
# Needs: VitaSDK ($VITASDK), git, python3. Output: ../thps.vpk (next to the disc image)
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
GAME_DIR="$(dirname "$HERE")"                 # C:\VitaBuild\TonyHawk as /mnt/c/...
WORK="${THPS_WORK:-$HOME/thps-vita}"
export VITASDK="${VITASDK:-/usr/local/vitasdk}"
export PATH="$VITASDK/bin:$PATH"
[ -x "$VITASDK/bin/arm-vita-eabi-gcc" ] || { echo "VitaSDK not found at $VITASDK"; exit 1; }
"$VITASDK/bin/arm-vita-eabi-gcc" --version | head -1
"$VITASDK/bin/arm-vita-eabi-nm" "$VITASDK/arm-vita-eabi/lib/libSDL2.a" 2>/dev/null | grep ' T VITA_GLES_LoadLibrary' >/dev/null \
  || { echo "SDL2 lacks vitaGL support: install sdl2_vitagl (vdpm pacman -- -S --noconfirm --ask 4 sdl2_vitagl)"; exit 1; }

# GNU v2 demangler: $GNU_DEMANGLER if set, else binutils 2.26 c++filt from tools/ (cxxfilt226 and
# libbfd-2.26.1-system.so, not in the repository: build them from binutils 2.26), copied to Linux
# disk, since /mnt/c drops exec bits
if [ -z "${GNU_DEMANGLER:-}" ]; then
  [ -f "$HERE/tools/cxxfilt226" ] || { echo "Set GNU_DEMANGLER to a GNU v2 demangler (binutils 2.26 c++filt)"; exit 1; }
  mkdir -p "$WORK/tools"
  cp "$HERE/tools/cxxfilt226" "$HERE/tools/libbfd-2.26.1-system.so" "$WORK/tools/"
  chmod +x "$WORK/tools/cxxfilt226"
  printf '#!/bin/sh\nLD_LIBRARY_PATH=%s exec %s "$@"\n' "$WORK/tools" "$WORK/tools/cxxfilt226" > "$WORK/tools/gnudem"
  chmod +x "$WORK/tools/gnudem"
  export GNU_DEMANGLER="$WORK/tools/gnudem"
fi

# the source: upstream at the base commit, plus the port's patches
if [ ! -d "$WORK/src/.git" ]; then
  git clone https://github.com/LANCommander/TonyWasAProSkater.git "$WORK/src"
fi
cd "$WORK/src"
git checkout -q -B vita-port "$(cat "$HERE/BASE")"
git -c user.name=vita-build -c user.email=vita@build am -q "$HERE"/patches/*.patch
git log --oneline -1

mkdir -p extern/thps1_retail build
cp "$GAME_DIR/extern/thps1_retail/SLUS_008.60" extern/thps1_retail/
cp "$HERE/psyq_names.tsv" build/

THPS_ARCH=vita python3 platform/pc/tools/build.py ${THPS_CLEAN:+--clean}
cp build/vita/thps.vpk "$GAME_DIR/thps.vpk"
echo "OK: $GAME_DIR/thps.vpk"
