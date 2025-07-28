# API URLs
$statusUrl = "https://status.opsgenie.com/api/v2/status.json"
$incidentUrl = "https://status.opsgenie.com/api/v2/incidents.json"
$webhookUrl = "https://webhook.site/some-status-app"

# Get the system status
try {
    $statusResponse = Invoke-RestMethod -Uri $statusUrl -Method Get
    $overallStatus = $statusResponse.status.description 
}
catch {
    write-error "Failed to retrieve system status: $_"
    exit 1
}

# Get recent incidents
try {
    $incidentsResponse = Invoke-RestMethod -Uri $incidentUrl -Method Get
    $recentIncidents = $incidentsResponse.incidents | Select-Object -First 3
}
catch {
    write-error "Failed to retrieve incidents: $_"
    exit 1 
}

# Format incident infromation 
$incidentText = ""
foreach ($incident in $recentIncidents) {
    $name = $incident.name
    $createAt = (Get-date $incident.created_at).ToLocalTime().ToString("HH:mm dd/MM/yyyy")
    $status = $incident.status

    $incidentText += "Issue: $name`nCreated: $createAt`nStatus: $status`n---`n"
}

# Message to post to slack
$slackMessage = @"
Current systems status: $overallstatus

Last 3 incidents:

$incidentText
"@

#Convert to JSON payload
$payload = @{
    text = $slackMessage
} | ConvertTo-Json -depth 2

#Send to webhook
try{
    Invoke-RestMethod -Uri $webhookUrl -Method Post -Body $payload -ContentType 'application/json'
    Write-host "Message sent Successfully!"
}
catch{
    write-error "Failed to send message to Slack webhook: $_"
}

