# Ways to optimize PS scripts -> https://blogs.technet.microsoft.com/ashleymcglone/2017/07/12/slow-code-top-5-ways-to-make-your-powershell-scripts-run-faster/

$mainMemorySize = 8192
$limit = $mainMemorySize / 10
$numberOfInstructions = $mainMemorySize
$random = New-Object Random

$trace = for ($i = 0; $i -lt $numberOfInstructions; $i++)
{
    $randomNum = $random.Next()
    
    # 5% de chance de acontecer
    if ($randomNum % 100 -lt 5) { $number = $randomNum % $mainMemorySize }
    else { $number = $i % $limit }

    "2 $([Convert]::ToString($number, 16))"
}

$trace | Out-File -Encoding default trace.txt
