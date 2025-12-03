# Contributing to AWS-GCP Cross-Cloud Interconnect

Thank you for your interest in contributing! This document provides guidelines and instructions.

## Code of Conduct

- Be respectful and inclusive
- Report security issues privately (see Security section below)
- No harassment or discrimination

## How to Contribute

### 1. Report a Bug
**Before submitting:**
- Check if bug already exists in [Issues](https://github.com/naveen-cloud-arch/aws-gcp-interconnect/issues)
- Test with latest version

**To report:**
- Click "New Issue" > "Bug Report"
- Include reproduction steps
- Share environment details (OS, Terraform version, AWS/GCP regions)

### 2. Request a Feature
- Click "New Issue" > "Feature Request"
- Describe use case clearly
- Explain why it's useful

### 3. Submit Code

**Fork and Clone:**
\`\`\`bash
git clone https://github.com/YOUR_USERNAME/aws-gcp-interconnect.git
cd aws-gcp-interconnect
git checkout -b feature/your-feature-name
\`\`\`

**Commit Standards:**
- Use clear, descriptive messages
- Reference issue numbers: "Fixes #123"
- Format: `type(scope): description`
  - Types: feat, fix, docs, style, refactor, test, chore
  - Example: `feat(terraform): add multi-region support for interconnect`

**Push and Pull Request:**
\`\`\`bash
git push origin feature/your-feature-name
\`\`\`

**PR Template:** Include
- What changes
- Why changes  
- Testing performed
- Related issues

## Code Style

### Terraform
- Max line length: 100 characters
- Use descriptive variable names
- Include comments for complex logic
- Use `terraform fmt` to format

### Shell Scripts
- Bash 4.0+ compatible
- Include error handling
- Add function comments
- Use shellcheck for linting

### Python
- Follow PEP 8
- Use type hints
- Include docstrings
- Run pylint/black

## Testing

Before submitting PR:

\`\`\`bash
# Terraform validation
cd terraform/aws && terraform validate && terraform fmt -check
cd ../gcp && terraform validate && terraform fmt -check

# Run test suite
cd ../..
./scripts/run-tests.sh

# Manual testing (if applicable)
terraform plan
terraform apply (on staging)
\`\`\`

## Documentation

- Update README if adding features
- Add examples for new use cases
- Update docs/ directory
- Include architecture diagrams
- Add troubleshooting tips

## Review Process

- At least 1 maintainer review required
- All tests must pass
- No conflicts with main branch
- Documentation complete

## Security

**Do NOT commit:**
- AWS credentials or access keys
- GCP service account keys
- Terraform state files
- Sensitive configuration

**Report Security Issues:**
Email: security@cloudarch.dev
(Do not open public issues for security vulnerabilities)

## Questions?

- Open Discussion thread
- Comment on related issue
- Email: naveen@cloudarch.dev

Thank you for contributing! 🙏
