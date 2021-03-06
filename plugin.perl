################################################################################
# Plugin     : git-info-bar
# Author     : Justin Francis
# Created    : 2012-03-03
# Source URL : https://github.com/comwt/git-info-bar
#
# Purpose    : Provides a Git 'info bar' (information bar) when you are under
#              a git repository.  It displays the following information:
#                - current branch (in 'red' if on main or master)
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

    export COLUMNS

    /usr/bin/env perl <<'EOF'
use strict;
use 5.4.0;

my $l_columns = $ENV{'COLUMNS'} || 0;

#- Get the current branch and sha1 cksum all in one blow
#---------------------------------------------------------
my $l_out = qx(git branch --verbose 2>/dev/null | grep ^\*);
$l_out =~ /^\*\s+(.*?)\s+([a-z0-9]+)/i;
my ( $l_git_branch, $l_git_sha1 ) = ( $1, $2 );

if ( ! ${l_git_branch} ) {
    GIT_CHECK: {
        my $l_dir = $ENV{"PWD"};
        $l_dir =~ s/[\\\/]$//;
        LOOP_A: {
            do {
                last GIT_CHECK if ( -e "${l_dir}/.git/config" );
                last LOOP_A if ( ! $l_dir );
                if ( $l_dir =~ /^([\\\/].+?)[\\\/].*$/ ) {
                    $l_dir = $1;
                } elsif ( $l_dir =~ /^[\\\/].+?/ ) {
                    $l_dir = "";
                }
            } while ( 1 );
        }
        exit; #not a repo, quit
    }
    #- this directory is part of a Git repository if we get here
}

my $l_hlt ="\033[30;47m"; #(highlight)    white background/black foreground
my $l_inf ="\033[31m";    #(message info) red foreground
my $l_int ="\033[1m";     #(intensity)    intensifies foreground
my $l_blufg ="\033[34;47m";    #(normal info)  blue foreground
my $l_blubg ="\033[37;44m";    #(normal info)  blue background
my $l_maj ="\033[41;37m"; #(major info)   red background/white foreground
my $l_rst ="\033[m";      #(reset)        original terminal colors
my $l_msg = "";

if ( ${l_git_branch} eq "main" || ${l_git_branch} eq "master" ) {
    $l_git_branch = "${l_maj}${l_git_branch}${l_hlt}";
} else {
    $l_git_branch = "${l_blufg}${l_git_branch}${l_hlt}";
}

#- Get the branches SHA1 cksum
#------------------------------
if ( ! ${l_git_sha1} ) {
    $l_git_sha1 = 'stateless';
}

#- If you need more speedy responses on large repositories, this is where
#  you need to look.  git status takes much longer than the other commands.
#- The --porcelain option to 'git status' was added in Git version 1.7.0.
#---------------------------------------------------------------------------
my $l_changes;
my $l_use_porcelain_TF = ( qx(git version) =~ /version (?:0|1\.[0-6])/ ) ? 0 : 1;
if ( ${l_use_porcelain_TF} ) {
    $l_changes = qx(git status --porcelain 2>/dev/null | wc -l);
} else {
    foreach ( qx(git status 2>/dev/null) ) {
        $l_changes++ if ( /^#\t/ );
    }
}
chomp( $l_changes );
$l_changes =~ s/^.*?(\d+)/$1/;
if ( ${l_changes} ) {
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
my @la_stash = qx( git stash list 2>&1 3>&1 );
if ( "@la_stash" !~ /fatal.*working tree/ && @la_stash ) {
    $l_msg = "${l_msg} / ${l_int}${l_blubg}STASHES: " . scalar(@la_stash) . "${l_blufg}";
}

#- Print the 'Info Bar'
#-----------------------
print "\n${l_hlt}" . " "x${l_columns} . "${l_rst}\r"
    . "${l_hlt}  ${l_int}BRANCH:${l_rst}${l_hlt} ${l_git_branch}  (${l_git_sha1})${l_msg}  ${l_rst}\n\$ ";
EOF

}

export COLUMNS
PS1="${PS1}\$(Func_GitCheck)"
