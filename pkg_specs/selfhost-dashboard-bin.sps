name = "selfhost-dashboard-bin"
architecture = "any"
summary = "A simple UI for selfhost-enabled applications"
recommends = ["selfhost-dashboard"]
add_files = ["/usr/bin/selfhost-dashboard", "static /usr/share/selfhost-dashboard"]
add_dirs = ["/etc/selfhost-dashboard/apps", "/usr/lib/selfhost-dashboard/apps/entry_points", "/usr/share/selfhost-dashboard/apps/icons"]
add_manpages = ["target/man/selfhost-dashboard.1"]
long_doc = """This package provides a very simple, yet useful UI for accessing
selfhost-enabled applications."""
