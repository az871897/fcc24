#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
SECRET_NUMBER=$(($RANDOM % 1000 + 1))

GET_DATA() {
     USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
     GAMES_PLAYED=$($PSQL "SELECT COUNT(game_id) FROM games WHERE user_id=$USER_ID")
     BEST_GAME=$($PSQL "SELECT MIN(number_of_guesses) FROM games WHERE user_id=$USER_ID")
}

POST() {
     INSERT_GAME=$($PSQL "INSERT INTO games(number_of_guesses, user_id) VALUES($NUMBER_OF_GUESSES, $USER_ID)")
     GET_GAMES_PLAYED=$($PSQL "SELECT COUNT(game_id) FROM games WHERE user_id=$USER_ID")
     UPDATE_GAMES_PLAYED=$($PSQL "UPDATE users SET games_played=$GET_GAMES_PLAYED+1 WHERE user_id=$USER_ID")
     
     BEST_GAME_UPDATED=$($PSQL "SELECT MIN(number_of_guesses) FROM games WHERE user_id=$USER_ID")
     UPDATE_BEST=$($PSQL "UPDATE users SET best_game=$BEST_GAME_UPDATED WHERE user_id=$USER_ID")
     
     echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"  
}

CHECK() {
  
  if [[ $1 =~ ^[0-9]+$ ]]
  then
     NUMBER_OF_GUESSES=$(( $2 + 1 ))
     if (( $1 > $SECRET_NUMBER ))
          then echo "It's lower than that, guess again:"
               read NEWGUESS
               CHECK $NEWGUESS $NUMBER_OF_GUESSES
     elif (( $1 < $SECRET_NUMBER )) 
          then echo "It's higher than that, guess again:"
               read NEWGUESS
               CHECK $NEWGUESS $NUMBER_OF_GUESSES
     else 
          POST          
     fi
  else echo That is not an integer, guess again:
       read GUESS
       NUMBER_OF_GUESSES=0
       CHECK $GUESS $NUMBER_OF_GUESSES
  fi
}

INTRO() {
     echo Enter your username:
     read USERNAME

     USER_RESULT=$($PSQL "SELECT username FROM users WHERE username='$USERNAME'")

     if [[ -z $USER_RESULT ]]
          then 
               NEW_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
               USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
               GAMES_PLAYED=$($PSQL "UPDATE users SET games_played=0 WHERE user_id=$USER_ID")
               echo "Welcome, $USERNAME! It looks like this is your first time here."
          else 
               GET_DATA
               echo "Welcome back, $USER_RESULT! You have played $GAMES_PLAYED $( if [[ $GAMES_PLAYED -gt 1 ]]; then echo games; else echo game; fi ), and your best game took $BEST_GAME $( if [[ $BEST_GAME -gt 1 ]]; then echo guesses; else echo guess; fi )."
     fi
     }

INTRO
echo "Guess the secret number between 1 and 1000:"
read GUESS
NUMBER_OF_GUESSES=0
CHECK $GUESS $NUMBER_OF_GUESSES
