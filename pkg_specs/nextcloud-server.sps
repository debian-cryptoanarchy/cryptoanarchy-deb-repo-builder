name = "nextcloud-server"
architecture = "all"
summary = "A safe home for all your data."
depends = ["php-cli (>= 2:8.0)", "php-cli (<< 2:8.4)", "php-intl", "php-zip", "php-xml", "php-mbstring", "php-gd", "php-curl"]
recommends = ["nextcloud-server-system", "php-imagick", "php-gmp", "php-bcmath", "php-apcu"]
add_files = [ "/usr/share/nextcloud-server", ]
long_doc = """Nextcloud is a full-featured file sharing, collaboration and synchronization platform.
It can act as a private, self-hosted replacement for non-trusted cloud providers such as Google Drive."""
