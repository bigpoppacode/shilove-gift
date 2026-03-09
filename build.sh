#!/bin/bash
set -e
cd "$(dirname "$0")"

echo "🪡 Shi Love — Build Script"
echo "=========================="

echo ""
echo "[1/5] Installing dependencies..."
npm install

echo ""
echo "[2/5] Creating hero cutout (rembg)..."
$HOME/.local/bin/rembg i public/images/shilove-7.jpg public/images/hero-cutout.png
echo "  ✓ hero-cutout.png created"

echo ""
echo "[3/5] Generating ambient music..."
ffmpeg -y \
  -f lavfi -i "anoisesrc=d=180:c=pink:r=44100:a=0.008" \
  -f lavfi -i "sine=frequency=110:duration=180:sample_rate=44100" \
  -f lavfi -i "sine=frequency=165:duration=180:sample_rate=44100" \
  -f lavfi -i "sine=frequency=220:duration=180:sample_rate=44100" \
  -f lavfi -i "sine=frequency=330:duration=180:sample_rate=44100" \
  -filter_complex "
    [1:a]volume=0.03[s1];
    [2:a]volume=0.02[s2];
    [3:a]volume=0.025[s3];
    [4:a]volume=0.015[s4];
    [0:a][s1][s2][s3][s4]amix=inputs=5:duration=longest[mixed];
    [mixed]lowpass=f=2000,highpass=f=60,afade=t=in:st=0:d=5,afade=t=out:st=175:d=5[out]
  " -map "[out]" -codec:a libmp3lame -b:a 192k public/audio/couture-chronicles.mp3
echo "  ✓ couture-chronicles.mp3 created"

echo ""
echo "[4/5] Creating OG image..."
FONT="/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"
ffmpeg -y \
  -f lavfi -i "color=c=0x08080A:s=1280x720:d=1" \
  -i public/images/hero-cutout.png \
  -filter_complex "
    [1:v]scale=-1:680[photo];
    [0:v][photo]overlay=x=W-overlay_w+60:y=(H-overlay_h)/2+20[bg];
    [bg]drawtext=fontfile=${FONT}:text='SHI':fontcolor=0xFFD700:fontsize=120:x=70:y=180[t1];
    [t1]drawtext=fontfile=${FONT}:text='LOVE':fontcolor=0xFFD700:fontsize=120:x=70:y=310[t2];
    [t2]drawbox=x=70:y=450:w=320:h=2:color=0xFFD700@0.6:t=fill[line];
    [line]drawtext=fontfile=${FONT}:text='Couture . Culture . Confidence':fontcolor=0x8A8A94:fontsize=26:x=70:y=475[out]
  " \
  -map "[out]" -frames:v 1 -update 1 public/images/og-image.png
echo "  ✓ og-image.png created"

echo ""
echo "[5/5] Initializing git..."
git init
git add -A
git commit -m "Initial build — premium dark luxury site for Shi Love"
git remote add origin git@github.com:bigpoppacode/shi-love-gift.git
git branch -M main
git push -u origin main
echo "  ✓ Pushed to GitHub"

echo ""
echo "=========================="
echo "🪡 Build complete!"
echo "Run: node server.js"
echo "Open: http://localhost:31007"
