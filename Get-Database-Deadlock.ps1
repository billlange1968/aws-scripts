<#
.SYNOPSIS
  Retrieves and processes CloudWatch log for deadlock events for a specified RDS instance.

.DESCRIPTION
  This script connect to AWS CloudWatch, retrieves log events for a specified RDS SQL Server instance,
  and processes the logs to identify deadlock events and related information.

.PARAMETER dbInstanceId
  The identifier of the RDS instance for which to retrieve log events.

.PARAMETER startTime
  The start time for the log retrieval window in the format 'yyyy-MM-dd HH:mm:ss'.

.EXAMPLE
  powershell -command ". .\Get-Database-Deadlock.ps1; Get-Database-Deadlock -dbInstanceId '############' -startTime '2025-02-23 03:00:00.00'"

.NOTES
  Author: William R. Lange
  Date: February 25, 2025
  Version: 1.0
  Requires: AWS CLI, PowerShell

.LINK https://docs.aws.amazon.com/cli/latest/reference/logs/get-log-events.html
#>

function Get-Database-Deadlock {
  param(
    [string]$dbInstanceId,
    [string]$startTime
  )

  $logGroupName = "/aws/rds/instance/rds-database-sql-server-$dbInstanceId/error"
  $logStreamName = "rds-database-sql-server-$dbInstanceId.node1"

  $startTimeDT = [datetime]::Parse($startTime)
  $endTimeMS = $startTimeDT.AddMinutes(30)

  $startTimeDT = Convert-DateTime-To-Milliseconds $startTimeDT
  $endTimeDT = Convert-DateTime-To-Milliseconds $endTImeDT

  Write-Host = aws logs get-log-events --log-group-name $logGroupName --log-stream-name $logStreamName --start-time $startTimeMS --end-time $endTimeMS --output json | ConvertFrom-Json

  $spid = $null

  foreach ($event in $events.Events) {
    $timestamp = $event.timestamp
    $message = $event.message.Trim()

    if ($message -like "*Deadlock encountered*") {
      if ($message -match "\bspid\S*") {
        $spid = $matches[0]
      }
      Write-Host "Deadlock at $timestamp. SPID: $spid. Message: '$message'."
    }
    elseif ($message -like "* spid*") {
      Write-Host "$message"
    }
  }
}

function Convert-DateTime-To-Milliseconds {
  param(
    [datetime]$datetime
  )

  $epoch = Get-Date "1970-01-01T00:00:00Z"

  # Calculate the difference in milliseconds
  $milliseconds = [math]::Round(($datetime - $epoch).TotalMilliseconds)

  return $milliseconds
}

# Example usage
$dbInstanceId = "############"
#$startTime = "2025-02-23 03:00:00.00"
#Get-Database-Deadlock -dbInstanceId $dbInstanceId -startTime $startTime
