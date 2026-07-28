spino-enable-extensions:
    bash /usr/share/ublue-os-spinosauros/enableExtensions.sh

spino-configure-extensions:
    dconf load /org/gnome/shell/extensions/ < /usr/share/ublue-os-spinosauros/extension-settings.dconf
    
spino-install-extensions:
    bash /usr/share/ublue-os-spinosauros/installpipxandgnomeshellextensions.sh
    
