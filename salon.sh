#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo "Welcome to My Salon, how can I help you?"

MENU () {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  # display number of services
  SERVICES_OFFERED=$($PSQL "SELECT * FROM services")

  echo "$SERVICES_OFFERED" | while read SERVICE_ID NAME
  do
    echo -e "$SERVICE_ID) $NAME" | sed 's/ |//'
  done;

  read SERVICE_ID_SELECTED

  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    #send to main menu
    MENU "That is not a valid service number."
  else
    #get service availability
    SERVICE_AVAILABILITY=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")
    #if not available
    if [[ -z $SERVICE_AVAILABILITY ]]
    then
      #send to main menu
      MENU "I could not find that service. What would you like today?"
    else
      # ask for customer number
      echo "What's your phone number?"   
      read CUSTOMER_PHONE     
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

      # if customer doesn't exist
      if [[ -z $CUSTOMER_NAME ]]
      then
        # ask for customer name
        echo "I don't have a record for that phone number, what's your name?"
        read CUSTOMER_NAME
        INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
      fi

      #get customer id
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

      #get time of service
      echo "What time would you like your cut, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')?"
      read SERVICE_TIME

      INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

      #get service name
      SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

      echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."
    fi
  fi
  
}

MENU
