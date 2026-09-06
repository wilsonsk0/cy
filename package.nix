{
  lib,
  bash,
  buildGoModule,
  libx11,
  ncurses,
  vim,
  testers,
  makeBinaryWrapper,
  gitCommit ? "development"
}:
buildGoModule (finalAttrs: {
  pname = "cy";
  version = "1.12.0";
  src = ./.;
  vendorHash = null;

  subPackages = [ "cmd/cy" ];

  nativeBuildInputs = [
    makeBinaryWrapper
  ];

  buildInputs = [
    libx11
  ];

  ldflags =
    let
      versionPkg = "github.com/cfoust/cy/pkg/version";
    in
    [
      "-X ${versionPkg}.Version=v${finalAttrs.version}"
      "-X ${versionPkg}.GoVersion=${finalAttrs.finalPackage.go.version}"
      "-X ${versionPkg}.GitCommit=${gitCommit}"
    ];

  postFixup = ''
    wrapProgram $out/bin/cy \
      --suffix TERMINFO_DIRS : ${ncurses}/share/terminfo \
      --suffix LD_LIBRARY_PATH : ${libx11}/lib
  '';

  nativeCheckInputs = [
    bash
    vim
  ];

  preCheck = ''
    export HOME="$TMPDIR"
    mkdir -p "$HOME"

    export TERMINFO_DIRS="${ncurses}/share/terminfo"
    export EDITOR="${vim}/bin/vim"
  '';

  passthru.tests = {
    version = testers.testVersion {
      package = finalAttrs.finalPackage;
      command = "cy --version";
      version = "v${finalAttrs.version}";
    };
  };

  __structuredAttrs = true;

  meta = {
    description = "A time travelling terminal multiplexer";
    homepage = "https://cfoust.github.io/cy/";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.wilsonsk0 ];
    platforms = lib.platforms.linux;
    mainProgram = "cy";
  };
})
