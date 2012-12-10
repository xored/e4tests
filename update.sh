#!/bin/bash -xe

LATEST=`curl -s http://download.eclipse.org/eclipse/downloads/ \
    | grep -o '<a href=['"'"'"][^"'"'"']*['"'"'"]' \
    | sed -e 's/^<a href=["'"'"']//' -e 's/["'"'"']$//' \
    | grep -e "N201[2-3]" \
    | grep -v testResults \
    | sed -e 's:^drops4/::' -e 's:/$::' \
    | sort -u \
    | tail -n1`

CURRENT=`xmllint --noblanks pom.xml \
    | egrep -o '<build-name>[^>]+<\/build-name>' \
    | sed -e 's/<build-name>//' -e 's/<\/build-name>//'`

echo "LATEST=[$LATEST]"
echo "CURRENT=[$CURRENT]"

if [[ "$LATEST" == "$CURRENT" ]]
then
    echo "Up to date"
elif [[ -n "$LATEST" && -n "$CURRENT" ]]
then
    cp pom.xml pom.xml.bak
    cat pom.xml.bak | sed "s/$CURRENT/$LATEST/g" > pom.xml
    git commit pom.xml -m "* updated build-name to $LATEST"
else
    echo "Something is wrong"
    exit 1
fi
