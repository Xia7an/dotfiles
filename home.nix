{
  imports = [
    ./modules/zsh.nix
  ];
  home = rec { # recでAttribute Set内で他の値を参照できるようにする
    username="inoyu";
    homeDirectory = "/home/${username}"; # 文字列に値を埋め込む
    stateVersion = "22.11";
  };
  programs.home-manager.enable = true; # home-manager自身でhome-managerを有効化
}
