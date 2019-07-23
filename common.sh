SCRIPT_HOME=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")
source $SCRIPT_HOME/bash-installer-common/common.sh

crd_set_resolution()
{
    resolution=$1
    echo "Setting Chrome Remote Desktop resolution to $resolution"
    sed_command="s/DEFAULT_SIZE_NO_RANDR = \"[0-9]*x[0-9]*\"/DEFAULT_SIZE_NO_RANDR = \"$resolution\"/g"
    sed -i "$sed_command" /opt/google/chrome-remote-desktop/chrome-remote-desktop
}

install_desktop_environment()
{
    resolution=$1
    wants_lubuntu_desktop=$2
    desktop_package=ubuntu-mate-desktop
    if (( $wants_lubuntu_desktop )); then
        desktop_package=lubuntu-desktop
    fi

    echo "Installing virtual desktop software..."

    # Force bluetooth to install and then disable it so that it doesn't break the rest of the install.
    install_packages bluez || true
    disable_services bluetooth
    install_packages

    install_packages software-properties-common openssh-server $desktop_package
    remove_packages light-locker
    
    install_packages_from_repository ppa:x2go/stable \
        x2goserver \
        x2goserver-xsession \
        x2goclient

    install_packages_from_urls \
            https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
            https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb

    crd_set_resolution $resolution

    disable_services \
        apport \
        cpufrequtils \
        hddtemp \
        lm-sensors \
        network-manager \
        speech-dispatcher \
        ufw \
        unattended-upgrades

    echo "First time connection to the virtual desktop must be done using x2go. Once logged in, you can set up chrome remote desktop."
    echo
    echo "SSH Password authentication may be disabled by default. To enable it:"
    echo " * modify PasswordAuthentication in /etc/ssh/sshd_config"
    echo " * systemctl restart sshd"
}

check_user_exists()
{
    user=$1
    force_create=$2

    if ! does_user_exist $user; then
        if (( $force_create )); then
            useradd --create-home --shell /bin/bash --user-group $user
            echo ${user}:${user} | chpasswd
        else
            echo "User $user doesn't exist. Please use -U switch to create." 1>&2
            return 1
        fi
    fi
}

install_dev_software()
{
    echo "wireshark-common  wireshark-common/install-setuid boolean true" | debconf-set-selections

    install_packages snapd

    # Don't use snap docker because it's broken in 18.04
    install_snaps \
        lxd \
        multipass:classic:beta \

    install_packages \
        autoconf \
        bison \
        bridge-utils \
        build-essential \
        cmake \
        cpu-checker \
        debconf-utils \
        devscripts \
        dpkg-dev \
        flex \
        libnss-libvirt \
        libxml2-dev \
        libvirt-clients \
        libvirt-daemon \
        libvirt-daemon-system \
        libtool \
        mtools \
        net-tools \
        nfs-common \
        nmap \
        ovmf \
        pastebinit \
        piuparts \
        pkg-config \
        python3-argcomplete \
        python3-launchpadlib \
        python3-lazr.restfulclient \
        python3-petname \
        python3-pip \
        python3-pkg-resources \
        python3-pygit2 \
        python3-pytest \
        python3-ubuntutools \
        qemu \
        qemu-kvm \
        re2c \
        rsnapshot \
        snapcraft \
        squashfuse \
        tree \
        tshark \
        ubuntu-dev-tools \
        uvtool \
        virtinst

    add_repository_keys https://download.docker.com/linux/ubuntu/gpg
    install_packages_from_repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" docker-ce docker-ce-cli containerd.io
    install_appimage https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m) docker-compose

    install_git_repo https://github.com/kstenerud/go.git go1.12.6-warn /usr/local/go

    # Use LIBVIRT instead of QEMU due to bug launching disco
    snap set multipass driver=LIBVIRT
}

install_gui_software()
{
    install_snaps \
        sublime-text:classic \
        eclipse:classic

    install_packages \
        filezilla \
        hexchat \
        meld \
        virt-manager \
        wireshark

    install_packages_from_repository ppa:remmina-ppa-team/remmina-next remmina remmina-plugin-rdp remmina-plugin-secret remmina-plugin-spice

    install_appimage https://github.com/visualfc/liteide/releases/download/x36/liteidex36.linux64-qt5.5.1.AppImage liteide

    sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com --recv 7568D9BB55FF9E5287D586017AE645C0CF8E292A
    install_packages_from_repository "deb http://repo.pritunl.com/stable/apt bionic main" pritunl-client-electron
}

install_blackfire_agent()
{
    add_repository_keys https://packages.blackfire.io/gpg.key
    install_packages_from_repository "deb http://packages.blackfire.io/debian any main" blackfire-agent
    sudo blackfire-agent -register
    echo "To configure: $ blackfire-agent config"
    echo "If you modify the config, you must restart the agent: $ sudo /etc/init.d/blackfire-agent restart"
}

install_blackfire_probe()
{
    add_repository_keys https://packages.blackfire.io/gpg.key
    install_packages_from_repository "deb http://packages.blackfire.io/debian any main" blackfire-php
}

install_php_ubuntu()
{
    install_packages php libapache2-mod-php
    sudo systemctl restart apache2
    init_file_with_contents root /var/www/html/info.php "<?php phpinfo(); ?>"
    echo "Quick test url: http://$(get_default_ip_address)/info.php"
}
