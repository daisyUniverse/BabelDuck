# Convert To DuckyScript
# A Custom written intermediary language
# Written to make writing DuckyScript a little nicer
# Robin Universe [R]
# 02 . 28 . 23

# Desired functionality
# 1. Repeat functionality
# 2. Custom functions
# 3. Precalculation of variables into code

$Output = ''
[String[]]$Functions

function Convert-ToDuckyScript ( [Parameter(Mandatory=$true)][String]$InputCode ) {
    # Get all lines of code, ditching trailing and leading spaces
    $Lines = $InputCode -split '/r?/n' | ForEach-Object { $_.Trim() }

    # Loop through the code
    foreach ($Line in $Lines){
        if ($Line -ne '' -and $Line -notmatch '^//'){                   # Skip empty lines and // comments
            $Tokens = $Line -split '/s+' | ForEach-Object {$_.Trim()}   # Break each line down into tokens
            switch ($Tokens[0]) {                                       # Depending on the token, send the job off to different functions
                "repeat"    { repeat $Tokens }                          # Repeat a key a number of times
                "type"      { type   $Tokens }                          # Simple "STRING" replacement
                "delay"     { delay  $Tokens }                          # Implement a delay that takes unit options
                "function"  { functionAdd $Tokens[1] }                  # Add a Function by name to an internal dict containing all functions
                Default     { Write-Host "'$Tokens' is not valid syntax!" -ForegroundColor Red }
            }
        }
    }
}

# Find all functions
function Parse-Functions ( [String]$InputCode ){
    $Lines = $InputCode -split '/r?/n' | ForEach-Object { $_.Trim() }
    foreach ($Line in $Lines) {
        if ($Line -ne '' -and $Line -notmatch '^//'){   
            $Tokens = $Line -split '/s+' | ForEach-Object {$_.Trim()}
            if ($Tokens[0] -eq "function"){ $Functions += $Tokens[1].split("(")[0].Trim() }
        }
    }
}

function Add-Function ( [String]$FunctionName ) {
    # This is gonna be kind of a pain so let's get this logic lined out
    # 1. Do an initial code scan to find all function content and calls 
    # 2. Do a secondary code scan that simply replaces all calls with function contents
    # 3. Do a final code parsing with all code content in place
}

function repeat ( [String[]]$Tokens ) {
    # If Token[1] is a function name, parse that and repeat it Token[2] times
    $key = $Tokens[1]
    $reps = $Tokens[2]
    buffer "REPEAT $reps { $key }"
}

function type ( [String[]]$Tokens ) {
    $String = $Tokens[1]   
    buffer "STRING $String"
}

function delay ([String[]]$Tokens) { # Interpet Delays with options for MS, Seconds, or Minutes
    $Time = $Tokens[1]
    if ( $null -ne $Tokens[2] ){
        $Unit = $Tokens[2]
    } else { $Unit = "" }
    switch ($Unit) {
        "Minutes"       { $multiplier = 60000 }
        "Seconds"       { $multiplier = 1000  }
        "Milliseconds"  { $multiplier = 0     }
        Default         { $multiplier = 0     }
    }
    $FinalTime = $Time * $multiplier
    buffer "DELAY $FinalTime"
}

function buffer ([String]$DuckyScript) {
    $Output += ($DuckyScript + "`n")
}
