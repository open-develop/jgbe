#!/bin/bash

# show usage message if asked for
if [ "x${1}" == "x--help" ]
then
	echo "Usage: zipopt.bash [--help]"
	echo "       zipopt.bash infile.zip outfile.zip" 
	echo "       zipopt.bash --7zip /path/to/7zip infile.zip outfile.zip"
	echo "       zipopt.bash infile.zip outfile.zip /path/to/7zip"
	echo ""
	echo "If no path to 7zip is given, a 7z or 7za found in the path will be used."
	exit
fi

# find 7zip path
P7Z="${3}"
if [ "x${1}" == "x--7zip" ]
then
	P7Z="${2}"
	shift
	shift
fi
if [ "x${P7Z}" == "x" ]
then
	P7Z=`which 7z 2> /dev/null || which 7za 2> /dev/null`
else
	P7Z=`which "${P7Z}" 2> /dev/null`
fi
if [ "x${P7Z}" == "x" ]
then
	echo 'Failed to find 7zip executable.'
	exit
fi

# report findings
echo Using 7zip at: ${P7Z}
echo Input: ${1}
echo Output: ${2}

# create workdir and copy over the input file
CURDIR=`pwd`
WORKDIR=`mktemp -d -t zipopt.XXXXXXXXXX` || exit
cp "${1}" "${WORKDIR}/input.zip" || exit
cd "${WORKDIR}"

# fill methods.txt with a list of lines containing the different arguments we will try

#echo "-mm=Deflate -mx=9 -mpass=15" >> methods.txt
#echo "-mm=Deflate -mfb=32 -mpass=7" >> methods.txt
#echo "-mm=Deflate -mfb=32 -mpass=10" >> methods.txt
#echo "-mm=Deflate -mfb=32 -mpass=15" >> methods.txt

#echo "-mm=Deflate -mfb=64 -mpass=7" >> methods.txt
echo "-mm=Deflate -mfb=64 -mpass=10" >> methods.txt
echo "-mm=Deflate -mfb=64 -mpass=15" >> methods.txt

#echo "-mm=Deflate -mfb=128 -mpass=7" >> methods.txt
echo "-mm=Deflate -mfb=128 -mpass=10" >> methods.txt
echo "-mm=Deflate -mfb=128 -mpass=15" >> methods.txt

#echo "-mm=Deflate -mfb=256 -mpass=7" >> methods.txt
#echo "-mm=Deflate -mfb=256 -mpass=10" >> methods.txt
#echo "-mm=Deflate -mfb=256 -mpass=15" >> methods.txt

#echo "-mm=Deflate -mfb=258 -mpass=7" >> methods.txt
echo "-mm=Deflate -mfb=258 -mpass=10" >> methods.txt
echo "-mm=Deflate -mfb=258 -mpass=15" >> methods.txt

#echo "-mx=9 -mm=Copy" >> methods.txt
#echo "-mx=9 -mm=Deflate64" >> methods.txt
#echo "-mx=9 -mm=BZip2" >> methods.txt
#echo "-mm=Deflate64 -mfb=257 -mpass=15" >> methods.txt

#cat methods.txt

# get list of files in the zip
"${P7Z}" l input.zip -slt | grep -B1 'Folder = -' | sed -n 's:^Path = ::p' > files.txt

# iterate over all files
cat files.txt | while read -r
do
	# don't use 'read line' as it chokes on some whitespaces
	line="${REPLY}"
	echo file: "${line}"
	
	# find best method
	mkdir temp
	cd temp
	"${P7Z}" x ../input.zip -i!"${line}" -so > file.dat
	cat ../methods.txt | while read method
	do
		"${P7Z}" a "method ${method}.zip" ${method} file.dat	
	done
	rm file.dat
	BESTMETHOD=`ls -rS | head -n 1 | sed "s:^method ::" | sed "s:\.zip$::"`
	echo "Best method:${BESTMETHOD} (${line})" >> ../mres.txt
	cd ..
	rm -r temp
	
	# store file in result.zip with the method we found
	mkdir temp
	cd temp
	"${P7Z}" x ../input.zip -i!"${line}"
	"${P7Z}" a ../result.zip ${BESTMETHOD} "${line}"
	cd ..
	rm -r temp
done

# do some real output
echo --------
cat mres.txt
echo --------
ls -l input.zip result.zip
echo --------

# copy over result file and remove temp work dir
cd "${CURDIR}"
cp "${WORKDIR}/result.zip" "${2}"
rm -r "$WORKDIR"
