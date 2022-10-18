import type { CsvRow } from "./csvParser";
import type { SynopMeasure } from "../data/meteoFranceTypes";

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
    const dateValue = csvRow.getCellValue("date");
    const temperatureValue = csvRow.getCellValue("t");
    const seaLevelPressureValue = csvRow.getCellValue("pmer");
    const windSpeedValue = csvRow.getCellValue("ff");
    const humidityValue = csvRow.getCellValue("u");
    const visibilityValue = csvRow.getCellValue("vv");
    if (!dateValue || !temperatureValue || !seaLevelPressureValue || !windSpeedValue || !humidityValue || !visibilityValue)
        return null;

    return {
        date: parseDate(dateValue),
        temperature: parseFloat(temperatureValue) - 273.15,
        seaLevelPressure: parseFloat(seaLevelPressureValue) / 100,
        windSpeed: parseFloat(windSpeedValue),
        humidity: parseInt(humidityValue),
        visibility: parseInt(visibilityValue)
    };
}