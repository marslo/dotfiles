#!/usr/bin/env bash

declare -a commands=( 'ansible'
                      'ansible-config'
                      'ansible-console'
                      'ansible-doc'
                      'ansible-galaxy'
                      'ansible-inventory'
                      'ansible-playbook'
                      'ansible-pull'
                      'ansible-vault'
                    )

declare path=$PWD

for val in "${commands[@]}"; do
  echo "~~ ${val} ~~"
  # eval $(register-python-argcomplete "${val}")
  register-python-argcomplete "${val}" > "${path}/${val}"
done
