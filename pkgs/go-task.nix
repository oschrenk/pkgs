{
  lib,
  stdenvNoCC,
  fetchurl,
  installShellFiles,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "go-task";
  version = "3.54.0";

  src = fetchurl {
    url = "https://github.com/go-task/task/releases/download/v${finalAttrs.version}/task_darwin_arm64.tar.gz";
    hash = "sha256-Eqafzze7jVvJFQxE+ak2d1tz5Z/wRMLCRSMvGYwTVjc=";
  };

  sourceRoot = ".";

  nativeBuildInputs = [ installShellFiles ];

  installPhase = ''
    runHook preInstall
    install -Dm755 task $out/bin/task
    ln -s task $out/bin/go-task
    installShellCompletion \
      --bash completion/bash/task.bash \
      --fish completion/fish/task.fish \
      --zsh completion/zsh/_task
    runHook postInstall
  '';

  meta = {
    description = "Task runner / simpler Make alternative written in Go";
    homepage = "https://taskfile.dev";
    license = lib.licenses.mit;
    mainProgram = "task";
    platforms = [ "aarch64-darwin" ];
  };
})
