#!/bin/bash
## Crear carpeta desktop y respaldo 
if [ ${LANG:0:2} == "en" ]; then
	path=~/Desktop/BACKUP
elif [ ${LANG:0:2} == "es"]; then
	path =~/Escritorio/RESPALDO
fi
mkdir -p $path

## Copiar archivos con las extensiones dadas a la carpeta respaldo
find ~ -iname "*.c" -or -iname "*.c++" -or -iname "*.cpp" -or -iname "*.docx" -or -iname "*.xlsx" -or -iname "*.pptx" -or -iname "*.pdf" -or -iname "*.sh" -not -iname  $(basename $0) | xargs -i cp {} $path

## Comprimir carpeta respaldo
tar -cvzf ~/$(date +%d-%m-%Y).tar.gz $path

## Borrar carpeta respaldo
rm -r $path

## Eliminar archivos con las extensiones dadas a la carpeta respaldo
find ~ -iname "*.c" -or -iname "*.c++" -or -iname "*.cpp" -or -iname "*.docx" -or -iname "*.xlsx" -or -iname "*.pptx" -or -iname "*.pdf" -or -iname "*.sh" -not -iname $(basename $0) | xargs -i rm {}

