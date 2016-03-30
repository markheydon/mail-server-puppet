
class config {
	$domain = "DOMAIN.COM"
 	$mail_server_name = "host.${domain}"
  	$web_server_name = "webmail.${domain}"

	$generate_certificate = "letsencrypt"

	## staging or v01
	$cert_type = "v01"

	$files = "/root/mail-server-puppet/files"

	if ( $generate_certificate == "true" ) {
		$certificate = "ssl-cert-snakeoil.pem"
		$certificate_key = "ssl-cert-snakeoil.key"
	}
	elsif ( $generate_certificate == "letsencrypt" ) {
		$certificate = "fullchain.pem"
		$certificate_key = "privkey.pem"
	}
	else {
		$certificate = "my-seed-cert.pem"
		$certificate_key = "my-seed-cert.key"
	}

	$maildb_user = 'mail'
	$maildb_name = 'mail'
	$maildb_pwd = get_password("/root/.mail.pwd")

	$mailadmin_user = "admin@$mail_server_name"
	$mailadmin_pwd = get_password("/root/.mailadmin.pwd")

	$roundcube_user = 'roundcube'
	$roundcube_name = 'roundcube'
	$roundcube_pwd = get_password("/root/.roundcube.pwd")

	$rainloop_user = 'rainloop'
	$rainloop_name = 'rainloop'
	$rainloop_pwd = get_password("/root/.rainloop.pwd")

	$ajenti_user = 'root'
	$ajenti_pwd  = get_password("/root/.ajenti.pwd")

	$vimbadmin_salt1 = get_password("/root/.vimbadmin_salt1.pwd", 64)
	$vimbadmin_salt2 = get_password("/root/.vimbadmin_salt2.pwd", 64)
	$vimbadmin_salt3 = get_password("/root/.vimbadmin_salt3.pwd", 64)

	$restore_maildb_backup = "false"
	
	# Number of processors to use for amavis (less means less memory, more means more emails at a time)
	$amavis_process_count = 2

	# Maximum allowed email size.
	$message_size_limit = 10240000

	$backup_user_allowed_key = ""
}

class packages {

	# nginx (www)
	package { "apache2": 		ensure => absent }
	->
	exec { "autoremove" :
		user        => "root",
		path  => ["/usr/bin/","/usr/sbin/","/bin"],
		command     => "sudo apt-get autoremove --purge -y",
		refreshonly => true
	}
	->
	package { "nginx": 		ensure => present }
	->
	package { "apache2-utils": 	ensure => present }

	# php
	package { "php5-fpm": 		ensure => present }
	package { "php-apc": 		ensure => present, require => Package["php5-fpm"], }
	package { "php5-mcrypt": 	ensure => present, require => Package["php5-fpm"], }
	package { "php5-curl": 		ensure => present, require => Package["php5-fpm"], }
	package { "php5-gd": 		ensure => present, require => Package["php5-fpm"], }
	package { "php-xml-parser": 	ensure => present, require => Package["php5-fpm"], }
	package { "php5-mysql": 	ensure => present, require => Package["php5-fpm"], }
	package { "php5-imap": 		ensure => present, require => Package["php5-fpm"], }

	# database server
	#package { "mariadb-client": 	ensure => absent }
	#package { "mariadb-server": 	ensure => present }

	# database server
	package { "mysql-server":	ensure => present }
	package { "mysql-client":	ensure => present }

	# postfix (smtp)
	package { "postfix": 		ensure => present }
	package { "postfix-mysql": 	ensure => present, require => Package["postfix"], }

	package { "postgrey": 		ensure => present }
	package { "amavis": 		ensure => present }
	package { "clamav": 		ensure => present }
	package { "clamav-daemon": 	ensure => present }
	package { "spamassassin": 	ensure => present }

	# Random stuff needed by spam/virtus scanners
	package { "pyzor": 		ensure => present }
	package { "razor": 		ensure => present }
	package { "arj": 		ensure => present }
	package { "cabextract": 	ensure => present }
	package { "lzop": 		ensure => present }
	package { "nomarch": 		ensure => present }
	package { "p7zip-full": 	ensure => present }
	package { "ripole": 		ensure => present }
	package { "rpm2cpio": 		ensure => present }
	package { "tnef": 		ensure => present }
	package { "unzip": 		ensure => present }
	package { "unrar-free": 	ensure => present }
	package { "zip": 		ensure => present }
	package { "zoo": 		ensure => present }

	# Dovecot (imap)
	package { "dovecot-core": 		ensure => present }
	package { "dovecot-imapd": 		ensure => present }
	package { "dovecot-pop3d": 		ensure => present }
	package { "dovecot-lmtpd": 		ensure => present }
	package { "dovecot-mysql": 		ensure => present }
	package { "dovecot-sieve": 		ensure => present }
	package { "dovecot-managesieved": 	ensure => present }

	# ssl helpers to make dummy certs
	package { "ssl-cert":			ensure => present }

	# support utilites
	package { "git-core":			ensure => present }
	package { "subversion":			ensure => present }
	package { "rsyslog": 			ensure => present }
	package { "openssh-server":		ensure => present }
	package { "openssh-blacklist":		ensure => present, require => Package["openssh-server"], }
	package { "openssh-blacklist-extra":	ensure => present, require => Package["openssh-server"], }
	package { "sudo":			ensure => present }

