#!/bin/bash

datadir=/home/tkarraker/postgrep/

function postgrep_server () {
    while true ; do
        read msg
        case $msg in
            i | index )
                ls "${datadir}" ;;
            scan\ * )
                f=${msg#scan }
                cat ${datadir}/$f ;;
            put\ * )
                f=(${msg#put })
                table=${f[0]}
                unset f[0]
                echo ${f[*]} >> ${datadir}/$table ;;
            get\ * )
                f=(${msg#get })
                table=${f[0]}
                unset f[0]
                grep "${f[*]}" ${datadir}/$table ;;
            t | time )
                date ;;
            u | uptime )
                uptime=$(ps -eo pid,etime | grep $$ | grep -v grep | awk {'print $2'})
                echo "$(date +%T) PostGrep has been up ${uptime}" ;;
            * )
            echo "Commands: i, index; scan <file>; put <table> <text>; get <table> <string>"
                echo "    ctrl-c to exit"
        esac
        echo -n "> "
    done
}

coproc POSTGREP { postgrep_server; }

nc -l 6785 -k <&${POSTGREP[0]} >&${POSTGREP[1]}
