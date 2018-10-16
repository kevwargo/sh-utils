#!/bin/bash
asm()
{
    compiler=$1
    linker=$2
    src=$3
    exe=`splitext $src`
    obj=$exe.o
    $compiler $src -o $obj
    $linker $obj -o $exe
    rm $obj
    echo $exe
}

if [[ $0 != *"bash" ]]; then
    linecmd=$0
    compiler="nasm -f elf"
    linker="ld"
    while ! [ -z $1 ]; do
        if [[ $1 == "-cmp" ]]; then
            shift
            compiler=$1
            shift
        elif [[ $1 == "-ln" ]]; then
            shift
            linker=$1
            shift
        elif [[ $1 == "-l" ]]; then
            shift
            if [[ $1 == "-cmp" ]]; then
                shift
                libcompiler=$1
                shift
            else
                libcompiler="nasm -f elf"
            fi
#            echo libcompiler - $libcompiler -o $(splitext $1).o $1
            if [[ $(splitext $1 e) == "asm"* ]]; then
                $libcompiler -o $(splitext $1).o $1
                libs="$libs $(splitext $1).o"
            else
                libs="$libs $1"
            fi
            shift
        else
            break
        fi
    done
    src=$1
    shift
    if [ -z "$libs" ]; then
        result=$(asm "$compiler" "$linker" "$src")
    else
#        echo libs - $libs
#        echo $compiler $src -o $(splitext $src).o
        $compiler $src -o $(splitext $src).o
#        echo $linker $(splitext $src).o $libs -o $(splitext $src)
        $linker $(splitext $src).o $libs -o $(splitext $src)
        result=$(splitext $src)
    fi
    [[ $linecmd == *"scmx" ]] && $(realpath $result) $@
fi