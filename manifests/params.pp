# /etc/puppet/modules/hbase/manafests/params.pp

class hbase::params ( 
	$version =  "0.95-SNAPSHOT",
 	$hadoop_user =  "hduser",
 	$hadoop_group =  "hadoop",
	$master = "master.hadoop",
	$slaves = ["slave01.hadoop", "slave02.hadoop"] 
    	$namenode =  "${master}",
	$hdfsport = "8020",
	$rootdir = "hbase",
	$java_home = "${java::params::java_base}/jdk${java::params::java_version}",
	$hadoop_base = "/opt/hadoop",
	$hadoop_conf = "${hadoop_base}/hadoop/conf",
	$hbase_base = "/opt/hbase",
	$hbase_conf = "${hbase_base}/hbase/conf",
    	$hadoop_user_path = "/home/${hadoop_user}",
{
	include java::params
}
