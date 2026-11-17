extends Node2D

const FighterScript = preload("res://scripts/Fighter.gd")
const EnemyScript = preload("res://scripts/Enemy.gd")

var hero: Fighter
var enemies: Array[ArenaEnemy] = []
var attack_timer: float = 0.0
var game_over: bool = false
var victory: bool = false
var message_label: Label
var health_label: Label
var score_label: Label
var restart_button: Button
var hero_damage_cooldown: float = 0.0
var score: int = 0
var arena_width: float = 1280.0
var arena_height: float = 720.0

func _ready() -> void:
    _setup_input()
    hero = FighterScript.new()
    hero.position = Vector2(330, 520)
    add_child(hero)
    _spawn_enemy("scout", Vector2(790, 500))
    _spawn_enemy("soldier", Vector2(970, 525))
    _spawn_enemy("boss", Vector2(1110, 480))
    _build_hud()
    queue_redraw()

func _setup_input() -> void:
    _add_action("move_left", KEY_A)
    _add_action("move_right", KEY_D)
    _add_action("move_up", KEY_W)
    _add_action("move_down", KEY_S)
    _add_action("attack", KEY_SPACE)

func _add_action(action_name: String, key: int) -> void:
    if not InputMap.has_action(action_name):
        InputMap.add_action(action_name)
        var event := InputEventKey.new()
        event.physical_keycode = key
        InputMap.action_add_event(action_name, event)

func _spawn_enemy(kind: String, at: Vector2) -> void:
    var enemy: ArenaEnemy = EnemyScript.new()
    enemy.setup(kind)
    enemy.position = at
    add_child(enemy)
    enemies.append(enemy)

func _build_hud() -> void:
    var layer := CanvasLayer.new()
    add_child(layer)
    var panel := ColorRect.new()
    panel.color = Color(0.035,0.055,0.08,0.82)
    panel.position = Vector2(22,18)
    panel.size = Vector2(390,86)
    layer.add_child(panel)
    var title := Label.new()
    title.text = "NDAO HIADY  •  AFO'KASOKA"
    title.position = Vector2(42,25)
    title.add_theme_font_size_override("font_size",25)
    title.add_theme_color_override("font_color",Color("#f3d28a"))
    layer.add_child(title)
    health_label = Label.new()
    health_label.position = Vector2(42,61)
    health_label.add_theme_font_size_override("font_size",19)
    layer.add_child(health_label)
    score_label = Label.new()
    score_label.position = Vector2(285,61)
    score_label.add_theme_font_size_override("font_size",19)
    layer.add_child(score_label)
    message_label = Label.new()
    message_label.text = "MORONDAVA  •  ALLÉE DES BAOBABS"
    message_label.position = Vector2(420,28)
    message_label.size = Vector2(520,42)
    message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    message_label.add_theme_font_size_override("font_size",21)
    message_label.add_theme_color_override("font_color",Color("#f5e8cf"))
    layer.add_child(message_label)
    _add_touch_button(layer, "◀", Vector2(36, 595), "move_left")
    _add_touch_button(layer, "▶", Vector2(128, 595), "move_right")
    _add_touch_button(layer, "▲", Vector2(82, 510), "move_up")
    _add_touch_button(layer, "▼", Vector2(82, 635), "move_down")
    var attack_button := Button.new()
    attack_button.text = "ÉPÉE"
    attack_button.position = Vector2(1090,565)
    attack_button.size = Vector2(145,105)
    attack_button.add_theme_font_size_override("font_size",24)
    attack_button.add_theme_color_override("font_color",Color("#fff0d0"))
    attack_button.pressed.connect(_attack)
    layer.add_child(attack_button)
    restart_button = Button.new()
    restart_button.text = "REJOUER"
    restart_button.position = Vector2(500, 390)
    restart_button.size = Vector2(280, 90)
    restart_button.add_theme_font_size_override("font_size", 30)
    restart_button.add_theme_color_override("font_color", Color("#fff0d0"))
    restart_button.pressed.connect(_restart_game)
    restart_button.visible = false
    layer.add_child(restart_button)
    _refresh_hud()

func _add_touch_button(layer: CanvasLayer, caption: String, at: Vector2, action_name: String) -> void:
    var button := Button.new()
    button.text = caption
    button.position = at
    button.size = Vector2(82,76)
    button.add_theme_font_size_override("font_size",27)
    button.button_down.connect(func(): Input.action_press(action_name))
    button.button_up.connect(func(): Input.action_release(action_name))
    layer.add_child(button)

