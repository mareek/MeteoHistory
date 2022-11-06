<script setup lang="ts">
import { ref, onMounted, watchEffect } from "vue";
import type { FeatureCollection, Station } from "@/data/meteoFranceTypes";

const props = defineProps<{
    selectedStation: Station | undefined,
    sourceFileUrl: string
}>();

function isInFranceMetropolitaine(station: Station) {
    return 41 < station.Latitude && station.Latitude < 51.1
        && -6 < station.Longitude && station.Longitude < 10
}

onMounted(async () => {
    const response = await fetch(props.sourceFileUrl);
    const featureCollection: FeatureCollection = await response.json();
    const readStations = featureCollection.features.map(f => f.properties);
    readStations.sort((a, b) => a.Nom.localeCompare(b.Nom))
    stations.value = readStations.filter(isInFranceMetropolitaine);
});

const stations = ref<Station[]>([]);
const selectedStationId = ref<string>();

const emit = defineEmits(['update:selectedStation'])

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
