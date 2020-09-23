require 'json'

work_dir        = File.expand_path(File.dirname(__FILE__))
input_configs   = JSON.parse(File.read(File.join(work_dir, "configs.json")))
scripts_dir     = File.join(work_dir, "scripts")
files_dir       = File.join(work_dir, "files")

# Define salt-master IP Address
master_ip_address = ""

# Fetch new IP Address from first_ip and index function
def fetch_ip_address(first_ip, i)
    array = first_ip.split('.')
    change = (array.first 3).push(array[-1].to_i + i)
    new_ip = ""
    for i in change
        new_ip += "." + i.to_s
    end
    return new_ip[1..-1]
end

Vagrant.configure(2) do |config|
    # Define box
    config.vm.box = input_configs.fetch('os')

    # Define custom VM
    input_configs.fetch('vm').each do |vms|
        # Define salt-master IP Address, add to /etc/hosts on all salt VMs 
        if vms.fetch('name') == "salt-master"
            master_ip_address = vms.fetch('first_ip')
        end

        # Define VM by count
        (1..vms.fetch('count')).each do |i|

            # Define Server name => ID for Vagrant VM define, hostname and provider VM name also
            server_name = "#{vms.fetch('name')}-#{i}"

            config.vm.define server_name do |server|

                # Define VM IP Address
                ip_address = fetch_ip_address(vms.fetch('first_ip'), i - 1)

                # Get VMs configuration
                server.vm.provider input_configs.fetch('provider') do |v|
                    v.name = server_name
                    v.cpus = vms.fetch('cpu')
                    v.memory = vms.fetch('memory')
                    v.linked_clone = input_configs.fetch('linked_clones')
                end
                server.vm.network input_configs.fetch('network').fetch('network_type'), ip: ip_address, netmask: input_configs.fetch('network').fetch('netmask')
                server.vm.hostname = server_name

                # Add salt-master IP Address to all salt-minion (Use `salt` prefix)
                if vms.fetch('name').start_with?("salt")
                    server.vm.provision "shell", inline: "sudo echo #{master_ip_address} salt >> /etc/hosts"
                end

                # Run custom scripts for each VM type
                if vms.key?("custom_scripts")
                    vms.fetch("custom_scripts").each do |script|
                        server.vm.provision "shell", path: File.join(scripts_dir, script)
                    end
                end
                # Post message after provison all VMs to get IP Address for each VM
                server.vm.post_up_message = "IP Address: #{ip_address} - CPUs: #{vms.fetch('cpu')} - Memory: #{vms.fetch('memory')} MB"
            end
        end
    end

    # Run scripts to all created VM
    config.vm.provision "shell", path: File.join(scripts_dir, input_configs.fetch('scripts').fetch('base'))
    config.vm.provision "file", source: File.join(files_dir, input_configs.fetch('files').fetch('ssh_public_key')), destination: "/tmp/id_rsa.pub"
    config.vm.provision "shell" do |s|
        s.path = File.join(scripts_dir, input_configs.fetch('scripts').fetch('add_user'))
        s.args = input_configs.fetch('username')
    end
end