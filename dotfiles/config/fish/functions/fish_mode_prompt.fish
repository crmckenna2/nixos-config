function fish_mode_prompt

    # Get the color of the current vi mode
    switch $fish_bind_mode
	case default;     set_color --bold red
	case insert;      set_color --bold green
	case replace_one; set_color --bold cyan
	case visual;      set_color --bold magenta
	case "*";         set_color --bold red
    end 

    # Display the user@hostname text
    echo -n (whoami)"@"(hostname)" "

end
