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
            $inFileStream = New-Object System.IO.FileStream $inFile, ([IO.FileMode]::Open), ([IO.FileAccess]::Read), ([IO.FileShare]::Read)
            if ($inFile.EndsWith(".gz")) {
                $inGzipStream = New-Object System.IO.Compression.GzipStream $inFileStream, ([IO.Compression.CompressionMode]::Decompress)
                $inGzipStream.CopyTo($gzipStream)
                $inGzipStream.Close()                    
            }
            else {
                $inFileStream.CopyTo($gzipStream)
            }
            $inFileStream.Close()
        }        
    }
    finally {
        if ($null -ne $gzipStream) { $gzipStream.Close() }
        if ($null -ne $outputFileStream) { $outputFileStream.Close() }
        if ($null -ne $inFileStream) { $inFileStream.Close() }
    }
}

function Out-GZip-File {
    param ([String[]]$content, [String]$outfile)
    try {
        $outputFileStream = New-Object System.IO.FileStream $outFile, ([IO.FileMode]::Create), ([IO.FileAccess]::Write), ([IO.FileShare]::None)
        $gzipStream = New-Object System.IO.Compression.GzipStream $outputFileStream, ([IO.Compression.CompressionMode]::Compress)
        $streamWriter = New-Object System.IO.StreamWriter $gzipStream
        foreach ($line in $content) {
            $streamWriter.WriteLine($line)
        }
        $streamWriter.flush()
    }
    finally {
        if ($null -ne $streamWriter) { $streamWriter.Close() }
        if ($null -ne $gzipStream) { $gzipStream.Close() }
        if ($null -ne $outputFileStream) { $outputFileStream.Close() }
    }
}