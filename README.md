# Extract MS Learn Units

A robust, fail-fast Zsh utility designed to extract all unit URLs from Microsoft Learn **Learning Path** and **Module** pages. 

This tool was created specifically to streamline the process of importing Microsoft Learn documentation into **[Google NotebookLM](https://notebooklm.google.com/)**, RAG pipelines, or AI study assistants by automatically generating clean, content-dense source URL lists.

---

## 🎯 Why This Tool?

When creating custom research notebooks or knowledge bases in **NotebookLM**, manually opening and copying individual unit URLs from multi-module Microsoft Learn learning paths is tedious and time-consuming. 

`extract-ms-learn-units` automates this entire workflow while intelligently filtering out boilerplate pages that add no semantic value to your AI models:
- **Excludes introductions** (`*introduction*`)
- **Excludes unit summaries** (`*summary*`)
- **Excludes quizzes & assessments** (`*knowledge-check*`)

The result is a clean, ordered list of pure instructional unit URLs ready to be pasted directly into NotebookLM as website sources.

---

## ✨ Features

- ⚡ **Dual Input Support**: Pass either full Learning Path URLs (`.../training/paths/...`) or individual Module URLs (`.../training/modules/...`).
- 🧹 **Smart Filtering**: Automatically skips non-instructional pages (Introduction, Summary, Knowledge Check) to keep your knowledge base focused.
- 🌐 **Dynamic Locale Preservation**: Automatically detects and respects URL languages and locales (e.g., `zh-tw`, `en-us`, `ja-jp`, `de-de`).
- 🛡️ **Fail-Fast & Safe**: Built to strict Zsh guidelines with dependency checks, standard ANSI color logging, and atomic temporary file handling with automatic cleanup traps.
- 🔍 **Developer Friendly**: Features a `--verbose` debug mode and `--dump-dir` option to save raw HTML responses for inspection and regex tuning.
- 🧪 **100% Tested**: Complete Behavior-Driven Development (BDD) test suite built with [ShellSpec](https://shellspec.info/).

---

## 📋 Prerequisites

Ensure the following standard command-line tools are installed on your system:
- `zsh` (Z shell)
- `curl`
- `grep`
- `sed`
- `awk`
- `mktemp`

---

## 🚀 Installation & Usage

### 1. Clone the repository
```bash
git clone https://github.com/jim60105/extract-ms-learn-units.git
cd extract-ms-learn-units
```

### 2. Syntax
```bash
./extract-ms-learn-units.zsh [-v|--verbose] [--dump-dir DIR] <url> [url2 ...]
```

### Options
| Option | Description |
| :--- | :--- |
| `-v, --verbose` | Print detailed debugging logs to `stderr` (does not pollute `stdout`). |
| `--dump-dir DIR` | Save downloaded HTML files into `DIR/` for offline inspection and debugging. |
| `-h, --help` | Display usage instructions and exit. |

---

## 💡 Examples & NotebookLM Workflow

### Extracting a Learning Path for NotebookLM

To generate a clean list of URLs and save them to a file:

```bash
./extract-ms-learn-units.zsh \
  "https://learn.microsoft.com/zh-tw/training/paths/explore-microsoft-365-administration/" \
  > ms_learn_sources.txt
```

**Output sample (`ms_learn_sources.txt`):**
```text
https://learn.microsoft.com/zh-tw/training/modules/explore-microsoft-365-security-foundations/2-analyze-zero-trust-security-model
https://learn.microsoft.com/zh-tw/training/modules/explore-microsoft-365-security-foundations/3-implement-zero-trust-microsoft-365
https://learn.microsoft.com/zh-tw/training/modules/explore-microsoft-365-security-foundations/4-examine-threat-protection-intelligence
https://learn.microsoft.com/zh-tw/training/modules/explore-microsoft-365-security-foundations/5-explore-identity-authentication
...
```

### Direct Copy to Clipboard (macOS / Linux)

You can pipe the extracted URLs directly to your system clipboard and paste them straight into NotebookLM's **Add sources -> Web URLs** input:

```bash
# macOS
./extract-ms-learn-units.zsh "https://learn.microsoft.com/en-us/training/paths/deploy-configure-identity/" | pbcopy

# Linux (X11 / Wayland)
./extract-ms-learn-units.zsh "https://learn.microsoft.com/en-us/training/paths/deploy-configure-identity/" | xclip -selection clipboard
```

---

## 🧪 Testing

This project uses [ShellSpec](https://shellspec.info/) for comprehensive BDD testing and syntax verification.

To execute the test suite locally:

```bash
# Run all tests
shellspec

# Run tests with detailed documentation format
shellspec --format documentation
```

---

## 📜 License

This project is licensed under the **GNU General Public License v3.0 or later (GPL-3.0-or-later)**. See [GPL-3.0 License](https://www.gnu.org/licenses/gpl-3.0.html) for details.
