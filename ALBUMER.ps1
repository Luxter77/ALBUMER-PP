$ext = Read-Host " - Extension de los archivos a concatenar (sin el punto inicial)";
$mdir = "ESTE ES UN TEXTO PLACEHOLDER INVALIDO QUE NO DEVERIA EXISTIR EN TU COMPUTADORA 117843647349133%&&#4W31";
$pdir = "ESTE ES UN TEXTO PLACEHOLDER INVALIDO QUE NO DEVERIA EXISTIR EN TU COMPUTADORA 117843647349133%&&#4W31";
while ( -not ($mdir | Test-Path) ) {
	$mdir = (Read-Host " - Directorio que contiene los archivos a concatenar (relativo)" | Convert-Path )
};
while ( -not ($pdir | Test-Path) ) {
	$pdir = (Read-Host " - Direccion de la imagen a usar como portada (relativa)" | Convert-Path )
};

Get-ChildItem $mdir;
Write-Host "";

$nn = 1; $n = 0; $ns = "";

Set-Location $mdir; Set-Location "..";

Get-childItem -File $mdir | Where-Object { $_.Extension.tolower() -like ".$ext" } | ForEach-Object {
    $f = $_; $bn = $f.BaseName;
	
	if ($n -gt 0) {
		$t = (& ffprobe -i "$n.$ext" -show_entries format=duration -v quiet -of csv="p=0" -sexagesimal).split(".")[0];
	} else {
		$t = "0:00:00"
	};
	
	$o = "$t => $bn";
	
    ffmpeg -y -i "concat:$ns$f" -acodec copy "$nn.$ext" 2> $null;
    
	$ns = "$nn.$ext|";
	
	if ($n -gt 0) {
		Remove-Item -Force "$n.$ext";
	};
	
	$n = $nn; $nn = $nn + 1;
	$o | Tee-Object -Append "album.txt"
};

ffmpeg -loop 1 -i "$pdir" -i "$n.$ext" -c:v libx264 -tune stillimage -c:a aac -b:a 192k -pix_fmt yuv420p -shortest "album.mp4" 2> $null

Read-Host "Precione cualquier tecla para salir.";
