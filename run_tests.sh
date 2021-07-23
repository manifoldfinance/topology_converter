#!/usr/bin/env bash

count=0
failed=()
#declare -a failed

directories=`ls -d tests/*/`
for directory in $directories; do
    echo $directory
    scripts=`ls -f ${directory}*`
    for script in $scripts; do
        echo $script
        $script
        rc=$?
        if [ $rc -ne 0 ]; then
            echo "FAIL!!!"
            failed+=( "$script" )
        fi
        count=$((count + 1))
    done
done

echo ""
echo "======================"
echo "$count tests executed"
echo "${#failed[@]} failures"
if [ "${#failed[@]}" -gt "0" ]; then
    echo "----------------------"
    for test in ${failed[@]}; do
        echo $test
    done
    echo ""
    exit 1
else
    echo ""
    exit 0
fi
