# dotfiles

Configurazione personale per workstation Ubuntu e WSL Ubuntu.

Il repository contiene configurazioni riproducibili e una lista esplicita delle
dipendenze di sistema. Credenziali, segreti e stato generato dagli strumenti non
devono essere versionati.

## Installazione

Clonare il repository e avviare il bootstrap:

```bash
git clone <url-del-repository> ~/dev/dotfiles

cd ~/dev/dotfiles

./install.sh
```

Lo script:

1. installa `mise` per l'utente, se non è già disponibile;
2. collega la configurazione globale di `mise` in `~/.config/mise/config.toml`;
3. collega la configurazione TUI di OpenCode nella directory di configurazione utente;
4. aggiunge l'attivazione di `mise` a `~/.bashrc`, se non è già presente;
5. installa o aggiorna gli strumenti dichiarati in `mise/config.toml`.

Le configurazioni esistenti vengono salvate con suffisso
`.before-dotfiles` prima di essere sostituite. Lo script può essere eseguito più
volte.

Dopo l'installazione, aprire una nuova shell oppure eseguire:

```bash
source ~/.bashrc
```

## Strumenti gestiti da mise

Gli strumenti globali sono dichiarati in [`mise/config.toml`](mise/config.toml).
Attualmente sono gestiti:

- `composer`: <https://getcomposer.org/>;
- `fd`: <https://github.com/sharkdp/fd>;
- `fzf`: <https://github.com/junegunn/fzf>;
- `gh`: <https://cli.github.com/>;
- `glab`: <https://gitlab.com/gitlab-org/cli>;
- `go`: <https://go.dev/>;
- `intelephense`: <https://intelephense.com/>;
- `jq`: <https://jqlang.org/>;
- `laravel-lsp`: <https://github.com/laravel/lsp>;
- `lua-language-server`: <https://luals.github.io/>;
- `neovim`: <https://neovim.io/>;
- `node`: <https://nodejs.org/>;
- `opencode`: <https://opencode.ai/>;
- `rg`: <https://github.com/BurntSushi/ripgrep>;
- `stylua`: <https://github.com/JohnnyMorganz/StyLua>;
- `typescript`: <https://www.typescriptlang.org/>;
- `tree-sitter`: <https://tree-sitter.github.io/tree-sitter/>;
- `yt-dlp`: <https://github.com/yt-dlp/yt-dlp>.

Per installarli o aggiornarli:

```bash
mise install
mise upgrade
```

Per aggiungere uno strumento globale e aggiornare il repository:

```bash
mise use --global <strumento>@latest
```

Dopo il bootstrap, la configurazione globale è un collegamento al file nel
repository: il comando modifica direttamente `mise/config.toml`.

## OpenCode

Il file [`opencode/tui.json`](opencode/tui.json) seleziona il tema integrato
`catppuccin`. Il bootstrap lo collega a `~/.config/opencode/tui.json`, oppure a
`$XDG_CONFIG_HOME/opencode/tui.json` se `XDG_CONFIG_HOME` è impostata.

Per cambiare tema, modificare il campo `theme` e riavviare OpenCode.
Credenziali e stato locale di OpenCode restano fuori dal repository.

## Sottocomandi Git

Gli script personali in [`bin/`](bin) vengono collegati dal bootstrap a
`~/.local/bin` e possono essere invocati come sottocomandi Git:

```bash
git mr
git pr
git release v1.2.3
```

### git mr

`git mr` crea una merge request GitLab per il branch corrente tramite `glab`.
Il branch deve essere già pubblicato sul remote configurato.

```bash
git mr [opzioni]
```

Opzioni disponibili:

- `--assignee USER`: sostituisce l'assegnatario configurato;
- `--target BRANCH`: sostituisce il branch di destinazione;
- `--remote REMOTE`: usa un remote diverso da `origin`;
- `--title TITLE`: imposta il titolo senza aprire l'editor;
- `--description TEXT`: imposta la descrizione insieme a `--title`;
- `--draft`: crea una merge request in bozza;
- `--dry-run`: mostra il comando `glab` senza eseguirlo;
- `--no-squash`: disabilita lo squash per questa esecuzione;
- `--keep-source-branch`: conserva il branch sorgente dopo il merge;
- `-h`, `--help`: mostra l'help.

Le impostazioni predefinite possono essere definite nel singolo repository:

```bash
git config --local mr.assignee <username>
git config --local mr.target <branch>
git config --local mr.remote origin
git config --local mr.squash true
git config --local mr.removeSourceBranch true
git config --local mr.template <template>
```

Se l'editor viene chiuso senza salvare il file, il comando annulla la creazione
della merge request.

### git pr

`git pr` crea una pull request GitHub tramite `gh`. Per impostazione predefinita
apre l'editor per compilare titolo e descrizione.

```bash
git pr [opzioni di gh pr create]
```

Accetta tutte le opzioni di `gh pr create`. In particolare, `-w` o `--web`
aprono il browser e disabilitano l'editor nel terminale. L'elenco completo è
disponibile tramite:

```bash
git pr --help
```

Se l'editor viene chiuso senza salvare il file, il comando annulla la creazione
della pull request.

### git release

`git release` pubblica una release dopo aver verificato la CI GitHub, aggiornato
il changelog e unito il branch sorgente nel branch di destinazione. Il tag deve
rispettare il formato semantico `vX.Y.Z`:

```bash
git release v1.2.3
```

Il comando non accetta opzioni. Richiede un working tree pulito, una sezione
`## Unreleased` non vuota nel changelog e una CI completata con successo per il
commit corrente. Prima di applicare le modifiche mostra le note di rilascio e
chiede conferma.

Le impostazioni disponibili nel singolo repository sono:

```bash
git config --local release.source-branch develop
git config --local release.target-branch main
git config --local release.remote origin
git config --local release.workflow test.yml
git config --local release.changelog CHANGELOG.md
```

- `release.source-branch`: branch da pubblicare, predefinito `develop`;
- `release.target-branch`: branch che riceve il merge, predefinito `main`;
- `release.remote`: remote sul quale eseguire il push, predefinito `origin`;
- `release.workflow`: workflow GitHub Actions da verificare, predefinito
  `test.yml`;
- `release.changelog`: percorso del changelog, predefinito `CHANGELOG.md`.
