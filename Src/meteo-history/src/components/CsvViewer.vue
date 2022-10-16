<script setup lang="ts">
import { computed, ref, watchEffect } from "vue";
import { parseCsv } from "../utils/csvParser";
import type { CsvFile } from "../utils/csvParser";

const props = defineProps<{
    fileUrl: string | null,
    separator: string
}>();

watchEffect(async () => {
    if (!props.fileUrl)
        return;

    const response = await fetch(props.fileUrl);
    if (!response.ok) 
        return;
        
    const content = await response.text();
    csvFile.value = parseCsv(content, props.separator);
});

const csvFile = ref<CsvFile>();

const columns = computed(() => csvFile.value ? csvFile.value.columns : []);
const rows = computed(() => csvFile.value ? csvFile.value.rows : []);

</script>

<template>
    <table>
        <thead>
            <tr>
                <th v-for="column in columns">{{column.name}}</th>
            </tr>
        </thead>
        <tbody>
            <tr v-for="row in rows">
                <td v-for="cell in row.cells">{{cell.value}}</td>
            </tr>
        </tbody>
    </table>
</template>