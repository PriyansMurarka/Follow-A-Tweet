#!/bin/bash

############################################################################
# Script Name: follow-a-tweet.sh
# Creator    : Priyans
# Example    : sh follow-a-tweet.sh https://twitter.com/priyansm/status/371531619103805440 20m
############################################################################

if ($# -ne 2)
then
	echo "Usage: ./follow-a-tweet.sh <original-tweet-url> <delay>"
	echo "Eg: ./follow-a-tweet.sh https://twitter.com/priyansm/status/371531619103805440 20m"
	echo "Note: Delay can be entered in either of the formats: 20s 4m 10h 5d"
fi
while :
do
	clear
	reply=twitter-atreply 												# Key word to find "replies" in source code
	replies_arr_ind='0' 												# Index of replies
	replies_arr_index=0													# Index of replies
	reply_end="</p>"													# Key word to end a reply.
	person_reply_arr=0													# Storing person's name
	person_reply_arr_ind='0'											# Index of replied person
	person_reply_arr_index=0											# Index of replied person
	substring1='><s>@</s><b>'
	substring2='</b></a>'
	substring3='</p>'
	replacement1='@'
	replacement2=''
	replacement3=''
	tweet_page=$(wget $1 -q -O -) 										# Gets the source code and stores in the variable.
	tweet_page=$(echo "$tweet_page"|tr -dc ‘[:print:]‘) 				# Removes all the non printable ASCII characters
	read -a array <<< "$tweet_page" 									# Converts the variable tweet_page to an array
	for index in "${!array[@]}"
	do
		if(echo "${array[index]}"|grep "$reply");						# Find the unique starting point of the tweet
		then
			clear
			reply_index=$((index+3))									# Converting index string to reply_index number and incrementing it by 3
			reply_ind=$(printf $reply_index)							# Converting number reply_index to a string
			reply_arr[replies_arr_ind]=${array[reply_ind]}				# Following steps just clear away the clutter.
			reply_arr[replies_arr_ind]=${reply_arr[replies_arr_ind]/$substring1/$replacement1}
			reply_arr[replies_arr_ind]=${reply_arr[replies_arr_ind]/$substring2/$replacement2}
			while :
			do
				if(!(echo "${array[reply_ind]}" | grep $reply_end ));	# Reply is till you find </p>
				then
					clear
					reply_index=$((reply_index+1))
					reply_ind=$(printf $reply_index)
					reply_arr[replies_arr_ind]="${reply_arr[replies_arr_ind]} ${array[reply_ind]}"
					clear
				else
					break
				fi
				reply_arr[replies_arr_ind]=${reply_arr[replies_arr_ind]/$substring3/$replacement3}
			done
			((replies_arr_index++))
			replies_arr_ind=$(printf $replies_arr_index)
			clear
		fi
		if(echo "${array[reply_ind]}" | grep $reply_end );
		then
			clear
			reply_index=$((reply_index+7))								# Need to find out who replied. 7 ahead.
			reply_ind=$(printf $reply_index)
			person_reply_arr[person_reply_arr_ind]=$(echo "${array[reply_ind]}")
			clear
			person_reply_arr[person_reply_arr_ind]=${person_reply_arr[person_reply_arr_ind]#*/}
			clear
			person_reply_arr[person_reply_arr_ind]=${person_reply_arr[person_reply_arr_ind]%/*}
			clear
			person_reply_arr[person_reply_arr_ind]=${person_reply_arr[person_reply_arr_ind]%/*}
			clear
			((person_reply_arr_index++))
			person_reply_arr_ind=$(printf $person_reply_arr_index)
			clear
		fi
	done
	echo "Replies:"
	for x in "${!reply_arr[@]}"
	do
		echo "${person_reply_arr[x]} replied: ${reply_arr[x]}"
		echo "------------------------------------------------"
		notify-send "Reply to tweet you are following" "${person_reply_arr[x]} replied: ${reply_arr[x]}" # Send notification.
	done
	sleep "$2"															# Sleep for the desired amount of time.
done
