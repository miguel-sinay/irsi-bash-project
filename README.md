# Análisis Web

Este script de Bash realiza varias tareas de análisis web, incluyendo la verificación de sitios web con WAF (Web Application Firewall), escaneo de puertos abiertos y envío de URLs a [URLScan.io](https://urlscan.io). El script también obtiene resultados de URLScan.io y guarda los logs de salida y errores en archivos separados.

## Prerrequisitos

1. **Permiso de Ejecución**: Conceder permiso de ejecución sobre el script `analisis_web.sh` con el siguiente comando:
    ```bash
    chmod -v u+x analisis_web.sh
    ```

2. **API Key**: Sustituir el texto 'CONFIDENTIAL' en el archivo `credenciales.dat` por una clave de API que se puede obtener en [URLScan.io](https://urlscan.io).

3. **Sistemas Operativos**: El script está diseñado para funcionar correctamente en sistemas operativos basados en Debian.

4. **Instalación de Dependencias**: Asegúrate de tener instalados los siguientes comandos:
    - `jq`
    - `curl`
    - `wafw00f`
    - `nmap`

   Puedes instalarlos con los siguientes comandos:
    ```bash
    sudo apt-get update
    sudo apt-get install -y jq curl wafw00f nmap
    ```

## Uso

1. **Ejecutar el script**:
    ```bash
    ./analisis_web.sh
    ```

2. **Seguir las instrucciones** en el menú interactivo para realizar las diferentes tareas de análisis.

## Integrantes del Equipo

- Pamella
- José
- Hendry
- Jhon
- Angel
- Miguel

## Archivos de Log

- `STDOUT.log`: Contiene la salida estándar de las operaciones del script.
- `STDERR.log`: Contiene los errores estándar generados durante la ejecución del script.

## Funcionalidades

1. **Mostrar sitios web**: Muestra los sitios web que se van a analizar.
2. **Analizar con WAFW00F**: Analiza los sitios web para detectar la presencia de WAF.
3. **Analizar con Nmap**: Realiza un escaneo de puertos abiertos en los sitios web.
4. **Enviar URLs a URLScan.io**: Envía los sitios web a URLScan.io para su análisis.
5. **Obtener resultados de URLScan.io**: Recupera los resultados del análisis de URLScan.io.
6. **Leer log de errores**: Muestra el contenido del archivo `STDERR.log`.

## Notas

- Asegúrate de tener una conexión a Internet activa para que el script pueda enviar y obtener datos de URLScan.io.
- Ejecuta el script con privilegios de superusuario si es necesario para instalar dependencias.

¡Esperamos que encuentres útil este script para tus análisis web!
