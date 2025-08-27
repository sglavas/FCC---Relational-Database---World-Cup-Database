# World Cup Database
ETL (Extract, Transform, Load) project that imports World Cup match data from a CSV file into a PostgreSQL database.
Originally created for a FreeCodeCamp certification, then refactored with error handling, input sanitization, and Dockerized PostgreSQL for easier setup and experimentation.

## Project Structure

```bash
├── games.csv                # Raw dataset (World Cup matches)
├── insert_data.sh           # ETL script (imports CSV -> PostgreSQL)
├── queries.sh               # Example queries (SQL)
├── README.md                # Documentation
└── worldcup.sql             # Database dump (schema + data)
```

---

## Features
- **Automated Data Import**: Processes CSV files into normalized PostgreSQL tables
- **Error Handling**: Comprehensive error tracking with line numbers and failed commands
- **SQL Injection Protection**: Input sanitization to prevent security vulnerabilities
- **Progress Tracking**: Real-time progress updates during data processing
- **Containerized**: Docker-based PostgreSQL integration

---

## Technologies Used

- **Bash**
- **PostgreSQL**
- **Docker**

---

## Installation & Setup

1. Clone the repo
```bash
git clone https://github.com/sglavas/world-cup-database.git
cd worldcup-database
```
2. Run PostgreSQL with Docker
```bash
docker run --name worldcup-db -e POSTGRES_PASSWORD=postgres123 -d -p 5432:5432 postgres:15
```

3. Create a database
```bash
docker exec worldcup-db psql -U postgres -c "CREATE DATABASE worldcup;"
```

4. Load schema (from included worlcup.sql)
```bash
docker exec -i worldcup-db psql -U postgres -d worldcup < worldcup.sql
```
5. Run the ETL script
```bash
chmod +x insert_data.sh
./insert_data.sh
```

---

## Usage Example

Basic Operation
```bash
./insert_data.sh
```

Expected Output
```text
Truncating tables...
Tables truncated successfully.
Processing 32 games...
[1/32] Processing: France vs Croatia (2018 Final)
[2/32] Processing: Belgium vs England (2018 Third Place)
...
Data import completed successfully! Processed 32 games.
```

Custom CSV File

Place your CSV file in the project root with the same format as games.csv and update the script if needed.

---

## Future Improvements

- Add data validation checks
- Implement incremental loading
- Create Docker Compose setup
- Add JSON export functionality



