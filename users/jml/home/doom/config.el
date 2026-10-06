(setq standard-indent 2)
(setq-default indent-tabs-mode nil)

(after! lsp-mode
  (setq lsp-rust-analyzer-cargo-watch-command "clippy"))

(require 'rustowl)
