# /etc/puppet/modules/hbase/manafests/params.pp

class hbase::params ( 
	$version =  "0.95-SNAPSHOT",
 	$hadoop_user =  "hadoop",
 	$hadoop_user_uid =  800,
 	$hadoop_group =  "hadoop",
 	$hadoop_group_gid =  800,
	$master = "master.hadoop",
	$slaves = ["slave01.hadoop", "slave02.hadoop"] ,
    	$namenode =  "UNSET",
	$hdfsport = 8020,
	$rootdir = "hbase",
	$java_home = "/usr/lib/jvm/java",
	$hadoop_base = "/opt/hadoop",
	$hadoop_conf = "UNSET",
	$hbase_base = "/opt/hbase",
	$hbase_conf = "UNSET",
    	$hadoop_user_path = "UNSET"
)
{
	if $namenode == "UNSET" {
		$real_namenode = $master
	}else{
		$real_namenode = $namenode
	}

	if $hadoop_conf == "UNSET" {
		$real_hadoop_conf = "${hadoop_base}/hadoop/conf"
	}else{
		$real_hadoop_conf = $hadoop_conf
	}

	if $hbase_conf == "UNSET"{
		$real_hbase_conf = "${hbase_base}/hbase/conf"
	}else{
		$real_hbase_conf = $hbase_conf
	}

	if $hadoop_user_path == "UNSET"{
		$real_hadoop_user_path = "/home/${hadoop_user}"
	}else{
		$real_hadoop_user_path = $hadoop_user_path
	}

	
		
}
