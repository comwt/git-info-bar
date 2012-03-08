
#use whatever shell you want, invoke as '${SHELL} install.sh'

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

l_out=`/usr/bin/env perl -e 'use 5.4.0'` #require minimum of Perl 5.4
l_out=`fakecmd123` #require minimum of Perl 5.4
if [[ $? -ne 0 ]]; then
    echo "[WARN] Missing dependency -> Perl 5.4.0 or greater"
    if [[ ${l_shell} != "bash" && ${l_shell} != "ksh" ]]; then
        echo "Bash is the only supported SHELL at this time."
        exit 101
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
l_profile=
case "${l_shell}" in
    bash ) l_profile=".bashrc"  ;;
    ksh  ) l_profile=".profile" ;;
    zsh  ) l_profile=".zshrc"   ;;
esac
l_installed_version=`awk '/BASH-GIT-VERSION/ {print $3}' ~/${l_profile}`
if [[ ${l_installed_version} != "" ]]; then
    #- Uninstall Version 1.0.0
    #--------------------------
    Uninstall "${l_installed_version}"
else
    if [[ -f "${ld_dest}/VERSION" ]]; then
        #- Uninstall Version 1.0.1
        #--------------------------
        l_installed_version=`awk '{print $1}' ${ld_dest}/VERSION`
        if [[ ${l_installed_version} != "" ]]; then
            Uninstall "${l_installed_version}"
        fi
    else
        ld_dest="${HOME}/.git-info-bar"
        if [[ -f "${ld_dest}/VERSION" ]]; then
            #- Uninstall Version 1.1.0 or later
            #-----------------------------------
            l_installed_version=`awk '{print $1}' ${ld_dest}/VERSION`
            if [[ ${l_installed_version} != "" ]]; then
                Uninstall "${l_installed_version}"
            fi
        fi
    fi
fi

l_version=`awk '{print $1}' VERSION`
printf "[INFO] Installing git-info-bar (version ${l_version}) ... "
if [[ ! -d "${ld_dest}" ]]; then
    l_out=$(mkdir ${ld_dest} 2>&1)
    if [[ $? -ne 0 ]]; then
        printf "FAILED!\nERROR: $1\n${l_out}"
        exit 101
    fi
fi
#if [[ ! -d "${ld_dest}" ]]; then
#    Run "mkdir ${ld_dest}"
#fi
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
#Run "cp ${ld_base}/License ${ld_dest}/"
#Run "cp ${ld_base}/${lf_plugin} ${ld_dest}/plugin"
#Run "cp ${ld_base}/VERSION ${ld_dest}/"
case "${l_shell}" in
    bash|ksh )
               grep "^\. ~/.git-info-bar/plugin" ${HOME}/${l_profile} 1>/dev/null
               if [[ $? -ne 0 ]]; then
                   echo ". ~/.git-info-bar/plugin" >>${HOME}/${l_profile}
                   if [[ $? -ne 0 ]]; then
                       printf "FAILED!\nERROR: $1\n${l_out}"
                       exit 101
                   fi
               fi
               ;;

    zsh      ) l_profile=".zshrc"
               echo "Unsupported shell (${l_shell}) - try bash or ksh"
               exit 101
               ;;

    *        ) echo "Unsupported shell (${l_shell}) - try bash or ksh"
               exit 101;
               ;;
esac
echo DONE

printf "Installation is finished!

Please run the following command to begin using git-info-bar:

    . ~/${l_profile}

Enjoy,
ComWT (https://github.com/comwt/git-info-bar)

"

exit 0

