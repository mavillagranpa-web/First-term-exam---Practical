# Proyecto: API de usuarios - FastAPI (Ejercicio estudiante)

Proyecto simple para la materia donde se creó una API con FastAPI que permite crear, listar, actualizar y eliminar usuarios, y también loguear.

---

## Requisitos

* Python 3.10+


## Preparar entorno y ejecutar

1. Crear y activar entorno virtual:

Windows (PowerShell):

```powershell
python -m venv venv
venv\\Scripts\\Activate.ps1
```

Linux / macOS (bash):

```bash
python -m venv venv
source venv/bin/activate
```

2. Instalar dependencias:

```bash
pip install fastapi uvicorn
```

3. Ejecutar la API:

```bash
python -m uvicorn main:app --reload
```

Abrir `http://127.0.0.1:8000/docs` para ver Swagger UI.

---

## Archivos importantes

* `main.py` — código de la API (usa una lista en memoria llamada `USERS`). Es una base de datos quemada.
* `brute_digits.ps1` — script PowerShell para probar contraseñas (usar solo en entornos de práctica). Luego tendran problemas legales :(.

---

## Usuarios por defecto

En `main.py` hay estos usuarios iniciales si gustas puedes agregar mas y probar, o cambiar las contraseñas y demas.

* naruto / rasengan123
* testuser / 0420
* demo / 007
* siu / a1


---

## Endpoints (rápido)

* `POST /users` — crear usuario (envía username, password, email, is_active). El `id` lo asigna el servidor.
* `GET /users` — listar usuarios
* `GET /users/{id}` — obtener usuario por id
* `PUT /users/{id}` — actualizar (no cambia password en este endpoint)
* `DELETE /users/{id}` — eliminar usuario
* `POST /login` — autenticar (envía {"username":"...","password":"..."})

---

## Uso básico (ejemplos)

Login con curl:

```bash
curl -X POST http://127.0.0.1:8000/login -H "Content-Type: application/json" -d '{"username":"siu","password":"a1"}'
```

Crear usuario con PowerShell:

```powershell
Invoke-RestMethod -Uri "http://127.0.0.1:8000/users" -Method Post -Body (ConvertTo-Json @{ id=0; username='nuevo'; password='123'; email='nuevo@example.com'; is_active=$true }) -ContentType "application/json"
```

---

## Advertencia

El script `brute_digits.ps1` puede generar muchas solicitudes y sirve solo para pruebas en tu entorno local. No lo uses contra sistemas reales sin permiso.

Seamos eticos muchachos :).

"Una vez que cuestionas tus propias creencias, estás acabado"  Naruto Uzumaki







Si quieres que lo deje aún más corto o que añada instrucciones para Windows/macOS más explícitas, dime y lo ajusto.

