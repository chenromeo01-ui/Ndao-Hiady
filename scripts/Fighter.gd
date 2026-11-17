extends Node2D
class_name Fighter

var facing: float = 1.0
var attack_flash: float = 0.0
var health: int = 100
var max_health: int = 100

func _process(delta: float) -> void:
    attack_flash = maxf(0.0, attack_flash - delta)
    queue_redraw()

func strike() -> void:
    attack_flash = 0.22

func take_damage(amount: int) -> void:
    health = maxi(0, health - amount)

func _draw() -> void:
    # Ombre au sol
    draw_ellipse(Vector2(0, 31), Vector2(24, 8), Color(0.02, 0.025, 0.03, 0.35))
    # Jambes et pagne
    draw_line(Vector2(-7, 7), Vector2(-12, 29), Color("#34251d"), 9.0, true)
    draw_line(Vector2(7, 7), Vector2(12, 29), Color("#34251d"), 9.0, true)
    draw_colored_polygon(PackedVector2Array([Vector2(-13,-8),Vector2(13,-8),Vector2(17,15),Vector2(-17,15)]), Color("#b34f2d"))
    # Torse, bras et tête
    draw_colored_polygon(PackedVector2Array([Vector2(-12,-25),Vector2(12,-25),Vector2(15,2),Vector2(-15,2)]), Color("#a85d38"))
    draw_line(Vector2(-11,-18), Vector2(-22,-2), Color("#a85d38"), 8.0, true)
    draw_line(Vector2(11,-18), Vector2(20,-5), Color("#a85d38"), 8.0, true)
    draw_circle(Vector2(0,-37), 12.0, Color("#8c4b30"))
    draw_arc(Vector2(0,-38), 13.0, PI, TAU, 20, Color("#211a18"), 5.0)
    # Bandeau
    draw_line(Vector2(-11,-43), Vector2(11,-43), Color("#e5b84e"), 4.0, true)
    # Épée
    var hand := Vector2(20,-8)
    var tip := hand + Vector2(32.0 * facing, -30.0 if attack_flash > 0.0 else -4.0)
    draw_line(hand, tip, Color("#d8e3e8"), 4.0, true)
    draw_line(hand + Vector2(-4,2), hand + Vector2(5,8), Color("#e3b44f"), 4.0, true)
