<?php

$CONFIG = [
	// obvious settings
	'datadirectory' => '/var/lib/nextcloud-server-system/data',
	'log_type' => 'file',
	'logfile' => '/var/log/nextcloud-server-system/nextcloud.log',
	'logfilemode' => 0640,
	'loglevel' => 1,
	'apps_paths' => [
		[
			'path'=> '/usr/share/nextcloud-server/apps',
			'url' => '/apps',
			'writable' => false,
		],
	],
	'cache_path' => '/var/cache/nextcloud-server',
	'adminlogin' => 'admin',

	// Activate maintenance until explicitly deactivated
	'maintenance' => true,

	// We prefer using apt/dpkg
	'appstoreenabled' => false,
	'appcodechecker' => false,

	// Updates are managed by apt
	'updatechecker' => false,
	'upgrade.disable-web' => true,

	// Nginx doesn't use .htaccess
	'check_for_working_htaccess' => false,
	'blacklisted_files' => [],

	// Defaults that should be more sensible
	// Copying extra files is annoying
	'skeletondirectory' => '',
	// Don't leak metadata
	'connectivity_check_domains' => [],
	'simpleSignUpLink.shown' => false,
];
