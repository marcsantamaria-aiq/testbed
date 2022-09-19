$fd_url=$args[0]
$token=$args[1]
$build_url = -join($fd_url,'/v1/agent_installers/build_agent_installer?id=10')
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Authorization", "Token $token")
$installer_info = Invoke-RestMethod $build_url -Headers $headers
$agent_url = $installer_info.url
$outfilename = "C:\Windows\Temp\firedrill_agent.zip"
Invoke-RestMethod $agent_url -Headers $headers -OutFile $outfilename
$ai_install_dir="C:\Windows\Temp\ai_install"
Remove-Item $ai_install_dir -Recurse
Expand-Archive -LiteralPath "C:\Windows\Temp\firedrill_agent.zip" -DestinationPath $ai_install_dir
$agent_token_ep="$fd_url/v1/users/agent_token"
$response = Invoke-RestMethod $agent_token_ep -Headers $headers
$agent_token =  $response.token
$fd_url = $fd_url.ToLower() -replace 'https://',''
$arguments = "/S /AiInstDir=`"C:\Program Files\AttackIQ\FiredrillAgent\`" /ConsoleServerAddress=`"$fd_url`" /ConsoleServerPort=`"443`" /UseHttps=`"1`" /AuthenticationToken=`"$agent_token`" /ProxyHttpScheme=`"http://`" /ProxyHttpsScheme=`"http://`" /AuthToken=`"$agent_token`" /PlatformAddress=`"$fd_url`" /PlatformPort=`"443`" "
Start-Process $ai_install_dir\*.exe -ArgumentList $arguments
Start-Sleep -Seconds 30
$service = Get-Service -Name "AttackIQ Testpoint Execute Service2" -ErrorAction SilentlyContinue
if ($service.Length -gt 0) {
  exit 0
} else {
  exit 1
}
