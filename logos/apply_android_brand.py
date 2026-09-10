"""Paint Trovey clipboard mark onto Capacitor Android launcher + splash assets."""

from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[1]
PWA = ROOT / "pwa"
RES = ROOT / "android" / "app" / "src" / "main" / "res"

LAUNCHER = {
    "mipmap-mdpi": 48,
    "mipmap-hdpi": 72,
    "mipmap-xhdpi": 96,
    "mipmap-xxhdpi": 144,
    "mipmap-xxxhdpi": 192,
}
FOREGROUND = {
    "mipmap-mdpi": 108,
    "mipmap-hdpi": 162,
    "mipmap-xhdpi": 216,
    "mipmap-xxhdpi": 324,
    "mipmap-xxxhdpi": 432,
}


def circle(img: Image.Image) -> Image.Image:
    mask = Image.new("L", img.size, 0)
    ImageDraw.Draw(mask).ellipse((0, 0, img.size[0] - 1, img.size[1] - 1), fill=255)
    out = Image.new("RGBA", img.size, (0, 0, 0, 0))
    out.paste(img.convert("RGBA"), mask=mask)
    return out


def splash(size: tuple[int, int], mark: Image.Image, fill: tuple[int, int, int, int]) -> Image.Image:
    w, h = size
    canvas = Image.new("RGBA", (w, h), fill)
    side = max(64, int(min(w, h) * 0.28))
    icon = mark.resize((side, side), Image.Resampling.LANCZOS).convert("RGBA")
    canvas.paste(icon, ((w - side) // 2, (h - side) // 2), icon)
    return canvas.convert("RGB")


def main() -> None:
    any_icon = Image.open(PWA / "icons" / "Icon-512.png").convert("RGBA")
    maskable = Image.open(PWA / "icons" / "Icon-maskable-512.png").convert("RGBA")
    fill = any_icon.getpixel((0, 0))

    for folder, px in LAUNCHER.items():
        dest = RES / folder
        dest.mkdir(parents=True, exist_ok=True)
        icon = any_icon.resize((px, px), Image.Resampling.LANCZOS).convert("RGBA")
        icon.save(dest / "ic_launcher.png")
        circle(icon).save(dest / "ic_launcher_round.png")

    for folder, px in FOREGROUND.items():
        dest = RES / folder
        dest.mkdir(parents=True, exist_ok=True)
        maskable.resize((px, px), Image.Resampling.LANCZOS).convert("RGBA").save(
            dest / "ic_launcher_foreground.png"
        )

    for path in RES.rglob("splash.png"):
        with Image.open(path) as current:
            size = current.size
        splash(size, any_icon, fill).save(path)
        print(f"splash {path.relative_to(RES)} {size[0]}x{size[1]}")

    hex_bg = f"#{fill[0]:02X}{fill[1]:02X}{fill[2]:02X}"
    bg = RES / "values" / "ic_launcher_background.xml"
    bg.write_text(
        '<?xml version="1.0" encoding="utf-8"?>\n'
        "<resources>\n"
        f'    <color name="ic_launcher_background">{hex_bg}</color>\n'
        "</resources>\n",
        encoding="utf-8",
    )
    print(f"android launcher + splash branded ({hex_bg})")


if __name__ == "__main__":
    main()
