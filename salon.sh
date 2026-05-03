#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

SERVICES=$($PSQL "SELECT service_id, name FROM services")

MAIN_MENU() {
  if [[ $1 ]] 
  then
    echo -e "\n$1"
  fi
  echo -e "\nWelcome to Fresh Ballin Salon"
  echo -e "Please choose your service:"
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
  echo "4) exit"
  read SERVICE_ID_SELECTED
  case $SERVICE_ID_SELECTED in
    1|2|3) BOOK_APPOINTMENT $SERVICE_ID_SELECTED ;;
    4) EXIT ;;
    *) MAIN_MENU "Please enter a valid option." ;;
  esac 
}

BOOK_APPOINTMENT() {
  SERVICE_ID_SELECTED=$1

  # get sercvice name
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  
  # ask for phone
  echo -e "\nWhat is your phone number bro/sis?"
  read CUSTOMER_PHONE

  # check if customer exists
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

  # if not found, ask for name
  if [[ -z $CUSTOMER_NAME ]] 
  then
    echo -e "\nWhat's your name bro/sis?"
    read CUSTOMER_NAME
    # create new customer
    CUSTOMER_INSERT_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
  fi

  # ask for time
  echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
  read SERVICE_TIME

  # get customer_id
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

  # create appointment
  CREATE_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
  echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
}

EXIT() {
  echo -e "\nThank you for stopping by!"
}

MAIN_MENU