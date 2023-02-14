function Expand-GZip-File {
    Param([String]$infile, [String]$outfile = ($infile -replace '\.gz$', ''))
    try {
        $fileStream = New-Object System.IO.FileStream $inFile, ([IO.FileMode]::Open), ([IO.FileAccess]::Read), ([IO.FileShare]::Read)
        $outputFileStream = New-Object System.IO.FileStream $outFile, ([IO.FileMode]::Create), ([IO.FileAccess]::Write), ([IO.FileShare]::None)
        $gzipStream = New-Object System.IO.Compression.GzipStream $fileStream, ([IO.Compression.CompressionMode]::Decompress)
        $gzipStream.CopyTo($outputFileStream)
    }
    finally {
        if ($null -ne $gzipStream) { $gzipStream.Close() }
        if ($null -ne $outputFileStream) { $outputFileStream.Close() }
        if ($null -ne $fileStream) { $fileStream.Close() }
    }
}

function Compress-GZip-Files {
    param ([String[]]$inFiles, [String]$outfile)
    try {
        $outputFileStream = New-Object System.IO.FileStream $outFile, ([IO.FileMode]::Create), ([IO.FileAccess]::Write), ([IO.FileShare]::None)
        $gzipStream = New-Object System.IO.Compression.GzipStream $outputFileStream, ([IO.Compression.CompressionMode]::Compress)
        foreach ($inFile in $inFiles) {
            $fileStream = New-Object System.IO.FileStream $inFile, ([IO.FileMode]::Open), ([IO.FileAccess]::Read), ([IO.FileShare]::Read)
            $fileStream.CopyTo($gzipStream)
            $fileStream.Close()
        }        
    }
    finally {
        if ($null -ne $gzipStream) { $gzipStream.Close() }
        if ($null -ne $outputFileStream) { $outputFileStream.Close() }
        if ($null -ne $fileStream) { $fileStream.Close() }
    }
}