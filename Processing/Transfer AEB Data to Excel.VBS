' ----------------------------------------------------------------------------------------
' Name         : ---
' Copyright(c) : National Instruments Ireland Resources Limited
' Author       : 
' Comment      : Create Excel Summary Sheet                                                  
' ----------------------------------------------------------------------------------------

Option Explicit


' Initialize script.
' Suppress display of the command that is currently executing.
AutoEcho = "No"

' ----------------------------------------------------------------------------------------
' MAIN SECTION
' ----------------------------------------------------------------------------------------
' Set constants.
Const DiademExcelWorkbook = "AEB Summary.xlsm"
Const xlMaximized =&HFFFFEFD7
Dim TESTID 
Dim Diadem_network_location, Test_Type
dim objExcel, objWorkbook 

Diadem_network_location = CurrentScriptPath
Test_Type = "AEB"

TESTID = Data.Root.Properties("TestIDDialog").Value

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


If Data.Root.Properties.Exists("Speed_Reduction_10kph") then
  ExcelSheet.Cells(5,3).Value = Data.Root.Properties("Speed_Reduction_10kph").Value
  ExcelSheet.Cells(5,4).Value = Data.Root.Properties("Valid_10kph_Tests").Value
Else
  ExcelSheet.Cells(5,3).Value = "N/A"
  ExcelSheet.Cells(5,4).Value = "N/A"
End if

If Data.Root.Properties.Exists("Speed_Reduction_15kph") then
  ExcelSheet.Cells(6,3).Value = Data.Root.Properties("Speed_Reduction_15kph").Value
  ExcelSheet.Cells(6,4).Value = Data.Root.Properties("Valid_15kph_Tests").Value
Else
  ExcelSheet.Cells(6,3).Value = "N/A"
  ExcelSheet.Cells(6,4).Value = "N/A"
End if

If Data.Root.Properties.Exists("Speed_Reduction_20kph") then
  ExcelSheet.Cells(7,3).Value = Data.Root.Properties("Speed_Reduction_20kph").Value
  ExcelSheet.Cells(7,4).Value = Data.Root.Properties("Valid_20kph_Tests").Value
Else
  ExcelSheet.Cells(7,3).Value = "N/A"
  ExcelSheet.Cells(7,4).Value = "N/A"
End if

If Data.Root.Properties.Exists("Speed_Reduction_25kph") then
  ExcelSheet.Cells(8,3).Value = Data.Root.Properties("Speed_Reduction_25kph").Value
  ExcelSheet.Cells(8,4).Value = Data.Root.Properties("Valid_25kph_Tests").Value
Else
  ExcelSheet.Cells(8,3).Value = "N/A"
  ExcelSheet.Cells(8,4).Value = "N/A"
End if

If Data.Root.Properties.Exists("Speed_Reduction_30kph") then
  ExcelSheet.Cells(9,3).Value = Data.Root.Properties("Speed_Reduction_30kph").Value
  ExcelSheet.Cells(9,4).Value = Data.Root.Properties("Valid_30kph_Tests").Value
Else
  ExcelSheet.Cells(9,3).Value = "N/A"
  ExcelSheet.Cells(9,4).Value = "N/A"
End if

If Data.Root.Properties.Exists("Speed_Reduction_35kph") then
  ExcelSheet.Cells(10,3).Value = Data.Root.Properties("Speed_Reduction_35kph").Value
  ExcelSheet.Cells(10,4).Value = Data.Root.Properties("Valid_35kph_Tests").Value
Else
  ExcelSheet.Cells(10,3).Value = "N/A"
  ExcelSheet.Cells(10,4).Value = "N/A"
End if

If Data.Root.Properties.Exists("Speed_Reduction_40kph") then
  ExcelSheet.Cells(11,3).Value = Data.Root.Properties("Speed_Reduction_40kph").Value
  ExcelSheet.Cells(11,4).Value = Data.Root.Properties("Valid_40kph_Tests").Value
Else
  ExcelSheet.Cells(11,3).Value = "N/A"
  ExcelSheet.Cells(11,4).Value = "N/A"
End if

If Data.Root.Properties.Exists("Speed_Reduction_45kph") then
  ExcelSheet.Cells(12,3).Value = Data.Root.Properties("Speed_Reduction_45kph").Value
  ExcelSheet.Cells(12,4).Value = Data.Root.Properties("Valid_45kph_Tests").Value
