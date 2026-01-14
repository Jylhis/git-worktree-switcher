{
  lib,
  stdenv,
  makeWrapper,
  installShellFiles,
  fzf,
  git,
}:

stdenv.mkDerivation rec {
  pname = "git-worktree-switcher";
  version = "0.2.8-fork";

  src = lib.cleanSourceWith {
    src = ./.;
    filter = path: type:
      let
        baseName = baseNameOf path;
        relPath = lib.removePrefix "${toString ./.}/" path;
      in
      # Include only necessary files
      baseName == "wt" ||
      baseName == "completions" ||
      lib.hasPrefix "completions/" relPath ||
      baseName == "LICENSE" ||
      baseName == "README.md";
  };

  nativeBuildInputs = [
    makeWrapper
    installShellFiles
  ];

  buildInputs = [
    fzf
    git
  ];

  installPhase = ''
    runHook preInstall

    install -Dm755 wt $out/bin/wt
    wrapProgram $out/bin/wt \
      --prefix PATH : ${lib.makeBinPath [ fzf git ]}

    installShellCompletion --zsh completions/_wt_completion
    installShellCompletion --bash completions/wt_completion

    runHook postInstall
  '';

  meta = {
    description = "Switch between git worktrees with speed. Fork with dynamic completions, add command, and special character handling";
    homepage = "https://github.com/mateusauler/git-worktree-switcher";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ jiriks74 mateusauler ];
    mainProgram = "wt";
    platforms = lib.platforms.all;
  };
}
