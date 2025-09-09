#!/bin/bash

#----------------------- Start Utils Fuctions---------------------------------------

function validateParamName {
    
    if [ -z "$1" ]
    then
        echo "The name field cannot be left empty"
        return 1
    elif [[ "$1" =~ ^[0-9] ]]
    then
        echo "Name should not begin with a number"
        return 1
    elif [[ "$1" = *" "* ]]
    then
        echo "Name Shouldn't Have Spaces"
        return 1
    elif [[ "$1" =~ [^a-zA-Z0-9_] ]]
    then
        echo "Name Shouldn't Have Special Characters"
        return 1
    fi
    
}

#$1 -> Value
#$2 -> datatype
function validateDataType {
    
    if [ -z "$1" ]
    then
        echo " value can't be empty."
        return 1
    fi
    
    if [[ "$1" =~ ^[0-9]+$ ]]
    then
        if [ "$2" == "integer" ]
        then
            return 0
        else
            echo "The value should be a String."
            return 1
        fi
    fi
    
    if [[ "$1" =~ ^[a-zA-Z0-9_@.]+$ ]];
    then
        if [ "$2" == "string" ]
        then
            return 0
        else
            echo "The value should be an Integer."
            return 1
        fi
    fi
    
}


#----------------------- End Utils Fuctions-----------------------------------------

#----------------------- Start Fuctions Area-----------------------------------------

function createDb {
    
    typeset status DbName
    
    while true
    do
        read -p "Enter the Database name: " DbName
        validateParamName $DbName
        if [ $? -eq 0 ]
        then
            break
        fi
    done
    
    if [ -d "databases/$DbName" ]
    then
        echo "A Database with same name already exist"
    else
        mkdir -p databases/$DbName
        echo "Database Created Successfully"
    fi
    
}

function listDbs {
    if [ -n "$(ls databases/ 2>/dev/null)" ]
    then
        echo "Databases List : "
        ls databases/
    else
        echo "No Databases Found"
    fi
}

function connectDb {
    
    typeset DbName
    
    if [ -z "$(ls databases/ 2>/dev/null )" ]
    then
        echo "No Databases Found To connect"
        return
    fi
    
    while true
    do
        read -p "Enter Database name: " DbName
        validateParamName $DbName
        if [ $? -eq 0 ]
        then
            break
        fi
    done
    
    if [ ! -d "databases/$DbName" ]
    then
        echo "Database Not Found"
    else
        cd databases/$DbName
        echo "You are connected to $DbName database"
        showTablesMenu
    fi
    
}

function DropDb {
    
    typeset DbName
    
    if [ -z "$(ls databases/ 2>/dev/null )" ]
    then
        echo "No Databases Found To Remove"
        return
    fi
    
    while true
    do
        read -p "Enter Database Name: " DbName
        validateParamName $DbName
        if [ $? -eq 0 ]
        then
            break
        fi
    done
    
    if [ ! -d "databases/$DbName" ]
    then
        echo "Database Not Found"
    else
        rm -r databases/$DbName
        echo "$DbName deleted successfully"
    fi
    
}

