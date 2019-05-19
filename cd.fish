# cd is a function with definition
# Defined in /usr/local/Cellar/fish/3.0.2/share/fish/functions/cd.fish @ line 4

function cd --description "Change directory"
    set -l MAX_DIR_HIST 25

    # create directory if it doesn't exist
    
    if test $argv[1] = "-p"
      set argv $argv[2]
      mkdir -p $argv
    end

    if test (count $argv) -gt 1
        printf "%s\n" (_ "Too many args for cd command")
        return 1
    end

    # Skip history in subshells.
    if status --is-command-substitution
        builtin cd $argv
        return $status
    end

    # Avoid set completions.
    set -l previous $PWD

    if test "$argv" = "-"
        if test "$__fish_cd_direction" = "next"
            nextd
        else
            prevd
        end
        return $status
    end

    # allow explicit "cd ." if the mount-point became stale in the meantime
    if test "$argv" = "."
        cd "$PWD"
        return $status
    end

    builtin cd $argv
    set -l cd_status $status

    if test $cd_status -eq 0 -a "$PWD" != "$previous"
        set -q dirprev
        or set -l dirprev
        set -q dirprev[$MAX_DIR_HIST]
        and set -e dirprev[1]
        set -g -a dirprev $previous
        set -e dirnext
        set -g __fish_cd_direction prev
    end

    return $cd_status
end
