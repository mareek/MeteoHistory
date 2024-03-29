export interface Station {
    ID: string,
    Nom: string,
    Latitude: number,
    Longitude: number,
    Altitude: number
}

export interface Geometry {
    coordinates: number[]
}

export interface Feature {
    properties: Station,
    geometry: Geometry
}

export interface FeatureCollection {
    features: Feature[]
}

export interface SynopMeasure {
    stationId: string,
    date: Date,
    temperature: number,
    seaLevelPressure: number,
    windSpeed: number,
    humidity: number,
    visibility: number
}
