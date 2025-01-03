#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=periodic_table --tuples-only -c"

if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
else
  ELEMENT_INFO=$($PSQL "SELECT * FROM elements WHERE CAST(atomic_number AS VARCHAR) = '$1' OR symbol = '$1' OR name = '$1'")

  # If the result is empty then the argument passed was NOT an atomic number OR an element's symbol OR an element's name.
  if [[ -z $ELEMENT_INFO ]]
  then
    echo -e "I could not find that element in the database."
  else 
    # Split the ELEMENT_INFO into the matching column values.
    ATOMIC_NUM=$(echo $ELEMENT_INFO | sed -E 's/ \|.+//') 
    SYMBOL=$(echo $ELEMENT_INFO | sed -E 's/^[0-9]+ \| //' | sed -E 's/ \| [A-Za-z]+$//')
    NAME=$(echo $ELEMENT_INFO | sed -E 's/^.+\| //')
   
    # Go get the property element for the element submitted.
    PROPERTY_INFO=$($PSQL "SELECT atomic_mass, melting_point_celsius, boiling_point_celsius, type_id FROM properties WHERE atomic_number = CAST('$ATOMIC_NUM' AS INT)")

    # Split the line using sed.
    ATOMIC_MASS=$(echo $PROPERTY_INFO | sed -E 's/ \| [0-9.\-]+ \| [0-9.\-]+ \| [0-9]+$//')
    MELTING_P_C=$(echo $PROPERTY_INFO |  sed -E 's/^[0-9.]+ \| //' | sed -E 's/ \| [-0-9.]+ \| [0-9]+$//')
    BOILING_P_C=$(echo $PROPERTY_INFO | sed -E 's/^[0-9.]+ \| [0-9.\-]+ \| //' | sed -E 's/ \| [0-9]+$//')
    TYPE_ID=$(echo $PROPERTY_INFO | sed -E 's/^[0-9.]+ \| [0-9.\-]+ \| [0-9.\-]+ \| //')

    # get the type based on the value of type_id.
    TYPE=$($PSQL "SELECT type FROM types WHERE type_id = '$TYPE_ID'" | sed 's/^ //')

    # result
    echo -e "The element with atomic number $ATOMIC_NUM is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_P_C celsius and a boiling point of $BOILING_P_C celsius."
  fi
fi
