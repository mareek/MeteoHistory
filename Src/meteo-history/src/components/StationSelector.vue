<script setup lang="ts">
import { ref, onMounted, watchEffect } from "vue";
import { computeDistance, getLocation } from "@/utils/geoUtils"
import _ from "lodash";
import type { FeatureCollection, Station } from "@/data/meteoFranceTypes";

const stationIdStorageKey = "meteo-history-selected-station-id";

const stations = ref<Station[]>([]);
const selectedStationId = ref<string | undefined>();
const showMap = ref<boolean>(false);

const props = defineProps<{
    selectedStation: Station | undefined,
    sourceFileUrl: string
}>();

function isInFranceMetropolitaine(station: Station) {
    return 41 < station.Latitude && station.Latitude < 51.1
        && -6 < station.Longitude && station.Longitude < 10;
}

onMounted(async () => {
    const response = await fetch(props.sourceFileUrl);
    const featureCollection: FeatureCollection = await response.json();
    const readStations = featureCollection.features.map(f => f.properties);
    readStations.sort((a, b) => a.Nom.localeCompare(b.Nom))
    stations.value = readStations.filter(isInFranceMetropolitaine);

    const storedStationId = localStorage.getItem(stationIdStorageKey);
    if (storedStationId) {
        selectedStationId.value = storedStationId;
    } else {
        const defaultStationId = "07149"; // Orly, near Paris
        await SetStationByLocation(defaultStationId);
    }
});

async function SetStationByLocation(defaultStationId: string | undefined = undefined) {
    try {
        const coordinates = await getLocation();
        if (!coordinates)
            return;
        const nearestStation = _.orderBy(stations.value, s => computeDistance(s, coordinates))[0];
        if (nearestStation) {
            selectedStationId.value = nearestStation.ID;
        }
    } catch (error: any) {
        console.log(`Error fetching coordinaes : ${error.message}`);
    }

    if (defaultStationId && !selectedStationId.value) {
        selectedStationId.value = defaultStationId;
    }
}

function getUserFriendlyName(station: Station) {
    switch (station.Nom) {
        case "ORLY":
            return "Paris - Orly";
        case "ALENCON":
            return "Alençon";
        case "CLERMONT-FD":
            return "Clermont-Ferrand";
        case "MONT-DE-MARSAN":
            return "Mont-de-Marsan";
        default:
            return station.Nom.split(' ').map(s => s.split('-').map(_.capitalize).join(' - ')).join(' ');
    }
}

const emit = defineEmits(['update:selectedStation']);

watchEffect(() => {
    if (selectedStationId.value && stations.value && stations.value.length) {
        const station = stations.value.find(s => s.ID === selectedStationId.value);
        localStorage.setItem(stationIdStorageKey, selectedStationId.value);
        emit('update:selectedStation', station)
    } else {
        emit('update:selectedStation', null)
    }
});
</script>

<template>
    <div class="flex-horizontal-stack-panel">
        <span>Station : </span>
        <select v-model="selectedStationId">
            <option v-for="station in stations" :value="station.ID">{{ getUserFriendlyName(station) }}</option>
        </select>
        <button @click="async () => await SetStationByLocation()" title="Sélectionner la station météo la plus proche">
            <img src="/src/assets/img/position.png" />
        </button>
        <button @click="() => showMap = !showMap" title="Selectionner la sation météo sur une carte">
            <img src="/src/assets/img/map.png" />
        </button>
    </div>
    <Transition name="fade">
        <img src="/src/assets/img/map.png" v-if="showMap" />
    </Transition>
</template>

<style scoped>
.flex-horizontal-stack-panel {
    display: flex;
    align-items: center;
}

.flex-horizontal-stack-panel>* {
    margin-right: 0.5em;
}

button {
    display: flex;
    align-items: center;
    justify-content: center;
}

button>img {
    height: 1em;
    width: 1em;
}

.fade-enter-active,
.fade-leave-active {
  transition: all 0.5s ease;
}

.fade-enter-from,
.fade-leave-to {
    opacity: 0;
}
</style>
