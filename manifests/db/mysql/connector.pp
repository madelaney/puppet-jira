class jira::db::mysql::connector(
  $version      = $jira::mysql_connector_version,
  $product      = $jira::mysql_connector_product,
  $format       = $jira::mysql_connector_format,
  $installdir   = $jira::mysql_connector_install,
  $download_url = $jira::mysql_connector_url
  ) {

  require ::archive

  $file = "${product}-${version}.${format}"

  if ! defined(File[$installdir]) {
    file {
      $installdir:
        ensure => 'directory',
        owner  => root,
        group  => root,
        before => Archive["${installdir}/${file}"]
    }
  }

  archive {
    "${installdir}/${file}":
      ensure       => present,
      source       => "${download_url}/${file}",
      extract      => true,
      extract_path => $installdir,
      creates      => "${installdir}/${product}-${version}"
  }
  -> file {
    "${jira::webappdir}/lib/mysql-connector-java.jar":
      ensure => link,
      target => "${installdir}/${product}-${version}/${product}-${version}-bin.jar"
  }
}
