# name: Python CI with Matrix

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        python-version: [3.8, 3.9, "3.10", "3.11"]
    steps:
      - uses: actions/checkout@v4

- name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: \${{ matrix.python-version }}

- name: Install dependencies
        run: |
          python -m pip install --upgrade pip
          pip install -r requirements.txt

- name: Display Python version
        run: python --version

- name: Run tests
        run: pytest

Create an complete end to end handon lab manual , with all the dependencies files.

Here is a **complete end-to-end hands-on lab manual** to create, configure, and run the Python CI workflow you provided, including all required dependency files like `requirements.txt` and test cases:

# Lab Manual: Multi-Version Python CI Pipeline Using GitHub Actions

## Objective:

Create a GitHub Actions workflow that runs your Python tests on multiple Python versions (3.8, 3.9, 3.10, 3.11) in parallel. Validate the setup with working tests and dependency management.

## Prerequisites:

- GitHub account
- Basic Python and Git knowledge
- Git installed locally or use GitHub web editor


## Step 1: Create a New GitHub Repository (or use existing)

- Create a new repository at https://github.com/new
- Clone it locally or use GitHub web editor for file edits


## Step 2: Add Python Application Code

### Create a file `app.py` with simple function

```python
def add(a, b):
    return a + b
```


## Step 3: Write Unit Tests

### Create `test_app.py` for pytest

```python
from app import add

def test_add():
    assert add(3, 4) == 7

def test_add_negative():
    assert add(-1, -1) == -2
```


## Step 4: Create `requirements.txt` file

List your dependencies including `pytest`:

```
pytest
```


## Step 5: Add GitHub Workflow

Create folder `.github/workflows` and add file `python-ci.yml` with this content:

```yaml
name: Python CI with Matrix

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        python-version: [3.8, 3.9, "3.10", "3.11"]
    steps:
      - uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: ${{ matrix.python-version }}

      - name: Install dependencies
        run: |
          python -m pip install --upgrade pip
          pip install -r requirements.txt

      - name: Display Python version
        run: python --version

      - name: Run tests
        run: pytest
```


## Step 6: Commit and Push All Files

```bash
git add app.py test_app.py requirements.txt .github/workflows/python-ci.yml
git commit -m "Add Python app, tests, requirements, and CI workflow"
git push origin main
```


## Step 7: Observe Workflow Execution

1. Go to your GitHub repo and click **Actions** tab.
2. You should see the "Python CI with Matrix" workflow triggered by your push.
3. It runs 4 parallel jobs—one for each Python version (3.8, 3.9, 3.10, 3.11).
4. Click into any job to view:
    - Setup Python
    - Dependency installation logs
    - Python version verification
    - Test run output

## Troubleshooting Tips

- **No tests collected:** Ensure test file and function names start with `test_`.
- **pytest not found:** Check `pytest` is listed in `requirements.txt`.
- **Wrong Python version:** Confirm supported versions are in the matrix.
- **Workflow not triggered:** Check branch and event configuration in `on:` block.


## Lab Summary

- You created a simple Python function and tests.
- Added `requirements.txt` with `pytest`.
- Defined a multi-version workflow matrix in GitHub Actions.
- Tested your code on multiple Python versions automatically.
- Learned best practices for naming and dependencies in GitHub CI.

Feel free to extend this by adding linting, coverage reporting, or deployment steps!

If you want, I can provide sample code for those next steps.

