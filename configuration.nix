{ config, ... }:

let
  pkgs = import /home/sephi/projects/nixpkgs { config.allowUnfree = true; };
  taxi = import <taxi>;
  unstable = import (builtins.fetchGit {
    # Descriptive name to make the store path easier to identify
    name = "nixos-unstable-2021-03-17";
    url = "/home/sephi/projects/nixpkgs";
    # Commit hash for nixos-unstable
    # `git ls-remote https://github.com/nixos/nixpkgs nixos-unstable`
    ref = "refs/remotes/origin/nixos-unstable";
    rev = "266dc8c3d052f549826ba246d06787a219533b8f";
  }) { config.allowUnfree = true; };
  emacs = pkgs.emacsWithPackages (epkgs: (with epkgs.melpaStablePackages; [
    epkgs.vterm
  ]));

  xkbLayout = pkgs.writeText "xkb-layout" ''
    xkb_symbols "dvpintl" {
    	include "us(dvp)+compose(rctrl)+level3(ralt_switch)+capslock(escape_shifted_capslock)"

    	key <AD04> { [         p,       P,  ediaeresis,     Ediaeresis ] };
    	key <AD05> { [         y,       Y,  udiaeresis,     Udiaeresis ] };
    	key <AD08> { [         c,       C,  ccedilla,       Ccedilla ] };
        key <AD03> { [    period, greater,  guillemotright, U2027 ] };
    
    	key <AC01> { [         a,       A,      agrave, Agrave ] };
    	key <AC02> { [         o,       O, ocircumflex, Ocircumflex ] };
    	key <AC03> { [         e,       E,      eacute, Eacute ] };
    	key <AC04> { [         u,       U, ucircumflex, Ucircumflex ] };
    	key <AC05> { [         i,       I, icircumflex, Icircumflex ] };
    	key <AC10> { [         s,       S,      ssharp, U1E9E ] };
    
        key <AB01> { [ rightsinglequotemark, quotedbl, apostrophe, dead_doubleacute ] };
    	key <AB02> { [         q,       Q,  odiaeresis, dead_ogonek ] };
    	key <AB03> { [         j,       J,      egrave, Egrave ] };
    	key <AB04> { [         k,       K,      ugrave, Ugrave ] };
    	key <AB05> { [         x,       X,  idiaeresis, Idiaeresis ] };
    
    	key <SPCE> { [     space,   space, nobreakspace, U202F ] };
    };
  '';
