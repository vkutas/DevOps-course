## Emoji Service
Python service which can provide you with emoji you like.

The service can accept http and https requests with POST and GET methods. POST request receive JSON object of the following format: 
`{"word":"name", "count": n}` and returns a string which consists of 'name' repeated 'n' times using emoji which name is equal to the 'name' as delimeter. If there is no emoji with the name 'name', random emoji is used instead. 
 
 **http POST  example:**  
 Request:  
 `curl -X POST -d '{"word":"owl", "count":3}' http://<ip_address>`  
 Response:  
 `🦉owl🦉owl🦉owl🦉`

**POST https example:** 
Because server uses self-signed SSL certificate, you should use `-k` flag to ask curl don't verify it:  
 `curl -X POST -k -d '{"word":"dolphin", "count":5}' https://<ip_address>`  
 Response:  
 `🐬dolphin🐬dolphin🐬dolphin🐬dolphin🐬dolphin🐬`  

 or, you can import certificate from them server and tell curl where it located.

 **WARNING: Don't use mentioned above approach with production servers, only for testing purpose on local machine!**

GET http and https request returns greetings page. You can see it in your browser typing server IP in address line.

### Project structure 

The project comprises the following parts:  
1. [emoji-service](/task4/ansible_provisioning/roles/emojiservice_deploy/files/emoji-service)  
    Python flask application, which also uses [emoji](https://pypi.org/project/emoji/) library to work with emoji.  
2. uWSGI - application server.  
   The file [wsgi.py](task4/ansible_provisioning/roles/emojiservice_deploy/files/emoji-service/wsgi.py) is the entry point to the application. The file [emojiservice.ini](task4/ansible_provisioning/roles/emojiservice_deploy/files/emoji-service/emojiservice.ini) contains uWSGI settings.
3. Nginx is used to handle http requests. It communicate with uWSGI application server using uwsgi binary protocol through unix socket.
4. [Vagrant](/task4/Vagrantfile) is used to manage VM and describe VM configuration as code.
   This project uses [debian/contrib-buster64](https://app.vagrantup.com/debian/boxes/contrib-buster64) - Debian 10 "Buster" image with installed VirtualBox guests additions in order to sync folders and port forwarding works properly. 
5. Ansible is used for configuration management and application deploying.

Directory [ansible_provisioning](/task4/ansible_provisioning) contains all files related to Asible:
1. [hosts.yml](task4/ansible_provisioning/hosts.yml) - ansible inventory file.
2. [webservers_install_dependencies.yml](/task4/ansible_provisioning/webservers_install_dependencies.yml) - playbook to install required dependecies on the server.
3. [webservers_security_config.yml](/task4/ansible_provisioning/webservers_security_config.yml) -  playbook to apply security rules to the server.
4. [ssl_self_signed.yml](/task4/ansible_provisioning/ssl_self_signed.yml) - playbook which creates self-signed SSL certificate on the server.
5. [install_nginx.yml](/task4/ansible_provisioning/install_nginx.yml) - playbook which install and configure nginx
6. [emoji-service_deploy.yml](/task4/ansible_provisioning/emoji-service_deploy.yml) - playbook which deploy emoji service on the server using [emojiservice_deploy](/task4/ansible_provisioning/roles/emojiservice_deploy) role.


### Usage

To run this project on your machine your need:  

1. [Vagrant](https://www.vagrantup.com/)
2. [VirtualBox](https://www.virtualbox.org/) as VM provider for Vagrant.  
   You can also use another provider which Vagrant [supports](https://www.vagrantup.com/docs/providers), such as [VMware](https://www.vagrantup.com/docs/providers/vmware) or [Hyper-V](https://www.vagrantup.com/docs/providers/hyperv), but in this case you will need to make some changes in [Vagrantfile](/task4/Vagrantfile)
3. [Ansible](https://www.ansible.com/) to run Vagrant provisioners in order to set up environment and deploy aplication.
4. [community.crypto.*](https://github.com/ansible-collections/community.crypto) Ansible modules to create self-signed certificate. You can install it running:  
 `ansible-galaxy collection install community.crypto` in your teminal.

When you have all dependencies mentioned above:
 1. Clone the repository.
 2. To run the provisioner. you need to create *service_user_password*:  
   2.1. Come up with a strong password.  
   2.2. Use `mkpasswd` command line utilty to get hash of your password, e.g. `mkpasswd --method=SHA-512 yourpassword`    
   2.3. Come up with a strong password for ansible-vault and put it to text file to the ansible_provisioning directory (or any else).  
   2.4. Use the following command to encrypt the date from step 2.2:  
   `ansible-vault encrypt_string --vault-password-file a_password_file 'string_from_step_2.2' --name 'emoji_service_user_password'`
    where *a_password_file* path to the file with password from ansible vault.  
   2.5 Open the [emoji-service_deploy.yml](/task4/ansible_provisioning/emoji-service_deploy.yml) and replace the value of emoji_service_user_password variable on ecrypted values from step 2.4.  
   2.6. Open [Vagrantfile](/task4/Vagrantfile) and specify the path to the file with ansible vault password to the `ANSIBLE_SERVICE_USER_VAULT_FILE_PATH`    
   
   Alternatively, you can remove encrypted varible from [emoji-service_deploy.yml](/task4/ansible_provisioning/emoji-service_deploy.yml). The role's defaults will be used instead.   

 3. Open project's root directory (directory with [Vagrantfile](/task4/Vagrantfile))
 4. Open terminal in this directory.
 5. Run `vagrant up` command in your terminal.

 Vagrant will download [VM box](https://app.vagrantup.com/debian/boxes/contrib-buster64) from Vagrant Cloud, set up the VM using VirtualBox and then run ansible provision to set up environment and deploy application.  
 Just after Ansible finish its job, you will see following message:  
 `==> emojiservice: Vanilla Debian box. See https://app.vagrantup.com/debian for help and bug reports`  
Now you can test the service.
