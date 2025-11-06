# AI/ML Development Environment

This directory contains the Python environment for AWS AI/ML development with Amazon Bedrock and SageMaker.

## Setup

```bash
poetry install
```

## Usage

### Run Bedrock Examples

```bash
poetry run python src/bedrock_example.py
poetry run python src/langchain_bedrock_example.py
```

### Launch Jupyter Lab

```bash
poetry run jupyter lab
```

Then open `notebooks/bedrock_quickstart.ipynb` or `notebooks/sagemaker_training.ipynb`.

## Environment

- Python 3.12
- boto3 with type stubs for Bedrock & SageMaker
- LangChain with AWS integration
- JupyterLab for notebooks
- FastAPI for inference endpoints
- pandas, numpy, matplotlib for data analysis
