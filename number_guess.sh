#!/bin/bash
RANDOM_NUMBER=$(( RANDOM % 1000 + 1))
echo "Enter your username:"
read USERNAME
#SQL access
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
USER_DB=$($PSQL "SELECT username FROM number_guess WHERE username='$USERNAME'")
if [[ -z $USER_DB ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else
  USER_INFO=$($PSQL "SELECT games_played, best_game FROM number_guess WHERE username='$USERNAME'")
  echo $USER_INFO | while IFS="|" read GAMES_PLAYED BEST_GAME
  do    
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  done
fi
TRIES=0
NUMBER=0
echo "Guess the secret number between 1 and 1000:"
read USER_NUMBER
while [[ $NUMBER == 0 ]]
do
  if [[ ! $USER_NUMBER =~ ^[0-9]+$ ]]
  then
    #not a valid integer
    echo "That is not an integer, guess again:"
    read USER_NUMBER
  else
    #valid integer
    TRIES=$((TRIES + 1))
    if [[ $USER_NUMBER > $RANDOM_NUMBER ]]
    then
      echo "It's lower than that, guess again:"
      read USER_NUMBER
    elif [[ $USER_NUMBER < $RANDOM_NUMBER ]]
    then
      echo "It's higher than that, guess again:"
      read USER_NUMBER
    else
      if [[ -z $USER_DB ]]
      then
        #New user
        RESULT=$($PSQL "INSERT INTO number_guess(username,games_played,best_game) VALUES ('$USERNAME',1,$TRIES)")
      else
        echo $($PSQL "SELECT games_played,best_game FROM number_guess WHERE username='$USERNAME'") | while IFS="|" read GAMES BEST
        do
          GAMES=$((GAMES +1))
          if [[ $BEST > $TRIES ]]
          then
            BEST=$TRIES
          fi
          RESULT=$($PSQL "UPDATE number_guess SET games_played=$GAMES, best_game=$BEST WHERE username='$USERNAME'")
        done
      fi
      NUMBER=1
      echo "You guessed it in $TRIES tries. The secret number was $RANDOM_NUMBER. Nice job!"
    fi
  fi
done
  

