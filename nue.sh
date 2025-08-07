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

version=1.0.4


tmpdir=$HOME/.cache/nue
nuedir=$HOME/.nue

# lists of installed packages
pacfile=$nuedir/packages.txt
aurfile=$nuedir/aur.txt
flatpakfile=$nuedir/flatpak.txt
    #whether to manage flatpaks, uncomment to enable
#manageflatpaks=true


# split into non-aur and aur packages
function pacsplit {
  pacman -Qq > $tmpdir/pacfile_all.tmp
  pacman -Qqm > $tmpdir/aur.tmp
  grep -vf $tmpdir/aur.tmp $tmpdir/pacfile_all.tmp > $tmpdir/pacfile.tmp 
}

# document all installed packages 
function generate {
  # filter out aur packages
  pacsplit
  cp $tmpdir/aur.tmp $aurfile 
  cp $tmpdir/pacfile.tmp $pacfile 

  if [[ $manageflatpaks = true ]]; then
    flatpak list --columns=application > $flatpakfile
  fi
}

function diff {
  cat $1 $2 | sort | uniq -u > $tmpdir/$3-big.txt
  
  grep -vf $1 $tmpdir/$3-big.txt > $tmpdir/$3-add
  grep -vf $2 $tmpdir/$3-big.txt > $tmpdir/$3-remove

}

# install all packages from $pacfile, $aurfile and $flatpakfile, remove everything else
function sync {
  pacsplit 
  diff $tmpdir/pacfile.tmp $pacfile pacman

  pacmod "sudo pacman" -Rsn $tmpdir/pacman-remove
  pacmod "sudo pacman" -S $tmpdir/pacman-add
 
  diff $tmpdir/aur.tmp $aurfile aur
  # make sure to not use this script on your work computer or something
  pacmod "yay" -Rsn $tmpdir/aur-remove
  pacmod "yay" -S $tmpdir/aur-add

  if [[ $manageflatpak = true ]]; then
    flatpak list --app --columns=application > $tmpdir/flatpak.tmp
    diff $tmpdir/flatpak.tmp $flatpakfile flatpak 
    # installation and removal blah blah
    flatpak install flathub $(<"$tmpdir/flatpak-add")
    flatpak remove flathub $(<"$tmpdir/flatpak-remove")
  fi
}

#install or remove packages from a list, $1 are pacman options, $2 is the file containing the packages
#not in use, but I'd like to keep it 
function pacmod {
  while IFS= read -r pkgs; do 
    $1 $2 --noconfirm $pkgs
  done < "$3"
}

function helpmsg {
  echo "nue - small script to keep track of and manage pacman packages.

help:
    help  - show this help text
    sync  - install/remove packages according to config files 
    generate - generate files containing a list of packages    
    edit packages|aur|flatpak - directly edit one of the files with your preferred editor
    "
}

#create necessary directories if they do not exist
declare -a arr=("$tmpdir" "$nuedir" )

for i in "${arr[@]}" 
do
  if [[ ! -d $i ]]; then 
    mkdir $i > /dev/null 2>&1 && generate
  fi 
done
  

if [[ $1 = sync ]]; then
  sync
elif [[ $1 = generate ]]; then
  generate
elif [[ $1 = help ]]; then
  helpmsg
elif [[ $1 = edit ]]; then
  $EDITOR $nuedir/$2.txt
elif [[ $1 = init ]]; then
  init
elif [[ $1 = version ]]; then
  echo $version
else 
  echo "unknown option, use nue help to see all options" && exit
fi


