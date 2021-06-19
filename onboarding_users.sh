#!/bin/bash
#
# Onboard 20 new users on a Linux Server
# Each user will have a HOME directory

#CSV file containing the names of new users
CSV_FILE=names.csv

# Name of group to add all new users to
GROUP_NAME=developers 

# .ssh folder to be created in each user's home directory
SSH_SKEL_FOLDER="/etc/skel/.ssh/"

# public key file to be adde to each user's .ssh directory
AUTH_KEY=authorized_keys

# default password for all the users
PASSWORD=password



#check if group exists
if [ $(getent group developers) ]
then
   echo "group already exists"
else    
   sudo groupadd $GROUP_NAME
   echo "group successfully added"
fi

# check if ssh folder  exists in the skeleton folder(i.e /etc/skel)
# If not add create the skel folder and add the authorized_key file to it   
if [ -d "$SSH_SKEL_FOLDER" ]
then
   echo "$SSH_SKEL_FOLDER already exists"
else
   sudo mkdir -p $SSH_SKEL_FOLDER
   sudo bash -c "cat $AUTH_KEY >> $SSH_SKEL_FOLDER/authorized_keys"
fi       

# create each user on the server
while IFS= read USERNAME
 do
   #check if user already exists
   if [ $(getent passwd $USERNAME) ]
    then
      echo "$USERNAME already exists"
    else
      sudo useradd -m -G $GROUP_NAME -s/bin/bash $USERNAME
      sudo echo -e "$PASSWORD\n$PASSWORD" | sudo passwd "${USERNAME}"
      sudo passwd -x 7 ${USERNAME}
      sudo chmod 700 /home/$USERNAME/.ssh
      sudo chmod 644 /home/$USERNAME/.ssh/$AUTH_KEY
      echo "$USERNAME successfully created" 
    fi

done < "$CSV_FILE"      

exit 0
