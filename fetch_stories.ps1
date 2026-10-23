# Downloads long Reddit stories to stories.json on the Desktop.
$ErrorActionPreference = "Continue"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$subs = "AmItheAsshole","tifu","MaliciousCompliance","pettyrevenge","ProRevenge","entitledparents","TrueOffMyChest","relationship_advice"
$periods = "year","all"
$out = @{}
foreach ($s in $subs) {
  foreach ($t in $periods) {
    try {
      $u = "https://www.reddit.com/r/$s/top.json?t=$t&limit=100&raw_json=1"
      $r = Invoke-RestMethod -Uri $u -UserAgent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/124 Safari/537.36" -TimeoutSec 30
      foreach ($c in $r.data.children) {
        $d = $c.data
        if (-not $d.is_self -or $d.stickied -or $d.over_18) { continue }
        $words = ($d.selftext -split '\s+').Count
        if ($words -lt 600 -or $words -gt 3500) { continue }
        $out[$d.id] = [ordered]@{
          id = $d.id; subreddit = $d.subreddit; title = $d.title; text = $d.selftext
          score = $d.score; comments = $d.num_comments
          url = "https://www.reddit.com" + $d.permalink; nsfw = $false
        }
      }
      Write-Host "r/$s ($t): ok, total $($out.Count)"
    } catch {
      Write-Host "r/$s ($t): error $($_.Exception.Message)"
    }
    Start-Sleep -Seconds 3
  }
}
$path = Join-Path ([Environment]::GetFolderPath("Desktop")) "stories.json"
$json = ConvertTo-Json -InputObject @($out.Values) -Depth 4
[IO.File]::WriteAllText($path, $json, (New-Object Text.UTF8Encoding $false))
Write-Host "Done: $($out.Count) stories. File: $path"
