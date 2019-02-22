#/bin/bash
# vague
# get and set wallpapers from livestream

# TODO move the wallpaper setting part into a function so we can make a new block for each desktop environment and comment out ones for other desktop environments and keep the script cleaner

# handle losing internet cleanly
wget(){
	command wget $@ || {
		echo failed. waiting 10s >&2
		sleep 10s
		wget $@
	}
}

# address of the camera from the proper user facing website 
#	ive only tested this with earthcam.com links
vidurl='https://www.earthcam.com/world/russia/moscow/?cam=moscow_hd'
vidurl='https://www.earthcam.com/usa/illinois/chicago/field/?cam=fieldmuseum'
vidurl='https://www.earthcam.com/usa/tennessee/nashville/?cam=nashville'

# time between wallpaper updates in seconds
time=10

# find the chunklist stream
linkToChunkListLink=$(wget -q -O - $vidurl  | grep ,\"html5_streamingdomain.*m3u8 -o | cut -d ':' -f 2,3,4 | sed -e 's+\\++g' -e 's+","html5_streampath":"++' | grep http.*m3u8 -o)
echo linkToChunkListLink $linkToChunkListLink
urlbase=$(echo $linkToChunkListLink | sed -e 's/playlist.*//')
echo using urlbase $urlbase
chunkListLink=$urlbase$(wget -q -O - $linkToChunkListLink | grep chunklist)
echo chunkListLink $chunkListLink
#latestChunk=$urlbase$(wget -q -O - $chunkListLink | tac | grep -m1 'media.*ts')
#echo latestChunk $latestChunk

while true ; do 
	latestChunk=$urlbase$(wget -q -O - $chunkListLink | tac | grep -m1 'media.*ts')
	echo $latestChunk

	# create and cleanup working space	
	popd	
	rm -rf temp
	mkdir temp # if this becomes a problem we can do it in /tmp
	pushd temp

	# get the next video chunk	
	wget $latestChunk

	# extract image from video for wallpaper
	ffmpeg -i m*.ts -ss 00:00:00 -vframes 1 -q:v 1 image.jpg 

	# set wallpaper
	#	this works on mate 
	gsettings set org.mate.background picture-filename $(pwd)/image.jpg

	sleep $time
done
