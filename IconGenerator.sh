#!/bin/bash
# Генерация иконок для iOS

# Требует установки ImageMagick
# brew install imagemagick

echo "Generating iOS icons..."

# Размеры иконок
sizes=(
  "20x20"
  "29x29"
  "40x40"
  "60x60"
  "76x76"
  "83.5x83.5"
  "1024x1024"
)

for size in "${sizes[@]}"; do
  width=$(echo $size | cut -d'x' -f1)
  height=$(echo $size | cut -d'x' -f2)

  # Создаём иконку с градиентом и символом
  convert -size ${width}x${height} \
    gradient:blue-purple \
    -fill white -font Helvetica -pointsize $((width / 4)) \
    -gravity center -annotate 0 "🌐" \
    "Assets.xcassets/AppIcon.appiconset/icon_${width}x${height}.png"
done

echo "Done!"
