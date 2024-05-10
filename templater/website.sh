#!/bin/bash

# Perform system update
echo "Performing system update..."
sudo apt-get update -y && sudo apt-get upgrade -y &> /dev/null

# Function to create a directory and its contents
create_dir() {
  local dir_name="$1"
  shift
  local files=("$@")

  if ! mkdir -p "$dir_name"; then
    echo "Error: Unable to create directory $dir_name"
    return 1
  fi

  for file in "${files[@]}"; do
    if ! touch "$dir_name/$file"; then
      echo "Error: Unable to create file $file in $dir_name"
      return 1
    fi
  done
}

# Display main menu
echo "Main Menu"
echo "1. Create website structure"
echo "2. Exit"

read -r -p "Enter your choice: " choice

case "$choice" in
  1)
    # Ask for the name of the main directory
    read -r -p "Enter the name of the main directory: " main_dir

    # Validate user input
    if [[ -z "$main_dir" ]]; then
      echo "Error: Main directory name cannot be empty"
      exit 1
    fi

    # Create the main directory and its contents
    create_dir "$main_dir/html" "index.html" "main.html" "something.html" "example.html"
    create_dir "$main_dir/css" "styles.css"
    create_dir "$main_dir/javascript" "file.js" "something.js"

    echo "Standard website file structure created in $main_dir!"
    ;;
  2)
    exit 0
    ;;
  *)
    echo "Invalid choice. Exiting..."
    exit 1
    ;;
esac
