%Emre Başaran 2643740
classdef Schedule < handle

    properties
        dailyPlanningHorizon%(object of type Interval)
        planningDays%(type: Integer)
        numberOfRooms%(type: Integer)
        finalSchedule%(type: cellArray)
        FoVCount % # of operations that fit own availableInterval
        roomOR%Occupancy Ratio of Rooms(type: LIST)
        priPost%Priority Level of Postponed Operations(type: LIST)
    end
    
    methods
        function self = Schedule(dailyPlanningHorizon,planningDays,numberOfRooms)
        %CONSTRUCTOR
            self.dailyPlanningHorizon = dailyPlanningHorizon;
            self.planningDays = planningDays;
            self.numberOfRooms = numberOfRooms;
            self.finalSchedule ={};
            self.FoVCount=0;
            self.roomOR = [];
            self.priPost = [];
        end
        
        function constructSchedule(self,operation,objective)
            if objective == 1
                self.scheduled_objective_1(operation);
            elseif objective == 2
                self.scheduled_objective_2(operation);
            elseif objective == 3
                self.scheduled_objective_3(operation);
            else
                error('Invalid Objective');
            end
        end
%SCHEDULE OBJECTIVE 1

        function scheduled_objective_1(self, operation)
            %how much an operation occupies the room = duration + sanitization
            for totT=1:97
                operation{totT,8} = operation{totT,4}+(operation{totT,6}-1)*20;
            end

        %SORTING
        %While planning the operations, I first sort the features as necessary for the necessary objective.
            operation = sortrows(operation,8);%how much an operation occupies the room = duration + sanitization
            operation = sortrows(operation,3);%priority
            operation = sortrows(operation,7);%available start
            operation = sortrows(operation,5);%day

            postOp = [];%This keeps postponed operations

            %ROOMS-FINAL SCHEDULE
            a = 1;
            for i = 1:self.planningDays
                room1 = Interval(self.dailyPlanningHorizon.left, self.dailyPlanningHorizon.right); 
                room2 = Interval(self.dailyPlanningHorizon.left, self.dailyPlanningHorizon.right); 
                room3 = Interval(self.dailyPlanningHorizon.left, self.dailyPlanningHorizon.right); 
                %room4 = Interval(self.dailyPlanningHorizon.left, self.dailyPlanningHorizon.right); 

                self.finalSchedule{i, 1} = {};
                self.finalSchedule{i, 2} = {};
                self.finalSchedule{i, 3} = {};
                %self.finalSchedule{i, 4} = {};

                NPO = size(postOp,1);% # of postponed operations
                length = NPO;

                if ~isempty(postOp) 
                    postOp = sortrows(postOp, 2);
                end

                %ROOM COUNTERS & OCCUPANCY RATIO CALCULATOR
                room1Count = 1; 
                room1Occupancy = 0;
                room2Count = 1; 
                room2Occupancy = 0;
                room3Count = 1; 
                room3Occupancy = 0;
                %room4Count = 1; 
                %room4Occupancy = 0;
                
                while ~isempty(postOp) && NPO ~= length-3%%-4
                    if NPO == length
                        self.finalSchedule{i, 1, 1} = Operation(postOp{NPO,1}.id, postOp{NPO,1}.patient, postOp{NPO,1}.availableInterval, Interval(room1.left*(room1.left >= postOp{NPO,1}.availableInterval.left) + postOp{NPO,1}.availableInterval.left*(room1.left < postOp{NPO,1}.availableInterval.left), room1.left*(room1.left >= postOp{NPO,1}.availableInterval.left) + postOp{NPO,1}.availableInterval.left*(room1.left < postOp{NPO,1}.availableInterval.left) + postOp{NPO,1}.duration), postOp{NPO,1}.duration, i, 1,operation{a, 1}.patientName,operation{a, 1}.patientSurname);
                        room1.left = room1.left*(room1.left >= postOp{NPO,1}.availableInterval.left) + postOp{NPO,1}.availableInterval.left*(room1.left < postOp{NPO,1}.availableInterval.left) + postOp{NPO,1}.duration+(operation{a,6}-1)*20;
                        room1Count = room1Count+1;
                        room1Occupancy = room1Occupancy + postOp{NPO,1}.duration;
                    elseif NPO == length-1
                        self.finalSchedule{i, 2, 1} = Operation(postOp{NPO,1}.id, postOp{NPO,1}.patient, postOp{NPO,1}.availableInterval, Interval(room2.left*(room2.left>= postOp{NPO,1}.availableInterval.left) + postOp{NPO,1}.availableInterval.left * (room2.left < postOp{NPO,1}.availableInterval.left), room2.left * (room2.left >= postOp{NPO,1}.availableInterval.left) + postOp{NPO,1}.availableInterval.left * (room2.left < postOp{NPO,1}.availableInterval.left) + postOp{NPO,1}.duration), postOp{NPO,1}.duration, i, 2,operation{a, 1}.patientName,operation{a, 1}.patientSurname);
                        room2.left = room2.left * (room2.left >= postOp{NPO,1}.availableInterval.left) + postOp{NPO,1}.availableInterval.left * (room2.left < postOp{NPO,1}.availableInterval.left) + postOp{NPO,1}.duration+(operation{a,6}-1)*20;
                        room2Count = room2Count+1;
                        room2Occupancy = room2Occupancy + postOp{NPO,1}.duration;
                
                    elseif NPO == length-2
                        self.finalSchedule{i, 3, 1} = Operation(postOp{NPO,1}.id, postOp{NPO,1}.patient, postOp{NPO,1}.availableInterval, Interval(room3.left*(room3.left >= postOp{NPO,1}.availableInterval.left) + postOp{NPO,1}.availableInterval.left * (room3.left < postOp{NPO,1}.availableInterval.left), room3.left * (room3.left >= postOp{NPO,1}.availableInterval.left) + postOp{NPO,1}.availableInterval.left * (room3.left < postOp{NPO,1}.availableInterval.left) + postOp{NPO,1}.duration), postOp{NPO,1}.duration, i, 3,operation{a, 1}.patientName,operation{a, 1}.patientSurname);
                        room3.left = room3.left*(room3.left >= postOp{NPO,1}.availableInterval.left) + postOp{NPO,1}.availableInterval.left * (room3.left < postOp{NPO,1}.availableInterval.left) + postOp{NPO,1}.duration+(operation{a,6}-1)*20;
                        room3Count = room3Count + 1;
                        room3Occupancy = room3Occupancy + postOp{NPO,1}.duration;
                    
                    %elseif NPO == length-3
                    %    self.finalSchedule{i, 4, 1} = Operation(postOp{NPO,1}.id, postOp{NPO,1}.patient, postOp{NPO,1}.availableInterval, Interval(room4.left*(room4.left >= postOp{NPO,1}.availableInterval.left) + postOp{NPO,1}.availableInterval.left * (room4.left < postOp{NPO,1}.availableInterval.left), room4.left * (room4.left >= postOp{NPO,1}.availableInterval.left) + postOp{NPO,1}.availableInterval.left * (room3.left < postOp{NPO,1}.availableInterval.left) + postOp{NPO,1}.duration), postOp{NPO,1}.duration, i, 3,operation{a, 1}.patientName,operation{a, 1}.patientSurname);
                    %    room4.left = room4.left*(room4.left >= postOp{NPO,1}.availableInterval.left) + postOp{NPO,1}.availableInterval.left * (room4.left < postOp{NPO,1}.availableInterval.left) + postOp{NPO,1}.duration+(operation{a,6}-1)*20;
                    %    room4Count = room4Count + 1;
                    %    room4Occupancy = room4Occupancy + postOp{NPO,1}.duration;
                    end
                    postOp(NPO,:) = [];
                    NPO = NPO - 1;
                end

                b = 1;
                postOp = {};
                while operation{a, 5} == i && a ~= size(operation, 1)
                    if room1.left * (room1.left >= operation{a, 1}.availableInterval.left) + operation{a, 1}.availableInterval.left * (room1.left < operation{a, 1}.availableInterval.left) + operation{a, 1}.duration <= operation{a, 1}.availableInterval.right
                        self.finalSchedule{i, 1, room1Count} = Operation(operation{a, 1}.id, operation{a, 1}, operation{a, 1}.availableInterval, Interval(room1.left * (room1.left >= operation{a, 1}.availableInterval.left) + operation{a, 1}.availableInterval.left * (room1.left < operation{a, 1}.availableInterval.left), room1.left * (room1.left >= operation{a, 1}.availableInterval.left) + operation{a, 1}.availableInterval.left * (room1.left < operation{a, 1}.availableInterval.left) + operation{a, 1}.duration), operation{a, 1}.duration, i, 1,operation{a, 1}.patientName,operation{a, 1}.patientSurname);
                        room1.left = room1.left * (room1.left >= operation{a, 1}.availableInterval.left) + operation{a, 1}.availableInterval.left * (room1.left < operation{a, 1}.availableInterval.left) + operation{a, 1}.duration+(operation{a,6}-1)*20;
                        room1Count = room1Count + 1;
                        room1Occupancy = room1Occupancy + operation{a, 1}.duration;
                        self.FoVCount = self.FoVCount + 1;
                    elseif room2.left * (room2.left >= operation{a, 1}.availableInterval.left) + operation{a, 1}.availableInterval.left * (room2.left < operation{a, 1}.availableInterval.left) + operation{a, 1}.duration <= operation{a, 1}.availableInterval.right
                        self.finalSchedule{i, 2, room2Count} = Operation(operation{a, 1}.id, operation{a, 1}.patient, operation{a, 1}.availableInterval, Interval(room2.left * (room2.left >= operation{a, 1}.availableInterval.left) + operation{a, 1}.availableInterval.left * (room2.left < operation{a, 1}.availableInterval.left), room2.left * (room2.left >= operation{a, 1}.availableInterval.left) + operation{a, 1}.availableInterval.left * (room2.left < operation{a, 1}.availableInterval.left) + operation{a, 1}.duration), operation{a, 1}.duration, i, 2,operation{a, 1}.patientName,operation{a, 1}.patientSurname);
                        room2.left = room2.left * (room2.left >= operation{a, 1}.availableInterval.left) + operation{a, 1}.availableInterval.left * (room2.left < operation{a, 1}.availableInterval.left) + operation{a, 1}.duration+(operation{a,6}-1)*20;
                        room2Count = room2Count + 1;
                        room2Occupancy = room2Occupancy + operation{a, 1}.duration;
                        self.FoVCount = self.FoVCount + 1;
                    elseif room3.left * (room3.left >= operation{a, 1}.availableInterval.left) + operation{a, 1}.availableInterval.left * (room3.left < operation{a, 1}.availableInterval.left) + operation{a, 1}.duration <= operation{a, 1}.availableInterval.right
                        self.finalSchedule{i, 3, room3Count} = Operation(operation{a, 1}.id, operation{a, 1}, operation{a, 1}.availableInterval, Interval(room3.left * (room3.left >= operation{a, 1}.availableInterval.left) + operation{a, 1}.availableInterval.left * (room3.left < operation{a, 1}.availableInterval.left), room3.left * (room3.left >= operation{a, 1}.availableInterval.left) + operation{a, 1}.availableInterval.left * (room3.left < operation{a, 1}.availableInterval.left) + operation{a, 1}.duration), operation{a, 1}.duration, i, 3,operation{a, 1}.patientName,operation{a, 1}.patientSurname);
                        room3.left = room3.left * (room3.left >= operation{a, 1}.availableInterval.left) + operation{a, 1}.availableInterval.left * (room3.left < operation{a, 1}.availableInterval.left) + operation{a, 1}.duration+(operation{a,6}-1)*20;
                        room3Count = room3Count + 1;
                        room3Occupancy = room3Occupancy + operation{a, 1}.duration;
                        self.FoVCount = self.FoVCount + 1;
                    %elseif room4.left * (room4.left >= operation{a, 1}.availableInterval.left) + operation{a, 1}.availableInterval.left * (room4.left < operation{a, 1}.availableInterval.left) + operation{a, 1}.duration <= operation{a, 1}.availableInterval.right
                    %    self.finalSchedule{i, 4, room4Count} = Operation(operation{a, 1}.id, operation{a, 1}, operation{a, 1}.availableInterval, Interval(room4.left * (room4.left >= operation{a, 1}.availableInterval.left) + operation{a, 1}.availableInterval.left * (room4.left < operation{a, 1}.availableInterval.left), room4.left * (room4.left >= operation{a, 1}.availableInterval.left) + operation{a, 1}.availableInterval.left * (room4.left < operation{a, 1}.availableInterval.left) + operation{a, 1}.duration), operation{a, 1}.duration, i, 4,operation{a, 1}.patientName,operation{a, 1}.patientSurname);
                    %    room4.left = room4.left * (room4.left >= operation{a, 1}.availableInterval.left) + operation{a, 1}.availableInterval.left * (room4.left < operation{a, 1}.availableInterval.left) + operation{a, 1}.duration+(operation{a,6}-1)*20;
                    %    room4Count = room4Count + 1;
                    %    room4Occupancy = room4Occupancy + operation{a, 1}.duration+(operation{a,1}.patient.getPatientComplexity -1)*20;
                    %    self.FoVCount = self.FoVCount + 1;
                    else
                        self.priPost = [self.priPost operation{a, 1}.patient.getPatientPriority];
                        operation{a, 1}.patient.setPatientDay(i+1)
                        operation{a, 1}.patient.setPatientPriority(0)
                        postOp{b,1} = Operation(operation{a, 1}.id, operation{a, 1}, operation{a, 1}.availableInterval, operation{a, 1}.availableInterval, operation{a, 1}.duration, i+1,0,operation{a, 1}.patientName,operation{a, 1}.patientSurname);
                        postOp{b,1}.setAvailableInterval(Interval(0,operation{a, 1}.duration))
                        postOp{b,1}.setScheduledInterval(Interval(0,operation{a, 1}.duration))
                        postOp{b,2} = operation{a, 1}.duration;
                        b=b+1;
                    end
                    a=a+1;
                end
                self.roomOR = [self.roomOR; [room1Occupancy/480, room2Occupancy/480, room3Occupancy/480]];%, room4Occupancy/480]];
            end
        end
