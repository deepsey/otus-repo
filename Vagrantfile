# Describe VMs
home = ENV['HOME']
MACHINES = {
  # VM name "kernel update"
  :"otus-rpm" => {
              # VM box
              :box_name => "centos/7",
              # IP address
              :ip_addr => '192.168.100.38',     
              # VM CPU count
              :cpus => 4,
              # VM RAM size (Mb)
              :memory => 4096,
              # forwarded ports
              :forwarded_port => [],
             
              
   },                
}

Vagrant.configure("2") do |config|
  MACHINES.each do |boxname, boxconfig|
    # Disable shared folders
    config.vm.synced_folder ".", "/vagrant", disabled: false
    config.vm.define boxname do |box|
      # Set VM base box and hostname
      box.vm.box = boxconfig[:box_name]
      box.vm.host_name = boxname.to_s
      box.vm.network "private_network", ip: boxconfig[:ip_addr]
      # Port-forward config if present
      if boxconfig.key?(:forwarded_port)
        boxconfig[:forwarded_port].each do |port|
          box.vm.network "forwarded_port", port
        end
      end
      # VM resources config
      
      box.vm.provider "virtualbox" do |v|
        # Set VM RAM size and CPU count
        v.memory = boxconfig[:memory]
        v.cpus = boxconfig[:cpus]
        v.name = boxname.to_s
        
         end
      box.vm.provision "shell", path: "script.sh"
  
          
    end
  end
end