in
{
  imports =
    [
      <nixos-hardware/lenovo/thinkpad/t470s>
      ./hardware-configuration.nix
    ];

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "20.03";

  ########
  # BOOT #
  ########

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.efiInstallAsRemovable = true;
  boot.loader.grub.device = "nodev"; # "nodev" for efi only
  boot.tmpOnTmpfs = true;

  boot.initrd.luks.devices = {
    root = {
      device = "/dev/disk/by-uuid/ddd25652-25a5-4886-a625-5bbc345cb36e";
      preLVM = true;
    };
  };

  ##############
  # NETWORKING #
  ##############

  networking.hostName = "midgar";
  networking.useDHCP = false;
  networking.interfaces.enp0s31f6.useDHCP = true;
  networking.interfaces.wlp58s0.useDHCP = true;
  networking.interfaces.wwp0s20f0u6i12.useDHCP = true;
  networking.networkmanager.enable = true;
  programs.nm-applet.enable = true;
  networking.enableIPv6 = false;
  networking.networkmanager.dns = "dnsmasq";
  networking.firewall.allowedTCPPorts = [ 3000 8000 ];
  networking.extraHosts = ''
    192.168.100.201 raspberry
  '';
  # https://github.com/nix-community/nixops-libvirtd/
  networking.firewall.checkReversePath = false;

  ########
  # I18N #
  ########

  i18n = {
    defaultLocale = "en_US.UTF-8";
  };
  console.font = "Lat2-Terminus16";
  console.useXkbConfig = true;

  # Required for redshift
  location.latitude = 46.5189;
  location.longitude = 6.636;

  time.timeZone = "Europe/Zurich";

  ############
  # PACKAGES #
  ############

  environment.systemPackages = with pkgs; [
    # X
    gvfs
    i3
    i3lock-fancy
    i3-gaps
    i3status-rust
    networkmanagerapplet
    networkmanager-openvpn
    # Required by EnergiaPro VPN
    networkmanager-l2tp
    strongswan
    networkmanager_strongswan
    # End
    xorg.xkbcomp
    xorg.xmodmap
    xorg.xev
    xorg.xrandr
    xfce.thunar
    xfce.tumbler  # to generate thumbnails
    xfce.gvfs
    xfce.xfce4-icon-theme
    lxappearance
    stilo-themes
    tango-icon-theme
    brightnessctl
    neocomp
    xclip
    polybarFull
    siji  # font for polybar

    # Languages
    (python3.withPackages(ps: [
      ps.isort
      ps.virtualenv
      ps.setuptools
      ps.black
      ps.flake8
      ps.python-language-server
      ps.pyls-mypy
      ps.pyls-isort
      ps.pyls-black
      ps.pyflakes
    ]))
    python37
    nodejs
    gcc  # required to compile some libs
    elmPackages.elm
    elmPackages.elm-format
    unstable.elmPackages.elm-language-server
    elmPackages.elm-test
    elmPackages.elm-live
    rustc
    rust-analyzer
    cargo
    rustfmt
    nixfmt

    # Python packages
    python3Packages.twine
    autoflake

    # Fonts
    terminus_font
    inconsolata
    font-awesome_4
    powerline-fonts
    twitter-color-emoji
    source-code-pro  # For i3status-rust

    # Utilities
    direnv
    ffmpeg
    git
    pinentry  # To ask for gpg passphrase
    pinentry-gnome
    htop
    httpie
    rxvt_unicode
    kitty
    ranger
    vimHugeX  # Package vim doesn't have X clipboard support
    wget
    ripgrep
    redir
    man
    gnupg
    pavucontrol
    yubikey-personalization
    libu2f-host
    fzy
    fzf  # for fisher fzf package
    gnumake
    dnsutils  # dig
    gitAndTools.diff-so-fancy
    ntfs3g
    unzip
    unrar
    youtube-dl
    exfat
    securefs
    duplicity
    nmap
    ansible
    wcalc
    playerctl
    zip
    telnet
    fd
    gitAndTools.gh
    cookiecutter
    (taxi.taxi.withPlugins [ taxi.taxi_clockify taxi.taxi_zebra ])
    openvpn
    steam-run
    scrot
    unstable.manix  # not available in stable yet
    gettext
    protonvpn-cli
    protonvpn-gui
    cmake  # to compile vterm in emacs
    libtool  # to compile vterm in emacs
    editorconfig-core-c

    # Apps
    arandr
    evince
    firefox
    gimp
    gnome3.gnome-keyring
    gnome3.zenity
    gnome3.file-roller
    irssi
    klavaro
    libreoffice
    mplayer
    nitrogen
    signal-desktop
    simplescreenrecorder
    slack
    smplayer
    spotify
    transmission-gtk
    viewnior
    darktable
    poedit
    godot
    element-desktop
    krita
    discord
    emacs
    apache-directory-studio
    inkscape
    insomnia

    # Services
    mailhog
    upower  # show battery in i3status-rust

    cryptsetup

    vagrant
    lxc
    # Needed for the helpful `lxc network create` command
    lxd
    docker
    docker-compose
    keepassxc
    avahi

    # Misc
    samsung-unified-linux-driver
    hfsprogs
  ];

  programs.fish.enable = true;
  programs.xss-lock.enable = true;
  programs.xss-lock.lockerCommand = "${pkgs.i3lock-fancy}/bin/i3lock-fancy -t 'Welcome back'";
  programs.xss-lock.extraOptions = [ "-l" ];
  programs.ssh.startAgent = true;
  programs.seahorse.enable = true;
  programs.adb.enable = true;
  programs.steam.enable = true;

  ############
  # SERVICES #
  ############

  services.emacs = {
    enable = true;
    defaultEditor = true;
    package = emacs;
  };
  services.redshift.enable = true;
  services.compton.enable = true;
  services.compton.inactiveOpacity = 1.0;
  services.compton.vSync = true;
  services.compton.backend = "glx";
  services.clipmenu.enable = true;
  #services.jack.jackd.enable = true;  # for sonic-pi to work

  services.postgresql.enable = true;
  services.postgresql.package = pkgs.postgresql_11;
  services.postgresql.ensureUsers = [
    {
      name = "sephi";
      ensurePermissions = {
        "ALL TABLES IN SCHEMA public" = "ALL PRIVILEGES";
      };
    }
  ];

  services.redis.enable = true;

  services.gvfs.enable = true;
  services.avahi.enable = true;
  services.mailhog.enable = true;
  services.upower.enable = true;

  services.printing.enable = true;
  services.printing.drivers = [ pkgs.samsung-unified-linux-driver pkgs.hplipWithPlugin ];

  services.lorri.enable = true;

  # X11
  services.xserver.enable = true;
  services.xserver.layout = "dvpintl";
  services.xserver.extraLayouts = {
    dvpintl = {
      description = "International programmer dvorak.";
      languages = [ "eng" "fre" ];
      symbolsFile = xkbLayout;
    };
  };
  services.xserver.autoRepeatInterval = 30;
  services.xserver.autoRepeatDelay = 300;
  services.xserver.desktopManager.xterm.enable = false;
  services.xserver.windowManager.i3.enable = true;
  services.xserver.windowManager.i3.package = pkgs.i3-gaps;
  services.gnome3.gnome-keyring.enable = true;
  services.xserver.desktopManager.wallpaper.mode = "fill";
  services.xserver.displayManager.sessionCommands = ''
    xset b off
    xset s off
    xset -dpms
  '';

  # Syncthing
  services.syncthing.enable = true;
  services.syncthing.user = "sephi";
  services.syncthing.group = "users";
  services.syncthing.dataDir = "/home/sephi/syncthing";
  services.syncthing.declarative.folders = {
    "/home/sephi/syncthing/midgar" = {
      devices = [ "oneplus" ];
      id = "midgar";
    };

    "/home/sephi/syncthing/oneplus" = {
      devices = [ "oneplus" ];
      id = "oneplus_a3003_3zjp-photos";
      type = "receiveonly";
    };
  };
  services.syncthing.declarative.devices = {
    oneplus = {
      id = "T6ZR2GE-MSOTYE4-72GWFXN-5WSHHFI-QRYD25J-TSWOZHD-JK5R5FK-RTMYVQR";
    };
  };

  # Input
  services.xserver.libinput.enable = true;
  services.xserver.libinput.tapping = false;
  services.xserver.libinput.clickMethod = "clickfinger";
  services.xserver.libinput.accelSpeed = "0.0348675";

  services.udev.packages = [
    pkgs.yubikey-personalization
    pkgs.libu2f-host
  ]; 

  sound.enable = true;
  sound.mediaKeys.enable = true;
  hardware.pulseaudio.enable = true;
  hardware.opengl.enable = true;
  hardware.opengl.driSupport32Bit = true;

  #########
  # USERS #
  #########

  users.users.sephi = {
    isNormalUser = true;
    extraGroups = [
      "wheel" 
      "video" 
      "docker" 
      "lxd" 
      "networkmanager" 
      "syncthing" 
      "adbusers" 
      "jackaudio"
      "libvirtd"
    ];
    shell = pkgs.fish;
  };
  security.sudo.extraRules = [
    {
      users = [ "sephi" ];
      commands = [
        {
          command = "${pkgs.protonvpn-cli}/bin/protonvpn";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  ##################
  # VIRTUALISATION #
  ##################

  virtualisation.docker.enable = true;
  virtualisation.lxc.enable = true;
  # Reenable if problems with lxc networking
  virtualisation.lxd.enable = true;
  virtualisation.lxc.defaultConfig = ''
    lxc.net.0.type = veth
    lxc.net.0.link = lxcbr0
  '';
  virtualisation.libvirtd.enable = true;

  ########
  # MISC #
  ########

  fonts.fonts = [
    pkgs.dejavu_fonts
    pkgs.font-awesome_4
    pkgs.inconsolata
    pkgs.terminus_font
  ];

  nixpkgs.config.allowUnfree = true;
  security.apparmor.enable = true;
  security.apparmor.packages = [ pkgs.lxc ];

  environment.etc = {
    "NetworkManager/dnsmasq.d/pontsun".text = ''
      address=/pontsun.test/127.0.0.1
      strict-order
    '';
    "NetworkManager/dnsmasq.d/local".text = ''
      address=/local/127.0.0.1
      strict-order
    '';
  };

  environment.variables = {
    TERMINAL = "kitty";
  };

  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = [ "sephi" ];

  # Allow vagrant-hostmanager to edit hosts file
  environment.etc.hosts.mode = "0644";

  # Allow to use flakes on Nix 2.3
  #nix.package = pkgs.nixUnstable;
  #nix.extraOptions = ''
  #  experimental-features = nix-command flakes
  #'';
}
