interface dailyTemperature {
    year: number,
    month: number,
    day: number,
    min: number,
    max: number
}

interface temperatureSerie {
    label: string,
    dailyTemperatures : dailyTemperature[]
}

export type { dailyTemperature, temperatureSerie };