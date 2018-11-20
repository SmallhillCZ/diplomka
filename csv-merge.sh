#!/bin/bash
destFile=$1                       # Fix the output name
echo "Merging to $destFile"
i=0                                       # Reset a counter
for filename in ./*.csv; do 
 if [ "$filename"  != "$destFile" ] ;      # Avoid recursion 
 then 
   echo "$filename"
   if [[ $i -eq 0 ]] ; then 
      head -1  $filename >   $destFile # Copy header if it is the first file
   fi
   tail -n +2  $filename >>  $destFile # Append from the 2nd line each file
   i=$(( $i + 1 ))                        # Increase the counter
 fi
done
exit 0