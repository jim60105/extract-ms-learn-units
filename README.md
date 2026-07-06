# Extract MS Learn Units
<img width="1774" height="887" alt="banner" src="https://github.com/user-attachments/assets/005e1cb9-8cb6-49da-a88c-cd9b8e6ea880" />

This is a Zsh script that grabs all the lesson URLs from any Microsoft Learn learning path or module page. 

I originally built this to feed official documentation into **[Google NotebookLM](https://notebooklm.google.com/)**. Instead of opening dozens of tabs and copying links by hand, you run one command and get a clean list of URLs ready to import.

---

## 🎯 Why I Built This

If you use NotebookLM to study or build knowledge bases, you know that Microsoft Learn courses are split across multiple modules and individual unit pages. Copying every single URL manually takes forever.

If you just feed the top-level learning path URL to an AI tool, it usually misses the underlying pages. But if you grab every link indiscriminately, you end up cluttering your notebook with filler pages that don't teach you anything.

This script fetches the pages for you and automatically filters out the noise:
- Skips introductory pages (`*introduction*`)
- Skips module summaries (`*summary*`)
- Skips knowledge check quizzes (`*knowledge-check*`)

You get back exactly what you need: a plain list of core instructional URLs, ordered from start to finish, that you can paste straight into NotebookLM.

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

<img src="https://github.com/user-attachments/assets/f4d883c0-80d1-4980-a9f4-eebf31a28b02" alt="gplv3" width="300" />

[GNU GENERAL PUBLIC LICENSE Version 3](LICENSE)

Copyright (C) 2026 Jim Chen <Jim@ChenJ.im>.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.

### Trademarks & Fair Use Notice

Microsoft, Microsoft Learn, and the Microsoft logo are trademarks or registered trademarks of Microsoft Corporation in the United States and/or other countries. Google, Google NotebookLM, and the NotebookLM logo are trademarks or registered trademarks of Google LLC.

The Microsoft and Google NotebookLM logos and branding elements depicted in the project banner image are owned exclusively by Microsoft Corporation and Google LLC respectively. They are utilized here under the doctrine of **fair use** (nominative fair use) strictly for descriptive, educational, and identification purposes to illustrate project compatibility and workflow integration with Microsoft Learn documentation and Google NotebookLM. 

This open-source project is an independent developer tool and is not affiliated with, endorsed by, sponsored by, or otherwise associated with Microsoft Corporation or Google LLC.

