$fd_url=$args[0]
$token=$args[0]
$build_url = -join($fd_url,'/v1/agent_installers/build_agent_installer?id=10')
$installer_info = Invoke-RestMethod $build_url -Headers $headers
$agent_url = $installer_info.url
$outfilename = "C:\Windows\Temp\firedrill_agent.zip"
$header2 = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$header2.Add("Authorization", "Token $token")
Invoke-RestMethod $agent_url -Headers $header2 -OutFile $outfilename
$ai_install_dir="C:\Windows\Temp\ai_install"
Remove-Item $ai_install_dir
Expand-Archive -LiteralPath "C:\Windows\Temp\firedrill_agent.zip" -DestinationPath $ai_install_dir
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$agent_token_ep="$fd_url/v1/users/agent_token"
$header = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$header.Add("Authorization", "Token $token")
$response = Invoke-RestMethod $agent_token_ep -Headers $header
$agent_token =  $response.token
$fd_url = $fd_url.ToLower() -replace 'https://',''
$arguments = "/S /AiInstDir=`"C:\Program Files\AttackIQ\FiredrillAgent\`" /ConsoleServerAddress=`"$fd_url`" /ConsoleServerPort=`"443`" /UseHttps=`"1`" /AuthenticationToken=`"$agent_token`" /ProxyHttpScheme=`"http://`" /ProxyHttpsScheme=`"http://`" /AuthToken=`"$agent_token`" /PlatformAddress=`"$fd_url`" /PlatformPort=`"443`" "
Start-Process $ai_install_dir\*.exe -ArgumentList $arguments
