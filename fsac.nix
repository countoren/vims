{
  buildDotnetGlobalTool,
  lib,
  dotnetCorePackages,
  writeShellScriptBin,
}:

let
  fsautocomplete = buildDotnetGlobalTool {
    pname = "fsautocomplete";
    version = "0.83.0";

    nugetSha256 = "sha256-5K93/XwKG+pgNW6UfW1OOgHv01Xh7xYnLB5v/AyhpUw=";

    dotnet-runtime =
      with dotnetCorePackages;
      combinePackages [
        sdk_9_0
      ];

    meta = with lib; {
      homepage = "https://github.com/fsharp/FsAutoComplete";
      changelog = "https://github.com/fsharp/FsAutoComplete/releases";
      license = licenses.apsl20;
      platforms = platforms.linux ++ platforms.darwin;
    };
  };
in
{
  # Prefers a project-local dotnet tool install over the nix package,
  # falling back to the nix-built binary if none is found.
  fsautocomplete-local-or-nix = writeShellScriptBin "fsautocomplete" ''
    if command -v dotnet >/dev/null && dotnet tool run fsautocomplete --version >/dev/null 2>/dev/null;
    then
      exec dotnet tool run fsautocomplete "$@"
    else
      exec "${fsautocomplete}/bin/fsautocomplete" "$@"
    fi
  '';
  inherit fsautocomplete;
}
