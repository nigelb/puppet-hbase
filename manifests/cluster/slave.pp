# /etc/puppet/modules/hbase/manifests/cluster/slave.pp

class hbase::cluster::slave {

    require hbase::params
    require hbase

}
