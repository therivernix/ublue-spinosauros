enable-extensions:
    bash /etc/customscripts/enableExtensions.sh

configure-extensions:
    dconf load /org/gnome/shell/extensions/ < /etc/customscripts/extension-settings.dconf
    
install-extensions:
    gnome-extensions install --force /etc/customscripts/tailscale-gnome-qstailscale-qs.github.io.v14.shell-extension.zip
    gnome-extensions install --force /etc/customscripts/clipboard-indicatortudmotu.com.v71.shell-extension.zip
    
