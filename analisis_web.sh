#!/bin/bash
# Cargar credenciales
if [ -f "credenciales.dat" ]; then
    source credenciales.dat
else
    echo "Archivo credenciales.dat no encontrado. Por favor, asegúrese de que exista y contenga la API_KEY."
    exit 1
fi

# Declara variable
sitios=("irsi.education" "testphp.vulnweb.com" "scanme.nmap.org")
declare -A uuid_por_sitio

# Función para validar comandos necesarios
validar_comandos() {
    comandos=("curl" "jq" "nmap" "wafw00f")
    for cmd in "${comandos[@]}"; do
        if ! command -v $cmd &>/dev/null; then
            read -p "$cmd no está instalado. ¿Desea instalarlo? (s/n): " respuesta
            if [ "$respuesta" = "s" ]; then
               sudo apt-get install -y $cmd
            else
                echo "Instalación de $cmd cancelada. Saliendo..."
                exit 1
            fi
        else
            echo "$cmd ya está instalado."
        fi
    done
     echo "Todos los comandos requeridos estan instalados."
} 
 
# Función para mostrar los sitios web
mostrar_sitios() {
    for sitio in "${sitios[@]}"; do
        echo "Sitio web: $sitio"
    done
}

# Función para analizar con wafw00f
analizar_con_wafw00f() {
    for sitio in "${sitios[@]}"; do
        echo "Analizando $sitio con wafw00f..."
        wafw00f $sitio
        read -p "Presione Enter para continuar..."
    done
} 2>> STDERR.log | tee -a STDOUT.log

# Función para analizar puertos abiertos con nmap
analizar_con_nmap() {
    for sitio in "${sitios[@]}"; do
        read -p "Presione Enter para continuar..."
        echo "Analizando puertos abiertos en $sitio con nmap..."
        nmap -Pn $sitio       
   done
} 2>> STDERR.log | tee -a STDOUT.log

# Función para enviar URL a URLScan.io
enviar_a_urlscan() {
    for sitio in "${sitios[@]}"; do
        echo "Enviando $sitio a URLScan.io..."
        response=$(curl -s --request POST --url 'https://urlscan.io/api/v1/scan/' \
        --header "Content-Type: application/json" \
        --header "API-Key: $API_KEY" \
        --data "{\"url\": \"$sitio\", \"customagent\": \"US\"}" )
        uuid=$(echo $response | jq -r '.uuid')
        if [ "$uuid" != "null" ]; then
           echo "UUID de URLScan.io para $sitio: $uuid"
           uuid_por_sitio["$sitio"]=$uuid
        else
            echo "Error al enviar $sitio a URLScan.io. Respuesta: $response"
        fi        
    done
} 2>> STDERR.log | tee -a STDOUT.log

# Función para obtener resultados de URLScan.io
obtener_resultados_urlscan() {
    if [ ${#uuid_por_sitio[@]} -eq 0 ]; then
        echo "Para utilizar esta opción, primero debes Enviar URLs a URLScan.io en la OPCIÓN 4."
    else
        for sitio in "${!uuid_por_sitio[@]}"; do
            uuid=${uuid_por_sitio[$sitio]}
            echo "Obteniendo resultados de URLScan.io para $sitio (UUID: $uuid)..."
	    while true; do
            response=$(curl -s --request GET --url "https://urlscan.io/api/v1/result/$uuid/" \
            --header "API-Key: $API_KEY" 2>> STDERR.log | tee -a STDOUT.log )
			status=$(echo $response | jq -r ' .status')
			if [ "$status" == "404" ]; then
				echo "La exploracion no ha terminado aun. Esperando 10 segundos antes de reintentar..."
			sleep 10
		else	
            		echo "Resultado de URLScan.io para $sitio (UUID: $uuid): $response"
			break
		fi
	done
     done
  fi
} 2>> STDERR.log | tee -a STDOUT.log

# Función para leer el log de errores
leer_log_errores() {
    if [ -f "STDERR.log" ]; then
       cat STDERR.log
    else
        echo "No se encontró el archivo STDERR.log"
    fi
} 

# Función para mostrar el menú
mostrar_menu() {
    echo "Seleccione una opción:"
    echo "1) Mostrar sitios web"
    echo "2) Analizar con wafw00f"
    echo "3) Analizar con nmap"
    echo "4) Enviar URLs a URLScan.io"
    echo "5) Obtener resultados de URLScan.io"
    echo "6) Leer log de errores"
    echo "7) Salir"
} 

# Ejecutar la validación de comandos al inicio  
validar_comandos

# Bucle principal del menú
while true; do
    clear
    mostrar_menu
    read -p "Ingrese una opción: " opcion
    case $opcion in
         1) mostrar_sitios ;;
         2) analizar_con_wafw00f ;;
         3) analizar_con_nmap ;;
         4) enviar_a_urlscan ;;
         5) obtener_resultados_urlscan ;;
         6) leer_log_errores ;;
         7) echo "Saliendo..."; break ;;
         *) echo "Opción no válida." ;;
     esac
     read -p "Presione Enter para regresar al menú..."	 
done
echo "Script finalizado."
