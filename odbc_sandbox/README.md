# README

## Open Database Connectivity Driver with SQL

## What is OBBC?
An ODBC driver uses the Open Database Connectivity (ODBC) interface by Microsoft that allows applications to access data in database management systems (DBMS) using SQL as a standard for accessing the data.

An ODBC driver uses the Open Database Connectivity (ODBC) interface by Microsoft that allows applications to access data in database management systems (DBMS) using SQL as a standard for accessing the data. ODBC permits maximum interoperability, which means a single application can access different DBMS. Application end users can then add ODBC database drivers to link the application to their choice of DBMS.

## How to make a connection to a database in OBDC
### Step 1
* You need the ODBC driver installed for SQLite3 for this workflow as the SQL file is packaged in SQLite. You can download it at the link below. The x64 version worked for myself, Nick and others. You may find this driver helpful (or necessary) to repeat the same process with Python as it’s tied to how DOE coded the E+ results file. As a point of order, this driver has not been officially endorsed, vetted or approved by IT so download at your own risk. http://www.ch-werner.de/sqliteodbc/

* Once the driver is installed, from Excel you simply go to ‘Get Data’ under the ‘Data’ tab, select ‘From Other Sources’, then ‘From ODBC’ to start the import wizard. This process is nearly identical in PowerBI.

* You will want to select the database file type for the SQL file, SQLite3 Datasource, and then add the connection string below. In the example file, I simply edit this connection string to point to the sources table in excel to skip this step. For optimization purposes, the SQL statement can be expanded upon directly or in PowerQuery to point to specific tables or values.

  * `connection string` ==> `database=C:\Users\point\to\your\eplus\sql\file.sql`

* Windows security will prompt you to log-in, this is a Microsoft security check. No credentials are required so you can just go to default and hit connect or use your current windows credentials for tracking. I am fairly certain this step can be automated in PowerQuery but any tools we are developing will eventually want some level of authentication. By default this pops up every time you connect to a new database.

* I recommend starting with the HTML reports or hourly reports which are written to these two tables:
  * `TabularDataWithStings`
  * `ReportVariableWithTime`

* MS Excel Pivot Tables then work really well with this workflow
  * 'Create Pivot Table' command
  * 'Use an External Datasource' bubble option
  * 

