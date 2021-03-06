'-------------------------------------------------------------------------------
'-- VBS script file
'-- Created on 03/05/2013 11:07:04
'-- Author: ---
'-- Comment: ---
'-------------------------------------------------------------------------------
Option Explicit  'Forces the explicit declaration of all the variables in a script.

  Dim Folder
  Dim filesys

  'Input values from dialogue box
  Sub AEBGPS (TestVehicle, TestSpeed, TestNumber, TestID)

    Dim testgroups, grp

    If Data.Root.ChannelGroups.Count>0 then
    Set testgroups=data.getchannelgroups("*kph Raw Data")
    For each grp in testgroups
      If grp.properties("Run_Number").value = TestNumber then
        msgbox("File has already been processed.")
        exit sub
      End if 
    Next
    End if

    Folder ="C:\"

    Set filesys=CreateObject("Scripting.FileSystemObject")
    If filesys.FileExists(Folder & TestID & "\RT\" & TestID & "-" & TestNumber & ".csv") Then
        Call Data.Root.ChannelGroups.Add("Test-" & TestNumber & " " & TestSpeed & " kph Raw Data", groupcount + 1).Activate()
        Call DataFileLoadSel(Folder & TestID & "\RT\" & TestID & "-" & TestNumber & ".csv","CSV","[1]/[1,2,3,9,10,14,15,16,23,24,25,26,27,28,66,67,68,73,74,75,108,111,112,113]","") '... 47DataFilename,FileImportFilter,ImportSelection,ImportAction 
    Else
        msgbox(TestID & "-" & TestNumber & ".csv" & " does not exist.")
    End If

    'Change filename
    Data.Root.Name = TestID & " - " & TestVehicle

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
    Data.Root.ActiveChannelGroup.Channels("AngleRateForward (deg\s)").Properties("unit_string").Value = "°/s"
    Data.Root.ActiveChannelGroup.Channels("AngAccelForward (deg\s²)").Properties("unit_string").Value = "°/s^2"
    Data.Root.ActiveChannelGroup.Channels("AngAccelLateral (deg\s²)").Properties("unit_string").Value = "°/s^2"
    Data.Root.ActiveChannelGroup.Channels("AngAccelDown (deg\s²)").Properties("unit_string").Value = "°/s^2"

    'Save TestSpeed as description variable for Raw Data group
    Data.Root.ActiveChannelGroup.Properties("description").Value = TestSpeed
    Call Data.Root.ActiveChannelGroup.Properties.Add("Run Number",TestNumber,DataTypeString) 


    'Change numeric channels to waveform
    Dim i
    For i = 4 to Data.Root.ActiveChannelGroup.Channels.Count
      If data.Root.ActiveChannelGroup.Channels(i).DataType <> DataTypeString Then
        Call ChnToWfChn("/TimeFromStart (s)",Data.Root.ActiveChannelGroup.Channels(i),0) '... X,ChnNoStr,XChnDelete
        Else
        Call Data.Root.ActiveChannelGroup.Channels.Remove(i)
      End If
    Next

    'Find point where valid approach period begins (30m for 20 kph and less, 60m for 25kph and more)
    Dim targetdistance, temp_value, temp_value1, valid_distance_point, valid_distance_time

    If TestSpeed <= 20 then 
      targetdistance = 30
      Else
      targetdistance = 60
    End if

    'Find the point just before the local position reaches 30m for test speeds <=20 and 60m for test speeds >20 
    For i = 1 to Data.Root.ActiveChannelGroup.Channels("PosLocalX (m)").Properties("length").Value
      temp_value = Data.Root.ActiveChannelGroup.Channels("PosLocalX (m)").Values(i)
      temp_value1 = Data.Root.ActiveChannelGroup.Channels("PosLocalX (m)").Values(i+1)

      'If values crosses valid distance
      IF temp_value >= targetdistance THEN  
        IF temp_value1 < targetdistance THEN
          valid_distance_point = i 
          Exit For
        END IF
      END IF

    Next

    'Calculate the time the local position reaches 30m or 60m
    valid_distance_time = ((valid_distance_point - 1) * .01)

    'Create copies of the relevent channels that start from valid distance of 30m or 60m
    Call ChnClpCopy("'/PosLocalX (m)', '/PosLocalY (m)', '/AccelForward (m\s²)', '/AngleRateForward (deg\s)', '/VelForward (km\h)'") '... ClpSource 
    Call ChnClpPaste()

    If Data.Root.ActiveChannelGroup.Channels.Exists("Accelerator_Pedal_Position()") then
      Data.Root.ActiveChannelGroup.Channels("Accelerator_Pedal_Position()").Properties("unit_string").Value = "%"
      Call ChnClpCopy("'/Accelerator_Pedal_Position()'")
      Call ChnClpPaste()
    Else
      msgbox ("Accelerator Pedal Position does not exist")
    End If

    If Data.Root.ActiveChannelGroup.Channels.Exists("Steering_Wheel_Angle()") then
      Data.root.ActiveChannelGroup.Channels("Steering_Wheel_Angle()").Properties("unit_string").Value = "°"
      Call ChnClpCopy("'/Steering_Wheel_Angle()'")
      Call ChnClpPaste()
    Else
      msgbox ("Steering Wheel Angle does not exist")
    End If

    'Add Channel group for Processed Data
    Call Data.Root.ChannelGroups.Add("Test-" & TestNumber & " " & TestSpeed & " kph Processed Data", groupcount + 1).Activate()

    'Save TestSpeed as description variable for Processed Data group
    Data.Root.ActiveChannelGroup.Properties("description").Value = TestSpeed
    Call Data.Root.ActiveChannelGroup.Properties.Add("Run Number",TestNumber,DataTypeString) 

    'Move relevent channels and change names
    Call Data.Move(Data.Root.ChannelGroups(groupcount-1).Channels("PosLocalX (m)1"),Data.Root.ActiveChannelGroup.Channels,1)
    Call Data.Move(Data.Root.ChannelGroups(groupcount-1).Channels("PosLocalY (m)1"),Data.Root.ActiveChannelGroup.Channels,2)
    Call Data.Move(Data.Root.ChannelGroups(groupcount-1).Channels("AccelForward (m\s²)1"),Data.Root.ActiveChannelGroup.Channels,3)
    Call Data.Move(Data.Root.ChannelGroups(groupcount-1).Channels("AngleRateForward (deg\s)1"),Data.Root.ActiveChannelGroup.Channels,4)
    Call Data.Move(Data.Root.ChannelGroups(groupcount-1).Channels("VelForward (km\h)1"),Data.Root.ActiveChannelGroup.Channels,5)

    Data.Root.ActiveChannelGroup.Channels("PosLocalX (m)1").Properties("name").Value = "Longitudinal Position"
    Data.Root.ActiveChannelGroup.Channels("PosLocalY (m)1").Properties("name").Value = "Lateral Position"
    Data.Root.ActiveChannelGroup.Channels("AccelForward (m\s²)1").Properties("name").Value = "Longitudinal Acceleration"
    Data.Root.ActiveChannelGroup.Channels("AngleRateForward (deg\s)1").Properties("name").Value = "Yaw Velocity"
    Data.Root.ActiveChannelGroup.Channels("VelForward (km\h)1").Properties("name").Value = "Speed"

    If Data.Root.ChannelGroups(groupcount-1).Channels.Exists("Accelerator_Pedal_Position()") then
      Call Data.Move(Data.Root.ChannelGroups(groupcount-1).Channels("Accelerator_Pedal_Position()1"),Data.Root.ActiveChannelGroup.Channels,6)
      Data.Root.ActiveChannelGroup.Channels("Accelerator_Pedal_Position()1").Properties("name").Value = "Accelerator Pedal Position"
      Data.Root.ActiveChannelGroup.Channels("Accelerator Pedal Position").Properties("wf_start_offset").Value = -valid_distance_time
    Else
    End If

    If Data.Root.ChannelGroups(groupcount-1).Channels.Exists("Steering_Wheel_Angle()") then
      Call Data.Move(Data.Root.ChannelGroups(groupcount-1).Channels("Steering_Wheel_Angle()1"),Data.Root.ActiveChannelGroup.Channels,7)
      Data.Root.ActiveChannelGroup.Channels("Steering_Wheel_Angle()1").Properties("name").Value = "Steering Wheel Angle"
      Data.Root.ActiveChannelGroup.Channels("Steering Wheel Angle").Properties("wf_start_offset").Value = -valid_distance_time
    Else
    End If

    'Change offset so channels t0 occurs at 30m or 60m
    Data.Root.ActiveChannelGroup.Channels("Longitudinal Position").Properties("wf_start_offset").Value = -valid_distance_time
    Data.Root.ActiveChannelGroup.Channels("Lateral Position").Properties("wf_start_offset").Value = -valid_distance_time 
    Data.Root.ActiveChannelGroup.Channels("Longitudinal Acceleration").Properties("wf_start_offset").Value = -valid_distance_time
    Data.Root.ActiveChannelGroup.Channels("Yaw Velocity").Properties("wf_start_offset").Value = -valid_distance_time
    Data.Root.ActiveChannelGroup.Channels("Speed").Properties("wf_start_offset").Value = -valid_distance_time

    'Remove channel offset and filter longitudinal acceleration
    Call ChnFiltCalc("","/Longitudinal Acceleration","/Longitudinal Acceleration","IIR","Butterworth","Low pass",12,6,0,0,1.2,25,"Hamming",1,0) '... XW,Y,E,FiltStruc,FiltStyle,FiltType,FiltDegree,FiltLimit,FiltLowLimit,FiltUppLimit,FiltWave,FiltSamples,FiltWndFct,FiltZeroPhase,FiltCorrection 

    'Remove channel offset and filter yaw velocity
    Call ChnFiltCalc("","/Yaw Velocity","/Yaw Velocity","IIR","Butterworth","Low pass",12,6,0,0,1.2,25,"Hamming",1,0) '... XW,Y,E,FiltStruc,FiltStyle,FiltType,FiltDegree,FiltLimit,FiltLowLimit,FiltUppLimit,FiltWave,FiltSamples,FiltWndFct,FiltZeroPhase,FiltCorrection 

    'Determind AEB activation point/time by finding the point where the longitudinal acceleration drops below -0.5 m\s² 
    Dim temp_value2, temp_value3, AEBactivation_point, AEBactivation_time

    For i = valid_distance_point to Data.Root.ActiveChannelGroup.Channels("Longitudinal Acceleration").Properties("length").Value
      temp_value2 = Data.Root.ActiveChannelGroup.Channels("Longitudinal Acceleration").Values(i)
      temp_value3 = Data.Root.ActiveChannelGroup.Channels("Longitudinal Acceleration").Values(i+1)

      'If values crosses below -0.5 m/s^2
      IF temp_value2 >= -0.5 THEN  
        IF temp_value3 < -0.5 THEN
          AEBactivation_point = i  
          Exit For
        END IF
      END IF

    Next

    'Calculate time in seconds that accel reaches -0.5 m\s²
    AEBactivation_time = ((AEBactivation_point) * .01) - valid_distance_time

    'Calculate initial speed (average speed 0.1 sec before AEB activation)
    Call ChnTimeAreaCopy("","/Speed","","/AEBActivation",AEBactivation_time - 0.1,AEBactivation_time) '... XW,Y,E,E,TimeAreaCopyBeg,TimeAreaCopyEnd 

    StatSel(1)       = "No"
    StatSel(2)       = "No"
    StatSel(3)       = "No"
    StatSel(4)       = "No"
    StatSel(5)       = "No"
    StatSel(6)       = "Yes"
    StatSel(7)       = "No"
    StatSel(8)       = "No"
    StatSel(9)       = "No"
    StatSel(10)      = "No"
    StatSel(11)      = "No"
    StatSel(12)      = "No"
    StatSel(13)      = "No"
    StatSel(14)      = "No"
    StatSel(15)      = "No"
    StatSel(16)      = "No"
    StatSel(17)      = "No"
    StatSel(18)      = "No"
    StatSel(19)      = "No"
    StatSel(20)      = "No"
    StatSel(21)      = "No"
    StatSel(22)      = "No"
    StatSel(23)      = "No"
    StatClipCopy     = 0
    StatClipValue    = 0
    StatFormat       = ""
    StatResChn       = 1
    StatResChnNames  = 0
    StatResChnNameFormat= "NameName"
    Call StatBlockCalc("Channel","1-","/AEBActivation") '... StatDirec,RowNoStr,ChnNoStr 

    'Save average speed as initial speed
    Dim Initial_Speed
    Initial_Speed = Data.Root.ActiveChannelGroup.Channels("ArithmeticMean").Properties("Maximum").Value
    Call Data.Root.ActiveChannelGroup.Properties.Add("Initial_Speed", Initial_Speed, DataTypeFloat64)

    Call Data.Root.ActiveChannelGroup.Channels.Remove("AEBActivation")
    Call Data.Root.ActiveChannelGroup.Channels.Remove("ArithmeticMean")

    'Find impact speed by determining if local position drops below 0m or speed reaches 0 kph before impact
    Dim Impact_Speed, temp_value4, temp_value5, Impact_Point, Impact_Time

    If Data.Root.ActiveChannelGroup.Channels("Longitudinal Position").Properties("minimum").Value < 0 then

      For i = valid_distance_point to Data.Root.ActiveChannelGroup.Channels("Longitudinal Position").Properties("length").Value
        temp_value4 = Data.Root.ActiveChannelGroup.Channels("Longitudinal Position").Values(i)
        temp_value5 = Data.Root.ActiveChannelGroup.Channels("Longitudinal Position").Values(i+1)

        'If values crosses below zero
        IF temp_value4 > 0 THEN  
          IF temp_value5 <= 0 THEN
            Impact_Point = i  'choose the point after impact
            Exit For
          END IF
        END IF
      Next
      
      Impact_Time = ((Impact_Point) * .01) - valid_distance_time 
      Call ChnTimeAreaCopy("","/Speed","","/tempspeed",0,Impact_Time) '... XW,Y,E,E,TimeAreaCopyBeg,TimeAreaCopyEnd
      
      If Data.Root.ActiveChannelGroup.Channels("tempspeed").Properties("minimum").Value > 0 then
        Impact_Speed = Data.Root.ActiveChannelGroup.Channels("Speed").Values(Impact_Point + 1) 
        Call Data.Root.ActiveChannelGroup.Properties.Add("Impact_Speed", Impact_Speed, DataTypeFloat64)
      Else
        Impact_Speed = 0
        Call Data.Root.ActiveChannelGroup.Properties.Add("Impact_Speed", Impact_Speed, DataTypeFloat64)
      End if
      
      Data.Root.ActiveChannelGroup.Channels.Remove("tempspeed")
      
    Else
      Impact_Speed = 0
      Call Data.Root.ActiveChannelGroup.Properties.Add("Impact_Speed", Impact_Speed, DataTypeFloat64)
    End If

    'Calculate maximum deceleration during AEB
    Dim Max_AEB_Decel, TestEnd

    If Data.Root.ActiveChannelGroup.Channels("Longitudinal Position").Properties("minimum").Value < 0 then 
      TestEnd = Impact_Time
      Else
      TestEnd = ((Data.Root.ActiveChannelGroup.Channels("Speed").Properties("length").Value) * 0.01) - valid_distance_time
    End IF

    Call ChnTimeAreaCopy("","/Longitudinal Acceleration","","/MaxDecel", 0, TestEnd) '... XW,Y,E,E,TimeAreaCopyBeg,TimeAreaCopyEnd
    Max_AEB_Decel = -1 * Data.Root.ActiveChannelGroup.Channels("MaxDecel").Properties("minimum").Value
    Call Data.Root.ActiveChannelGroup.Properties.Add("Max_AEB_Decel", Max_AEB_Decel, DataTypeFloat64)
    Call Data.Root.ActiveChannelGroup.Channels.Remove("MaxDecel")

    'Calculate speed reduction
    Dim Speed_reduction 
    Speed_reduction = Initial_speed - Impact_speed
    Call Data.Root.ActiveChannelGroup.Properties.Add("Speed Reduction", Speed_reduction, DataTypeFloat64)

    'Determine if the lateral position is valid for the run, yaw rate, speed and accelerator pedal position are valid for the run
    Dim Offset_min, Offset_max, Valid_Lateral_Position

    Call ChnTimeAreaCopy("","/Lateral Position","","/LatPosCheck", 0, TestEnd) '... XW,Y,E,E,TimeAreaCopyBeg,TimeAreaCopyEnd
    Offset_Min = Data.Root.ActiveChannelGroup.Channels("LatPosCheck").Properties("minimum").Value
    Offset_Max = Data.Root.ActiveChannelGroup.Channels("LatPosCheck").Properties("maximum").Value

    If Offset_min < -0.3 or Offset_max > 0.3 then
      Valid_Lateral_Position = "No"
      Else
      Valid_Lateral_Position = "Yes"
    End if

    Call Data.Root.ActiveChannelGroup.Properties.Add("Valid Position", Valid_Lateral_Position, DataTypeString)
    Call Data.Root.ActiveChannelGroup.Properties.Add("Min Lateral Offset",Offset_Min,DataTypeFloat64)
    Call Data.Root.ActiveChannelGroup.Properties.Add("Max Lateral Offset",Offset_Max,DataTypeFloat64)
    Call Data.Root.ActiveChannelGroup.Channels.Remove("LatPosCheck")

    'Determine if the yaw rate is valid for the run
    Dim Valid_Yaw_Max, Valid_Yaw_Min, Valid_YawRate

    Call ChnTimeAreaCopy("","/Yaw Velocity","","/YawCheck", 0, AEBactivation_time) '... XW,Y,E,E,TimeAreaCopyBeg,TimeAreaCopyEnd
    Valid_Yaw_Min = Data.Root.ActiveChannelGroup.Channels("YawCheck").Properties("minimum").Value
    Valid_Yaw_Max = Data.Root.ActiveChannelGroup.Channels("YawCheck").Properties("maximum").Value

    If Valid_Yaw_Min < -1 or Valid_Yaw_Max > 1 then
      Valid_YawRate = "No"
      Else
      Valid_YawRate = "Yes"
    End if

    Call Data.Root.ActiveChannelGroup.Properties.Add("Valid Yaw", Valid_YawRate, DataTypeString)
    Call Data.Root.ActiveChannelGroup.Properties.Add("Min Yaw",Valid_Yaw_Min,DataTypeFloat64)
    Call Data.Root.ActiveChannelGroup.Properties.Add("Max Yaw",Valid_Yaw_Max,DataTypeFloat64) 
    Call Data.Root.ActiveChannelGroup.Channels.Remove("YawCheck")

    'Determine if the Speed is valid for the test run
    Dim Valid_Speed_Min, Valid_Speed_Max, Valid_Speed

    Call ChnTimeAreaCopy("","/Speed","","/SpeedCheck", 0, AEBactivation_time) '... XW,Y,E,E,TimeAreaCopyBeg,TimeAreaCopyEnd
    Valid_Speed_Max = Data.Root.ActiveChannelGroup.Channels("SpeedCheck").Properties("maximum").Value
    Valid_Speed_Min = Data.Root.ActiveChannelGroup.Channels("SpeedCheck").Properties("minimum").Value

    If Valid_Speed_Max > TestSpeed + 1 or Valid_Speed_Min < TestSpeed - 1 then
      Valid_Speed = "No"
      Else
      Valid_Speed = "Yes"
    End if 

    Call Data.Root.ActiveChannelGroup.Properties.Add("Valid Speed", Valid_Speed, DataTypeString)
    Call Data.Root.ActiveChannelGroup.Properties.Add("Min Speed",Valid_Speed_Min,DatatypeFloat64)
    Call Data.Root.ActiveChannelGroup.Properties.Add("Max Speed",Valid_Speed_Max,DataTypeFloat64)
    Call Data.Root.ActiveChannelGroup.Channels.Remove("SpeedCheck")

    'Determine if the accelerator pedal is valid for the test run
    Dim Initial_Pedal, Pedal_Max, Pedal_Min, Valid_Pedal

    If Data.Root.ActiveChannelGroup.Channels.Exists("Accelerator Pedal Position") then
      Call ChnTimeAreaCopy("","/Accelerator Pedal Position","","/PedalCheck",0, AEBactivation_time)
      Initial_Pedal = Data.Root.ActiveChannelGroup.Channels("PedalCheck").Values(1)
      Pedal_Max = Data.Root.ActiveChannelGroup.Channels("PedalCheck").Properties("maximum").Value
      Pedal_Min = Data.Root.ActiveChannelGroup.Channels("PedalCheck").Properties("minimum").Value
      Call Data.Root.ActiveChannelGroup.Properties.Add("Pedal Target",Initial_Pedal,DataTypeFloat64)
      Call Data.Root.ActiveChannelGroup.Properties.Add("Min Pedal Travel",Pedal_Min,DataTypeFloat64)
      Call Data.Root.ActiveChannelGroup.Properties.Add("Max Pedal Travel",Pedal_Max,DataTypeFloat64)
      Call Data.Root.ActiveChannelGroup.Channels.Remove("PedalCheck")
      
      If Pedal_Max > Initial_Pedal + 5 or Pedal_Min < Initial_Pedal - 5 then
        Valid_Pedal = "No"
        Else
        Valid_Pedal = "Yes"
      End if 
    Else
    Valid_Pedal = "N/A"
    Call Data.Root.ActiveChannelGroup.Properties.Add("Pedal Target","N/A",DataTypeString)
    Call Data.Root.ActiveChannelGroup.Properties.Add("Min Pedal Travel","N/A",DataTypeString)
    Call Data.Root.ActiveChannelGroup.Properties.Add("Max Pedal Travel","N/A",DataTypeString)
    End if

    Call Data.Root.ActiveChannelGroup.Properties.Add("Valid Pedal", Valid_Pedal, DataTypeString)

    msgbox("Valid Lateral Position? " & Valid_Lateral_Position & vbcrlf & "Valid Yaw Rate? " & Valid_YawRate & vbcrlf & "Valid Speed? " & Valid_Speed & vbcrlf & "Valid Pedal Pos? " & Valid_Pedal)

    If Data.Root.Properties.Exists("Valid_" & TestSpeed & "kph_Tests") = True then
    Else
      Call Data.Root.Properties.Add("Valid_" & TestSpeed & "kph_Tests", 0, DataTypeFloat64)
      Call Data.Root.Properties.Add("Speed_Reduction_" & TestSpeed & "kph", 0, DataTypeFloat64)
      Call Data.Root.Properties.Add("TotalSpeed" & TestSpeed, 0, DataTypeFloat64)
    End if

    'Check if the run is valid, update valid test counter
    Dim Valid_Test

    If Valid_Lateral_Position = "No" or Valid_YawRate = "No" or Valid_Speed = "No" or Valid_Pedal = "No" then
      Valid_Test = "No"
    Else
      Valid_Test = "Yes"
      Data.Root.Properties("Valid_" & TestSpeed & "kph_Tests").Value = Data.Root.Properties("Valid_" & TestSpeed & "kph_Tests").Value + 1
      msgbox("Test Results for " & TestSpeed & "kph-" & TestNumber & ":" & vbcrlf & "Initial Speed: " & round(Initial_speed,2) & " km/h" & vbcrlf & "Impact Speed: " & round(Impact_Speed,2) & " km/h" & vbcrlf & "Speed Reduction: " & round(Speed_reduction,2) & " km/h") 
      Data.Root.Properties("TotalSpeed" & TestSpeed).Value = Data.Root.Properties("TotalSpeed" & TestSpeed).Value + Speed_reduction
      Data.Root.Properties("Speed_Reduction_" & TestSpeed & "kph").Value = Data.Root.Properties("TotalSpeed" & TestSpeed).Value/Data.Root.Properties("Valid_" & TestSpeed & "kph_Tests").Value
      msgbox(TestSpeed & " km/h Test Results:" & vbcrlf & "Valid Tests: " & round(Data.Root.Properties("Valid_" & TestSpeed & "kph_Tests").Value,2) & vbcrlf & "Average Speed Reduction: " & round(Data.Root.Properties("Speed_Reduction_" & TestSpeed & "kph").Value, 2) & " km/h")
    End If

    Call Data.Root.ActiveChannelGroup.Properties.Add("Valid Test", Valid_Test, DataTypeString)

    'Add properties for TTC of AEB activation and TTC of Warning
    Dim AEB_TTC, AEB_TTC_point

    AEB_TTC_point = ((AEBactivation_time - Data.Root.ActiveChannelGroup.Channels("Longitudinal Position").Properties("wf_start_offset").Value)*100)+1
    AEB_TTC = Data.Root.ActiveChannelGroup.Channels("Longitudinal Position").Values(AEB_TTC_point)/(Data.Root.ActiveChannelGroup.Channels("Speed").Values(AEB_TTC_point)*.2777778)

    If AEB_TTC < 0 then 
      AEB_TTC = 0 
    Else
    End If

    Call Data.Root.ActiveChannelGroup.Properties.Add("FCW TTC",0,DataTypeFloat64)
    Call Data.Root.ActiveChannelGroup.Properties.Add("AEB TTC",AEB_TTC,DataTypeFloat64)

    'Add properties for start date/time for each test
    Dim Test_run_start, Test_run_time, Test_run_date
    Dim Test_run_end, Test_end_time, Test_end_date,last_value

    Test_run_date = RTT(Data.Root.ChannelGroups(groupcount - 1).Channels(1).Values(1), "mm/dd/yyyy")
    Test_run_time = RTT(Data.Root.ChannelGroups(groupcount - 1).Channels(2).Values(1), "hh:nn AMPM")
    Test_run_start = Test_run_date & " " & Test_run_time
    Call Data.Root.ActiveChannelGroup.Properties.Add("Test Run Start",Test_run_start)

    Last_value = Data.Root.ChannelGroups(groupcount - 1).Channels(1).Properties("lengthmax").Value
    Test_end_date = RTT(Data.Root.ChannelGroups(groupcount - 1).Channels(1).Values(Last_value),"mm/dd/yyyy")
    Test_end_time = RTT(Data.Root.ChannelGroups(groupcount - 1).Channels(2).Values(Last_value),"hh:nn AMPM")
    Test_run_end = Test_end_date & " " & Test_end_time
    Call Data.Root.ActiveChannelGroup.Properties.Add("Test Run End",Test_run_end)

    If Data.Root.Properties.Exists("StartTime") = False then
      Call Data.Root.Properties.Add("StartTime",Test_run_start)
      Call Data.Root.Properties.Add("EndTime",Test_run_end)
    Else
      Data.Root.Properties("EndTime").Value = Test_run_end
    End if  

    'Save File
    Call DataFileSave(Folder & TestID & "\DIAdem\" & TestID & " - " & TestVehicle & ".tdms","TDMS") '... DataFilename,FileExportFilter 

    'Collapse data portal
    Call UIAutoRefreshSet(True) 
    Call Portal.Structure.Collapse(Data.Root) 
    Call UIAutoRefreshSet(False) 

  End Sub
