function worknix --wraps='cd ~/work/nobodywho/nobodywho/; nix develop' --description 'alias worknix=cd ~/work/nobodywho/nobodywho/; nix develop'
    cd ~/work/nobodywho/nobodywho/; nix develop $argv
end
