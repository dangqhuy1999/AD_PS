# Khởi tạo một danh sách để lưu trữ các job
$jobs = @()

# Danh sách các địa chỉ cần ping
$addresses = @("google.com", "facebook.com", "baomoi.com")

# Tạo và bắt đầu job cho từng địa chỉ
foreach ($address in $addresses) {
    $job = Start-Job -ScriptBlock {
        $pingAddress = $using:address  # Sử dụng biến bên ngoài
        while ($true) {
            $result = Test-Connection -ComputerName $pingAddress -Count 1 -ErrorAction SilentlyContinue
            if ($result) {
                Write-Output "${pingAddress}: Ping thành công: $($result.Address) tại $($result.ResponseTime) ms"
            } else {
                Write-Output "${pingAddress}: Ping thất bại"
            }
            Start-Sleep -Seconds 1  # Đợi 1 giây giữa các lần ping
        }
    }
    $jobs += $job  # Thêm job vào danh sách
}

# Đếm số từ 1 đến 100 đồng thời với việc chạy các job ping
for ($i = 1; $i -le 100; $i++) {
    Write-Host $i
    Start-Sleep -Milliseconds 100  # Đợi 100 ms giữa các lần đếm

    # Kiểm tra trạng thái các job ping
    foreach ($job in $jobs) {
        $pingStatus = Get-Job -Id $job.Id
        if ($pingStatus.State -eq 'Running') {
            Write-Host "Job $($job.Id) vẫn đang chạy..."
        }
    }
}

# Dừng tất cả các job ping khi hoàn tất đếm
foreach ($job in $jobs) {
    Stop-Job $job
    Remove-Job $job
}