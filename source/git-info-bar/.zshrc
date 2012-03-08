. ~/.my_profile
#- Trash Can
TRASHDIR=/home/jfrancis/.trash   #-- User's TRASH DIRectory
TBINDIR=/home/jfrancis/.trash     #-- Trash BINary DIRectory
alias delete="/usr/bin/zsh ${TBINDIR}/trash.sh -rest ${TRASHDIR} -d "
alias empty="/usr/bin/zsh ${TBINDIR}/trash.sh -empty ${TRASHDIR} "
alias prm="/usr/bin/zsh ${TBINDIR}/trash.sh -prm ${TRASHDIR} "
alias purge="/usr/bin/zsh ${TBINDIR}/trash.sh -purge ${TRASHDIR} "
alias trestore="/usr/bin/zsh ${TBINDIR}/trash.sh -rest ${TRASHDIR} "
alias rm="/usr/bin/zsh ${TBINDIR}/trash.sh -rm ${TRASHDIR} "  #-- Same as 'throw'
alias throw="/usr/bin/zsh ${TBINDIR}/trash.sh -rm ${TRASHDIR} "  #-- Same as 'rm'
alias tkeep="/usr/bin/zsh ${TBINDIR}/trash.sh -keep ${TRASHDIR} "  #-- Configure keep days
alias tmax="/usr/bin/zsh ${TBINDIR}/trash.sh -tmax ${TRASHDIR} "  #-- Configure capacity
alias trash="/usr/bin/zsh ${TBINDIR}/trash.sh -list ${TRASHDIR} "  #-- Trash Specs/Contents
purge #-- Daily Old Trash Purge

. ~/.git-info-bar/plugin
