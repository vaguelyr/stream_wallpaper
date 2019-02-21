#/bin/bash
# vague
# get wallpapers from livestream

# the webplayer knows where the playlist is
# the playlist holds the next 3 video chunks
# the webplayer plays those chunks and continually gets the playlist to get more chunks

# TODO cleanup the video playlist url part
# TODO move the wallpaper setting part into a function so we can make a new block for each desktop environment and comment out ones for other desktop environments and keep the script cleaner


# nashville woods
videourl=https://videos3.earthcam.com/fecnetwork/13650.flv/chunklist_w334136231.m3u8
# nashville city
videourl=https://videos3.earthcam.com/fecnetwork/13714.flv/chunklist_w597565875.m3u8

# time between wallpaper updates in seconds
time=10

while true ; do 
	latesttsurl=https://videos3.earthcam.com/fecnetwork/13714.flv/$(wget -q -O - $videourl | tail -n1)
	echo $latesttsurl

	# create and cleanup working space	
	popd	
	rm -rf temp
	mkdir temp # if this becomes a problem we can do it in /tmp
	pushd temp

	# get the next video chunk	
	wget $latesttsurl 

	# extract image from video for wallpaper
	ffmpeg -i m*.ts -ss 00:00:00 -vframes 1 -q:v 1 image.jpg 

	# set wallpaper
	#	this works on mate 
	gsettings set org.mate.background picture-filename $(pwd)/image.jpg

	sleep $((time+1))
done
