import { parseCsv } from "./csvParser";
import type { CsvRow } from "./csvParser";
import type { SynopMeasure, Station } from "../data/meteoFranceTypes";

function parseDate(dateValue: string): Date {
    const year = dateValue.substring(0, 4);
    const month = dateValue.substring(4, 6);
    const day = dateValue.substring(6, 8);
    const hour = dateValue.substring(8, 10);
    const minute = dateValue.substring(10, 12);
    const second = dateValue.substring(12, 14);
    const isoStrDate = `${year}-${month}-${day}T${hour}:${minute}:${second}.000Z`;
    return new Date(isoStrDate);
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

async function downloadSynopFile(station: Station, year: number, month: number): Promise<SynopMeasure[]> {
    const url = `data/${station.ID}/synop.${year}${month.toLocaleString(undefined, { minimumIntegerDigits: 2 })}.csv`;
    const response = await fetch(url);
    if (!response.ok)
        return [];

    const content = await response.text();
    return readSynopFile(content);
}

function readSynopFile(content: string) {
    const csvFile = parseCsv(content, ";");
    return csvFile.rows.map(convertToSynopMeasure).filter((m): m is SynopMeasure => m != null);
}
