kdbus() {
    qdbus org.kde.konsole "$@"
}

konsole_wait() {
    if ! kdbus &>/dev/null; then
        konsole --new-tab >> ~/konsole.log 2>&1 &
        cat /proc/$!/environ | tr '\0' '\n' > ~/konsole-env-$!.log
        while ! kdbus &>/dev/null; do
            sleep 1
        done
    fi
}
