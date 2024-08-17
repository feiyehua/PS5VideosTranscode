###
 # @Author       : FeiYehua
 # @Date         : 2024-08-18 00:15:02
 # @LastEditTime : 2024-08-18 01:00:21
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

if [ -z "$1" ]; then
    directory="./"
else
    directory="$1"
fi
echo "$directory"
traverse_directory "$directory"
