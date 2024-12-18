<#
Licencia GNU General Public License (GPL) v3.0

Este programa es software libre: puede redistribuirlo y/o modificarlo 
bajo los términos de la Licencia Pública General de GNU publicada 
por la Free Software Foundation, ya sea la versión 3 de la Licencia 
o (a su elección) cualquier versión posterior.

Este programa se distribuye con la esperanza de que sea útil, pero 
SIN NINGUNA GARANTÍA; incluso sin la garantía implícita de 
COMERCIABILIDAD o IDONEIDAD PARA UN PROPÓSITO PARTICULAR. Consulte la 
Licencia Pública General de GNU para más detalles.

Puede consultar la Licencia Pública General de GNU en:
https://www.gnu.org/licenses/gpl-3.0.html
#>

# Configuración de PowerShell para detener el script en caso de errores
$ErrorActionPreference = "Stop"

# Mostrar mensaje de inicio del script
Write-Output "Iniciando script..."

# ------------------ VARIABLES DE CONFIGURACIÓN ------------------
# Nombre del archivo base ROM que se necesita para aplicar los parches
$BASE_ROM = "Mario 1 - Super Mario World 1.0 (USA).sfc"

# Nombre del directorio donde se guardarán las ROMs parchadas
$ROMSDIR = "_roms"

# Nombre del directorio donde se encuentran los archivos de parches (.bps)
$PATCHES = "patches"

# ------------------ RUTA AL EJECUTABLE BpsPatcher.jar ------------------
# Resolve-Path intenta convertir la ruta relativa en una ruta absoluta
$BpsPatcher = Resolve-Path -Path ".\BpsPatcher.jar" -ErrorAction SilentlyContinue

# Verificar si BpsPatcher.jar existe, de lo contrario, detener el script
if (-Not $BpsPatcher) {
    Write-Error "No se encontró BpsPatcher.jar en la ruta especificada (.\BpsPatcher.jar). Verifique la ubicación del archivo."
    exit
}

# ------------------ VERIFICAR EL DIRECTORIO DE SALIDA ------------------
# Si no existe el directorio "_roms", se crea
if (-Not (Test-Path -Path "$ROMSDIR")) {
    Write-Output "Directorio '$ROMSDIR' no encontrado, creando..."
    New-Item -Path "$ROMSDIR" -ItemType Directory
}

# ------------------ VERIFICAR EL ARCHIVO BASE ROM ------------------
# Comprobar si el archivo base ROM existe
if (Test-Path -Path "$BASE_ROM") {
    # Obtener la lista de archivos .bps en el directorio de parches
    $patchFiles = Get-ChildItem -Path "$PATCHES" -Filter "*.bps"

    # Iterar sobre cada archivo de parche encontrado
    foreach ($patch in $patchFiles) {
        # Definir la ruta del archivo de salida (ROM parchada)
        $outputFile = Join-Path -Path $ROMSDIR -ChildPath "$($patch.BaseName).sfc"

        # Mostrar mensaje del parche en proceso
        Write-Output "Aplicando parche $($patch.Name)..."
        
        # Ejecutar el JAR para aplicar el parche
        $command = "java -jar `"$BpsPatcher`" `"$BASE_ROM`" `"$($patch.FullName)`""
        Write-Output "Ejecutando: $command"

        # Invocar el comando y manejar errores si ocurren
        try {
            Invoke-Expression $command
            Write-Output "Parche aplicado correctamente: $outputFile"
        }
        catch {
            Write-Error "Error al aplicar el parche: $($patch.Name). Detalle: $_"
        }
    }
    
    # Mostrar mensaje de finalización y cerrar el script
    Write-Output "Proceso completado. Cerrando el script..."
    Start-Sleep -Seconds 2  # Espera 2 segundos antes de cerrar
    exit
}
else {
    # Si no se encuentra el archivo base ROM, mostrar un mensaje de error
    Write-Output ":-( No se encontró '$BASE_ROM'. Por favor incluya una versión limpia y renómbrela correctamente."
    Start-Sleep -Seconds 2  # Espera 2 segundos antes de cerrar
    exit
}