	# DKIM
	package { "opendkim":			ensure => present }
	package { "opendkim-tools":		ensure => present }

	# ajenti
	package { "build-essential":		ensure => present }
	package { "python-pip":			ensure => present }
	package { "python-dev":			ensure => present }
	package { "python-dbus":		ensure => present }
	package { "python-lxml":		ensure => present }
	package { "libffi-dev":			ensure => present }
	package { "libssl-dev":			ensure => present }
	package { "libjpeg-dev":		ensure => present }
	package { "libpng-dev":			ensure => present }
	package { "uuid-dev":			ensure => present }
	package { "gcc":			ensure => present }

	## letsencrypt
	## duplicate entries are commented
	#package { "python":			ensure => present }
	#package { "python-dev":		ensure => present }
	package { "virtualenv":			ensure => present }
	package { "python-virtualenv":		ensure => present }
	#package { "gcc":			ensure => present }
	package { "dialog":			ensure => present }
	package { "libaugeas0":			ensure => present }
	package { "augeas-lenses":		ensure => present }
	#package { "libssl-dev":		ensure => present }
	#package { "libffi-dev":		ensure => present }
	package { "ca-certificates":		ensure => present }

	# Update before
	exec { "apt-update":
		command => "/usr/bin/apt-get update"
	}
	#Exec["apt-update"]	-> Package <| |>
}

class services {
	service { "nginx":
		ensure  => "running",
		enable  => "true",
		require => Package["nginx"],
	}
	service { "mysql":
		ensure  => "running",
		enable  => "true",
		require => Package["mysql-server"],
	}
	service { "dovecot":
		ensure  => "running",
		enable  => "true",
		require => Package["dovecot-core"],
	}
	service { "spamassassin":
		ensure  => "running",
		enable  => "true",
		require => Package["spamassassin"],
	}
	service { "amavis":
		ensure  => "running",
		enable  => "true",
		require => [ Package["amavis"], File["/etc/mailname"] ],
	}
	service { "postfix":
		ensure  => "running",
		enable  => "true",
		require => Package["postfix"],
	}
	service { "clamav-daemon":
		ensure  => "running",
		enable  => "true",
		require => Package["clamav-daemon"],
	}
	service { "php5-fpm":
		ensure  => "running",
		enable  => "true",
		require => Package["php5-fpm"],
	}
	service { "ssh":
		ensure  => "running",
		enable  => "true",
		require => Package["openssh-server"],
	}
	service { "rsyslog":
		ensure  => "running",
		enable  => "true",
		require => Package["rsyslog"],
	}
}

class swap {
	exec { 'Create swap file':
		command => "/usr/bin/fallocate -l 4G /swapfile",
		creates => "/swapfile",
	}
	exec { 'Attach swap file':
		command => "/sbin/mkswap /swapfile && /sbin/swapon /swapfile",
		require => Exec['Create swap file'],
		unless  => "/sbin/swapon -s | grep /swapfile",
		notify  => Service["clamav-daemon"],
	}
}

class config_host {
	include config

	$mail_server_name = $config::mail_server_name
	$alias            = regsubst($mail_server_name, '^([^.]*).*$', '\1')
	
	file { '/etc/hostname':
        	ensure       => present,
		owner        => 'root',
		group        => 'root',
		mode         => 644,
		content      => "${mail_server_name}\n",
	} ->
	exec { "update-hostname":
		unless       => "/usr/bin/test \"`/bin/hostname --fqdn`\" == \"${mail_server_name}\"",
		command      => "/bin/hostname \"${mail_server_name}\"",
		logoutput    => "on_failure",
	} ->
	file { '/etc/mailname':
		ensure       => present,
		owner        => 'root',
		group        => 'root',
		mode         => 644,
		content      => "${mail_server_name}\n",
	}
	host { "${mail_server_name}":
		ip           => '127.0.0.1',
		host_aliases => "$alias",
	}
}

class config_firewall {
	include ufw
	ufw::allow { 'firewall http':
		port  => 80,
	}
	ufw::allow { 'firewall http2':
		port  => 8000,
	}
	ufw::allow { 'firewall https':
		port  => 443,
	}
	ufw::allow { 'firewall https2':
		port  => 444,
	}
	ufw::allow { 'firewall ssh':
		port  => 22,
	}
	ufw::allow { 'smtp':
		port  => 25,
	}
	ufw::allow { 'smtps':
		port  => 465,
	}
	ufw::allow { 'imap':
		port  => 143,
	}
	ufw::allow { 'imaps':
		port  => 993,
	}
	ufw::allow { 'pop3':
		port  => 110,
	}
	ufw::allow { 'pop3s':
		port  => 995,
	}
}

class config_php {
	include stdlib

