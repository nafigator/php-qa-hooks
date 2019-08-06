[![GitHub license][License img]][License src]

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

	composer require nafigator/git-hooks

  [pre-commit img]: https://github.com/nafigator/git-hooks/raw/master/.images/pre-commit.png
  [License img]: https://img.shields.io/badge/license-BSD3-brightgreen.svg
  [License src]: https://tldrlegal.com/license/bsd-3-clause-license-(revised)
