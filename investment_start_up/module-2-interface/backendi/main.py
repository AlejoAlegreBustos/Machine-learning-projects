from fastapi import FastAPI, HTTPException
from fastapi.responses import FileResponse
from pydantic import BaseModel
import xgboost as xgb
import numpy as np
import os
import uuid
import time # Para generar nombres de archivo basados en timestamp
from datetime import datetime
from fastapi.middleware.cors import CORSMiddleware
# --- LIBRERÍAS DE CONEXIÓN ---
from supabase import create_client, Client # Necesitas 'pip install supabase'
# ------------------------------

# ReportLab (PDF)
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Image
from reportlab.lib.styles import getSampleStyleSheet
from reportlab.lib.pagesizes import letter
from reportlab.lib.units import inch

# Matplotlib para gráficos
import matplotlib.pyplot as plt
from io import BytesIO

# -----------------------------------------------------------
# CONFIGURACIÓN INICIAL Y CLIENTE SUPABASE
# -----------------------------------------------------------
app = FastAPI()
REPORTS_DIR = "reports"
os.makedirs(REPORTS_DIR, exist_ok=True)

# *** IMPORTANTE: REEMPLAZA ESTAS CLAVES CON TUS CREDENCIALES REALES ***
SUPABASE_URL = "https://vhhusfbogsjknjsahfyy.supabase.co" 
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZoaHVzZmJvZ3Nqa25qc2FoZnl5Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2MjIwMDU0NiwiZXhwIjoyMDc3Nzc2NTQ2fQ.9my-umoYH7-FW86nTzjYHggjQ9HuEWuGZxu5nJxf3vk" 

# -----------------------------------------------------------
# 2. CONFIGURACIÓN DEL MIDDLEWARE DE CORS
# -----------------------------------------------------------
# La lista de orígenes DEBE incluir tu URL de Render (producción) y tus puertos de desarrollo (local)
origins = [
    # Producción (Tu URL de Render, si aplica)
    "https://invest-app-72ob.onrender.com",
    # Desarrollo Local (Flutter Web/Edge)
    "http://localhost:62898",  # Asegúrate de usar el puerto correcto (62898 es el que aparece en tu log)
    "http://127.0.0.1:62898", # Espejo del anterior
    "http://localhost:5000", # Puertos comunes si usas un proxy o frontend diferente
    "http://127.0.0.1:5000",
    "*", # Permite CUALQUIER origen (Solo para desarrollo rápido, usar el puerto específico es mejor)
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,     # Lista de orígenes permitidos
    allow_credentials=True,    # Permitir cookies y encabezados de autorización
    allow_methods=["*"],       # Permitir todos los métodos (POST, GET, OPTIONS, etc.)
    allow_headers=["*"],       # Permitir todos los encabezados
)
try:
    supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)
except Exception as e:
    print(f"Error initializing Supabase client: {e}")
    # Esto puede hacer que la app falle si las credenciales son incorrectas

# Cargar modelo
model = xgb.XGBClassifier()
current_dir = os.path.dirname(os.path.abspath(__file__))
model_path = os.path.join(current_dir, "investment-pred.json")
model.load_model(model_path)

EXPECTED_FEATURES = 29

# -----------------------------------------------------------
# Esquemas
# -----------------------------------------------------------

class PredictionInput(BaseModel):
    # ¡NUEVO CAMPO! Requerido por Flutter y para el registro de Supabase
    user_id: str 
    features: list[float]
    title: str = "New Startup Prediction" # Usado para el título en el reporte
    startup_name: str | None = None  # Nombre/ID de la startup para la tabla reports

# -----------------------------------------------------------
# Funciones auxiliares (Sin cambios en esta sección)
# -----------------------------------------------------------

def exponential_projection(current_value: float, growth_rate: float, years: int = 1):
    """Simple deterministic projection (not used directly in the PDF)."""
    return current_value * np.exp(growth_rate * years)

def estimate_growth_rate(funding_amount: float, revenue: float, employees: int) -> float:
    """Heuristic estimate of annual growth rate.

    - Base rate depends on funding round size (funding_amount).
    - Adjusted by current revenue level and team size.
    """
    # Base component by round size
    if funding_amount > 100_000_000:
        base = 0.18
    elif funding_amount > 10_000_000:
        base = 0.12
    else:
        base = 0.06

    # Size adjustment by current revenue (large companies tend to grow slower in % terms)
    if revenue > 100_000_000:
        size_factor = 0.8
    elif revenue > 10_000_000:
        size_factor = 0.9
    else:
        size_factor = 1.0

    # Light adjustment by team size (very small teams can scale faster)
    if employees < 50:
        team_factor = 1.1
    elif employees < 200:
        team_factor = 1.0
    else:
        team_factor = 0.9

    return base * size_factor * team_factor

