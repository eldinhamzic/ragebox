extends RefCounted
class_name RageboxPixelArtKit

# Shared art-only drawing utilities. No collisions, triggers or gameplay logic.
# Original element implementations remain authoritative for behavior.
const THEMES := ["Grassland", "White Brick Interior", "Night Soil", "Desert", "Asphalt", "Warehouse", "Snow", "Rainy Soil", "Rooftop", "Stone Cave"]
const SKY := ["#86cfe9","#343c50","#111b36","#eec485","#a3bac7","#626a72","#b1d7e8","#536b7c","#7593b2","#323646"]
const BASE := ["#8d5b3d","#d5dde0","#684936","#d8a65b","#464d59","#826e58","#dce9ed","#594939","#68707d","#66626b"]
const DARK := ["#503a2e","#818e98","#352f3c","#9c7847","#262e38","#493e36","#8aaebc","#302f35","#313b4d","#393642"]
const TOP := ["#82bd57","#f4f5eb","#456b5a","#f2d289","#6b7786","#bf9e68","#fbffff","#648466","#adb2b8","#9f9a92"]

static func color(hex: String) -> Color:
    return Color(hex)

static func pix(c: CanvasItem, x: float, y: float, w: float, h: float, shade: Color) -> void:
    c.draw_rect(Rect2(x, y, w, h), shade)

static func background(c: CanvasItem, theme: int) -> void:
    var t := posmod(theme, THEMES.size())
    pix(c, 0, 0, 960, 450, color(SKY[t]))
    pix(c, 0, 0, 960, 100, color(SKY[t]).lightened(0.12))
    if t == 1 or t == 5 or t == 9:
        for x in range(0, 960, 96):
            for y in range(0, 450, 48):
                pix(c, x + (48 if int(y / 48) % 2 == 1 else 0), y, 92, 44, color(DARK[t]).darkened(0.20))
                pix(c, x + 2 + (48 if int(y / 48) % 2 == 1 else 0), y + 3, 86, 37, color(BASE[t]).darkened(0.1))
    elif t == 8:
        for x in range(0, 960, 110):
            var h := 65 + (int(x / 110) % 4) * 23
            pix(c, x, 450 - h, 90, h, color(DARK[t]).lightened(0.25))
            for wx in range(x + 13, x + 80, 24):
                for wy in range(450 - h + 16, 425, 27):
                    pix(c, wx, wy, 8, 11, color("#f6d88d"))
    else:
        var far := color(DARK[t]).lightened(0.50)
        var near := color(DARK[t]).lightened(0.25)
        for x in range(0, 960, 120):
            pix(c, x, 320 + (int(x / 120) % 3) * 24, 120, 130, far)
            pix(c, x + 45, 365 + (int(x / 120) % 2) * 25, 115, 90, near)
        if t == 2:
            pix(c, 795, 72, 44, 44, color("#f1e6be"))
        elif t != 7:
            pix(c, 790, 69, 50, 50, color("#ffe09b"))
        if t == 7:
            for x in range(12, 960, 79):
                for y in range(35, 450, 95):
                    c.draw_line(Vector2(x + 9, y), Vector2(x - 1, y + 25), color("#a7ccd9"), 2)

static func ground(c: CanvasItem, r: Rect2, theme: int) -> void:
    var t := posmod(theme, THEMES.size())
    var base := color(BASE[t])
    var shade := color(DARK[t])
    var trim := color(TOP[t])
    c.draw_rect(r, shade)
    pix(c, r.position.x, r.position.y + 12, r.size.x, r.size.y - 12, base)
    pix(c, r.position.x, r.position.y, r.size.x, 9, trim)
    pix(c, r.position.x, r.position.y + 9, r.size.x, 4, shade.lightened(0.15))
    for x in range(int(r.position.x), int(r.end.x), 24):
        var offset := int(x / 24)
        if t == 1 or t == 5 or t == 9:
            pix(c, x + (offset % 2) * 6, r.position.y + 25, 18, 2, shade)
            pix(c, x + 12, r.position.y + 50, 2, 19, shade)
        elif t == 4 or t == 8:
            pix(c, x + 4, r.position.y + 28, 13, 2, shade)
            if offset % 4 == 0:
                pix(c, x + 17, r.position.y + 47, 2, 14, trim)
        elif t == 6:
            pix(c, x + 5, r.position.y + 30, 14, 5, trim)
            pix(c, x + 12, r.position.y + 57, 9, 3, shade)
        else:
            pix(c, x + 5, r.position.y + 28 + (offset % 3) * 4, 11, 4, shade)
            pix(c, x + 13, r.position.y + 59, 6, 5, trim.darkened(0.15))
        if t == 0 or t == 2 or t == 7:
            if offset % 3 == 0:
                pix(c, x + 10, r.position.y - 5, 3, 9, trim.lightened(0.3))

static func platform(c: CanvasItem, pos: Vector2, width: float, theme: int) -> void:
    ground(c, Rect2(pos, Vector2(width, 18)), theme)
    pix(c, pos.x + 3, pos.y + 18, width - 6, 5, color(DARK[posmod(theme, THEMES.size())]))

