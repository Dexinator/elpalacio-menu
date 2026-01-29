#!/bin/bash

# Hook que actualiza el historial en Obsidian después de commits del menú
# No usa jq, solo herramientas básicas de bash

# Leer input del hook desde stdin
input=$(cat)

# Solo procesar si el comando contiene "git commit" y "menu"
if [[ ! "$input" =~ \"command\":.*git\ commit ]] || [[ ! "$input" =~ menu ]]; then
  exit 0
fi

# Archivo de Obsidian
obsidian_file="/mnt/c/Users/Jorge/Documents/Obsidian/Badi's Life/JorgeTrabaja/Palacio/Actualización Semanal de Menú.md"

# Verificar que el archivo existe
if [[ ! -f "$obsidian_file" ]]; then
  exit 0
fi

# Obtener fecha
fecha=$(date "+%Y-%m-%d")

# Extraer cambios del input (buscar patrones como "Recomendación: X")
cambios=$(echo "$input" | grep -oE '(Recomendación|Carta|Especial|temporada|Torito|Célebres):[^,"\\]+' | tr '\n' ', ' | sed 's/, $//')

# Si no encontró cambios específicos, usar mensaje genérico
if [[ -z "$cambios" ]]; then
  cambios="Actualización de menú"
fi

# Crear la nueva línea del historial
nueva_linea="| $fecha | $cambios |"

# Verificar si ya existe una entrada para hoy (evitar duplicados)
if grep -q "| $fecha |" "$obsidian_file"; then
  exit 0
fi

# Insertar después de la línea de encabezado del historial
sed -i "/|-------|---------|/a\\$nueva_linea" "$obsidian_file"

exit 0
