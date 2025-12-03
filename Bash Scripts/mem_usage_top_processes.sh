#!/bin/bash

# Create a script to check memory usage and log the top 5 memory-consuming processes.

echo "checking memory usage..."
available_memory=$(free -h | awk 'NR==2 {print $7}' | sed 's/Gi/GB/')

echo "Avaiable Memory: $available_memory"
echo "-----------------------------------"
echo "Top 5 memory-consuming processes:"
echo "-----------------------------------"
ps aux --sort=-%mem | awk 'NR<=6 {printf "%-10s %-10s %-10s %-30s\n", $1, $2, $4, $11}'
echo "-----------------------------------"
echo "Top 5 CPU consuming processes"
echo ""
ps aux --sort=-%cpu | awk 'NR<=6 {printf "%-10s %-10s %-10s %-30s\n", $1, $2, $3, $11}'
