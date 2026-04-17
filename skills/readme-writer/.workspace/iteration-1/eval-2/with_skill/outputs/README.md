<div align="center">

# data-lens

**Profile, diff, and summarize Pandas DataFrames in one line.**

[![PyPI](https://img.shields.io/pypi/v/data-lens.svg)](https://pypi.org/project/data-lens/)
[![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](./LICENSE)
[![Python](https://img.shields.io/pypi/pyversions/data-lens.svg)](https://pypi.org/project/data-lens/)

[Quick Start](#quick-start) • [Installation](#installation) • [Usage](#usage) • [API Reference](#api-reference)

</div>

---

> **Status:** beta. The public API is stable across 0.4.x releases. Safe for
> production pipelines — pin your version.

data-lens is a Python library for data engineers who need fast, readable
diagnostics on Pandas DataFrames. Profile a frame for nulls and type
distributions, diff two frames to surface schema changes, or generate a
one-page summary — all without leaving your notebook or pipeline script.
Output renders in the terminal via [Rich](https://github.com/Textualize/rich)
and can be captured as plain text for logging.

## Installation

```bash
pip install data-lens
```

Requires Python 3.10+ and pandas 2.0+.

## Quick start

```python
import pandas as pd
from data_lens import profile

df = pd.read_parquet("orders.parquet")
profile(df)
```

This prints a Rich-formatted profile table to the terminal — row count, column
types, null rates, and value distributions for every column. See
[Usage](#usage) for diffing and summarizing.

## Usage

### Profile a DataFrame

```python
from data_lens import profile

report = profile(df)
# Renders a styled table; returns the report object for programmatic access.
print(report.null_rate("order_date"))   # → 0.023
```

### Diff two DataFrames

```python
from data_lens import diff

result = diff(df_before, df_after)
# Highlights added/removed columns, schema changes, and row-count delta.
```

### Summarize for logging

```python
from data_lens import summarize

summary = summarize(df)
print(summary.to_text())
# One-paragraph plain-text description suitable for log output or Slack alerts.
```

## API reference

Full API docs are at [data-lens.readthedocs.io](https://data-lens.readthedocs.io).

## Development

```bash
git clone https://github.com/psenger/data-lens.git
cd data-lens
pip install -e ".[dev]"
pytest
```

Linting uses [Ruff](https://docs.astral.sh/ruff/) (`ruff check .`). Type
checking uses mypy (`mypy src/`).

## License

Apache 2.0 — see [LICENSE](./LICENSE) for details.

---

<div align="center">

**DataFrame diagnostics for data engineers who move fast.**

[Report Bug](https://github.com/psenger/data-lens/issues) • [Request Feature](https://github.com/psenger/data-lens/issues) • [Documentation](https://data-lens.readthedocs.io)

</div>