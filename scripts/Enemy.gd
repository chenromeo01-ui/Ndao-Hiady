extends Node2D
class_name ArenaEnemy

var enemy_kind: String = "soldier"
var health: int = 35
var max_health: int = 35
var speed: float = 72.0
var attack_cooldown: float = 0.0
var hit_flash: float = 0.0
var display_name: String = "Miaramila"

func setup(kind: String) -> void:
    enemy_kind = kind
    if kind == "boss":
        health = 180
        max_health = 180
        speed = 48.0
        display_name = "LE CHEF DES OMBRES"
    elif kind == "scout":
        health = 24
        max_health = 24
        speed = 105.0
        display_name = "Mpanafika"
    else:
        health = 42
        max_health = 42
        speed = 68.0
        display_name = "Miaramila"

func _process(delta: float) -> void:
    attack_cooldown = maxf(0.0, attack_cooldown - delta)
    hit_flash = maxf(0.0, hit_flash - delta)
    queue_redraw()

func take_damage(amount: int) -> void:
    health = maxi(0, health - amount)
    hit_flash = 0.15

func _draw() -> void:
    var boss := enemy_kind == "boss"
    var body_color := Color("#552c45") if boss else Color("#47515c")
    if hit_flash > 0.0:
        body_color = Color("#f2d5a0")
    var scale_factor := 1.55 if boss else 1.0
    draw_set_transform(Vector2(0, 31.0 * scale_factor), 0.0, Vector2(scale_factor, 0.33 * scale_factor))
    draw_circle(Vector2.ZERO, 25.0, Color(0.02,0.02,0.03,0.35))
    draw_set_transform(Vector2.ZERO, 0.0, Vector2(scale_factor, scale_factor))
    draw_line(Vector2(-7,7),Vector2(-12,29),Color("#29232a"),9.0,true)
    draw_line(Vector2(7,7),Vector2(12,29),Color("#29232a"),9.0,true)
    draw_colored_polygon(PackedVector2Array([Vector2(-14,-25),Vector2(14,-25),Vector2(16,12),Vector2(-16,12)]),body_color)
    draw_line(Vector2(-12,-18),Vector2(-23,-2),body_color,8.0,true)
    draw_line(Vector2(12,-18),Vector2(23,-2),body_color,8.0,true)
    draw_circle(Vector2(0,-37),12.0,Color("#75452f"))
    draw_line(Vector2(-11,-43),Vector2(11,-43),Color("#c69a48"),4.0,true)
    draw_line(Vector2(22,-3),Vector2(34,17),Color("#d5dce0"),3.0,true)
    draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
    var bar_width := 54.0 if boss else 42.0
    draw_rect(Rect2(-bar_width/2,-61,bar_width,5),Color("#271d24"))
    draw_rect(Rect2(-bar_width/2,-61,bar_width * float(health)/float(max_health),5),Color("#d64c48"))