	file_line { 'fix_pathinfo php security':
		path	=> '/etc/php5/fpm/php.ini',
		line	=> 'cgi.fix_pathinfo = 0',
		match	=> '^.*fix_pathinfo=.*$',
		require	=> Package['php5-fpm'],
	}
	file_line { 'increase file upload size 1':
		path	=> '/etc/php5/fpm/php.ini',
		line	=> 'upload_max_filesize = 20M',
		match	=> '^.*upload_max_filesize =.*$',
		require	=> Package['php5-fpm'],
	}
	file_line { 'increase file upload size 2':
		path	=> '/etc/php5/fpm/php.ini',
		line	=> 'post_max_size = 20M',
		match	=> '^.*post_max_size =.*$',
		require	=> Package['php5-fpm'],
	}
	file_line { 'increase file memory':
		path	=> '/etc/php5/fpm/php.ini',
		line	=> 'memory_limit = 256M',
		match	=> '^.*memory_limit =.*$',
		require	=> Package['php5-fpm'],
	}
	file_line { 'increase execution time':
		path	=> '/etc/php5/fpm/php.ini',
		line	=> 'max_execution_time = 180',
		match	=> '^.*max_execution_time =.*$',
		require	=> Package['php5-fpm'],
	}
}

class make_certificate {
	include config
	include $::letsencrypt
	include packages

	$generate_certificate = $config::generate_certificate
	$files = $config::files
	if $generate_certificate == "true" {
		exec { "make-ssl-cert":
			command		=> "/usr/sbin/make-ssl-cert generate-default-snakeoil --force-overwrite",
			creates		=> [ "/etc/ssl/certs/ssl-cert-snakeoil.pem", "/etc/ssl/private/ssl-cert-snakeoil.key" ],
			require		=> Package["ssl-cert"],
			logoutput	=> "on_failure",
		} ~> Service['nginx']
	}
	elsif $generate_certificate == "letsencrypt" {
                $certificate		= $config::certificate
                $certificate_key	= $config::certificate_key

		exec { "stop nginx":
			command => '/usr/sbin/service nginx stop',
			onlyif  => '/usr/sbin/service nginx status',
		} ->
		file { "/tmp/letsencrypt":
			ensure  => directory,
			require => Class["packages"]
		} ->
		class { ::letsencrypt:
			config => {
 				email	=> "admin@${config::mail_server_name}",
				server	=> "https://acme-${config::cert_type}.api.letsencrypt.org/directory",
			},
			install_method => 'package',
			configure_epel => false,
		} ->
		letsencrypt::certonly { "${config::mail_server_name}":
				domains => ["${config::mail_server_name}", "${config::web_server_name}"],
			
				#webroot_paths quantity must be same number of domains
				#webroot_paths   => ['/tmp/letsencrypt', '/tmp/letsencrypt'],
				plugin  => 'standalone',
		} ->
		
	        file { "/etc/ssl/certs/$certificate":
                        ensure  => link,
			links	=> follow,
                        source  => "/etc/letsencrypt/live/${config::mail_server_name}/$certificate",
                } ->
                file { "/etc/ssl/private/$certificate_key":
                        ensure  => link,
			links	=> follow,
                        source  => "/etc/letsencrypt/live/${config::mail_server_name}/$certificate_key",
                } ~> Service['nginx']
	}
	else {
		$certificate		= $config::certificate
		$certificate_key	= $config::certificate_key
		file { "/etc/ssl/certs/$certificate":
			ensure	=> present,
			source	=> "${files}/ssl/$certificate",
		}
		file { "/etc/ssl/private/$certificate_key":
			ensure	=> present,
			source	=> "${files}/ssl/$certificate_key",
			mode	=> 600,
		} ~> Service['nginx']
	} 
}

class nginx_config {
	include config

	$web_server_name 	= $config::web_server_name
	$certificate 		= $config::certificate
	$certificate_key 	= $config::certificate_key
	$mail_server_name 	= $config::mail_server_name

	file { "/etc/nginx/sites-available/${web_server_name}":
		ensure	=> present,
		content	=> template("custom/nginx.web_server_name.erb"),
		require	=> Package["nginx"],
		notify	=> Service["nginx"],
	}->
	file { "/etc/nginx/sites-enabled/${web_server_name}":
		ensure	=> link,
		target	=> "/etc/nginx/sites-available/${web_server_name}",
		notify	=> Service["nginx"],
	}

}

class configure_maildb {
	include config

	$maildb_user 	= $config::maildb_user
	$maildb_pwd 	= $config::maildb_pwd
	$maildb_name 	= $config::maildb_name

	exec { "create-${maildb_name}-db":
		unless  => "/usr/bin/mysql -uroot ${maildb_name}",
		command => "/usr/bin/mysql -uroot -e \"create database ${maildb_name}\"",
		require => Service["mysql"],
		logoutput => "on_failure",
	}->
	exec { "create-${maildb_user}-db-user":
		unless  => "/usr/bin/mysql -u${maildb_user} -p'${maildb_pwd}' ${maildb_name} -e \"quit\"",
		command => "/usr/bin/mysql -uroot -e \"grant all on ${maildb_name}.* to '${maildb_user}'@'localhost' identified by '$maildb_pwd';\"",
		require => Service["mysql"],
		logoutput => "on_failure",
	}
}

class configure_webadmin {
	include config
	include stdlib
	$vimbadmin_salt1 	= $config::vimbadmin_salt1
	$vimbadmin_salt2 	= $config::vimbadmin_salt2
	$vimbadmin_salt3 	= $config::vimbadmin_salt3

	$maildb_user 		= $config::maildb_user
	$maildb_pwd 		= $config::maildb_pwd
	$maildb_name 		= $config::maildb_name

	$mailadmin_user 	= $config::mailadmin_user
	$mailadmin_pwd 		= $config::mailadmin_pwd

