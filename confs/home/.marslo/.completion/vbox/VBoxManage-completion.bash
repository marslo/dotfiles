#!/bin/bash
#
# bash completion file for VBoxManage 
#
# To enable the completions either:
#  - place this file in /etc/bash_completion.d
#  or
#  - copy this file to e.g. ~/.VBoxManage-completion.sh and add the line
#    below to your .bashrc after bash completion features are loaded
#    . ~/.VBoxManage-completion.sh
#


_VBoxManage_clonehd() {
        local options=(
                --format
                --variant
                --existing
        )

        local cur
        local prev
        _get_comp_words_by_ref -n : cur prev

        for opt in ${options[*]}; do
                if [ "$prev" == "$opt" ]; then
                        return
                fi
        done

        COMPREPLY=( $( compgen -W "${options[*]}" -- "$cur" ) )
}


_VBoxManage_metrics() {
        local options=(
                collect
                disable
                enable
                list
                query
                setup
        )

        local cur
        local prev
        _get_comp_words_by_ref -n : cur prev

        for opt in ${options[*]}; do
                if [ "$prev" == "$opt" ]; then
                        return
                fi
        done

        COMPREPLY=( $( compgen -W "${options[*]}" -- "$cur" ) )
}


_VBoxManage_extpack() {
        local options=(
                cleanup
                install
                uninstall
        )

        local cur
        local prev
        _get_comp_words_by_ref -n : cur prev

        for opt in ${options[*]}; do
                if [ "$prev" == "$opt" ]; then
                        return
                fi
        done

        COMPREPLY=( $( compgen -W "${options[*]}" -- "$cur" ) )
}

_VBoxManage_dhcpserver() {
        local options=(
                add
                modify
                remove
        )

        local cur
        local prev
        _get_comp_words_by_ref -n : cur prev

        for opt in ${options[*]}; do
                if [ "$prev" == "$opt" ]; then
                        return
                fi
        done

        COMPREPLY=( $( compgen -W "${options[*]}" -- "$cur" ) )
}

_VBoxManage_list() {
        local subcommands=(
                bridgedifs
                dhcpservers
                dvds
                extpacks
                floppies
                groups
                hddbackends
                hdds
                hostcpuids
                hostdvds
                hostfloppies
                hostinfo
                hostonlyifs
                intnets
                natnets
                ostypes
                runningvms
                systemproperties
                usbfilters
                usbhost
                vms
                webcams
        )

        local options=(
                --long
                -l
        )

        # only one subcommand
        for subcom in ${subcommands[*]}; do
                if [ "$prev" == "$subcom" ]; then
                        return
                fi
        done


        # option are optatives
        exists_option=0
        for opt in ${options[*]}; do
                if [ "$prev" == "$opt" ]; then
                       exists_option=1 
                fi
        done

        if [ $exists_option -eq 0 ]; then
                for opt in ${options[*]}; do
                        subcommands+=("$opt")
                done
        fi

        COMPREPLY=( $( compgen -W "${subcommands[*]}" -- "$cur" ) )
}

_VBoxManage() {
	local commands=(
                adoptstate
                bandwidthctl
                clonehd
                clonevm
                closemedium
                controlvm
                convertfromraw
                createhd
                createvm
                debugvm
                dhcpserver
                discardstate
                export
                extpack
                getextradata
                guestcontrol
                guestproperty
                hostonlyif
                import
                list
                metrics
                modifyhd
                modifyvm
                natnetwork
                registervm
                setextradata
                setproperty
                sharedfolder
                showhdinfo
                showvminfo
                snapshot
                startvm
                storageattach
                storagectl
                unregistervm
                usbfilter
	)


        COMPREPLY=()
        local cur
        local prev
        local first="${COMP_WORDS[0]}"
        local second="${COMP_WORDS[1]}"
        _get_comp_words_by_ref -n : cur prev 

        if [ "$prev" == "$first" ]; then
                COMPREPLY=( $( compgen -W "${commands[*]}" -- "$cur" ) )
        else
                for option in ${commands[*]}; do
                        if [ "$second" == "$option" ]; then
                                declare -F _VBoxManage_$option >/dev/null || return
                                _VBoxManage_$option
                        fi
                done
        fi

        return
}

complete -F _VBoxManage VBoxManage
