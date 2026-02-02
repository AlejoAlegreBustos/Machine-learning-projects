# Startup Prediction API

A simple FastAPI API to predict startup exit outcomes and generate PDF reports. This is a working project: clear, functional, and easy to tweak or extend.

## What it does

- Takes startup features as input (289 numeric and boolean values).
- Predicts exit type using XGBoost:
  - `1` → IPO (high liquidity and visibility)
  - `0` → Not IPO
- Generates PDF reports with:
  - Prediction and confidence
  - Company info: founded year, funding, employees, revenue, valuation
  - Projected revenue and valuation for 1 year
  - Histograms with mean and 5%-95% ranges
- Provides endpoints:
  - `/predict` → make predictions
  - `/download/{filename}` → download PDF
  - `/health` → check API status

## How it works

- `main.py` starts the FastAPI app and creates the `reports/` folder.
- Loads a pre-trained XGBoost model.
- Prediction flow:
  1. Validates input features (`Expected: 289`).
  2. XGBoost predicts exit type and confidence.
  3. Estimates growth rate based on funding.
  4. Projects revenue and valuation using Monte Carlo simulation.
  5. Generates PDF with ReportLab:
     - Title, summary info, projections, histograms.
- Endpoints:
  - `POST /predict` → returns prediction, confidence, PDF filename.
  - `GET /download/{filename}` → returns PDF.
  - `GET /health` → returns `{"status": "ok"}`.

## Notes

- Make sure input features match `EXPECTED_FEATURES = 289`.
- PDFs are saved in `reports/` with timestamps.
- Monte Carlo settings can be adjusted (number of simulations, sigma).
- Ready to expand:
  - Add authentication for downloads.
  - Support batch predictions.
  - Include more financial metrics in projections.
