%Emre Başaran 2643740
classdef Operation < handle
    properties
        id
        patient
        availableInterval
        scheduledInterval
        duration
        operationDay
        operationRoom
        patientName
        patientSurname
    end

    methods
        function self = Operation(id,patient, availableInterval,scheduledInterval, duration,operationDay,operationRoom,patientName,patientSurname)
        %CONSTRUCTOR
            for i=1:97
                self.patient = patient;
                self.id = id;
                self.availableInterval = availableInterval;
                self.duration = duration;
                self.operationDay= operationDay;
                self.operationRoom = operationRoom;
                self.scheduledInterval=scheduledInterval;
                self.patientName = patientName;
                self.patientSurname = patientSurname;
            end
        end
    
        function setScheduledInterval(self, scheduledInterval)
            self.scheduledInterval = scheduledInterval;
        end
    
        function setAvailableInterval(self, availableInterval)
            self.availableInterval = availableInterval;
        end
    end
end
