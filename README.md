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

### Install via Composer
1. Install package:

        composer require --dev nafigator/php-qa-hooks
2. Add *extra* section to *composer.json*:

        "extra": {
            "scripts-dev": {
                "post-install-cmd": "vendor/nafigator/php-qa-hooks/src/hooks-uninstall.sh"
            }
        }
3. Run `composer install`.
### Uninstall
1. Remove git config section `check.php`

        git config --remove-section check.php
2. Add *extra* section to *composer.json*:

        "extra": {
            "scripts-dev": {
                "post-install-cmd": "vendor/nafigator/php-qa-hooks/src/hooks-uninstall.sh"
            }
        }
    Commit and push your changes to repository. When uninstall script completes
    cleanup for all work copies, move to next step.
3. Remove package:

        composer remove --dev nafigator/php-qa-hooks
### Versioning
This software follows *"Semantic Versioning"* specifications. All function signatures declared as public API.

Read more on [SemVer.org](http://semver.org).

  [Conventional commits src]: https://conventionalcommits.org
  [Conventional commits badge]: https://img.shields.io/badge/Conventional%20Commits-1.0.0-yellow.svg
  [Release img]: https://img.shields.io/badge/release-0.5.3-orange.svg
  [Release src]: https://github.com/nafigator/php-qa-hooks
  [pre-commit img]: https://github.com/nafigator/git-hooks/raw/master/.images/pre-commit.jpg
  [License img]: https://img.shields.io/badge/license-MIT-brightgreen.svg
  [License src]: https://tldrlegal.com/license/mit-license
  [Versioning img]: https://img.shields.io/badge/Semantic%20Versioning-2.0.0-brightgreen.svg
  [Versioning src]: https://semver.org
