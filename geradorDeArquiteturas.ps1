$associativityLevels = "02", "04", "08", "16"
$replacementAlgorithms = "FIFO", <# "LFU", #> "LRU"
$caches = "L1", "L2", "L3"
$cachesSizesMatrix = (
	("0016", "0256", "1024"),
	("0032", "0512", "2048"),
	("0064", "1024", "4096"),
	("0128", "2048", "8192")
)

# Extrai apenas as configurações da arquitetura e as estatísticas de um log
# find . -exec sh -c 'sed -ne "/Architecture Configuration/,/Trace/p; /Statistics/,//p" "{}" > "{}.txt"' \;

$lastCachesSize = $cachesSizesMatrix[$cachesSizesMatrix.Length - 1]
$mainMemorySize = $lastCachesSize[$lastCachesSize.Length - 1]

# $lineSizes = 1, 2, 4, 8

# Com L1, L2 e L3
# 3 substitution algorithms
# 4 associativity levels
# 4 groups of memory size
# 3 memory sizes for each group
# -------
# 48 architectures

$i = -1
$folders = 
	'Arquiteturas/Caches-L1',
	'Arquiteturas/Caches-L1-L2',
	'Arquiteturas/Caches-L1-L2-L3'

foreach ($folder in $folders)
{
	rm -r -fo "$folder/*"
	$i++

	foreach ($replacementAlgorithm in $replacementAlgorithms)
	{
		foreach ($associativityLevel in $associativityLevels)
		{
			foreach ($cachesSizes in $cachesSizesMatrix)
			{
				$cachesStr = "$(echo "$($caches[0..$i])")" -replace " ", "-"
				$cachesSizesStr = "$(echo "$($cachesSizes[0..$i])")" -replace " ", "-"
				$cachesXML = foreach ($cacheSize in $cachesSizes[0..$i])
				{
@"

<Cache>
	<cacheType>Unified</cacheType>
	<unifiedCache>
		<lineSize>1</lineSize>
		<ciclesPerAccessRead>1</ciclesPerAccessRead>
		<ciclesPerAccessWrite>2</ciclesPerAccessWrite>
		<timeCicle>1</timeCicle>
		<memorySize>$cacheSize</memorySize>
		<associativityLevel>$associativityLevel</associativityLevel>
		<writePolicy>WriteThrough</writePolicy>
		<replacementAlgorithm>$replacementAlgorithm</replacementAlgorithm>
	</unifiedCache>
</Cache>
"@
				}
	
				echo @"
<?xml version="1.0" encoding="ISO-8859-1"?> 

<!DOCTYPE AmnesiaConfiguration SYSTEM "Configuration/amnesia.dtd">
<?xml-stylesheet type="text/css" href="teste.css"?>
<AmnesiaConfiguration>
<Processor>
	<processorContains>0</processorContains>
	<createTraceFile>0</createTraceFile>
</Processor>
<Trace>
	<wordSize>4</wordSize>
</Trace>
<CPU>
	<wordSize>4</wordSize>
</CPU>
<MainMemory>
	<blockSize>1</blockSize>
	<memorySize>$mainMemorySize</memorySize>
	<ciclesPerAccessRead>1</ciclesPerAccessRead>
	<ciclesPerAccessWrite>2</ciclesPerAccessWrite>
	<timeCicle>10</timeCicle>
</MainMemory>$cachesXML
</AmnesiaConfiguration>
"@ | Out-File -Encoding default "$folder/Caches-$cachesStr-$(
	if ($replacementAlgorithm -ne "FIFO") { "_$replacementAlgorithm" }
	else { $replacementAlgorithm })-AssoLvl$associativityLevel-CachesSizes$cachesSizesStr.xml"
			}
		}
	}
}
