#!/bin/bash
# Off-device test of the t30 Data move: move, interrupted move, resume, re-run, interrupted undo, undo.
set -e
T=/tmp/bucket_test
rm -rf $T && mkdir -p $T/Data/Music
cd "$(dirname "$0")"
python3 mk.py ~/thps-vita/src/platform/pc/src/pc_assets.cpp $T/bt.cpp
g++ -O1 -o $T/bt $T/bt.cpp
# 2000 dummy files with mixed-case names like the game's, a subfolder file and a comment in the manifest
python3 - <<'EOF'
import random, os
random.seed(7)
T = "/tmp/bucket_test/Data"
names = set()
exts = [".psx", ".bmp", ".vab", ".fnt", ".pre", ".trg", ".bin"]
while len(names) < 2000:
    n = "".join(random.choice("abcdefghijklmnopqrstuvwxyzABCDEFGHIJ0123456789_") for _ in range(random.randint(3, 8)))
    names.add(n + random.choice(exts))
with open(T + "/Manifest.txt", "w") as m:
    m.write("# PS1 test manifest\n")
    for n in sorted(names):
        open(os.path.join(T, n), "w").write("data of " + n)
        m.write(n + "\n")
    open(T + "/Music/song1.str", "w").write("music")
    m.write("Music\\song1.str\n")
EOF
snap() { (cd $T/Data && find . -type f -exec md5sum {} + | sed 's|\./||' | awk '{print $1, gensub(".*/", "", 1, $2)}' | sort); }
tree() { (cd $T/Data && find . | sort | md5sum); }
snap > $T/orig.txt; tree > $T/origtree.txt
echo "--- move, cut after 700 renames"; $T/bt $T/Data 700 1; $T/bt $T/Data -1 check
echo "  top-level files left: $(find $T/Data -maxdepth 1 -type f | wc -l)"
echo "--- resume"; $T/bt $T/Data -1 1; $T/bt $T/Data -1 check
echo "  top-level files left: $(find $T/Data -maxdepth 1 -type f | wc -l) (Manifest.txt only)"
echo "  buckets: $(find $T/Data -maxdepth 1 -type d -name 'bk*' | wc -l), largest $(for d in $T/Data/bk*; do ls $d | wc -l; done | sort -n | tail -1) files"
snap > $T/moved.txt; cmp -s $T/orig.txt $T/moved.txt && echo "  same files and contents: yes" || echo "  same files and contents: NO"
echo "--- again (nothing to do)"; $T/bt $T/Data -1 1
echo "--- undo, cut after 500"; $T/bt $T/Data 500 undo; $T/bt $T/Data -1 check
echo "--- undo, finish"; $T/bt $T/Data -1 undo; $T/bt $T/Data -1 check
snap > $T/back.txt; tree > $T/backtree.txt
cmp -s $T/orig.txt $T/back.txt && echo "  contents identical to the start: yes" || echo "  contents identical: NO"
cmp -s $T/origtree.txt $T/backtree.txt && echo "  folder tree identical to the start: yes" || { echo "  folder tree identical: NO"; (cd $T/Data && find . -maxdepth 1 -type d); }
