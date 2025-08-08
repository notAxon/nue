# nue
small script to keep track of and manage pacman packages

## about this script

current version: 1.0.5

### ⚠️ disclaimer: use at your own risk, there won't be anyone saving you from either my or your own failures.

I wanted to manage my installed packages (native, foreign, installed via flatpak) pseudo-decleratively across multiple devices. This little script aims to fullfil those needs.

currently, this script only works with arch-based distributions, but feel free to edit its contents to match your needs. 

since not everyone might want their flatpaks to be managed, this script only takes care of packages installed via pacman or the AUR by default. This can be changed inside the script.

## installation 

copy **nue.sh** to ~/.local/bin/ or somewhere else in your path and make it executable 

```
chmod +x nue.sh # type shit
```

## usage

```
nue generate
```

will generate individual lists (native, AUR, flatpak) of installed packages which will be stored in ~/.nue/ 

> if you use something like GNU stow, you can just add ~/.nue to back up your lists

then enter 

```
nue edit packages # alternatively, append aur or flatpak respectively
```

and add a package, maybe fastfetch or something. After that, run 

```
nue sync
```

and nue will install fastfetch automatically. 

now, if you remove fastfetch from the list and run **nue sync** again, fastfetch will be removed

the **sync** option can also be used to setup a new system, just copy ~/.nue to the new machine and run **nue sync**, and you should be good to go.



