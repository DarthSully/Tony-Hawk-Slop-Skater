# Tony Hawk Slop Skater

**Tony Hawk's Pro Skater (PS1, 1999) running natively on the PlayStation Vita**, built from the community
**decompilation of the PS1 game** (SLUS-00860): the PS1's own code, recompiled for the Vita's ARM CPU, with a
native OpenGL ES renderer through vitaGL. No emulator.

> This repository contains **no game code from the retail disc, no game assets and no disc images**. You need your
> own copy of Tony Hawk's Pro Skater (USA, SLUS-00860). Don't ask for, and don't share, game files.

## Features

- All of THPS1 (career, single session, free skate, 2 player), from the PS1 game's decompiled code.
- Native 3D renderer: the PS1's polygons drawn as real 3D with a depth buffer, perspective-correct textures and
  sub-pixel vertices (PGXP-style), so no wobble and no texture warping.
- **16:9 widescreen** at the Vita's native **960x544**, or lighter render sizes (864x488, 832x472, 720x408,
  512x240) for a steadier 60 fps.
- **Options > Graphics** on the Vita: render resolution, widescreen, smoothing, 60 or locked 30 fps,
  native or PlayStation-style 3D, precise 3D (PGXP), draw distance, fog.
- Fast loading: game files read straight from the memory card, sorted into subfolders on the first start.
- Shaders compiled once and kept on the card; boots in a few seconds after the first start.
- Texture decoding, movie decoding and loading spread over the Vita's spare CPU cores (core 3 with CapUnlocker).
- One log file per start in `ux0:data/THPS/logs`, plus an optional per-second performance profile.
- Every optimisation has an `env.txt` switch to turn it off.

## Installing

You need:

