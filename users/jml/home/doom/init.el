(doom! :completion
       company
       :ui
       doom
       modeline
       :editor
       (evil +everywhere)
       :emacs
       undo
       :tools
       (lsp +peek)
       magit
       :lang
       (nix +lsp)
       (rust +lsp)
       markdown
       :config
       (default +bindings +smartparens))
