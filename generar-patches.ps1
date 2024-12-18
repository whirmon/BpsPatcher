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

# -------------------- CONFIGURACIÓN DE VARIABLES --------------------
# Nombre del archivo base ROM
$BASE_ROM = "Mario 1 - Super Mario World 1.0 (USA).sfc"

# Directorio donde se encuentran las ROMs modificadas
$ROMSDIR = "_roms"

# Directorio donde se guardarán los parches generados
$PATCHES = "patches"

# Ruta al ejecutable BpsPatcher.jar (ajustar según sea necesario)
$BpsPatcher = Resolve-Path -Path ".\BpsPatcher.jar" -ErrorAction SilentlyContinue

# -------------------- VALIDACIÓN DE BpsPatcher.jar --------------------
if (-Not (Test-Path -Path $BpsPatcher)) {
    Write-Error "Error: No se encontró BpsPatcher.jar en la ruta './BpsPatcher.jar'. Verifique la ubicación del archivo."
    Start-Sleep -Seconds 2  # Espera 2 segundos antes de cerrar
    exit
}

# -------------------- CREAR CARPETA DE PATCHES SI NO EXISTE --------------------
if (-Not (Test-Path -Path $PATCHES)) {
    Write-Output "Directorio '$PATCHES' no encontrado. Creando..."
    New-Item -Path $PATCHES -ItemType Directory
}

# -------------------- VALIDAR ARCHIVO BASE ROM --------------------
if (Test-Path -Path $BASE_ROM) {
    Write-Output "Archivo base ROM '$BASE_ROM' encontrado."

    # Obtener la lista de archivos .sfc en el directorio ROMSDIR
    $romFiles = Get-ChildItem -Path $ROMSDIR -Filter "*.sfc"

    # Validar si existen archivos en la carpeta ROMSDIR
    if ($romFiles.Count -eq 0) {
        Write-Warning "No se encontraron archivos .sfc en '$ROMSDIR'."
        Start-Sleep -Seconds 2  # Espera 2 segundos antes de cerrar
        exit
    }

    # Iterar sobre cada archivo .sfc para generar parches
    foreach ($rom in $romFiles) {
        # Definir el nombre del archivo de salida .bps
        $outputPatch = Join-Path -Path $PATCHES -ChildPath "$($rom.BaseName).bps"

        Write-Output "Generando parche '$outputPatch' desde '$($rom.Name)'..."

        # Ejecutar el JAR para generar el parche
        $command = "java -jar `"$BpsPatcher`" `"$BASE_ROM`" `"$($rom.FullName)`""
        Write-Output "Ejecutando: $command"

        try {
            Invoke-Expression $command
            Write-Output "Parche generado correctamente: $outputPatch"
        }
        catch {
            Write-Warning "Error al generar el parche para '$($rom.Name)'. Detalle: $_"
        }
    }

    Write-Output "Proceso completado. Todos los parches se encuentran en '$PATCHES'."
} 
else {
    # Mensaje de error si no se encuentra el archivo base ROM
    Write-Error ":( No se encontró '$BASE_ROM'. Por favor incluya una versión limpia y renómbrela correctamente."
    Start-Sleep -Seconds 2  # Espera 2 segundos antes de cerrar
    exit
}

# Pausa breve antes de cerrar la ventana
Write-Output "Presione Enter para cerrar el script..."
Read-Host | Out-Null
