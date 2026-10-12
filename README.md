# Survivor

Juego estilo *Vampire Survivors* hecho en **Godot 4** con **GDScript**. No usa imágenes: todo se dibuja con formas por código.

## Cómo jugar

| Tecla | Acción |
|---|---|
| WASD / flechas | Moverse (las armas disparan solas) |
| 1 · 2 · 3 / clic | Elegir mejora al subir de nivel |
| Esc / P | Pausa |
| R | Reiniciar tras morir |

Sobrevive el mayor tiempo posible. Los enemigos sueltan gemas de experiencia; al subir de nivel eliges entre 3 mejoras. Cada 3 minutos aparece un jefe.

## Cómo abrirlo

1. Descarga **Godot 4.3 o superior**, versión *estándar* (no la .NET): https://godotengine.org/download
2. Abre Godot → **Import** → selecciona `project.godot`.
3. Pulsa **F5** para jugar.

## Estructura del código

```
scenes/main.tscn          Escena raíz (solo carga main.gd)
scripts/
  main.gd                 Arma el mundo, conecta señales, pausa, level-up, game over
  player.gd               Movimiento, vida, XP, estadísticas, lista de armas
  enemy.gd                Persigue al jugador, recibe daño, retroceso, muere
  spawner.gd              Oleadas, tipos de enemigo (KINDS), dificultad, jefes
  projectile.gd           Proyectil genérico con "pierce"
  xp_gem.gd               Gema de experiencia con efecto imán
  upgrades.gd             Genera las 3 opciones del menú de mejora
  background.gd           Cuadrícula infinita de fondo
  util.gd                 Ayudas (formas de colisión)
  weapons/
    weapon.gd             Clase base de las armas
    magic_bolt.gd         Rayo mágico: dispara al enemigo más cercano
    orbit_blades.gd       Espadas que orbitan al jugador
    holy_aura.gd          Aura que daña en área
  ui/
    hud.gd                Barras de vida/XP, tiempo, muertes, pausa, game over
    upgrade_menu.gd       Menú de subida de nivel
  fx/
    damage_number.gd      Números de daño flotantes
```

### Capas de colisión
- Capa 1: jugador
- Capa 2: enemigos (chocan entre sí para no amontonarse)
- Las armas y la "hurtbox" del jugador son `Area2D` que solo miran la capa 2.

### Cómo extenderlo
- **Nuevo enemigo:** agrégalo a `KINDS` en `spawner.gd` y decide cuándo aparece en `_pick_kind()`.
- **Nueva arma:** crea un script que herede de `weapons/weapon.gd`, define `WEAPON_NAME`, `LEVEL_DESCRIPTIONS` y `_apply_level()`, y añádelo a la lista en `upgrades.gd`.
- **Nueva mejora de estadística:** añade una entrada a `STAT_UPGRADES` en `upgrades.gd` y su caso en `player.apply_stat()`.

## Publicar en la web

El proyecto ya usa el renderizador **Compatibility** (WebGL 2), que es el que necesita la exportación web. Por eso es GDScript y no C#: Godot 4 no exporta proyectos C# a la web.

1. En Godot: **Editor → Manage Export Templates → Download and Install**.
2. **Project → Export → Add… → Web**.
3. Desactiva **Thread Support** (así funciona en cualquier hosting sin cabeceras especiales).
4. **Export Project** → guarda como `export/web/index.html`.
5. Súbelo a uno de estos:
   - **itch.io**: comprime la carpeta `export/web` en un .zip, crea un proyecto tipo *HTML* y sube el zip.
   - **GitHub Pages / Netlify / Vercel**: sube el contenido de `export/web` como sitio estático.

Para probarlo en local antes de subirlo, en la ventana de exportación usa el botón **Run in Browser** (el ícono de HTML5 arriba a la derecha del editor).