%SCHEDULE OBJECTIVE 2
        function scheduled_objective_2(self, operation)

            for totT=1:97
                operation{totT,8} = operation{totT,4}+(operation{totT,6}-1)*20;
            end
        %SORTING
        %While planning the operations, I first sort the features as necessary for the necessary objective.
            operation = sortrows(operation, -4);%Duration is long to short
            operation = sortrows(operation, 3);%priority
            operation = sortrows(operation,7);%Available Start
            operation = sortrows(operation,5);%day
            postOp = [];
            %ROOMS-FINAL SCHEDULE
            a = 1;
            for i = 1:self.planningDays
                room1 = Interval(self.dailyPlanningHorizon.left, self.dailyPlanningHorizon.right); 
                room2 = Interval(self.dailyPlanningHorizon.left, self.dailyPlanningHorizon.right); 
                room3 = Interval(self.dailyPlanningHorizon.left, self.dailyPlanningHorizon.right); 
                %room4 = Interval(self.dailyPlanningHorizon.left, self.dailyPlanningHorizon.right); 

                self.finalSchedule{i, 1} = {};
                self.finalSchedule{i, 2} = {};
                self.finalSchedule{i, 3} = {};
                %self.finalSchedule{i, 4} = {};

                NPO = size(postOp,1);% # of postponed operations
                length = NPO;

                if ~isempty(postOp) 
                    postOp = sortrows(postOp, 2);
                end

                %ROOM COUNTERS & OCCUPANCY RATIO CALCULATOR
                room1Count = 1; 
                room1Occupancy = 0;
                room2Count = 1; 
                room2Occupancy = 0;
                room3Count = 1; 
                room3Occupancy = 0;
                %room4Count = 1; 
                %room4Occupancy = 0;
                
                while ~isempty(postOp) && NPO ~= length-3%%-4
                    if NPO == length
                        self.finalSchedule{i, 1, 1} = Operation(postOp{NPO,1}.id, postOp{NPO,1}.patient, postOp{NPO,1}.availableInterval, Interval(room1.left*(room1.left >= postOp{NPO,1}.availableInterval.left) + postOp{NPO,1}.availableInterval.left*(room1.left < postOp{NPO,1}.availableInterval.left), room1.left*(room1.left >= postOp{NPO,1}.availableInterval.left) + postOp{NPO,1}.availableInterval.left*(room1.left < postOp{NPO,1}.availableInterval.left) + postOp{NPO,1}.duration), postOp{NPO,1}.duration, i, 1,operation{a, 1}.patientName,operation{a, 1}.patientSurname);
                        room1.left = room1.left*(room1.left >= postOp{NPO,1}.availableInterval.left) + postOp{NPO,1}.availableInterval.left*(room1.left < postOp{NPO,1}.availableInterval.left) + postOp{NPO,1}.duration+(operation{a,6}-1)*20;
                        room1Count = room1Count+1;
                        room1Occupancy = room1Occupancy + postOp{NPO,1}.duration;
                        
                    elseif NPO == length-1
                        self.finalSchedule{i, 2, 1} = Operation(postOp{NPO,1}.id, postOp{NPO,1}.patient, postOp{NPO,1}.availableInterval, Interval(room2.left*(room2.left>= postOp{NPO,1}.availableInterval.left) + postOp{NPO,1}.availableInterval.left * (room2.left < postOp{NPO,1}.availableInterval.left), room2.left * (room2.left >= postOp{NPO,1}.availableInterval.left) + postOp{NPO,1}.availableInterval.left * (room2.left < postOp{NPO,1}.availableInterval.left) + postOp{NPO,1}.duration), postOp{NPO,1}.duration, i, 2,operation{a, 1}.patientName,operation{a, 1}.patientSurname);
                        room2.left = room2.left * (room2.left >= postOp{NPO,1}.availableInterval.left) + postOp{NPO,1}.availableInterval.left * (room2.left < postOp{NPO,1}.availableInterval.left) + postOp{NPO,1}.duration+(operation{a,6}-1)*20;
                        room2Count = room2Count+1;
                        room2Occupancy = room2Occupancy + postOp{NPO,1}.duration;
                
                    elseif NPO == length-2
                        self.finalSchedule{i, 3, 1} = Operation(postOp{NPO,1}.id, postOp{NPO,1}.patient, postOp{NPO,1}.availableInterval, Interval(room3.left*(room3.left >= postOp{NPO,1}.availableInterval.left) + postOp{NPO,1}.availableInterval.left * (room3.left < postOp{NPO,1}.availableInterval.left), room3.left * (room3.left >= postOp{NPO,1}.availableInterval.left) + postOp{NPO,1}.availableInterval.left * (room3.left < postOp{NPO,1}.availableInterval.left) + postOp{NPO,1}.duration), postOp{NPO,1}.duration, i, 3,operation{a, 1}.patientName,operation{a, 1}.patientSurname);
                        room3.left = room3.left*(room3.left >= postOp{NPO,1}.availableInterval.left) + postOp{NPO,1}.availableInterval.left * (room3.left < postOp{NPO,1}.availableInterval.left) + postOp{NPO,1}.duration+(operation{a,6}-1)*20;
                        room3Count = room3Count + 1;
                        room3Occupancy = room3Occupancy + postOp{NPO,1}.duration;
                    
                    %elseif NPO == length-3
                    %    self.finalSchedule{i, 4, 1} = Operation(postOp{NPO,1}.id, postOp{NPO,1}.patient, postOp{NPO,1}.availableInterval, Interval(room4.left*(room4.left >= postOp{NPO,1}.availableInterval.left) + postOp{NPO,1}.availableInterval.left * (room4.left < postOp{NPO,1}.availableInterval.left), room4.left * (room4.left >= postOp{NPO,1}.availableInterval.left) + postOp{NPO,1}.availableInterval.left * (room3.left < postOp{NPO,1}.availableInterval.left) + postOp{NPO,1}.duration), postOp{NPO,1}.duration, i, 3,operation{a, 1}.patientName,operation{a, 1}.patientSurname);
                    %    room4.left = room4.left * (room4.left >= postOp{NPO,1}.availableInterval.left) + postOp{NPO,1}.availableInterval.left * (room4.left < postOp{NPO,1}.availableInterval.left) + postOp{NPO,1}.duration+(operation{a,6}-1)*20;
                    %    room4Count = room4Count + 1;
                    %    room4Occupancy = room4Occupancy + postOp{NPO,1}.duration;
                    end
                    postOp(NPO,:) = [];
                    NPO = NPO - 1;
                end

                b = 1;
                postOp = {};
                while operation{a, 5} == i && a ~= size(operation, 1)
                    if room1.left * (room1.left >= operation{a, 1}.availableInterval.left) + operation{a, 1}.availableInterval.left * (room1.left < operation{a, 1}.availableInterval.left) + operation{a, 1}.duration <= operation{a, 1}.availableInterval.right
                        self.finalSchedule{i, 1, room1Count} = Operation(operation{a, 1}.id, operation{a, 1}, operation{a, 1}.availableInterval, Interval(room1.left * (room1.left >= operation{a, 1}.availableInterval.left) + operation{a, 1}.availableInterval.left * (room1.left < operation{a, 1}.availableInterval.left), room1.left * (room1.left >= operation{a, 1}.availableInterval.left) + operation{a, 1}.availableInterval.left * (room1.left < operation{a, 1}.availableInterval.left) + operation{a, 1}.duration), operation{a, 1}.duration, i, 1,operation{a, 1}.patientName,operation{a, 1}.patientSurname);
                        room1.left = room1.left * (room1.left >= operation{a, 1}.availableInterval.left) + operation{a, 1}.availableInterval.left * (room1.left < operation{a, 1}.availableInterval.left) + operation{a, 1}.duration+(operation{a,6}-1)*20;
                        room1Count = room1Count + 1;
                        room1Occupancy = room1Occupancy + operation{a, 1}.duration;
                        self.FoVCount = self.FoVCount + 1;
                    elseif room2.left * (room2.left >= operation{a, 1}.availableInterval.left) + operation{a, 1}.availableInterval.left * (room2.left < operation{a, 1}.availableInterval.left) + operation{a, 1}.duration <= operation{a, 1}.availableInterval.right
                        self.finalSchedule{i, 2, room2Count} = Operation(operation{a, 1}.id, operation{a, 1}, operation{a, 1}.availableInterval, Interval(room2.left * (room2.left >= operation{a, 1}.availableInterval.left) + operation{a, 1}.availableInterval.left * (room2.left < operation{a, 1}.availableInterval.left), room2.left * (room2.left >= operation{a, 1}.availableInterval.left) + operation{a, 1}.availableInterval.left * (room2.left < operation{a, 1}.availableInterval.left) + operation{a, 1}.duration), operation{a, 1}.duration, i, 2,operation{a, 1}.patientName,operation{a, 1}.patientSurname);
                        room2.left = room2.left * (room2.left >= operation{a, 1}.availableInterval.left) + operation{a, 1}.availableInterval.left * (room2.left < operation{a, 1}.availableInterval.left) + operation{a, 1}.duration+(operation{a,6}-1)*20;
                        room2Count = room2Count + 1;
                        room2Occupancy = room2Occupancy + operation{a, 1}.duration;
                        self.FoVCount = self.FoVCount + 1;
                    elseif room3.left * (room3.left >= operation{a, 1}.availableInterval.left) + operation{a, 1}.availableInterval.left * (room3.left < operation{a, 1}.availableInterval.left) + operation{a, 1}.duration <= operation{a, 1}.availableInterval.right
                        self.finalSchedule{i, 3, room3Count} = Operation(operation{a, 1}.id, operation{a, 1}, operation{a, 1}.availableInterval, Interval(room3.left * (room3.left >= operation{a, 1}.availableInterval.left) + operation{a, 1}.availableInterval.left * (room3.left < operation{a, 1}.availableInterval.left), room3.left * (room3.left >= operation{a, 1}.availableInterval.left) + operation{a, 1}.availableInterval.left * (room3.left < operation{a, 1}.availableInterval.left) + operation{a, 1}.duration), operation{a, 1}.duration, i, 3,operation{a, 1}.patientName,operation{a, 1}.patientSurname);
                        room3.left = room3.left * (room3.left >= operation{a, 1}.availableInterval.left) + operation{a, 1}.availableInterval.left * (room3.left < operation{a, 1}.availableInterval.left) + operation{a, 1}.duration+(operation{a,6}-1)*20;
                        room3Count = room3Count + 1;
                        room3Occupancy = room3Occupancy + operation{a, 1}.duration;
                        self.FoVCount = self.FoVCount + 1;
                    %elseif room4.left * (room4.left >= operation{a, 1}.availableInterval.left) + operation{a, 1}.availableInterval.left * (room4.left < operation{a, 1}.availableInterval.left) + operation{a, 1}.duration <= operation{a, 1}.availableInterval.right
                    %    self.finalSchedule{i, 4, room4Count} = Operation(operation{a, 1}.id, operation{a, 1}, operation{a, 1}.availableInterval, Interval(room4.left * (room4.left >= operation{a, 1}.availableInterval.left) + operation{a, 1}.availableInterval.left * (room4.left < operation{a, 1}.availableInterval.left), room4.left * (room4.left >= operation{a, 1}.availableInterval.left) + operation{a, 1}.availableInterval.left * (room4.left < operation{a, 1}.availableInterval.left) + operation{a, 1}.duration), operation{a, 1}.duration, i, 4,operation{a, 1}.patientName,operation{a, 1}.patientSurname);
                    %    room4.left = room4.left * (room4.left >= operation{a, 1}.availableInterval.left) + operation{a, 1}.availableInterval.left * (room4.left < operation{a, 1}.availableInterval.left) + operation{a, 1}.duration+(operation{a,6}-1)*20;
                    %    room4Count = room4Count + 1;
                    %    room4Occupancy = room4Occupancy + operation{a, 1}.duration;
                    %    self.FoVCount = self.FoVCount + 1;
                    else
                        self.priPost = [self.priPost operation{a, 1}.patient.getPatientPriority];
                        operation{a, 1}.patient.setPatientDay(i+1)
                        operation{a, 1}.patient.setPatientPriority(0)
                        postOp{b,1} = Operation(operation{a, 1}.id, operation{a, 1}, operation{a, 1}.availableInterval, operation{a, 1}.availableInterval, operation{a, 1}.duration, i+1,0,operation{a, 1}.patientName,operation{a, 1}.patientSurname);
                        postOp{b,1}.setAvailableInterval(Interval(0,operation{a, 1}.duration))
                        postOp{b,1}.setScheduledInterval(Interval(0,operation{a, 1}.duration))
                        postOp{b,2} = operation{a, 1}.duration;
                        b=b+1;
                        
                    end
                    a=a+1;
                end
                self.roomOR = [self.roomOR; [room1Occupancy/480, room2Occupancy/480, room3Occupancy/480]];%, room4Occupancy/480]];
            end
        end
