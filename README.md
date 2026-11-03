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

Every option of `ux0:data/THPS/env.txt` is listed under [env.txt options](#envtxt-options) below.

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

## env.txt options

`ux0:data/THPS/env.txt` is a text file of `NAME=value` lines (one per line, `#` starts a comment), read at start-up.
You don't need one: the defaults are what v0.30 ships with. Options > Graphics saves resolution, widescreen,
smoothing, frame rate, 3D mode and precise 3D (PGXP) to `Settings.ini`; the matching `env.txt` options below
("Settings" in the default column) override the menu while they're in the file. An empty file named
`ux0:data/THPS/profile` turns on per-second timings in the log (`[prof]` lines).

Most performance options exist to turn one optimisation off: if something looks wrong, try them one at a time
and report which one fixes it. The debug options are for development and can slow the game down.

### Display and resolution

| option | values | default | what it does |
|---|---|---|---|
| `THPS_VITA_RES` | 512x240, 720x408, 832x472, 864x488, 960x544 | Settings (960x544) | the size the game is drawn at before it's scaled to the screen; smaller is faster |
| `THPS_WIDESCREEN` | 0, 1 | Settings (1) | 16:9 3D (1) or the PS1's 4:3 (0) |
| `THPS_FILTER` | 0, 1 | Settings (1) | smooth (1) or sharp (0) scaling to the screen |
| `THPS_VITA_FPS` | 30, 60 | Settings (60) | 30: every other frame shown (the game still runs at 60) |
| `THPS_RENDER3D` | native, psx | Settings (native) | the native 3D renderer, or the PS1's own drawing (wobble and warping included) |
| `THPS_PGXP` | 0, 1 | Settings (1) | 0: both of the next two off (the PS1's whole-pixel, affine look) |
| `THPS_GL_PRECISE` | 0, 1 | 1 | 0: polygons at the PS1's whole-pixel positions (default: sub-pixel) |
| `THPS_GL_PERSPECTIVE` | 0, 1 | 1 | 0: affine texturing like the PS1 (default: perspective-correct) |
| `THPS_GL_SCALE` | n | off | draw the screens at exactly n times the PS1's 320x240 |
| `THPS_DRAWDIST` | 50-400, full | Settings | draw distance in percent, or the entire level |
| `THPS_OBJDIST` | 50-400 | Settings | object distance in percent |
| `THPS_FOG` | 0, 1, 2 | Settings | fog: normal, light, off |
| `THPS_SHADOWS` | 0, 1 | Settings | the skaters' shadows: the PS1's or the Dreamcast's |
| `THPS_GLOWS` | retail | off | draw light glows the retail way instead of the port's round ones |
| `THPS_WINDOW` | WxH | - | PC builds only: window size (no effect on the Vita) |
| `THPS_SCALE` | n | 3 | PC builds only: headless window size (no effect on the Vita) |
| `THPS_MSAA` | 0, 2, 4, 8 | - | PC builds only: antialiasing (the Vita has none) |
| `THPS_VSYNC` | 0, 1 | - | PC builds only: VSync (the Vita is always synced) |
| `THPS_HEADLESS` | 1 | - | PC builds only: no visible window (automated runs) |

### Rendering and performance

| option | values | default | what it does |
|---|---|---|---|
| `THPS_R3D_BATCH` | 0, 1 | 1 | 0: 3D faces drawn in small groups as before batching (slower) |
| `THPS_R3D_PREPASS` | 0, 1 | 1 | 0: opaque faces in one pass (a little faster, decals can flicker) |
| `THPS_GL_NODISCARD` | 0, 1 | 1 | 0: no faster shader for solid surfaces without see-through texels |
| `THPS_GL_DEPTHFS` | 0, 1 | 1 | 0: the depth pass uses the full texture shader instead of a texture-free one |
| `THPS_GL_HALF` | 0, 1 | 1 | 0: colour maths of solid surfaces in full precision instead of half |
| `THPS_GL_FBCACHE` | 0, 1 | 1 | 0: bind the render target again at every draw (old behaviour) |
| `THPS_GL_LAYERVBO` | 0, 1 | 1 | 0: a 3D layer's vertices copied at every draw instead of once into graphics memory |
| `THPS_R3D_NEARDROP` | 1 | off | drop faces crossing the near plane as the PS1 did (default: clip them) |
| `THPS_R3D_RETAILFADE` | 1 | off | leave fade-to-colour levels (Downhill Jam, Streets, menus) to the PS1 code |
| `THPS_FAR_RANGE` | n | 30000 | entire-level draw distance: items reaching past n take the precise path |
| `THPS_FAST` | 1 | off | don't hold the game to 60 Hz (runs as fast as it can) |

### Textures and shaders

| option | values | default | what it does |
|---|---|---|---|
| `THPS_GL_TEXCACHE` | 0, 1 | 1 | 0: no decoded texture cache (every texel looked up per pixel: much slower) |
| `THPS_GL_INPLACE` | 0, 1 | 1 | 0: textures written through vitaGL's copies instead of in place |
| `THPS_GL_DECODE_THREADS` | 0-3 | 3 | threads on cores 1-3 that decode texture pages with the game thread; 0: game thread alone |
| `THPS_GL_DECODEMS` | n | 25 | ms of texture decoding a frame may spend after the first 2 pages |
| `THPS_GL_WARMFRAMES` | n | 30 | frames after a loading screen that decode every page they draw, uncapped; 0: off |
| `THPS_GL_SAMEBYTES` | 0, 1 | 1 | 0: texture writes of unchanged bytes are done anyway |
| `THPS_GL_PRECISEINV` | 0, 1 | 1 | 0: texture writes reach cached pages by 16x16 blocks instead of exact areas |
| `THPS_GL_PARTIAL` | 0, 1 | 1 | 0: changed cached pages are thrown away instead of updated in place |
| `THPS_GL_USEDBOX` | 0, 1 | 1 | 0: a write anywhere on a page counts, even where no face reads |
| `THPS_GL_SHADERCACHE` | 0, 1 | 1 | 0: shaders compiled at every start instead of loaded from ux0:data/THPS/shaders |
| `THPS_GL_SELFTEST` | 0, 1 | 1 | 0: skip the start-up check of the texture paths |

### Movies and audio

| option | values | default | what it does |
|---|---|---|---|
| `THPS_FMV_THREAD` | 0, 1 | 1 | 0: movie pictures and level video screens decoded by the game thread alone |
| `THPS_MOVIES` | 0 | on | skip every movie |
| `THPS_AUDIO` | 0 | on | no sound |
| `THPS_AUDIO_DUMP` | file | off | also write the mixed sound as raw 16-bit stereo 44.1 kHz to that file |

### Loading and files

| option | values | default | what it does |
|---|---|---|---|
| `THPS_FILE_DIRECT` | 0, 1 | 1 | 0: game files read with the C library as before (slower on the card) |
| `THPS_DATA_BUCKETS` | 0, 1, undo | 1 | 0: leave Data's files where they are; undo: move them back out of the bk00-bk63 subfolders |
| `THPS_DATA_BUCKETS_SECS` | n | 60 | the most seconds one start spends sorting Data (the rest at the next start) |
| `THPS_DATA_DIR` | path | ux0:data/THPS/Data | where the extracted game files are |
| `THPS_DISC` | path | - | the disc image for the first-start extraction (a .gdi: the Dreamcast disc) |
| `THPS_MODS` | paths; none | - | extra mod folders (';'-separated); none: no mods at all |
| `THPS_SAVE_DIR` | path | ux0:data/THPS | where saves go |

### Debugging and logging (debug only)

| option | values | default | what it does |
|---|---|---|---|
| `THPS_GLSTATS` | 1 | off | renderer statistics in the log every 60 frames |
| `THPS_GL_GPUTIME` | 1 | off | log the GPU time per frame ([gpu]); slows the game |
| `THPS_LOG_SYNC` | 1 | off | write and sync every log line on its own thread (slow; for crashes that take the console down) |
| `THPS_R3DSTATS` | 1 | off | native 3D statistics once a second |
| `THPS_R3D_VERIFY` | 1 | off | check the 3D renderer's maths against the PS1's |
| `THPS_R3D_NCLIP` | 1 | off | back-face tests the PS1's way (comparison) |
| `THPS_R3D_PROBE` | frame,x,y | off | log the 3D faces covering one screen point on one frame |
| `THPS_R3D_DUMP` | 1 | off | with THPS_SHOT: also dump the 3D faces as text |
| `THPS_GL_FLAT` | 1 | off | vertex colours only, no textures (a measurement) |
| `THPS_GL_FASTVAR` | 1-4 | 0 | variants of the texture shader (a measurement) |
| `THPS_GPUSTATS` | 1 | off | polygon counts per frame |
| `THPS_GPUTRACE` | frame | off | log fills and drawing-state changes on that frame |
| `THPS_GPUDUMP` | from-to | off | log every triangle submitted in those frames |
| `THPS_GPUBT` | frame,x0,y0,x1,y1 | off | log a backtrace for the first triangle in that box on that frame |
| `THPS_TRACE` | 1 | off | log songs, movies, the game's debug prints and player 1's actions |
| `THPS_TRACE_CULL` | 1 | off | frustum-culling trace |
| `THPS_TRACE_RENDER` | 1 | off | renderer trace |
| `THPS_TRACE_SOUND` | 1 | off | sound channel, bank and reverb trace (with THPS_TRACE=1) |
| `THPS_STRICT` | 1 | off | stop on a call to an unimplemented function |
| `THPS_LOWMEM_FATAL` | 1 | off | crash on a read near address 0 instead of tolerating it |
| `THPS_DETERMINISTIC` | 1 | off | a virtual clock: identical runs every time |
| `THPS_POKE` | name[+off]:value,... | off | write values into game globals every frame (e.g. Cheat_LevelSelect:1) |
| `THPS_WATCH` | addr | off | PC builds only: hardware watchpoint on a word |
| `THPS_FRAMES` | n | off | quit after n frames |
| `THPS_SHOT` | f1,f2,... | off | save screenshots (and VRAM) at those frames |
| `THPS_SHOTDIR` | path | . | where THPS_SHOT saves |
| `THPS_INPUT` | frame:mask,... | off | scripted pad input for player 1 |
| `THPS_KEYS` | frame:Key+Key,... | off | scripted keyboard input |
| `THPS_NOGAMEPAD` | 1 | off | ignore connected gamepads (scripted runs) |
| `THPS_DBG_FILL` | bbggrr | off | screen clears in that colour, to show gaps |
| `THPS_DBG_NOCLIP` | 1 | off | ignore the drawing area's clipping |
| `THPS_DBG_NOSEMI` | 1 | off | draw semi-transparent primitives opaque |

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
