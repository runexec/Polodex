pair=$1
fpt="polodex.$pair.tmp"
fp="polodex.$pair"

if [ -z "$pair" ];
then
    echo "Please provide a proper pair. Example: BTC_NAV, BTC-NAV"
else
    proper_pair=`echo $pair | tr '[:lower:]' '[:upper:]' | tr '_' '-'`
    
    echo "Downloading info for pair $proper_pair"

    >$fp
    
    for i in 1 4 16 24 72
    do
    	# Volume
    	echo "# $i hour(s) Volume" >> $fp
	
    	curl 'http://cryptoindexes.com/api.php?index=performance' \
    	     -H 'Host: cryptoindexes.com' \
    	     -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:49.0) Gecko/20100101 Firefox/49.0' \
    	     -H 'Accept: */*' \
    	     -H 'Accept-Language: en-US,en;q=0.5' --compressed \
    	     -H 'Content-Type: application/x-www-form-urlencoded; charset=UTF-8' \
    	     -H 'X-Requested-With: XMLHttpRequest' \
    	     -H 'Referer: http://cryptoindexes.com/performance' \
    	     -H 'DNT: 1' \
    	     -H 'Connection: keep-alive' \
    	     --data "mode=volume&period=undefined&order=top&hours=${i}&price=100&volume=2&exchange=px" \
    	     > $fpt

    	cat $fpt | tr '}' '\n' | grep -i $proper_pair | tr ',' '\n' | grep -i percent >> $fp
    	sleep 3

    	# Price
    	echo "# $i hour(s) Price" >> $fp
	
    	curl 'http://cryptoindexes.com/api.php?index=performance' \
    	     -H 'Host: cryptoindexes.com' \
    	     -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:49.0) Gecko/20100101 Firefox/49.0' \
    	     -H 'Accept: */*' \
    	     -H 'Accept-Language: en-US,en;q=0.5' --compressed \
    	     -H 'Content-Type: application/x-www-form-urlencoded; charset=UTF-8' \
    	     -H 'X-Requested-With: XMLHttpRequest' \
    	     -H 'Referer: http://cryptoindexes.com/performance' \
    	     -H 'DNT: 1' \
    	     -H 'Connection: keep-alive' \
    	     --data "mode=price&period=undefined&order=top&hours=${i}&price=100&volume=2&exchange=px" \
    	     > $fpt

    	cat $fpt | tr '}' '\n' | grep -i $proper_pair | tr ',' '\n' | grep -i percent >> $fp
    	sleep 3
	
    	# Volatility
    	echo "# $i hour(s) Volatility" >> $fp    
	
    	curl 'http://cryptoindexes.com/api.php?index=volatility' \
    	     -H 'Host: cryptoindexes.com' \
    	     -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:49.0) Gecko/20100101 Firefox/49.0' \
    	     -H 'Accept: */*' \
    	     -H 'Accept-Language: en-US,en;q=0.5' --compressed \
    	     -H 'Content-Type: application/x-www-form-urlencoded; charset=UTF-8' \
    	     -H 'X-Requested-With: XMLHttpRequest' \
    	     -H 'Referer: http://cryptoindexes.com/performance' \
    	     -H 'DNT: 1' \
    	     -H 'Connection: keep-alive' \
    	     --data "mode=undefined&period=undefined&order=top&hours=${i}&price=100&volume=2&exchange=px" \
    	     > $fpt
	
    	cat $fpt | tr '}' '\n' | grep -i $proper_pair | tr ',' '\n' | grep -i percent >> $fp
    	sleep 3
    done

    echo "Notable Changes for $proper_pair"

    last_line=''
    while read l;
    do
	if echo $last_line | grep --quiet '#' && ! echo $l | grep --quiet '#';
	then
	    percent=`echo $l | cut -f2 -d ':'`
	    echo -e "$last_line \n $percent %"
	fi
	
	last_line=$l

    done <$fp

fi
