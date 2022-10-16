interface CsvColumn {
    order: number,
    name: string
}

interface CsvCell {
    column: CsvColumn,
    value: string
}

interface CsvRow {
    cells: CsvCell[]
}

interface CsvFile {
    columns: CsvColumn[],
    rows: CsvRow[]
}

function parseCsv(fileContent: string, separator: string): CsvFile {

    const lines = fileContent.replace('\r', '').split('\n');
    const columns = parseLine(lines[0], separator).map((v, i): CsvColumn => ({ order: i, name: v }));
    const rows: CsvRow[] = lines.slice(1).map(line => {
        const values = parseLine(line, separator);
        return { cells: columns.map((c, i) => ({ column: c, value: values[i] })) };
    });

    return {
        columns: columns,
        rows: rows
    };
}

function parseLine(line: string, separator: string): string[] {
    const cells: string[] = [];
    let cellStart = 0;
    while (cellStart < (line.length - 1)) {
        const isQuotedCell = line.charAt(cellStart) === '"';
        const cellLastChar = isQuotedCell ? '"' : separator;
        const cellValueStartPos = isQuotedCell ? cellStart + 1 : cellStart;
        let cellLastCharPos = line.indexOf(cellLastChar, cellValueStartPos);
        cellLastCharPos = cellLastCharPos < 0 ? line.length : cellLastCharPos;

        cells.push(line.substring(cellValueStartPos, cellLastCharPos));

        cellStart = cellLastCharPos + (isQuotedCell ? 2 : 1);
    }

    return cells
}

export { parseCsv }
export type { CsvFile }