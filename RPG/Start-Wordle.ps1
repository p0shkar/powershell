# Wordle-like PowerShell Game

#region | FUNCTIONS
function Show-Alphabet {
    $line = ""
    foreach ($c in 'a'..'z') {
        $color = $alphabet[$c]
        switch ($color) {
            'green' { $line += "$([char]27)[32m$($c.tostring().ToUpper())$([char]27)[0m " }
            'yellow' { $line += "$([char]27)[33m$($c.tostring().ToUpper())$([char]27)[0m " }
            'red' { $line += "$([char]27)[31m$($c.tostring().ToUpper())$([char]27)[0m " }
            default { $line += "$($c.tostring().ToUpper()) " }
        }
    }
    Write-Host "Alphabet: $line"
}

function Update-Alphabet($guess, $secret) {
    for ($i = 0; $i -lt 5; $i++) {
        if ($guess[$i] -eq $secret[$i]) {
            $alphabet[$guess[$i]] = 'green'
        } elseif ($secret.Contains($guess[$i])) {
            if ($alphabet[$guess[$i]] -ne 'green') {
                $alphabet[$guess[$i]] = 'yellow'
            }
        } else {
            if ($alphabet[$guess[$i]] -notin @('green','yellow')) {
                $alphabet[$guess[$i]] = 'red'
            }
        }
    }
}

function Show-Feedback($guess, $secret) {
    $output = ""
    for ($i = 0; $i -lt 5; $i++) {
        $Letter = $guess[$i].ToString().ToUpper()
        if ($guess[$i] -eq $secret[$i]) {
            $output += "$([char]27)[32m[$($Letter)]$([char]27)[0m" # Green brackets for correct position
        } elseif ($secret.Contains($guess[$i])) {
            $output += "$([char]27)[33m[$($Letter)]$([char]27)[0m" # Yellow brackets for wrong position
        } else {
            $output += "[$($Letter)]" # White brackets for not in word
        }
    }
    Write-Host $output
}
#endregion | FUNCTIONS

#region | VARIABLES
# List of 5-letter words (you can expand this list)
$maxTries = 6
$words = @(
    "flame", "stone", "sword", "magic", "quest", "giant", "witch", "knave", "beast", "armor",
    "blade", "cloak", "elven", "dwarf", "fairy", "spell", "torch", "crown", "raven", "vigor",
    "troll", "griff", "lance", "pagan", "altar", "forge", "golem", "herbs", "joust", "knoll",
    "nymph", "ogres", "pouch", "realm", "rider", "siege", "thief", "vigil", "wight", "wyver",
    "abbey", "basil", "charm", "crypt", "drake", "ember", "fauna", "ghoul", "hydra", "ivory",
    "arrow", "bards", "brave", "curse", "demon", "elves", "fable", "faith", "feast", "vexed",
    "frost", "ghost", "guard", "haunt", "honor", "jewel", "knock", "lords", "maids", "mirth",
    "mines", "moons", "noble", "orcas", "pacts", "pious", "plume", "pride", "runes", "sages",
    "rings", "ruins", "saint", "shade", "sheep", "shrew", "spies", "spook", "steed", "tombs",
    "sworn", "tales", "titan", "tower", "vines", "wands", "wrath", "siren", "relic", "fiend"
)
#endregion | VARIABLES

# Build the alphabet dictionary
$alphabet = @{}
foreach ($c in 'a'..'z') {
    $alphabet[$c] = 'white'
}

Write-Host "Welcome to PowerShell Wordle!"
Write-Host "Guess the 5-letter word. You have $maxTries tries."
$secret = $words | Get-Random
for ($try = 1; $try -le $maxTries; $try++) {
    Show-Alphabet
    $guess = Read-Host "Try $try/$maxTries - Enter your guess"
    $guess = $guess.ToLower()
    if ($guess.Length -ne 5) {
        Write-Warning -Message "Please enter a 5-letter word."
        $try--
        continue
    }
    Update-Alphabet $guess $secret
    Show-Feedback $guess $secret
    if ($guess -eq $secret) {
        Write-Host "Congratulations! You guessed the word!"
        break
    }
    if ($try -eq $maxTries) {
        Write-Host "Sorry, the word was: $secret"
    }
}