Updating the translations
-------------------------

  1. Make sure you have `transifex-client` installed

  2. Update the translations. From GIT repo root directory run:

  ```
    make -C locale tx-update
  ```

  It will download translations from transifex, generates `mo` files, updates strings in `pot` file and wraps all the changes in a new commit. Transifex automatically updates its strings when the commit is pushed to Github.
