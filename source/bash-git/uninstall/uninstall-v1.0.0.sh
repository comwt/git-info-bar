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

. ${ld_base}/../lib/shell/global_functions

l_previous_version=$(awk '/BASH-GIT-VERSION/ {print $3}' ${HOME}/.bashrc)
if [[ ${l_previous_version} != '1.0.0' ]]; then
    echo "Version ${l_previous_version} is installed.  Aborting."
    exit 100
fi

printf "Removing bash-git version 1.0.0 ... "
l_out=`sed '/#BASH-GIT$/d' ${HOME}/.bashrc >${ld_base}/bashrc.sed.out`
if [[ $? -ne 0 ]]; then
    printf "FAILED!\nERROR: $1\n${l_out}"
    exit 101
fi
Run "cp ${ld_base}/bashrc.sed.out ${HOME}/.bashrc"
Run "rm ${ld_base}/bashrc.sed.out"
echo DONE

exit 0

