@echo off
title İpMan - Gelişmiş Versiyon
color 0A
echo ==================================================
echo   İpMan - Gelişmiş Versiyon
echo ==================================================
echo.

REM Kullanıcıdan dil seçimi alınır
set /p lang="Dil seçin (TR/EN): "
if /i "%lang%"=="EN" (
    set msg_enter_website=Please enter a website address (e.g., www.google.com): 
    set msg_error_no_input="[!] Error: No website address entered. Exiting..."
    set msg_ping="[*] Pinging %website%..."
    set msg_dns="[*] Retrieving DNS information for %website%..."
    set msg_traceroute="[*] Starting traceroute (maximum 10 hops)..."
    set msg_whois="[*] Retrieving Whois information (if supported)..."
    set msg_ip="[*] Retrieving IP address..."
    set msg_http="[*] Retrieving HTTP headers..."
    set msg_done="[*] Operation completed. Results saved to:"
    set msg_exit="Press Enter to exit..."
) else (
    set msg_enter_website=Lütfen bir web sitesi adresi girin (örnek: www.google.com): 
    set msg_error_no_input="[!] Hata: Web sitesi adresi girilmedi. Çıkılıyor..."
    set msg_ping="[*] %website% adresine ping atılıyor..."
    set msg_dns="[*] %website% için DNS bilgileri alınıyor..."
    set msg_traceroute="[*] Traceroute işlemi başlatılıyor (maksimum 10 atlama)..."
    set msg_whois="[*] Whois bilgileri alınıyor (yalnızca desteklenen sistemlerde)..."
    set msg_ip="[*] IP adresi alınıyor..."
    set msg_http="[*] HTTP başlıkları alınıyor..."
    set msg_done="[*] İşlem tamamlandı. Sonuçlar kaydedildi:"
    set msg_exit="Çıkmak için Enter'a basın..."
)

REM Kullanıcıdan web sitesi adresi alınır
set /p website="%msg_enter_website%"
if "%website%"=="" (
    echo %msg_error_no_input%
    pause
    exit
)

REM Çıktı dosyasının adı (tarih ve saat eklenir)
for /f "tokens=2 delims==" %%a in ('wmic os get localdatetime /value') do set datetime=%%a
set datetime=%datetime:~0,14%
set output_file=bilgi_%website%_%datetime%.txt
set log_file=log_%datetime%.txt

REM Loglama başlatılır
echo [LOG] İşlem başlatıldı: %datetime% > %log_file%

REM Ping işlemi
echo %msg_ping%
ping %website% > %output_file%
echo [LOG] Ping bilgileri kaydedildi. >> %log_file%

REM DNS bilgileri
echo %msg_dns%
nslookup %website% >> %output_file%
echo [LOG] DNS bilgileri kaydedildi. >> %log_file%

REM Traceroute işlemi
echo %msg_traceroute%
tracert -h 10 %website% >> %output_file%
if %errorlevel%==0 (
    echo [LOG] Traceroute bilgileri kaydedildi. >> %log_file%
) else (
    echo [LOG] Traceroute işlemi sırasında hata oluştu. >> %log_file%
)

REM Whois bilgileri
echo %msg_whois%
whois %website% >> %output_file% 2>nul
if %errorlevel%==0 (
    echo [LOG] Whois bilgileri kaydedildi. >> %log_file%
) else (
    echo [LOG] Whois komutu desteklenmiyor veya bulunamadı. >> %log_file%
)

REM IP adresi çıkarma
echo %msg_ip%
for /f "tokens=2 delims=[]" %%a in ('ping -n 1 %website% ^| find "Pinging"') do set ip=%%a
if defined ip (
    echo [*] %website% adresinin IP adresi: %ip% >> %output_file%
    echo [LOG] IP adresi: %ip% kaydedildi. >> %log_file%
) else (
    echo [LOG] IP adresi alınamadı. >> %log_file%
)

REM HTTP başlıklarını alma
echo %msg_http%
curl -I %website% >> %output_file% 2>nul
if %errorlevel%==0 (
    echo [LOG] HTTP başlıkları kaydedildi. >> %log_file%
) else (
    echo [LOG] curl komutu desteklenmiyor veya bulunamadı. >> %log_file%
)

echo ==================================================
echo   %msg_done%
echo   %output_file%
echo ==================================================
echo.

echo %msg_exit%
pause > nul
