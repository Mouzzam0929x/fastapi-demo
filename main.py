from fastapi import FastAPI

app = FastAPI(title="Hello World API", version="1.0.0")

@app.get("/")
async def root():
    return {"message": "Hello World 123"}

@app.get("/hello/{name}")
async def say_hello(name: str):
    return {"message": f"Hello {name}"}

@app.get("/health")
async def health_check():
    return {"status": "healthy"}