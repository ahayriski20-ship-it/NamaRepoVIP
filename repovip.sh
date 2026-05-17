#!/bin/bash

# 1. Masuk ke folder repo yang baru
cd ~/NamaRepoVIP || { echo "Folder ~/NamaRepoVIP tidak ditemukan!"; exit 1; }

# 2. Cek apakah format ketikan sudah benar
if [ -z "$1" ] || [ -z "$2" ]; then
  echo "======================================"
  echo "❌ FORMAT SALAH!"
  echo "Cara pakai: ./repovip.sh <HWID> <JumlahHari>"
  echo "Contoh: ./repovip.sh TULISAN-RANDOM 1"
  echo "======================================"
  exit 1
fi

HWID=$1
DAYS=$2

# 3. Kunci Anti-Bentrok: Selalu tarik data terbaru dari GitHub dulu
echo "Menyinkronkan data..."
git pull origin HEAD

# 4. Hitung tanggal expired (Otomatis dari hari ini)
EXP_DATE=$(date -d "+${DAYS} days" +%Y-%m-%d)

# 5. Masukkan ke file whitelist
echo "${HWID}=${EXP_DATE}" >> whitelist.txt

echo "======================================"
echo "✅ MEMPROSES AKSES..."
echo "HWID    : $HWID"
echo "Durasi  : $DAYS Hari"
echo "Expired : $EXP_DATE"
echo "======================================"

# 6. Upload otomatis (Menggunakan HEAD agar otomatis mendeteksi branch main/master)
git add whitelist.txt
git commit -m "Add HWID: $HWID (Exp: $EXP_DATE)"
git push origin HEAD

echo "======================================"
echo "🚀 SUKSES! Database di GitHub terupdate."
echo "======================================"