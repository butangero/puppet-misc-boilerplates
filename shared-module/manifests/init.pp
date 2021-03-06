# == Class: boilerplate
#
# This class is able to install or remove boilerplate on a node.
# It manages the status of the related service.
#
# [Add description - What does this module do on a node?] FIXME/TODO
#
#
# === Parameters
#
# [*ensure*]
#   String. Controls if the managed resources shall be <tt>present</tt> or
#   <tt>absent</tt>. If set to <tt>absent</tt>:
#   * The managed software packages are being uninstalled.
#   * Any traces of the packages will be purged as good as possible. This may
#     include existing configuration files. The exact behavior is provider
#     dependent. Q.v.:
#     * Puppet type reference: {package, "purgeable"}[http://j.mp/xbxmNP]
#     * {Puppet's package provider source code}[http://j.mp/wtVCaL]
#   * System modifications (if any) will be reverted as good as possible
#     (e.g. removal of created users, services, changed log settings, ...).
#   * This is thus destructive and should be used with care.
#   Defaults to <tt>present</tt>.
#
# [*autoupgrade*]
#   Boolean. If set to <tt>true</tt>, any managed package gets upgraded
#   on each Puppet run when the package provider is able to find a newer
#   version than the present one. The exact behavior is provider dependent.
#   Q.v.:
#   * Puppet type reference: {package, "upgradeable"}[http://j.mp/xbxmNP]
#   * {Puppet's package provider source code}[http://j.mp/wtVCaL]
#   Defaults to <tt>false</tt>.
#
# [*status*]
#   String to define the status of the service. Possible values:
#   * <tt>enabled</tt>: Service is running and will be started at boot time.
#   * <tt>disabled</tt>: Service is stopped and will not be started at boot
#     time.
#   * <tt>running</tt>: Service is running but will not be started at boot time.
#     You can use this to start a service on the first Puppet run instead of
#     the system startup.
#   * <tt>unmanaged</tt>: Service will not be started at boot time and Puppet
#     does not care whether the service is running or not. For example, this may
#     be useful if a cluster management software is used to decide when to start
#     the service plus assuring it is running on the desired node.
#   Defaults to <tt>enabled</tt>. The singular form ("service") is used for the
#   sake of convenience. Of course, the defined status affects all services if
#   more than one is managed (see <tt>service.pp</tt> to check if this is the
#   case).
#
# [*version*]
#   String to set the specific version you want to install.
#   Defaults to <tt>false</tt>.
#
# [*restart_on_change*]
#   Boolean that determines if the application should be automatically restarted
#   whenever the configuration changes. Disabling automatic restarts on config
#   changes may be desired in an environment where you need to ensure restarts
#   occur in a controlled/rolling manner rather than during a Puppet run.
#
#   Defaults to <tt>true</tt>, which will restart the application on any config
#   change. Setting to <tt>false</tt> disables the automatic restart.
#
# The default values for the parameters are set in boilerplate::params. Have
# a look at the corresponding <tt>params.pp</tt> manifest file if you need more
# technical information about them.
#
#
# === Examples
#
# * Installation, make sure service is running and will be started at boot time:
#     class { 'boilerplate': }
#
# * Removal/decommissioning:
#     class { 'boilerplate':
#       ensure => 'absent',
#     }
#
# * Install everything but disable service(s) afterwards
#     class { 'boilerplate':
#       status => 'disabled',
#     }
#
#
# === Authors
#
# * John Doe <mailto:john.doe@example.com>
#
class boilerplate(
  $ensure            = $boilerplate::params::ensure,
  $autoupgrade       = $boilerplate::params::autoupgrade,
  $status            = $boilerplate::params::status,
  $restart_on_change = $boilerplate::params::restart_on_change,
  $version           = false
) inherits boilerplate::params {

  anchor {'boilerplate::begin': }
  anchor {'boilerplate::end': }


  #### Validate parameters

  # ensure
  if ! ($ensure in [ 'present', 'absent' ]) {
    fail("\"${ensure}\" is not a valid ensure parameter value")
  }

  # autoupgrade
  validate_bool($autoupgrade)

  # service status
  if ! ($status in [ 'enabled', 'disabled', 'running', 'unmanaged' ]) {
    fail("\"${status}\" is not a valid status parameter value")
  }

  # restart on change
  validate_bool($restart_on_change)


  #### Manage actions

  # package(s)
  class { 'boilerplate::package': }

  # configuration
  class { 'boilerplate::config': }   # FIXME/TODO: Remove this declaration or this comment. See "config.pp" for more information.

  # service(s)
  class { 'boilerplate::service': }



  #### Manage relationships

  if $ensure == 'present' {

    # we need the software before configuring it
    Anchor['boilerplate::begin']
    -> Class['boilerplate::package']
    -> Class['boilerplate::config'] # FIXME/TODO: Remove this relationship or this comment. See "config.pp" for more information.

    # we need the software and a working configuration before running a service
    Class['boilerplate::package'] -> Class['boilerplate::service']
    Class['boilerplate::config']  -> Class['boilerplate::service']  # FIXME/TODO: Remove this relationship or this comment. See "config.pp" for more information.

    Class['boilerplate::service'] -> Anchor['boilerplate::end']

  } else {

    # make sure all services are getting stopped before software removal
    Anchor['boilerplate::begin']
    -> Class['boilerplate::service']
    -> Class['boilerplate::package']
    -> Anchor['boilerplate::end']

  }

}
