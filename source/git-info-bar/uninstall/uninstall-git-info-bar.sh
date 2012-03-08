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

l_previous_version=$(awk '/BASH-GIT-VERSION/ {print $3}' ${HOME}/.bashrc)
if [[ ${l_previous_version} == '1.0.0' ]]; then
    echo "Version 1.0.0 is installed.  Aborting."
    exit 100
fi
if [ -f "${HOME}/.bash-git/VERSION" ]; then
    echo "Version 1.0.1 is installed.  Aborting."
    exit 100
fi
if [ ! -f "${HOME}/.git-info-bar/VERSION" ]; then
    echo "git-info-bar does not appear to be installed."
    exit 0
fi

l_previous_version=$(awk '{print $1}' ${HOME}/.git-info-bar/VERSION)

printf "Removing git-info-bar version ${l_previous_version} ... "
if [ -d "${HOME}/.git-info-bar" ]; then
    Run "rm -fr ${HOME}/.git-info-bar"
fi
l_out=`sed '/git-info-bar\/plugin/d' ${HOME}/.bashrc >${ld_base}/bashrc.sed.out`
Run "cp ${ld_base}/bashrc.sed.out ${HOME}/.bashrc"
if [[ $? -ne 0 ]]; then
    printf "FAILED!\nERROR: $1\n${l_out}"
    exit 101
fi
Run "rm ${ld_base}/bashrc.sed.out"
echo DONE

exit 0

