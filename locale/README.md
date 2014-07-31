Updating the translations
-------------------------

  1. Check if there are any new languages with progress more than 50% on [transifex](https://www.transifex.com/projects/p/foreman/resource/hammer-cli/). If so, do the following for each of the new languages:

  ```
    mkdir locale/<lang>
    cp locale/hammer-cli.pot locale/<lang>/hammer-cli.po
  ```
  2. Make sure you have `transifex-client` installed

  3. Update the translations. From GIT repo root directory run:

  ```
    make -C locale tx-update
  ```

  It will download translations from transifex, generates `mo` files, updates strings in `pot` file and wraps all the changes in a new commit. Transifex automatically updates its strings when the commit is pushed to Github.
