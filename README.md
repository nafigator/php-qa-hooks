[![GitHub license][License img]][License src] [![GitHub release][Release img]][Release src] [![Conventional Commits][Conventional commits badge]][Conventional commits src] [![Semantic Versioning][Versioning img]][Versioning src]

# PHP QA git hooks
Git hooks for PHP commits quality assurance

![pre-commit output example][pre-commit img]

### Requirements
* git
* bash
* PHP
* Core utils

### Features
* Customization by git config options
* Check for PHP syntax before commit
* Check for Git conflict markups before commit
* Warn about PHP dump functions (var_dump(), var_export(), print_r())
* Colored output

### Installation

Add to your project *.git/config* options:

    [check.php]
        syntax = true
        dumps = true
        conflicts = true

Copy **pre-commit.sh** to *.git/hooks* folder in your working copy of project.
Or use this oneliner inside root of project:

    curl -s https://raw.githubusercontent.com/nafigator/git-hooks/master/pre-commit.sh > .git/hooks/pre-commit && chmod +x .git/hooks/pre-commit && printf "[check.php]\n\tsyntax = true\n\tdumps = true\n\tconflicts = true\n" >> .git/config

### Install via Composer

	composer require nafigator/php-qa-hooks

## Versioning
This software follows *"Semantic Versioning"* specifications. All function signatures declared as public API.

Read more on [SemVer.org](http://semver.org).

  [Conventional commits src]: https://conventionalcommits.org
  [Conventional commits badge]: https://img.shields.io/badge/Conventional%20Commits-1.0.0-yellow.svg
  [Release img]: https://img.shields.io/badge/release-0.3.0-orange.svg
  [Release src]: https://github.com/nafigator/php-qa-hooks
  [pre-commit img]: https://github.com/nafigator/git-hooks/raw/master/.images/pre-commit.png
  [License img]: https://img.shields.io/badge/license-MIT-brightgreen.svg
  [License src]: https://tldrlegal.com/license/mit-license
  [Versioning img]: https://img.shields.io/badge/Semantic%20Versioning-2.0.0-brightgreen.svg
  [Versioning src]: https://semver.org
