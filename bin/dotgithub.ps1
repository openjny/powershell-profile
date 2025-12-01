[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$Command,

    [Parameter(Position = 1)]
    [string]$Template,

    [switch]$Force
)

# 設定
$TemplateRoot = Join-Path $PSScriptRoot 'dotgithub'
$TemplateTargets = @('.github', 'AGENTS.md')

# テンプレート一覧を取得
$AvailableTemplates = Get-ChildItem -Path $TemplateRoot -Directory -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Name

# 共通関数: テンプレート一覧表示
function Show-TemplateList {
    if ($AvailableTemplates) {
        $AvailableTemplates | ForEach-Object { Write-Host "  - $_" }
    } else {
        Write-Host "  (none)"
    }
}

# 共通関数: ヘルプ表示
function Show-Help {
    Write-Host "Usage:" -ForegroundColor Cyan
    Write-Host "  dotgithub list                      - List available templates"
    Write-Host "  dotgithub apply <template> [-Force] - Apply template to current directory"
    Write-Host "  dotgithub push <template> [-Force]  - Update template from current directory"
    Write-Host ""
    Write-Host "Available templates:" -ForegroundColor Yellow
    Show-TemplateList
}

# 共通関数: ファイルコピー (上書きポリシー付き)
function Copy-FileWithPolicy {
    param(
        [string]$Source,
        [string]$Destination,
        [string]$RelativePath,
        [bool]$ForceOverwrite,
        [string]$CreateMessage = "Created",
        [string]$OverwriteMessage = "Overwritten",
        [string]$SkipMessage = "Skipped"
    )

    $destDir = Split-Path $Destination -Parent
    if (-not (Test-Path $destDir)) {
        New-Item -ItemType Directory -Path $destDir -Force | Out-Null
    }

    if (Test-Path $Destination) {
        if ($ForceOverwrite) {
            Copy-Item -Path $Source -Destination $Destination -Force
            Write-Host "${OverwriteMessage}: $RelativePath" -ForegroundColor Yellow
        } else {
            Write-Host "${SkipMessage}: $RelativePath (already exists)" -ForegroundColor DarkGray
        }
    } else {
        Copy-Item -Path $Source -Destination $Destination
        Write-Host "${CreateMessage}: $RelativePath" -ForegroundColor Green
    }
}

# コマンドなしまたは不正なコマンド
if (-not $Command -or $Command -notin @('list', 'apply', 'push')) {
    if ($Command) {
        Write-Host "Error: Unknown command '$Command'" -ForegroundColor Red
        Write-Host ""
    }
    Show-Help
    exit 1
}

# list: テンプレート一覧を表示
if ($Command -eq 'list') {
    Write-Host "Available templates:" -ForegroundColor Cyan
    Show-TemplateList
    return
}

# apply/push: テンプレート名が必要
if (-not $Template) {
    Write-Host "Error: Template name is required for '$Command' command." -ForegroundColor Red
    Write-Host ""
    Show-Help
    exit 1
}

# apply: テンプレートを現在のディレクトリに展開
if ($Command -eq 'apply') {
    if ($Template -notin $AvailableTemplates) {
        Write-Host "Error: Template '$Template' not found." -ForegroundColor Red
        Write-Host "Available templates:" -ForegroundColor Yellow
        Show-TemplateList
        exit 1
    }

    $SourcePath = Join-Path $TemplateRoot $Template
    $DestinationPath = $PWD.Path

    Get-ChildItem -Path $SourcePath -Recurse -File | ForEach-Object {
        $relativePath = $_.FullName.Substring($SourcePath.Length + 1)
        $destFile = Join-Path $DestinationPath $relativePath
        Copy-FileWithPolicy -Source $_.FullName -Destination $destFile -RelativePath $relativePath -ForceOverwrite $Force
    }

    Write-Host "`nTemplate '$Template' applied successfully." -ForegroundColor Cyan
    return
}

# push: 現在のディレクトリからテンプレートを更新
if ($Command -eq 'push') {
    $DestTemplatePath = Join-Path $TemplateRoot $Template
    $SourcePath = $PWD.Path

    # 対象ファイル/ディレクトリの存在確認
    $foundTargets = $TemplateTargets | Where-Object {
        Test-Path (Join-Path $SourcePath $_)
    }

    if (-not $foundTargets) {
        $targetNames = $TemplateTargets -join ', '
        Write-Host "Error: No target files/directories ($targetNames) found in current directory." -ForegroundColor Red
        exit 1
    }

    # 新規テンプレート作成
    if ($Template -notin $AvailableTemplates) {
        Write-Host "Template '$Template' does not exist. Creating new template..." -ForegroundColor Yellow
        New-Item -ItemType Directory -Path $DestTemplatePath -Force | Out-Null
    }

    # 各ターゲットをコピー
    foreach ($target in $foundTargets) {
        $targetPath = Join-Path $SourcePath $target

        if (Test-Path $targetPath -PathType Container) {
            # ディレクトリの場合
            Get-ChildItem -Path $targetPath -Recurse -File | ForEach-Object {
                $relativePath = $target + $_.FullName.Substring($targetPath.Length)
                $destFile = Join-Path $DestTemplatePath $relativePath
                Copy-FileWithPolicy -Source $_.FullName -Destination $destFile -RelativePath $relativePath -ForceOverwrite $Force -CreateMessage "Added"
            }
        } else {
            # ファイルの場合
            $destFile = Join-Path $DestTemplatePath $target
            Copy-FileWithPolicy -Source $targetPath -Destination $destFile -RelativePath $target -ForceOverwrite $Force -CreateMessage "Added"
        }
    }

    Write-Host "`nTemplate '$Template' updated successfully." -ForegroundColor Cyan
    return
}
