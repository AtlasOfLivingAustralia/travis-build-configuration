###problem
often we modify some ansible script-s or variables, and some might get not checked in (for example because an invetory file contains some sensitive information like passords, etc), or we add/modify a variable for one playbook, and unintentionally break some other script/playbook; example: 
```
bash-3.2$ ansible-playbook -i inventories/nci-biocache-test ala-demo.yml -u hor22n --ask-sudo-pass -s

 ...

TASK: [biocache-service | ensure application data directory exists] *********** 
ok: [nci-biocache-test]

TASK: [biocache-service | copy all data assets] ******************************* 
ok: [nci-biocache-test]

TASK: [biocache-service | ensure target directories exist [data subdirectories etc.] *** 
ok: [nci-biocache-test] => (item=/data/ala/layers/ready/shape)
ok: [nci-biocache-test] => (item=/data/biocache-load)
ok: [nci-biocache-test] => (item=/data/biocache-media)
ok: [nci-biocache-test] => (item=/data/biocache-upload)
ok: [nci-biocache-test] => (item=/data/biocache-delete)
ok: [nci-biocache-test] => (item=/data/cache)
ok: [nci-biocache-test] => (item=/data/tmp)
ok: [nci-biocache-test] => (item=/data/offline/exports)
ok: [nci-biocache-test] => (item=/data/tool)

TASK: [biocache-service | copy all template configs] ************************** 
fatal: [nci-biocache-test] => {'msg': "AnsibleUndefinedVariable: One or more undefined variables: 'userdetails_url' is undefined", 'failed': True}
fatal: [nci-biocache-test] => {'msg': 'One or more items failed.', 'failed': True, 'changed': False, 'results': [{'msg': "AnsibleUndefinedVariable: One or more undefined variables: 'userdetails_url' is undefined", 'failed': True}]}

FATAL: all hosts have already failed -- aborting

PLAY RECAP ******************************************************************** 
           to retry, use: --limit @/Users/hor22n/ala-demo.retry

nci-biocache-test          : ok=105  changed=18   unreachable=1    failed=0 
```

###solution
to avoid that type of problems, resp. to identify the problem-s as soon as possible one can use [travis-ci.org](travis-ci.org) to automatically test the ansible scripts. here is a step by step example/howto add [travis-ci.org](travis-ci.org) test/support to your ansible-playbooks:

**1.** clone the github repo with ansible scripts you want to add travis support to, for example:
```BASH
git clone git@github.com:mbohun/ala-install.git ala-install.git
cd ala-install.git
```
**2.** copy the simple/basic ansible `.travis.yml` template/boilerplate (it is a separate file bellow) into the root of your repo
```BASH
cp ansible_template_travis.yml .travis.yml
```
**3.** use the travis client (or the travis webinterface) to login and enable the github repository on travis-ci.org
```BASH
travis login --github-token $GITHUB_TOKEN
travis enable --org --no-interactive
```
**4.** use the travis client to encrypt the username you want to use for running your ansible-playbook with
```BASH
travis encrypt -a -p "ANSIBLE_TEST_USER=someusername"
```
**5.** get and exncrypt your virtual machine SSH keypar (hereafter `key.pem`); **DO NOT** add/commit your `key.pem` into git/github - add/commit to git/github the **ENCRYPTED** `key.pem.enc`
```BASH
travis encrypt-file key.pem --add
git add key.pem.enc
```
**6.** fix the `key.pem` permissions (`chmod 600 key.pem`), in the `before_install` **AFTER** the travis openssl decryption of `key.pem.enc` to `key.pem` as shown in the example bellow.

**7.** add your VM's IP address (and/or hostname if available) to the `addons` `ssh_known_hosts` section, this is to prevent ansible/ssh from stopping/hanging and waiting for user confirmation as this is a noninteractive task run on travis-ci.org.

**8.** add your ansible-playbook test into the .travis.yml `script` section, for example:
```yaml
script:
  - cd ansible && ansible-playbook -i inventories/biocache-test ala-demo.yml --private-key ../key.pem -u $ANSIBLE_TEST_USER -s
```
**9.** add the .travis.yml file to git/github repo
```BASH
git add .travis.yml
```
**10.** add travis BuildStatus badge to your README.md file
```BASH
vi README.md && ...
git add README.md
```
*you should have by now something like:*
```yaml
language: python

python:
  - "2.7"

branches:
  only:
  - master

before_install:
  - openssl aes-256-cbc -K $encrypted_bc4ab20c2dda_key -iv $encrypted_bc4ab20c2dda_iv -in key.pem.enc -out key.pem -d
  - chmod 600 key.pem

install:
  - pip install ansible

script:
  - cd ansible && ansible-playbook -i inventories/biocache-test ala-demo.yml --private-key ../key.pem -u $ANSIBLE_TEST_USER -s

addons:
  ssh_known_hosts:
  - 203.101.226.44

env:
  global:
  - secure: "qHZ4n4DAqe+3UkfuQBPMDqthgHjHZf53kWNZU1tO5csmScsoYnoOg3Qq3Y60tBjQ+ENEI04b3flNRo+rGA6swSV4rXv0LhRgCkPyxXhzUmTjgcAc4uF+5dlKfbwUXqy55pIi0nqphlJhnHoHRLDMvxkatuzxoUJk0pLeYcq/Daw="
  ```
**11.** git commit & push your additions to github and check travis-ci.org for the result of your changes
```BASH
git commit -m "added travis-ci.org ansible support/test"
git push
```
