library(RSQLite)

db <- dbConnect(dbDriver("SQLite"), dbname = "people.db")

dbListTables(db)
dbListFields(db, "tb_Person")

results <- dbSendQuery(db, "SELECT * FROM tb_Person;")

dbFetch(results, n = 2)               # Retrieve first two rows
dbHasCompleted(results)

dbFetch(results, n = -1)              # Retrieve rest of rows
dbHasCompleted(results)

dbClearResult(results)

dbReadTable(db, "tb_Person")