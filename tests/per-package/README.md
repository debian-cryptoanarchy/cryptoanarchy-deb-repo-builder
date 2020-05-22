# Per-package tests

For each package this directory may contain a subdirectory of that package name.
For each such subdirectory, there can be checks to perform:

* `after_install.sh` - run after installation or reinstallation
* `after_remove.sh` - run after removal
* `after_upgrade.sh` - run after upgrade from an older version

All of the above should run regardless if the package is dependency or not.
Further, scripts of same names may be placed into `alone` subdirectory, which
is run only if the package is **not** a dependency.
