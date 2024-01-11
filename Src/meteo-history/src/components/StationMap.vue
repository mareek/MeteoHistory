<script setup lang="ts">
import "leaflet/dist/leaflet.css";
import { LMap, LTileLayer, LMarker, LIcon } from "@vue-leaflet/vue-leaflet";
import { ref } from "vue";
import type { Station } from "@/data/meteoFranceTypes";

const zoom = ref(6);

const props = defineProps<{
    stations: Station[]
}>();
const emit = defineEmits(['updateSelectedStationId']);


</script>
<template>
    <div style="height:700px; width:700px">
        <l-map ref="map" v-model:zoom="zoom" :center="[46.5, 2.5]" :use-global-leaflet="false">
            <l-tile-layer url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png" layer-type="base" name="OpenStreetMap">
            </l-tile-layer>
            <l-marker v-for="station in stations" :lat-lng="[station.Latitude, station.Longitude]"
                @click="() => emit('updateSelectedStationId', station.ID)">
                <l-icon icon-url="/src/assets/img/meteo-france-logo.png" :icon-size="[20, 20]" />
            </l-marker>
        </l-map>
    </div>
</template>