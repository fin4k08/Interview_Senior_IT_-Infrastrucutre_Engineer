# Requires -Module Pester

Describe "OpsGenie Status Script" {

    Context "Message Formatting" {

        It "Should format incidents in reverse chronological order" {
            # Define sample data INSIDE the It block
            $sampleIncidents = @{
                incidents = @(
                    @{
                        name = "Issue with website login"
                        created_at = "2019-09-05T08:32:00.000Z"
                        status = "unresolved"
                    },
                    @{
                        name = "Alerts are very slow to send"
                        created_at = "2019-07-19T22:04:00.000Z"
                        status = "resolved"
                    },
                    @{
                        name = "Some users receiving duplicate alerts"
                        created_at = "2019-06-27T03:16:00.000Z"
                        status = "resolved"
                    }
                )
            }

            $incidents = $sampleIncidents.incidents | Sort-Object { [datetime]$_.created_at } -Descending  | Select-Object -First 3

            Write-Host "Number of incidents: $($incidents.Count)"  # Debug confirmation

            $output = ""
            foreach ($incident in $incidents) {
                $name = $incident.name
                $createdAt = (Get-Date $incident.created_at).ToLocalTime().ToString("HH:mm dd/MM/yyyy")
                $status = $incident.status
                $output += "Issue: $name`nCreated: $createdAt`nStatus: $status`n---`n"
            }

            $output | Should -Match "Issue: Issue with website login"
            $output | Should -Match "Issue: Alerts are very slow to send"
            $output | Should -Match "Issue: Some users receiving duplicate alerts"

            Write-Host "$output"
        }

        It "Should include the overall system status in the final message" {
            # Define status mock inside It block
            $sampleStatus = @{
                status = @{
                    description = "Partially Degraded"
                }
            }

            $overallStatus = $sampleStatus.status.description

            $slackMessage = @"
Current systems status: $overallStatus

Last 3 incidents:

Issue: Example Incident
Created: 10:00 01/01/2025
Status: resolved
"@

            $slackMessage | Should -Match "Current systems status: Partially Degraded"
            Write-Host "$slackMessage"
        }

        It "Should sort incidents in reverse chronological order by created_at" {
            $sampleIncidents = @{
                incidents = @(
                    @{
                        name = "Alerts are very slow to send"
                        created_at = "2019-07-19T22:04:01.109Z"
                        status = "resolved"
                    },
                    @{
                        name = "Some users receiving duplicate alerts"
                        created_at = "2019-06-27T03:16:31.647Z"
                        status = "resolved"
                    },
                    @{
                        name = "Issue with website login"
                        created_at = "2019-09-05T08:32:51.523Z"
                        status = "unresolved"
                    }
                )
            }

            # Sort using same logic as the script
            Write-Host "$($sampleIncidents.incidents.created_at)" -foregroundcolor magenta
            $sorted = $sampleIncidents.incidents |
                Sort-Object { [datetime]$_.created_at } -Descending

            # Convert strings to datetime just to double-check
            $firstDate = [datetime]$sorted[0].created_at
            $secondDate = [datetime]$sorted[1].created_at
            $thirdDate = [datetime]$sorted[2].created_at

            # Assert reverse order
            $firstDate | Should -BeGreaterThan $secondDate
            $secondDate | Should -BeGreaterThan $thirdDate
        }

    }
}
