# Data product Copier template

## Dependencies

* `git` set up with SSH
* `gh` authorized with SSH
* `python` version 3.12 or higher
* `poetry` version 2
* `copier` (Python library) version 9.4.1 or higher
* `just` rask runner version 1.36.0 or higher

## Creating a data product

Simply run:

```
$ copier copy gh:Netbeheer-Nederland/tmpl-dp dp-name-of-data-product
```

Copier will ask you for some information and store the answers in a file used to set project variables.

Then, it will run `just init-project` to:

* Create a local Git repository
* Create a remote GitHub repository
* Set up branch protection rules
* Install a Python virtual environment for local development
