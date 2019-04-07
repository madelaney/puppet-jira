# -----------------------------------------------------------------------------
#   Copyright (c) 2012 Bryce Johnson
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
# -----------------------------------------------------------------------------
# == Class: jira
#
# This module is used to install Jira.
#
# See README.md for more details
#
# === Authors
#
# Bryce Johnson
# Merritt Krakowitzer
#
# === Copyright
#
# Copyright (c) 2012 Bryce Johnson
#
# Published under the Apache License, Version 2.0
#
class jira (
  String $version,
  String $format,
  Stdlib::Absolutepath $installdir,
  Stdlib::Absolutepath $homedir,
  Boolean $manage_user,
  String $user,
  String $group,
  Optional[Integer] $uid = undef,
  Optional[Integer] $gid = undef,
  Stdlib::Absolutepath $shell,
  Hash $config_properties,
  Boolean $datacenter,
  Optional[String] $product,
  Enum['postgresql','mysql','sqlserver','oracle','h2'] $db,
  Optional[Stdlib::Absolutepath] $shared_homedir = undef,
  Optional[Stdlib::Host] $ehcache_listener_host = undef,
  Optional[Stdlib::Port] $ehcache_listener_port = undef,
  Optional[Stdlib::Port] $ehcache_object_port = undef,
  Optional[String] $dbuser = undef,
  Optional[String] $dbpassword = undef,
  Optional[String] $dbserver = undef,
  Optional[String] $dbname = undef,
  Optional[Integer] $dbport = undef,
  Optional[String] $dbdriver = undef,
  Optional[String] $dbtype = undef,
  Optional[String] $dburl = undef,
  Optional[Integer] $poolsize = undef,
  Optional[String] $dbschema = undef,
  Optional[Boolean] $mysql_connector_manage = undef,
  Optional[String] $mysql_connector_version = undef,
  Optional[String] $mysql_connector_product = undef,
  Optional[String] $mysql_connector_format = undef,
  Optional[Stdlib::Absolutepath] $mysql_connector_install,
  Optional[Stdlib::HTTPUrl] $mysql_connector_url = undef,
  # Configure database settings if you are pooling connections
  Optional[Boolean] $enable_connection_pooling = undef,
  Optional[Integer] $pool_min_size = undef,
  Optional[Integer] $pool_max_size = undef,
  Optional[Integer] $pool_max_wait = undef,
  Optional[String] $validation_query = undef,
  Optional[Integer] $min_evictable_idle_time = undef,
  Optional[Integer] $time_between_eviction_runs = undef,
  Optional[Integer] $pool_max_idle = undef,
  Optional[Boolean] $pool_remove_abandoned = undef,
  Optional[Integer] $pool_remove_abandoned_timeout = undef,
  Optional[Boolean] $pool_test_while_idle = undef,
  Optional[Boolean] $pool_test_on_borrow = undef,
  # JVM Settings
  Optional[String] $javahome,
  Optional[String] $jvm_xms,
  Optional[String] $jvm_xmx,
  Optional[String] $jvm_permgen,
  Optional[Array] $jvm_optional = [],
  Optional[Array] $java_opts = [],
  Optional[Array] $catalina_opts = [],
  # Misc Settings
  Optional[Stdlib::HTTPUrl] $download_url,
  Optional[String] $checksum = undef,
  Optional[Boolean] $disable_notifications = undef,
  # Choose whether to use puppet-staging, or puppet-archive
  Optional[String] $proxy_server = undef,
  Optional[Enum['none','http','https','ftp']] $proxy_type,
  # Manage service
  Optional[Boolean] $service_manage,
  Optional[Enum['running', 'stopped']] $service_ensure,
  Optional[Boolean] $service_enable,
  Optional[String] $service_notify = undef,
  Optional[String] $service_subscribe = undef,
  # Command to stop jira in preparation to updgrade. This is configurable
  # incase the jira service is managed outside of puppet. eg: using the
  # puppetlabs-corosync module: 'crm resource stop jira && sleep 15'
  Optional[String] $stop_jira,
  # Whether to manage the 'check-java.sh' script, and where to retrieve
  # the script from.
  Optional[Boolean] $script_check_java_manage,
  Optional[String] $script_check_java_template,
  # Tomcat
  Optional[String] $tomcat_address,
  Optional[Integer] $tomcat_port,
  Optional[Integer] $tomcat_shutdown_port,
  Optional[Integer] $tomcat_max_http_header_size,
  Optional[Integer] $tomcat_min_spare_threads,
  Optional[Integer] $tomcat_connection_timeout,
  Optional[Boolean] $tomcat_enable_lookups,
  Optional[Boolean] $tomcat_native_ssl,
  Optional[Integer] $tomcat_https_port,
  Optional[Integer] $tomcat_redirect_https_port = undef,
  Optional[String] $tomcat_protocol,
  Optional[String] $tomcat_protocol_ssl = undef,
  Optional[Boolean] $tomcat_use_body_encoding_for_uri,
  Optional[Boolean] $tomcat_disable_upload_timeout,
  Optional[String] $tomcat_key_alias,
  Optional[Stdlib::Absolutepath] $tomcat_keystore_file,
  Optional[String] $tomcat_keystore_pass,
  Optional[Enum['JKS', 'JCEKS', 'PKCS12']] $tomcat_keystore_type,
  Optional[String] $tomcat_accesslog_format,
  # Tomcat Tunables
  Optional[Integer] $tomcat_max_threads,
  Optional[Integer] $tomcat_accept_count,
  # Reverse https proxy
  Optional[Hash] $proxy,
  # Options for the AJP connector
  Optional[Hash] $ajp,
  # Context path (usually used in combination with a reverse proxy)
  Optional[String] $contextpath,
  # Resources for context.xml
  Optional[Hash] $resources = {},
  # Enable SingleSignOn via Crowd
  Optional[Boolean] $enable_sso,
  Optional[String] $application_name = undef,
  Optional[String] $application_password = undef,
  Variant[Stdlib::HTTPUrl, Stdlib::HTTPSUrl] $application_login_url,
  Variant[Stdlib::HTTPUrl, Stdlib::HTTPSUrl] $crowd_server_url,
  Variant[Stdlib::HTTPUrl, Stdlib::HTTPSUrl] $crowd_base_url,
  Optional[String] $session_isauthenticated = undef,
  Optional[String] $session_tokenkey = undef,
  Optional[Integer] $session_validationinterval = undef,
  Optional[String] $session_lastvalidation = undef,
  Optional[Array] $json_packages = [],
  Optional[String] $service_file_location,
  Optional[String] $service_file_template,
  Optional[String] $service_lockfile,
  Optional[String] $service_provider
) {

  Exec {
    path => ['/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/']
  }

  if $datacenter and !$shared_homedir {
    fail("\$shared_homedir must be set when \$datacenter is true")
  }

  if $tomcat_redirect_https_port {
    unless ($tomcat_native_ssl) {
      fail('You need to set native_ssl to true when using tomcat_redirect_https_port')
    }
  }

  # The default Jira product starting with version 7 is 'jira-software'
  # The default Jira product starting with version 7 is 'jira-software'
  if ((versioncmp($version, '7.0.0') > 0) and ($product == 'jira')) {
    $product_name = 'jira-software'
  }
  else {
    $product_name = $product
  }

  if defined('$::jira_version') {
    # If the running version of JIRA is less than the expected version of JIRA
    # Shut it down in preparation for upgrade.
    if versioncmp($version, $::jira_version) > 0 {
      notify { 'Attempting to upgrade JIRA': }
      exec { $stop_jira: before => Class['jira::install'] }
    }
  }

  $extractdir = "${installdir}/atlassian-${product_name}-${version}-standalone"
  if $format == zip {
    $webappdir = "${extractdir}/atlassian-${product_name}-${version}-standalone"
  } else {
    $webappdir = $extractdir
  }

  if $dbport {
    $dbport_real = $dbport
  } else {
    $dbport_real = $db ? {
      'postgresql' => 5432,
      'mysql'      => 3306,
      'oracle'     => 1521,
      'sqlserver'  => 1433,
      'h2'         => undef,
    }
  }

  if $dbdriver {
    $dbdriver_real = $dbdriver
  } else {
    $dbdriver_real = $db ? {
      'postgresql' => 'org.postgresql.Driver',
      'mysql'      => 'com.mysql.jdbc.Driver',
      'oracle'     => 'oracle.jdbc.OracleDriver',
      'sqlserver'  => 'com.microsoft.sqlserver.jdbc.SQLServerDriver',
      'h2'         => 'org.h2.Driver',
    }
  }

  if $dbtype {
    $dbtype_real = $dbtype
  } else {
    $dbtype_real = $db ? {
      'postgresql' => 'postgres72',
      'mysql'      => 'mysql',
      'oracle'     => 'oracle10g',
      'sqlserver'  => 'mssql',
      'h2'         => 'h2',
    }
  }

  if $dburl {
    $dburl_real = $dburl
  }
  else {
    $dburl_real = $db ? {
      'postgresql' => "jdbc:${db}://${dbserver}:${dbport_real}/${dbname}",
      'mysql'      => "jdbc:${db}://${dbserver}:${dbport_real}/${dbname}?useUnicode=true&amp;characterEncoding=UTF8&amp;sessionVariables=default_storage_engine=InnoDB",
      'oracle'     => "jdbc:${db}:thin:@${dbserver}:${dbport_real}:${dbname}",
      'sqlserver'  => "jdbc:jtds:${db}://${dbserver}:${dbport_real}/${dbname}",
      'h2'         => "jdbc:h2:file:/${jira::homedir}/database/${dbname}",
    }
  }

  if $tomcat_protocol_ssl {
    $tomcat_protocol_ssl_real = $tomcat_protocol_ssl
  } else {
    if versioncmp($version, '7.3.0') >= 0 {
      $tomcat_protocol_ssl_real = 'org.apache.coyote.http11.Http11NioProtocol'
    } else {
      $tomcat_protocol_ssl_real = 'org.apache.coyote.http11.Http11Protocol'
    }
  }

  if ! empty($ajp) {
    if ! ('port' in $ajp) {
      fail('You need to specify a valid port for the AJP connector.')
    } else {
      assert_type(Variant[Pattern[/^\d+$/], Stdlib::Port], $ajp['port'])
    }
    if ! ('protocol' in $ajp) {
      fail('You need to specify a valid protocol for the AJP connector.')
    } else {
      assert_type(Enum['AJP/1.3', 'org.apache.coyote.ajp', 'org.apache.coyote.ajp.AjpNioProtocol'], $ajp['protocol'])
    }
  }

  if $javahome == undef {
    fail('You need to specify a value for javahome')
  }

  # Archive module checksum_verify = true; this verifies checksum if provided, doesn't if not.
  if $checksum == undef {
    $checksum_verify = false
  } else {
    $checksum_verify = true
  }

  contain jira::install
  contain jira::config
  contain jira::service

  Class['jira::install']
  -> Class['jira::config']
  ~> Class['jira::service']

  if ($enable_sso) {
    class { '::jira::sso': }
  }
}
