magit()
{
    local dir
    dir="${1:-$(git rev-parse --show-toplevel 2>/dev/null)}"
    emacsclient --eval "$(cat <<EOF
(progn
 (magit-status "$dir")
 (raise-frame)
 (x-focus-frame (selected-frame)))
EOF
)"
}

magit-log()
{
    local dir
    dir="${1:-$PWD}"
    emacsclient --eval "$(cat <<EOF
(let ((default-directory "$dir"))
 (magit-log-all)
 (raise-frame)
 (x-focus-frame (selected-frame)))
EOF
)"
}
