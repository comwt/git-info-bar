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
ld_dest="${HOME}/.bash-git"

. ${ld_base}/lib/shell/global_functions

#- Version 1.0.0 was placed in-line into .bashrc
#  Later versions have their own home directory, thus the second test, if the first fails
#-----------------------------------------------------------------------------------------
l_installed_version=$(awk '/BASH-GIT-VERSION/ {print $3}' ~/.bashrc)
if [[ ${l_installed_version} != "" ]]; then
    Uninstall "${l_installed_version}"
else
    if [ -f "${ld_dest}/VERSION" ]; then
        l_installed_version=$(awk '{print $1}' ${ld_dest}/VERSION)
        if [[ ${l_installed_version} != "" ]]; then
            Uninstall "${l_installed_version}"
        fi
    fi
fi

l_version=$(awk '{print $1}' VERSION)
printf "Installing bash-git (version ${l_version}) ... "
if [ ! -d '${ld_dest}' ]; then
    Run "mkdir ${ld_dest}"
fi
Run "cp ${ld_base}/License ${ld_dest}/"
Run "cp ${ld_base}/plugin ${ld_dest}/"
Run "cp ${ld_base}/VERSION ${ld_dest}/"
grep "^\. ~/.bash-git/plugin" ${HOME}/.bashrc 1>/dev/null
if [[ $? -ne 0 ]]; then
    echo ". ~/.bash-git/plugin" >>${HOME}/.bashrc
    if [[ $? -ne 0 ]]; then
        printf "FAILED!\nERROR: $1\n${l_out}"
        exit 101
    fi
fi
echo DONE

printf "Installation is finished!

Please run the following command to begin using bash-git:

    . ~/.bashrc

Enjoy,
ComWT (https://github.com/comwt/bash-git)

"

exit 0

