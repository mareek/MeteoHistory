<script setup lang="ts">
import { ref, onMounted, watchEffect } from "vue";
import { computeDistance, getLocation } from "@/utils/geoUtils"
import _ from "lodash";
import type { FeatureCollection, Station } from "@/data/meteoFranceTypes";
import type { Coordinates } from "@/utils/geoUtils"

const defaultStationId = "07149"; // Orly, near Paris

const props = defineProps<{
    selectedStation: Station | undefined,
    sourceFileUrl: string
}>();

function isInFranceMetropolitaine(station: Station) {
    return 41 < station.Latitude && station.Latitude < 51.1
        && -6 < station.Longitude && station.Longitude < 10;
}

onMounted(async () => {
    const locationPromise = getLocation();

    const response = await fetch(props.sourceFileUrl);
    const featureCollection: FeatureCollection = await response.json();
    const readStations = featureCollection.features.map(f => f.properties);
    readStations.sort((a, b) => a.Nom.localeCompare(b.Nom))
    stations.value = readStations.filter(isInFranceMetropolitaine);

    locationPromise.then(setCoordinates)
        .catch((error) => {
            selectedStationId.value = defaultStationId;
            console.log(`Error fetching coordinaes : ${error.message}`);
        });
});

const stations = ref<Station[]>([]);
const selectedStationId = ref<string | undefined>();

function setCoordinates(coordinates: Coordinates | undefined) {
    if (!coordinates)
        return;
    const nearestStation = _.orderBy(stations.value, s => computeDistance(s, coordinates))[0];
    selectedStationId.value = nearestStation?.ID ?? defaultStationId;
}

const emit = defineEmits(['update:selectedStation']);

watchEffect(() => {
    if (selectedStationId.value && stations.value && stations.value.length) {
        const station = stations.value.find(s => s.ID === selectedStationId.value)
        emit('update:selectedStation', station)
    } else {
        emit('update:selectedStation', null)
    }
});
</script>

<template>
    <select v-model="selectedStationId">
        <option v-for="station in stations" :value="station.ID">{{ station.Nom }}</option>
    </select>
</template>
