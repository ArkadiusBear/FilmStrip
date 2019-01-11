[CmdletBinding()]
Param (
    [string] $VideoFile,
    [ValidateRange(100,4000)]
    [int] $Height = 1500,
    [ValidateRange(100,4000)]
    [int] $Width = 500,
    [int] $Density = 150,
    [switch] $KeepFrames
)

# Clear screen 
Clear-Host

# First test filepath given
if (!(Test-Path -Path $VideoFile -PathType leaf)) {
    throw "Not a valid file"
}

# Creates output filename from the video file path
$outputBasePath = Split-Path -Path $VideoFile -Parent
$outputFileName = ((Split-Path -Path $VideoFile -Leaf).Split('.'))[0] + '.bmp'
$outputFilePath = Join-Path -Path $outputBasePath -ChildPath $outputFileName

# Remove any old temp directory and then make a new one
New-Item -ItemType Directory -Path $PSScriptRoot\TempScreenCaps -Force | Out-Null

# Get the total time in seconds of the video file
$totalTime = [int](& $PSScriptRoot\binaries\ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 $VideoFile)

Write-Verbose "Creating final image measuring $($Width)x$($Height) for file $VideoFile which is $totalTime seconds long"

# Create size variable
$imageSize = [string]$Width + 'x' + [string]$Height

# Create final image base canvas to add strips to
& $PSScriptRoot\binaries\ImageMagick\magick.exe convert -size $imageSize 'xc:#000000' $outputFilePath

# Generates all the frames, average colour and creates final image
For ($i=0; $i -lt $Density; $i++) {

    # Sets frame path and current time in seconds
    $framePath = "$PSScriptRoot\TempScreenCaps\Frame$($i).jpg"
    $currentTime = [int](($totalTime/$Density)*$i)

    # Uses ffmpeg to extract frame at current time
    & $PSScriptRoot\binaries\ffmpeg.exe -ss $currentTime -i $VideoFile -frames:v 3 -y $framePath 2>&1 | Out-Null
    Write-Verbose "Generated frame $i of $density at $currentTime seconds"

    # Uses magick to extract the average colour of the frame to hex and stick in array
    $hexCode = (((& $PSScriptRoot\binaries\ImageMagick\magick.exe convert $framePath -resize 1x1 txt:-)[1]) -Split (' '))[3]
    $hexCodeArg = '"' + $hexCode + '"'
    Write-Verbose "Obtained average hex colour $hexCode for frame $i"

    # Draw a rectangle on the main image at the correct location with the correct fill
    $coord1 = '0,' + [string](($Height/$Density)*$i)
    $coord2 = [string]$Width + ',' + [string](($Height/$Density)*($i+1))
    & $PSScriptRoot\binaries\ImageMagick\magick.exe convert $outputFilePath -stroke none -fill $hexCodeArg -draw "rectangle $coord1 $coord2" $outputFilePath
    Write-Verbose "Added rectangle to main image from $coord1 to $coord2 using fill $hexCode"

    # Write progress bar to console
    $percentComplete = (($i + 1) / $density) * 100
    Write-Progress -Activity 'Creating image' -Status "Frame $i of $density complete" -PercentComplete $percentComplete
}

# Wipes temp folder if specified
if (!($KeepFrames)) {
    Remove-Item -Path $PSScriptRoot\TempScreenCaps -Recurse -Force | Out-Null
}

# Displays final result
& $outputFilePath