def simulate_and_plot(current_value: float, growth_rate: float, years: int = 1, n_sim: int = 1000, sigma: float = 0.2):
    """Simulate future values and generate a histogram image in memory (BytesIO).

    Uses a simple lognormal model and scales growth by the number of years.
    """
    if current_value <= 0:
        current_value = 1.0  # avoid log(0)

    simulated = np.random.lognormal(
        mean=np.log(current_value) + growth_rate * years,
        sigma=sigma,
        size=n_sim,
    )
    mean_val = np.mean(simulated)
    p5 = np.percentile(simulated, 5)
    p95 = np.percentile(simulated, 95)

    fig, ax = plt.subplots(figsize=(4, 2.5))
    ax.hist(simulated, bins=30, color='lightblue', edgecolor='black')
    ax.axvline(mean_val, color='red', linestyle='--', label='Mean')
    ax.axvline(p5, color='green', linestyle='--', label='5th percentile')
    ax.axvline(p95, color='orange', linestyle='--', label='95th percentile')
    ax.set_title(f"Projected distribution ({years} year(s))")
    ax.set_xlabel("USD")
    ax.set_ylabel("Frequency")
    ax.legend(fontsize=6)

    img_buffer = BytesIO()
    plt.tight_layout()
    plt.savefig(img_buffer, format='PNG')
    plt.close(fig)
    img_buffer.seek(0)

    return mean_val, p5, p95, img_buffer

def create_pdf_report(
    prediction: int,
    confidence: float,
    revenue: float,
    valuation: float,
    funding_amount: float,
    founded_year: int,
    employees: int
) -> str:
    """Genera un PDF con la predicción del modelo, revenue y valuación con gráficos."""
    
    # El nombre del archivo ahora se genera en /predict (con user_id y timestamp)
    # y solo se utiliza aquí el timestamp para el nombre temporal
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S_%f")
    filename = f"temp_report_{timestamp}.pdf"
    filepath = os.path.join(REPORTS_DIR, filename)

    # ... (código de ReportLab para generar el PDF) ...
    styles = getSampleStyleSheet()
    story = []

    # Growth rate (now adjusted by funding amount, current revenue and team size)
    growth_rate = estimate_growth_rate(funding_amount, revenue, employees)

    # 1-year simulation (different volatility for revenue and valuation)
    revenue_mean_1, revenue_p5_1, revenue_p95_1, revenue_img = simulate_and_plot(
        revenue,
        growth_rate,
        years=1,
        sigma=0.15,
    )
    valuation_mean_1, valuation_p5_1, valuation_p95_1, valuation_img = simulate_and_plot(
        valuation,
        growth_rate,
        years=1,
        sigma=0.25,
    )

    # 3-year simulation (numbers only, no additional charts)
    revenue_mean_3, revenue_p5_3, revenue_p95_3, _ = simulate_and_plot(
        revenue,
        growth_rate,
        years=3,
        sigma=0.18,
    )
    valuation_mean_3, valuation_p5_3, valuation_p95_3, _ = simulate_and_plot(
        valuation,
        growth_rate,
        years=3,
        sigma=0.3,
    )

    # Title
    story.append(Paragraph("Startup Prediction Report", styles["Title"]))
    story.append(Spacer(1, 0.2 * inch))

    # Main information
    if prediction == 1:
        prediction_text='IPO - High liquidity and visibility'
    else:
        prediction_text='Not IPO'

    info = f"""
    <b>XGBoost Prediction Exit-type:</b> {prediction_text}<br/>
    <b>Model confidence:</b> {confidence*100:.3f}%<br/>
    <b>Founded year:</b> {founded_year}<br/>
    <b>Funding amount USD:</b> {funding_amount:,.2f}<br/>
    <b>Employees:</b> {employees}<br/>
    <b>Current annual revenue:</b> {revenue:,.2f}<br/>
    <b>Current valuation:</b> {valuation:,.2f}<br/><br/>
    <b>Estimated annual growth rate:</b> {growth_rate*100:.1f}%<br/><br/>
    <b>Projected revenue in 1 year:</b> {revenue_mean_1:,.2f} USD 
    (5%-95%: {revenue_p5_1:,.2f} - {revenue_p95_1:,.2f})<br/>
    <b>Projected valuation in 1 year:</b> {valuation_mean_1:,.2f} USD 
    (5%-95%: {valuation_p5_1:,.2f} - {valuation_p95_1:,.2f})<br/><br/>
    <b>Projected revenue in 3 years:</b> {revenue_mean_3:,.2f} USD 
    (5%-95%: {revenue_p5_3:,.2f} - {revenue_p95_3:,.2f})<br/>
    <b>Projected valuation in 3 years:</b> {valuation_mean_3:,.2f} USD 
    (5%-95%: {valuation_p5_3:,.2f} - {valuation_p95_3:,.2f})<br/><br/>
    These projections are illustrative scenarios based on the current revenue,
    valuation and funding amount, assuming a lognormal distribution of outcomes.
    Actual future performance may be higher or lower than these estimates.<br/>
    """
    story.append(Paragraph(info, styles["BodyText"]))
    story.append(Spacer(1, 0.2*inch))

    # Insert charts
    story.append(Paragraph("<b>Revenue distribution (1 year):</b>", styles["BodyText"]))
    story.append(Image(revenue_img, width=400, height=250))
    story.append(Spacer(1, 0.2*inch))

    story.append(Paragraph("<b>Valuation distribution (1 year):</b>", styles["BodyText"]))
    story.append(Image(valuation_img, width=400, height=250))

    # Create PDF
    doc = SimpleDocTemplate(filepath, pagesize=letter)
    doc.build(story)

    # Retorna el path temporal, que será renombrado en /predict
    return filepath

