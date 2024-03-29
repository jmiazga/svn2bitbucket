#! /bin/bash 

function usage_and_exit()
{
    echo "$0 -s <svnUrl> -n <bitbucketRepoName> -u <bitbucketUserName>"
    exit 1;
}

svnUrl=
bitbucketRepoName=
bitbucketRepoNameNoSpaces=
bitbucketUserName=
bitbucketPassword=

while getopts s:n:u: flag
do
    case $flag in
        s)
            svnUrl=$OPTARG;;
        n)
            bitbucketRepoName=$OPTARG
	    bitbucketRepoNameNoSpaces=${bitbucketRepoName// /-};;
        u)
            bitbucketUserName=$OPTARG;;
        ?)
            usage_and_exit;;
    esac
done

if [ -z "$svnUrl" ] || [ -z "$bitbucketRepoName" ] || [ -z "$bitbucketUserName" ];
then
    echo "missing a required parameter (svnUrl, bitbucketRepoName and bitbucketUserName are required)"
    usage_and_exit
fi

command -v svn2git >/dev/null 2>&1 || { echo >&2 "I require svn2git but it's not installed.  Aborting."; exit 1; }

set -x
read -s -p "Enter Bitbucket Password: " bitbucketPassword
mkdir "$bitbucketRepoName"
cd "$bitbucketRepoName"
svn2git $svnUrl --trunk / --nobranches --notags -v
curl -k -X POST --user $bitbucketUserName:$bitbucketPassword "https://api.bitbucket.org/1.0/repositories" -d "name=$bitbucketRepoName" -d "is_private='true'"
git remote add origin git@bitbucket.org:$bitbucketUserName/$bitbucketRepoNameNoSpaces.git
git push -u origin master
