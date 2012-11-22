
#Currently supported shells are BASH and KSH93
#You can install with ZSH, but it will only integrate for the supported shells
#If using ZSH, invoke as 'zsh install.sh'

#set -x
################################################################################
#
# Program: install.sh
# Author : Justin Francis
# Created: 2012-03-04
#
################################################################################
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
#
################################################################################

cd `dirname $0`
ld_base=$PWD
ld_dest="${HOME}/.bash-git" #original name; reset to .git-info-bar, further down
lf_plugin=
l_shell=`echo ${SHELL} | awk -F'/' '{print $NF}'`

printf "\n\n"

l_out=`/usr/bin/env perl -e 'use 5.4.0'` #require minimum of Perl 5.4
#l_out=`fakecmd123` #require minimum of Perl 5.4
if [[ $? -ne 0 ]]; then
    echo "[WARN] Missing dependency -> Perl 5.4.0 or greater"
    if [[ ${l_shell} != "bash" && ${l_shell} != "ksh" && ${l_shell} != "sh" ]]; then
        echo "Bash, ksh93 and gitbash (for MS Windows) are the only supported shells at this time."
        exit 101
    elif [[ ${l_shell} == "sh" ]]; then
        if [[ ! -s ${OS} || $(echo ${OS} | grep -ic "Windows") -eq 0 ]]; then
            echo "Bash, ksh93 and gitbash (for MS Windows) are the only supported shells at this time."
            exit 101
        fi
    fi
    echo "[WARN] Using SHELL plugin, rather than Perl based plugin"
    lf_plugin="plugin.shell"
else
    lf_plugin="plugin.perl"
fi

. ${ld_base}/lib/shell/global_functions

#- Version 1.0.0 was placed in-line into the rc or profile
#  Later versions have their own home directory, thus the second test, if the first fails
#-----------------------------------------------------------------------------------------
l_effective_profile=
case "${l_shell}" in
    bash   ) l_effective_profile=".bashrc"  ;;
    ksh|sh ) l_effective_profile=".profile" ;;
    zsh    ) l_effective_profile=".zshrc"   ;;
esac

l_new_version=$(cat VERSION)
printf "This will remove any previous versions of git-info-bar\nand install version ${l_new_version}.  Proceed? (y/n): "
read l_answ
if [[ $(echo ${l_answ} | grep -c -i "^y") -lt 1 ]]; then
    echo "Aborted."
    exit 100
fi
${ld_base}/uninstall/uninstall-git-info-bar.sh
if [[ $? -ne 0 ]]; then
    printf "Sorry, there was an error uninstalling the previous version.\nPlease remove it by hand.\n"
    exit 0
fi

ld_dest="${HOME}/.git-info-bar"

l_version=`awk '{print $1}' VERSION`
printf "[INFO] Installing git-info-bar (version ${l_version}) ... "
if [[ ! -d "${ld_dest}" ]]; then
    l_out=$(mkdir ${ld_dest} 2>&1)
    if [[ $? -ne 0 ]]; then
        printf "FAILED!\nERROR: $1\n${l_out}"
        exit 101
    fi
fi
l_out=$(cp ${ld_base}/License ${ld_dest}/)
if [[ $? -ne 0 ]]; then
    printf "FAILED!\nERROR: $1\n${l_out}"
    exit 101
fi
l_out=$(cp ${ld_base}/${lf_plugin} ${ld_dest}/plugin)
if [[ $? -ne 0 ]]; then
    printf "FAILED!\nERROR: $1\n${l_out}"
    exit 101
fi
l_out=$(cp ${ld_base}/VERSION ${ld_dest}/)
if [[ $? -ne 0 ]]; then
    printf "FAILED!\nERROR: $1\n${l_out}"
    exit 101
fi

for l_profile in .bashrc .profile
do
    case "${l_shell}" in
        bash|ksh|sh ) #- We allow bash, ksh93 and gitbash, currently
                      #- gitbash uses 'sh', but is really bash
                      #----------------------------------------------
                      ;;

        zsh         ) printf "FAILED!\n  Unsupported shell (${l_shell}) - try bash, ksh93 or gitbash.\n"
                      exit 101
                      ;;

        *           ) printf "FAILED!\n  Unsupported shell (${l_shell}) - try bash, ksh93 or gitbash.\n"
                      exit 101;
                      ;;
    esac
    if [[ ${l_profile} == ".profile" ]]; then
        which ksh 1>/dev/null 2>&1
        if [[ $? -ne 0 ]]; then
            if [[ ! -s ${OS} || $(echo ${OS} | grep -ic "Windows") -eq 0 ]]; then
                #- skip non-gitbash shell
                #-------------------------
                continue
            fi
        fi
    fi
    grep "~/.git-info-bar/plugin" ${HOME}/${l_profile} 1>/dev/null
    if [[ $? -ne 0 ]]; then
        echo "if [[ \$TERM != '' ]]; then . ~/.git-info-bar/plugin; fi" >>${HOME}/${l_profile}
        if [[ $? -ne 0 ]]; then
            printf "FAILED!\nERROR: $1\n${l_out}"
            exit 101
        fi
    fi
done

echo DONE

printf "
git-info-bar (v${l_version}) installation completed successfully!

Please run the following command to begin using git-info-bar:

    . ~/${l_effective_profile}

Enjoy,
ComWT (https://github.com/comwt/git-info-bar)

"

exit 0