	$web_server_name 	= $config::web_server_name
	$certificate 		= $config::certificate
	$certificate_key 	= $config::certificate_key
	$mail_server_name 	= $config::mail_server_name

	Exec {
		logoutput => "on_failure",
	}

	# check if directory exists
	file { "/usr/local/bin":
		ensure	=> directory,
	} ->
	exec { "download_composer":
		command	=> "/usr/bin/curl -sS -O https://getcomposer.org/composer.phar > /tmp/composer.phar",
		creates	=> "/tmp/composer.phar",
		require	=> Package['php5-fpm'],
		cwd	=> '/tmp',
	} ->
	file { "/usr/local/bin/composer.phar":
		ensure	=> present,
		source	=> "/tmp/composer.phar",
		group	=> 'staff',
		mode	=> '0755',
	} ->
	exec { "clone_ViMbAdmin":
		command	=> "/usr/bin/git clone https://github.com/opensolutions/ViMbAdmin.git vimbadmin",
		creates	=> "/usr/local/vimbadmin",
		cwd	=> '/usr/local',
		require	=> [ Package['git-core'], File["/usr/local/bin/composer.phar"], ],
		notify	=> Exec['chown_ViMbAdmin'],
	} ->
	exec { "install ViMbAdmin":
		command	=> "/usr/bin/php /usr/local/bin/composer.phar install --no-interaction",
		environment	=> ["COMPOSER_HOME=/usr/local/vimbadmin"],
		cwd	=> '/usr/local/vimbadmin',
	} ->
	file { "/usr/local/vimbadmin/public/.htaccess":
		ensure	=> present,
		source	=> "/usr/local/vimbadmin/public/.htaccess.dist",
		mode	=> '0644',
	} ->
	exec { "chown_ViMbAdmin":
		command	=> "/bin/chown www-data:www-data -R /usr/local/vimbadmin/var",
	} ->
	file { "/usr/local/vimbadmin/application/configs/application.ini":
		ensure	=> present,
		replace	=> false,
		source	=> "/usr/local/vimbadmin/application/configs/application.ini.dist",
	} ->
	file_line { 'vimbadmin_salt1 application.ini':
		path	=> '/usr/local/vimbadmin/application/configs/application.ini',
		line	=> "securitysalt=\"$vimbadmin_salt1\"",
		match	=> '^securitysalt.*=.*$',
	} ->
	file_line { '2 application.ini':
		path	=> '/usr/local/vimbadmin/application/configs/application.ini',
		line	=> "resources.auth.oss.rememberme.salt=\"$vimbadmin_salt2\"",
		match	=> '^resources.auth.oss.rememberme.salt.*=.*$',
	} ->
	file_line { 'vimbadmin_salt3 application.ini':
		path	=> '/usr/local/vimbadmin/application/configs/application.ini',
		line	=> "defaults.mailbox.password_salt=\"$vimbadmin_salt3\"",
		match	=> '^defaults.mailbox.password_salt.*=.*$',
	} ->
	file_line { 'defaults.mailbox.gid application.ini':
		path	=> '/usr/local/vimbadmin/application/configs/application.ini',
		line	=> "defaults.mailbox.gid=TODO",
		match	=> '^defaults.mailbox.gid.*=.*$',
	} ->
	file_line { 'defaults.mailbox.uid application.ini':
		path	=> '/usr/local/vimbadmin/application/configs/application.ini',
		line	=> "defaults.mailbox.uid=TODO",
		match	=> '^defaults.mailbox.uid.*=.*$',
	} ->
	file_line { 'defaults.mailbox.homedir application.ini':
		path	=> '/usr/local/vimbadmin/application/configs/application.ini',
		line	=> "defaults.mailbox.homedir='/var/vmail/'",
		match	=> '^defaults.mailbox.homedir.*=.*$',
	} ->
	file_line { 'db-driver application.ini':
		path	=> '/usr/local/vimbadmin/application/configs/application.ini',
		line	=> "resources.doctrine2.connection.options.driver='pdo_mysql'",
		match	=> '^resources.doctrine2.connection.options.driver.*=.*$',
	} ->
	file_line { 'db-name application.ini':
		path	=> '/usr/local/vimbadmin/application/configs/application.ini',
		line	=> "resources.doctrine2.connection.options.dbname='$maildb_name'",
		match	=> '^resources.doctrine2.connection.options.dbname.*=.*$',
	} ->
	file_line { 'db-user application.ini':
		path	=> '/usr/local/vimbadmin/application/configs/application.ini',
		line	=> "resources.doctrine2.connection.options.user='$maildb_user'",
		match	=> '^resources.doctrine2.connection.options.user.*=.*$',
	} ->
	file_line { 'db-pwd application.ini':
		path	=> '/usr/local/vimbadmin/application/configs/application.ini',
		line	=> "resources.doctrine2.connection.options.password='$maildb_pwd'",
		match	=> '^resources.doctrine2.connection.options.password.*=.*$',
	} ->
	file_line { 'db-hostname application.ini':
		path	=> '/usr/local/vimbadmin/application/configs/application.ini',
		line	=> "resources.doctrine2.connection.options.host='localhost'",
		match	=> '^resources.doctrine2.connection.options.host.*=.*$',
	} ->
	file_line { 'password scheme application.ini':
		path	=> '/usr/local/vimbadmin/application/configs/application.ini',
		line	=> "defaults.mailbox.password_scheme='md5'",
		match	=> '^defaults.mailbox.password_scheme.*=.*$',
	} ->
	exec { "install ViMbAdmin db":
		unless	=> "/usr/bin/mysql -uroot $maildb_name -e \"select 1 from admin;\"",
		command	=> "/usr/local/vimbadmin/bin/doctrine2-cli.php orm:schema-tool:create",
		environment	=> ["COMPOSER_HOME=/usr/local/vimbadmin"],
		cwd		=> '/usr/local/vimbadmin',
		logoutput	=> 'true'
	} ->
	file { "/etc/nginx/sites-available/${mail_server_name}":
		ensure	=> present,
		content	=> template("custom/nginx.mail_server_name.erb"),
		require	=> Package["nginx"],
		notify	=> Service["nginx"],
	} ->
	file { "/etc/nginx/sites-enabled/${mail_server_name}":
		ensure	=> link,
		target	=> "/etc/nginx/sites-available/${mail_server_name}",
		notify	=> Service["nginx"],
	} ->
	exec { "force restart nginx":
		command	=> "/etc/init.d/nginx reload",
		refreshonly	=> true,
		require	=> Service["nginx"],
	} ->
	exec { "configure admin":
		command	=> "/usr/bin/curl --insecure --data 'salt=${vimbadmin_salt1}&username=${mailadmin_user}&password=${mailadmin_pwd}' https://127.0.0.1:444/auth/setup --max-time 10",
		onlyif	=> "/usr/bin/test \"`/usr/bin/mysql --raw -uroot $maildb_name -e 'select count(1) from admin' --batch -s`\" == \"0\"",
		returns	=> [0, 28],
		require	=> Service["nginx"],
	}
}

