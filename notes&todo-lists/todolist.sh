#!/bin/bash


# Author: Kris Tomplait
# It was made by me, so use this at your own risk because I am not
# responsible  for what you decide to run on your computer... I didn't tell you to run it ,
# so.... yeah... use it at your own risk
# Check if zenity is installed, if not install it



if ! command -v zenity &> /dev/null
then
    echo "zenity not found. Installing..."
    sudo apt-get install -y zenity
fi

# Function to display menu options using zenity
display_menu() {
    choice=$(zenity --list \
        --title="Todo and Toget List" \
        --column="Option" --column="Description" \
        "Add Todo" "Add item to Todo list" \
        "Mark Todo Done" "Mark item in Todo list as done" \
        "Add Toget" "Add item to Toget list" \
        "Mark Toget Gotten" "Mark item in Toget list as gotten" \
        "Add Note" "Add note to an item" \
        "Display Lists" "Display todo and to-get lists" \
        "Save Lists" "Save lists" \
        "Delete Item" "Delete an item" \
        "View/Edit Note" "View or edit note for an item" \
        "Load Lists" "Load previously saved lists" \
        "Edit Note" "Edit existing note for an item" \
        "Display Notes" "Display notes alongside corresponding items in the lists" \
        "Exit" "Exit the program")

    if [ -z "$choice" ]
    then
        zenity --error --text="Invalid choice. Please try again."
        return
    fi

    case $choice in
        "Add Todo") add_todo ;;
        "Mark Todo Done") mark_todo_done ;;
        "Add Toget") add_toget ;;
        "Mark Toget Gotten") mark_toget_gotten ;;
        "Add Note") add_note;;
        "Display Lists" | "Display Todo List" | "Display Toget List") display_lists ;;
        "Save Lists") save_lists;;
        "Delete Item") delete_item ;;
        "View/Edit Note" | "Edit Note") view_edit_note ;;
        "Load Lists") load_lists ;;
        "Display Notes") display_notes ;;
        "Exit") exit ;;
        *) zenity --error --text="Invalid choice. Please try again." ;;
    esac
}

# Function to add item to Todo list
add_todo() {
    todo_item=$(zenity --entry --text="Enter todo item:")
    if [ -z "$todo_item" ]
    then
        zenity --error --text="Todo item cannot be empty. Please try again."
        return
    fi
    echo "$todo_item [TODO]" >> todo.txt
    zenity --info --text="Item added to Todo list."
}

# Function to mark item in Todo list as done
mark_todo_done() {
    index=$(zenity --entry --text="Enter index of item to mark as done:")
    if ! [[ $index =~ ^[0-9]+$ ]]
    then
        zenity --error --text="Index must be a number. Please try again."
        return
    fi
    if [ $(grep -c "^$index \[TODO\]" todo.txt) -eq 0 ]
    then
        zenity --error --text="Item not found in Todo list. Please try again."
        return
    fi
    sed -i "s/^\($index \[TODO\]\)/[$index [DONE]]/" todo.txt
    zenity --info --text="Item marked as done in Todo list."
}

# Function to add item to Toget list
add_toget() {
    toget_item=$(zenity --entry --text="Enter item to get:")
    if [ -z "$toget_item" ]
    then
        zenity --error --text="Item cannot be empty. Please tryagain."
        return
    fi
    echo "$toget_item [TOGET]" >> toget.txt
    zenity --info --text="Item added to Toget list."
}

# Function to mark item in Toget list as gotten
mark_toget_gotten() {
    index=$(zenity --entry --text="Enter index of item to mark as gotten:")
    if ! [[ $index =~ ^[0-9]+$ ]]
    then
        zenity --error --text="Index must be a number. Please try again."
        return
    fi
    if [ $(grep -c "^$index \[TOGET\]" toget.txt) -eq 0 ]
    then
        zenity --error --text="Item not found in Toget list. Please try again."
        return
    fi
    sed -i "s/^\($index \[TOGET\]\)/[$index [GOTTEN]]/" toget.txt
    zenity --info --text="Item marked as gotten in Toget list."
}

