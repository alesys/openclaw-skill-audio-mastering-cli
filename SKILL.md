---
name: audio-mastering-youtube-cli
description: Masteriza audio por CLI sin pista de referencia con ffmpeg (EQ, compresion, limitador y objetivo YouTube).
metadata: {"openclaw":{"emoji":"🎚️","homepage":"https://github.com/alesys/openclaw-skill-audio-mastering-youtube-cli","os":["win32"],"requires":{"bins":["ffmpeg","powershell"]}}}
---

# Audio Mastering YouTube CLI

Usa este skill cuando el usuario quiera masterizar una mezcla sin pista de referencia, desde CLI, con una cadena reproducible.

## Flujo
1. Verifica que existe el archivo de entrada (`.wav`, `.aiff`, `.flac`, etc.).
2. Ejecuta el script del skill:
   `powershell -ExecutionPolicy Bypass -File "{baseDir}/scripts/master_youtube.ps1" -InputFile "<ruta-archivo>" -MakeMp3`
3. Entrega rutas de salida:
   - WAV master: `<base>_master_yt.wav`
   - MP3 master: `<base>_master_yt.mp3`
4. Reporta loudness/true peak del log para validar resultado.

## Cadena aplicada
- Filtros tonales: `highpass` + `lowpass`
- EQ suave de correccion/mejora
- `acompressor` (control de dinamica)
- `alimiter` (seguridad de picos)
- `loudnorm` en dos pasadas a objetivo YouTube

## Comando de verificacion (opcional)
`ffmpeg -hide_banner -i "<archivo_master.wav>" -af "loudnorm=I=-14:TP=-1:LRA=7:print_format=summary" -f null NUL`

## Notas
- El script produce un master seguro para plataformas tipo YouTube; ajusta a ~`-14 LUFS` integrado.
- Si el material llega demasiado hot, puede haber avisos de clipping interno en etapas de EQ; en ese caso baja entrada o reduce ganancia de EQ antes de reexportar.
