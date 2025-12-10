# Contributing to MPAS Lengau Installation

Thank you for your interest in contributing to this project! This document provides guidelines and instructions for contributing.

## Code of Conduct

- Be respectful and inclusive
- Provide constructive feedback
- Help others learn and grow
- Follow the project's coding standards

## How to Contribute

### Reporting Issues

If you encounter a bug or have a feature request:

1. Check if the issue already exists in the Issues tab
2. Create a new issue with:
   - Clear title and description
   - Steps to reproduce (for bugs)
   - Expected vs. actual behavior
   - System information (cluster, modules, etc.)

### Submitting Changes

1. **Fork the repository**
   ```bash
   git clone https://github.com/msovara/mpas-lengau.git
   cd mpas-lengau
   ```

2. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Make your changes**
   - Follow existing code style
   - Add comments for complex logic
   - Test on Lengau cluster if possible

4. **Commit your changes**
   ```bash
   git commit -m "Add: description of your changes"
   ```
   Use clear, descriptive commit messages.

5. **Push to your fork**
   ```bash
   git push origin feature/your-feature-name
   ```

6. **Create a Pull Request**
   - Provide a clear description
   - Reference any related issues
   - Include test results if applicable

## Coding Standards

### Shell Scripts

- Use `#!/bin/bash` shebang
- Set `set -e` for error handling
- Use meaningful variable names
- Add comments for complex logic
- Follow existing indentation (4 spaces)

### Documentation

- Use Markdown format
- Keep README.md updated
- Add examples where helpful
- Document all configuration options

## Testing

Before submitting:

1. Test on Lengau cluster (if possible)
2. Verify scripts work on both DTN and compute nodes
3. Check error handling
4. Verify module file generation
5. Test installation from scratch

## Areas for Contribution

- **Documentation**: Improve guides, add examples
- **Error Handling**: Better error messages, recovery
- **Compatibility**: Support for other MPAS versions
- **Testing**: Automated test scripts
- **Performance**: Optimization suggestions
- **Features**: Additional functionality

## Questions?

Feel free to:
- Open an issue for questions
- Contact the maintainer
- Check existing documentation

Thank you for contributing! 🎉

