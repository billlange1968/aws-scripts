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