func _process(delta: float) -> void:
    if game_over:
        return
    attack_timer = maxf(0.0, attack_timer - delta)
    hero_damage_cooldown = maxf(0.0, hero_damage_cooldown - delta)
    var direction := Vector2(
        float(Input.is_action_pressed("move_right")) - float(Input.is_action_pressed("move_left")),
        float(Input.is_action_pressed("move_down")) - float(Input.is_action_pressed("move_up"))
    )
    if direction.length() > 1.0:
        direction = direction.normalized()
    hero.position += direction * 245.0 * delta
    hero.position.x = clampf(hero.position.x, 55.0, arena_width - 55.0)
    hero.position.y = clampf(hero.position.y, 320.0, 620.0)
    if direction.x != 0.0:
        hero.facing = signf(direction.x)
    if Input.is_action_just_pressed("attack"):
        _attack()
    for enemy in enemies:
        if not is_instance_valid(enemy) or enemy.health <= 0:
            continue
        var offset: Vector2 = hero.position - enemy.position
        if offset.length() > (85.0 if enemy.enemy_kind == "boss" else 55.0):
            enemy.position += offset.normalized() * enemy.speed * delta
        elif enemy.attack_cooldown <= 0.0:
            if hero_damage_cooldown <= 0.0:
                hero.take_damage(12 if enemy.enemy_kind == "boss" else 6)
                hero_damage_cooldown = 0.55
            enemy.attack_cooldown = 1.25 if enemy.enemy_kind == "boss" else 1.6
    for enemy in enemies:
        if is_instance_valid(enemy) and enemy.health <= 0:
            enemy.queue_free()
            score += 100 if enemy.enemy_kind == "boss" else 25
    enemies = enemies.filter(func(e): return is_instance_valid(e) and e.health > 0)
    if hero.health <= 0:
        game_over = true
        message_label.text = "AFO'KASOKA EST TOMBÉ"
        restart_button.visible = true
    elif enemies.is_empty():
        victory = true
        game_over = true
        message_label.text = "VICTOIRE ! MORONDAVA EST LIBÉRÉE"
        restart_button.visible = true
    _refresh_hud()

func _attack() -> void:
    if game_over or attack_timer > 0.0:
        return
    attack_timer = 0.42
    hero.strike()
    for enemy in enemies:
        if not is_instance_valid(enemy):
            continue
        var offset: Vector2 = enemy.position - hero.position
        if offset.length() < 115.0 and offset.x * hero.facing > -30.0:
            enemy.take_damage(24 if enemy.enemy_kind != "boss" else 17)

func _refresh_hud() -> void:
    if health_label == null:
        return
    health_label.text = "VIE  %d / %d" % [hero.health, hero.max_health]
    score_label.text = "SCORE  %d" % score

func _restart_game() -> void:
    for enemy in enemies:
        if is_instance_valid(enemy):
            enemy.queue_free()
    enemies.clear()
    if is_instance_valid(hero):
        hero.queue_free()
    hero = FighterScript.new()
    hero.position = Vector2(330, 520)
    add_child(hero)
    _spawn_enemy("scout", Vector2(790, 500))
    _spawn_enemy("soldier", Vector2(970, 525))
    _spawn_enemy("boss", Vector2(1110, 480))
    score = 0
    attack_timer = 0.0
    hero_damage_cooldown = 0.0
    game_over = false
    victory = false
    restart_button.visible = false
    message_label.text = "MORONDAVA  •  ALLÉE DES BAOBABS"
    _refresh_hud()

func _draw() -> void:
    draw_rect(Rect2(0,0,arena_width,arena_height),Color("#e7b879"))
    draw_rect(Rect2(0,0,arena_width,285),Color("#e9a96e"))
    draw_circle(Vector2(1030,105),52,Color("#f7d99a"))
    # Horizon et lointains
    draw_rect(Rect2(0,270,arena_width,95),Color("#c88b58"))
    # Silhouettes de baobabs stylisés
    _draw_baobab(Vector2(130,290),1.55)
    _draw_baobab(Vector2(410,305),0.95)
    _draw_baobab(Vector2(690,285),1.3)
    _draw_baobab(Vector2(1000,300),1.65)
    _draw_baobab(Vector2(1200,310),0.9)
    # Piste de terre
    draw_colored_polygon(PackedVector2Array([Vector2(0,410),Vector2(1280,390),Vector2(1280,720),Vector2(0,720)]),Color("#b77a4e"))
    for i in range(18):
        var x := float((i * 137) % 1280)
        var y := 425.0 + float((i * 53) % 250)
        draw_circle(Vector2(x,y),2.5,Color(0.45,0.29,0.19,0.38))
    draw_rect(Rect2(0,0,1280,8),Color("#d6a34f"))

func _draw_baobab(base: Vector2, scale_value: float) -> void:
    draw_set_transform(base,0.0,Vector2(scale_value,scale_value))
    draw_colored_polygon(PackedVector2Array([Vector2(-24,0),Vector2(-18,-125),Vector2(-12,-170),Vector2(12,-170),Vector2(18,-125),Vector2(24,0)]),Color("#63452f"))
    draw_line(Vector2(0,-140),Vector2(-45,-205),Color("#63452f"),13.0,true)
    draw_line(Vector2(0,-145),Vector2(40,-215),Color("#63452f"),12.0,true)
    draw_line(Vector2(-12,-170),Vector2(-70,-190),Color("#63452f"),9.0,true)
    draw_line(Vector2(12,-175),Vector2(73,-188),Color("#63452f"),9.0,true)
    draw_set_transform(Vector2.ZERO,0.0,Vector2.ONE)
