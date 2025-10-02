#vamos a ocupar lo siguiente
#1
#python -m venv venv

#2

# pip install --upgrade pip y pip install fastapi uvicorn


# iniciar FastAPI
# python -m uvicorn main:app --reload

# entrar al servidor  http://127.0.0.1:8000/docs

# main.py

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime

app = FastAPI()

# Modelos mínimos
class User(BaseModel):
    id: int
    username: str
    password: str           # texto plano para ejercicio local
    email: Optional[str] = ""
    is_active: bool = True
    last_login: Optional[str] = None   # registro opcional del último login

class Credentials(BaseModel):
    username: str
    password: str

# "Base de datos" quemada en memoria (simple)
USERS: List[User] = [
    User(id=1, username="naruto", password="rasengan123", email="naruto@example.com", is_active=True),
    User(id=2, username="testuser", password="0420", email="test@example.com", is_active=True),
    User(id=3, username="demo", password="007", email="demo@example.com", is_active=True),
    User(id=4, username="siu", password="a1", email="siu@example.com", is_active=True),
]

# Rutas

@app.post("/users")
def create_user(user: User):
    # username único
    if any(u.username == user.username for u in USERS):
        raise HTTPException(status_code=400, detail="Username ya existe")
    user.id = max((u.id for u in USERS), default=0) + 1
    USERS.append(user)
    return user

@app.get("/users")
def list_users():
    return USERS

@app.get("/users/{user_id}")
def get_user(user_id: int):
    for u in USERS:
        if u.id == user_id:
            return u
    raise HTTPException(status_code=404, detail="Usuario no encontrado")

@app.put("/users/{user_id}")
def update_user(user_id: int, payload: User):
    # NOTA: payload incluye password por simplicidad de modelo, pero aquí no lo actualizamos
    for idx, u in enumerate(USERS):
        if u.id == user_id:
            # validar username único si lo cambian
            if payload.username != u.username and any(other.username == payload.username for other in USERS):
                raise HTTPException(status_code=400, detail="Username ya existe")
            # actualizar campos excepto password
            u.username = payload.username
            u.email = payload.email
            u.is_active = payload.is_active
            USERS[idx] = u
            return u
    raise HTTPException(status_code=404, detail="Usuario no encontrado")

@app.delete("/users/{user_id}")
def delete_user(user_id: int):
    for idx, u in enumerate(USERS):
        if u.id == user_id:
            USERS.pop(idx)
            return {"message": "Usuario eliminado"}
    raise HTTPException(status_code=404, detail="Usuario no encontrado")

@app.post("/login")
def login(creds: Credentials):
    for u in USERS:
        if u.username == creds.username and u.password == creds.password:
            # actualizar último login
            u.last_login = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            return {"message": f"Querido darling, tu login fue exitoso, y tú eres... {u.username}! Último login: {u.last_login}"}
    raise HTTPException(status_code=401, detail=f"Querido darling, tu login fue rechazado, {creds.username}")
