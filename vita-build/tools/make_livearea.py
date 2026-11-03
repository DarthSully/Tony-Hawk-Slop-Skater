"""The LiveArea images from the two cover pictures in C:\\VitaBuild\\TonyHawk\\livearea:
a square one (the bubble) and a tall one (the cover). Writes livearea/sce_sys/... as 8-bit
indexed PNGs (256 colours), which the VPK takes from platform/pc/dist/vita/sce_sys:

  icon0.png                      128x128, the square picture
  livearea/contents/bg.png       840x500, the tall picture centred on a blurred, stretched copy
  livearea/contents/startup.png  280x158, the cover's logo band (the gate's start button)

Usage: python make_livearea.py <livearea folder>   (needs Pillow)
"""
import os
import sys

from PIL import Image, ImageFilter


def find(folder, square):
    """The square picture (width == height) or the tall one (height > width)."""
    for name in sorted(os.listdir(folder)):
        if not name.lower().endswith((".jpg", ".jpeg", ".png")):
            continue
        im = Image.open(os.path.join(folder, name))
        w, h = im.size
        if (abs(w - h) <= 2) == square and (square or h > w):
            return im.convert("RGB"), name
    sys.exit("no %s picture in %s" % ("square" if square else "tall", folder))


def indexed(im, path):
    """256 colours, Floyd-Steinberg dithered, as an 8-bit palette PNG."""
    q = im.quantize(colors=256, method=Image.Quantize.MEDIANCUT, dither=Image.Dither.FLOYDSTEINBERG)
    os.makedirs(os.path.dirname(path), exist_ok=True)
    q.save(path, optimize=True, bits=8)
    print("%s: %dx%d, %s, %d bytes" % (path, q.size[0], q.size[1], q.mode, os.path.getsize(path)))


def centred_on_blur(im, size):
    """im scaled to the height, centred on a copy stretched to the whole size and blurred."""
    w, h = size
    back = im.resize(size, Image.LANCZOS).filter(ImageFilter.GaussianBlur(radius=max(4, h // 30)))
    fw = round(im.size[0] * h / im.size[1])
    back.paste(im.resize((fw, h), Image.LANCZOS), ((w - fw) // 2, 0))
    return back


def main():
    folder = sys.argv[1] if len(sys.argv) > 1 else os.path.join(os.path.dirname(__file__), "..", "..", "livearea")
    square, sname = find(folder, True)
    tall, tname = find(folder, False)
    print("square: %s %dx%d; tall: %s %dx%d" % (sname, *square.size, tname, *tall.size))
    out = os.path.join(folder, "sce_sys")
    indexed(square.resize((128, 128), Image.LANCZOS), os.path.join(out, "icon0.png"))
    indexed(centred_on_blur(tall, (840, 500)), os.path.join(out, "livearea", "contents", "bg.png"))
    # the logo band: the cover's full width at 280:158, centred 56% down (where the logo sits)
    tw, th = tall.size
    bh = round(tw * 158 / 280)
    top = min(max(0, round(th * 0.56) - bh // 2), th - bh)
    indexed(tall.crop((0, top, tw, top + bh)).resize((280, 158), Image.LANCZOS),
            os.path.join(out, "livearea", "contents", "startup.png"))


if __name__ == "__main__":
    main()
