# 🐧 Bash Script Lite DBMS

A lightweight, file-based Relational Database Management System (RDBMS) implemented purely in **Bash Script**. This project is a great way to understand the core concepts of databases like MySQL or PostgreSQL from the ground up.

## ✨ Features

- **Database Management**: Create, list, connect to, and drop databases.
- **Table Management**: Create, list, and drop tables with custom schemas.
- **Data Types**: Support for `integer` and `string` data types.
- **Constraints**:
  - `PRIMARY KEY`: Uniquely identifies each record (automatically applied to the first column).
  - `UNIQUE`: Ensures all values in a column are different (can be applied to any other column).
- **CRUD Operations**: Full support for Creating, Reading, Updating, and Deleting records.
  - `INSERT`: Add new records with data type and constraint validation.
  - `SELECT`: View all records or filter them using a `WHERE` clause. (`SELECT * FROM table WHERE column=value`).
  - `UPDATE`: Modify existing records while checking constraints.
  - `DELETE`: Remove records by their primary key.
- **User-Friendly Interface**: Interactive menus make it easy to use.

## 🛠️ Tech Stack

- **Bash Script** (Compatible with most Linux/macOS shells)
- Core Unix utilities: `awk`, `sed`, `grep`, `cut`

## 🚀 Getting Started

### Prerequisites

- A Unix-like environment (Linux, macOS, or WSL on Windows).
- Bash Shell (usually pre-installed).
- Git (to clone the repository).

### Installation & Running

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/YOUR_GITHUB_USERNAME/Bash-Script-Lite-DBMS.git
    cd "Bash-Script-Lite-DBMS"
    ```

2.  **Make the script executable:**
    ```bash
    chmod +x script.sh
    ```

3.  **Run the DBMS:**
    ```bash
    ./script.sh
    ```

4.  **Follow the interactive menus:**
    - Start by creating a database.
    - Connect to it.
    - Create tables and manage your data!

## 📖 Usage Example

```bash
# Main Menu
(Main Menu) Select Option:
1) Create Database
2) List Databases
3) Connect to Database
4) Drop Database
5) Exit
# > 1
Enter the Database name: company
Database Created Successfully

# > 3
Enter Database name: company
You are connected to company database

# Table Menu
(Table Menu) Select Option:
1) Create Table
2) List Tables
3) Drop Table
4) Insert into Table
5) Select from Table
6) Delete from Table
7) Update Table
8) Back to Main Menu
# > 1
Enter Table Name: employees
Enter Number Of Columns: 3
(Note: The first column is the Primary Key and must be UNIQUE)
Enter The PK Column Name: id
Choose an option:
1) string
2) integer
# > 2
Enter Column 2 Name: name
Choose an option:
1) string
2) integer
# > 1
Choose a constraint for 'name':
1) none
2) unique
# > 1
Enter Column 3 Name: email
Choose an option:
1) string
2) integer
# > 1
Choose a constraint for 'email':
1) none
2) unique
# > 2 # Make email unique!
Table 'employees' created successfully with schema.

# > 4
Enter Table Name: employees
Enter value of id (integer): 101
Enter value of name (string): John Doe
Enter value of email (string): john.doe@company.com
Record inserted successfully.

# > 5
Enter Table Name: employees
Do you want to filter results with a WHERE clause? (y/n): y
Available columns: id name email
Enter the column name to filter by: name
Enter the value to filter for (WHERE name = ?): John Doe
id      name    email
------------------------------------------------
101     John    john.doe@company.com
