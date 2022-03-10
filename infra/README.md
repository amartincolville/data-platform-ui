# The `infra` directory

This directory you are in contains all the needed files to properly deploy you application as an immutable image. Currently this immutable image is an AMI (Amazon Machine Image) embedding a Docker container running a Docker image as built by `../Dockerfile.release`.

The AMI is _baked_ by [Hashicorp Packer](https://packer.io) following the instructions in `packer/packer.json` and is customized by an [Ansible](https://www.ansible.com) playbook found in `ansible/`.

## Configuring your application
After performing this actions, execute the script `infra/provision.sh` to configure this project.

### Adding environment variables

Please check how to [view and set runtime configuration in a Stuart project](https://stuart-team.atlassian.net/wiki/spaces/EN/pages/906985485/View+and+set+runtime+configuration+for+a+Stuart+project#id-%E2%9A%99%EF%B8%8FViewandsetruntimeconfigurationforaStuartproject-%F0%9F%93%A6StoringenvironmentvarsonConsul) in our Confluence documentation.

### Adding secrets

Please check how to [view and set runtime configuration in a Stuart project](https://stuart-team.atlassian.net/wiki/spaces/EN/pages/906985485/View+and+set+runtime+configuration+for+a+Stuart+project#id-%E2%9A%99%EF%B8%8FViewandsetruntimeconfigurationforaStuartproject-%F0%9F%94%91StoringsecretsonHashicorpVault) in our Confluence documentation.
