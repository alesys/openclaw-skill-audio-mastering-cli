param(
  [Parameter(Mandatory=$true)]
  [string]$InputFile,

  [string]$OutputBase = "",

  [switch]$MakeMp3
)

$ErrorActionPreference = "Continue"

if (-not (Test-Path -LiteralPath $InputFile)) {
  throw "No existe el archivo de entrada: $InputFile"
}

$inItem = Get-Item -LiteralPath $InputFile
if ([string]::IsNullOrWhiteSpace($OutputBase)) {
  $OutputBase = [System.IO.Path]::Combine($inItem.DirectoryName, ($inItem.BaseName + "_master_yt"))
}

$outWav = "$OutputBase.wav"
$outMp3 = "$OutputBase.mp3"

# Cadena base sin referencia:
# 1) EQ correctiva suave (HPF/LPF + realce presencia + control low-mid)
# 2) Compresion musical moderada
# 3) Limitador de picos antes de normalizacion final
$baseChain = @(
  "highpass=f=28",
  "lowpass=f=18500",
  "equalizer=f=90:t=q:w=1.0:g=0.8",
  "equalizer=f=280:t=q:w=1.1:g=-1.2",
  "equalizer=f=3500:t=q:w=1.0:g=1.3",
  "equalizer=f=12000:t=q:w=0.8:g=1.0",
  "acompressor=threshold=-19dB:ratio=2.2:attack=18:release=180:makeup=3",
  "alimiter=limit=0.95:level=disabled"
) -join ","

# Targets recomendados para YouTube
$targetI = -14
$targetTP = -1.0
$targetLRA = 7

Write-Host "[1/3] Midiendo loudness (primera pasada)..."
$measureFilter = "$baseChain,loudnorm=I=${targetI}:TP=${targetTP}:LRA=${targetLRA}:print_format=json"
$measureOutput = & ffmpeg -hide_banner -y -i "$InputFile" -af "$measureFilter" -f null NUL 2>&1 | Out-String

$jsonMatch = [regex]::Match($measureOutput, '\{\s*"input_i"[\s\S]*?\}')
if (-not $jsonMatch.Success) {
  throw "No se pudo extraer JSON de loudnorm. Salida ffmpeg:`n$measureOutput"
}

$stats = $jsonMatch.Value | ConvertFrom-Json

Write-Host "[2/3] Aplicando mastering (segunda pasada) a WAV..."
$secondPassLoudnorm = "loudnorm=I=${targetI}:TP=${targetTP}:LRA=${targetLRA}:measured_I=$($stats.input_i):measured_TP=$($stats.input_tp):measured_LRA=$($stats.input_lra):measured_thresh=$($stats.input_thresh):offset=$($stats.target_offset):linear=true:print_format=summary"
$masterChain = "$baseChain,$secondPassLoudnorm"

& ffmpeg -hide_banner -y -i "$InputFile" -af "$masterChain" -c:a pcm_s24le "$outWav"

if ($LASTEXITCODE -ne 0) {
  throw "Fallo la renderizacion WAV"
}

if ($MakeMp3) {
  Write-Host "[3/3] Exportando MP3 320 kbps..."
  & ffmpeg -hide_banner -y -i "$outWav" -c:a libmp3lame -b:a 320k "$outMp3"
  if ($LASTEXITCODE -ne 0) {
    throw "Fallo la exportacion MP3"
  }
}

Write-Host "Listo. Archivo master WAV: $outWav"
if ($MakeMp3) {
  Write-Host "Archivo master MP3: $outMp3"
}

Write-Host "\nResumen de medicion (pre-normalizacion):"
Write-Host ("input_i:      {0} LUFS" -f $stats.input_i)
Write-Host ("input_tp:     {0} dBTP" -f $stats.input_tp)
Write-Host ("input_lra:    {0} LU" -f $stats.input_lra)
Write-Host ("input_thresh: {0}" -f $stats.input_thresh)
Write-Host ("target_offset:{0}" -f $stats.target_offset)


