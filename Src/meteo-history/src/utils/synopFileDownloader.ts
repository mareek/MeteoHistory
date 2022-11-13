import { parseCsv } from "./csvParser";
import { decompressResponse } from "./gzip";
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
    const csvFileName = `synop.${year}${month.toLocaleString(undefined, { minimumIntegerDigits: 2 })}.csv`;
    const url = `data/${station.ID}/${csvFileName}`;
    const response = await fetch(url);
    if (!response.ok)
        return undefined;

    const content = await response.text();
    return readSynopFile(content);
}

async function downloadSynopMonthlyArchive(station: Station, month: number): Promise<SynopMeasure[] | undefined> {
    const gzFileName = `synop.${month.toLocaleString(undefined, { minimumIntegerDigits: 2 })}.csv.gz`;
    const url = `data/${station.ID}/${gzFileName}`;
    const response = await fetch(url);
    if (!response.ok)
        return undefined;

    const content = await response.text();
    if (!content)
        return undefined

    return readSynopFile(content);
}

// This function does not work due to CORS on météo france's servers
async function doawnloadSynopFileFromMeteoFrance(station: Station, csvFileName: string): Promise<SynopMeasure[] | undefined> {
    const url = `https://donneespubliques.meteofrance.fr/donnees_libres/Txt/Synop/Archive/${csvFileName}.gz`

    const response = await fetch(url, { mode: "cors" });
    if (!response.ok)
        return undefined;

    const content = await decompressResponse(response);
    if (!content)
        return undefined

    return readSynopFile(content).filter(s => s.stationId === station.ID);
}
export { downloadSynopFile, downloadSynopMonthlyArchive };
