extends RefCounted
## Genera las opciones del menú de subida de nivel.
## Cada opción es un diccionario { title, desc, apply: Callable }.

const MagicBolt := preload("res://scripts/weapons/magic_bolt.gd")
const OrbitBlades := preload("res://scripts/weapons/orbit_blades.gd")
const HolyAura := preload("res://scripts/weapons/holy_aura.gd")

const STAT_UPGRADES := [
	{"title": "Vitalidad", "desc": "+20 de vida máxima", "stat": "max_health", "amount": 20.0},
	{"title": "Poción", "desc": "Recupera 40 de vida", "stat": "heal", "amount": 40.0},
	{"title": "Botas ligeras", "desc": "+10% velocidad de movimiento", "stat": "speed", "amount": 0.10},
	{"title": "Fuerza", "desc": "+15% daño de todas las armas", "stat": "damage", "amount": 0.15},
	{"title": "Concentración", "desc": "-8% recarga de todas las armas", "stat": "cooldown", "amount": 0.08},
	{"title": "Imán", "desc": "+30% radio para recoger experiencia", "stat": "pickup", "amount": 0.30},
	{"title": "Regeneración", "desc": "+0.5 de vida por segundo", "stat": "regen", "amount": 0.5},
	{"title": "Armadura", "desc": "Reduce el daño por contacto", "stat": "armor", "amount": 3.0},
]


static func get_options(player, count: int = 3) -> Array:
	var weapon_options: Array = []
	for weapon_script in [MagicBolt, OrbitBlades, HolyAura]:
		var owned = player.get_weapon(weapon_script)
		if owned == null:
			weapon_options.append({
				"title": "NUEVA: " + weapon_script.WEAPON_NAME,
				"desc": weapon_script.LEVEL_DESCRIPTIONS[0],
				"apply": func(): player.add_weapon(weapon_script),
			})
		elif owned.level < weapon_script.LEVEL_DESCRIPTIONS.size():
			weapon_options.append({
				"title": "%s (nivel %d)" % [weapon_script.WEAPON_NAME, owned.level + 1],
				"desc": weapon_script.LEVEL_DESCRIPTIONS[owned.level],
				"apply": func(): owned.upgrade(),
			})

	var stat_options: Array = []
	for stat in STAT_UPGRADES:
		stat_options.append({
			"title": stat["title"],
			"desc": stat["desc"],
			"apply": func(): player.apply_stat(stat["stat"], stat["amount"]),
		})

	# Hasta 2 opciones de armas (si hay) y el resto de estadísticas.
	weapon_options.shuffle()
	stat_options.shuffle()
	var result := weapon_options.slice(0, mini(2, weapon_options.size()))
	result.append_array(stat_options.slice(0, count - result.size()))
	result.shuffle()
	return result
