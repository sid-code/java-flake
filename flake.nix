{
  outputs = _: {
    lib = {
      mkJavaMavenShell =
        { pkgs, fetchedMavenDeps }:

        pkgs.mkShell {
          packages = with pkgs; [
            jdk11_headless
            jdt-language-server
            maven
          ];

          # Initialize .jdtls directory with stuff that jdt-language-server
          # needs. It should probably be added to .git/info/exclude (or
          # equivalent) of the project
          shellHook = ''
            export TMPDIR=$PWD/.jdtls

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
