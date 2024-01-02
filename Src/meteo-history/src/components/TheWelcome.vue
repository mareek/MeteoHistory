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
  <div>
    <StationSelector v-model:selectedStation="selectedStation" sourceFileUrl="data/postesSynop.json" />
  </div>
  <div>
    <span>Mois : </span>
    <select v-model="selectedMonth">
      <option v-for="month in Array(12).fill(0).map((_, i) => i)" :value="month">
        {{ new Date(2000, month, 1).toLocaleString('fr-FR', { month: 'long' }) }}
      </option>
    </select>
  </div>
  <TemperatureHistoryViewerVue :selected-station="selectedStation" :selected-date="selectedDate" />
</template>

