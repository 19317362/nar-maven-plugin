#!/bin/sh

URL=github.com:maven-nar/maven-nar.github.com &&
git fetch "$URL" master &&
for d in /usr/lib/jvm/java-7-openjdk-amd64/
do
	if test -d "$d"
	then
		echo "Using Java 7 for prettier javadocs" &&
		export JAVA_HOME="$d" &&
		export PATH="$JAVA_HOME/bin:$PATH" &&
		break
	fi
done &&
mvn clean site &&
export GIT_INDEX_FILE=.git/tmp-index &&
    rm -f $GIT_INDEX_FILE &&
git add -f target/site &&
    TREE=$(git write-tree) &&
unset GIT_INDEX_FILE &&
TREE=$(git rev-parse $TREE:target/site) &&
COMMIT=$(printf "Update %s from %s\n\n%s\n\n%s" \
		"http://maven-nar.github.io/" \
		"$(git rev-parse --short HEAD)" \
		"This trick was performed by these commands:" \
		"$(cat "$0" | sed 's/^/	/')" |
	git commit-tree $TREE -p FETCH_HEAD) &&
git update-ref -m "Generated by mvn site" \
	FETCH_HEAD $COMMIT &&
git push $URL FETCH_HEAD:master
