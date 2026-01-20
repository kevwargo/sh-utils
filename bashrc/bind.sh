_xsel-copyline () {
    printf "%s" "$READLINE_LINE" | xsel -b
}

bind -x '"\ew": "_xsel-copyline"'
