Vagrant::Config.run do |config|
  # All Vagrant configuration is done here. For a detailed explanation
  # and listing of configuration options, please check the documentation
  # online.
  config.vm.provisioner = :chef_solo
  config.chef.cookbooks_path = "cookbooks"
  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "base"
  config.vm.forward_port("web", 8000, 9000)
end
