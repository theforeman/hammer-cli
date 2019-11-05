# Release Howto

Our release process is documented using Jupyter notebook (interractive documentation).

To read the docs view the `gem_release.ipynb` on GitHub. To run the notebook Jupyter is needed. Jupyter is web based interractive python
environment that can mix executable snippets with markdown.

The markdown parts should inform the releaser about what is going to be done and 
the executable pieces should do the actual work. If anything goes unexpected it is easy
 to stop, investigate, fix and re-run the step.
 

## Install Jupyter

```
$ pip install jupyter
```

## Run the notebook

Once jupyter is executed it starts local webserver and usualy it opens new tab in your 
browser with the notebook loaded.

```
$ cd <your hammer-cli directory>
$ jupyter notebook rel-eng/gem_release.ipynb 
```

> NOTE: Every executable bit is executed in your local hammer-cli directory.

> NOTE: It is recommended to use non-interactive auth with git hub (such as ssh keys)
as current notebook can not handle password prompt. If your env requires interactive
steps skip the step in notebook and run its equivalent manually in your terminal. 

> NOTE: If your notebook hangs waiting on your prompt you have to `Menu > Kernel > Interrupt`
your notebook kernel. It may lead to loosing the variables and you'll have to re-run 
some steps.

> NOTE: To run Jupyter within virtual machine you need the server to listen to public
 e.g. `jupyter notebook --ip 0.0.0.0 rel-eng/gem_release.ipynb`. Beware of the security risks
 envolved - access to jupyter notebook means unrestricted access to the shell
 as the user who runs the Jupyter.
 
## Follow the notebook

Once you are in the notebook page in your browser read the content to see what is going on.
 - cells that have `[ ]` next to it are executable cells 
 - use arrows to navigate
 - cell with green frame is in edit mode. Pres `<ESC>` to get to command mode (blue frame)
 - `<CTRL>+<Enter>` executes the cell
 - `<Shift>+<Enter>` executes the cell and moves to next one
 - you can execute markdown cells too
 - when the cell is executed the output is attached to the cell
 - when the execution is in progress the `[*]` is shown nex to it
 - to edit cell press `<Enter>`
 
 ## Notebook updates
 
 Notebook is internally stored as a JSON so it is easy to version in github. 
 Feel free to send PRs with your updates.
 
 > NOTE: notebook stores also the output of execution. To keep the notebook free 
 of your personal content use `Menu > Cell > All Output > Clear` before you save 
 the notebook.
