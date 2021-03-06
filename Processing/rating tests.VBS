'-------------------------------------------------------------------------------
'-- VBS script file
'-- Created on 05/27/2014 10:08:48
'-- Author: 
'-- Comment: 
'-------------------------------------------------------------------------------
Option Explicit  'Forces the explicit declaration of all the variables in a script.

'delete channel groups that are not for ratings
Dim k,channel,TestID,TestVehicle

TestID = Data.Root.Properties("TestIDDialog").Value
TestVehicle = Data.Root.Properties("VehicleInfoDialog").Value

For k = 1 to groupcount
If Left(channel,2) = "We"  or Left(channel,2) = "AE" then
Exit For
Else
channel = Data.Root.ChannelGroups(k).Properties("name").Value
  If Mid(channel,10,2) = "20" or Mid(channel,10,2) = "40" or Mid(channel,10,2) = "We" then
    Else
    Call Data.Root.ChannelGroups.Remove(k)
    k=k-1
  End if
End IF  
Next    

'Save File
Call DataFileSave("\\IIHS\IIHSDrive\VRC\Shared\Crash Avoidance Programs\Autonomous Emergency Braking\" & TestID & "\Data\DIAdem\" & TestID & " - " & TestVehicle & " AEB rating tests.tdms","TDMS") '... DataFilename,FileExportFilter 

'delelte channel properties that are not for ratings
If Data.Root.Properties.Exists("Speed_Reduction_10kph") then
  Data.Root.Properties.Remove("Speed_Reduction_10kph")
  Data.Root.Properties.Remove("TotalSpeed10")
  Data.Root.Properties.Remove("Valid_10kph_Tests")
End If

If Data.Root.Properties.Exists("Speed_Reduction_15kph") then
  Data.Root.Properties.Remove("Speed_Reduction_15kph")
  Data.Root.Properties.Remove("TotalSpeed15")
  Data.Root.Properties.Remove("Valid_15kph_Tests")
End If

If Data.Root.Properties.Exists("Speed_Reduction_25kph") then
  Data.Root.Properties.Remove("Speed_Reduction_25kph")
  Data.Root.Properties.Remove("TotalSpeed25")
  Data.Root.Properties.Remove("Valid_25kph_Tests")
End If

If Data.Root.Properties.Exists("Speed_Reduction_30kph") then
  Data.Root.Properties.Remove("Speed_Reduction_30kph")
  Data.Root.Properties.Remove("TotalSpeed30")
  Data.Root.Properties.Remove("Valid_30kph_Tests")
End If

If Data.Root.Properties.Exists("Speed_Reduction_35kph") then
  Data.Root.Properties.Remove("Speed_Reduction_35kph")
  Data.Root.Properties.Remove("TotalSpeed35")
  Data.Root.Properties.Remove("Valid_35kph_Tests")
End If

If Data.Root.Properties.Exists("Speed_Reduction_45kph") then
  Data.Root.Properties.Remove("Speed_Reduction_45kph")
  Data.Root.Properties.Remove("TotalSpeed45")
  Data.Root.Properties.Remove("Valid_45kph_Tests")
End If

If Data.Root.Properties.Exists("Speed_Reduction_50kph") then
  Data.Root.Properties.Remove("Speed_Reduction_50kph")
  Data.Root.Properties.Remove("TotalSpeed50")
  Data.Root.Properties.Remove("Valid_50kph_Tests")
End If

' Initialize script.
' Suppress display of the command that is currently executing.
AutoEcho = "No"

' ----------------------------------------------------------------------------------------
' MAIN SECTION
' ----------------------------------------------------------------------------------------
' Set constants.
Const DiademExcelWorkbook = "AEB Rating Summary.xlsm"
Const xlMaximized =&HFFFFEFD7
Dim Test_Type
dim objExcel, objWorkbook 

Test_Type = "AEB"

' Define global variables.
Dim Excel           ' Object variable for Excel
Dim ExcelSheet      ' Object variable for Excel worksheet

' Open Excel files  
Set objExcel = CreateObject("Excel.Application") 
Set objWorkbook = objExcel.Workbooks.Open(CurrentScriptPath & DiademExcelWorkbook) 

' Minimize DIAdem window.
Call WndShow("SHELL", "MINIMIZE")

' Maximize Excel window. 
objExcel.WindowState = xlMaximized 
objExcel.Visible = True 

'Open Summary Sheet
Set ExcelSheet = objExcel.Workbooks(DiademExcelWorkbook).Sheets("Summary")
ExcelSheet.Name = TESTID + " SUMMARY"
  
'Enter values on the Summary tab
ExcelSheet.Cells(1,1).Value = Data.Root.Properties("TestIDDialog").Value
ExcelSheet.Cells(1,2).Value = Data.Root.Properties("VehicleInfoDialog").Value

If Data.Root.Properties.Exists("Speed_Reduction_20kph") then
ExcelSheet.Cells(5,3).Value = Data.Root.Properties("Speed_Reduction_20kph").Value
ExcelSheet.Cells(5,4).Value = Data.Root.Properties("Valid_20kph_Tests").Value
Else
ExcelSheet.Cells(5,3).Value = "N/A"
ExcelSheet.Cells(5,4).Value = "N/A"
End if

If Data.Root.Properties.Exists("Speed_Reduction_40kph") then
ExcelSheet.Cells(6,3).Value = Data.Root.Properties("Speed_Reduction_40kph").Value
ExcelSheet.Cells(6,4).Value = Data.Root.Properties("Valid_40kph_Tests").Value
Else
ExcelSheet.Cells(6,3).Value = "N/A"
ExcelSheet.Cells(6,4).Value = "N/A"
End if

ExcelSheet.Cells(4,7).Value = Data.Root.Properties("StartTime").Value
ExcelSheet.Cells(5,7).Value = Data.Root.Properties("EndTime").Value
ExcelSheet.Cells(5,11).Value = Data.Root.Properties("Min_Temp").Value
ExcelSheet.Cells(5,12).Value = Data.Root.Properties("Min_Temp_Time").Value
ExcelSheet.Cells(5,13).Value = Data.Root.Properties("Max_Temp").Value
ExcelSheet.Cells(5,14).Value = Data.Root.Properties("Max_Temp_Time").Value
ExcelSheet.Cells(6,11).Value = Data.Root.Properties("Min_Light").Value
ExcelSheet.Cells(6,12).Value = Data.Root.Properties("Min_Light_Time").Value
ExcelSheet.Cells(6,13).Value = Data.Root.Properties("Max_Light").Value
ExcelSheet.Cells(6,14).Value = Data.Root.Properties("Max_Light_Time").Value
ExcelSheet.Cells(7,11).Value = Data.Root.Properties("Min_Wind").Value
ExcelSheet.Cells(7,12).Value = Data.Root.Properties("Min_Wind_Time").Value
ExcelSheet.Cells(7,13).Value = Data.Root.Properties("Max_Wind").Value
ExcelSheet.Cells(7,14).Value = Data.Root.Properties("Max_Wind_Time").Value

Dim i,j,Row
Row = 12
For i = 2 to groupcount step 2
  If Data.Root.ChannelGroups(i).Properties.Exists("Valid_Test") then
    If Data.Root.ChannelGroups(i).Properties("Valid_Test").Value = "Yes" then
      ExcelSheet.Cells(Row,2).Value = Data.Root.ChannelGroups(i).Properties("Description").Value 
      ExcelSheet.Cells(Row,3).Value = Data.Root.ChannelGroups(i).Properties("Run_Number").Value 
      ExcelSheet.Cells(Row,4).Value = Data.Root.ChannelGroups(i).Properties("Test_Run_Start").Value 
      ExcelSheet.Cells(Row,5).Value = Data.Root.ChannelGroups(i).Properties("Min_Speed").Value 
      ExcelSheet.Cells(Row,6).Value = Data.Root.ChannelGroups(i).Properties("Max_Speed").Value
      ExcelSheet.Cells(Row,7).Value = Data.Root.ChannelGroups(i).Properties("Min_Yaw").Value
      ExcelSheet.Cells(Row,8).Value = Data.Root.ChannelGroups(i).Properties("Max_Yaw").Value
      ExcelSheet.Cells(Row,9).Value = Data.Root.ChannelGroups(i).Properties("Min_Lateral_Offset").Value
      ExcelSheet.Cells(Row,10).Value = Data.Root.ChannelGroups(i).Properties("Max_Lateral_Offset").Value
      If Data.Root.ChannelGroups(i).Properties.Exists("Pedal_Target") then
        ExcelSheet.Cells(Row,11).Value = Data.Root.ChannelGroups(i).Properties("Pedal_Target").Value
        ExcelSheet.Cells(Row,12).Value = Data.Root.ChannelGroups(i).Properties("Min_Pedal_Travel").Value
        ExcelSheet.Cells(Row,13).Value = Data.Root.ChannelGroups(i).Properties("Max_Pedal_Travel").Value
        Else
        ExcelSheet.Cells(Row,11).Value = " "
        ExcelSheet.Cells(Row,12).Value = " "
        ExcelSheet.Cells(Row,13).Value = " "
      End if  
      ExcelSheet.Cells(Row,14).Value = Data.Root.ChannelGroups(i).Properties("FCW_TTC").Value
      ExcelSheet.Cells(Row,15).Value = Data.Root.ChannelGroups(i).Properties("AEB_TTC").Value
      ExcelSheet.Cells(Row,16).Value = Data.Root.ChannelGroups(i).Properties("Max_AEB_Decel").Value
      ExcelSheet.Cells(Row,17).Value = Data.Root.ChannelGroups(i).Properties("Initial_Speed").Value
      ExcelSheet.Cells(Row,18).Value = Data.Root.ChannelGroups(i).Properties("Impact_Speed").Value
      ExcelSheet.Cells(Row,19).Value = Data.Root.ChannelGroups(i).Properties("Speed_Reduction").Value
      Row=Row+1
    Else
    End If
   End IF
Next


Call Run_Excel_TDMS_Addin
objExcel.Windows("AEB Rating Summary.xlsm").Activate

objExcel.Run ("Move_TDMS_Data")

objExcel.Windows("AEB Rating Summary.xlsm").Activate

objExcel.ActiveWorkbook.SaveAs "\\IIHS\IIHSDrive\VRC\Shared\Crash Avoidance Programs\Autonomous Emergency Braking\" & TESTID & "\DATA\EXCEL\" & TESTID & " Rating Summary.xlsm"

' Set object references to 'Nothing'.
Set objExcel = Nothing

' Restore DIAdem window.
'Call WndShow("VIEW", "NORMAL")

'Run Excel TDMS Add-in
Sub Run_Excel_TDMS_Addin()

Dim TdmAddIn, TdmsFilePath, Template_Workbook, TDMS_Workbook,TDMS_Name

'objExcel = CreateObject("Excel.Application")
Template_Workbook = objExcel.ActiveWorkbook.Name

TdmsFilePath = "\\IIHS\IIHSDrive\VRC\Shared\Crash Avoidance Programs\Autonomous Emergency Braking\"

TDMS_NAME = Data.Root.Properties("name").Value


On Error Resume Next

objExcel.Visible = True
If Err.number <> 0 Then Call AutoQuit("Could not contact Excel on this computer")
Set TdmAddIn = objExcel.COMAddIns.Item("ExcelTDM.TdmAddin")
If Err.number <> 0 Then Call AutoQuit("Could not access the TDM Excel Addin" & vbCrLf & vbCrLf & "(TDM Excel Addin version 3.1 or later is required)")
objExcel.Visible = True
Call TdmAddIn.Object.ImportFile(TdmsFilePath & TESTID & "\DATA\DIAdem\" & TDMS_NAME & ".TDMS", True)
If Err.number <> 0 Then Call AutoQuit("Could not load the desired data file" & vbCrLf & vbCrLf & """" & TdmsFilePath & """")
Call objExcel.ActiveWindow.Activate
On Error GoTo 0

End Sub

'---------------------------


