# Class: helm::chart::update
# ===========================
#
# A module to update Helm charts.

# Cfr. README for parameter documentation

define helm::chart_update (
  $ensure = present,
  $ca_file = undef,
  $cert_file = undef,
  $chart = undef,
  $debug = false,
  $devel = false,
  $dry_run = false,
  $env = undef,
  $key_file = undef,
  $keyring = undef,
  $home = undef,
  $host = undef,
  $install = true,
  $kube_context = undef,
  $namespace = undef,
  $no_hooks = false,
  $path = undef,
  $purge = true,
  $repo = undef,
  $release_name = undef,
  $recreate_pods = undef,
  $reset_values = undef,
  $reuse_values = undef,
  $set = [],
  $timeout = undef,
  $tiller_namespace = 'kube-system',
  $tls = false,
  $tls_ca_cert = undef,
  $tls_cert = undef,
  $tls_key = undef,
  $tls_verify = false,
  $values = [],
  $verify = false,
  $version = undef,
  $wait = false,
){

  include helm::params

  if ($release_name == undef) {
    fail("\nYou must specify a name for the service with the release_name attribute \neg: release_name => 'mysql'")
  }

  if $ensure == present {
    $helm_chart_update_flags = helm_chart_update_flags({
      ensure => $ensure,
      ca_file =>$ca_file,
      cert_file => $cert_file,
      chart => $chart,
      debug => $debug,
      devel => $devel,
      dry_run => $dry_run,
      key_file => $key_file,
      keyring => $keyring,
      home => $home,
      host => $host,
      install => $install,
      kube_context => $kube_context,
      namespace => $namespace,
      no_hooks => $no_hooks,
      recreate_pods => $recreate_pods,
      reset_values => $reset_values,
      reuse_values => $reuse_values,
      repo => $repo,
      release_name => $release_name,
      set => $set,
      timeout => $timeout,
      tiller_namespace => $tiller_namespace,
      tls => $tls,
      tls_ca_cert => $tls_ca_cert,
      tls_cert => $tls_cert,
      tls_key => $tls_key,
      tls_verify => $tls_verify,
      values => $values,
      verify => $verify,
      version => $version,
      wait => $wait,
      })
    $exec = "helm upgrade ${chart}"
    $exec_chart = "helm ${helm_chart_update_flags}"
    $unless_chart = false
  }

  if $ensure == absent {
    $helm_delete_flags = helm_delete_flags({
      ensure => $ensure,
      debug => $debug,
      dry_run => $dry_run,
      home => $home,
      host => $host,
      kube_context => $kube_context,
      namespace => $namespace,
      no_hooks => $no_hooks,
      purge => $purge,
      release_name => $release_name,
      timeout => $timeout,
      tiller_namespace => $tiller_namespace,
      tls => $tls,
      tls_ca_cert => $tls_ca_cert,
      tls_cert => $tls_cert,
      tls_key => $tls_key,
      tls_verify => $tls_verify,
      })
    $exec = "helm delete ${chart}"
    $exec_chart = "helm ${helm_delete_flags}"
    $helm_ls_flags = helm_ls_flags({
      ls => true,
      home => $home,
      host => $host,
      kube_context => $kube_context,
      tiller_namespace => $tiller_namespace,
      short => true,
      tls => $tls,
      tls_ca_cert => $tls_ca_cert,
      tls_cert => $tls_cert,
      tls_key => $tls_key,
      tls_verify => $tls_verify,
    })
    $unless_chart = "helm ${helm_ls_flags} | awk '{if(\$1 == \"${release_name}\") exit 1}'"
  }

  exec { $exec:
    command     => $exec_chart,
    environment => $env,
    path        => $path,
    timeout     => 0,
    tries       => 10,
    try_sleep   => 10,
    unless      => $unless_chart,
  }
}