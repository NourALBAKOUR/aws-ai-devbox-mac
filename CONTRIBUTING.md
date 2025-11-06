# Contributing to AWS Mac Bootstrap

Thank you for your interest in contributing! This document provides guidelines for contributing to this project.

## Code of Conduct

- Be respectful and inclusive
- Focus on constructive feedback
- Help others learn and grow

## How to Contribute

### Reporting Issues

1. Check existing issues first
2. Use issue templates
3. Provide clear reproduction steps
4. Include environment details (macOS version, architecture)

### Suggesting Features

1. Open a discussion first
2. Explain the use case
3. Consider backwards compatibility

### Pull Requests

1. **Fork the repository**
   ```bash
   gh repo fork YOUR-USERNAME/aws-mac-bootstrap-bedrock-sagemaker
   ```

2. **Create a feature branch**
   ```bash
   git checkout -b feature/amazing-feature
   ```

3. **Make your changes**
   - Follow existing code style
   - Add tests if applicable
   - Update documentation

4. **Test thoroughly**
   ```bash
   # Test bootstrap scripts
   bash bootstrap/install_homebrew.sh
   
   # Test Python code
   cd ai && poetry run pytest
   
   # Test Terraform
   cd infra && terraform validate
   ```

5. **Run pre-commit hooks**
   ```bash
   pre-commit install
   pre-commit run --all-files
   ```

6. **Commit with clear messages**
   ```bash
   git commit -m "feat: add support for X"
   ```

   Use conventional commits:
   - `feat:` - New feature
   - `fix:` - Bug fix
   - `docs:` - Documentation
   - `style:` - Formatting
   - `refactor:` - Code restructure
   - `test:` - Tests
   - `chore:` - Maintenance

7. **Push and create PR**
   ```bash
   git push origin feature/amazing-feature
   gh pr create
   ```

## Development Setup

```bash
# Clone repo
git clone https://github.com/YOUR-USERNAME/aws-mac-bootstrap-bedrock-sagemaker.git
cd aws-mac-bootstrap-bedrock-sagemaker

# Install pre-commit
pre-commit install

# Install Python dependencies
cd ai && poetry install

# Test changes
poetry run pytest
```

## Coding Standards

### Shell Scripts

- Use `set -euo pipefail`
- Add comments for complex logic
- Make scripts idempotent
- Test on both Apple Silicon and Intel

### Python

- Follow PEP 8
- Use type hints
- Add docstrings
- Format with black and ruff

### Terraform

- Use modules for reusability
- Add variable descriptions
- Include outputs
- Format with `terraform fmt`

### Documentation

- Clear and concise
- Include code examples
- Update table of contents
- Test all commands

## Testing

### Shell Scripts

```bash
# Test on clean environment
# Verify idempotency (run twice)
bash bootstrap/install_homebrew.sh
bash bootstrap/install_homebrew.sh
```

### Python

```bash
cd ai/
poetry run pytest
poetry run ruff check src/
poetry run black --check src/
```

### Terraform

```bash
cd infra/
terraform fmt -check
terraform validate
tflint
tfsec .
```

## Documentation Guidelines

- Use Markdown
- Include working examples
- Add to appropriate doc file
- Update README if needed

## Release Process

Maintainers will:
1. Review and merge PRs
2. Update CHANGELOG
3. Tag releases
4. Publish release notes

## Questions?

- Open a discussion
- Tag maintainers in issues
- Check existing docs

## License

By contributing, you agree your code will be licensed under the MIT License.

---

Thank you for contributing! 🎉
