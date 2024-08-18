# PS5VideosTranscode
Transcode PS5's VP9 WebP videos into H.265 videos. After that you can edit and upload it easier.
Takes advantage of macOS's VideoToolbox.

Usage: 

`./transcode.sh` Transcode all WebP files in ./

`./transcode.sh /path/of/your/videos\ clips/` Transcode all your WebP files in /path/to/your/videos/clips/ (In macOS you can simply drag and drop your folder to terminal)

`./transcode.sh /path/of/your/videos\ clips/ delete` Move converted original files and unsucessfully output file into trash. You must spcify the path manually.

Note: The script will ignore every file that has been transcoded already.