class restore_maildb_backup {
	include config

	$files 			= $config::files
	$restore_maildb_backup 	= $config::restore_maildb_backup
	$maildb_name 		= $config::maildb_name

	if $restore_maildb_backup == "true" {
		file { "/tmp/domain.csv":
			ensure	=> present,
			source	=> "${files}/backup/domain.csv",
		} ->
		exec { "restore backup: domain":
			command	=> "/usr/bin/mysql -uroot $maildb_name -e \"LOAD DATA INFILE '/tmp/domain.csv' INTO TABLE domain FIELDS TERMINATED BY ',';\"",
			onlyif	=> "/usr/bin/test `/usr/bin/mysql --raw -uroot $maildb_name -e 'select count(1) from domain' --batch -s` == \"0\"",
			require	=> Service["mysql"],
		}
		file { "/tmp/mailbox.csv":
			ensure	=> present,
			source	=> "${files}/backup/mailbox.csv",
		} ->
		exec { "restore backup: mailbox":
			command	=> "/usr/bin/mysql -uroot $maildb_name -e \"LOAD DATA INFILE '/tmp/mailbox.csv' INTO TABLE mailbox FIELDS TERMINATED BY ',';\"",
			onlyif	=> "/usr/bin/test `/usr/bin/mysql --raw -uroot $maildb_name -e 'select count(1) from mailbox' --batch -s` == \"0\"",
			require	=> Service["mysql"],
		}
		file { "/tmp/alias.csv":
			ensure	=> present,
			source	=> "${files}/backup/alias.csv",
		} ->
		exec { "restore backup: alias":
			command	=> "/usr/bin/mysql -uroot $maildb_name -e \"LOAD DATA INFILE '/tmp/alias.csv' INTO TABLE alias FIELDS TERMINATED BY ',';\"",
			onlyif	=> "/usr/bin/test `/usr/bin/mysql --raw -uroot $maildb_name -e 'select count(1) from alias' --batch -s` == \"0\"",
			require	=> Service["mysql"],
		}
		file { "/tmp/log.csv":
			ensure	=> present,
			source	=> "${files}/backup/log.csv",
		} ->
		exec { "restore backup: log":
			command	=> "/usr/bin/mysql -uroot $maildb_name -e \"LOAD DATA INFILE '/tmp/log.csv' INTO TABLE log FIELDS TERMINATED BY ',';\"",
			onlyif	=> "/usr/bin/test `/usr/bin/mysql --raw -uroot $maildb_name -e 'select count(1) from log' --batch -s` == \"0\"",
			require	=> Service["mysql"],
		}
	}
}

class configure_mail {
	include config
	include stdlib

	$maildb_user 		= $config::maildb_user
	$maildb_pwd 		= $config::maildb_pwd
	$maildb_name 		= $config::maildb_name

	$certificate 		= $config::certificate
	$certificate_key 	= $config::certificate_key

	$mailadmin_user 	= $config::mailadmin_user
	$mailadmin_pwd 		= $config::mailadmin_pwd

	file { "/etc/rsyslog.d/33-dovecot.conf":
		ensure	=> present,
		content	=> template("custom/rsyslog-33-dovecot.conf"),
		require	=> Package["rsyslog"],
		notify	=> Service["rsyslog"],
	}

