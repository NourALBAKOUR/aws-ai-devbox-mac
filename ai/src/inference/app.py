# SPDX-License-Identifier: Apache-2.0
# Copyright (c) 2025 Nour Al Bakour

"""
FastAPI Inference Application
Example inference endpoint for SageMaker or local testing
"""

import joblib
import numpy as np
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field

app = FastAPI(title="SageMaker Inference API", version="1.0")

# Load model at startup
model = None


class PredictionRequest(BaseModel):
    """Request schema for predictions."""
    features: list[float] = Field(..., description="Input features for prediction")


class PredictionResponse(BaseModel):
    """Response schema for predictions."""
    prediction: int = Field(..., description="Model prediction")
    probability: list[float] = Field(..., description="Class probabilities")


@app.on_event("startup")
async def load_model() -> None:
    """Load model at startup."""
    global model
    try:
        model = joblib.load("/opt/ml/model/model.joblib")
        print("Model loaded successfully")
    except Exception as e:
        print(f"Warning: Could not load model: {e}")
        print("Using dummy model for testing")


@app.get("/ping")
async def health_check() -> dict[str, str]:
    """Health check endpoint."""
    if model is None:
        raise HTTPException(status_code=503, detail="Model not loaded")
    return {"status": "healthy"}


@app.post("/invocations", response_model=PredictionResponse)
async def predict(request: PredictionRequest) -> PredictionResponse:
    """Make predictions."""
    if model is None:
        raise HTTPException(status_code=503, detail="Model not loaded")
    
    try:
        # Convert to numpy array and reshape
        features = np.array(request.features).reshape(1, -1)
        
        # Predict
        prediction = int(model.predict(features)[0])
        probabilities = model.predict_proba(features)[0].tolist()
        
        return PredictionResponse(
            prediction=prediction,
            probability=probabilities
        )
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Prediction error: {str(e)}")


@app.get("/")
async def root() -> dict[str, str]:
    """Root endpoint."""
    return {"message": "SageMaker Inference API", "docs": "/docs"}


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8080)
