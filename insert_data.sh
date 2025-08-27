#! /bin/bash

#
# World Cup Database ETL Script
# Description: Imports CSV data into PostgreSQL with validation and error handling
# Author: sglavas
# Date: 2025-08-27
#

PSQL="docker exec worldcup-db psql --username=postgres --dbname=worldcup --no-align --tuples-only -c"


# Exit on any error
set -e

# Function for error handling
HANDLE_ERROR() {
  echo "Error occurred at line $1" >&2
  echo "Last command: ${BASH_COMMAND}" >&2
  exit 1
}

trap 'HANDLE_ERROR $LINENO' ERR

# Truncate teams and games tables when script is executed
echo "Truncating tables..."
echo $($PSQL "TRUNCATE teams, games;")
echo "Tables truncated successfully."


# Use counter for progress
COUNT=0
TOTAL=$(($(wc -l < games.csv) - 1))

echo "Processing $TOTAL games..."

# Use file descriptor 3 for the CSV input
while IFS=',' read -u 3 YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  # Skip the first line
  if [[ $YEAR != "year" ]]
  then

    # Sanitize inputs to prevent SQL injection
    SANITIZE() {
      echo "$1" | sed "s/'/''/g"
    }

    ROUND=$(SANITIZE "$ROUND")
    WINNER=$(SANITIZE "$WINNER")
    OPPONENT=$(SANITIZE "$OPPONENT")

    # Increment COUNT to track progress
    COUNT=$((COUNT + 1))

    # Display progress
    echo "[$COUNT/$TOTAL] Processing: $WINNER vs $OPPONENT ($YEAR $ROUND)"

    # get winner_id
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER';")

    # if not found
    if [[ -z $WINNER_ID ]]
    then
      # insert winner team into teams table
      INSERT_WINNER_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER');")

      # get new winner_id
      WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER';")

    fi

    # get opponent_id
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")

    # if not found
    if [[ -z $OPPONENT_ID ]]
    then
      # insert opponent id into teams table
      INSERT_OPPONENT_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      
      # get new opponent_id
      OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT';")

    fi

    # insert game into games table
    INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS);")
    
  fi
done 3< games.csv


echo "Data import completed successfully! Processed $COUNT games."