	group { "mail":
		ensure	=> present,
	}
	user { "vmail":
		ensure	=> present,
		comment	=> "Virtual maildir handler",
		uid	=> 150,
		gid	=> "mail",
		membership	=> minimum,
		shell	=> "/usr/sbin/nologin",
		home	=> "/var/vmail",
		require	=> Group["mail"],
	}
	file { '/var/vmail':
		ensure	=> directory,
		owner	=> 'vmail',
		group	=> 'mail',
		mode	=> 770,
		require => User[vmail],
	}
	file { "/etc/dovecot/dovecot-sql.conf.ext":
		ensure	=> present,
		content	=> template("custom/dovecot-sql.conf.ext.erb"),
		require	=> Package["dovecot-core"],
		notify	=> Service["dovecot"],
	}
	file_line { 'dovecot: disable_plaintext_auth':
		path	=> '/etc/dovecot/conf.d/10-auth.conf',
		line	=> "disable_plaintext_auth = yes",
		match	=> '.*disable_plaintext_auth.*=.*$',
		require	=> Package["dovecot-core"],
		notify	=> Service["dovecot"],
	}
	file_line { 'dovecot auth_mechanisms':
		path	=> '/etc/dovecot/conf.d/10-auth.conf',
		line	=> "auth_mechanisms = plain login",
		match	=> '.*auth_mechanisms.*',
		require	=> Package["dovecot-core"],
		notify	=> Service["dovecot"],
	}
	file_line { 'dovecot: disable system':
		path	=> '/etc/dovecot/conf.d/10-auth.conf',
		line	=> "#!include auth-system.conf.ext",
		match	=> '.*include auth-system.conf.ext$',
		require	=> Package["dovecot-core"],
		notify	=> Service["dovecot"],
	}
	file_line { 'dovecot: enable sql':
		path	=> '/etc/dovecot/conf.d/10-auth.conf',
		line	=> "!include auth-sql.conf.ext",
		match	=> '.*include auth-sql.conf.ext$',
		require	=> Package["dovecot-core"],
		notify	=> Service["dovecot"],
	}
	file_line { 'dovecot: enable master':
		path	=> '/etc/dovecot/conf.d/10-auth.conf',
		line	=> "!include auth-master.conf.ext",
		match	=> '.*include auth-master.conf.ext$',
		require	=> Package["dovecot-core"],
		notify	=> Service["dovecot"],
	}
	file_line { 'dovecot: mail_location':
		path	=> '/etc/dovecot/conf.d/10-mail.conf',
		line	=> "mail_location = maildir:/var/vmail/%d/%n",
		match	=> '^mail_location *=.*$',
		require	=> Package["dovecot-core"],
		notify	=> Service["dovecot"],
	}
	file_line { 'dovecot: mail_uid':
		path	=> '/etc/dovecot/conf.d/10-mail.conf',
		line	=> "mail_uid = vmail",
		match	=> '.*mail_uid.*=.*$',
		require	=> Package["dovecot-core"],
		notify	=> Service["dovecot"],
	}
	file_line { 'dovecot: mail_gid':
		path	=> '/etc/dovecot/conf.d/10-mail.conf',
		line	=> "mail_gid = mail",
		match	=> '.*mail_gid.*=.*$',
		require	=> Package["dovecot-core"],
		notify	=> Service["dovecot"],
	}
	file_line { 'dovecot: first_valid_uid':
		path	=> '/etc/dovecot/conf.d/10-mail.conf',
		line	=> "first_valid_uid = 150",
		match	=> '.*first_valid_uid.*=.*$',
		require	=> Package["dovecot-core"],
		notify	=> Service["dovecot"],
	}
	file_line { 'dovecot: last_valid_uid':
		path	=> '/etc/dovecot/conf.d/10-mail.conf',
		line	=> "last_valid_uid = 150",
		match	=> '.*last_valid_uid.*=.*$',
		require	=> Package["dovecot-core"],
		notify	=> Service["dovecot"],
	}
	file_line { 'dovecot: ssl':
		path	=> '/etc/dovecot/conf.d/10-ssl.conf',
		line	=> "ssl = yes",
		match	=> '.*ssl *= *(yes|no)$',
		require	=> Package["dovecot-core"],
		notify	=> Service["dovecot"],
	}
	file_line { 'dovecot: ssl_cert':
		path	=> '/etc/dovecot/conf.d/10-ssl.conf',
		line	=> "ssl_cert = </etc/ssl/certs/$certificate",
		match	=> '.*ssl_cert *=.*$',
		require	=> Package["dovecot-core"],
		notify	=> Service["dovecot"],
	}
	file_line { 'dovecot: ssl_key':
		path	=> '/etc/dovecot/conf.d/10-ssl.conf',
		line	=> "ssl_key = </etc/ssl/private/$certificate_key",
		match	=> '.*ssl_key *=.*$',
		require	=> Package["dovecot-core"],
		notify	=> Service["dovecot"],
	}
	file_line { 'dovecot: ssl_dh_size':
		path	=> '/etc/dovecot/conf.d/10-ssl.conf',
		line	=> "ssl_dh_parameters_length = 2048",
		match	=> '.*ssl_dh_parameters_length *=.*$',
		require	=> Package["dovecot-core"],
		notify	=> Service["dovecot"],
	}
#	file_line { 'dovecot: ssl_ca':
#		path	=> '/etc/dovecot/conf.d/10-ssl.conf',
#		line	=> "ssl_ca = </etc/ssl/certs/ca-bundle.crt",
#		match	=> '^[# ]*ssl_ca *=.*$',
#		require	=> Package["dovecot-core"],
#		notify	=> Service["dovecot"],
#	}
	file { "/etc/dovecot/conf.d/10-master.conf":
		ensure	=> present,
		content	=> template("custom/10-master.conf.erb"),
		require	=> [ User[vmail], Package["dovecot-core"]],
		notify	=> Service["dovecot"],
	}
	# Create the admin user (for dovecot as well)
	exec { "create dovecot admin user":
		command	=> "/usr/bin/htpasswd -b -c -s /etc/dovecot/master-users '${mailadmin_user}' '${mailadmin_pwd}'",
		logoutput	=> "on_failure",
		require	=> Package["apache2-utils"],
		creates	=> "/etc/dovecot/master-users",
	}

}

