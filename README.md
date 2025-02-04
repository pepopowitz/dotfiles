# Steve's dotfiles repo

## To install on a new machine

1. `brew install rcm`
2. Clone this repo into ~/.dotfiles:

```sh
gh repo clone pepopowitz/dotfiles .dotfiles
```

3. Follow https://thoughtbot.github.io/rcm/rcm.7.html#QUICK_START_FOR_EXISTING_DOTFILES_DIRECTORIES:
   1. `lsrc` to see what rcm will do; though I don't know how to tell it to ignore some things.
   2. `rcup -v` to set up symlinks
      - overwrite everything, if this is a new computer. 
4. Reload zsh and see what needs to be installed!


Built and managed with [rcm](https://github.com/thoughtbot/rcm).
