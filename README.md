hyperloop-deux
==============

More "cloudy" hyperloop

Project Structure
=================
RATIONALE:
Maximize speed of onboarding, development and deployment of complex applications.

Automate ALL the things.  A simple 'git clone && vagrant up' should be enough to get the whole thing going.  There should be no need to be a vagrant/docker/core os expert to use this template.  Minimize downloads, where possible.  Make it easy to stay in sync.  Make it easy to deploy to QA, Production and other environments.  Simulate the real production environment as much as possible on dev machines.

TARGET STRUCTURE:
1. /infrastructure - for programmatic infrastructure setup, management and teardown
        /exportContainers - docker containers (.tar) that have been saved for future import
        /importContainers - docker containers (.tar) that will be imported on creation of the cluster
        /provisionScripts - scripts for use during provisioning and management

2. /projects - for source code

3. /global - for globally available files between all machines
        /dockerfiles - to build docker images
        /data - for persistent data-files, like databases
        /secrets **NEVER** check in to source control
        /templates - template files from which config files and scripts are generated
            /config - config file templates, output to /local/vm_name/config
            /scripts - script file templates, output to /local/vm_name/scripts

4. /local - for locally available files to specific machines
        /config - generated machine config files
        /scripts - generated script files

when starting a container (ideal)
-use fleetctl to provision the container, but it will really just run a script
-if base image is not already in docker cache then

    -script will see if container is available locally in /infrastructure/importContainers
        -if not, then script will fetch image, start container, and then save copy to /importContainers
    -if so, then script will load the image and start container

-if base image is already in docker cache then script will start container
