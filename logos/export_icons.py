"""Rasterize the Trovey Horizon-T mark to PWA / favicon sizes."""

from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw

PRIMARY = (14, 110, 138, 255)
SUN = (217, 119, 6, 255)
PAPER = (247, 251, 254, 255)

ROOT = Path(__file__).resolve().parent
WEB = ROOT.parent / "app" / "web"
ICONS = WEB / "icons"


def _box(size: int, x: float, y: float, w: float, h: float, inset: float) -> tuple[int, int, int, int]:
    inner = size * (1 - 2 * inset)
    left = size * inset
    return (
        int(left + x / 512 * inner),
        int(left + y / 512 * inner),
        int(left + (x + w) / 512 * inner),
        int(left + (y + h) / 512 * inner),
    )


def render(size: int, *, maskable: bool = False, rounded: bool = False) -> Image.Image:
    img = Image.new("RGBA", (size, size), PRIMARY)
    draw = ImageDraw.Draw(img)
    inset = 0.18 if maskable else 0.0
    sun = _box(size, 184, 104, 144, 144, inset)
    bar = _box(size, 80, 264, 352, 64, inset)
    stem = _box(size, 224, 264, 64, 164, inset)
    draw.ellipse(sun, fill=SUN)
    draw.rounded_rectangle(bar, radius=max(2, (bar[3] - bar[1]) // 2), fill=PAPER)
    draw.rounded_rectangle(stem, radius=max(2, (stem[2] - stem[0]) // 2), fill=PAPER)
    if rounded:
        mask = Image.new("L", (size, size), 0)
        ImageDraw.Draw(mask).rounded_rectangle((0, 0, size - 1, size - 1), radius=int(size * 0.22), fill=255)
        out = Image.new("RGBA", (size, size), (0, 0, 0, 0))
        out.paste(img, mask=mask)
        return out
    return img


def save_png(img: Image.Image, path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    img.save(path, "PNG")
    print(f"{path}  {path.stat().st_size} bytes")


def main() -> None:
    ICONS.mkdir(parents=True, exist_ok=True)
    export = ROOT / "export"
    export.mkdir(exist_ok=True)

    for px in (16, 32, 48, 96, 180, 192, 512, 1024, 2048):
        save_png(render(px), export / f"icon-{px}.png")
        save_png(render(px), export / f"logo-{px}.png")

    save_png(render(16), WEB / "favicon-16x16.png")
    save_png(render(32), WEB / "favicon-32x32.png")
    save_png(render(32), WEB / "favicon.png")
    save_png(render(96), WEB / "favicon-96x96.png")
    save_png(render(180), WEB / "apple-touch-icon.png")
    save_png(render(192), ICONS / "Icon-192.png")
    save_png(render(512), ICONS / "Icon-512.png")
    save_png(render(192, maskable=True), ICONS / "Icon-maskable-192.png")
    save_png(render(512, maskable=True), ICONS / "Icon-maskable-512.png")
    save_png(render(512, rounded=True), ICONS / "icon-rounded.png")

    ico = Image.new("RGBA", (48, 48), PRIMARY)
    ico.paste(render(48))
    ico_path = WEB / "favicon.ico"
    ico.save(ico_path, sizes=[(16, 16), (32, 32), (48, 48)])
    print(f"{ico_path}  {ico_path.stat().st_size} bytes")


if __name__ == "__main__":
    main()
