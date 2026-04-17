# data-lens

**Profile, diff, and summarize Pandas DataFrames in one line.**

`data-lens` is a Python library that makes exploratory data analysis (EDA) and data quality checks fast and readable. Import it into your project to instantly profile DataFrames, compare two DataFrames side-by-side, or generate human-readable summaries — all without writing boilerplate inspection code.

---

## Features

- **Profile** — generate a comprehensive statistical summary of any DataFrame, including dtypes, null counts, unique value counts, and descriptive statistics
- **Diff** — compare two DataFrames and surface schema changes, value differences, and row count deltas at a glance
- **Summarize** — produce concise, human-readable overviews formatted with [Rich](https://github.com/Textualize/rich) for terminal or notebook output
- **One-line API** — designed to be called inline during analysis without disrupting your workflow
- **Arrow-backed** — optional PyArrow integration for high-performance data handling

---

## Requirements

- Python >= 3.10
- pandas >= 2.0
- numpy >= 1.24
- rich >= 13.0
- pyarrow >= 14.0

---

## Installation

Install from PyPI:

```bash
pip install data-lens
```

To install with development dependencies:

```bash
pip install "data-lens[dev]"
```

---

## Quick Start

```python
import pandas as pd
from data_lens import profile, diff, summarize

df = pd.DataFrame({
    "id": [1, 2, 3, 4, 5],
    "name": ["Alice", "Bob", "Carol", "Dave", None],
    "score": [88.5, 92.0, None, 76.3, 84.1],
    "category": ["A", "B", "A", "C", "B"],
})

# Profile a DataFrame
report = profile(df)
print(report)

# Summarize a DataFrame in plain language
summarize(df)

# Diff two DataFrames
df_v2 = df.copy()
df_v2.loc[0, "score"] = 95.0
df_v2 = df_v2.drop(columns=["category"])

diff(df, df_v2)
```

---

## API Reference

### `profile(df)`

Returns a structured profile of the DataFrame including:

- Column names and dtypes
- Null / missing value counts and percentages
- Unique value counts
- Min, max, mean, and standard deviation for numeric columns
- Sample values for categorical columns

```python
from data_lens import profile

report = profile(df)
```

**Parameters**

| Parameter | Type | Description |
|-----------|------|-------------|
| `df` | `pd.DataFrame` | The DataFrame to profile |

**Returns:** A profile report object. Use `print()` or Rich's console to render it.

---

### `summarize(df)`

Prints a concise, human-readable summary of the DataFrame to the terminal using Rich formatting.

```python
from data_lens import summarize

summarize(df)
```

**Parameters**

| Parameter | Type | Description |
|-----------|------|-------------|
| `df` | `pd.DataFrame` | The DataFrame to summarize |

**Returns:** `None`. Output is written directly to the console.

---

### `diff(df_left, df_right)`

Compares two DataFrames and reports differences in:

- Schema (added, removed, or changed columns)
- Row counts
- Cell-level value changes

```python
from data_lens import diff

diff(df_before, df_after)
```

**Parameters**

| Parameter | Type | Description |
|-----------|------|-------------|
| `df_left` | `pd.DataFrame` | The baseline DataFrame |
| `df_right` | `pd.DataFrame` | The DataFrame to compare against the baseline |

**Returns:** A diff report object describing all detected differences.

---

## Usage Patterns

### Inline during data loading

```python
import pandas as pd
from data_lens import profile

df = profile(pd.read_csv("data.csv"))
```

### Validating a data pipeline step

```python
from data_lens import diff

raw = pd.read_parquet("raw.parquet")
cleaned = clean(raw)

diff(raw, cleaned)  # confirm only expected changes occurred
```

### Notebook EDA

```python
from data_lens import summarize, profile

summarize(df)
profile(df)
```

---

## Development

Clone the repository and install with dev dependencies:

```bash
git clone https://github.com/psenger/data-lens.git
cd data-lens
pip install -e ".[dev]"
```

Run tests:

```bash
pytest
```

Lint and type-check:

```bash
ruff check .
mypy .
```

---

## Links

- **Homepage:** https://github.com/psenger/data-lens
- **Documentation:** https://data-lens.readthedocs.io
- **Issues:** https://github.com/psenger/data-lens/issues

---

## License

Licensed under the [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0).