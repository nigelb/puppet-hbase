# /etc/puppet/modules/hbase/manafests/init.pp

class hbase {
	require hadoop
	require hbase::params
	
	if !defined(Group[$hbase::params::hadoop_group]){
		group { $hbase::params::hadoop_group:
			ensure => present,
			gid =>$hbase::params::hadoop_group_gid
		}
	}

	if !defined(User[$hbase::params::hadoop_user]){
		user { $hbase::params::hadoop_user:
			ensure => present,
			comment => "Hadoop",
			password => "!!",
			uid => $hbase::params::hadoop_user_uid,
			gid => $hbase::params::hadoop_group_gid,
			shell => "/bin/bash",
			home => $hbase::params::real_hadoop_user_path,
			require => Group[$hbase::params::hadoop_group],
		}
	}
	if !defined(File[$hbase::params::real_hadoop_user_path]){
		file { $hbase::params::real_hadoop_user_path:
			ensure => "directory",
			owner => $hbase::params::hadoop_user,
			group => $hbase::params::hadoop_group,
			alias => "${hbase::params::hadoop_user}-home",
			require => [ User[$hbase::params::hadoop_user], Group[$hbase::params::hadoop_group] ]
		}
	}
 
	file {"${hbase::params::hbase_base}":
		ensure => "directory",
		owner => "${hbase::params::hadoop_user}",
		group => "${hbase::params::hadoop_group}",
		alias => "hbase-base",
	}

 	file {"${hbase::params::real_hbase_conf}":
		ensure => "directory",
		owner => "${hbase::params::hadoop_user}",
		group => "${hbase::params::hadoop_group}",
		alias => "hbase-conf",
		require => [File["hbase-base"], Exec["untar-hbase"]],
		before => [File["hbase-site-xml"], File["hdfs-site-xml-link"], File["hbase-env-sh"]]
	}

 	file {"${hbase::params::zookeeper_dataDir}":
		ensure => "directory",
		owner => "${hbase::params::hadoop_user}",
		group => "${hbase::params::hadoop_group}",
		alias => "hbase-zookeeper-datadir",
		before => [File["hbase-site-xml"], File["hdfs-site-xml-link"], File["hbase-env-sh"]]
	}

 
	file { "${hbase::params::hbase_base}/hbase-${hbase::params::version}.tar.gz":
		mode => 0644,
		owner => "${hbase::params::hadoop_user}",
		group => "${hbase::params::hadoop_group}",
		source => "puppet:///modules/hbase/hbase-${hbase::params::version}.tar.gz",
		alias => "hbase-source-tgz",
		before => Exec["untar-hbase"],
		require => File["hbase-base"]
	}
	
	exec { "untar hbase-${hbase::params::version}.tar.gz":
		command => "tar xfvz hbase-${hbase::params::version}.tar.gz",
		cwd => "${hbase::params::hbase_base}",
		creates => "${hbase::params::hbase_base}/hbase-${hbase::params::version}",
		alias => "untar-hbase",
		refreshonly => true,
		subscribe => File["hbase-source-tgz"],
		user => "${hbase::params::hadoop_user}",
		before => [ File["hbase-symlink"], File["hbase-app-dir"]],
        	path    => ["/bin", "/usr/bin", "/usr/sbin"],
	}

	file { "${hbase::params::hbase_base}/hbase-${hbase::params::version}":
		ensure => "directory",
		mode => 0644,
		owner => "${hbase::params::hadoop_user}",
		group => "${hbase::params::hadoop_group}",
		alias => "hbase-app-dir",
	        require => Exec["untar-hbase"],
	}

	file { "/etc/hbase":
		force => true,
		ensure => "link",
		target => "${hbase::params::hbase_base}/hbase-${hbase::params::version}/conf",
		alias => "etc-hbase-symlink",
		owner => $hbase::params::hadoop_user,
		group => $hbase::params::hadoop_group,
		require => File["hbase-app-dir"],
	}
	file { "/var/log/hbase":
		force => true,
		ensure => "link",
		target => "${hbase::params::hbase_base}/hbase-${hbase::params::version}/logs",
		alias => "log-hbase-symlink",
		owner => $hbase::params::hadoop_user,
		group => $hbase::params::hadoop_group,
		require => File["hbase-app-dir"],
	}
		
