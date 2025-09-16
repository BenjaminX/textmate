# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build System and Commands

TextMate uses a custom build system based on **rave** configuration files and **ninja**.

### Initial Setup
```bash
# Install dependencies (Homebrew)
brew install boost capnp google-sparsehash multimarkdown ninja ragel

# Configure and build
./configure && ninja TextMate/run
```

### Common Development Commands
```bash
# Build TextMate
ninja TextMate

# Build and launch TextMate
ninja TextMate/run

# Clean build
ninja -t clean

# Run tests for a specific framework
ninja <framework_name>/test

# Build specific application
ninja <app_name>/run
```

### Testing
Tests are located in `tests/` subdirectories within each framework. Test files follow naming conventions:
- `t_*.cc` or `t_*.mm` - Unit tests using CxxTest
- `gui_*.mm` - GUI tests

The build target for tests is automatically determined by the `.tm_properties` file based on the current file location.

## Architecture Overview

TextMate follows a modular architecture with clear separation between low-level C++ data structures and high-level Objective-C++ GUI components.

### Core Data Structures

**`oak::basic_tree_t`** - Balanced binary indexed tree (AA-tree) that serves as the foundation for text storage and layout. Provides O(log N) operations with automatic offset calculation.

**`ng::detail::storage_t`** - Efficient byte sequence storage using chunked memory in basic_tree_t.

**`ng::buffer_t`** - Text buffer that adds semantic services on top of storage:
- Line/column tracking
- Spelling checking  
- Syntax parsing and scope assignment
- Text marks and metadata

**`ng::indexed_map_t`** - Segment tree providing both map-like interface and indexed access. Used extensively for storing ranges of metadata.

**`ng::layout_t`** - Manages text layout and rendering, handling line wrapping, folding, and visual presentation.

### Framework Organization

The codebase is organized into frameworks in the `Frameworks/` directory:

**Core Frameworks:**
- `buffer/` - Text storage and manipulation
- `editor/` - Text editing operations and transformations  
- `parse/` - Grammar parsing and syntax highlighting
- `layout/` - Text layout and rendering
- `selection/` - Text selection handling
- `regexp/` - Regular expression and pattern matching

**GUI Frameworks:**
- `OakTextView/` - Main text editing view (OakTextView, GutterView, OTVStatusBar, OakDocumentView)
- `DocumentWindow/` - Document window management
- `FileBrowser/` - File browser sidebar
- `Find/` - Search and replace functionality
- `BundleEditor/` - Bundle editing interface

**Support Frameworks:**
- `io/` - File I/O, path manipulation, process execution
- `settings/` - Configuration and preferences
- `bundles/` - Bundle loading and management
- `scm/` - Source control integration (Git, SVN, Hg, P4)

### Applications

The `Applications/` directory contains several executable targets:
- `TextMate/` - Main TextMate.app
- `mate/` - Command line tool
- `SyntaxMate/` - Syntax highlighting framework

## Development Configuration

The project uses `.rave` files for build configuration and `.tm_properties` for TextMate-specific settings.

### Key Build Targets
- `TextMate/run` - Default target that builds and launches TextMate
- Individual framework tests: `<framework>/test`
- Command line tools: `mate/run`, `gtm/run`, etc.

### Code Style
- Objective-C++ for GUI components
- C++ for core data structures
- Uses C++2a standard features
- Precompiled headers in `Shared/PCH/`
- 3-space tabs, no soft tabs for C++ code
- All header files default to `source.objc++` file type

### Path Variables
The build system automatically configures include paths for frameworks via `TM_FRAMEWORK_INCLUDE` variable, allowing frameworks to include each other using their public headers.

## Testing Framework

Tests use CxxTest framework. Test targets are automatically determined:
- Framework tests: Files matching `tests/t_*.{cc,mm}` build `<framework>/test`
- GUI tests: Files matching `tests/gui_*.mm` build `<framework>/cxx_test`

## Bundle Development

TextMate's functionality is extended through bundles containing:
- Commands, snippets, and macros
- Grammar definitions for syntax highlighting
- Themes for visual appearance
- Language-specific settings

Bundle dependencies and loading are managed by the `bundles/` framework.