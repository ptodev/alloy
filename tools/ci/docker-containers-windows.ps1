param (
    [string]
    [ValidateNotNull()]
    $tag,

    [string]
    [ValidateNotNull()]
    [ValidateSet('2025', '2022', '2019')]
    $windowsVersion
)

# Write-Host "target: $($target)"
# Write-Host "pushImage: $($pushImage)"
# Write-Host "imageName: $($imageName)"
Write-Host "windowsVersion: $($windowsVersion)"

$baseImages := @{
    '2025' = 'mcr.microsoft.com/windows/nanoserver:ltsc2025'
    '2022' = 'mcr.microsoft.com/windows/nanoserver:ltsc2022'
    '2019' = 'mcr.microsoft.com/windows/nanoserver:ltsc2019'
}

$imageNames := @{ 
    '2025' = 'windowsservercore-ltsc2025'
    '2022' = 'windowsservercore-ltsc2022'
    '2019' = 'nanoserver-1809'
}

# Example image names:
# * Release branch: 
#   * grafana/alloy:v1.9.1-nanoserver-1809
#   * grafana/alloy:v1.9.2-windowsservercore-ltsc2022
# * Main branch:
#   * grafana/alloy:nanoserver-1809
#   * grafana/alloy:windowsservercore-ltsc2022

$githubTag := ""
if ($Env:GITHUB_REF_TYPE = "tag") {
  $githubTag = $Env:GITHUB_REF_NAME
}

$releaseAlloyImage := 'grafana/alloy'
$develAlloyImage := 'grafana/alloy-dev'


if [[ -n "$GITHUB_TAG" && "$GITHUB_TAG" != *"-rc."* ]] || [[ "$TARGET_CONTAINER" == *"-devel"* ]]; then
  BRANCH_TAG=$DEFAULT_LATEST
else
  BRANCH_TAG=$VERSION_TAG
fi





docker build -t $imageName --build-arg BASE_IMAGE_WINDOWS=$imageName -f ./Dockerfile.windows --isolation=hyperv .
docker push $target
docker image ls

# docker build -t "ptodev/alloy-dev" --build-arg VERSION="paulintest" --build-arg RELEASE_BUILD=1 --build-arg BASE_IMAGE_WINDOWS="mcr.microsoft.com/windows/nanoserver:ltsc2022" -f ./Dockerfile.windows --isolation=hyperv .
# docker push "ptodev/alloy-dev"

function Get-VersionTag() {
  $version := ''
  if ($Env:GITHUB_TAG) {
    $version = $Env:GITHUB_TAG
  } else {
    # NOTE(rfratto): Do not use ./tools/image-tag-docker here, which doesn't
    # produce valid semver.
    $version = $(./tools/image-tag)
  }

   $versionTag := ${version//+/-}-$IMAGE_NAME_SUFFIX

}