static func prop(c: CanvasItem, kind: String, at: Vector2, theme: int = 0) -> void:
    # Canonical pixel-art previews for existing gameplay elements.
    var t := posmod(theme, THEMES.size())
    var outline := color("#263244")
    var metal := color("#b0bdc6")
    var glow := color("#f0d178")
    var x := at.x
    var y := at.y
    match kind:
        "hammer":
            pix(c, x - 7, y - 32, 14, 52, outline)
            pix(c, x - 4, y - 30, 8, 48, color("#b9824e"))
            pix(c, x - 30, y - 48, 60, 25, outline)
            pix(c, x - 26, y - 44, 52, 16, metal)
            pix(c, x - 24, y - 42, 32, 5, color("#e4ebee"))
        "piano":
            pix(c, x - 37, y - 43, 74, 50, outline)
            pix(c, x - 33, y - 39, 66, 35, color("#555169"))
            for k in range(7):
                pix(c, x - 30 + k * 9, y - 4, 8, 13, color("#edf1e6"))
                if k % 3 != 2:
                    pix(c, x - 25 + k * 9, y - 4, 4, 8, outline)
            pix(c, x - 32, y + 9, 8, 17, outline)
            pix(c, x + 24, y + 9, 8, 17, outline)
        "spikes":
            for i in range(3):
                var sx := x - 27 + i * 20
                c.draw_colored_polygon(PackedVector2Array([Vector2(sx, y + 14), Vector2(sx + 10, y - 21), Vector2(sx + 20, y + 14)]), outline)
                c.draw_colored_polygon(PackedVector2Array([Vector2(sx + 5, y + 10), Vector2(sx + 10, y - 13), Vector2(sx + 15, y + 10)]), metal)
        "fly":
            pix(c, x - 18, y - 15, 15, 12, color("#ddebf1"))
            pix(c, x + 3, y - 15, 15, 12, color("#ddebf1"))
            pix(c, x - 9, y - 7, 18, 17, outline)
            pix(c, x - 5, y - 4, 10, 10, glow)
            pix(c, x + 5, y - 2, 4, 4, color("#fce5dc"))
        "dragon":
            pix(c, x - 36, y - 9, 60, 27, outline)
            pix(c, x - 26, y - 5, 43, 17, color("#6fba77"))
            c.draw_colored_polygon(PackedVector2Array([Vector2(x - 13, y - 11), Vector2(x + 2, y - 45), Vector2(x + 14, y - 10)]), color("#45947e"))
            pix(c, x + 20, y - 16, 28, 28, outline)
            pix(c, x + 25, y - 11, 23, 19, color("#76c47d"))
            pix(c, x + 38, y - 4, 4, 4, glow)
            for k in range(3):
                pix(c, x - 24 + k * 16, y - 16, 9, 10, glow)
        "lift":
            pix(c, x - 33, y - 3, 66, 12, outline)
            pix(c, x - 29, y, 58, 5, metal)
            pix(c, x - 30, y - 53, 6, 50, color("#929eab"))
            pix(c, x + 24, y - 53, 6, 50, color("#929eab"))
            pix(c, x - 30, y - 57, 60, 8, glow)
        "bridge":
            for k in range(4):
                pix(c, x - 46 + k * 23, y - 3, 21, 14, outline)
                pix(c, x - 44 + k * 23, y - 1, 17, 8, color(BASE[t]))
        "spring":
            pix(c, x - 25, y + 14, 50, 7, outline)
            for k in range(4):
                pix(c, x - 16 + (k % 2) * 9, y - 21 + k * 9, 31, 5, metal)
            pix(c, x - 24, y - 29, 48, 9, glow)
        "button":
            pix(c, x - 22, y + 8, 44, 13, outline)
            pix(c, x - 17, y + 3, 34, 7, color("#718593"))
            pix(c, x - 12, y - 8, 24, 11, color("#e77766"))
        "wall":
            for ry in range(4):
                for rx in range(2):
                    pix(c, x - 24 + rx * 24 + (ry % 2) * 4, y - 54 + ry * 17, 22, 15, outline)
                    pix(c, x - 22 + rx * 24 + (ry % 2) * 4, y - 52 + ry * 17, 18, 11, color(BASE[t]))
        "lightning":
            c.draw_colored_polygon(PackedVector2Array([Vector2(x - 5,y - 47),Vector2(x + 15,y - 47),Vector2(x + 2,y - 18),Vector2(x + 19,y - 18),Vector2(x - 14,y + 21),Vector2(x - 3,y - 10),Vector2(x - 18,y - 10)]), glow)
        "falling_ground":
            ground(c, Rect2(x - 35, y - 10, 70, 30), t)
        "moving_platform", "rising_platform", "stable_platform":
            platform(c, Vector2(x - 36, y - 4), 72, t)
        _:
            pix(c, x - 18, y - 18, 36, 36, outline)
