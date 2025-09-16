# TextMate

TextMate is a powerful, modular text editor for macOS with a sophisticated architecture built on efficient C++ data structures and an elegant Objective-C++ GUI layer.

## Download

You can [download TextMate from here](https://macromates.com/download).

## Building

### Dependencies

TextMate uses a custom build system based on **rave** configuration files and **ninja**. Install the following dependencies:

 * [boost][]            — portable C++ source libraries
 * [Cap'n Proto][capnp] — serialization library
 * [multimarkdown][]    — marked-up plain text compiler
 * [ninja][]            — build system similar to `make`
 * [ragel][]            — state machine compiler
 * [sparsehash][]       — a cache friendly `hash_map`

Install via [Homebrew][] or [MacPorts][]:

```bash
# Homebrew (recommended)
brew install boost capnp google-sparsehash multimarkdown ninja ragel

# MacPorts
sudo port install boost capnproto multimarkdown ninja ragel sparsehash
```

### Initial Setup

```bash
git clone --recursive https://github.com/textmate/textmate.git
cd textmate
./configure && ninja TextMate/run
```

The `./configure` script checks dependencies and generates `build.ninja` with default config set to `release`.

### Common Build Commands

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

### Building from within TextMate

1. Install the [Ninja][NinjaBundle] bundle via _Preferences_ → _Bundles_
2. Set up `PATH` in _Preferences_ → _Variables_ or `~/.tm_properties` (e.g., `$PATH:/usr/local/bin`)
3. Press ⌘B to build

The default target is `TextMate/run` which will relaunch TextMate with full session restore.

## Architecture Overview

TextMate follows a modular architecture with clear separation between low-level C++ data structures and high-level Objective-C++ GUI components.

### Core Data Structures

- **`oak::basic_tree_t`** - Balanced binary indexed tree (AA-tree) for text storage with O(log N) operations
- **`ng::detail::storage_t`** - Efficient chunked memory storage in basic_tree_t
- **`ng::buffer_t`** - Text buffer with semantic services (line/column tracking, syntax parsing, text marks)
- **`ng::indexed_map_t`** - Segment tree providing map-like interface and indexed access for metadata
- **`ng::layout_t`** - Text layout and rendering with line wrapping and folding support

### Framework Organization

**Core Frameworks:**
- `buffer/` - Text storage and manipulation
- `editor/` - Text editing operations and transformations  
- `parse/` - Grammar parsing and syntax highlighting
- `layout/` - Text layout and rendering
- `selection/` - Text selection handling
- `regexp/` - Regular expression and pattern matching

**GUI Frameworks:**
- `OakTextView/` - Main text editing view components
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

- `TextMate/` - Main TextMate.app
- `mate/` - Command line tool
- `SyntaxMate/` - Syntax highlighting framework
- Plus various utility applications

## Testing

Tests use the CxxTest framework and are located in `tests/` subdirectories:

- `t_*.cc` or `t_*.mm` - Unit tests using CxxTest
- `gui_*.mm` - GUI tests

Build test targets automatically based on current file location via `.tm_properties`.

## Bundle Development

TextMate's functionality is extended through bundles containing:
- Commands, snippets, and macros
- Grammar definitions for syntax highlighting
- Themes for visual appearance
- Language-specific settings

## Development Configuration

- Uses `.rave` files for build configuration
- Uses `.tm_properties` for TextMate-specific settings
- C++2a standard with 3-space tabs
- Precompiled headers in `Shared/PCH/`
- Automatic framework include path configuration

## Feedback

- [TextMate mailing list](https://lists.macromates.com/listinfo/textmate)
- [#textmate][] IRC channel on [freenode.net][]
- [Contact MacroMates](https://macromates.com/support)

Please read the [writing bug reports](https://github.com/textmate/textmate/wiki/writing-bug-reports) instructions before submitting issues.

## Screenshot

![textmate](https://raw.github.com/textmate/textmate/gh-pages/images/screenshot.png)

# Legal

The source for TextMate is released under the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

TextMate is a trademark of Allan Odgaard.

[boost]:         http://www.boost.org/
[ninja]:         https://ninja-build.org/
[multimarkdown]: http://fletcherpenney.net/multimarkdown/
[ragel]:         http://www.complang.org/ragel/
[capnp]:         https://github.com/capnproto/capnproto.git
[MacPorts]:      http://www.macports.org/
[Homebrew]:      http://brew.sh/
[NinjaBundle]:   https://github.com/textmate/ninja.tmbundle
[sparsehash]:    https://code.google.com/p/sparsehash/
[#textmate]:     irc://irc.freenode.net/#textmate
[freenode.net]:  http://freenode.net/
