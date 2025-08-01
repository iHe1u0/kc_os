# PowerShell脚本：combine.ps1

# 1MB = 1024 * 1024 bytes
$oneMB = 1024 * 1024

# 读boot.bin
$boot = [System.IO.File]::ReadAllBytes("boot.bin")

# 读kernel.bin
$kernel = [System.IO.File]::ReadAllBytes("kernel.bin")

# 创建1MB大小的空数组初始化为0
$image = New-Object byte[] ($oneMB + $kernel.Length)

# 复制boot.bin到起始0偏移（boot.bin通常512字节）
[Array]::Copy($boot, 0, $image, 0, $boot.Length)

# 复制kernel.bin到偏移1MB
[Array]::Copy($kernel, 0, $image, $oneMB, $kernel.Length)

# 写入合成镜像
[System.IO.File]::WriteAllBytes("os-image.bin", $image)

Write-Host "合并完成，生成 os-image.bin"
