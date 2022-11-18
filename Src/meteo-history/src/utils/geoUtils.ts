interface Coordinates {
    Latitude: number,
    Longitude: number
}

function computeDistance(pointA: Coordinates, pointB: Coordinates): number {
    const toRadians = (deg: number) => deg / 57.29557951;
    const R = 6371; // Radius of the earth

    const latDistance = toRadians(pointB.Latitude - pointA.Latitude);
    const lonDistance = toRadians(pointB.Longitude - pointA.Longitude);
    const a = Math.sin(latDistance / 2) * Math.sin(latDistance / 2)
        + Math.cos(toRadians(pointA.Latitude)) * Math.cos(toRadians(pointB.Latitude))
        * Math.sin(lonDistance / 2) * Math.sin(lonDistance / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return R * c;
}

async function getLocation(): Promise<Coordinates | undefined> {
    const locationPromise = new Promise<GeolocationPosition>((resolve, reject) => 
        navigator.geolocation.getCurrentPosition(resolve, reject, { timeout: 5000 }));
    const result = await locationPromise;
    return {
        Latitude: result.coords.latitude,
        Longitude: result.coords.longitude,
    };
}

export { computeDistance, getLocation }
export type { Coordinates }