# Function to add note to an item
add_note() {
    index=$(zenity --entry --text="Enter index of item to add note to:")
    if ! [[ $index =~ ^[0-9]+$ ]]
    then
        zenity --error --text="Index must be a number. Please try again."
        return
    fi
    if [ $(grep -c "^$index \[TODO\]" todo.txt) -eq 0 ] && [ $(grep -c "^$index \[TOGET\]" toget.txt) -eq 0 ]
    then
        zenity --error --text="Item not found in Todo or Toget list. Please try again."
        return
    fi
    note=$(zenity --entry --text="Enter note:")
    if [ -z "$note" ]
    then
        zenity --error --text="Note cannot be empty. Please try again."
        return
    fi
    echo "$index $note" >> notes.txt
    zenity --info --text="Note added to item."
}

# Function to display lists
display_lists() {
    todo=$(cat todo.txt 2>/dev/null)
    toget=$(cat gotten.txt 2>/dev/null)
    zenity --text-info --title="Lists" --width=500 --height=300 --filename=- <<< "Todo List:\n$todo\n\nToget List:\n$toget"
}

# Function to save lists
save_lists() {
    if [ -f todo_backup.txt ]
    then
        mv todo_backup.txt todo.txt
    fi
    if [ -f gotten_backup.txt ]
    then
        mv gotten_backup.txt gotten.txt
    fi
    if [ -f notes.txt ]
    then
        cat notes.txt >> todo.txt
        cat notes.txt >> gotten.txt
        rm notes.txt
    fi
    zenity --info --text="Lists saved."
}

# Function to delete an item
delete_item() {
    index=$(zenity --entry --text="Enter index of item to delete:")
    if ! [[ $index =~ ^[0-9]+$ ]]
    then
        zenity --error --text="Index must be a number. Please try again."
        return
    fi
    if [ $(grep -c "^$index \[TODO\]" todo.txt) -eq 0 ] && [ $(grep -c "^$index \[TOGET\]" gotten.txt) -eq 0 ]
    then
        zenity --error --text="Item not found in Todo or Toget list. Please try again."
        return
    fi
    sed -i "${index}d" todo.txt
    sed -i "${index}d" gotten.txt
    zenity --info --text="Item deleted."
}

# Function to view or edit note for an item
view_edit_note() {
    index=$(zenity --entry --text="Enter index of item to view or edit note for:")
    if ! [[ $index =~ ^[0-9]+$ ]]
    then
        zenity --error --text="Index must be a number. Please tryagain."
        return
    fi
    note=$(grep "^$index" notes.txt)
    if [ -z "$note" ]
    then
       note=$(zenity --entry --text="Enter note for item $index:")
    else
        note=$(zenity --entry --text="Enter new note for item $index (leave blank to clear):")
        if [ -z "$note" ]
        then
            sed -i "/^$index/d" notes.txt
            return
        fi
    fi
    echo "$index $note" >> notes.txt
    zenity --info --text="Note updated for item."
}

# Function to load previously saved lists
load_lists() {
    if [ -f todo_backup.txt ]
    then
        mv todo_backup.txt todo.txt
    fi
    if [ -f gotten_backup.txt ]
    then
        mv gotten_backup.txt gotten.txt
    fi
    if [ -f notes.txt ]
    then
        cat notes.txt >> todo.txt
        cat notes.txt >> gotten.txt
        rm notes.txt
    fi
    zenity --info --text="Lists loaded."
}

# Function to edit an existing note for an item
edit_note() {
    index=$(zenity --entry --text="Enter index of item to edit note for:")
    if ! [[ $index =~ ^[0-9]+$ ]]
    then
        zenity --error --text="Index must be a number. Please try again."
        return
    fi
    note=$(grep "^$index" notes.txt)
    if [ -z "$note" ]
    then
        zenity --error --text="Note not found for item $index."
        return
    fi
    new_note=$(zenity --entry --text="Enter new note for item $index:" --entry-text="$note")
    if [ -z "$new_note" ]
    then
        sed -i "/^$index/d" notes.txt
        zenity --info --text="Note deleted for item $index."
    else
        sed -i "s/^$index .*/$index $new_note/" notes.txt
        zenity --info --text="Note updated for item $index."
    fi
}

# Function to display notes alongside corresponding items in the lists
display_notes() {
    notes=$(cat notes.txt)
    zenity --text-info --title="Notes" --width=500 --height=300 --filename=- <<< "Notes:\n$notes"
}

# Main loop
while true; do
    display_menu
done
