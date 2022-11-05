<script setup lang="ts">
import { ref, computed } from "vue"
import type { Station } from "@/data/meteoFranceTypes"
import WelcomeItem from './WelcomeItem.vue'
import ToolingIcon from './icons/IconTooling.vue'
import CsvViewer from './CsvViewer.vue'
import StationSelector from './StationSelector.vue'
import TemperatureHistoryViewerVue from "./TemperatureHistoryViewer.vue"

const selectedStation = ref<Station>();
const csvFileUrl = computed(() => selectedStation.value 
                                      ? `data/${selectedStation.value.ID}/synop.202001.csv` 
                                      : null);
</script>

<template>

  <StationSelector v-model:selectedStation="selectedStation" sourceFileUrl="data/postesSynop.json" />
  <TemperatureHistoryViewerVue :selected-station="selectedStation"/>
  <!--
    <CsvViewer :fileUrl="csvFileUrl" separator=";" />
  -->
  <WelcomeItem>
    <template #icon>
      <ToolingIcon />
    </template>
    <template #heading>Tooling</template>

    This project is served and bundled with
    <a href="https://vitejs.dev/guide/features.html" target="_blank" rel="noopener">Vite</a>. The
    recommended IDE setup is
    <a href="https://code.visualstudio.com/" target="_blank" rel="noopener">VSCode</a> +
    <a href="https://github.com/johnsoncodehk/volar" target="_blank" rel="noopener">Volar</a>. If
    you need to test your components and web pages, check out
    <a href="https://www.cypress.io/" target="_blank" rel="noopener">Cypress</a> and
    <a href="https://on.cypress.io/component" target="_blank">Cypress Component Testing</a>.

    <br />

    More instructions are available in <code>README.md</code>.
  </WelcomeItem>
</template>
