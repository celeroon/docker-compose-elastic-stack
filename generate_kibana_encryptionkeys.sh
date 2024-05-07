#!/bin/bash

# Function to generate a random string of specified length
generate_random_string() {
    local length=$1
    head /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w "$length" | head -n 1
}

# Function to check if a variable exists in the .env file
variable_exists_in_env() {
    local variable_name=$1
    grep -q "^$variable_name=" .env
}

# Define the length of the random strings
LENGTH=32

# Generate new random values or replace existing values for each variable
if variable_exists_in_env "XPACK_ENCRYPTEDSAVEDOBJECTS_ENCRYPTIONKEY"; then
    XPACK_ENCRYPTEDSAVEDOBJECTS_ENCRYPTIONKEY=$(generate_random_string "$LENGTH")
    sed -i "s/^XPACK_ENCRYPTEDSAVEDOBJECTS_ENCRYPTIONKEY=.*/XPACK_ENCRYPTEDSAVEDOBJECTS_ENCRYPTIONKEY=$XPACK_ENCRYPTEDSAVEDOBJECTS_ENCRYPTIONKEY/" .env
else
    XPACK_ENCRYPTEDSAVEDOBJECTS_ENCRYPTIONKEY=$(generate_random_string "$LENGTH")
    echo "XPACK_ENCRYPTEDSAVEDOBJECTS_ENCRYPTIONKEY=$XPACK_ENCRYPTEDSAVEDOBJECTS_ENCRYPTIONKEY" >> .env
fi

if variable_exists_in_env "XPACK_REPORTING_ENCRYPTIONKEY"; then
    XPACK_REPORTING_ENCRYPTIONKEY=$(generate_random_string "$LENGTH")
    sed -i "s/^XPACK_REPORTING_ENCRYPTIONKEY=.*/XPACK_REPORTING_ENCRYPTIONKEY=$XPACK_REPORTING_ENCRYPTIONKEY/" .env
else
    XPACK_REPORTING_ENCRYPTIONKEY=$(generate_random_string "$LENGTH")
    echo "XPACK_REPORTING_ENCRYPTIONKEY=$XPACK_REPORTING_ENCRYPTIONKEY" >> .env
fi

if variable_exists_in_env "XPACK_SECURITY_ENCRYPTIONKEY"; then
    XPACK_SECURITY_ENCRYPTIONKEY=$(generate_random_string "$LENGTH")
    sed -i "s/^XPACK_SECURITY_ENCRYPTIONKEY=.*/XPACK_SECURITY_ENCRYPTIONKEY=$XPACK_SECURITY_ENCRYPTIONKEY/" .env
else
    XPACK_SECURITY_ENCRYPTIONKEY=$(generate_random_string "$LENGTH")
    echo "XPACK_SECURITY_ENCRYPTIONKEY=$XPACK_SECURITY_ENCRYPTIONKEY" >> .env
fi

echo "Random strings generated and updated in .env file:"
echo "XPACK_ENCRYPTEDSAVEDOBJECTS_ENCRYPTIONKEY=$XPACK_ENCRYPTEDSAVEDOBJECTS_ENCRYPTIONKEY"
echo "XPACK_REPORTING_ENCRYPTIONKEY=$XPACK_REPORTING_ENCRYPTIONKEY"
echo "XPACK_SECURITY_ENCRYPTIONKEY=$XPACK_SECURITY_ENCRYPTIONKEY"
