#/bin/bash
# vague
# get and set wallpapers from livestream

setWallpaper(){
	echo set wallpaper
	if [ ! -e "$1" ] ; then
		echo wallpaper doesnt exist
		return 1
	fi

	# this works on mate 
	gsettings set org.mate.background picture-filename $(pwd)/$1

}

# address of the camera from the proper user facing website 
#	ive only tested this with earthcam.com links

#vidurl='https://www.earthcam.com/canada/niagarafalls/thefalls/?cam=niagarafalls2'
#vidurl='https://www.earthcam.com/events/mardigras/?cam=catsmeow2'
#vidurl='https://www.earthcam.com/usa/colorado/breckenridge/?cam=beaverrun'
#vidurl='https://www.earthcam.com/usa/florida/miamiandthebeaches/?cam=miamibeach1' 
#vidurl='https://www.earthcam.com/usa/florida/miamiandthebeaches/?cam=miamibeach4'
#vidurl='https://www.earthcam.com/usa/florida/naples/?cam=naplespier'
#vidurl='https://www.earthcam.com/usa/illinois/chicago/field/?cam=fieldmuseum'	
#vidurl='https://www.earthcam.com/usa/kentucky/hyden/?cam=hyden'
#vidurl='https://www.earthcam.com/usa/massachusetts/boston/?cam=boston_hd'
#vidurl='https://www.earthcam.com/usa/newyork/columbuscircle/?cam=columbus_circle'
#vidurl='https://www.earthcam.com/usa/newyork/utica/?cam=tamarin'
#vidurl='https://www.earthcam.com/usa/pennsylvania/scranton/?cam=steamtown'
#vidurl='https://www.earthcam.com/usa/pennsylvania/shanksville/?cam=flight93_hd'
#vidurl='https://www.earthcam.com/usa/southcarolina/kiawahisland/?cam=kiawah_island_hd'
vidurl='https://www.earthcam.com/usa/tennessee/nashville/?cam=nashville'
#vidurl='https://www.earthcam.com/world/aruba/beachresort/?cam=arubabeach'
#vidurl='https://www.earthcam.com/world/aruba/druifbeach/?cam=casadelmar'
#vidurl='https://www.earthcam.com/world/russia/moscow/?cam=moscow_hd'
#vidurl='https://www.earthcam.com/world/uae/dubai/atlantisthepalm/?cam=atlantis2'

# time between wallpaper updates in seconds
time=10

# find the link to the newest video chunk
# 	player ->playlist.m3u8 (sometimes multiple) -> chunklist_wtrash.m3u8 -> chunks.ts
linkToPlaylist=$(wget -q -O - $vidurl  | grep var\ json_base | grep 'html5_streampath":"[^"]*'  -o | sort -u )
echo $linkToPlaylist
for link in $linkToPlaylist ; do
	link=http://videos3.earthcam.com/$(echo $link | sed -e 's/.*fecnetwork/fecnetwork/' -e 's+\\++g')
	echo $link
	name=$(wget -O - -q $link --timeout=3 --tries=1 | grep chunklist)
	if [ -z "$name" ] ; then
		continue
	fi
	urlbase=$(echo $link | sed -e 's/playlist.m3u8//')
	echo got !! $name
	chunkListLink=$urlbase$name
	echo $chunklistLink
	chunkName=$(wget -q -O - $chunkListLink | tail -n1)
	echo chunkname $chunkName 
	latestChunk=$urlbase$(wget -q -O - $chunkListLink | tac | grep -m1 'media.*ts')
	echo $latestChunk
	break
done


# main loop - sets wallpaper
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
	ffmpeg -i m*.ts -ss 00:00:00 -vframes 1 -q:v 1 image.jpg 1>&2 2>/dev/null

	setWallpaper image.jpg

	sleep $time
done
