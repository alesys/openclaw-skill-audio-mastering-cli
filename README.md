# OpenClaw Skill: Audio Mastering CLI

Skill compatible con OpenClaw/AgentSkills para masterizar audio por CLI sin pista de referencia.

## Features
- Mastering de archivos de audio (`wav`, `aiff`, `flac`, `mp3`, `m4a`).
- Mastering del audio en video (`mp4`, `mov`, `m4v`, `mkv`, `webm`) y salida en `mp4`.
- Cadena reproducible: EQ + compresion + limitador + loudnorm (2 pasadas).

## Requisitos
- `ffmpeg` disponible en `PATH`
- `powershell` (Windows)

## Instalacion
Clona el repo y colocalo dentro de tu carpeta `skills/` del workspace OpenClaw.

```powershell
git clone https://github.com/alesys/openclaw-skill-audio-mastering-cli.git
```

## Uso (ejemplos)
Audio a WAV + MP3:

```powershell
powershell -ExecutionPolicy Bypass -File ".\scripts\master_media.ps1" -InputFile ".\water.wav" -MakeMp3
```

Video MOV/MP4 a MP4 masterizado:

```powershell
powershell -ExecutionPolicy Bypass -File ".\scripts\master_media.ps1" -InputFile ".\coyo2.mov" -MakeMp3
```

Salidas esperadas:
- `<base>_master.wav`
- `<base>_master.mp3` (si `-MakeMp3`)
- `<base>_master.mp4` (si la entrada tiene video)

## Limitaciones conocidas
- Si el material entra demasiado alto, pueden aparecer avisos de clipping interno en etapas de EQ.
- El objetivo de loudness es conservador multiplaforma (`~ -14 LUFS`), no orientado a loud masters agresivos.
- En salida de video se conserva el stream de video (`-c:v copy`) y se recodifica solo audio a AAC 320k.

## Version
- `v1.0.0`
