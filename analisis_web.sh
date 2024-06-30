#!/bin/bash

# Cargar credenciales
if [ -f "credenciales.dat" ]; then
    source credenciales.dat
else
    echo "Archivo credenciales.dat no encontrado. Por favor, asegúrese de que exista y contenga la API_KEY." | tee -a STDOUT.log
    exit 1
fi

# Declara variable
sitios=("irsi.education" "scanme.nmap.org")
declare -A uuid_por_sitio

# Función para validar comandos necesarios
validar_comandos() {
    comandos=("curl" "jq" "nmap" "wafw00f")
    for cmd in "${comandos[@]}"; do
        if ! command -v $cmd &>/dev/null; then
            read -p "$cmd no está instalado. ¿Desea instalarlo? (s/n): " respuesta
            if [ "$respuesta" = "s" ]; then
                sudo apt-get install -y $cmd >> STDOUT.log 2>> STDERR.log
            else
                echo "Instalación de $cmd cancelada. Saliendo..." | tee -a STDOUT.log
                exit 1
            fi
        else
            echo "$cmd ya está instalado." | tee -a STDOUT.log
        fi
    done
    echo "Todos los comandos requeridos están instalados." | tee -a STDOUT.log
}

# Función para mostrar los sitios web
mostrar_sitios() {
    for sitio in "${sitios[@]}"; do
        echo "Sitio web: $sitio" | tee -a STDOUT.log
    done
}

# Función para analizar con wafw00f
analizar_con_wafw00f() {
    for sitio in "${sitios[@]}"; do
        echo "Analizando $sitio con wafw00f..." | tee -a STDOUT.log
        wafw00f $sitio >> STDOUT.log 2>> STDERR.log
        read -p "Presione Enter para continuar..." | tee -a STDOUT.log
    done
}

# Función para analizar puertos abiertos con nmap
analizar_con_nmap() {
    for sitio in "${sitios[@]}"; do
        echo "Analizando puertos abiertos en $sitio con nmap..." | tee -a STDOUT.log
        nmap -Pn $sitio >> STDOUT.log 2>> STDERR.log
        read -p "Presione Enter para continuar..." | tee -a STDOUT.log
    done
}

# Función para enviar URL a URLScan.io
enviar_a_urlscan() {
    for sitio in "${sitios[@]}"; do
        echo "Enviando $sitio a URLScan.io..." | tee -a STDOUT.log
        response=$(curl -s --request POST --url 'https://urlscan.io/api/v1/scan/' \
        --header "Content-Type: application/json" \
        --header "API-Key: $API_KEY" \
        --data "{\"url\": \"$sitio\", \"customagent\": \"US\"}" >> STDOUT.log 2>> STDERR.log)
        uuid=$(echo $response | jq -r '.uuid')
        if [ "$uuid" != "null" ]; then
            echo "UUID de URLScan.io para $sitio: $uuid" | tee -a STDOUT.log
            uuid_por_sitio["$sitio"]=$uuid
        else
            echo "Error al enviar $sitio a URLScan.io. Respuesta: $response" | tee -a STDOUT.log
        fi
    done
}

# Función para obtener resultados de URLScan.io
obtener_resultados_urlscan() {
    if [ ${#uuid_por_sitio[@]} -eq 0 ]; then
        echo "Para utilizar esta opción, primero debes Enviar URLs a URLScan.io en la OPCIÓN 4." | tee -a STDOUT.log
    else
        for sitio in "${!uuid_por_sitio[@]}"; do
            uuid=${uuid_por_sitio[$sitio]}
            echo "Obteniendo resultados de URLScan.io para $sitio (UUID: $uuid)..." | tee -a STDOUT.log
            while true; do
                response=$(curl -s --request GET --url "https://urlscan.io/api/v1/result/$uuid/" \
                --header "API-Key: $API_KEY" >> STDOUT.log 2>> STDERR.log)
                status=$(echo $response | jq -r '.status')
                if [ "$status" == "404" ]; then
                    echo "La exploración no ha terminado aún. Esperando 10 segundos antes de reintentar..." | tee -a STDOUT.log
                    sleep 10
                else
                    echo "Resultado de URLScan.io para $sitio (UUID: $uuid): $response" | tee -a STDOUT.log
                    break
                fi
            done
        done
    fi
}

# Función para leer el log de errores
leer_log_errores() {
    if [ -f "STDERR.log" ]; then
        cat STDERR.log | tee -a STDOUT.log
    else
        echo "No se encontró el archivo STDERR.log" | tee -a STDOUT.log
    fi
}

# Función para mostrar el menú
mostrar_menu() {
    echo "Seleccione una opción:" | tee -a STDOUT.log
    echo "1) Mostrar sitios web" | tee -a STDOUT.log
    echo "2) Analizar con wafw00f" | tee -a STDOUT.log
    echo "3) Analizar con nmap" | tee -a STDOUT.log
    echo "4) Enviar URLs a URLScan.io" | tee -a STDOUT.log
    echo "5) Obtener resultados de URLScan.io" | tee -a STDOUT.log
    echo "6) Leer log de errores" | tee -a STDOUT.log
    echo "7) Salir" | tee -a STDOUT.log
}

# Ejecutar la validación de comandos al inicio
validar_comandos

# Bucle principal del menú
while true; do
    clear
    mostrar_menu
    read -p "Ingrese una opción: " opcion
    case $opcion in
        1) mostrar_sitios | tee -a STDOUT.log ;;
        2) analizar_con_wafw00f | tee -a STDOUT.log ;;
        3) analizar_con_nmap | tee -a STDOUT.log ;;
        4) enviar_a_urlscan | tee -a STDOUT.log ;;
        5) obtener_resultados_urlscan | tee -a STDOUT.log ;;
        6) leer_log_errores | tee -a STDOUT.log ;;
        7) echo "Saliendo..." | tee -a STDOUT.log; break ;;
        *) echo "Opción no válida." | tee -a STDOUT.log ;;
    esac
    read -p "Presione Enter para regresar al menú..." | tee -a STDOUT.log
done
echo "Script finalizado." | tee -a STDOUT.log
