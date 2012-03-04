#!/bin/bash

#set -x
################################################################################
#
# Copyright (C) 2012
# by Justin Francis
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

cd $(dirname $0)
ld_base=$PWD
l_version=$(awk '/BASH-GIT-VERSION/ {print $3}' plugin)

function Run {
    l_out=$($1 2>&1 3>&1)
    if [[ $? -ne 0 ]]; then
        printf "FAILED!\nERROR: $1\n${l_out}"
        exit 101
    fi
}

l_installed_version=$(awk '/BASH-GIT-VERSION/ {print $3}' ~/.bashrc)
if [[ ${l_installed_version} != "" ]]; then
    echo "Found bash-git (version: ${l_installed_version})"
    printf "Are you sure you want to overwrite it? (y/n): "
    read l_answ
    if [[ $(echo ${l_answ} | grep -c -i "^y") -lt 1 ]]; then
        echo "Aborted."
        exit 100
    fi

    printf "Removing previous version ... "
    l_out=`sed '/#BASH-GIT$/d' ${HOME}/.bashrc >${ld_base}/bashrc.sed.out`
    if [[ $? -ne 0 ]]; then
        printf "FAILED!\nERROR: $1\n${l_out}"
        exit 101
    fi
    Run "cp ${ld_base}/bashrc.sed.out ${HOME}/.bashrc"
    echo DONE
fi

printf "Installing bash-git (version ${l_version}) ... "
l_out=`cat ${ld_base}/plugin >>${HOME}/.bashrc`
if [[ $? -ne 0 ]]; then
    printf "FAILED!\nERROR: $1\n${l_out}"
    exit 101
fi
echo DONE

printf "Installation is finished!

Please run the following command to begin using bash-git:

    . ~/.bashrc

Enjoy,
ComWT (https://github.com/comwt/bash-git)

"

exit 0

