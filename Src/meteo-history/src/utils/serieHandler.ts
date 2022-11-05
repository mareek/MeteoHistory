import type { Station, SynopMeasure } from "@/data/meteoFranceTypes";
import type { temperatureSerie, dailyTemperature } from "@/data/meteoTypes";
import { downloadSynopFile } from "@/utils/synopFileDownloader";
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

async function createSerie(station: Station, year: number, month: number): Promise<temperatureSerie | undefined> {
    const measures = await downloadSynopFile(station, year, month);
    if (!measures)
        return undefined;

    return {
        label: year.toString(),
        dailyTemperatures: getDailyTemperatures(measures)
    };
}

function getYears(currentDate: Date): number[] {
    const lastYear = currentDate.getUTCFullYear();
    const result = [];
    for (let year = 1996; year <= lastYear; year++) {
        result.push(year);
    }
    return result;
}

async function downloadSeries(station: Station, currentDate: Date): Promise<temperatureSerie[]> {
    const month = currentDate.getUTCMonth() + 1;
    const promises = getYears(currentDate).map(y => createSerie(station, y, month));

    await Promise.all(promises);

    const result = [];
    for (let i = 0; i < promises.length; i++) {
        const serie = await promises[i];
        if (serie) {
            result.push(serie);
        }
    }
    return result;
}

export { downloadSeries };