class chown_dovecot_config {
	exec { "chown dovecot config":
		command		=> "/bin/chown -R vmail:dovecot /etc/dovecot",
		logoutput	=> "on_failure",
	}
	exec { "chmod dovecot config":
		command		=> "/bin/chmod -R o-rwx /etc/dovecot",
		logoutput       => "on_failure",
	}
}

class configure_spamav {
	include config
	include stdlib

	$maildb_user			= $config::maildb_user
	$maildb_pwd			= $config::maildb_pwd
	$maildb_name			= $config::maildb_name

	$amavis_process_count	= $config::amavis_process_count

	file { "/etc/amavis/conf.d/15-content_filter_mode":
		ensure	=> present,
		content	=> template("custom/15-content_filter_mode.erb"),
		require	=> Package[amavis],
		notify	=> Service["amavis"],
	}
	file_line { 'spamassasin: enable':
		path	=> '/etc/default/spamassassin',
		line	=> "ENABLED=1",
		match	=> '^ENABLED=.*$',
		require	=> Package["spamassassin"],
		notify	=> Service["spamassassin"],
	}
	file_line { 'spamassasin: updates':
		path	=> '/etc/default/spamassassin',
		line	=> "CRON=1",
		match	=> '^CRON=.*$',
		require	=> Package["spamassassin"],
		notify	=> Service["spamassassin"],
	}
	file { "/etc/amavis/conf.d/50-user":
		ensure	=> present,
		content	=> template("custom/50-user.erb"),
		require	=> Package[amavis],
		notify	=> Service["amavis"],
	}
	user {'amavis':
		groups	=> ['clamav'],
		require	=> [ Package[amavis], Package[clamav-daemon], ],
	}
	user {'clamav':
		groups	=> ['amavis'],
		require	=> [ Package[amavis], Package[clamav-daemon], ],
	}
}

class configure_postfix {
	include config

	$maildb_user			= $config::maildb_user
	$maildb_pwd			= $config::maildb_pwd
	$maildb_name			= $config::maildb_name
	$certificate			= $config::certificate
	$certificate_key		= $config::certificate_key
	$mail_server_name		= $config::mail_server_name
	$amavis_process_count	= $config::amavis_process_count
	$message_size_limit		= $config::message_size_limit

	file { "/etc/postfix/mysql_virtual_alias_maps.cf":
		owner	=> 'root',
		group	=> 'root',
		mode	=> 644,
		ensure	=> present,
		content	=> template("custom/mysql_virtual_alias_maps.cf.erb"),
		require	=> Package[postfix],
		notify	=> Service["postfix"],
	}
	file { "/etc/postfix/mysql_virtual_domains_maps.cf":
		owner	=> 'root',
		group	=> 'root',
		mode	=> 644,
		ensure	=> present,
		content	=> template("custom/mysql_virtual_domains_maps.cf.erb"),
		require	=> Package[postfix],
		notify	=> Service["postfix"],
	}
	file { "/etc/postfix/mysql_virtual_mailbox_maps.cf":
		owner	=> 'root',
		group	=> 'root',
		mode	=> 644,
		ensure	=> present,
		content	=> template("custom/mysql_virtual_mailbox_maps.cf.erb"),
		require	=> Package[postfix],
		notify	=> Service["postfix"],
	}
	file { "/etc/postfix/header_checks":
		owner	=> 'root',
		group	=> 'root',
		mode	=> 644,
		ensure	=> present,
		content	=> template("custom/header_checks.erb"),
		require	=> Package[postfix],
		notify  => Service["postfix"],
	}
	file { "/etc/postfix/master.cf":
		owner	=> 'root',
		group	=> 'root',
		mode	=> 644,
		ensure	=> present,
		content	=> template("custom/master.cf.erb"),
		require	=> Package[postfix],
		notify	=> Service["postfix"],
	}
	file { "/etc/postfix/main.cf":
		owner	=> 'root',
		group	=> 'root',
		mode	=> 644,
		ensure	=> present,
		content	=> template("custom/main.cf.erb"),
		require	=> Package[postfix],
		notify	=> Service["postfix"],
	}

}

class rainloop {
	include config

	$rainloop_user = $config::rainloop_user
	$rainloop_name = $config::rainloop_name
	$rainloop_pwd  = $config::rainloop_pwd

