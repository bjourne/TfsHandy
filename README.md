TfsHandy
========

A collection of Powershell scripts for interacting with TFS from the
command line. They mostly add colorization and some prettifying to the
data.

Commands
========
Command with its alias in paranthesis explained below:

Show-TfsDiff (mydf)
---------------------
Unified diff of all workspace changes.
   
Show-TfsHistory (myhi)
----------------------
Show the last N (default 30) checkins:

    myhi -path "path/to/it" -limit 60
    
Show-TfsChangeset (mycs)
------------------------
Show details about a specific checkin. If verbose, then all diffs
contained in that checkin is listed.
