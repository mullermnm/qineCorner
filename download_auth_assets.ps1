$assetsDir = "assets/images"
$urls = @{
    "login.png" = "https://raw.githubusercontent.com/afgprogrammer/Flutter-Login-Page-UI/master/assets/images/login.png"
    "signup.png" = "https://raw.githubusercontent.com/afgprogrammer/Flutter-Login-Page-UI/master/assets/images/signup.png"
    "main_top.png" = "https://raw.githubusercontent.com/afgprogrammer/Flutter-Login-Page-UI/master/assets/images/main_top.png"
    "login_bottom.png" = "https://raw.githubusercontent.com/afgprogrammer/Flutter-Login-Page-UI/master/assets/images/login_bottom.png"
}

if (-not (Test-Path $assetsDir)) {
    New-Item -ItemType Directory -Path $assetsDir -Force
}

foreach ($file in $urls.GetEnumerator()) {
    $outFile = Join-Path $assetsDir $file.Key
    Write-Host "Downloading $($file.Key)..."
    Invoke-WebRequest -Uri $file.Value -OutFile $outFile
}

Write-Host "All assets downloaded successfully!"
