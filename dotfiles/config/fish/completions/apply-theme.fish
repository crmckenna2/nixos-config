set -l options (apply-theme --list)

complete -c apply-theme -a "$options" -d "Available themes" -f
