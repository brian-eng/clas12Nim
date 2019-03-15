#!/bin/csh -f

# It's a cronjob that check if a repo has changed, and compile the PDF in case
#
# possible util: 	set gcheck = `git whatchanged -n 1 | grep "\t$d\/"`

set path = (/usr/local/bin /usr/bin /bin /usr/sbin /sbin /Library/TeX/texbin /opt/X11/bin /Library/Frameworks/Mono.framework/Versions/Current/Commands /Users/ungaro/myenv)
# echo $path

set currentDir = /opt/projects/clas12Nim
cd $currentDir

set detectors = (`ls | grep -v \.csh | grep -v \.sty | grep -v \.md | grep -v \.txt | grep -v \.log | grep -v template `)
echo
echo All detectors: $detectors
echo

# chacking which detector was changed
# keeping all pulls log.
set nlogs = `ls pull*.log | wc | awk '{print $1}'`
@ nlogs += 1
set newLog = pull_$nlogs".txt"

rm -f $newLog
git pull > $newLog

rm -f detectorChanged.txt ; touch detectorChanged.txt
foreach d ($detectors)
	set gcheck = `cat $newLog | grep " $d\/"`
	if(`echo $gcheck` != "" || $1 == "all") then
		echo $d >> detectorChanged.txt
	endif
end

echo
set detChanged = `cat detectorChanged.txt`
echo "List of detector changed: "$detChanged
echo

if($1 != "" && $1 != "all") then
	set detChanged = $1
endif

foreach d ($detChanged)
	# make sure the style files are common
	cd $currentDir
	rm -f compile.log
	cp *.sty $d
	echo                  > compile.log
	echo Detector: $d    >> compile.log
	echo                 >> compile.log
	cd $currentDir/$d
	# chacking if repo has changed on the master. Using tab and det name, i.e. svt/
	scons                >> compile.log
	ls -lrt              >> compile.log
	scp -v $d.pdf ftp.jlab.org:/group/clas/www/clasweb/html/12gev/nims >> compile.log
	echo $d published    >> compile.log
	scons -c             >> compile.log
end
