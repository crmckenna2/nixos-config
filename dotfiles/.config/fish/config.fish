if status is-interactive

    # Set aliases
    alias la="ls -a --group-directories-first"
    alias ff="fastfetch"
    alias nv="nvim"
    alias gpu="nvidia-smi"

    # Allow vim keybinds
    fish_vi_key_bindings
    
    # View manuals in neovim
    set -gx MANPAGER "nvim +Man!" 

    # Remove the fish greeting
    set -g fish_greeting ""
    
    # Remove the autocomplete 
    set -g fish_autosuggestion_enabled 0

    # Prevent the shortening of the working directory
    set -g fish_prompt_pwd_dir_length 0

    # Add the user made scripts to the path
    fish_add_path -g ~/.local/scripts

    # Enable direnv
    direnv hook fish | source

end
