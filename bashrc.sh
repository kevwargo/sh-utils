source /etc/profile
umask 000

dir="$(dirname $(realpath $BASH_SOURCE))"
PATH="$PATH:$dir/executables"

importdir="$dir/bashrc"

for i in $(ls $importdir | grep "^[[:alnum:]].*[^\~]$"); do
    [ -f $importdir/$i ] && . $importdir/$i
done

unset i importdir dir

LANG="en_US.UTF-8"
