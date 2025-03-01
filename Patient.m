%Emre Başaran 2643740
classdef Patient <handle
    properties
        name
        surname
        priority
        complexity
        day
    end

    methods
        function self = Patient(name, surname, priority, complexity, day)
        %CONSTRUCTOR
            self.name = name;
            self.surname = surname;
            self.priority = priority;
            self.complexity = complexity;
            self.day = day;
        end

        function priority = getPatientPriority(self)
            priority = self.priority;
        end

        function setPatientPriority(self, priority)
            self.priority = priority;
        end

        function complexity = getPatientComplexity(self)
            complexity = self.complexity;
        end
        
        function name = getPatientName(self)
            name = self.name;
        end

        function surname = getPatientSurname(self)
            surname = self.surname;
        end

        function day = getPatientDay(self)
            day = self.day;
        end

        function setPatientDay(self, day)
            self.day = day;
        end
    end
end