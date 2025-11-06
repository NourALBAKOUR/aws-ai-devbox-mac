# SPDX-License-Identifier: Apache-2.0
# Copyright (c) 2025 Nour Al Bakour

"""
SageMaker Training Script (Scikit-Learn Example)
This is a minimal training script for demonstration.
"""

import argparse
import json
import os
import joblib
import numpy as np
import pandas as pd
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score, classification_report
from sklearn.model_selection import train_test_split


def parse_args() -> argparse.Namespace:
    """Parse training arguments."""
    parser = argparse.ArgumentParser()
    
    # Hyperparameters
    parser.add_argument("--n-estimators", type=int, default=100)
    parser.add_argument("--max-depth", type=int, default=10)
    parser.add_argument("--random-state", type=int, default=42)
    
    # SageMaker directories
    parser.add_argument("--model-dir", type=str, default=os.environ.get("SM_MODEL_DIR", "/opt/ml/model"))
    parser.add_argument("--train", type=str, default=os.environ.get("SM_CHANNEL_TRAIN", "/opt/ml/input/data/train"))
    parser.add_argument("--test", type=str, default=os.environ.get("SM_CHANNEL_TEST", "/opt/ml/input/data/test"))
    parser.add_argument("--output-data-dir", type=str, default=os.environ.get("SM_OUTPUT_DATA_DIR", "/opt/ml/output"))
    
    return parser.parse_args()


def load_data(train_dir: str, test_dir: str) -> tuple[pd.DataFrame, pd.DataFrame]:
    """Load training and test data."""
    train_file = os.path.join(train_dir, "train.csv")
    test_file = os.path.join(test_dir, "test.csv")
    
    train_df = pd.read_csv(train_file)
    test_df = pd.read_csv(test_file)
    
    print(f"Train data shape: {train_df.shape}")
    print(f"Test data shape: {test_df.shape}")
    
    return train_df, test_df


def train_model(args: argparse.Namespace) -> RandomForestClassifier:
    """Train RandomForest model."""
    print("Loading data...")
    train_df, test_df = load_data(args.train, args.test)
    
    # Assume last column is target
    X_train = train_df.iloc[:, :-1].values
    y_train = train_df.iloc[:, -1].values
    X_test = test_df.iloc[:, :-1].values
    y_test = test_df.iloc[:, -1].values
    
    print("Training model...")
    model = RandomForestClassifier(
        n_estimators=args.n_estimators,
        max_depth=args.max_depth,
        random_state=args.random_state,
        n_jobs=-1
    )
    
    model.fit(X_train, y_train)
    
    # Evaluate
    train_preds = model.predict(X_train)
    test_preds = model.predict(X_test)
    
    train_acc = accuracy_score(y_train, train_preds)
    test_acc = accuracy_score(y_test, test_preds)
    
    print(f"\nTraining Accuracy: {train_acc:.4f}")
    print(f"Test Accuracy: {test_acc:.4f}")
    print("\nClassification Report:")
    print(classification_report(y_test, test_preds))
    
    # Save metrics
    metrics = {
        "train_accuracy": train_acc,
        "test_accuracy": test_acc
    }
    
    metrics_path = os.path.join(args.output_data_dir, "metrics.json")
    with open(metrics_path, "w") as f:
        json.dump(metrics, f)
    
    return model


def save_model(model: RandomForestClassifier, model_dir: str) -> None:
    """Save trained model."""
    model_path = os.path.join(model_dir, "model.joblib")
    joblib.dump(model, model_path)
    print(f"Model saved to {model_path}")


if __name__ == "__main__":
    args = parse_args()
    
    print("=" * 80)
    print("SageMaker Training Job")
    print("=" * 80)
    print(f"Hyperparameters: n_estimators={args.n_estimators}, max_depth={args.max_depth}")
    print()
    
    model = train_model(args)
    save_model(model, args.model_dir)
    
    print("\n" + "=" * 80)
    print("Training complete!")
    print("=" * 80)
