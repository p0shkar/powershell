function New-CharacterStats {
    Param(
        [switch]$Verbose
    )
    $AbilityScores = @()
    for($AbilityRolls = 1; $AbilityRolls -le 6; $AbilityRolls++){
        $Roll = @()
        for($D6 = 1; $D6 -le 4; $D6++){
            $Roll += Get-Random -Minimum 1 -Maximum 6
        }
        $Minimum = [int]($Roll | measure -Minimum).Minimum
        $Sum = [int]($Roll | measure -Sum).Sum
        $SumMinusMinimum = $Sum - $Minimum
        if($Verbose -eq $true){
            Write-Host -f "White" "Rolled 4D6: $Roll"
            Write-Host -f "White" "Removing minimum roll: $Minimum"
            Write-Host -f "Cyan" "Total Ability Score: $SumMinusMinimum"
        }
        $AbilityScores += $SumMinusMinimum
    }
    Write-Host -f "Yellow" "Your total ability scores are: $AbilityScores"
}