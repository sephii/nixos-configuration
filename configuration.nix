# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  xkbLayout = pkgs.writeText "xkb-layout" ''
    xkb_symbols "dvpintl" {
    	include "pc+us(dvp)+inet(evdev)+compose(rctrl)+level3(ralt_switch)+capslock(escape_shifted_capslock)"
    
    	key <AD04> { [         p,       P,  ediaeresis,     Ediaeresis ] };
    	key <AD05> { [         y,       Y,  udiaeresis, Udiaeresis ] };
    	key <AD08> { [         c,       C,    ccedilla,    Ccedilla ] };
    
    	key <AC01> { [         a,       A,      agrave, Agrave ] };
    	key <AC02> { [         o,       O, ocircumflex, Ocircumflex ] };
    	key <AC03> { [         e,       E,      eacute, Eacute ] };
    	key <AC04> { [         u,       U, ucircumflex, Ucircumflex ] };
    	key <AC05> { [         i,       I, icircumflex, Icircumflex ] };
    	key <AC10> { [         s,       S,      ssharp,            U1E9E ] };
    
    	key <AB02> { [         q,       Q,  odiaeresis,      dead_ogonek ] };
    	key <AB03> { [         j,       J,      egrave, Egrave ] };
    	key <AB04> { [         k,       K,      ugrave, Ugrave ] };
    	key <AB05> { [         x,       X,  idiaeresis, Idiaeresis ] };
    
    	key <SPCE> { [     space,   space,nobreakspace, U202F      ] };
    };
  '';
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.09";

  ########
  # BOOT #
  ########

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.efiInstallAsRemovable = true;
  boot.loader.grub.device = "nodev"; # "nodev" for efi only

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
  networking.enableIPv6 = false;
  networking.networkmanager.dns = "dnsmasq";

  ########
  # I18N #
  ########

  i18n = {
    consoleFont = "Lat2-Terminus16";
    defaultLocale = "en_US.UTF-8";
    consoleUseXkbConfig = true;
  };

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
    xorg.xkbcomp
    xorg.xmodmap
    xorg.xev
    xorg.xrandr
    xfce.thunar
    xfce.gvfs
    xfce.xfce4-icon-theme
    lxappearance
    lxappearance-gtk3
    stilo-themes
    tango-icon-theme
    brightnessctl
    redshift
    compton
    xss-lock

    # Languages
    python3
    nodejs
    gcc  # required to compile some libs
    jre  # Java, required by VaudTax
    swt  # required by VaudTax

    # Python packages
    python37Packages.virtualenv
    python37Packages.pip
    python37Packages.setuptools

    # Fonts
    terminus_font
    inconsolata
    font-awesome_4
    powerline-fonts
    twitter-color-emoji

    # Utilities
    direnv
    fish
    git
    htop
    httpie
    rxvt_unicode
    ranger
    vim
    wget
    ripgrep
    redir
    man
    gnupg
    pavucontrol
    yubikey-personalization
    libu2f-host
    syncthing
    fzy
    fzf  # for fisher fzf package
    gnumake

    # Apps
    arandr
    firefox
    emacs
    evince
    gimp
    mplayer
    smplayer
    nitrogen
    signal-desktop
    spotify
    klavaro
    slack
    gnome3.gnome-keyring
    gnome3.seahorse
    simplescreenrecorder

    # Services
    postgresql_11
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

    # Libs
    webkitgtk  # required by VaudTax
  ];

  programs.fish.enable = true;
  programs.xss-lock.enable = true;
  programs.xss-lock.lockerCommand = "${pkgs.i3lock-fancy}/bin/i3lock-fancy";
  programs.xss-lock.extraOptions = [ "-l" ];
  programs.ssh.startAgent = true;
  programs.seahorse.enable = true;

  ############
  # SERVICES #
  ############

  services.redshift.enable = true;
  services.compton.enable = true;
  services.compton.inactiveOpacity = "0.8";
  services.compton.vSync = true;
  services.compton.backend = "glx";

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

  services.printing.enable = true;
  services.gvfs.enable = true;
  services.avahi.enable = true;
  services.mailhog.enable = true;
  services.upower.enable = true;

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
  services.emacs.defaultEditor = true;
  services.gnome3.gnome-keyring.enable = true;

  # Syncthing
  services.syncthing.enable = true;
  services.syncthing.declarative.folders = {
    "/var/lib/syncthing/midgar" = {
      devices = [ "oneplus" ];
      id = "midgar";
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
  #services.xserver.libinput.additionalOptions = ''
  #  Option "MinSpeed" "1"
  #  Option "MaxSpeed" "1.75"
  #  Option "HorizHysteresis" "28"
  #  Option "VertHysteresis" "28"
  #'';

  services.udev.packages = [
    pkgs.yubikey-personalization
    pkgs.libu2f-host
  ]; 

  sound.enable = true;
  sound.mediaKeys.enable = true;
  hardware.pulseaudio.enable = true;
  hardware.opengl.enable = true;

  #########
  # USERS #
  #########

  users.users.sephi = {
    isNormalUser = true;
    extraGroups = [ "wheel" "video" "docker" "lxd" "networkmanager" ];
    shell = pkgs.fish;
  };

  ##################
  # VIRTUALISATION #
  ##################

  virtualisation.docker.enable = true;
  virtualisation.lxc.enable = true;
  virtualisation.lxd.enable = true;
  virtualisation.lxc.defaultConfig = ''
    lxc.net.0.type = veth
    lxc.net.0.link = lxcbr0
  '';

  ########
  # MISC #
  ########

  fonts.fonts = [
    pkgs.dejavu_fonts
    pkgs.font-awesome_4
    pkgs.inconsolata
    pkgs.terminus_font
  ];

  hardware.brightnessctl.enable = true;
  nixpkgs.config.allowUnfree = true;
  security.apparmor.enable = true;
  security.apparmor.packages = [ pkgs.lxc ];

  environment.etc = {
    "NetworkManager/dnsmasq.d/pontsun".text = ''
      address=/pontsun.test/127.0.0.1
      strict-order
    '';
  };
}
