###
 # @Author       : FeiYehua
 # @Date         : 2024-08-18 00:15:02
 # @LastEditTime : 2024-08-18 12:52:08
 # @LastEditors  : FeiYehua
 # @Description  : 
 # @FilePath     : transcode.sh
 #      © 2021 FeiYehua
### 
#!/bin/zsh

traverse_directory() {
  local current_dir="$1"
    #echo $current_dir
  for file in "$current_dir"/*; do
    if [ -f "$file" ]; then
      local extension="${file##*.}"
      local filename="${file%.*}"
      if [ "$extension" = "webm" ] && ! [ -f "$filename.mp4" ]; then
        #echo "find! $filename"
        ffmpeg -hwaccel videotoolbox -i "$file" -c:v h264_videotoolbox -b:v 13M -c:a copy "$filename".mp4
      fi
    elif [ -d "$file" ]; then
      echo "Find directory: $file"
      traverse_directory "$file"  
    fi
  done
}
delete_file() 
{
  local current_file="$1"
  echo "$current_file"
  osascript <<EOF
    tell application "Finder"
      move POSIX file "$current_file" to trash
    end tell
EOF
  echo "Moved to trash: $current_file"

}
delete_original_file() {
  local current_dir="$1"
    #echo $current_dir
  for file in "$current_dir"/*; do
    if [ -f "$file" ]; then
      local extension="${file##*.}"
      local filename="${file%.*}"
      if [ "$extension" = "webm" ] && [ -f "$filename.mp4" ]; then
        if [ $(ls -l "$filename.mp4" | awk '{print $5}') -le 1000 ]; then
          echo "Covert Failed (Empty file), delete coverted file! ($filename.mp4)"
          delete_file "$filename.mp4"
        else
        #echo "find! $filename"
        #ffmpeg -hwaccel videotoolbox -i "$file" -c:v h264_videotoolbox -b:v 13M -c:a copy "$filename".mp4
          local webmDuration=$(ffmpeg -i "$filename.webm" 2>&1 | grep "Duration")
          local mp4Duration=$(ffmpeg -i "$filename.mp4" 2>&1 | grep "Duration")
          webmDuration=${webmDuration%%.*}
          mp4Duration=${mp4Duration%%.*}
          local webmSecond=${webmDuration##*:}
          local mp4Second=${mp4Duration##*:}
          webmDuration=${webmDuration%:*}
          mp4Duration=${mp4Duration%:*}
        #echo $webmSecond
        #echo $mp4Second
        #echo $webmDuration
        #echo $mp4Duration
          local webmMinute=${webmDuration##*:}
          local mp4Minute=${webmDuration##*:}
        #echo $webmMinute
        #echo $mp4Minute
          webmDuration=${webmDuration%:*}
          mp4Duration=${mp4Duration%:*}
          local webmHour=${webmDuration##* }
          local mp4Hour=${webmDuration##* }
        #echo $webmHour
        #echo $mp4Hour
          local webmLength=$(($webmHour*3600 + $webmMinute*60 + $webmSecond))
          local mp4Length=$(($mp4Hour*3600 + $mp4Minute*60 + $mp4Second))
        #echo $webmLength
        #echo $mp4Length
          local durationGap=$(($webmLength-$mp4Length))
          if [ $durationGap -ge -1 ] && [ $durationGap -le 1 ] ; then
            echo "Covert Succeed, delete original file! ($filename.webm)"
            delete_file "$filename.webm"
          else
            echo "Covert Failed (Convert didn't complete), delete coverted file! ($filename.mp4)"
            delete_file "$filename.mp4"
          fi
        fi
      fi
    elif [ -d "$file" ]; then
      echo "Find directory: $file"
      delete_original_file "$file"  
    fi
  done
}
if [ -z "$1" ]; then
    directory="./"
elif [ $1 == delete ]; then
    echo error!
    exit 1
else
    directory="$1"
fi
echo "$directory"
if [ -z $2 ]; then
    traverse_directory "$directory"
elif [ $2 = "delete" ]; then
   delete_original_file "$1"
fi