%SCHEDULE OBJECTIVE 3
        function scheduled_objective_3(self, operation)

            for totT=1:97
                operation{totT,8} = operation{totT,4}+(operation{totT,6}-1)*20;
            end
        %SORTING
        %While planning the operations, I first sort the features as necessary for the necessary objective.
            operation = sortrows(operation, 3);%priority
            operation = sortrows(operation,7);%Available Start
            operation = sortrows(operation,5);%day
            postOp = [];
            %ROOMS-FINAL SCHEDULE
            a = 1;
            for i = 1:self.planningDays
                operation = sortrows(operation, 3);%priority
                operation = sortrows(operation,7);%Available Start
                operation = sortrows(operation,5);%day
                room1 = Interval(self.dailyPlanningHorizon.left, self.dailyPlanningHorizon.right); 
                room2 = Interval(self.dailyPlanningHorizon.left, self.dailyPlanningHorizon.right); 
                room3 = Interval(self.dailyPlanningHorizon.left, self.dailyPlanningHorizon.right); 
                %room4 = Interval(self.dailyPlanningHorizon.left, self.dailyPlanningHorizon.right); 

                self.finalSchedule{i, 1} = {};
                self.finalSchedule{i, 2} = {};
                self.finalSchedule{i, 3} = {};
                %self.finalSchedule{i, 4} = {};

                NPO = size(postOp,1);% # of postponed operations
                length = NPO;

                if ~isempty(postOp) 
                    postOp = sortrows(postOp, 2);
                end

                %ROOM COUNTERS & OCCUPANCY RATIO CALCULATOR
                room1Count = 1; 
                room1Occupancy = 0;
                room2Count = 1; 
                room2Occupancy = 0;
                room3Count = 1; 
                room3Occupancy = 0;
                %room4Count = 1; 
                %room4Occupancy = 0;
                
                while ~isempty(postOp) && NPO ~= length-3%%-4
                    if NPO == length
                        self.finalSchedule{i, 1, 1} = Operation(postOp{NPO,1}.id, postOp{NPO,1}.patient, postOp{NPO,1}.availableInterval, Interval(room1.left*(room1.left >= postOp{NPO,1}.availableInterval.left) + postOp{NPO,1}.availableInterval.left*(room1.left < postOp{NPO,1}.availableInterval.left), room1.left*(room1.left >= postOp{NPO,1}.availableInterval.left) + postOp{NPO,1}.availableInterval.left*(room1.left < postOp{NPO,1}.availableInterval.left) + postOp{NPO,1}.duration), postOp{NPO,1}.duration, i, 1,operation{a, 1}.patientName,operation{a, 1}.patientSurname);
                        room1.left = room1.left*(room1.left >= postOp{NPO,1}.availableInterval.left) + postOp{NPO,1}.availableInterval.left*(room1.left < postOp{NPO,1}.availableInterval.left) + postOp{NPO,1}.duration+(operation{a,6}-1)*20;
                        room1Count = room1Count+1;
                        room1Occupancy = room1Occupancy + postOp{NPO,1}.duration;
                        
                    elseif NPO == length-1
                        self.finalSchedule{i, 2, 1} = Operation(postOp{NPO,1}.id, postOp{NPO,1}.patient, postOp{NPO,1}.availableInterval, Interval(room2.left*(room2.left>= postOp{NPO,1}.availableInterval.left) + postOp{NPO,1}.availableInterval.left * (room2.left < postOp{NPO,1}.availableInterval.left), room2.left * (room2.left >= postOp{NPO,1}.availableInterval.left) + postOp{NPO,1}.availableInterval.left * (room2.left < postOp{NPO,1}.availableInterval.left) + postOp{NPO,1}.duration), postOp{NPO,1}.duration, i, 2,operation{a, 1}.patientName,operation{a, 1}.patientSurname);
                        room2.left = room2.left * (room2.left >= postOp{NPO,1}.availableInterval.left) + postOp{NPO,1}.availableInterval.left * (room2.left < postOp{NPO,1}.availableInterval.left) + postOp{NPO,1}.duration+(operation{a,6}-1)*20;
                        room2Count = room2Count+1;
                        room2Occupancy = room2Occupancy + postOp{NPO,1}.duration;
                
                    elseif NPO == length-2
                        self.finalSchedule{i, 3, 1} = Operation(postOp{NPO,1}.id, postOp{NPO,1}.patient, postOp{NPO,1}.availableInterval, Interval(room3.left*(room3.left >= postOp{NPO,1}.availableInterval.left) + postOp{NPO,1}.availableInterval.left * (room3.left < postOp{NPO,1}.availableInterval.left), room3.left * (room3.left >= postOp{NPO,1}.availableInterval.left) + postOp{NPO,1}.availableInterval.left * (room3.left < postOp{NPO,1}.availableInterval.left) + postOp{NPO,1}.duration), postOp{NPO,1}.duration, i, 3,operation{a, 1}.patientName,operation{a, 1}.patientSurname);
                        room3.left = room3.left*(room3.left >= postOp{NPO,1}.availableInterval.left) + postOp{NPO,1}.availableInterval.left * (room3.left < postOp{NPO,1}.availableInterval.left) + postOp{NPO,1}.duration+(operation{a,6}-1)*20;
                        room3Count = room3Count + 1;
                        room3Occupancy = room3Occupancy + postOp{NPO,1}.duration;
                    
                    %elseif NPO == length-3
                    %    self.finalSchedule{i, 4, 1} = Operation(postOp{NPO,1}.id, postOp{NPO,1}.patient, postOp{NPO,1}.availableInterval, Interval(room4.left*(room4.left >= postOp{NPO,1}.availableInterval.left) + postOp{NPO,1}.availableInterval.left * (room4.left < postOp{NPO,1}.availableInterval.left), room4.left * (room4.left >= postOp{NPO,1}.availableInterval.left) + postOp{NPO,1}.availableInterval.left * (room3.left < postOp{NPO,1}.availableInterval.left) + postOp{NPO,1}.duration), postOp{NPO,1}.duration, i, 3,operation{a, 1}.patientName,operation{a, 1}.patientSurname);
                    %    room4.left = room4.left * (room4.left >= postOp{NPO,1}.availableInterval.left) + postOp{NPO,1}.availableInterval.left * (room4.left < postOp{NPO,1}.availableInterval.left) + postOp{NPO,1}.duration+(operation{a,6}-1)*20;
                    %    room4Count = room4Count + 1;
                    %    room4Occupancy = room4Occupancy + postOp{NPO,1}.duration;
                    end
                    postOp(NPO,:) = [];
                    NPO = NPO - 1;
                end

                b = 1;
                postOp = {};
                while operation{a, 5} == i && a ~= size(operation, 1)
                    if room1.left * (room1.left >= operation{a, 1}.availableInterval.left) + operation{a, 1}.availableInterval.left * (room1.left < operation{a, 1}.availableInterval.left) + operation{a, 1}.duration <= operation{a, 1}.availableInterval.right
                        self.finalSchedule{i, 1, room1Count} = Operation(operation{a, 1}.id, operation{a, 1}, operation{a, 1}.availableInterval, Interval(room1.left * (room1.left >= operation{a, 1}.availableInterval.left) + operation{a, 1}.availableInterval.left * (room1.left < operation{a, 1}.availableInterval.left), room1.left * (room1.left >= operation{a, 1}.availableInterval.left) + operation{a, 1}.availableInterval.left * (room1.left < operation{a, 1}.availableInterval.left) + operation{a, 1}.duration), operation{a, 1}.duration, i, 1,operation{a, 1}.patientName,operation{a, 1}.patientSurname);
                        room1.left = room1.left * (room1.left >= operation{a, 1}.availableInterval.left) + operation{a, 1}.availableInterval.left * (room1.left < operation{a, 1}.availableInterval.left) + operation{a, 1}.duration+(operation{a,6}-1)*20;
                        room1Count = room1Count + 1;
                        room1Occupancy = room1Occupancy + operation{a, 1}.duration;
                        self.FoVCount = self.FoVCount + 1;
                    elseif room2.left * (room2.left >= operation{a, 1}.availableInterval.left) + operation{a, 1}.availableInterval.left * (room2.left < operation{a, 1}.availableInterval.left) + operation{a, 1}.duration <= operation{a, 1}.availableInterval.right
                        self.finalSchedule{i, 2, room2Count} = Operation(operation{a, 1}.id, operation{a, 1}, operation{a, 1}.availableInterval, Interval(room2.left * (room2.left >= operation{a, 1}.availableInterval.left) + operation{a, 1}.availableInterval.left * (room2.left < operation{a, 1}.availableInterval.left), room2.left * (room2.left >= operation{a, 1}.availableInterval.left) + operation{a, 1}.availableInterval.left * (room2.left < operation{a, 1}.availableInterval.left) + operation{a, 1}.duration), operation{a, 1}.duration, i, 2,operation{a, 1}.patientName,operation{a, 1}.patientSurname);
                        room2.left = room2.left * (room2.left >= operation{a, 1}.availableInterval.left) + operation{a, 1}.availableInterval.left * (room2.left < operation{a, 1}.availableInterval.left) + operation{a, 1}.duration+(operation{a,6}-1)*20;
                        room2Count = room2Count + 1;
                        room2Occupancy = room2Occupancy + operation{a, 1}.duration;
                        self.FoVCount = self.FoVCount + 1;
                    elseif room3.left * (room3.left >= operation{a, 1}.availableInterval.left) + operation{a, 1}.availableInterval.left * (room3.left < operation{a, 1}.availableInterval.left) + operation{a, 1}.duration <= operation{a, 1}.availableInterval.right
                        self.finalSchedule{i, 3, room3Count} = Operation(operation{a, 1}.id, operation{a, 1}, operation{a, 1}.availableInterval, Interval(room3.left * (room3.left >= operation{a, 1}.availableInterval.left) + operation{a, 1}.availableInterval.left * (room3.left < operation{a, 1}.availableInterval.left), room3.left * (room3.left >= operation{a, 1}.availableInterval.left) + operation{a, 1}.availableInterval.left * (room3.left < operation{a, 1}.availableInterval.left) + operation{a, 1}.duration), operation{a, 1}.duration, i, 3,operation{a, 1}.patientName,operation{a, 1}.patientSurname);
                        room3.left = room3.left * (room3.left >= operation{a, 1}.availableInterval.left) + operation{a, 1}.availableInterval.left * (room3.left < operation{a, 1}.availableInterval.left) + operation{a, 1}.duration+(operation{a,6}-1)*20;
                        room3Count = room3Count + 1;
                        room3Occupancy = room3Occupancy + operation{a, 1}.duration;
                        self.FoVCount = self.FoVCount + 1;
                    %elseif room4.left * (room4.left >= operation{a, 1}.availableInterval.left) + operation{a, 1}.availableInterval.left * (room4.left < operation{a, 1}.availableInterval.left) + operation{a, 1}.duration <= operation{a, 1}.availableInterval.right
                    %    self.finalSchedule{i, 4, room4Count} = Operation(operation{a, 1}.id, operation{a, 1}, operation{a, 1}.availableInterval, Interval(room4.left * (room4.left >= operation{a, 1}.availableInterval.left) + operation{a, 1}.availableInterval.left * (room4.left < operation{a, 1}.availableInterval.left), room4.left * (room4.left >= operation{a, 1}.availableInterval.left) + operation{a, 1}.availableInterval.left * (room4.left < operation{a, 1}.availableInterval.left) + operation{a, 1}.duration), operation{a, 1}.duration, i, 4,operation{a, 1}.patientName,operation{a, 1}.patientSurname);
                    %    room4.left = room4.left * (room4.left >= operation{a, 1}.availableInterval.left) + operation{a, 1}.availableInterval.left * (room4.left < operation{a, 1}.availableInterval.left) + operation{a, 1}.duration+(operation{a,6}-1)*20;
                    %    room4Count = room4Count + 1;
                    %    room4Occupancy = room4Occupancy + operation{a, 1}.duration;
                    %    self.FoVCount = self.FoVCount + 1;
                    else
                        self.priPost = [self.priPost operation{a, 1}.patient.getPatientPriority];
                        operation{a, 1}.patient.setPatientDay(i+1)
                        operation{a, 1}.patient.setPatientPriority(0)
                        postOp{b,1} = Operation(operation{a, 1}.id, operation{a, 1}, operation{a, 1}.availableInterval, operation{a, 1}.availableInterval, operation{a, 1}.duration, i+1,0,operation{a, 1}.patientName,operation{a, 1}.patientSurname);
                        postOp{b,1}.setAvailableInterval(Interval(0,operation{a, 1}.duration))
                        postOp{b,1}.setScheduledInterval(Interval(0,operation{a, 1}.duration))
                        postOp{b,2} = operation{a, 1}.duration;
                        b=b+1;
                    end
                    a=a+1;
                end
                self.roomOR = [self.roomOR; [room1Occupancy/480, room2Occupancy/480, room3Occupancy/480]];%, room4Occupancy/480]];
            end
        end

        %PRINT SCHEDULE METHOD PART

        function printSchedule(self,operation)

            %In this part, I resized the properties of the finalSchedule property to better obtain the data that is desired to be written to the excel file. 
            % Otherwise, the output is missing, I couldn't find another way. That's why I found and used the reshape function. 
            % I tried making new cellarrays but everything was messing up. For
            % this reasons, i use reshape.

            OpList = reshape(self.finalSchedule,[],1);
            k = length(OpList);
            i = 1;
            j = 1;
            while i <= k
                if isempty(OpList{j})
                    OpList(j) = [];
                    j = j - 1;
                end
                j = j + 1;
                i = i + 1;
            end

            %I used the id numbers of the patients while printing to Excel. 
            % That's why I assigned the id values to the top empty list.

            for i = 1:length(OpList)
                OpList{i,2} = OpList{i,1}.id;
            end

                OpList = sortrows(OpList, 2);

            RoomNo = [];
            AvailableInterval = {};
            Duration = [];
            ScheduledInterval = {};
            PatientName = {};
            PatientSurname = {};
            PatientPriority = [];
            OperationDay = [];

            for i = 1:length(OpList)
                RoomNo= [RoomNo; OpList{i,1}.operationRoom];
                AvailableInterval{i,1}= "("+num2str(OpList{i,1}.availableInterval.left)+","+num2str(OpList{i,1}.availableInterval.right)+")";
                Duration= [Duration; OpList{i,1}.duration];
                ScheduledInterval{i,1}= "("+num2str(OpList{i,1}.scheduledInterval.left)+","+num2str(OpList{i,1}.scheduledInterval.right)+")";
                PatientName{i,1}= OpList{i,1}.patientName;
                PatientSurname{i,1}= OpList{i,1}.patientSurname;
                PatientPriority= [PatientPriority; operation{i,1}.patient.getPatientPriority];
                OperationDay= [OperationDay; OpList{i,1}.operationDay];
            end

            Tablo = table(RoomNo, AvailableInterval, Duration, ScheduledInterval, PatientName, PatientSurname, PatientPriority, OperationDay);
            writetable(Tablo,"PR_ID2643740.xlsx")

            %GANTT CHARTS (THE MOST HARD PART OF PROJECT(I THINK :) ))
            %Provides gantt charts that output figures for each day and show the operations taking place in each room

            for i = 1:self.planningDays
                figure('Name',"Day "+int2str(i),'NumberTitle','off', 'Color', 'w');
                tl = tiledlayout(self.numberOfRooms,1);
                title(tl, "Day "+int2str(i))
                xlabel(tl, "times (""min"")")
                for j = 1:self.numberOfRooms
                    nexttile
                    hold on
                    title("Room "+int2str(j), 'HorizontalAlignment','left', 'Position', [-60,-70], 'FontSize',10.5,'FontWeight', 'bold')
                    for k = 1:numOperation(self, i, j)
                        fill([self.finalSchedule{i,j,k}.scheduledInterval.left,self.finalSchedule{i,j,k}.scheduledInterval.right,self.finalSchedule{i,j,k}.scheduledInterval.right,self.finalSchedule{i,j,k}.scheduledInterval.left],[-20*k,-20*k,-20*(k-1),-20*(k-1)],"y")
                        plot([self.finalSchedule{i,j,k}.availableInterval.left,self.finalSchedule{i,j,k}.availableInterval.right,self.finalSchedule{i,j,k}.availableInterval.right,self.finalSchedule{i,j,k}.availableInterval.left,self.finalSchedule{i,j,k}.availableInterval.left],[-20*k,-20*k,-20*(k-1),-20*(k-1),-20*k],"LineWidth",1.5,"Color","k")
                        text(self.finalSchedule{i,j,k}.scheduledInterval.left + (self.finalSchedule{i,j,k}.scheduledInterval.right - self.finalSchedule{i,j,k}.scheduledInterval.left)/2, -20*(k-1)-9,"OP "+ int2str(self.finalSchedule{i,j,k}.id), "Color", "black", "FontSize", 12, "HorizontalAlignment", "center", "VerticalAlignment", "middle",'FontWeight', 'bold');
                        hold on
                    end
                    xlim([0,480])
                    xticks(0:20:480)
                    ylim([-140,20])
                    yticks([]);
                end
            end
        end

        %REPORT PART for Term Project Report
        
        %For the desired outputs, I printed the necessary outputs for the result of the operation planning in the Command Window section.

        function Reporting(self)
            fprintf("Objective Function Value = %d\n\n", self.FoVCount)
            %Objective Function Value means that how many operations are scheduled?
            fprintf("Utilization of Rooms:\n")
            fprintf("Days ---> ")
            for i = 1:self.planningDays
                fprintf("%d   ", i); 
            end 
            fprintf("Average \n")
            fprintf("Rooms \n")
            for i = 1:self.numberOfRooms
                fprintf("%d ------>",i) 
                for j = 1:self.planningDays
                    fprintf("%.0f  ", self.roomOR(j,i)*100);
                end
                average = 0;
                for j = 1:self.planningDays 
                    average = average + self.roomOR(j,i)*100; 
                end
                fprintf(" %.0f \n", round(average/5))
            end
            fprintf("Average->")
            for i = 1:self.planningDays
                average = 0;
                for j = 1:self.numberOfRooms
                    average = average + self.roomOR(i,j)*100;
                end
                fprintf("%.0f  ", average/3)%4)
            end
            fprintf("\n\n# of operations shifted in each priority levels:\n")
            fprintf("priority levels # of shifts \n")
            TNofPND = 0;% TOTAL # OF OPERATION POSTPONED TO NEX DAY
            for i = 1:4; fprintf("%d ---> %d \n", i, length(find(self.priPost == i)))
                TNofPND = TNofPND + length(find(self.priPost == i)); 
            end
            fprintf("\n# of operations that postponed to the next day = %d\n\n", TNofPND)
        end

        function  i = numOperation(self, planningDays, numberofRooms)
            i = 0;
            for j = 1:size(self.finalSchedule, 3)
                if isa(self.finalSchedule{planningDays, numberofRooms, j}, "Operation")
                    i = i + 1;
                end
            end
        end
    end
end
