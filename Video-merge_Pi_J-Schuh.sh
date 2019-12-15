#!/bin/bash

#This script find all the video files from the same date and same camera in the folder /mnt/Exteranl-Disk/Cats/Motion and merge into one file
Directory="/home/pi/Videos/Motion"

file_specification() {
	#this function is going to search through the folder and look for files
		FILE_NAME="$(basename "${entry}")"
    NAME="${FILE_NAME%.*}"
    EXT="${FILE_NAME##*.}"
		#check if the file has an extension of .mkv, otherwise exit the function
		if [[ $EXT == "mkv" ]]; then
			:
		else
			echo "Error: No video file"
			echo "$EXT"
			exit 1
		fi
        #put all the video files with the same prefix, e.g. CAM01_2019-11-17, into one txt file
		TXTFile="${FILE_NAME:0:16}"
        # check if a txt file with the file name with first 16 characters of the file, e.g. CAM01_2019-11-17 exist. If not, create one
		if [ -f "${Directory}/${TXTFile}.txt" ]; then
			echo -n "+" >> ${Directory}/$TXTFile.txt
    	echo -n "$FILE_NAME" >> ${Directory}/$TXTFile.txt
			echo " " >> ${Directory}/$TXTFile.txt
			#the same for the file for deleting, without '+'
			echo -n "$FILE_NAME" >> ${Directory}/$TXTFile.log
			echo " " >> ${Directory}/$TXTFile.log
		else
    	echo "$TXTFile has been created"
    	touch ${Directory}/${TXTFile}.txt
			touch ${Directory}/${TXTFile}.log #this file is for deleting
			echo -n "$FILE_NAME" >> ${Directory}/$TXTFile.txt
			echo " " >> ${Directory}/$TXTFile.txt
			echo -n "$FILE_NAME" >> ${Directory}/$TXTFile.log
			echo " " >> ${Directory}/$TXTFile.log
		fi
}

walk() {
		#this local variable is used to ignore the 2nd argument for walk function
        local indent="${2:-0}"
        # If the entry is a file do some operations
        for entry in "$1"/*; do [[ -f "$entry" ]] && file_specification; done
        # If the entry is a directory call walk() == create recursion
        for entry in "$1"/*; do [[ -d "$entry" ]] && walk "$entry" $((indent+4)); done
}

# run the walk function to scan through all the video files and put the names into txt file
walk "${Directory}"

#find all the files with extension of .txt into the variable MergeFileList
MergeFileList=$(find $Directory -type f -name "*.txt")

#Merge all the Videos in the MergFileList into one Video
eval cd $Directory
echo "Current folder is $PWD"

while IFS= read -r line
do
	mkvmerge -o ${line:0:39}.mkv $(< $line)
done < <(printf '%s\n' "$MergeFileList")

#find all the files with extension of .txt into the variable MergeFileList
DeleteFileList=$(find $Directory -type f -name "*.log")
#delete all the files, which are listed in the $DeleteFileList
while IFS= read -r line
do
	rm $(< $line)
done < <(printf '%s\n' "$DeleteFileList")
# delete the generated txt and log file
rm ./*.txt ./*.log

# move the video files to the Camera folder
mv ./*.mkv /mnt/Exteranl-Disk/Cats/Camera
