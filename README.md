[![GitHub license][License img]][License src] [![GitHub release][Release img]][Release src] [![Conventional Commits][Conventional commits badge]][Conventional commits src] [![Semantic Versioning][Versioning img]][Versioning src]

# PHP QA git hooks
Git hooks for PHP commits quality assurance

![pre-commit output example][pre-commit img]

### Requirements
* git
* bash
* PHP CLI
* Core utils

### Features
* Customization by git config options
* Check for PHP syntax before commit
* Check for Git conflict markups before commit
* Warn about PHP dump functions (var_dump(), var_export(), print_r())
* Check PHP code style before push
* Run PHPUnit tests before push
* Colored output

### Install via Composer
1. Install package:

        composer require --dev nafigator/php-qa-hooks
2. Add *extra* section to *composer.json*:

        "extra": {
            "scripts-dev": {
                "post-install-cmd": "vendor/nafigator/php-qa-hooks/src/hooks-install.sh"
            }
        }
3. Place *phpcs.xml* into root of your project.
    > NOTE: An example phpcs.xml file can be found in the PHP_CodeSniffer repository: [phpcs.xml.dist]

4. Run `composer install`.
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
4. Remove *phpcs.xml* from root ot your project.

### Configuration
Example (colors off):

    git config check.php.colors false

Available git config options:

    check.php.colors [true|false]
    check.php.conflicts [true|false]
    check.php.dumps [true|false]
    check.php.phpunit [true|false]
    check.php.style [true|false]
    check.php.syntax [true|false]

>NOTE: PHPUnit disabled by default. You need to enable it manually.

### Versioning
This software follows *"Semantic Versioning"* specifications. All function signatures declared as public API.

Read more on [SemVer.org](http://semver.org).

  [Conventional commits src]: https://conventionalcommits.org
  [Conventional commits badge]: https://img.shields.io/badge/Conventional%20Commits-1.0.0-yellow.svg
  [Release img]: https://img.shields.io/badge/release-1.0.4-brightgreen.svg
  [Release src]: https://github.com/nafigator/php-qa-hooks
  [pre-commit img]: https://github.com/nafigator/git-hooks/raw/master/.images/pre-commit.jpg
  [License img]: https://img.shields.io/badge/license-MIT-brightgreen.svg
  [License src]: https://tldrlegal.com/license/mit-license
  [Versioning img]: https://img.shields.io/badge/Semantic%20Versioning-2.0.0-brightgreen.svg
  [Versioning src]: https://semver.org
  [phpcs.xml.dist]: https://raw.githubusercontent.com/squizlabs/PHP_CodeSniffer/3.4.2/phpcs.xml.dist
