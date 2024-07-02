#!/bin/bash

FILE=$1
LINE=$2

OPEN_COMMAND=":e $FILE | :$LINE"

TERMINAL="Kitty"
SESSION="sana"
WINDOW="client"
PANE=0

tmux has-session -t $SESSION 2>/dev/null

if [ $? != 0 ]; then
	echo "Session $SESSION does not exist."
else
	tmux select-window -t $WINDOW
	tmux send-keys -t $PANE $OPEN_COMMAND Enter
	osascript -e 'tell application "'$TERMINAL'" to activate'
fi
