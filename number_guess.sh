#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# generate a random number between 1 and 1000
SECRET_NUMBER=$(( $RANDOM % 1000 + 1 ))
echo $SECRET_NUMBER

# initialize guess counter
NUMBER_OF_GUESSES=0

# prompt for username
echo "Enter your username:"
read USERNAME
GAMES_PLAYED=$($PSQL "SELECT games_played FROM user_profile WHERE username='$USERNAME'")
BEST_GAME=$($PSQL "SELECT best_game FROM user_profile WHERE username='$USERNAME'")

if [[ -z $GAMES_PLAYED ]] 
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# Ask user for their initial guess
echo "Guess the secret number between 1 and 1000:"

while [[ $USER_GUESS != $SECRET_NUMBER ]] 
do
  read USER_GUESS
  # if guess is not an integer, ask for another guess
  while [[ ! $USER_GUESS =~ ^[0-9]+$ ]] 
  do
    echo "That is not an integer, guess again:"
    read USER_GUESS
  done

  # increment number of guesses
  NUMBER_OF_GUESSES=$(( NUMBER_OF_GUESSES+1 ))

  # if guess equals the secret number
  if [[ $USER_GUESS -eq $SECRET_NUMBER ]] 
  then
    echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $USER_GUESS. Nice job!"
  elif [[ $USER_GUESS -lt $SECRET_NUMBER ]] 
  then
    echo "It's higher than that, guess again:"
  elif [[ $USER_GUESS -gt $SECRET_NUMBER ]] 
  then
    echo "It's lower than that, guess again:"
  fi
done

# save user data 
if [[ -z $GAMES_PLAYED ]] 
then
  # insert new player
  INSERT_RESULT=$($PSQL "INSERT INTO user_profile(username,games_played,best_game) VALUES('$USERNAME', 1, $NUMBER_OF_GUESSES)")
else
  # update existing player
  if [[ $NUMBER_OF_GUESSES -lt $BEST_GAME ]]
  then 
    BEST_GAME=$NUMBER_OF_GUESSES
  fi
  UPDATE_RESULT=$($PSQL "UPDATE user_profile SET games_played=$(($GAMES_PLAYED+1)), best_game=$BEST_GAME WHERE username='$USERNAME'")
fi

