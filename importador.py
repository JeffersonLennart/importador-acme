import os
from dotenv import load_dotenv
import psycopg2
import pandas as pd

# --- CONFIGURACIÓN BASE DE DATOS ---
load_dotenv()
DB_CONFIG = {
    "host": os.getenv("DB_HOST"),
    "port": os.getenv("DB_PORT"),
    "database": os.getenv("DB_NAME"),
    "user": os.getenv("DB_USER"),
    "password": os.getenv("DB_PASSWORD")
}

# --- RUTA ABSOLUTA DEL ARCHIVO ---
BASE_DIR = os.path.dirname(os.path.abspath(__file__))

# --- RUTA DE LA DATA ---
DATA_PATH = os.path.join(BASE_DIR, "data")

# --- RUTA DE LOS ERRORES ---
ERROR_PATH = os.path.join(BASE_DIR, "error")

# --- MAPEO DE PROCEDIMIENTOS Y COLUMNAS ---
SHEET_CONFIG = {
    "VENDEDORES": {
        "columns": ("VENDEDOR", "TERRITORIO"),
        "procedure": "CALL prc_vendedores_importar(%s, %s)"
    },
    "CLIENTES": {
        "columns": ("CLIENTE", "SEGMENTO"),
        "procedure": "CALL prc_clientes_importar(%s, %s)"
    },
    "LOCALES": {
        "columns": ("LOCAL", "CLIENTE", "TERRITORIO"),
        "procedure": "CALL prc_locales_importar(%s, %s, %s)"
    },
    "PRODUCTO": {
        "columns": ("PRODUCTO", "CATEGORIA", "MARCA", "COMERCIALIZADOR"),
        "procedure": "CALL prc_productos_importar(%s, %s, %s, %s)"
    },
    "VENTAS": {
        "columns": ("FECHA", "PRODUCTO", "MARCA", "CLIENTE", "LOCAL", "PRECIOUSD", "CANTIDAD", "MONTOUSD"),
        "procedure": "CALL prc_ventas_importar(%s, %s, %s, %s, %s, %s, %s, %s)"
    }
}

# --- PREPROCESAMIENTO DE UN DATAFRAME ---
def preprocesamiento_dataframe(df: pd.DataFrame):     
    # Eliminar duplicados
    df.drop_duplicates(inplace=True)
    # Poner en mayúscula el nombre de las columnas
    df.columns = df.columns.str.upper()
    # Quitar caracteres especiales a las columnas
    df.columns = df.columns.str.replace("(", "").str.replace(")", "").str.replace(" ", "")    
    # Preprocesamiento a las columnas de tipos texto
    columnas_texto = df.select_dtypes(include=['object']).columns    
    for col in columnas_texto:
        df[col] = df[col].astype(str).str.strip().str.title()                
    return df

# --- IMPORTAR DATAFRAME ASOCIADO A UNA HOJA DEL EXCEL ---
def importar_dataframe(sheet: str, df: pd.DataFrame):
    # Preprocesamiento al dataframe
    df = preprocesamiento_dataframe(df)    
    # Crea la carpeta de errores, si es necesario
    os.makedirs(ERROR_PATH, exist_ok=True)

    config = SHEET_CONFIG.get(sheet)
    # Verifica si la hoja tiene el formato correcto según el nombre de las columnas        
    if not set(df.columns) == set(config["columns"]):
        path = os.path.join(ERROR_PATH, f"{sheet}_Error_Formato.xlsx")
        df.to_excel(path, sheet_name=sheet, index=False)
        print(f"Error de formato al importar '{sheet}'")
        return

    conexion = None
    try:
        conexion = psycopg2.connect(**DB_CONFIG)
        with conexion.cursor() as cursor:
            for row in df.itertuples(index=False):
                cursor.execute(config["procedure"], tuple(getattr(row, col) for col in config["columns"]))
            conexion.commit()
            print(f"Importación de '{sheet}' exitosa.")

    except Exception as e:
        print(f"Error al importar '{sheet}': {e}")
        if conexion:
            conexion.rollback()
        path = os.path.join(ERROR_PATH, f"{sheet}_Error_Importacion_Total.xlsx")
        df.to_excel(path, sheet_name=sheet, index=False)

    finally:
        if conexion:
            conexion.close()

# --- ORDENAMIENTO SEGUN PRIORIDAD DE TABLAS ---
def ordenamiento_tablas(valor1 :str) -> int:    
    prioridades = {
        'VENDEDORES' : 1, # Alta (se importa primero)
        'CLIENTES' : 2,
        'LOCALES' : 3,
        'PRODUCTO' : 3,
        'VENTAS' : 4 # Baja (se importa al final)
    }
    return prioridades.get(valor1)

# --- IMPORTAR UN EXCEL CON LAS TABLAS EN CADA HOJA ---
def importar_excel(path):
        
    data = pd.read_excel(path, sheet_name=None)

    # Convertir claves (nombre de la hoja) a mayusculas
    data = {k.upper(): v for k, v in data.items()}

    sheets = [x for x in data.keys() if x in SHEET_CONFIG.keys()]

    sheets.sort(key=ordenamiento_tablas)

    # Importar cada hoja del excel como dataframe
    for sheet in sheets:
        importar_dataframe(sheet, data.get(sheet))            