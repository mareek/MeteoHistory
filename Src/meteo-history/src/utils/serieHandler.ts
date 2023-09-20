import type { Station, SynopMeasure } from "@/data/meteoFranceTypes";
import type { temperatureSerie, dailyTemperature } from "@/data/meteoTypes";
import { downloadSynopMonthlyArchive, downloadCurrentMonthFile } from "@/utils/synopFileDownloader";
import _ from "lodash";

function createDailyTemperature(dailyMeasures: SynopMeasure[]): dailyTemperature {
    const date = dailyMeasures[0].date;
    return {
        year: date.getUTCFullYear(),
        month: date.getUTCMonth() + 1,
        day: date.getUTCDate(),
        min: _.min(dailyMeasures.map(m => m.temperature))!,
        max: _.max(dailyMeasures.map(m => m.temperature))!
    };
}

function getDailyTemperatures(measures: SynopMeasure[]): dailyTemperature[] {
    return _.chain(measures)
        .groupBy(m => `${m.date.getUTCFullYear()}-${m.date.getUTCMonth() + 1}-${m.date.getUTCDate()}`)
        .map(createDailyTemperature)
        .value();
}

function createSeries(years: number[], measures: SynopMeasure[]): temperatureSerie[] {
    return years.map(year => createSerie(year, measures.filter(m => m.date.getUTCFullYear() === year)))
        .filter((serie): serie is temperatureSerie => !!serie)
}

function createSerie(year: number, measures: SynopMeasure[]): temperatureSerie | undefined {
    if (!measures?.length)
        return undefined;

    return {
        label: year.toString(),
        dailyTemperatures: getDailyTemperatures(measures)
    };
}

function getYears(currentDate: Date): number[] {
    const lastYear = currentDate.getFullYear();
    const result = [];
    for (let year = 1996; year <= lastYear; year++) {
        result.push(year);
    }
    return result;
}

async function downloadSeries(station: Station, currentDate: Date): Promise<temperatureSerie[]> {
    const month = currentDate.getMonth() + 1;
    const year = currentDate.getFullYear();
    const archivePromise = downloadSynopMonthlyArchive(station, month);
    const partialPromise = downloadCurrentMonthFile(station, year, month);
    const measures = (await archivePromise).concat(await partialPromise);

    return createSeries(getYears(currentDate), measures);
}


export { downloadSeries };
