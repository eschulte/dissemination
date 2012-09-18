#!/bin/bash
#
# Usage: to be used as a cgi script
# Serves access to a message database through a simple web page.
# 
# The DIS_BASE environment variable must be set in the environment in
# which the cgi script is run.
#
. "$(dirname $(which dis-read))/dis-common"

saveIFS=$IFS; IFS='=&'
parm=($QUERY_STRING)
IFS=$saveIFS

declare -A params
for ((i=0; i<${#parm[@]}; i+=2));do
    params[${parm[i]}]=${parm[i+1]}
done

messages(){
    if [ -z "${params[grep]}" ];
    then dis-read
    else dis-read -k content -g "${params[grep]}"|dis-read -
    fi
}

messages_to_html(){
    IFS='
'
    for JSON in $(messages|tac);do
        KEYS="$(keys)"
        HASH="$(get hash)"
        echo  "<dt title='$HASH'>$(echo "$HASH"|cut -c1-8)</dt><dd>"
        if $(contains "$KEYS" signatory);then
            echo "Signed By: <span title='$(get signature)'>"
            echo "$(get signatory)</span>"
        fi
        echo "<pre>"
        get content
        echo "</pre>"
        echo "</dd>"
    done
}

cat <<EOF
Content-type: text/html

<html>
<title>Disseminated Messages</title>
<body>
<p><a style="float:right" href="http://cs.unm.edu/~eschulte/data/dissemination-0.1-1.src.tar.gz">AUR package</a></p>
<form method="GET" action="messages.cgi">
  <p>
    Search for <input type="text" name="grep" size="20" value="${params[grep]}">
    <input type="submit" value="Submit" name="Search">
  </p>
</form>

<h1>Messages</h1>

<dl>$(messages_to_html)</dl>
</body>
</html>
EOF
