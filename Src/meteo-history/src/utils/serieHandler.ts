import type { Station, SynopMeasure } from "@/data/meteoFranceTypes";
import type { temperatureSerie, dailyTemperature } from "@/data/meteoTypes";
import { downloadSynopFile, downloadSynopMonthlyArchive } from "@/utils/synopFileDownloader";
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
    const years = getYears(currentDate);
    const result = await downloadSeriesByArchive(station, month, years);
    if (!!result)
        return result;

    return await downloadSeriesByFile(station, month, years);
}

async function downloadSeriesByFile(station: Station, month: number, years: number[]): Promise<temperatureSerie[]> {
    const promises = years.map(y => downloadSynopFile(station, y, month));

    await Promise.all(promises);

    const measures: SynopMeasure[] = [];
    for (let i = 0; i < promises.length; i++) {
        const serie = await promises[i];
        if (serie) {
            measures.push(...serie);
        }
    }
    return createSeries(years, measures);
}

async function downloadSeriesByArchive(station: Station, month: number, years: number[]): Promise<temperatureSerie[] | undefined> {
    const measures = await downloadSynopMonthlyArchive(station, month);
    if (!measures)
        return undefined;

    return createSeries(years, measures);
}


export { downloadSeries };
