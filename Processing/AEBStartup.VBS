'-------------------------------------------------------------------------------
'-- VBS script file
'-- Created on 05/28/2013 09:47:52
'-- Author: 
'-- Comment: 
'-------------------------------------------------------------------------------
Option Explicit  'Forces the explicit declaration of all the variables in a script.
Call SUDDefLoad(CurrentScriptPath & "CrashAvoidanceDialog.sud")
Call SUDDlgShow("AEBStartup")