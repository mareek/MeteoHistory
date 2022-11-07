<script setup lang="ts">
import { computed, ref } from "vue"
import type { Station } from "@/data/meteoFranceTypes"
import StationSelector from './StationSelector.vue'
import TemperatureHistoryViewerVue from "./TemperatureHistoryViewer.vue"

const selectedStation = ref<Station>();

const selectedMonth = ref<number>(new Date().getMonth());
const selectedDate = computed(() => new Date(new Date().getFullYear(), selectedMonth.value, 1));
</script>

<template>
  <span>
    <StationSelector v-model:selectedStation="selectedStation" sourceFileUrl="data/postesSynop.json" />
    <select v-model="selectedMonth">
      <option v-for="month in [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]" :value="month">
        {{ new Date(2000, month, 1).toLocaleString('default', { month: 'long' }) }}
      </option>
    </select>
  </span>
  <TemperatureHistoryViewerVue :selected-station="selectedStation" :selected-date="selectedDate" />
</template>

