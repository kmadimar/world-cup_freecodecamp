#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
$PSQL "TRUNCATE TABLE games, teams"

# Read games.csv and insert data into the database
cat games.csv | while IFS=',' read year round winner opponent winner_goals opponent_goals
do
  # Skip the header row
  if [[ $year != "year" ]]
  then
    # Insert winner team if it doesn't exist
    winner_id=$($PSQL "SELECT team_id FROM teams WHERE name='$winner'")
    if [[ -z $winner_id ]]
    then
      INSERT_WINNER_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$winner')")
      if [[ $INSERT_WINNER_RESULT == "INSERT 0 1" ]]
      then
        winner_id=$($PSQL "SELECT team_id FROM teams WHERE name='$winner'")
      fi
    fi

    # Insert opponent team if it doesn't exist
    opponent_id=$($PSQL "SELECT team_id FROM teams WHERE name='$opponent'")
    if [[ -z $opponent_id ]]
    then
      INSERT_OPPONENT_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$opponent')")
      if [[ $INSERT_OPPONENT_RESULT == "INSERT 0 1" ]]
      then
        opponent_id=$($PSQL "SELECT team_id FROM teams WHERE name='$opponent'")
      fi
    fi

    # Insert game
    INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($year,'$round', $winner_id, $opponent_id, $winner_goals, $opponent_goals)")
  fi
done
