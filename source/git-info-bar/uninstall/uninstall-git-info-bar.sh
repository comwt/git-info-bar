#!/bin/bash

#set -x
################################################################################
#
# Program: uninstall-git-info-bar.sh
# Author : Justin Francis
# Created: 2012-03-05
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

#----------------------------------------------------------------------
# NOTE: before release v1.1.0, git-info-bar was know as 'bash-git' and
#       the plugin was installed under ~/.bash-git
#----------------------------------------------------------------------

cd $(dirname $0)
ld_base=$PWD

. ${ld_base}/../lib/shell/global_functions

for l_profile in .bashrc .profile .zshrc
do
    l_previous_version=$(awk '/BASH-GIT-VERSION/ {print $3}' ${HOME}/${l_profile})
    if [[ ${l_previous_version} != "" ]]; then
        printf "Removing bash-git references from ~/${l_profile} ... "
        l_out=`sed '/#BASH-GIT$/d' ${HOME}/${l_profile} >${ld_base}/profile.sed.out`
        if [[ $? -ne 0 ]]; then
            printf "FAILED!\nERROR: $1\n${l_out}"
            exit 101
        fi
        Run "cp ${ld_base}/profile.sed.out ${HOME}/${l_profile}"
        Run "rm ${ld_base}/profile.sed.out"
        echo DONE
        continue;  #try the next file, in case multiple shells are integrated
    fi

    l_bash_git_count=$(grep -ic "bash-git\/plugin" ${HOME}/${l_profile})
    if [[ ${l_bash_git_count} -gt 0 ]]; then
        printf "Removing bash-git references from ~/${l_profile} ... "
        l_out=`sed '/bash-git\/plugin/d' ${HOME}/${l_profile} >${ld_base}/profile.sed.out`
        Run "cp ${ld_base}/profile.sed.out ${HOME}/${l_profile}"
        if [[ $? -ne 0 ]]; then
            printf "FAILED!\nERROR: $1\n${l_out}"
            exit 101
        fi
        Run "rm ${ld_base}/profile.sed.out"
        echo DONE
        continue;  #try the next file, in case multiple shells are integrated
    fi

    l_git_info_bar_count=$(grep -ic "git-info-bar\/plugin" ${HOME}/${l_profile})
    if [[ ${l_git_info_bar_count} -gt 0 ]]; then
        printf "Removing git-info-bar references from ~/${l_profile} ... "
        l_out=`sed '/git-info-bar\/plugin/d' ${HOME}/${l_profile} >${ld_base}/profile.sed.out`
        Run "cp ${ld_base}/profile.sed.out ${HOME}/${l_profile}"
        if [[ $? -ne 0 ]]; then
            printf "FAILED!\nERROR: $1\n${l_out}"
            exit 101
        fi
        Run "rm ${ld_base}/profile.sed.out"
        echo DONE
        continue;  #try the next file, in case multiple shells are integrated
    fi
done

if [[ -d "${HOME}/.bash-git" ]]; then
    l_installed_version=$(cat ${HOME}/.bash-git/VERSION 2>/dev/null)
    printf "Removing directory ~/.bash-git ... "
    if [[ ${l_installed_version} == "1.0.1" ]]; then
        Run "rm -fr ${HOME}/.bash-git"
        echo DONE
    else
        printf "\033[7mBYPASSED!\033[0m\n  Expected ~/.bash-git/VERSION to contain '1.0.1'.\n  If you know that you do not need that directory, please remove it by hand.\n"
    fi
fi

if [[ -d "${HOME}/.git-info-bar" ]]; then
    printf "Removing directory ~/.git-info-bar ... "
    Run "rm -fr ${HOME}/.git-info-bar"
    echo DONE
fi

exit 0

