#!/bin/bash

#******************************************************************************#
# BlockManyUsers.sh - Block many users in a system using a text file           #
#                       as argument                                            #
#   Copyright (C) 2008 - written by flynets - <flynets<at>autistici<dot>org>   #
#   BlockManyUsers is free software: you can redistribute it and/or modify     #
#   it under the terms of the GNU General Public License as published by       #
#   the Free Software Foundation, either version 3 of the License, or          #
#   any later version.                                                         #
#                                                                              #
#   BlockManyUsers is distributed in the hope that it will be useful,          #
#   but WITHOUT ANY WARRANTY; without even the implied warranty of             #
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the               #
#   GNU General Public License for more details.                               #
#                                                                              #
#   You should have received a copy of the GNU General Public License          #
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.      #
#******************************************************************************#

# Checks if you have the right privileges
if [ "$USER" = "root" ];then
   # Checks if there is an argument
   [ $# -eq 0 ] && { echo >&2 ERROR: You may enter as an argument a text file containing users, one per line. ; exit 1; }
   # checks if there a regular file
   [ -f "$1" ] || { echo >&2 ERROR: The input file does not exists. ; exit 1; }
   TMPIN=$(mktemp)
   # Remove blank lines and delete duplicates
   sed '/^$/d' "$1"| sort -g | uniq > "$TMPIN"
   
   NOW=$(date +"%Y-%m-%d-%X")
   LOGFILE="BMU-log-$NOW.log"

   for user in $(more "$TMPIN"); do
      # Checks if the user already exists.
      cut -d: -f1 /etc/passwd | grep "$user" > /dev/null
      OUT=$?
      if [ $OUT -eq 0 ];then
         # block selected user
         /usr/sbin/usermod -L "$user"
         # save user info in a file
         echo The user \"$user\" has been blocked. >> "$LOGFILE"
      else
        echo >&2 Error the user account \"$user\" doesnt exists! >> "$LOGFILE"
      fi
   done
   rm -f $TMPIN
   exit 0
else
   echo >&2 ERROR: You must be a root user to execute this script.
   exit 1
fi
exit 0
