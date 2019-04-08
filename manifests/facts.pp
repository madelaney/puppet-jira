# == Class: jira::facts
#
# Class to add some facts for JIRA. They have been added as an external fact
# because we do not want to distrubute these facts to all systems.
#
# === Parameters
#
# [*port*]
#   port that jira listens on.
# [*uri*]
#   ip that jira is listening on, defaults to localhost.
#
# === Examples
#
# class { 'jira::facts': }
#
class jira::facts (
  $ensure        = 'present',
  $port          = $jira::tomcat_port,
  $contextpath   = $jira::contextpath,
  $json_packages = $jira::json_packages,
  # lint:ignore:parameter_order
  $uri           = $jira::tomcat_address ? {
    undef   => '127.0.0.1',
    default => $jira::tomcat_address,
  },
  # lint:endignore
) {

  # Puppet Enterprise supplies its own ruby version if your using it.
  # A modern ruby version is required to run the executable fact
  if $facts['puppetversion'] =~ /Puppet Enterprise/ {
    $ruby_bin = '/opt/puppet/bin/ruby'
    $dir = 'puppetlabs/'
  } else {
    $ruby_bin = '/usr/bin/env ruby'
    $dir = ''
  }

  if !defined(File["/etc/${dir}facter"]) {
    file { "/etc/${dir}facter":
      ensure => directory,
    }
  }
  if !defined(File["/etc/${dir}facter/facts.d"]) {
    file { "/etc/${dir}facter/facts.d":
      ensure => directory,
    }
  }

  if $facts['osfamily'] == 'RedHat' and $facts['puppetversion'] !~ /Puppet Enterprise/ {
    ensure_packages ($json_packages, { ensure => present })
  }

  file { "/etc/${dir}facter/facts.d/jira_facts.rb":
    ensure  => $ensure,
    content => template('jira/facts.rb.erb'),
    mode    => '0500',
  }

}
