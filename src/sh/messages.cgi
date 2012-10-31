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
        echo "<dt><span title='$HASH'>$(echo "$HASH"|cut -c1-8)</span>"
        echo "<a href='?hash=$HASH&view=text'>view</a>"
        echo "<a href='?hash=$HASH'>download</a></dt><dd>"
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

if [ ! -z "${params[submit]}" ];then
cat <<EOF
Content-type: text/html

<html>
<body>
<pre>
# With these tools installed you can do,
echo "some message"|dis -H $(hostname)

# Or without these tools the following will work for very simple messages.
CONTENT="some message"
LENGTH=\$(expr length "\$CONTENT")
HASH=\$(echo "\"content\" \$length \$content"|sha1sum|cut -c-40)
echo "{\\"hash\\":\\"\$HASH\\", \\"content\\":\\"\$CONTENT\\"}" \\
  |netcat -c $(hostname) 4444
<pre>
</body>
</html>
EOF
elif [ ! -z "${params[doc]}" ];then
cat <<EOF
Content-type: text/html

<html>
<body>
<pre>$(cat "$0"|sed -n '/^DOC:/,$p'|tail -n +2)<pre>
</body>
</html>
EOF
elif [ ! -z "${params[hash]}" ];then
    if [ "${params[view]}" == "text" ];then
        cat <<EOF
Content-type: text/plain

$(show_msg "$(echo "${params[hash]}"|dis-read -|head -1)")
EOF
    else
        cat <<EOF
Content-type: text/json

$(echo "${params[hash]}"|dis-read -|head -1)
EOF
    fi
else
cat <<EOF
Content-type: text/html

<html>
<title>Disseminated Messages</title>
<body>
<ul style="float:right">
<li><a href="?submit=yes">How to Submit a Message</a></li>
<li><a href="?doc=yes">Documentation</a></li>
<li><a href="http://cs.unm.edu/~eschulte/data/dissemination-0.1-1.src.tar.gz">AUR package</a></li>
</ul>
<form method="GET" action="messages.cgi">
  <p>
    Search for <input type="text" name="grep" size="20" value="${params[grep]}">
    <input type="submit" value="Submit" name="Search">
  </p>
</form>

<h1>Messages</h1>

<pre>
${params[it]}
</pre>

<dl>$(messages_to_html)</dl>
</body>
</html>
EOF
fi

exit 0
DOC:
