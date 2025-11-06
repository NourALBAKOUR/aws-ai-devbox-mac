# 02 - Python Environment with pyenv and Poetry

## Overview

Our Python setup uses:
- **pyenv** - Python version management
- **Poetry** - Dependency and virtual environment management
- **Python 3.12** - Latest stable release
- **Jupyter** - Interactive notebooks

## pyenv - Python Version Manager

### Verify Installation

```bash
pyenv --version
```

### List Available Python Versions

```bash
pyenv install --list | grep "^\s*3.12"
```

### Install Python 3.12

```bash
pyenv install 3.12.0  # or latest 3.12.x
pyenv global 3.12.0
```

### Verify

```bash
python --version  # Should show Python 3.12.x
which python      # Should point to ~/.pyenv/shims/python
```

### Switch Versions

```bash
# Set global version
pyenv global 3.12.0

# Set local version (per directory)
cd ~/project
pyenv local 3.11.0  # Creates .python-version file

# Set shell version (current session only)
pyenv shell 3.10.0
```

### Update pyenv

```bash
brew upgrade pyenv
```

## Poetry - Dependency Management

### Verify Installation

```bash
poetry --version
```

### Initialize New Project

```bash
poetry new my-project
cd my-project
```

### Add to Existing Project

```bash
cd existing-project
poetry init
```

### Install Dependencies

```bash
cd ai/
poetry install
```

This creates a virtual environment and installs all dependencies from `pyproject.toml`.

### Add Packages

```bash
poetry add boto3
poetry add pandas numpy
poetry add --group dev pytest black
```

### Remove Packages

```bash
poetry remove boto3
```

### Update Dependencies

```bash
poetry update
poetry update boto3  # Update single package
```

### Show Installed Packages

```bash
poetry show
poetry show --tree  # Dependency tree
```

### Run Commands in Virtual Environment

```bash
poetry run python script.py
poetry run pytest
poetry run jupyter lab
```

### Activate Virtual Environment

```bash
poetry shell
# Now you're in the virtual environment
python --version
exit  # To deactivate
```

### Export Requirements

```bash
poetry export -f requirements.txt --output requirements.txt
poetry export --without-hashes -f requirements.txt --output requirements.txt
```

## AI/ML Project Structure

Our `ai/` project includes:

```
ai/
├── pyproject.toml      # Dependencies and config
├── poetry.lock         # Locked versions
├── src/                # Source code
│   ├── bedrock_example.py
│   ├── langchain_bedrock_example.py
│   ├── sagemaker/
│   └── inference/
└── notebooks/          # Jupyter notebooks
```

### Install AI Project

```bash
cd ai/
poetry install
```

### Key Dependencies

- **boto3** - AWS SDK
- **sagemaker** - SageMaker SDK
- **langchain** - LLM framework
- **fastapi** - API framework
- **jupyterlab** - Notebooks
- **pandas, numpy** - Data manipulation

## Jupyter Notebook Setup

### Launch Jupyter Lab

```bash
cd ai/
poetry run jupyter lab
```

Opens browser at `http://localhost:8888`.

### Register Jupyter Kernel

Register the Poetry environment as a Jupyter kernel:

```bash
cd ai/
poetry run python -m ipykernel install --user --name=ai-env --display-name="Python (AI/ML)"
```

### List Kernels

```bash
jupyter kernelspec list
```

### Use Kernel in VS Code

1. Open `.ipynb` file
2. Click kernel selector (top right)
3. Select "Python (AI/ML)"

## Running Examples

### Bedrock Example

```bash
cd ai/
poetry run python src/bedrock_example.py
```

### LangChain Example

```bash
cd ai/
poetry run python src/langchain_bedrock_example.py
```

### Jupyter Notebook

```bash
cd ai/
poetry run jupyter lab notebooks/bedrock_quickstart.ipynb
```

## Environment Variables

### Option 1: .env File

Create `ai/.env`:

```bash
AWS_REGION=us-east-1
AWS_PROFILE=dev
BEDROCK_MODEL_ID=anthropic.claude-3-sonnet-20240229-v1:0
```

Load in Python:
```python
from dotenv import load_dotenv
load_dotenv()
```

### Option 2: direnv

Create `ai/.envrc`:
```bash
export AWS_REGION=us-east-1
export AWS_PROFILE=dev
```

```bash
direnv allow
```

## Type Checking with MyPy

```bash
cd ai/
poetry run mypy src/
```

## Linting and Formatting

### Ruff (Fast Linter)

```bash
cd ai/
poetry run ruff check src/
poetry run ruff check --fix src/  # Auto-fix
```

### Black (Formatter)

```bash
cd ai/
poetry run black src/
poetry run black --check src/  # Check only
```

### isort (Import Sorter)

```bash
cd ai/
poetry run isort src/
poetry run isort --check-only src/
```

### All Together

```bash
cd ai/
poetry run ruff check --fix src/
poetry run black src/
poetry run isort src/
```

## Testing

### Create Tests

```bash
mkdir -p ai/tests
touch ai/tests/test_bedrock.py
```

Example test:
```python
def test_import():
    import boto3
    assert boto3 is not None
```

### Run Tests

```bash
cd ai/
poetry run pytest
poetry run pytest -v  # Verbose
poetry run pytest --cov=src  # With coverage
```

## Troubleshooting

### Wrong Python Version

```bash
# Check pyenv version
pyenv version

# Set correct version
pyenv global 3.12.0

# Rebuild Poetry env
cd ai/
poetry env remove python
poetry install
```

### Poetry Not Found

```bash
# Check PATH
echo $PATH | grep .local

# Add to ~/.zshrc if missing
export PATH="$HOME/.local/bin:$PATH"
```

### Virtual Environment Issues

```bash
# Remove and recreate
cd ai/
poetry env remove python
poetry install
```

### Jupyter Kernel Not Found

```bash
# Reinstall kernel
cd ai/
poetry run python -m ipykernel install --user --name=ai-env --force
```

### Import Errors

```bash
# Verify you're in the right environment
cd ai/
poetry shell
python -c "import boto3; print(boto3.__version__)"
```

## Best Practices

1. **Always use Poetry** for dependency management
2. **Lock dependencies** - Commit `poetry.lock`
3. **Separate dev dependencies** - Use `--group dev`
4. **Use virtual environments** - Never install globally
5. **Pin Python version** - Specify in `pyproject.toml`
6. **Test in CI** - Run tests on multiple Python versions

## Performance Tips

### Faster Installs

```bash
# Use Poetry's installer (faster)
poetry config installer.parallel true
```

### Cache Dependencies

Poetry caches by default in `~/.cache/pypoetry`.

---

**Next:** [03 - Docker Setup](03-docker.md)
