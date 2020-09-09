# Fire up dev servers
alias dev-r="artsy reaction && yarn start"
alias dev-f="artsy force && yarn start"
alias dev-fr="lk-fr && watch-r & dev-f"
alias dev-rp="lk-rp && watch-p & dev-r"

# force to reaction
alias lk-fr="artsy reaction && yarn link && artsy force && yarn link @artsy/reaction"
alias unlk-fr="artsy force && yarn unlink @artsy/reaction && yarn --check-files"

# reaction to palette
alias lk-rp="lk-p && artsy reaction && yarn link @artsy/palette"
alias unlk-rp="artsy reaction && yarn unlink @artsy/palette && yarn --check-files"

# reaction
alias lk-r="artsy reaction && yarn link"
alias unlk-r="artsy reaction && yarn unlink"
alias watch-r="artsy reaction && yarn watch"

# palette
alias lk-p="artsy palette && yarn workspace @artsy/palette link"
alias unlk-p="artsy palette && yarn workspace @artsy/palette unlink"
alias watch-p="artsy palette && yarn workspace @artsy/palette watch"

# Panic buttons
alias tableflip="echo '(╯°□°)╯︵ ┻━┻' && yarn cache clean && rm -rf ./node_modules && yarn --check-files && yarn test --clearCache"
alias unlk-all="unlk-fr && unlk-rp && unlk-r && unlk-p"

# TODO:

# dev-palette/dev-p
# dev-palette-docs/dev-pd
# dev-force-reaction-palette/dev-frp

# link-palette-docs/lk-pd
# unlink-palette-docs/unlk-pd

# typecheck-force/tc-f
# typecheck-reaction/tc-r
# typecheck-palette/tc-p
