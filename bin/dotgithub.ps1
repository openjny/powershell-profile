[CmdletBinding(DefaultParameterSetName = 'Expand')]
param(
    [Parameter(ParameterSetName = 'List')]
    [switch]$List,

    [Parameter(ParameterSetName = 'Expand', Position = 0)]
    [string]$Template,

    [Parameter(ParameterSetName = 'Expand')]
    [switch]$Force
)

# テンプレートディレクトリのパスを取得
$TemplateRoot = Join-Path $PSScriptRoot 'dotgithub'

# テンプレート一覧を取得
$AvailableTemplates = Get-ChildItem -Path $TemplateRoot -Directory | Select-Object -ExpandProperty Name

# -List: テンプレート一覧を表示
if ($List) {
    Write-Host "Available templates:" -ForegroundColor Cyan
    $AvailableTemplates | ForEach-Object { Write-Host "  - $_" }
    return
}

# 引数なしの場合はヘルプを表示
if (-not $Template) {
    Write-Host "Usage: dotgithub <template> [-Force]" -ForegroundColor Cyan
    Write-Host "       dotgithub -List" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Available templates:" -ForegroundColor Yellow
    $AvailableTemplates | ForEach-Object { Write-Host "  - $_" }
    exit 1
}

# テンプレートの存在確認
if ($Template -notin $AvailableTemplates) {
    Write-Host "Error: Template '$Template' not found." -ForegroundColor Red
    Write-Host "Available templates:" -ForegroundColor Yellow
    $AvailableTemplates | ForEach-Object { Write-Host "  - $_" }
    exit 1
}

$SourcePath = Join-Path $TemplateRoot $Template
$DestinationPath = $PWD.Path

# テンプレート内のファイルを再帰的に取得して展開
Get-ChildItem -Path $SourcePath -Recurse -File | ForEach-Object {
    $relativePath = $_.FullName.Substring($SourcePath.Length + 1)
    $destFile = Join-Path $DestinationPath $relativePath
    $destDir = Split-Path $destFile -Parent

    # ディレクトリが存在しない場合は作成
    if (-not (Test-Path $destDir)) {
        New-Item -ItemType Directory -Path $destDir -Force | Out-Null
    }

    # ファイルの存在確認と処理
    if (Test-Path $destFile) {
        if ($Force) {
            Copy-Item -Path $_.FullName -Destination $destFile -Force
            Write-Host "Overwritten: $relativePath" -ForegroundColor Yellow
        }
        else {
            Write-Host "Skipped: $relativePath (already exists)" -ForegroundColor DarkGray
        }
    }
    else {
        Copy-Item -Path $_.FullName -Destination $destFile
        Write-Host "Created: $relativePath" -ForegroundColor Green
    }
}

Write-Host "`nTemplate '$Template' applied successfully." -ForegroundColor Cyan
