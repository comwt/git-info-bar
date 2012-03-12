################################################################################
# Plugin     : git-info-bar
# Author     : Justin Francis
# Created    : 2012-03-03
# Source URL : https://github.com/comwt/git-info-bar
#
# Purpose    : Provides a Git 'info bar' (information bar) when you are under
#              a git repository.  It displays the following information:
#                - current branch (in 'red' if on master)
#                - current cksum (in 'red' if there are uncommitted changes
#                  and displays an 'uncommitted changes' message in the message
#                  area)
#                - stash count in the message area if you have stashes
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
function Func_GitCheck {

/usr/bin/env perl <<'EOF'
use strict;
use 5.4.0;

my ( $l_columns, @la_other );

#foreach ( sort keys %{ENV} ) {
#  print qq(ENV: $_ = $ENV{"$_"}\n);
#}

if ( $ENV{'OS'} && $ENV{'OS'} =~ /Windows/i ) {
    $l_columns = $ENV{'COLUMNS'} || 0;  #gitbash for MS Windows integration
} else {
    eval "use Term::ReadKey";
    ( $l_columns, @la_other ) = ( $@ ) ? (0,0) : ( GetTerminalSize() );
}

#- Get the current branch
#-------------------------
my $l_git_branch = qx(git branch 2>/dev/null|awk '\$1 == "*" {print \$2}');
exit if ( ! ${l_git_branch} );
chomp( $l_git_branch );

my $l_hlt ="\033[30;47m"; #(highlight)    white background/black foreground
my $l_inf ="\033[31m";    #(message info) red foreground
my $l_int ="\033[1m";     #(intensity)    intensifies foreground
my $l_blufg ="\033[34;47m";    #(normal info)  blue foreground
my $l_blubg ="\033[37;44m";    #(normal info)  blue background
my $l_maj ="\033[41;37m"; #(major info)   red background/white foreground
my $l_rst ="\033[m";      #(reset)        original terminal colors
my $l_msg = "";

if ( ${l_git_branch} eq "master" ) {
    $l_git_branch = "${l_maj}${l_git_branch}${l_hlt}";
} else {
    $l_git_branch = "${l_blufg}${l_git_branch}${l_hlt}";
}

#- Get the branches SHA1 cksum
#------------------------------
my $l_git_sha1 = qx(git branch --verbose 2>/dev/null|awk '\$1 == "*" {print \$3}');
chomp( $l_git_sha1 );

#- If you need more speedy responses on large repositories, this is where
#  you need to look.  git status takes much longer than the other commands.
#---------------------------------------------------------------------------
my $l_changes = qx(git status --porcelain 2>/dev/null | wc -l);
chomp( $l_changes );
if ( ${l_changes} ne 0 ) {
    $l_git_sha1 = "${l_maj}${l_git_sha1}${l_hlt}";
    $l_msg = "${l_msg} / ${l_changes} uncommitted";
    if ( ${l_changes} eq 1 ) {
        $l_msg = "${l_msg} change";
    } else {
        $l_msg = "${l_msg} changes";
    }
} else {
    $l_git_sha1 = "${l_blufg}${l_git_sha1}${l_hlt}";
}

$l_msg = "${l_inf}${l_msg}";

#- Show STASH stack count, if there is a stash
#----------------------------------------------
my $l_stash_cnt = qx(git stash list | wc -l | awk '{print \$NF}');
chomp( $l_stash_cnt );
if ( ${l_stash_cnt} gt 0 ) {
    $l_msg = "${l_msg} / ${l_int}${l_blubg}STASHES: ${l_stash_cnt}${l_blufg}";
}

#- Print the 'Info Bar'
#-----------------------
print "\n${l_hlt}" . " "x${l_columns} . "${l_rst}\r"
    . "${l_hlt}  ${l_int}BRANCH:${l_rst}${l_hlt} ${l_git_branch}  (${l_git_sha1})${l_msg}  ${l_rst}\n\$ ";
EOF

}

PS1="${PS1}\$(Func_GitCheck)"
