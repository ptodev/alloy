param (
    [Parameter(Mandatory = $true)]
    [string]
    $target,

    [Parameter(Mandatory = $true)]
    [string]
    $goVersion,

    [switch]
    # Switch parameter always default to false.
    $pushImage,

    [string]
    [ValidateNotNull()]
    $imageName,

    [string]
    [ValidateNotNull()]
    [ValidateSet('windows-2022', 'windows-2025')]
    $windowsVersion
)

Write-Host "target: $($target)"
Write-Host "goVersion: $($goVersion)"
Write-Host "pushImage: $($pushImage)"
Write-Host "imageName: $($imageName)"
Write-Host "windowsVersion: $($windowsVersion)"

pwd

docker build -t $target --build-arg BASE_IMAGE_WINDOWS=$imageName -f ./Dockerfile.windows --isolation=hyperv .
docker push $target
docker image ls

# docker build -t "ptodev/alloy-dev" --build-arg VERSION="paulintest" --build-arg RELEASE_BUILD=1 --build-arg BASE_IMAGE_WINDOWS="mcr.microsoft.com/windows/nanoserver:ltsc2022" -f ./Dockerfile.windows --isolation=hyperv .
# docker push "ptodev/alloy-dev"
