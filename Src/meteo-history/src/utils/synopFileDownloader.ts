import { parseCsv } from "./csvParser";
import type { CsvRow } from "./csvParser";
import type { SynopMeasure, Station } from "@/data/meteoFranceTypes";

function parseDate(dateValue: string): Date {
    // dateValue is of the form "20200101030000" => YYYYMMDDHHmmSS
    const year = parseInt(dateValue.substring(0, 4));
    const month = parseInt(dateValue.substring(4, 6));
    const day = parseInt(dateValue.substring(6, 8));
    const hour = parseInt(dateValue.substring(8, 10));
    const minute = parseInt(dateValue.substring(10, 12));
    const second = parseInt(dateValue.substring(12, 14));
    return new Date(Date.UTC(year, month - 1, day, hour, minute, second));
}

function convertToSynopMeasure(csvRow: CsvRow): SynopMeasure | null {
    const stationIdValue = csvRow.getCellValue("numer_sta");
    const dateValue = csvRow.getCellValue("date");
    const temperatureValue = csvRow.getCellValue("t");
    const seaLevelPressureValue = csvRow.getCellValue("pmer");
    const windSpeedValue = csvRow.getCellValue("ff");
    const humidityValue = csvRow.getCellValue("u");
    const visibilityValue = csvRow.getCellValue("vv");
    if (!stationIdValue || !dateValue || !temperatureValue || !seaLevelPressureValue || !windSpeedValue || !humidityValue || !visibilityValue)
        return null;

    return {
        stationId: stationIdValue,
        date: parseDate(dateValue),
        temperature: parseFloat(temperatureValue) - 273.15, // convert from °K to °C
        seaLevelPressure: parseFloat(seaLevelPressureValue) / 100, // convert from Pa to millibar
        windSpeed: parseFloat(windSpeedValue),
        humidity: parseInt(humidityValue),
        visibility: parseInt(visibilityValue)
    };
}

function readSynopFile(csvFileContent: string): SynopMeasure[] {
    const csvFile = parseCsv(csvFileContent, ";");
    return csvFile.rows.map(convertToSynopMeasure).filter((m): m is SynopMeasure => !!m);
}

async function downloadSynopFile(station: Station, year: number, month: number): Promise<SynopMeasure[] | undefined> {
    const url = `data/${station.ID}/synop.${year}${month.toLocaleString(undefined, { minimumIntegerDigits: 2 })}.csv`;
    const response = await fetch(url);
    if (!response.ok)
        return undefined;

    //Faire un truc où on télécharge le fichier directement depuis météo france si on ne le trouve pas en "local"
    const content = await response.text();
    return readSynopFile(content);
}

export { downloadSynopFile };
