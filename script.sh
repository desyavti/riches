#!/bin/bash
set -e

echo "=== Mulai menjalankan script.sh ==="

# Contoh perintah awal (bisa ditambah sesuai kebutuhan kamu)
echo "Menjalankan build/test dummy..."
echo "Hello dari script.sh"

# Jalankan ScanCentral
echo "Menjalankan Fortify ScanCentral..."
"/home/admin/Fortify/OpenText_SAST_Fortify_25.2.0/bin/scancentral" -url "http://10.100.34.250:8280/scancentral-ctrl/" start -upload \
  -application "kejagung-demo" \
  -version "v1" \
  -uptoken 58af2e23-cebb-47f9-9e2f-35d76e98218b

echo "=== script.sh selesai ==="
