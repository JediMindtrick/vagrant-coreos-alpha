require 'fileutils'
require 'erb'

=begin
/infrastructure
    /importContainers
    /exportContainers
    /provisionScripts
/projects
/global
    /data
    /secrets
    /dockerfiles
    /templates
/local/{machine name}
    /config
    /scripts
=end

$project_root = File.expand_path('..',Dir.pwd)
$container_home = '/home'
$vm_home = '/home/core'


$local_directories = {}
$local_directories[:local_config] = {
    #this needs to be a function in order to inject the machine name
    host: lambda do |vm_name|
        File.join($project_root,'local',vm_name,'config')
    end,
    vm: File.join($vm_home,'local', 'config'),
    vm_share_id: 'localConfig',
    container: File.join($container_home,'local','config')
}
$local_directories[:local_scripts] = {
    #this needs to be a function in order to inject the machine name
    host: lambda do |vm_name|
        File.join($project_root,'local',vm_name,'scripts')
    end,
    vm: File.join($vm_home,'local', 'scripts'),
    vm_share_id: 'localScripts',
    container: File.join($container_home,'local','scripts')
}

$global_directories = {}

$global_directories[:infrastructure] = {
    host: File.join($project_root,'infrastructure'),
    vm: File.join($vm_home,'infrastructure'),
    vm_share_id: 'infrastructure',
    container: File.join($container_home,'infrastructure')
}
    $global_directories[:import_containers] = {
        host: File.join($global_directories[:infrastructure][:host],'importContainers'),
        vm: File.join($global_directories[:infrastructure][:vm],'importContainers'),
        vm_share_id: 'importContainers',
        container: File.join($global_directories[:infrastructure][:container],'importContainers')
    }
    $global_directories[:export_containers] = {
        host: File.join($global_directories[:infrastructure][:host],'exportContainers'),
        vm: File.join($global_directories[:infrastructure][:vm],'exportContainers'),
        vm_share_id: 'exportContainers',
        container: File.join($global_directories[:infrastructure][:container],'exportContainers')
    }
    $global_directories[:provision_scripts] = {
        host: File.join($global_directories[:infrastructure][:host],'provisionScripts'),
        vm: File.join($global_directories[:infrastructure][:vm],'provisionScripts'),
        vm_share_id: 'provisionScripts',
        container: File.join($global_directories[:infrastructure][:container],'provisionScripts')
    }

$global_directories[:projects] = {
    host: File.join($project_root,'projects'),
    vm: File.join($vm_home,'projects'),
    vm_share_id: 'projects',
    container: File.join($container_home,'projects')
}

$global_directories[:global] = {
    host: File.join($project_root,'global'),
    vm: File.join($vm_home,'global'),
    vm_share_id: 'global',
    container: File.join($container_home,'global')
}
    $global_directories[:data] = {
        host: File.join($global_directories[:global][:host],'data'),
        vm: File.join($global_directories[:global][:vm],'data'),
        vm_share_id: 'data',
        container: File.join($global_directories[:global][:container],'data')
    }
    $global_directories[:secrets] = {
        host: File.join($global_directories[:global][:host],'secrets'),
        vm: File.join($global_directories[:global][:vm],'secrets'),
        vm_share_id: 'secrets',
        container: File.join($global_directories[:global][:container],'secrets')
    }
    $global_directories[:dockerfiles] = {
        host: File.join($global_directories[:global][:host],'dockerfiles'),
        vm: File.join($global_directories[:global][:vm],'dockerfiles'),
        vm_share_id: 'dockerfiles',
        container: File.join($global_directories[:global][:container],'dockerfiles')
    }
    $global_directories[:templates] = {
        host: File.join($global_directories[:global][:host],'templates'),
        vm: File.join($global_directories[:global][:vm],'templates'),
        vm_share_id: 'templates',
        container: File.join($global_directories[:global][:container],'templates')
    }
        $global_directories[:templates_config] = {
            host: File.join($global_directories[:templates][:host],'config'),
            vm: File.join($global_directories[:templates][:vm],'config'),
            vm_share_id: 'globalTemplatesConfig',
            container: File.join($global_directories[:templates][:container],'config')
        }
        $global_directories[:templates_scripts] = {
            host: File.join($global_directories[:templates][:host],'scripts'),
            vm: File.join($global_directories[:templates][:vm],'scripts'),
            vm_share_id: 'globalScriptsConfig',
            container: File.join($global_directories[:templates][:container],'scripts')
        }

def list_project_directories()
    arr = []

    $global_directories.each do |key,value|
        arr.push(value[:host])
    end

    return arr
end

def setup_project_directories
    list_project_directories.each do |d|
        FileUtils.mkdir_p(d)
    end
end

def setup_machine_directories(machine_name)
    $local_directories.each do |key,value|
        FileUtils.mkdir_p(value[:host].call(machine_name))
    end
end

def get_template(template_name)
    ERB.new(File.read(File.join($project_templates,template_name)))
end

def setup_host_global_shares(config,i)
    $global_directories.each do |key,value|
        config.vm.synced_folder value[:host], value[:vm], id: (value[:vm_share_id] + i.to_s), :nfs => true, :mount_options => ['nolock,vers=3,udp']
    end
end

def setup_host_local_shares(config,machine_name,i)
    $local_directories.each do |key,value|
        config.vm.synced_folder value[:host].call(machine_name), value[:vm], id: (value[:vm_share_id] + i.to_s), :nfs => true, :mount_options => ['nolock,vers=3,udp']
    end
end


=begin
list_project_directories().each do |d|
    puts d
end

setup_machine_directories 'core-01'

setup_project_directories
setup_machine_directories 'core-01'

Dir["#{$project_shares_global}/importContainers/**/*.tar"].each { |f|
    tar_name = File.basename(f)
    puts tar_name
}

$directories.each do |key|
    puts "#{key}-----"
    hash[key].each do |dir|
        dir.each { |val| puts val }
    end
end

puts $local_directories[:local_config][:host].call('core-01')

$local_directories.each do |key,value|
    puts key
    puts '------------------------------'
    value.each do |key2,value2|
        puts "#{key2} = #{value2}"
    end
    puts '------------------------------'
end
=end

#setup_project_directories
#setup_machine_directories 'core-01'