function createTable {
    
    typeset tableName cols num=0 nameRecord="" dataTypeRecord="" constraintRecord=""
    
    while true
    do
        read -p "Enter Table Name: " tableName
        validateParamName $tableName
        if [ $? -eq 0 ]
        then
            break
        fi
    done
    
    if [ -d "$tableName" ]
    then
        echo "Table Already Exists"
        return
    fi
    
    mkdir $tableName
    cd $tableName
    
    touch "${tableName}.txt"
    touch "${tableName}-meta.txt"
    
    while true
    do
        read -p "Enter Number Of Columns: " cols
        if [[ ! $cols =~ ^[0-9]+$ ]]
        then
            echo "Cols number must be a number"
        elif [ $cols -eq 0 ]
        then
            echo "Cols number should be greater than 0"
        else
            break
        fi
    done
    
    typeset colName colType constraintChoice
    while [ $num -lt $cols ]
    do
        if [ $num -eq 0 ]
        then
            echo "(Note: The first column is the Primary Key and must be UNIQUE)"
            colName=""
            while [ -z "$colName" ]; do
                read -p "Enter The PK Column Name: " colName
                validateParamName "$colName" || colName=""
            done
            colType=""
            select colType in "string" "integer"; do
                case $colType in
                    "integer" | "string" ) break ;;
                    *) echo "Invalid Choice" ;;
                esac
            done
            constraintRecord="${constraintRecord}pk:" # Mark first col as PK
        else
            colName=""
            while [ -z "$colName" ]; do
                read -p "Enter Column $((num+1)) Name: " colName
                validateParamName "$colName" || colName=""
            done
            
            colType=""
            select colType in "string" "integer"; do
                case $colType in
                    "integer" | "string" ) break ;;
                    *) echo "Invalid Choice" ;;
                esac
            done

            # Feature 2: Ask about UNIQUE constraint for non-PK columns
            constraintChoice=""
            select constraintChoice in "none" "unique"; do
                case $constraintChoice in
                    "none" | "unique" ) break ;;
                    *) echo "Invalid Choice" ;;
                esac
            done
            constraintRecord="${constraintRecord}${constraintChoice}:"
        fi
        
        if [ $num -eq $((cols-1)) ]
        then
            nameRecord="${nameRecord}${colName}"
            dataTypeRecord="${dataTypeRecord}${colType}"
        else
            nameRecord="${nameRecord}${colName}:"
            dataTypeRecord="${dataTypeRecord}${colType}:"
        fi
        let num=$num+1
    done
    # Write metadata: Line1:types, Line2:names, Line3:constraints
    echo $dataTypeRecord >> "${tableName}-meta.txt"
    echo $nameRecord >> "${tableName}-meta.txt"
    echo $constraintRecord >> "${tableName}-meta.txt"
    
    cd ../
    echo "Table '$tableName' created successfully with schema."
}

function listTables {
    if [ -z "$(ls)" ]
    then
        echo "No Tables To Show, Database Is Empty."
    else
        ls
    fi
}

function dropTable {
    typeset tableName
    
    if [ -z "$(ls)" ]
    then
        echo "No Tables To Drop, Database Is Empty."
    else
        while true
        do
            read -p "Enter Table Name: " tableName
            validateParamName $tableName
            if [ $? -eq 0 ]
            then
                break
            fi
        done
        
        if [ -d "$tableName" ]
        then
            rm -r "$tableName"
            echo "Table ${tableName} deleted successfully"
        else
            echo "Table ${tableName} Doesn't Exist"
            return
        fi
    fi
}

function insertTable {
    
    if [ -z "$(ls)" ]
    then
        echo "No Tables To Insert, Database Is Empty."
        return
    fi
    
    typeset tableName
    while true
    do
        read -p "Enter Table Name: " tableName
        validateParamName $tableName
        if [ $? -eq 0 ]
            then
            break
        fi
    done
    
    if [ ! -d "$tableName" ]
    then
        echo "Table Doesn't Exist"
        return
    fi
    
    typeset colNum
    colNum=$( head -1 ${tableName}/${tableName}-meta.txt | awk -F':' '{print NF}')
    typeset constraints=$(tail -1 ${tableName}/${tableName}-meta.txt) # Get constraints line
    
    typeset num=0
    typeset insertVal=""
    while [ $num -lt $colNum ]
    do
        typeset colName=$(sed -n '2p' ${tableName}/${tableName}-meta.txt | cut -d ':' -f $((num+1)))
        typeset colDatatype=$(sed -n '1p' ${tableName}/${tableName}-meta.txt | cut -d ':' -f $((num+1)))
        typeset colConstraint=$(echo $constraints | cut -d ':' -f $((num+1)))
        
        while true
        do
            read -p "Enter value of ${colName} (${colDatatype}): " colValue
            validateDataType "$colValue" "$colDatatype"
            dataTypeValid=$?
            
            # Feature 2: Check for UNIQUE constraint (including PK)
            if [[ $dataTypeValid -eq 0 && ( $colConstraint == "pk" || $colConstraint == "unique" ) ]]
            then
                if [ ! -z "$(awk -F: -v col=$((num+1)) -v value="$colValue" '$col == value' ${tableName}/${tableName}.txt)" ]
                then
                    echo "Error: Value must be UNIQUE for column '$colName'. '$colValue' already exists."
                    continue
                fi
            fi
            
            if [ $dataTypeValid -eq 0 ]
            then
                break
            fi
        done
        
        if [ $num -eq $((colNum-1)) ]
        then
            insertVal="${insertVal}${colValue}"
        else
            insertVal="${insertVal}${colValue}:"
        fi
        
        let num=$num+1
    done
    
    echo ${insertVal} >> "${tableName}/${tableName}.txt"
    echo "Record inserted successfully."
    
}

