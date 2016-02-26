#!/bin/bash

# 取自 http://davidaq.com/technique/share/2015/08/10/shell-console-color-table.html

T='Text'
echo -e "         --       40       41       42       43       44       45       46       47 "
for FGs in '   0' '   1' '  30' '1;30' '  31' '1;31' '  32' '1;32' '  33' '1;33' '  34' '1;34' '  35' '1;35' '  36' '1;36' '  37' '1;37'
    do FG=${FGs// /}m 
    echo -en " $FGs \033[$FG  $T  "
    for BG in 40m 41m 42m 43m 44m 45m 46m 47m 
        do echo -en "$EINS \033[$FG\033[$BG  $T \033[0m\033[$BG \033[0m"
    done
    echo
done
echo -e "\033[0m"
