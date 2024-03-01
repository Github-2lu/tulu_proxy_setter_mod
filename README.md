
# Project Title

Tulu Proxy Setter. To change system proxy automatically using wifi name.



# Installation

This app is originally created to run on debian and arch deriavatives.
## For Arch users

arch users can install it using PKGBUILD or from zst file in release page.\
From PKGBUILD

```bash
  makepkg
  sudo pacman -U {filename}.zst

```
To install package from zst file use second command.

## For Debian users
Download .deb file from release page
```bash
sudo dpkg -i {filename}.deb
```


# Usage/Examples

## Set or unset a proxy
To Set a Proxy. you have to first create a proxy in list.\
When adding a new proxy it automatically detects the current wifi name.
![App Screenshot](https://raw.githubusercontent.com/Github-2lu/tulu_proxy_setter_mod/master/screenshot/add_new_proxy.png)

Now select that proxy and go back to home page.\
There current proxy and proxy that is selected is shown\
Press play button to select the proxy or pause button to select any existing proxy in system.

![App Screenshot](https://raw.githubusercontent.com/Github-2lu/tulu_proxy_setter_mod/master/screenshot/set_proxy.png)

## auto proxy
*** This feature works only with bare metal linux install and with wifi.

At home screen if this option is selected then after restart it will start a background service which will set proxy automatically according to connected wifi name from proxy list you created.

If wifi name not found then it will unset proxy.

# Uninstallation
## Arch users
```bash
sudo pacman -Rcns sudoproxysetter
```
## Debian users
```bash
sudo apt remove sudoproxysetter
```

Right now it does not remove the files changed in home dir in the system.

So these changes have to be manually reverted back.

## Changes in home dir
1. Delete .tuluproxysetter folder in home dir
2. Delete tuluautoproxy.desktop file if exist in .config/autostart folder
3. Remove the following line from .bashrc and .zshrc
```bash
[[ -f ~/.tuluproxysetter/proxyVars/proxy ]] && source ~/.tuluproxysetter/proxyVars/proxy
```
