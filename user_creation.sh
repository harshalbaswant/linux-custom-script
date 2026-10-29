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
