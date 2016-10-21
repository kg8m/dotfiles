export LOCAL_GEMFILE=Gemfile.local

set_bundle_gemfile() {
  if [[ -f $LOCAL_GEMFILE ]]; then
    [[ ! $BUNDLE_GEMFILE ]] && export BUNDLE_GEMFILE=$LOCAL_GEMFILE
  else
    [[ $BUNDLE_GEMFILE = $LOCAL_GEMFILE ]] && export BUNDLE_GEMFILE=
  fi
}
set_bundle_gemfile
add-zsh-hook chpwd set_bundle_gemfile
