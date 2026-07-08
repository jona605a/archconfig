function fish_right_prompt --description 'Write out the right prompt (command duration)'
    # $CMD_DURATION is set by fish after each command finishes, in milliseconds.
    # It's unset before the very first command, so guard against that.
    if not set -q CMD_DURATION
        return
    end

    set -l ms $CMD_DURATION

    # Only show duration for commands that took a while, to avoid noise from
    # near-instant commands like `ls` or `cd`.
    if test $ms -lt 500
        return
    end

    set -l duration
    if test $ms -ge 60000
        set -l minutes (math -s0 "$ms / 60000")
        set -l seconds (math -s0 "($ms % 60000) / 1000")
        set duration "$minutes"m" $seconds"s
    else if test $ms -ge 1000
        set duration (math -s1 "$ms / 1000")s
    else
        set duration "$ms"ms
    end

    set_color brblack
    echo -n "took $duration"
    set_color normal
end
