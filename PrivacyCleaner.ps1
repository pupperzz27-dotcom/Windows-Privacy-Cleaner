
# Windows Privacy Cleaner
# ล้างเฉพาะไฟล์ชั่วคราวของผู้ใช้และไฟล์ชั่วคราวของ Windows
# ไม่ลบ Event Logs, Prefetch, Registry หรือประวัติการใช้งานโปรแกรม

$ErrorActionPreference = "Continue"

$report = Join-Path $env:USERPROFILE (
    "Desktop\PrivacyCleaner-{0}.txt" -f (Get-Date -Format "yyyyMMdd-HHmmss")
)

"Privacy Cleaner Report" | Set-Content -Path $report
"Started: $(Get-Date)" | Add-Content -Path $report

$paths = @(
    $env:TEMP,
    (Join-Path $env:LOCALAPPDATA "Temp")
) | Select-Object -Unique

foreach ($path in $paths) {
    if (-not (Test-Path -LiteralPath $path)) {
        continue
    }

    Write-Host "`nตรวจสอบ: $path" -ForegroundColor Cyan

    $answer = Read-Host "ต้องการลบไฟล์ชั่วคราวในโฟลเดอร์นี้หรือไม่ (Y/N)"
    if ($answer -ne "Y") {
        "Skipped: $path" | Add-Content -Path $report
        continue
    }

    try {
        $items = @(Get-ChildItem -LiteralPath $path -Force -ErrorAction SilentlyContinue)
        $removed = 0
        $failed = 0

        foreach ($item in $items) {
            try {
                Remove-Item -LiteralPath $item.FullName -Recurse -Force -ErrorAction Stop
                $removed++
            }
            catch {
                $failed++
            }
        }

        "Path: $path | Removed: $removed | Failed: $failed" |
            Add-Content -Path $report

        Write-Host "ลบสำเร็จ: $removed | ลบไม่ได้: $failed" `
            -ForegroundColor Green
    }
    catch {
        "Error: $path | $($_.Exception.Message)" |
            Add-Content -Path $report
    }
}

"Finished: $(Get-Date)" | Add-Content -Path $report

Write-Host "`nเสร็จแล้ว รายงานอยู่ที่:" -ForegroundColor Green
Write-Host $report
Read-Host "กด Enter เพื่อปิด"
