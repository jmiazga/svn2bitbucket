#! /bin/bash 
svnUrl=$1
bitbucketRepoName=$2
bitbucketRepoNameNoSpaces=${bitbucketRepoName// /-}
bitbucketUserName=$3
bitbucketPassword=$4

command -v svn2git >/dev/null 2>&1 || { echo >&2 "I require svn2git but it's not installed.  Aborting."; exit 1; }

if [ $# != 4 ]; then
	echo "usage: svn2bitbucket [svnUrl] [bitbucketRepoName] [bitbucketUserName] [bitbucketPassword]"
else
	set -x
	mkdir "$bitbucketRepoName"
	cd "$bitbucketRepoName"
	svn2git $svnUrl --trunk / --nobranches --notags
	curl -k -X POST --user $bitbucketUserName:$bitbucketPassword "https://api.bitbucket.org/1.0/repositories" -d "name=$bitbucketRepoName" -d "is_private='true'"
	git remote add origin git@bitbucket.org:$bitbucketUserName/$bitbucketRepoNameNoSpaces.git
	git push -u origin master
	set +x
fi