	exec { "create-${rainloop_name}-db":
		unless  => "/usr/bin/mysql -uroot ${rainloop_name}",
		command => "/usr/bin/mysql -uroot -e \"create database ${rainloop_name}\"",
		require => Service["mysql"],
		logoutput => "on_failure",
	}->
	exec { "create-${rainloop_user}-db-user":
		unless  => "/usr/bin/mysql -u${rainloop_user} -p'${rainloop_pwd}' ${rainloop_name} -e \"quit\"",
		command => "/usr/bin/mysql -uroot -e \"grant all on ${rainloop_name}.* to '${rainloop_user}'@'localhost' identified by '$rainloop_pwd';\"",
		require => Service["mysql"],
		logoutput => "on_failure",
	}

	# Create Directories
	file { [
		"/var/www",
		"/var/www/rainloop/",
		"/var/www/rainloop/logs",
		"/var/www/rainloop/www" ] :
		ensure => directory,
		before => Exec[	"download_rainloop" ]
	} ->
        exec { "download_rainloop":
                command => "/usr/bin/curl -sS -O http://repository.rainloop.net/installer.php > /var/www/rainloop/www/installer.php",
                creates => "/var/www/rainloop/www/installer.php",
                require => Package['php5-fpm'],
                cwd     => '/var/www/rainloop/www/',
        } ->
	file { "/var/www/rainloop/www/installer.php":
		ensure	=> present,
		before	=> Exec[ "install-rainloop" ]
	}
	exec { "install-rainloop":
		onlyif	=> "/usr/bin/test ! -d /var/www/rainloop/www/rainloop",
		cwd	=> "/var/www/rainloop/www",
		command	=> "/usr/bin/php installer.php",
		logoutput	=> "on_failure",
		require => [ Package['php5-fpm'], Package['php5-curl'], Package['php5-mcrypt'], Package['php5-mysql'], ],
	}
	#file_line { 'rainloop-change-password':
	#	path  => '/etc/default/spamassassin',
	#	line  => "ENABLED=1",
	#	match => '^ENABLED=.*$',
	#	require => Package["spamassassin"],
	#	notify  => Service["spamassassin"],
	#}
}

class ajenti {
	include config

	$ajenti_user = $config::ajenti_user
	$ajenti_pwd  = $config::ajenti_pwd

	exec { "install-ajenti":
		onlyif	=> "/usr/bin/test ! -d /etc/ajenti",
		cwd => "/root",
		command => "/usr/bin/wget -O- https://raw.githubusercontent.com/ajenti/ajenti/master/scripts/install.sh | sh",
		logoutput => "on_failure",
	}
}

class backup_user {
	include config

	$backup_user_allowed_key = $config::backup_user_allowed_key

	$maildb_user 	= $config::maildb_user
	$maildb_pwd 	= $config::maildb_pwd
	$maildb_name 	= $config::maildb_name

	group { "backup":
		ensure => present,
	}
	user { "backup":
		ensure		=> present,
		comment		=> "(Mail) Backup user",
		membership	=> minimum,
		gid		=> 'backup',
		shell		=> "/bin/bash",
		home		=> "/home/backup",
		require		=> [Group["mail"], Group["backup"]],
	}
	file { '/home/backup':
		ensure	=> directory,
		owner	=> 'backup',
		group	=> 'backup',
		mode	=> 770,
		require	=> User[backup],
    }

	if $backup_user_allowed_key == "" {
		ssh_keygen { 'vmail':
			home => '/var/vmail'
		}
		ssh_keygen { 'backup': }
	} else {
		ssh_keygen { 'vmail':
			home => '/var/vmail'
		}
		ssh_keygen { 'backup': }
		->
		file { "/home/backup/.ssh/authorized_keys":
			ensure	=> present,
			owner	=> 'backup',
			group	=> 'backup',
			mode	=> 600,
			content		=> $backup_user_allowed_key
		}
	}

	file { "/etc/sudoers.d/backup-user":
		ensure		=> present,
		owner		=> 'root',
		group		=> 'root',
		mode		=> 440,
		content		=> 'backup ALL=(vmail:vmail) NOPASSWD:ALL',
		require		=> Package["sudo"]
	}
	file { "/home/backup/backup-to-this.sh":
		ensure		=> present,
		owner		=> 'backup',
		group		=> 'backup',
		mode		=> 755,
		content		=> template("custom/backup-to-this.sh.erb"),
		require		=> File["/home/backup"]
	}
	file { "/home/backup/.my.cnf":
		ensure		=> present,
		owner		=> 'backup',
		group		=> 'backup',
		mode		=> 600,
		content		=> template("custom/backup-my.cnf.erb"),
		require		=> File["/home/backup"]
	}
}

Class['apt']->Class['packages']->Class['make_certificate']->Class['nginx_config']->Class['services']

include config_host
include swap
include packages
include make_certificate
include services
include nginx_config
include configure_spamav
include configure_postfix
#include config_firewall
include config_php
include rainloop
#include ajenti
include backup_user

include apt

class { 'apt::backports':
  pin => 500,
}
apt::source { 'puppetlabs':
  location => 'http://apt.puppetlabs.com',
  repos    => 'main',
  key      => {
    'id'     => '47B320EB4C7C375AA9DAE1A01054B7A24BD6EC30',
    'server' => 'pgp.mit.edu',
  },
}


class {'configure_maildb':}
->
class {'configure_webadmin':}
->
class {'restore_maildb_backup':}

class {'configure_mail':}
->
class {'chown_dovecot_config':}

