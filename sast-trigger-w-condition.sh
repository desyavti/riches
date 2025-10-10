#!/bin/bash

# Jalankan perintah scancentral dan tangkap outputnya
output=$(scancentral -url "http://10.100.34.250:8280/scancentral-ctrl/" start -upload -bt none -application "riches" -version "1.0" -uptoken 58af2e23-cebb-47f9-9e2f-35d76e98218b 2>&1)

# Tampilkan seluruh output untuk debugging
echo "Log Output:"
echo "$output"

# Pola regex untuk menangkap token
# lama----- pattern='Submitted job and received token:\s*([a-f0-9\-]+)'
pattern='Submitted job and received token:\s+([0-9a-fA-F\-]{36})'

# Gunakan grep untuk ekstraksi jika regex BASH tidak cocok
if [[ $output =~ $pattern ]]; then
    token="${BASH_REMATCH[1]}"
    echo "Job Token: $token"
else
    token=$(echo "$output" | grep -oP '(?<=Submitted job and received token:\s*)[a-f0-9\-]+')
    
    if [[ -n "$token" ]]; then
        echo "Job Token (grep method): $token"
    else
        echo "No match found."
    fi
fi

# Next Step: Cek Status Scan via API
apikey="ZDkxMmUxMTgtNjk4Ni00NGMzLTliMWEtYzJmYzRmYmFmNGRk"
cek_sast_api="http://10.100.34.250:8280/ssc/api/v1/cloudjobs/$token"
jobState="PENDING"

echo "Menunggu hasil scan..."
sleep 120

# Loop untuk mengecek status scan sampai selesai
while [[ "$jobState" == "PENDING" || "$jobState" == "SCAN_RUNNING" ]]; do
    sleep 30  # Tunggu 30 detik sebelum melakukan pengecekan ulang
    # Panggil API untuk mendapatkan status scan
    runstatus=$(curl --insecure -s -X GET \
      -H "Authorization: FortifyToken ${apikey}" \
      -H "Content-Type: application/json" \
      "$cek_sast_api")
    #echo "Status status: $runstatus"
    # Ambil status dari response API
    jobState=$(echo "$runstatus" | grep -oP '"jobState":"\K[^"]+')
    # Tampilkan status terkini
    echo "Status Scan: $jobState"
done

echo "Scan selesai dengan status: $jobState"
pvId=$(echo "$runstatus" | grep -oP '"pvId":\K\d+')
pvName=$(echo "$runstatus" | grep -oP '"pvName":"\K[^"]+')
projectName=$(echo "$runstatus" | grep -oP '"projectName":"\K[^"]+')

echo "Project Version ID: $pvId"
echo "Project Version Name: $pvName"
echo "Project Name: $projectName"

cekssc="http://10.100.34.250:8280/ssc/api/v1/projectVersions/$pvId/issueSummaries?seriestype=ISSUE_FRIORITY&groupaxistype=ISSUE_FRIORITY"
runscan=$(curl --insecure -s -X GET \
      -H "Authorization: FortifyToken ${apikey}" \
      -H "Content-Type: application/json" \
      "$cekssc")
critical=$(echo "$runscan" | grep -oP '"Critical","y":\K[0-9]+')
high=$(echo "$runscan" | grep -oP '"High","y":\K[0-9]+')
medium=$(echo "$runscan" | grep -oP '"Medium","y":\K[0-9]+')
low=$(echo "$runscan" | grep -oP '"Low","y":\K[0-9]+')
total_issue=$(echo "$runscan" | grep -oP '"totalIssueCount":\K[0-9]+')

echo "Critical: $critical"
echo "High: $high"
echo "Medium: $medium"
echo "Low: $low"
echo "Total Issue Count: $total_issue"

echo "Untuk detail vulnerability dapat dilihat pada: https://fortify.kikoichi.dev/ssc/html/ssc/version/$pvId/audit"

if [[ "$critical" -gt 100 ]]; then
      echo "ERROR: Jumlah isu Critical ($critical) melebihi batas! Pipeline dihentikan."
      exit 1
elif [[ "$high" -gt 100 ]]; then
      echo "ERROR: Jumlah isu High ($high) melebihi batas! Pipeline dihentikan."
      exit 1
fi
