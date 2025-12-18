{
  description = "OnePlus15-165HZ Module";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        moduleProp =
          let
            content = builtins.readFile ./module.prop;
            lines = pkgs.lib.splitString "\n" content;
            validLines = builtins.filter (l: l != "" && builtins.substring 0 1 l != "#") lines;
            parseLine =
              line:
              let
                parts = builtins.match "([^=]+)=(.*)" line;
              in
              if parts != null then
                {
                  name = builtins.head parts;
                  value = builtins.elemAt parts 1;
                }
              else
                null;
          in
          builtins.listToAttrs (map parseLine validLines);

        repoUrl = pkgs.lib.removeSuffix "/releases/latest/download/update.json" moduleProp.updateJson;

        updateJson = {
          version = moduleProp.version;
          versionCode = builtins.fromJSON moduleProp.versionCode;
          zipUrl = "${repoUrl}/releases/latest/download/${moduleProp.id}_${moduleProp.version}.zip";
          changelog = "${repoUrl}/CHANGELOG.md";
        };
      in
      {
        packages = {
          default = pkgs.stdenvNoCC.mkDerivation {
            inherit (moduleProp) version;
            pname = moduleProp.id;

            src = self;

            nativeBuildInputs = with pkgs; [
              zip
              jq
            ];

            # zip -r $out/${moduleProp.id}_minimal_${moduleProp.version}.zip ./* -x flake.{nix,lock} README.md CHANGELOG.md LICENSE "banner.*"
            installPhase = ''
              mkdir -p $out

              for f in banner.*; do
                if [ -e "$f" ]; then
                  echo "banner=$f" >> module.prop
                  break
                fi
              done
              zip -r $out/${moduleProp.id}_${moduleProp.version}.zip ./* -x flake.{nix,lock} {CHANGELOG,README}.md LICENSE

              echo '${builtins.toJSON updateJson}' | jq . > $out/update.json
            '';
          };
        };

        devShells.default = pkgs.mkShellNoCC {
          buildInputs = with pkgs; [
            android-tools
            inotify-tools
          ];
          packages = with pkgs; [
            (writeShellScriptBin "push_module" ''
              temp_dir=/data/local/tmp/${moduleProp.id}
              adb shell "rm -rf $temp_dir"
              adb shell "mkdir -p $temp_dir"
              adb push ./* "$temp_dir"
              target_dir=/data/adb/modules/${moduleProp.id}
              adb shell su -c "rm -rf '$target_dir'"
              adb shell su -c "mv '/data/local/tmp/${moduleProp.id}' '$target_dir'"
            '')
            # TODO: remake it to sync folder instead file
            (writeShellScriptBin "sync_file" ''
              filename=$1
              basename=$(basename "$filename")
              basedir=$(dirname "$filename")
              target_dir=/data/adb/modules/${moduleProp.id}/$basedir
              adb push "$filename" /data/local/tmp/"$basename"
              adb shell su -c "mkdir -p '$target_dir'"
              adb shell su -c "mv '/data/local/tmp/$basename' '$target_dir/'"
            '')
            (writeShellScriptBin "hotreload" ''
              filename=$1
              while inotifywait -e close_write "$filename"; do sync_file "$filename"; done
            '')
          ];

          shellHook = ''
            echo "🚀 KernelSU/Apatch/Magisk WebUI Module environment loaded!"
            echo "💡 Run 'hotreload webroot/index.html' to watch for changes"
            echo "💡 Run 'sync_file webroot/styles.css' to push manually"
          '';
        };
      }
    );
}
