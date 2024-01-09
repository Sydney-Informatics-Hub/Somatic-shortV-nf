#!/usr/bin/env nextflow

process createIntervalLists {

// where to publish the outputs
tag "createIntervalLists"
publishDir "${params.outDir}", mode:'copy'

input:
    val(number_of_intervals)

output:
    path("intervals_folder")
    path("intervals_list.txt")
    env(intervalList)

shell:
// Create an intervalList based on user specified number_of_intervals
'''
ref=!{params.ref}
dict=!{params.dict}
number_of_intervals=!{params.number_of_intervals}

if [ "$number_of_intervals" -ne 0 ]; then
    
    printf "user input"
    for ((i = 0; i <= (number_of_intervals-1); i++)); do
        printf "%04d\n" "$i" >> intervals_list.txt
    done


    # Read the content of intervals_list.txt into a Bash array named intervalList
    IFS=$'\n'
    #intervalList=()
    while read line; do
        intervalList+=("$line")
    done < "intervals_list.txt"



    # Access elements using indexing
    echo "First element: ${intervalList[0]}"

    gatk SplitIntervals \
         --java-options "-Xmx3g" \
         -R !{params.ref} \
            -scatter-count $number_of_intervals \
         -O intervals_folder


else
    # Determine number of intervals based on genome size
    min=100000000 # min 100 Mb per interval for scattering
    size=$(awk 'NR>1 {print $3}' ${dict} | cut -d ':' -f 2 | awk '{sum+=$1} END {print sum}')

    number_of_intervals=$(expr $size / $min)



    for ((i = 0; i <= (number_of_intervals-1); i++)); do
        printf "%04d\n" "$i" >> intervals_list.txt
    done


    # Read the content of intervals_list.txt into a Bash array named intervalList
    IFS=$'\n'
    #intervalList=()
    while read line; do
        intervalList+=("$line")
    done < "intervals_list.txt"



    # Access elements using indexing
    echo "First element: ${intervalList[0]}"

    gatk SplitIntervals \
         --java-options "-Xmx3g" \
         -R !{params.ref} \
            -scatter-count $number_of_intervals \
         -O intervals_folder



fi




#-XL !{params.exclude_intervals} \



'''




}
