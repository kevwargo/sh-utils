#!/bin/bash

ShowHelp()
{
    if [ -z "$1" ]; then
        echo "mountpart: small util for mounting partitions from disk images
Image can also be block device, e.g. real disk"
    fi
    echo "Usage: mountpart IMAGE PARTITION [OPTIONS] [MOUNTPOINT]

Options:
 -n, --no-mount         create loop device for the partition without mounting
 -v, --verbose          verbose output (to stderr)
 -p, --print-result     print mount point if mounted or loop device if one created (any other output is suppressed)
                        (e.g. using like \"cd \`mountpart -r image 1 /mnt/image_1 -t ext3 -o rw\`\" is possible)
 -o, --mount-options    set mount options
 -t, --fs-type          set filesystem type to try to mount with
 -l, --loop-device      set advanced loop device
 -h, --help             print this help"
    exit ${1:-0}
}

while ! [ -z "$1" ]; do
    case "$1" in
        "-n" | "--no-mount" ) MountP=no ;;
        "-p" | "--print-result" ) PrintResult=yes ;;
        "-v" | "--verbose" ) verbose=yes ;;
        "-o" | "--mount-options" )
            shift
            [ -z "$1" ] || MountOptions="-o $1" ;;
        "-t" | "--fs-type" )
            shift
            [ -z "$1" ] || FSType="-t $1" ;;
        "-l" | "--loop-device" ) shift && LoopDevice="$1" ;;
        "-h" | "--help" ) ShowHelp ;;
        *    )
            if [ -z "$image" ]; then
                image="$1"
            elif [ -z "$partition" ]; then
                partition="$1"
            elif [ -z "$MountPoint" ]; then
                MountPoint="$1"
            fi
            ;;
    esac
    shift
done

if [ -z "$image" ] || [ -z "$partition" ]; then
    echo "Image and partition number must be specified." > /dev/stderr
    ShowHelp 1
fi

if ! LoopDevice="${LoopDevice:-$(losetup -f)}"; then
    echo "Failed to get free loop device automatically. Specify it manually." > /dev/stderr
    exit 2
fi

MountP="${MountP:-yes}"

### partx юзаць ня трэба, бо на /dev/sda14 напрыклад ён дае толькі 14-ы падзел
### /dev/sda, а /dev/sda14 можа сам быць вінтом і трэба атрымаць яго падзелы
# start=$(( 512*$(partx -s "$img" | grep "^ *${part} " | awk '{print $2}') ))
# size=$(( 512*$(partx -s "$img" | grep "^ *${part} " | awk '{print $4}') ))


# format of location is: "start_pos size" in 512-byte sectors
location="$(fdisk -l "$image" | tr '*' ' ' | awk -v img="$image" -v part="$partition" '$0 ~ ("^[[:space:]]*" img "p?" part "\\>") {print $2, $3 - $2 + 1}')"

if [ -z "$location" ]; then
    echo "Wrong partition number." > /dev/stderr
    exit 3
fi

start=$(( ${location%% *}*512 ))
size=$(( ${location##* }*512 ))

# echo $image $partition $start $size $LoopDevice $MountP $MountOptions $FSType $MountPoint

### Creating loop device ###

[[ $verbose = "yes" ]] && echo losetup \"$LoopDevice\" \"$image\" -o $start --sizelimit $size > /dev/stderr

losetup "$LoopDevice" "$image" --offset $start --sizelimit $size > /dev/stderr
if [ $? != 0 ]; then
    if [[ $LoopDevice = $(losetup -f) ]]; then
        minor=$(echo $LoopDevice | grep -o "[0-9]*$")
        [[ $verbose = "yes" ]] && echo "Trying to create $LoopDevice with mknod..." > /dev/stderr
        if ! mknod $LoopDevice b 7 $minor; then
            echo "Failed to create loop device node." > /dev/stderr
            exit 5
        fi
        [[ $verbose = "yes" ]] && echo "$LoopDevice created successfully." > /dev/stderr
        losetup "$LoopDevice" "$image" --offset $start --sizelimit $size > /dev/stderr
    else
        echo "Failed to create loop device." > /dev/stderr
        exit 4
    fi
fi

### Loop device is created ###


### Mounting loop device ###

if [[ $MountP = "yes" ]]; then
    if [ -z "$MountPoint" ]; then
        [[ $PrintResult != "yes" ]] && echo "Mount point wasn't specified. Just loop device created" > /dev/stderr
    else
        [[ $verbose = "yes" ]] && echo mount $FSType $MountOptions \"$LoopDevice\" \"$MountPoint\" > /dev/stderr
        mount $FSType $MountOptions "$LoopDevice" "$MountPoint" > /dev/stderr
        ec=$?
        if [ $ec != 0 ]; then
            echo "Failed to mount specified partition." > /dev/stderr
            exit 6
        fi
        [[ $PrintResult = "yes" ]] && echo $MountPoint
    fi
else
    [[ $PrintResult = "yes" ]] && echo $LoopDevice
fi

### Loop device is mounted ###
