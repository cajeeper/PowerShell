# Office365 Usage Reporting

I wrote this script to send out longer than just a few days worth of email usage for our Office365 users.

The script:
	1) Gathers user inbound / outbound emails from Office365
	2) Upload the statistics to a local database
	3) Email out the email administrators the top users outbound for the last few days and the last 30 day total trend of usage inbound and outbound.
	

I have it run daily from one of our job servers and the database server is a local SQL.

Steps to installs:
	1) Run sql_create_db.sql against a local SQL database to facilitate gathering of results.
	2) Create a Office365 account that has permissions to run statistics and PowerShell
	3) Set the run.ps1 to launch daily. We have ours set to 5:00 am and generally finishes by 6:00 am for 200k users.
	
Best of luck!
-Justin
