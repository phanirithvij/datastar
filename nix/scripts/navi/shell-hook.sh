if [[ :$SHELLOPTS: =~ :(vi|emacs): ]]; then
  rm /tmp/navi-shell*
  script=$(mktemp -t navi-shell.XXXX)
  navi widget bash \
    | sed 's/_navi_widget/_navi_widget_currdir/g' \
    | sed 's/--print/--print --path "docs"/g' \
    | sed 's/C-g/C-j/g' \
  > $script
  source $script
  eval "$(navi widget bash)"
fi
