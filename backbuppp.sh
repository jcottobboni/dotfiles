installAll() {
  apt_intall_git
  apt_update_upgrade
  apt_install_dev_dependencies
  apt_install_rbenv
  apt_install_ruby_build
  apt_install_ruby
  apt_install_bundler
  apt_install_nodejs
  apt_install_rails
}

case "$1" in
  "packages" | "pkgs")
    apt_install_dev_dependencies
    ;;
  *)
    installAll
    ;;
esac
