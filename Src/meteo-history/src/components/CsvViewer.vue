<script setup lang="ts">
import { computed, ref, onMounted } from "vue";

const props = defineProps<{
    fileUrl: string,
    separator: string
}>()

onMounted(async () => {
    const response = await fetch(props.fileUrl);
    fileContent.value = await response.text();
});

const fileContent = ref<string>();
const fileLines = computed(() => fileContent.value?.split('\n').slice(0, 100));
const columns = computed(() => fileLines.value && fileLines.value[0].split(props.separator));
const rows = computed(() => fileLines.value?.slice(1).map(l => l.split(props.separator)));

</script>

<template>
    <div>
        <table>
            <thead>
                <tr>
                    <th v-for="column in columns">{{column}}</th>
                </tr>
            </thead>
            <tbody>
                <tr v-for="row in rows">
                    <td v-for="val in row">{{val}}</td>
                </tr>
            </tbody>
        </table>
    </div>
</template>