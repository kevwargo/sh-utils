LOG_WINDOW_NAME=logs

kdbus() {
    qdbus org.kde.konsole "$@"
}

wait-for-konsole() {
    if ! kdbus >> /home/jarasz/kdbus.log 2>&1; then
        echo `date` kdbus fail >> /home/jarasz/kdbus.log
        /mnt/develop/my/cpp/konsole/build/src/konsole &
        echo $!
        qdbus-wait org.kde.konsole
    else
        echo `date` kdbus success >> /home/jarasz/kdbus.log
    fi
}
