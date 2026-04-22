{ pkgs, ... }: {
  channel = "stable-24.05";
  packages = [
    pkgs.flutter
    pkgs.jdk17
  ];
  idx.previews = {
    enable = true;
    previews = {
      android = {
        command = [ "flutter" "run" "--machine" "-d" "android" "-d" "emulator-5554" ];
        manager = "flutter";
      };
    };
  };
}