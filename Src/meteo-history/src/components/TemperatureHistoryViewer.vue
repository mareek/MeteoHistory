<script setup lang="ts">
import { computed, watchEffect, ref } from 'vue';
import type { Station } from '@/data/meteoFranceTypes';
import type { temperatureSerie } from '@/data/meteoTypes';
import { downloadSeries } from "@/utils/serieHandler";
import TemperatureChart from "./TemperatureChart.vue";

const props = defineProps<{ selectedStation: Station | undefined }>();

const series = ref<temperatureSerie[]>([])

watchEffect(async () => {
    if (!props.selectedStation)
        return;

    series.value = await downloadSeries(props.selectedStation, new Date());
});

const backgroundSeries = computed(() => series.value.slice(0, -1));
const foregroundSerie = computed(() => series.value.length ? series.value.slice(-1)[0] : undefined);

</script>

<template>
    <TemperatureChart :backgroundTemperatures="backgroundSeries" :foregroundTemperature="foregroundSerie" />
</template>