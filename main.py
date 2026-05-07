# Library Imports
from fastapi import FastAPI, HTTPException
from fastapi.responses import FileResponse, PlainTextResponse
from fastapi.staticfiles import StaticFiles

# Router Imports
from routers.crud_router import crud_router


app = FastAPI(
    title = "Hamburg Inn Database Project",
    version = "0.136.1"
)

app.include_router(crud_router, prefix="/crud", tags=["Manager"])


@app.get("/")
async def home():
    return FileResponse("./frontend/index.html")


app.mount("/", StaticFiles(directory="./frontend"), name="static")

@app.exception_handler(HTTPException)
async def my_http_exception_handler(request, ex):
    return PlainTextResponse(str(ex.detail), status_code=ex.status_code)