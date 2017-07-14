# == Class: ethtool
#
# Installs ethtool so the ethtool type can function.
#
# === Parameters
#
# [*ensure_installed*]
#  Boolean. If true, will ensure that the right ethtool package
#  is installed on the system.
#
class ethtool (
  Boolean $ensure_installed = true
) {

  validate_bool($ensure_installed)
  if str2bool($ensure_installed) {
    ensure_packages(['ethtool'])
  }

  if defined(Package['ethtool']) {
    Package['ethtool'] -> Ethtool<| |>
  }

}