	file { "${hbase::params::hbase_base}/hbase":
		force => true,
		ensure => "${hbase::params::hbase_base}/hbase-${hbase::params::version}",
		alias => "hbase-symlink",
		owner => "${hbase::params::hadoop_user}",
		group => "${hbase::params::hadoop_group}",
		require => File["hbase-source-tgz"],
		before => [ File["hbase-site-xml"], File["hdfs-site-xml-link"], File["hbase-env-sh"], File["hbase-logging-conf"]]
	}
	
	file { "${hbase::params::hbase_base}/hbase-${hbase::params::version}/conf/hbase-site.xml":
		owner => "${hbase::params::hadoop_user}",
		group => "${hbase::params::hadoop_group}",
		mode => "644",
		alias => "hbase-site-xml",
		content => template("hbase/conf/hbase-site.xml.erb"),
	}
	file { "${hbase::params::hbase_base}/hbase-${hbase::params::version}/conf/log4j.properties":
		owner => $hbase::params::hadoop_user,
		group => $hbase::params::hadoop_group,
		mode => "644",
		alias => "hbase-logging-conf",
		source => "puppet:///modules/hbase/conf/log4j.properties",
	}

	file { "${hbase::params::hbase_base}/hbase-${hbase::params::version}/conf/hdfs-site.xml":
		owner => "${hbase::params::hadoop_user}",
		group => "${hbase::params::hadoop_group}",
		mode => "644",
		alias => "hdfs-site-xml-link",
		ensure => link,
		target => "${hbase::params::real_hadoop_conf}/hdfs-site.xml",
	}
 
	file { "${hbase::params::hbase_base}/hbase-${hbase::params::version}/conf/hbase-env.sh":
		owner => "${hbase::params::hadoop_user}",
		group => "${hbase::params::hadoop_group}",
		mode => "644",
		alias => "hbase-env-sh",
		content => template("hbase/conf/hbase-env.sh.erb"),
	}
	
	file { "${hbase::params::hbase_base}/hbase-${hbase::params::version}/conf/regionservers":
		owner => "${hbase::params::hadoop_user}",
		group => "${hbase::params::hadoop_group}",
		mode => "644",
		alias => "hbase-slave",
		content => template("hbase/conf/regionservers.erb"),
	}

#    file { "${hbase::params::hbase_base}/hbase-${hbase::params::version}/lib/hadoop-core-1.0.4.jar":
#        ensure => absent,
#        require => [File["hbase-base"], Exec["untar-hbase"]],
#    }
#
#    file { "${hbase::params::hbase_base}/hbase-${hbase::params::version}/lib/hadoop-jar.tar.gz":
#        ensure => present,
#        owner => "${hbase::params::hadoop_user}",
#        group => "${hbase::params::hadoop_group}",
#        mode => 0644,
#        alias => "hadoop-jars",
#        source => "puppet:///modules/hbase/lib/hadoop-jar.tar.gz",
# 		before => Exec["untar-hadoop-jars"],
#		require => [File["hbase-base"], Exec["untar-hbase"]],
#    }
# 
#	exec { "untar hadoop-jars":
#		command => "tar xfvz hadoop-jar.tar.gz",
#		cwd => "${hbase::params::hbase_base}/hbase-${hbase::params::version}/lib",
#		alias => "untar-hadoop-jars",
#		refreshonly => true,
#		subscribe => File["hadoop-jars"],
#		user => "${hbase::params::hadoop_user}",
#		require => File["hadoop-jars"],
#        path    => ["/bin", "/usr/bin", "/usr/sbin"],
#	}
 
 	file { "/etc/security/limits.conf":
		owner => "root",
		group => "root",
		mode => "644",
		alias => "limit-conf",
		content => template("hbase/etc/limits.conf.erb"),
	}

 	file { "/etc/pam.d/common-session":
		owner => "root",
		group => "root",
		mode => "644",
		alias => "common-session",
		content => template("hbase/etc/common-session.erb"),
	}
    
}
