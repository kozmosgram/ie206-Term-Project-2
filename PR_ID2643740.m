%Emre Başaran 2643740
clear classes
clear all
clc

[num,txt,raw] = xlsread('InputData.xlsx');

%DATAS

numOperations = size(raw, 1)-1;
operation = {};
for i = 2:numOperations+1
    operationDay=0;
    operationRoom=0;
    patient(i-1)=Patient(raw{i,2}, raw{i,3}, raw{i,8}, raw{i,9}, raw{i,4});%Patient(name,surname,priority,complexity,day
    operation{i-1,1} =Operation(raw{i,1},patient(i-1),Interval(raw{i,6},raw{i,7}),Interval(0,0),raw{i,5},operationDay,operationRoom,patient(i-1).getPatientName,patient(i-1).getPatientSurname);
    operation{i-1,2}= raw{i,7};%AVAILABLE FINISH
    operation{i-1,3}=raw{i,8};%PRIORITY
    operation{i-1,4}=raw{i,5};%DURATION
    operation{i-1,5}=raw{i,4};%DAY
    operation{i-1,6}=raw{i,9};%COMPLEXITY
    operation{i-1,7} = raw{i,6};%AVAILABLE START
end

%SCHEDULE & REPORT

dailyPlanningHorizon = Interval(0,480);
planningDays = 5;
numberOfRooms = 3;%4;
schedule = Schedule(dailyPlanningHorizon,planningDays,numberOfRooms);
objective=input("Objective: ");
schedule.constructSchedule(operation,objective)
schedule.printSchedule(operation)
schedule.Reporting()