1. A Vita or PS TV with HENkaku/h-encore/Ensō and **VitaShell**.
2. **`ur0:data/libshacccg.suprx`**, the shader compiler from your console's firmware. Extract it with
   [ShaRKBR33D](https://github.com/Rinnegatamante/ShaRKBR33D) (run it once; it puts the file there).
3. **Your own disc image** of Tony Hawk's Pro Skater (USA) as a raw `.bin` (MODE2/2352).

Then:

1. Download `thps.vpk` from the [v0.30 release](../../releases/tag/v0.30) and install it with VitaShell.
2. Copy your disc image to `ux0:data/THPS/thps1.bin` (or keep its name `Tony Hawk's Pro Skater (USA).bin`).
3. Start the game. **The first start is slow**: it extracts the game's files to `ux0:data/THPS/Data`
   (about 630 MB; the disc image can be deleted afterwards), sorts them into subfolders (30-40 s) and compiles
   the shaders (about 10 s). Later starts take a few seconds.
4. Optional: [CapUnlocker](https://github.com/GrapheneCt/CapUnlocker) gives the game a fourth CPU core.

Saves, `Settings.ini` and logs are in `ux0:data/THPS`.

## Settings

**Options > Graphics** (applies after a restart; the menu offers one):

| setting | choices | note |
|---|---|---|
| Render resolution | 512x240, 720x408, 832x472, 864x488, **960x544** | 864x488 or 832x472 hold 60 fps best |
| Widescreen | **on** / off | 16:9 3D |
| Smoothing | **on** / off | smooth scaling to the screen |
| Frame rate | **60** / locked 30 | |
| 3D | **native** / PlayStation | PlayStation = the PS1's own way, with its wobble |
| Precise 3D | **on** / off | sub-pixel vertices, perspective-correct textures |

`ux0:data/THPS/env.txt` (one `NAME=value` per line) overrides them for testing, e.g. `THPS_VITA_RES=864x488`,
`THPS_FILTER=0`, `THPS_VITA_FPS=30`. `THPS_GLSTATS=1` adds renderer statistics to the log; an empty file
`ux0:data/THPS/profile` adds per-second timings. Switches that turn single optimisations off (if something looks
wrong, try these and report which one fixes it): `THPS_R3D_BATCH=0`, `THPS_R3D_PREPASS=0`, `THPS_GL_NODISCARD=0`,
`THPS_GL_DEPTHFS=0`, `THPS_GL_HALF=0`, `THPS_GL_USEDBOX=0`, `THPS_GL_PARTIAL=0`, `THPS_GL_PRECISEINV=0`,
`THPS_GL_SAMEBYTES=0`, `THPS_FMV_THREAD=0`, `THPS_GL_DECODE_THREADS=0`, `THPS_FILE_DIRECT=0`,
`THPS_GL_SHADERCACHE=0`, `THPS_DATA_BUCKETS=0` (or `=undo` to move the Data files back).

## Known bugs and limitations

- **Native 960x544 doesn't hold 60 fps** in busy levels (about 45-50 fps: the GPU is the limit). Use 864x488 or
  832x472 for a near-steady 60.
- **Short hitches on loading screens** (0.3-1.3 s frames while a level loads).
- Levels with video screens could dip to 15-30 fps; fixed in the latest build, confirmation welcome.
- Full-screen movies were slow (about 14 fps); sped up in the latest build, confirmation welcome.
- Occasional flicker of decals (graffiti, lighting) on some surfaces; much reduced, report where you see it.
- Graphics settings need a restart; there's no automatic resolution yet.
- No anti-aliasing. The PS1's reverb is approximated (in the decomp's runtime).
- An animated texture may change a frame early.
- The first start is slow (see Installing).

Please report bugs with the log from `ux0:data/THPS/logs` (and a crash dump `ux0:data/*.psp2dmp` if it crashed).

## Building

The Vita port is a series of patches on top of the decompilation's repository
([TonyWasAProSkater](https://github.com/LANCommander/TonyWasAProSkater)), in `vita-build/patches`, applied by
`vita-build/build-wsl.sh` to upstream commit `ed0ac5149c744177781879cc501d1e626533a649` (see `vita-build/BASE`).

You need (Linux or WSL):

- [VitaSDK](https://vitasdk.org) in `/usr/local/vitasdk` with `vitaGL`, `sdl2_vitagl`, `libmathneon` and
  `vitaShaRK` (`vdpm pacman -- -S --noconfirm --needed <pkg>`), git, python3.
- From your own disc: `SLUS_008.60` (the executable; `dumpsxiso` from
  [mkpsxiso](https://github.com/Lameguy64/mkpsxiso) extracts it), which the build reads the function layout from.
- The decompilation's other build inputs: `build/psyq_names.tsv` (made by its `tools/psyq_sigmatch.py` from the
  [ghidra_psx_ldr](https://github.com/lab313ru/ghidra_psx_ldr) Psy-Q signatures) and a GNU v2 C++ demangler
  (binutils 2.26 `c++filt`, or Ghidra's `DemanglerGnu`), set as `GNU_DEMANGLER`.

```
bash vita-build/build-wsl.sh      # clones upstream, applies the patches, builds thps.vpk (about 30 s)
```

## Credits

- **Pat Hartl** and **LANCommander**: the [matching decompilation of the PS1 game](https://github.com/LANCommander/THPS)
  and [TonyWasAProSkater](https://github.com/LANCommander/TonyWasAProSkater), the repository with the decompiled
  code and the runtime that stands in for the PS1's hardware, which these patches build on. All the game code here
  is their work; this project adds the Vita version.
- **Neversoft** and **Activision**: the original game. Tony Hawk's Pro Skater © 1999 Activision, Inc. and
  Neversoft Entertainment.
- **Rinnegatamante**: [vitaGL](https://github.com/Rinnegatamante/vitaGL) (LGPL-3.0),
  [vitaShaRK](https://github.com/Rinnegatamante/vitaShaRK) (LGPL-3.0), the
  [math-neon port](https://github.com/Rinnegatamante/math-neon), ShaRKBR33D.
- **Northfear**: [SDL2 for the Vita with vitaGL](https://github.com/Northfear/SDL) (zlib).
- **The VitaSDK team**: [VitaSDK](https://vitasdk.org) (toolchain, headers and stubs).
- **Dominic Szablewski**: [PL_MPEG](https://github.com/phoboslab/pl_mpeg) (MIT), for the Dreamcast films.
- **xyzz**: [vita-parse-core](https://github.com/xyzz/vita-parse-core), used to read crash dumps.
- **GrapheneCt**: CapUnlocker.
- Vita port: **Sully** ([DarthSully](https://github.com/DarthSully)), with Claude (AI assistant).

vitaGL and vitaShaRK are LGPL-3.0 and statically linked into `thps.vpk`; this repository's sources and build
steps let you rebuild it against your own copies of them.

## Legal

This project is not affiliated with or endorsed by Activision, Neversoft or Sony. It contains no game assets
(levels, models, textures, sounds, music, movies) and no original executable; the game reads its assets from your
own disc. The decompiled game code comes from the upstream projects above, under their terms.
