#!/bin/bash

# Check whether the script is running with root privileges
if [[ $EUID -ne 0 ]]; then
    echo "Error: Please run this script using sudo."
    echo "Usage: sudo $0"
    exit 1
fi

# Take username input
read -r -p "Enter username: " username

# Validate username
if [[ ! "$username" =~ ^[a-z_][a-z0-9_-]*[$]?$ ]]; then
    echo "Error: Invalid username."
    exit 1
fi

# Check whether the user already exists
if id "$username" &>/dev/null; then
    echo "Error: User '$username' already exists."
    exit 1
fi

# Create the user
if ! useradd -m "$username"; then
    echo "Error: Failed to create user."
    exit 1
fi

echo "User '$username' created successfully."

# Take password input securely
while true; do
    read -r -s -p "Enter password: " password
    echo

    read -r -s -p "Confirm password: " confirm_password
    echo

    if [[ -z "$password" ]]; then
        echo "Password cannot be empty. Try again."
    elif [[ "$password" != "$confirm_password" ]]; then
        echo "Passwords do not match. Try again."
    else
        break
    fi
done

# Set password securely
if printf '%s:%s\n' "$username" "$password" | chpasswd; then
    echo "Password set successfully for '$username'."
else
    echo "Error: Password setting failed."
    echo "The user '$username' exists but may not have a valid password."
    unset password confirm_password
    exit 1
fi

# Clear password variables
unset password confirm_password

echo "User creation completed successfully."
echo "Home directory: /home/$username"



Note: After saving the script I've created alias i.e "createuser".

1. Move the script to a permanent location
For example, store it in /usr/local/sbin/:

$sudo cp create_user.sh /usr/local/sbin/create_user.sh
$sudo chmod 755 /usr/local/sbin/create_user.shnano 

2. Add the permanent alias
Open your Bash configuration file:
$ vi ~/.bashrc

Add this line at the end:

alias createuser='sudo /usr/local/sbin/create_user.sh'

Save and exit.

3. Apply the changes
source ~/.bashrc

5. Verify the alias

alias createuser


Note: This alias is permanent for your current user because it is stored in ~/.bashrc. 
      Other users will need their own alias, or an administrator can configure a system-wide alias in /etc/bashrc.
