<script setup lang="ts">
import { ref } from "vue"
import type { Station } from "@/data/meteoFranceTypes"
import StationSelector from './StationSelector.vue'
import TemperatureHistoryViewerVue from "./TemperatureHistoryViewer.vue"

const selectedStation = ref<Station>();
</script>

<template>
  <StationSelector v-model:selectedStation="selectedStation" sourceFileUrl="data/postesSynop.json" />
  <TemperatureHistoryViewerVue :selected-station="selectedStation" />
</template>

