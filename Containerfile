FROM quay.io/toolbx/arch-toolbox:latest

# yes putting pacman key in a container image is "bad"
# but this is a very low volume image and i dont care
RUN pacman-key --init && \
    pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com && \
    pacman-key --lsign-key 3056513887B78AEB && \
    pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' && \
    pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst' && \
    echo -ne "\n\n[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist\n" | tee -a /etc/pacman.conf

# set pacman mirrors
RUN pacman -Sy --needed --noconfirm reflector && \
    reflector --country us --save /etc/pacman.d/mirrorlist --protocol https --latest 25 --fastest 5

COPY ./extra-packages ./aur-packages /
RUN pacman -Syu --needed --noconfirm - < /extra-packages && \
    pacman -Scc --noconfirm --clean

# run yay as temp user
# yay tries to read /dev/tty as stdin, there is no tty here! ugh
RUN useradd yaybuilder --groups wheel --create-home && \
    sudo -u yaybuilder yay -Sy --noconfirm `cat /aur-packages` && \
    userdel yaybuilder --remove && \
    pacman -Scc --noconfirm --clean

RUN rm /extra-packages /aur-packages

# twiddle some pacman settings
RUN sed -i -E /etc/pacman.conf \
        -e 's/^#Color/Color/' \
        -e 's/^NoProgressBar/#NoProgressBar/' \
        -e '\|^NoExtract.+usr/share/man|d' && \
    sed -i -E /etc/makepkg.conf \
        -e 's/^#MAKEFLAGS=.+/MAKEFLAGS="-j$(nproc)"/'

# pre set distrobox host links
RUN ln -s /usr/bin/distrobox-host-exec /usr/local/bin/firefox && \
    ln -s /usr/bin/distrobox-host-exec /usr/local/bin/systemctl && \
    ln -s /usr/bin/distrobox-host-exec /usr/local/bin/xdg-open && \
    ln -s /usr/bin/distrobox-host-exec /usr/local/bin/journalctl && \
    ln -s /usr/bin/distrobox-host-exec /usr/local/bin/podman && \
    ln -s /usr/bin/distrobox-host-exec /usr/local/bin/flatpak
