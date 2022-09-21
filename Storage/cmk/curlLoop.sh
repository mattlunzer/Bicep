!/bin/bash

# timestamp() {
#   "%T" # current time
# }


url='https://stg7erkpmbkeda2i.blob.core.windows.net/test/sample3.txt'

for ((i=1;i<=100;i++)); 
do   
    curl -o /dev/null -s -w "%{http_code}\n" $url; 
done
