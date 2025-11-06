import os
import importador as imp

# Obtener todos los archivos Excel en la carpeta data
files = [f for f in os.listdir(imp.DATA_PATH) if f.endswith(('.xls', '.xlsx')) and not f.startswith('~$')]

# Importar todos los archivos Excel en la carpeta data
for file in files:
    path_excel = os.path.join(imp.DATA_PATH, file)
    imp.importar_excel(path_excel)