# Contributing to AWS AI DevBox Mac

Thank you for your interest in contributing to AWS AI DevBox Mac! This document provides guidelines and instructions for contributing.

## Code of Conduct

By participating in this project, you agree to maintain a respectful and inclusive environment for everyone.

## How to Contribute

### Reporting Bugs

If you find a bug, please create an issue with:
- A clear title and description
- Steps to reproduce the issue
- Expected vs actual behavior
- Your environment (macOS version, Python version, etc.)

### Suggesting Enhancements

Enhancement suggestions are welcome! Please create an issue with:
- A clear description of the enhancement
- The motivation and use case
- Any implementation ideas you have

### Pull Requests

1. **Fork the repository** and create your branch from `main`
2. **Make your changes** following our coding standards
3. **Test your changes** thoroughly
4. **Run pre-commit hooks**: `pre-commit run --all-files`
5. **Update documentation** if needed
6. **Submit a pull request** with a clear description

## Development Setup

1. Clone your fork:
```bash
git clone https://github.com/YOUR_USERNAME/aws-ai-devbox-mac.git
cd aws-ai-devbox-mac
```

2. Run the bootstrap script:
```bash
./scripts/bootstrap.sh
```

3. Set up the development environment:
```bash
poetry install
poetry shell
pre-commit install
```

## Coding Standards

### Python

- Follow PEP 8 style guide
- Use type hints where appropriate
- Write docstrings for functions and classes
- Format code with Black: `poetry run black .`
- Lint with Ruff: `poetry run ruff check .`
- Check types with MyPy: `poetry run mypy .`

### Terraform

- Use consistent naming conventions
- Document variables and outputs
- Format code: `terraform fmt -recursive`
- Validate: `terraform validate`

### Commit Messages

- Use clear and descriptive commit messages
- Start with a verb (Add, Update, Fix, Remove, etc.)
- Keep the first line under 72 characters
- Add details in the body if needed

Example:
```
Add Bedrock streaming response example

- Implement streaming response handler
- Add example in bedrock_examples.py
- Update documentation
```

## Testing

Before submitting a pull request:

1. Test your changes locally
2. Run pre-commit hooks: `pre-commit run --all-files`
3. Verify Terraform modules: `terraform validate`
4. Test example scripts if modified

## Documentation

- Update README.md if you add new features
- Add comments to complex code
- Update docstrings for Python functions
- Document Terraform variables and outputs

## Project Structure

When adding new files, follow the existing structure:

```
examples/          - Example code and notebooks
scripts/           - Utility scripts
terraform/modules/ - Reusable Terraform modules
terraform/live/    - Environment-specific configs
```

## Questions?

If you have questions, feel free to:
- Open an issue
- Start a discussion
- Reach out to the maintainers

Thank you for contributing! 🎉
