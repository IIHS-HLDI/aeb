'-------------------------------------------------------------------------------
'-- VBS script file
'-- Created on 05/20/2013 09:28:23
'-- Author: 
'-- Comment: 
'-------------------------------------------------------------------------------
Option Explicit  'Forces the explicit declaration of all the variables in a script.

  Dim Folder
  Dim filesys

  Sub BRAKETESTGPS (TestVehicle, TestSpeed, TestNumber, TestID)

    'Dim TestSpeed, TestNumber, TestID, TestVehicle

    'TestSpeed = "72"
    'TestNumber = "003"
    'TestID = "AEB1399"
    'TestVehicle = "2010 Volvo XC60"

    Folder ="C:\"

    Set filesys=CreateObject("Scripting.FileSystemObject")
    If filesys.FileExists(Folder & TestID & "\RT\" & TestID & " Brake Test-" & TestNumber & ".csv" ) Then
        Call Data.Root.ChannelGroups.Add(TestSpeed & TestNumber & " Raw Data", groupcount + 1).Activate()
        Call DataFileLoadSel(Folder & TestID & "\RT\" & TestID & " Brake Test-" & TestNumber & ".csv","CSV","[1]/[1,2,3,9,10,14,15,16,23,24,25,26,27,28,66,67,68,73,74,75]","") '... 47DataFilename,FileImportFilter,ImportSelection,ImportAction 
    Else
        msgbox(TestID & " Brake Test-" & TestNumber & ".csv" & " does not exist.")
    End If

    'code for running from the network
    'Folder ="N:\VRC\Shared\Crash Avoidance Programs\Autonomous Emergency Braking\" & TESTID & "\DATA\RT"
    'Set filesys=CreateObject("Scripting.FileSystemObject")
    'If filesys.FileExists(Folder & "\" & TestID & " Brake Test-" & TestNumber & ".csv" ) Then
    '    Call Data.Root.ChannelGroups.Add(TestSpeed & TestNumber & " Raw Data", groupcount + 1).Activate()
    '    Call DataFileLoadSel(Folder & "\" & TestID & " Brake Test-" & TestNumber & ".csv","CSV","[1]/[1,2,3,9,10,14,15,16,23,24,25,26,27,28,66,67,68,73,74,75]","") '... 47DataFilename,FileImportFilter,ImportSelection,ImportAction 
    ' Else
    '    msgbox(TestID & " Brake Test-" & TestNumber & ".csv" & " does not exist.")
    ' End If


    'Change filename
    Data.Root.Name = TestID & " - " & TestVehicle & " Brake Tests"

    'Create units for each channel
    Data.Root.ActiveChannelGroup.Channels("TimeFromStart (s)").Properties("unit_string").Value = "s"
    Data.Root.ActiveChannelGroup.Channels("PosLocalX (m)").Properties("unit_string").Value = "m"
    Data.Root.ActiveChannelGroup.Channels("PosLocalY (m)").Properties("unit_string").Value = "m"
    Data.Root.ActiveChannelGroup.Channels("VelDown (km\h)").Properties("unit_string").Value = "km/h"
    Data.Root.ActiveChannelGroup.Channels("VelForward (km\h)").Properties("unit_string").Value = "km/h"
    Data.Root.ActiveChannelGroup.Channels("VelLateral (km\h)").Properties("unit_string").Value = "km/h"
    Data.Root.ActiveChannelGroup.Channels("AccelForward (m\s²)").Properties("unit_string").Value = "m/s^2"
    Data.Root.ActiveChannelGroup.Channels("AccelLateral (m\s²)").Properties("unit_string").Value = "m/s^2"
    Data.Root.ActiveChannelGroup.Channels("AccelDown (m\s²)").Properties("unit_string").Value = "m/s^2"
    Data.Root.ActiveChannelGroup.Channels("AngleHeading (deg)").Properties("unit_string").Value = "°"
    Data.Root.ActiveChannelGroup.Channels("AnglePitch (deg)").Properties("unit_string").Value = "°"
    Data.Root.ActiveChannelGroup.Channels("AngleRoll (deg)").Properties("unit_string").Value = "°"
    Data.Root.ActiveChannelGroup.Channels("AngleRateForward (deg\s)").Properties("unit_string").Value = "°/s"
    Data.Root.ActiveChannelGroup.Channels("AngleRateLateral (deg\s)").Properties("unit_string").Value = "°/s"
    Data.Root.ActiveChannelGroup.Channels("AngleRateDown (deg\s)").Properties("unit_string").Value = "°/s"
    Data.Root.ActiveChannelGroup.Channels("AngAccelForward (deg\s²)").Properties("unit_string").Value = "°/s^2"
    Data.Root.ActiveChannelGroup.Channels("AngAccelLateral (deg\s²)").Properties("unit_string").Value = "°/s^2"
    Data.Root.ActiveChannelGroup.Channels("AngAccelDown (deg\s²)").Properties("unit_string").Value = "°/s^2"

    'Change name of channel group 1
    Data.Root.ActiveChannelGroup.Name = "Test-" & TestNumber & " " & TestSpeed & " kph Brake Test Raw Data"

    'Change numeric channels to waveform
    Call ChnToWfChn("/TimeFromStart (s)","'/PosLocalX (m)' - '/AngAccelDown (deg\s²)'",0) '... X,ChnNoStr,XChnDelete 

    'Create copies of relevent channels
    Call ChnClpCopy("'/AccelForward (m\s²)'") '... ClpSource 
    Call ChnClpPaste()

    'Add Channel group for Filtered Data
    Call Data.Root.ChannelGroups.Add("Test-" & TestNumber & " " & TestSpeed & " kph Brake Test Processed Data", groupcount + 1).Activate()

    'Move relevent channels and change names
    Call Data.Move(Data.Root.ChannelGroups(groupcount-1).Channels("AccelForward (m\s²)1"),Data.Root.ActiveChannelGroup.Channels,1)

    'Rename Acceleration channel and convert to gs
    Data.Root.ActiveChannelGroup.Channels("AccelForward (m\s²)1").Properties("name").Value = "Longitudinal Acceleration"
    Call ChnUnitConvert("/Longitudinal Acceleration","Longitudinal Acceleration","gn") '... Y,E,TargetUnit 

    'Filter Acceleration
    Call ChnFiltCalc("","/Longitudinal Acceleration","/Longitudinal Acceleration","IIR","Butterworth","Low pass",12,6,0,0,1.2,25,"Hamming",1,0) '... XW,Y,E,FiltStruc,FiltStyle,FiltType,FiltDegree,FiltLimit,FiltLowLimit,FiltUppLimit,FiltWave,FiltSamples,FiltWndFct,FiltZeroPhase,FiltCorrection 

    'Find Maximum Deceleration and save as custom property
    Dim MaxDecel

    MaxDecel = round(-1 * Data.Root.ActiveChannelGroup.Channels("Longitudinal Acceleration").Properties("minimum").Value, 2)
    Call Data.Root.ActiveChannelGroup.Properties.Add("Max Decel", MaxDecel, DataTypeFloat64)

    'Calculate average decel
    If Data.Root.ActiveChannelGroup.Name = "Test-001 56 kph Brake Test Processed Data" then
      Call Data.Root.Properties.Add("Valid_56kph_Brake_Tests", 0, DataTypeFloat64)
      Call Data.Root.Properties.Add("Total_56_Decel", 0, DataTypeFloat64)
      Call Data.Root.Properties.Add("Average_56_Decel", 0, DataTypeFloat64)
      Call Data.Root.Properties.Add("Valid_72kph_Brake_Tests", 0, DataTypeFloat64)
      Call Data.Root.Properties.Add("Total_72_Decel", 0, DataTypeFloat64)
      Call Data.Root.Properties.Add("Average_72_Decel", 0, DataTypeFloat64)
    Else
    End if

    Data.Root.Properties("Valid_" & TestSpeed & "kph_Brake_Tests").Value = Data.Root.Properties("Valid_" & TestSpeed & "kph_Brake_Tests").Value + 1
    Data.Root.Properties("Total_" & TestSpeed & "_Decel").Value = Data.Root.Properties("Total_" & TestSpeed & "_Decel").Value + MaxDecel
    Data.Root.Properties("Average_" & TestSpeed & "_Decel").Value = Data.Root.Properties("Total_" & TestSpeed & "_Decel").Value/Data.Root.Properties("Valid_" & TestSpeed & "kph_Brake_Tests").Value

    'report test decel and average decel
    msgbox(TestSpeed & " km/h Test Count: " & Data.Root.Properties("Valid_" & TestSpeed & "kph_Brake_Tests").Value & vbcrlf & "Test " & Data.Root.Properties("Valid_" & TestSpeed & "kph_Brake_Tests").Value & " Max Decel: " & MaxDecel & vbcrlf & "Average " & TestSpeed & " km/h Max. Decel.: " & Data.Root.Properties("Average_" & TestSpeed & "_Decel").Value)

    'Save File
    Call DataFileSave(Folder & TestID & "\DIAdem\" & TESTID & " - " & TestVehicle & " Brake Tests.tdms","TDMS") '... DataFilename,FileExportFilter 
    'Call DataFileSave("N:\VRC\Shared\Crash Avoidance Programs\Autonomous Emergency Braking\" & TESTID & "\DATA\DIAdem\" & TESTID & " - " & TestVehicle & " Brake Tests.tdms","TDMS") '... DataFilename,FileExportFilter 

    'Collapse data portal
    Call UIAutoRefreshSet(True) 
    Call Portal.Structure.Collapse(Data.Root) 
    Call UIAutoRefreshSet(False)

  End Sub

'Collapse data portal
Call UIAutoRefreshSet(True) 
Call Portal.Structure.Collapse(Data.Root) 
Call UIAutoRefreshSet(False)