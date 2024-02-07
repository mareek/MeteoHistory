# Meteo History

Un site pour voir l'historique des température en France depuis 1996

## Instruction de déploiement

* Installer powershell 7.X (voir [cette page](https://learn.microsoft.com/en-us/powershell/scripting/install/community-support))
* Faire un clone de ce repo `git clone https://github.com/mareek/MeteoHistory.git`
* Aller dans le dossier `/Scripts/` et executer la commande `pwsh 'Download meteo data.ps1'`
* Attendre ~20-30mn pour un premier run
* aller dans le dossier `/Src/meteo-history/` et lancer `npm install` puis `npm build`
* Copier le contenu du dossier `/Src/meteo-history/dist/` dans le dossier meteo de votre site web
