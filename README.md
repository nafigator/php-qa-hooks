[![GitHub license][License img]][License src]

Git hooks
=========

Bunch of useful git hooks

pre-commit.sh
=========

Check for PHP syntax and debug functions before commit

![Alt php-bench](https://github.com/nafigator/git-hooks/raw/master/pre-commit.png)

###Requirements
* git
* bash
* PHP
* Coreutils

###Features
* Customization by git config options
* Check for PHP syntax before commit
* Warn about PHP dump functions (var_dump(), var_export())
* Colored output

###Installation

Add to your project _.git/config_ options:

    [check.php]
        syntax = true
        dumps = true

Copy **pre-commit.sh** to _.git/hooks_ folder in your working copy of project:

    cp pre-commit.sh <path to project>/.git/hooks/pre-commit

  [License img]: https://img.shields.io/badge/license-BSD3-brightgreen.svg
  [License src]: https://tldrlegal.com/license/bsd-3-clause-license-(revised)