# -----------------------------------------------------------
# Endpoints
# -----------------------------------------------------------

@app.post("/predict")
def predict(input_data: PredictionInput):
    # --- 1. Predicción y Creación de PDF ---
    X = np.array([input_data.features])

    if X.shape[1] != EXPECTED_FEATURES:
        raise HTTPException(
            status_code=400, 
            detail=f"Model expects {EXPECTED_FEATURES} features, received {X.shape[1]}"
        )

    # Predicción XGBoost
    pred_int = int(model.predict(X)[0])
    prob = model.predict_proba(X)[0]
    conf = float(np.max(prob))
    pred_label = 'IPO' if pred_int == 1 else 'NO IPO'
    
    # Extracción de valores para el PDF
    founded_year = int(input_data.features[0])
    funding_amount = float(input_data.features[1])
    employees = int(input_data.features[2])
    revenue = float(input_data.features[3])
    valuation = float(input_data.features[4])

    # Crea PDF (devuelve un path temporal)
    temp_pdf_path = create_pdf_report(pred_int, conf, revenue, valuation, funding_amount, founded_year, employees)
    
    # Generar el nombre de archivo final y renombrar el PDF
    timestamp_key = int(time.time())
    pdf_filename = f"report_{input_data.user_id}_{timestamp_key}.pdf"
    final_pdf_path = os.path.join(REPORTS_DIR, pdf_filename)
    os.rename(temp_pdf_path, final_pdf_path) # Renombra el archivo temporal

    # --- 2. Persistencia en Supabase ---
    # --- 2. Persistencia en Supabase ---
    try:
        report_uuid = str(uuid.uuid4())  # Generar ID único para la PK

        data_to_save = {
            # Nombres EXACTOS de las columnas en la tabla 'reports'
            'reportid': report_uuid,
            'model-used': 'XGBoost v1.0',
            'version': 1,
            'creation-date': datetime.now().strftime('%Y-%m-%d'),
            # IMPORTANTE: start_up_name referencia a la tabla "start-up" (columna "start-up-id").
            # Por ahora NO enviamos este campo para evitar violar la FK cuando
            # el id de startup aún no existe en esa tabla.
            # 'start_up_name': input_data.startup_name,
            'report_url': pdf_filename,
            'confidence': conf,
            'IPO_NO IPO': pred_label,
            # Enlazamos el reporte con el usuario de la tabla public.user
            'user_id': input_data.user_id,
        }

        # En supabase-py 2.x, insert devuelve directamente la respuesta.
        # No usamos .select() aquí.
        response = supabase.table('reports').insert(data_to_save).execute()

        # response.data suele ser una lista con las filas insertadas
        saved_report = response.data[0] if response.data else data_to_save
        report_id = saved_report.get('reportid', report_uuid)

    except Exception as e:
        print(f"SUPABASE INSERTION ERROR: {e}")
        # No rompemos la respuesta hacia Flutter; simplemente indicamos que
        # no se pudo guardar el reporte en la tabla.
        report_id = None

    # --- 3. Retornar la respuesta clave a Flutter ---
    return {
        "prediction": pred_int, # 1 o 0
        "confidence": conf,
        "report_file": pdf_filename,
        "report_id": report_id
    }

@app.get("/download/{filename}")
def download_report(filename: str):
    filepath = os.path.join(REPORTS_DIR, filename)
    if os.path.exists(filepath):
        return FileResponse(path=filepath, filename=filename, media_type="application/pdf")
    return {"error": "File not found"}

@app.get("/health")
def health():
    return {"status": "ok"}