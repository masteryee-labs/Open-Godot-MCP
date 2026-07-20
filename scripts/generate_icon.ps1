# Generates 256x256 Open Godot MCP icon for Asset Library submission.
# Output: docs/assets/icon.png (and a 128x128 variant for in-editor use).
$ErrorActionPreference = 'Stop'

Add-Type -AssemblyName System.Drawing

$outDir = Join-Path $PSScriptRoot '..\docs\assets'
if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir | Out-Null }

function New-Icon([int]$size, [string]$path) {
    $bmp = New-Object System.Drawing.Bitmap $size, $size
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode    = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TextRenderingHint= [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
    $g.InterpolationMode= [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic

    # Background: vertical gradient dark-navy -> blue (Godot-ish)
    $rect = New-Object System.Drawing.Rectangle 0, 0, $size, $size
    $brush = New-Object System.Drawing.Drawing2D.LinearGradientBrush `
        $rect,
        ([System.Drawing.Color]::FromArgb(255, 20, 28, 48)),
        ([System.Drawing.Color]::FromArgb(255, 56, 110, 200)),
        90
    $g.FillRectangle($brush, $rect)

    # Rounded-corner mask (subtle): draw a slightly darker border ring
    $pen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(255, 8, 16, 32)), ([int]($size * 0.03))
    $g.DrawRectangle($pen, 0, 0, $size - 1, $size - 1)

    # Connection motif: two nodes + link line (AI <-> Godot)
    $nodeR = [int]($size * 0.10)
    $leftCenter  = New-Object System.Drawing.PointF ([int]($size * 0.28), [int]($size * 0.40))
    $rightCenter = New-Object System.Drawing.PointF ([int]($size * 0.72), [int]($size * 0.40))

    # Link line (cyan)
    $linkPen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(255, 90, 220, 255)), ([int]($size * 0.04))
    $g.DrawLine($linkPen, $leftCenter, $rightCenter)

    # Left node (cyan)
    $g.FillEllipse(
        (New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 90, 220, 255))),
        $leftCenter.X - $nodeR, $leftCenter.Y - $nodeR, $nodeR * 2, $nodeR * 2)

    # Right node (Godot blue)
    $g.FillEllipse(
        (New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 88, 160, 240))),
        $rightCenter.X - $nodeR, $rightCenter.Y - $nodeR, $nodeR * 2, $nodeR * 2)

    # "MCP" text below
    $fontSize = [int]($size * 0.22)
    $font = New-Object System.Drawing.Font 'Consolas', $fontSize, ([System.Drawing.FontStyle]::Bold), ([System.Drawing.GraphicsUnit]::Pixel)
    $textBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 235, 245, 255))
    $sf = New-Object System.Drawing.StringFormat
    $sf.Alignment = [System.Drawing.StringAlignment]::Center
    $sf.LineAlignment = [System.Drawing.StringAlignment]::Center
    $textRect = New-Object System.Drawing.RectangleF 0, ([int]($size * 0.62)), $size, ([int]($size * 0.32))
    $g.DrawString('MCP', $font, $textBrush, $textRect, $sf)

    $bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose(); $bmp.Dispose()
    Write-Host "Wrote $path ($size x $size)"
}

New-Icon 256 (Join-Path $outDir 'icon.png')
New-Icon 128 (Join-Path $outDir 'icon-128.png')
