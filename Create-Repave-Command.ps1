param(
    [string]$region = "us-east-1",
    [string]$type = "batch"
)

Clear-Host

# Retrieve the list of State Machines
Write-Host "Getting list of State Machines from AWS for $region region."
$StateMachinesJsonObject = aws stepfunctions list-state-machines --region $region --output json | ConvertFrom-Json

# Retrieve the list of Lambda functions
Write-Host "Getting list of $type Lambda Functions from AWS for $region region."
$FunctionsJsonObject = aws lambda list-functions --region $region --output json | ConvertFrom-Json

# Filter and process Lambda functions
Write-Host "Filtering for *app-repave-asg-lambda* Lambda functions."
Write-Host
foreach ($function in $FunctionsJsonObject.Functions) {
    $functionName = $function.FunctionName
    $functionArn = $function.FunctionArn

    if ($functionName -like "*app-repave-asg-lambda*") {
        # Retrieve tags for the Lambda function
        $TagsJsonObject = aws lambda list-tags --resource $functionArn --output json | ConvertFrom-Json
        $TFE_WORKSPACE = $TagsJsonObject.Tags.TFE_WORKSPACE

        if ($TFE_WORKSPACE -like "*$type*") {
            $FunctionNameCode = $functionName.Substring($functionName.Length - 12)
            $RuleName = "asgRepave-$FunctionNameCode"

            # Retrieve event rule details
            $RulesJsonObject = aws events list-rules --name-prefix $RuleName --output json | ConvertFrom-Json
            $RuleDescription = $RulesJsonObject.Rules.Description
            $AutoScalingGroupName = ($RuleDescription -split ' ')[-1]

            Write-Host "FunctionName: $functionName"
            Write-Host "FunctionArn: $functionArn"
            Write-Host "Rule Name: $RuleName"
            Write-Host "AutoScalingGroupName: $AutoScalingGroupName"

            # Match state machines with the function
            foreach ($StateMachine in $StateMachinesJsonObject.stateMachines) {
                $StateMachineArn = $StateMachine.StateMachineArn

                if ($StateMachineArn -like "*$FunctionNameCode*") {
                    $StateMachineTagsJsonObject = aws stepfunctions list-tags-for-resource --resource-arn $StateMachineArn --region $region --output json | ConvertFrom-Json
                    $sm_tfeWorkspace = ($StateMachineTagsJsonObject.tags | Where-Object { $_.key -eq "TFE_WORKSPACE" }).value

                    if ($TFE_WORKSPACE -eq $sm_tfeWorkspace) {
                        Write-Host "StateMachineArn: $StateMachineArn"
                        Write-Host "AWS CLI command to repave $AutoScalingGroupName in $region is as follows:"
                        Write-Host "aws stepfunctions start-execution --state-machine-arn $StateMachineArn --input ""{\""AsgName\"": \""$AutoScalingGroupName\""}""" -ForegroundColor Yellow
                    }
                }
            }
            Write-Host
        }
    }
}
