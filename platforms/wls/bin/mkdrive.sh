#!/usr/bin/env bash

# Exit-on-error
set -e

die() {
	printf 'ERROR: %s\n' "$1" >&2
	exit 1
}
warn() {
	printf 'WARN: %s\n' "$1" >&2
}
getMountInfo() {
	echo "$(mount | grep $1)"
}

dir=
path=
deleting=0

# Capture input
while (( "$#" )); do
	case $1 in
		-d)
			deleting=1
			;;
		-*)
			warn "Unknown option (ignored): $1"
			;;
		[a-z])
			dir=`echo "$1" | tr '[:upper:]' '[:lower:]'`
			path=/mnt/$dir
			;;
		*)
			die "Invalid drive letter: $1"
			;;
	esac
	shift
done

# Validate input
if [ "$dir" == "" ]; then
	die "Please supply a drive-letter to map."
fi

# Check if mounted -> unmount
if [[ "$(getMountInfo $path)" = *[^[:space:]]* ]]; then
	sudo umount $path
fi
# Check exists -> delete
if [ -d $path ]; then
	if [ -L $path ]; then
		# Exists as symlink - delete
		sudo rm $path
	else
		# Exists as dir - delete to confirm empty
		sudo rmdir $path
	fi
fi

# Create & Mount
if [ $deleting = 0 ]; then
	sudo mkdir -p $path
	sudo mount -t drvfs $dir: $path
fi

# Display results
printf 	'%s %s DONE!\n' \
	"$([ $deleting = 0 ] && echo Mounthing || echo Unmounting)" \
	"$([ $deleting = 0 ] && echo $(getMountInfo $path) || echo $path)"