Else
  ExcelSheet.Cells(12,3).Value = "N/A"
  ExcelSheet.Cells(12,4).Value = "N/A"
End if

If Data.Root.Properties.Exists("Speed_Reduction_50kph") then
  ExcelSheet.Cells(13,3).Value = Data.Root.Properties("Speed_Reduction_50kph").Value
  ExcelSheet.Cells(13,4).Value = Data.Root.Properties("Valid_50kph_Tests").Value
Else
  ExcelSheet.Cells(13,3).Value = "N/A"
  ExcelSheet.Cells(13,4).Value = "N/A"
End if

If Data.Root.Properties.Exists("StartTime") then
  ExcelSheet.Cells(4,7).Value = Data.Root.Properties("StartTime").Value
  ExcelSheet.Cells(5,7).Value = Data.Root.Properties("EndTime").Value
Else
  ExcelSheet.Cells(4,7).Value = "N/A"
  ExcelSheet.Cells(5,7).Value = "N/A"
End if

If data.Root.Properties.Exists("Min_Temp") then 
  ExcelSheet.Cells(9,7).Value = Data.Root.Properties("Min_Temp").Value
  ExcelSheet.Cells(9,8).Value = Data.Root.Properties("Min_Temp_Time").Value
Else
  ExcelSheet.Cells(9,7).Value = "N/A"
  ExcelSheet.Cells(9,8).Value = "N/A"
End if

If Data.Root.Properties.Exists("Max_Temp") then
  ExcelSheet.Cells(9,9).Value = Data.Root.Properties("Max_Temp").Value
  ExcelSheet.Cells(9,10).Value = Data.Root.Properties("Max_Temp_Time").Value
Else
  ExcelSheet.Cells(9,9).Value = "N/A"
  ExcelSheet.Cells(9,10).Value = "N/A"
End if

If data.Root.Properties.Exists("Min_Light") then
  ExcelSheet.Cells(10,7).Value = Data.Root.Properties("Min_Light").Value
  ExcelSheet.Cells(10,8).Value = Data.Root.Properties("Min_Light_Time").Value
Else
  ExcelSheet.Cells(10,7).Value = "N/A"
  ExcelSheet.Cells(10,8).Value = "N/A"
End if

If Data.Root.Properties.Exists("Max_Light") then
  ExcelSheet.Cells(10,9).Value = Data.Root.Properties("Max_Light").Value
  ExcelSheet.Cells(10,10).Value = Data.Root.Properties("Max_Light_Time").Value
Else
  ExcelSheet.Cells(10,9).Value = "N/A"
  ExcelSheet.Cells(10,10).Value = "N/A"
End if

If Data.Root.Properties.Exists("Min_Wind") then
  ExcelSheet.Cells(11,7).Value = Data.Root.Properties("Min_Wind").Value
  ExcelSheet.Cells(11,8).Value = Data.Root.Properties("Min_Wind_Time").Value
Else
  ExcelSheet.Cells(11,7).Value = "N/A"
  ExcelSheet.Cells(11,8).Value = "N/A"
End If

If Data.Root.Properties.Exists("Max_Wind") then
  ExcelSheet.Cells(11,9).Value = Data.Root.Properties("Max_Wind").Value
  ExcelSheet.Cells(11,10).Value = Data.Root.Properties("Max_Wind_Time").Value
Else
  ExcelSheet.Cells(11,9).Value = "N/A"
  ExcelSheet.Cells(11,10).Value = "N/A"
End if


Dim i,j,Row
Row = 17
msgbox(groupcount)
For i = 2 to groupcount - 2 step 2
  If Left(Data.Root.ChannelGroups(i).Name,4) = "Test" then
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
objExcel.Windows("AEB Summary.xlsm").Activate

objExcel.Run ("Move_TDMS_Data")

objExcel.Windows("AEB Summary.xlsm").Activate

objExcel.ActiveWorkbook.SaveAs "\\IIHS\IIHSDrive\VRC\Shared\Crash Avoidance Programs\Autonomous Emergency Braking\" & TESTID & "\DATA\EXCEL\" & TESTID & " Summary.xlsm"

' Set object references to 'Nothing'.
Set objExcel = Nothing

'Call script to create excel spreadsheet with only 20 and 40 km/h tests
Call Scriptinclude(CurrentScriptPath & "rating tests.vbs")

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


