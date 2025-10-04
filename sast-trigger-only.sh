#!/bin/bash
set -e

echo "=== Mulai menjalankan script.sh ==="

# Contoh perintah awal
echo "Menjalankan build/test dummy..."

# Jalankan ScanCentral
echo "Menjalankan Fortify ScanCentral..."
scancentral -url "http://10.100.34.250:8280/scancentral-ctrl/" start -upload -bt none \
  -application "riches" \
  -version "1.0" \
  -uptoken 58af2e23-cebb-47f9-9e2f-35d76e98218b

echo "=== script.sh selesai ==="
