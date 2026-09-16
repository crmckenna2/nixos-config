function fish_prompt
    
    # Display the working directory
    set_color normal
    echo -n (prompt_pwd)
   
    # Finally, display the $ symbol
    set_color --bold green 
    echo -n "\$ "
    set_color normal

end
