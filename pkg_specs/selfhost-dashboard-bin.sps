name = "selfhost-dashboard-bin"
architecture = "any"
summary = "A simple UI for selfhost-enabled applications"
depends = ["default-selfhost-dashboard-data-iface (>= 0.1.0) | selfhost-dashboard-data-iface (>= 0.1.0)", "default-selfhost-dashboard-data-iface (<< 0.2) | selfhost-dashboard-data-iface (<< 0.2)"]
recommends = ["selfhost-dashboard"]
add_files = ["/usr/bin/selfhost-dashboard"]
add_dirs = ["/etc/selfhost-dashboard/apps", "/usr/lib/selfhost-dashboard/apps/entry_points", "/usr/share/selfhost-dashboard/apps/icons"]
add_manpages = ["target/man/selfhost-dashboard.1"]
long_doc = """This package provides a very simple, yet useful UI for accessing
selfhost-enabled applications."""
