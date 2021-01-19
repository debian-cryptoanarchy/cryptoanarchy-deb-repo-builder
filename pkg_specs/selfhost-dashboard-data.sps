name = "selfhost-dashboard-data"
architecture = "all"
provides = ["default-selfhost-dashboard-data-iface (= 0.1.0)", "selfhost-dashboard-data-iface (= 0.1.0)"]
summary = "Static data served by selfhost-dashboard"
add_files = ["static /usr/share/selfhost-dashboard"]
conflicts = ["selfhost-dashboard-bin (<< 0.1.0-4)"]