function deleteRecord {
    
    typeset pk tableName
    
    if [ -z "$(ls)" ]
    then
        echo "No Tables To Remove, Database Is Empty."
        return
    fi
    
    while true
    do
        read -p "Enter Table Name: " tableName
        validateParamName $tableName
        if [ $? -eq 0 ]
        then
            break
        fi
    done
    
    if [ ! -d "$tableName" ]
    then
        echo "Table Doesn't Exist"
        return
    fi
    
    if [ ! -s "${tableName}/${tableName}.txt" ]
    then
        echo "The $tableName table is empty."
        return
    fi
    
    
    read -p "Enter the primary key (PK) of the record to delete: " pk
    
    if [ ! -z "$(grep "^${pk}" "${tableName}/${tableName}.txt")" ]
    then
        sed -i "/^${pk}/d" "${tableName}/${tableName}.txt"
        echo "The record with PK = '${pk}' has been deleted successfully."
    else
        echo "Error: A record with PK = '${pk}' was not found."
    fi
    
}

# Feature 1: Enhanced SELECT with WHERE clause
function selectTable {
    
    typeset tableName colsNum whereCol whereVal choice displayAll
    typeset selectedCol="*"
    
    if [ -z "$(ls)" ]
    then
        echo "No Tables To Select From, Database Is Empty."
        return
    fi
    
    while true
    do
        read -p "Enter Table Name: " tableName
        validateParamName $tableName
        if [ $? -eq 0 ]
        then
            break
        fi
    done
    
    if [ ! -d "$tableName" ]
    then
        echo "Table Doesn't Exist"
        return
    fi
    
    if [ ! -s "${tableName}/${tableName}.txt" ]
    then
        echo "The $tableName table is empty."
        return
    fi
    
    # Feature 1: Ask if user wants to filter
    read -p "Do you want to filter results with a WHERE clause? (y/n): " choice
    if [[ $choice == "y" || $choice == "Y" ]]
    then
        displayAll=false
        # Get the column names for the user to choose from
        typeset colNamesLine=$(sed -n '2p' ${tableName}/${tableName}-meta.txt)
        typeset colNames=($(echo $colNamesLine | tr ':' ' '))
        echo "Available columns: ${colNames[@]}"
        
        read -p "Enter the column name to filter by: " whereCol
        # Check if the entered column exists
        if [[ ! " ${colNames[@]} " =~ " ${whereCol} " ]]
        then
            echo "Error: Column '$whereCol' does not exist in this table."
            return 1
        fi
        # Find the column number for the filter
        whereColNum=0
        for i in "${!colNames[@]}"; do
            if [[ "${colNames[$i]}" = "${whereCol}" ]]; then
                whereColNum=$((i+1))
                break
            fi
        done
        if [ $whereColNum -eq 0 ]; then
            echo "Error finding column."
            return 1
        fi
        read -p "Enter the value to filter for (WHERE $whereCol = ?): " whereVal
    else
        displayAll=true
    fi
    
    # Print the header (column names)
    sed -n '2p' ${tableName}/${tableName}-meta.txt | sed 's/:/\t/g'
    echo "------------------------------------------------"
    
    # Print the data, with or without filter
    if [ "$displayAll" = true ]
    then
        # Show all data
        sed 's/:/\t/g'  ${tableName}/${tableName}.txt
    else
        # Feature 1: Use awk to filter based on the chosen column and value
        awk -F: -v col="$whereColNum" -v val="$whereVal" '$col == val' ${tableName}/${tableName}.txt | sed 's/:/\t/g'
        if [ $? -ne 0 ]; then
            echo "No records found where $whereCol = $whereVal."
        fi
    fi
    echo
}

