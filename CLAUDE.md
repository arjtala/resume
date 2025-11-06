# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This repository generates a professional resume/CV from Org-mode source files using Emacs and LaTeX. The workflow:
1. Source content is authored in `resume.org` (Org-mode format)
2. Emacs Lisp scripts process and export to LaTeX using a custom exporter (`ox-kishvanchee.el`)
3. LaTeX compiles to PDF with BibTeX for bibliography management

## Build Commands

### Generate PDF Resume

```bash
emacs --batch -l genFile.el -f ox/export-org-to-pdf
```

This command:
- Loads the generation script (`genFile.el`)
- Exports `resume.org` to LaTeX format using custom exporter
- Runs pdflatex and bibtex to produce `resume.pdf`
- Also generates `resume.md` (Markdown export)
- Cleans up temporary files

### Manual Build Steps (if needed)

```bash
# Export org to LaTeX
emacs --batch -l genFile.el --eval "(progn (find-file \"resume.org\") (org-export-to-file 'kishvanchee \"resume.tex\"))"

# Compile LaTeX
pdflatex resume.tex
bibtex resume
pdflatex resume.tex

# Clean temporary files
rm -f resume.{aux,bbl,blg,log,out}
```

## Architecture

### Custom Org Export Backend

The core architecture revolves around a custom Org-mode export backend defined in `ox-kishvanchee.el`:

- **Derived from**: `ox-latex` (standard LaTeX exporter)
- **Custom metadata**: Extends Org with `:mobile`, `:linkedin`, `:github`, `:anon` properties
- **Template structure**: Injects `template.tex` for LaTeX preamble and styling
- **Hierarchical mapping**:
  - Level 1 headlines → LaTeX `\section` (e.g., "Experience", "Education")
  - Level 2 headlines → `\resumeSubheading` (e.g., company names with locations)
  - Level 3 headlines → `\resumeSubSubheading` (e.g., job titles with date ranges)
- **Date formatting**: Converts Org timestamps (e.g., `<2009-09-01>`) to human-readable format ("Sep 2009")
- **Property drawers**: Extracts `:LOCATION:`, `:FROM:`, `:TO:` properties for structured data

### Build System

`genFile.el` orchestrates the build:
- Configures Emacs environment (loads required packages: `org`, `ox-bibtex`, `ox-extra`)
- Sets up shell PATH from user environment (critical for finding `pdflatex`, `bibtex`, `bibtex2html`)
- Explicitly adds Homebrew (`/opt/homebrew/bin`) and MacTeX (`/usr/local/texlive/2025/bin/universal-darwin`) to `exec-path` for macOS
- Implements `ox/export-org-to-pdf` function for complete build pipeline
- Handles temporary file cleanup

### LaTeX Template

`template.tex` provides:
- Modern resume styling with custom colors (`ink` color scheme)
- Noto Sans font for clean, professional appearance
- Custom commands: `\resumeSubheading`, `\resumeSubSubheading`, `\creator`
- Tight spacing and margins optimized for one-page resume
- Bibliography formatting with `natbib`

### Content Structure

`resume.org` uses Org-mode features:
- **Property drawers** for structured metadata (locations, dates)
- **Headlines** for hierarchical organization
- **Bibliography directive**: `#+BIBLIOGRAPHY: refs abbrvnat` references `refs.bib`
- **Export options**: Controls author, email, date formatting via `#+options`

## Key Files

- `resume.org` - Source content (edit this)
- `refs.bib` - BibTeX bibliography entries
- `genFile.el` - Build orchestration script
- `ox-kishvanchee.el` - Custom Org exporter backend
- `template.tex` - LaTeX styling and preamble
- `ox-bibtex.el`, `org-bibtex.el`, `org-bibtex-extras.el` - Bibliography support
- `ox-extra.el` - Org export utilities (enables `:ignore:` tag to exclude headlines but keep content)

## Development Notes

### Modifying Resume Content

Edit `resume.org` following this structure:
```org
* Section Name
** Organization
:PROPERTIES:
:LOCATION: City, State
:END:
*** Position Title
:PROPERTIES:
:FROM: <2020-01-01>
:TO: <2023-12-31>
:END:
- Bullet point describing work
```

### Adding Bibliography Entries

Add entries to `refs.bib` using standard BibTeX format. The export process automatically generates HTML bibliography using `bibtex2html`.

### Path Configuration (macOS)

The build script requires these binaries in PATH:
- `pdflatex` - Usually in `/usr/local/texlive/2025/bin/universal-darwin`
- `bibtex` - Same directory as pdflatex
- `bibtex2html` - Usually in `/opt/homebrew/bin`

Update paths in `genFile.el:71-75` if tools are installed elsewhere.

### Anonymization

Set `#+anon: true` in `resume.org` to replace personal details with placeholders (for sharing templates).
