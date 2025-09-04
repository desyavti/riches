#!/bin/bash
# script.sh
# Contoh script sederhana untuk RHEL self-hosted runner

set -e  # kalau ada error, langsung stop

echo "=== Mulai eksekusi script di $(hostname) ==="
echo "Tanggal: $(date)"
echo "User   : $(whoami)"

# contoh perintah real: update paket & cek service
echo "=== Update paket ==="
sudo yum -y update

echo "=== Cek status Docker (jika ada) ==="
if systemctl is-active --quiet docker; then
  echo "Docker sedang berjalan"
else
  echo "Docker tidak berjalan"
fi

echo "=== Script selesai dengan sukses ==="
