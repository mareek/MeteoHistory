<script setup lang="ts">
import { computed } from 'vue';
import { Line as LineChart } from 'vue-chartjs';
import { Chart as ChartJS, Title, Tooltip, Legend, LineElement, LinearScale, PointElement, CategoryScale } from 'chart.js';
import type { temperatureSerie } from '@/data/meteoTypes';

ChartJS.register(Title, Tooltip, Legend, LineElement, LinearScale, PointElement, CategoryScale);

const props = defineProps<{
    backgroundTemperatures: temperatureSerie[],
    foregroundTemperature: temperatureSerie | undefined
}>();

const labels = computed(() =>
    props.backgroundTemperatures?.length
    && props.backgroundTemperatures[0]
        .dailyTemperatures
        .map(dt => `${dt.day}-${dt.month}`));

function CreateDatasets(serie: temperatureSerie, isForeground: boolean) {
    const datasetMin = {
        label: `${serie.label} Min`,
        borderColor: isForeground ? 'Blue' : 'Aquamarine',
        data: serie.dailyTemperatures.map(d => d.min)
    };

    const datasetMax = {
        label: `${serie.label} Max`,
        borderColor: isForeground ? 'Red' : 'Bisque',
        data: serie.dailyTemperatures.map(d => d.max)
    };

    return [datasetMin, datasetMax];
}

const datasets = computed(() => {
    const backgroundDatasets = props.backgroundTemperatures.flatMap(s => CreateDatasets(s, false));
    if (props.foregroundTemperature) {
        return CreateDatasets(props.foregroundTemperature, true).concat(backgroundDatasets);
    } else {
        return backgroundDatasets;
    }
});

const chartData = computed((): any => ({
    labels: labels.value,
    datasets: datasets.value
}));

const chartOptions: any = {
    elements: {
        line: { tension: 0.3 },
        point: { pointRadius: 0 }
    },
}

</script>

<template>
    <LineChart :chart-data="chartData" :chart-options="chartOptions" />
</template>