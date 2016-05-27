Name: Samuel Acuña
Date: 24 May 2016

this package interacts with the SQLite database: emg_tbi_database

1. using a txt file of EMG data, use processEMGtrial.m to convert to a matlab-friendly format

2. use addTrialToDatabase.m to make this trial accessible by database for plotting and analysis and such
	- note: the requisite subject and testpoint must already be in the database, add them using addTestPointToDatabase.m and addTbiSubjectToDatabase.m, then you can add a trial to the database

3. use an SQL query with loadSelectTrials.m to bring trials into the workspace for analysis and comparison and plotting

4. plot.m and list.m house many functions to display the data in the workspace, for example, >> tbiStudy.plot.trial(1,1,'baseline')

5. correlation functions found within correlation.m

