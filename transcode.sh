###
 # @Author       : FeiYehua
 # @Date         : 2024-08-18 00:15:02
 # @LastEditTime : 2024-08-20 00:43:02
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
        ffmpeg -i "$file" -c:v libx264 -vcodec copy -acodec copy "$filename".mp4
        #ffmpeg -hwaccel videotoolbox -i "$file" -c:v hevc_videotoolbox -b:v 45M -c:a copy "$filename".mp4
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
  echo "---------------"

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
          printf "\e[31mCovert Failed (Empty file)\e[0m, delete coverted file! ($filename.mp4)\n"
          delete_file "$filename.mp4"
        #elif ffmpeg -v error -i "$filename" 2>&1 | grep -q "Invalid data found when #processing input"; then
        #  echo "Covert Failed (Damaged file), delete coverted file! ($filename.mp4)"
        #  delete_file "$filename.mp4"
        else
        #echo "find! $filename"
        #ffmpeg -hwaccel videotoolbox -i "$file" -c:v h264_videotoolbox -b:v 13M -c:a copy "$filename".mp4
          local webmDuration=$(ffmpeg -i "$filename.webm" 2>&1 | grep "Duration")
          local mp4Duration=$(ffmpeg -i "$filename.mp4" 2>&1 | grep "Duration")
          #echo $webmDuration
          #echo $mp4Duration
          #ffmpeg -i "$filename.mp4"
          webmDuration=${webmDuration%%.*}
          mp4Duration=${mp4Duration%%.*}
          local webmSecond=${webmDuration##*:}
          local mp4Second=${mp4Duration##*:}
          webmDuration=${webmDuration%:*}
          mp4Duration=${mp4Duration%:*}
        #echo $webmSecond
        #echo $mp4Second
          local webmMinute=${webmDuration##*:}
          local mp4Minute=${mp4Duration##*:}
        #echo $webmMinute
        #echo $mp4Minute
          webmDuration=${webmDuration%:*}
          mp4Duration=${mp4Duration%:*}
          local webmHour=${webmDuration##* }
          local mp4Hour=${mp4Duration##* }
        #echo $webmHour
        #echo $mp4Hour
          local webmLength=$((10#$webmHour*3600 + 10#$webmMinute*60 + 10#$webmSecond))
          local mp4Length=$((10#$mp4Hour*3600 + 10#$mp4Minute*60 + 10#$mp4Second))
        #echo $webmLength
        #echo $mp4Length
          local durationGap=$(($webmLength-$mp4Length))
          if [ $durationGap -ge -1 ] && [ $durationGap -le 1 ] ; then
            printf "\e[32mCovert Succeed\e[0m, delete original file! ($filename.webm)\n"
            delete_file "$filename.webm"
          else
            printf "\e[31mCovert Failed (Convert didn't complete)\e[0m, delete coverted file! ($filename.mp4)\n"
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
elif [ "$1" == delete ]; then
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

