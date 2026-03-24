# Accidental Mantle PopUp

Displays a **"MANTLE ANIMATION"** popup on screen when you mantle while moving at high speed — helping you identify accidental mantles during gameplay.

## How it works

The mod tracks your horizontal speed every frame. If you mantle while you were recently moving above **300 u/s**, a stylized text popup appears in the center of the screen with a zoom-in and fade-out animation.

## Configuration

You can tweak these values at the top of `mantleanimation.nut`:

| Variable | Default | Description |
|---|---|---|
| `AM_SPEED_THRESHOLD` | `300.0` | Minimum speed (u/s) to count as accidental |
| `AM_COOLDOWN` | `0.55` | Seconds between alerts |
| `AM_FAST_WINDOW` | `0.30` | How long after going fast a mantle still counts |

## Compatibility

- Requires Northstar
- Client-side only — works in any multiplayer match
- May conflict with other mods that replace `cl_player.gnut`
