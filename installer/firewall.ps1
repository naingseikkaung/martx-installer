param([int]$Port = 5002, [switch]$Remove)
$ErrorActionPreference = 'Stop'
$rule = 'MartX POS LAN'
if ($Remove) { Remove-NetFirewallRule -DisplayName $rule -ErrorAction SilentlyContinue } else { Remove-NetFirewallRule -DisplayName $rule -ErrorAction SilentlyContinue; New-NetFirewallRule -DisplayName $rule -Direction Inbound -Action Allow -Protocol TCP -LocalPort $Port -Profile Private | Out-Null }
