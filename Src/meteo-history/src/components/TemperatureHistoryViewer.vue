<script setup lang="ts">
import { computed, watchEffect, ref } from 'vue';
import _ from "lodash"
import type { Station } from '@/data/meteoFranceTypes';
import type { temperatureSerie } from '@/data/meteoTypes';
import { downloadSeries } from "@/utils/serieHandler";
import TemperatureChart from "./TemperatureChart.vue";

const props = defineProps<{
    selectedStation: Station | undefined,
    selectedDate: Date | undefined
}>();

const series = ref<temperatureSerie[]>([]);

watchEffect(async () => {
    if (!props.selectedStation)
        return;

    series.value = await downloadSeries(props.selectedStation, props.selectedDate ?? new Date());
});

const seriesLabels = computed(() => _.reverse(series.value.map(s => s.label)))
const foregroundSerieLabel = ref<string>(new Date().getFullYear().toString());

const backgroundSeries = computed(() => series.value.filter(s => s.label !== foregroundSerieLabel.value));
const foregroundSerie = computed(() => series.value.filter(s => s.label === foregroundSerieLabel.value)[0]);

</script>

<template>
    <span>Année : </span>
    <select v-model="foregroundSerieLabel">
        <option v-for="serie in seriesLabels">{{ serie }}</option>
    </select>
    <TemperatureChart :backgroundTemperatures="backgroundSeries" :foregroundTemperature="foregroundSerie" />
</template>