#!/usr/bin/env bash

#         ::::    ::: :::    ::: :::::::::: 
#        :+:+:   :+: :+:    :+: :+:         
#       :+:+:+  +:+ +:+    +:+ +:+          
#      +#+ +:+ +#+ +#+    +:+ +#++:++#      
#     +#+  +#+#+# +#+    +#+ +#+            
#    #+#   #+#+# #+#    #+# #+#             
#   ###    ####  ########  ##########       
#
# little bash script to keep track of your installed packages and manage them via a textfile

version=1.0.5

tmpdir=$(mktemp -d)
nuedir=~/.nue

# lists of installed packages
pacfile=$nuedir/packages.txt
aurfile=$nuedir/aur.txt
flatpakfile=$nuedir/flatpak.txt
    #whether to manage flatpaks, set to true to enable
manageflatpaks=false

# split into non-aur and aur packages
function pacsplit {
  pacman -Qq > ${tmpdir}/pacfile_all.tmp
  pacman -Qqm > ${tmpdir}/aur.tmp
  grep -vf ${tmpdir}/aur.tmp ${tmpdir}/pacfile_all.tmp > ${tmpdir}/pacfile.tmp 
}

# document all installed packages 
function generate {
  # filter out aur packages
  pacsplit
  cp ${tmpdir}/aur.tmp $aurfile 
  cp ${tmpdir}/pacfile.tmp $pacfile 

  if [[ $manageflatpaks = true ]]; then
    flatpak list --columns=application > $flatpakfile
  fi
}

function diff {
  cat $1 $2 | sort | uniq -u > ${tmpdir}/$3-big.txt
  
  grep -vf $1 ${tmpdir}/$3-big.txt > ${tmpdir}/$3-add
  grep -vf $2 ${tmpdir}/$3-big.txt > ${tmpdir}/$3-remove

}

# install all packages from $pacfile, $aurfile and $flatpakfile, remove everything else
function sync {
  pacsplit 
  diff ${tmpdir}/pacfile.tmp $pacfile pacman

  pacmod "sudo pacman" -Rsn ${tmpdir}/pacman-remove
  pacmod "sudo pacman" -S ${tmpdir}/pacman-add
 
  diff ${tmpdir}/aur.tmp $aurfile aur
  # make sure to not use this script on your work computer or something
  pacmod "yay" -Rsn ${tmpdir}/aur-remove
  pacmod "yay" -S ${tmpdir}/aur-add

  if [[ $manageflatpak = true ]]; then
    flatpak list --app --columns=application > ${tmpdir}/flatpak.tmp
    diff ${tmpdir}/flatpak.tmp $flatpakfile flatpak 
    # installation and removal blah blah
    flatpak install flathub $(<"${tmpdir}/flatpak-add")
    flatpak remove flathub $(<"${tmpdir}/flatpak-remove")
  fi
}

function helpmsg {
  echo "nue - small script to keep track of and manage pacman packages.

help:
    help  - show this help message
    sync  - install/remove packages according to config files 
    generate - generate files containing a list of packages    
    edit packages|aur|flatpak - directly edit one of the files with your preferred editor
    "
}

set -eu

if [[ ! -d $nuedir ]]; then 
  mkdir $nuedir > /dev/null 2>&1 && generate
fi 

case ${1} in

sync | -s) sync ;;

gen | -g) generate ;;

help | -h) helpmsg ;;

edit | -e) $EDITOR ${nuedir}/${2}.txt ;;

version | -v) echo ${version} ;;

*) echo "unknown option, use nue help to see all options" && exit

esac

rm -r $tmpdir
