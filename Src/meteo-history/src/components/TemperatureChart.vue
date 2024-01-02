<script setup lang="ts">
import { computed } from 'vue';
import { Line as LineChart } from 'vue-chartjs';
import { Chart as ChartJS, Title, Tooltip, Legend, LineElement, LinearScale, PointElement, CategoryScale } from 'chart.js';
import type { ChartDataset } from 'chart.js';
import type { temperatureSerie } from '@/data/meteoTypes';

ChartJS.register(Title, Tooltip, Legend, LineElement, LinearScale, PointElement, CategoryScale);
const minForegroundColor = 'Blue';
const maxForegroundColor = 'Red';
const minBackgroundColor = 'rgba(0, 25, 255, 0.25)';
const maxBackgroundColor = 'rgba(255, 25, 0, 0.25)';

const props = defineProps<{
    backgroundTemperatures: temperatureSerie[],
    foregroundTemperature: temperatureSerie | undefined
}>();

const labels = computed(() =>
    props.backgroundTemperatures?.length
    && props.backgroundTemperatures[0]
        .dailyTemperatures
        .map(dt => new Date(2000, dt.month - 1, dt.day).toLocaleString('fr-FR', { day: "numeric", month: 'long' })));

function CreateDatasets(serie: temperatureSerie, isForeground: boolean): ChartDataset[] {
    const datasetMin: ChartDataset = {
        label: `${serie.label} Min`,
        borderColor: isForeground ? minForegroundColor : minBackgroundColor,
        borderWidth: isForeground ? 8 : 6,
        pointBorderWidth: 1,
        pointRadius: 5,
        data: serie.dailyTemperatures.map(d => d.min)
    };

    const datasetMax: ChartDataset = {
        label: `${serie.label} Max`,
        borderColor: isForeground ? maxForegroundColor : maxBackgroundColor,
        borderWidth: isForeground ? 8 : 6,
        pointBorderWidth: 1,
        pointRadius: 5,
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
        line: { tension: 0.3 }
    },
    plugins: { legend: { display: false } },
    maintainAspectRatio: false,
    animation: { duration: 0 }
}

</script>

<template>
    <LineChart class="chart" :chart-data="chartData" :chart-options="chartOptions" />
</template>

<style>
.chart {
    width: 95vw;
    height: 50vw;
    background-color: antiquewhite;
    color: black;
}
</style>