param(
    [Parameter(Mandatory = $true)][string]$Csv,
    [int]$Nombre = 120
)
$mesures = for ($i = 0; $i -lt $Nombre; $i++) {
    $heure = Get-Date -Format o
    $chrono = [System.Diagnostics.Stopwatch]::StartNew()
    try {
        $r = Invoke-WebRequest http://127.0.0.1:8088 -UseBasicParsing -TimeoutSec 2 -ErrorAction Stop
        $code = [string]$r.StatusCode
        $contenu = $r.Content.Trim()
        $httpOK = ($r.StatusCode -eq 200)
        $metierOK = $httpOK -and ($contenu -match '^SHOPALTO WEB[12] OK$')
    } catch {
        $code = 'ERREUR'
        $contenu = $_.Exception.Message
        $httpOK = $false
        $metierOK = $false
    }
    $chrono.Stop()
    $m = [pscustomobject]@{
        Heure = $heure; Code = $code
        DureeMs = $chrono.ElapsedMilliseconds
        HttpOK = $httpOK; MetierOK = $metierOK
        Contenu = $contenu
    }
    Write-Host "$heure $code $metierOK $contenu"
    $m
    Start-Sleep -Seconds 1
}
$mesures | Export-Csv $Csv -NoTypeInformation -Encoding UTF8
Write-Host "Mesures enregistrees dans $Csv"
