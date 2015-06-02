#

node 'default' {
  include oradb_os
  include oradb_11g
  include oradb_configuration
}

# operating system settings for Database
class oradb_os {

  $groups = ['oinstall','dba' ,'oper' ]

  group { $groups :
    ensure      => present,
  }

  user { 'oracle' :
    ensure      => present,
    uid         => 500,
    gid         => 'oinstall',
    groups      => $groups,
    shell       => '/bin/bash',
    password    => '$1$DSJ51vh6$4XzzwyIOk6Bi/54kglGk3.',
    home        => "/home/oracle",
    comment     => "This user oracle was created by Puppet",
    require     => Group[$groups],
    managehome  => true,
  }

  $install = [ 'binutils.x86_64', 'compat-libstdc++-33.x86_64', 'glibc.x86_64','ksh.x86_64','libaio.x86_64',
               'libgcc.x86_64', 'libstdc++.x86_64', 'make.x86_64','compat-libcap1.x86_64', 'gcc.x86_64',
               'gcc-c++.x86_64','glibc-devel.x86_64','libaio-devel.x86_64','libstdc++-devel.x86_64',
               'sysstat.x86_64','unixODBC-devel','glibc.i686','libXext.x86_64','libXtst.x86_64','unzip','python-pip']


  package { $install:
    ensure  => present,
  }

  class { 'limits':
     config => {
                '*'       => { 'nofile'  => { soft => '2048'   , hard => '8192',   },},
                'oracle'  => { 'nofile'  => { soft => '65536'  , hard => '65536',  },
                                'nproc'  => { soft => '2048'   , hard => '16384',  },
                                'stack'  => { soft => '10240'  ,},},
                },
     use_hiera => false,
  }

}

class oradb_11g {
  require oradb_os

    oradb::installdb{ '11.2.0.4_Linux-x86-64':
      version                => '11.2.0.4',
      file                   => 'p13390677_112040_Linux-x86-64',
      databaseType           => 'SE',
      oracleBase             => '/oracle',
      oracleHome             => '/oracle/product/11.2/db',
      userBaseDir            => '/home',
      bashProfile            => false,
      user                   => 'oracle',
      group                  => 'dba',
      group_install          => 'oinstall',
      group_oper             => 'oper',
      downloadDir            => "/var/tmp/install",
      remoteFile             => false,
      puppetDownloadMntPoint => '/software',
    }

    oradb::net{ 'config net':
      oracleHome   => '/oracle/product/11.2/db',
      version      => '11.2',
      user         => 'oracle',
      group        => 'dba',
      downloadDir  => "/var/tmp/install",
      require      => Oradb::Installdb['11.2.0.4_Linux-x86-64'],
    }

    oradb::listener{'start listener':
      oracleBase   => '/oracle',
      oracleHome   => '/oracle/product/11.2/db',
      user         => 'oracle',
      group        => 'dba',
      action       => 'start',
      require      => Oradb::Net['config net'],
    }

    oradb::database{ 'oraDb':
      oracleBase              => '/oracle',
      oracleHome              => '/oracle/product/11.2/db',
      version                 => '11.2',
      user                    => 'oracle',
      group                   => 'dba',
      downloadDir             => "/var/tmp/install",
      action                  => 'create',
      dbName                  => 'orcl',
      dbDomain                => 'example.com',
      template                => 'custom',
      sysPassword             => 'Welcome01',
      systemPassword          => 'Welcome01',
      dataFileDestination     => "/oracle/oradata",
      recoveryAreaDestination => "/oracle/flash_recovery_area",
      characterSet            => "AL32UTF8",
      nationalCharacterSet    => "UTF8",
      initParams              => "open_cursors=400,processes=200,job_queue_processes=1",
      sampleSchema            => 'FALSE',
      memoryPercentage        => "40",
      memoryTotal             => "800",
      databaseType            => "MULTIPURPOSE",
      emConfiguration         => "NONE",
      require                 => Oradb::Listener['start listener'],
    }

    oradb::dbactions{ 'start oraDb':
      oracleHome              => '/oracle/product/11.2/db',
      user                    => 'oracle',
      group                   => 'dba',
      action                  => 'start',
      dbName                  => 'orcl',
      require                 => Oradb::Database['oraDb'],
    }

    oradb::autostartdatabase{ 'autostart oracle':
      oracleHome              => '/oracle/product/11.2/db',
      user                    => 'oracle',
      dbName                  => 'soarepos',
      require                 => Oradb::Dbactions['start oraDb'],
    }

}

class oradb_configuration {
  require oradb_11g

  # tablespace {'MY_TS':
  #   ensure                    => present,
  #   size                      => 100M,
  #   datafile                  => 'my_ts.dbf',
  #   logging                   => 'yes',
  #   bigfile                   => 'yes',
  #   autoextend                => on,
  #   next                      => 100M,
  #   max_size                  => 12288M,
  #   extent_management         => local,
  #   segment_space_management  => auto,
  # }

  # role {'APPS':
  #   ensure    => present,
  # }

  # oracle_user{'TESTUSER':
  #   ensure                    => present,
  #   temporary_tablespace      => 'TEMP',
  #   default_tablespace        => 'MY_TS',
  #   password                  => 'testuser',
  #   grants                    => ['SELECT ANY TABLE',
  #                                 'CONNECT',
  #                                 'RESOURCE',
  #                                 'APPS'],
  #   quotas                    => { "MY_TS" => 'unlimited'},
  #   require                   => [Tablespace['MY_TS'],
  #                                 Role['APPS']],
  # }
}
