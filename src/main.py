from fastapi import FastAPI, File, UploadFile, Form
from fastapi.responses import JSONResponse
import subprocess
import tempfile
from pathlib import Path

app = FastAPI()

# Flags por categoria
CATEGORIES = {
    "placa_carro": "-c brg -p gn -j",
    "placa_carro_mercosul": "-c brms -p ms -j",
    "placa_moto": "-c brmt -p gn -j",
    "placa_moto_mercosul": "-c brmtms -p ms -j",
}


@app.post("/ler-placa")
async def ler_placa(
    file: UploadFile = File(...),
    categoria: str = Form(default=None),
):
    # Salva a imagem temporariamente
    with tempfile.TemporaryDirectory() as tmpdir:
        temp_image_path = Path(tmpdir) / file.filename
        with open(temp_image_path, "wb") as f:
            f.write(await file.read())

        categoria = None if categoria not in CATEGORIES else categoria

        # Caso categoria tenha sido enviada
        if categoria:
            if categoria is not None and categoria not in CATEGORIES:
                return JSONResponse(
                    status_code=400, content={"erro": "Categoria inválida"}
                )

            cmd = f"alpr {CATEGORIES[categoria]} {temp_image_path}"
            result = subprocess.run(cmd, shell=True, capture_output=True, text=True)

            if result.returncode != 0:
                return JSONResponse(
                    status_code=500,
                    content={"erro": "Erro ao executar ALPR", "detalhe": result.stderr},
                )

            return {"resultado": result.stdout.strip()}

        # Caso categoria seja nula, testar todas em ordem
        for categoria_teste, flags in CATEGORIES.items():
            cmd = f"alpr {flags} {temp_image_path}"
            result = subprocess.run(cmd, shell=True, capture_output=True, text=True)

            if result.returncode == 0 and result.stdout.strip():
                return {
                    "resultado": result.stdout.strip(),
                }

        return JSONResponse(
            status_code=404,
            content={
                "erro": "Nenhuma leitura válida encontrada com nenhuma categoria."
            },
        )
