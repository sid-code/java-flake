{
  outputs = _: {
    lib = {
      mkJavaMavenShell =
        {
          pkgs,
          fetchedMavenDeps,
          useOutsideDirectory ? false,
          jdk ? pkgs.jdk11_headless,
        }:

        pkgs.mkShell {
          packages = [
            jdk
            pkgs.jdt-language-server
            pkgs.maven
          ];

          # Initialize temporary directory with stuff that
          # jdt-language-server needs. If `useOutsideDirectory` is
          # false, it should probably be added to .git/info/exclude
          # (or equivalent) of the project
          shellHook =
            let
              tmpDir = if useOutsideDirectory then ''/tmp/javalsp/''${PWD//\//_}'' else "$PWD/.jdtls";
            in
            ''
              export TMPDIR=${tmpDir}

              rm -rf $TMPDIR/
              mkdir -p $TMPDIR/{maven,config,workspace}
              cp -dpR ${fetchedMavenDeps}/.m2 $TMPDIR/maven/
              cp -dpR ${pkgs.jdt-language-server}/share/java/jdtls/config_linux $TMPDIR/config/
              chmod +w -R $TMPDIR

              export MAVEN_OPTS="-Dmaven.repo.local=$TMPDIR/maven/.m2"
              export JDTLS_CONFIG="$TMPDIR/config/config_linux"
              export JDTLS_WORKSPACE="$TMPDIR/workspace"
            '';
        };
    };
  };
}