function updateTable {
    typeset tableName pk colName oldValue newValue colnum recordLine
    typeset constraints=$(tail -1 ${tableName}/${tableName}-meta.txt 2>/dev/null) # Get constraints for Feature 2
    
    if [ -z "$(ls)" ]
    then
        echo "No Tables To Update, Database Is Empty."
        return
    fi
    
    while true
    do
        read -p "Enter Table Name: " tableName
        validateParamName $tableName
        if [ $? -eq 0 ]
        then
            break
        fi
    done
    
    if [ ! -d "$tableName" ]
    then
        echo "${tableName} Doesn't Exist"
        return
    fi
    
    if [ ! -s "${tableName}/${tableName}.txt" ]
    then
        echo "The $tableName table is empty."
        return
    fi
    
    read -p "Enter the primary key (PK) of the record to update: " pk
    
    recordLine=$(grep "^${pk}" "${tableName}/${tableName}.txt")
    if [ -z "$recordLine" ]
    then
        echo "Error: A record with PK = '${pk}' was not found."
        return
    fi
    
    # Show the current record
    echo "Current Record: $recordLine"
    sed -n '2p' ${tableName}/${tableName}-meta.txt | sed 's/:/\t/g'
    echo $recordLine | sed 's/:/\t/g'
    echo "------------------------------------------------"
    
    # Get the column names
    typeset colNamesLine=$(sed -n '2p' ${tableName}/${tableName}-meta.txt)
    typeset colNames=($(echo $colNamesLine | tr ':' ' '))
    echo "Available columns: ${colNames[@]}"
    
    read -p "Enter the column name to update: " colName
    
    # Check if column exists and find its number
    colnum=0
    for i in "${!colNames[@]}"; do
        if [[ "${colNames[$i]}" = "${colName}" ]]; then
            colnum=$((i+1))
            break
        fi
    done
    if [ $colnum -eq 0 ]; then
        echo "Error: Column '$colName' does not exist."
        return 1
    fi
    # Don't allow updating the PK (column 1)
    if [ $colnum -eq 1 ]; then
        echo "Error: Cannot update the Primary Key column. Please delete and re-insert the record instead."
        return 1
    fi
    
    oldValue=$(echo $recordLine | cut -d ':' -f $colnum)
    read -p "Enter New Value for '$colName' (current: $oldValue): " newValue
    
    # Feature 2: Check UNIQUE constraint for the target column if it exists
    typeset colConstraint=$(echo $constraints | cut -d ':' -f $colnum)
    if [[ $colConstraint == "unique" ]]
    then
        # Check if the new value already exists in this column (excluding the current record being updated)
        # awk: Check if any record's colnum equals newValue, and that the first field (PK) is not the current pk
        if [ ! -z "$(awk -F: -v col=$colnum -v newval="$newValue" -v pk="$pk" '$col == newval && $1 != pk' ${tableName}/${tableName}.txt)" ]
        then
            echo "Error: Value must be UNIQUE for column '$colName'. '$newValue' already exists in another record."
            return 1
        fi
    fi
    
    # Validate data type before updating
    typeset colDatatype=$(sed -n '1p' ${tableName}/${tableName}-meta.txt | cut -d ':' -f $colnum)
    validateDataType "$newValue" "$colDatatype"
    if [ $? -ne 0 ]; then
        echo "Update cancelled due to data type error."
        return 1
    fi
    
    # Use awk to safely replace the specific field in the specific record
    # This is more robust than simple sed as it handles special characters better
    awk -F: -v OFS=':' -v pk="$pk" -v colnum="$colnum" -v newval="$newValue" '
        $1 == pk {$colnum = newval}1
    ' "${tableName}/${tableName}.txt" > "${tableName}/${tableName}.txt.tmp" && mv "${tableName}/${tableName}.txt.tmp" "${tableName}/${tableName}.txt"
    
    echo "Record updated successfully."
}

function showTablesMenu {
    PS3="(Table Menu) Select Option: "
    select choice2 in "Create Table" "List Tables" "Drop Table" "Insert into Table" "Select from Table" "Delete from Table" "Update Table" "Back to Main Menu"
    do
        case $choice2 in
            "Create Table") createTable
            ;;
            "List Tables") listTables
            ;;
            "Drop Table") dropTable
            ;;
            "Insert into Table") insertTable
            ;;
            "Select from Table") selectTable
            ;;
            "Delete from Table") deleteRecord
            ;;
            "Update Table") updateTable
            ;;
            "Back to Main Menu")
                cd ../..
                echo "Disconnected from database."
                break
            ;;
            *) echo "$REPLY is not a valid option"
            ;;
        esac
        echo
    done
}

#----------------------- End Fuctions Area-----------------------------------------

#----------------------- Start Script Main body------------------------------------
# Create the main databases directory if it doesn't exist
mkdir -p databases

echo "Welcome to Bash Script Lite DBMS!"
PS3="(Main Menu) Select Option: "

select choice in "Create Database" "List Databases" "Connect to Database" "Drop Database" "Exit"
do
    case $choice in
        "Create Database") createDb
        ;;
        "List Databases") listDbs
        ;;
        "Connect to Database") connectDb
        ;;
        "Drop Database") DropDb
        ;;
        "Exit")
            echo "Goodbye!"
            exit 0
        ;;
        *) echo "$REPLY is not a valid option"
        ;;
    esac
    echo
done
#----------------------- End Script Main body------------------------------------
