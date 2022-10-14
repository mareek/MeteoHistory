<script setup lang="ts">
import { ref, onMounted } from "vue";
import type { FeatureCollection, Station } from "../data/meteoFranceTypes";

const props = defineProps<{
    selectedStationId: string | undefined,
    sourceFileUrl: string
}>();

onMounted(async () => {
    const response = await fetch(props.sourceFileUrl);
    const featureCollection: FeatureCollection = await response.json();
    const readStations = featureCollection.features.map(f => f.properties);
    readStations.sort((a, b) => a.Nom.localeCompare(b.Nom))
    stations.value = readStations;
});

const stations = ref<Station[]>();

</script>

<template>
    <select v-model="selectedStationId">
        <option v-for="station in stations" :value="station.ID">{{station.Nom}}</option>
    </select>
    <span>{{selectedStationId}}</span>
</template>
