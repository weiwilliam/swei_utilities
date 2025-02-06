#!/usr/bin/env bash

# Usage: ./update_symlinks.sh /path/to/directory "old_path_part" "new_path_part"

# Directory containing the symbolic links
dir=$1

# Old partial path to be replaced
old_path_part=$2

# New partial path to replace with
new_path_part=$3

# Check if correct number of arguments provided
if [[ $# -ne 3 ]]; then
    echo "Usage: $0 /path/to/directory old_path_part new_path_part"
    exit 1
fi

# Loop through each symbolic link in the directory
find "$dir" -type l | while read -r symlink; do
    # Get the target of the symbolic link
    target=$(readlink "$symlink")

    # Check if the target contains the old path part
    if [[ "$target" == *"$old_path_part"* ]]; then
        # Create the new target path by replacing the old path part with the new one
        new_target="${target/$old_path_part/$new_path_part}"

	if [[ -s $new_target ]]; then
            # Remove the old symbolic link
            rm "$symlink"

            # Create a new symbolic link with the updated target path
            ln -s "$new_target" "$symlink"

            echo "Updated $symlink -> $new_target"
	fi
    else
        echo "No match in $symlink"
    fi
done

