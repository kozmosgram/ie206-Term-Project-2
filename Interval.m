%Emre Başaran 2643740
classdef Interval < handle
% An Interval has a left endpoint and a right endpoint.
    properties
       left
       right
    end
    
    methods
        function Inter = Interval(lt, rt)
        % Constructor:  construct an Interval object
            Inter.left= lt;
            Inter.right= rt;
        end

        %tf==1 --> True, else: OVERLAP
        function tf = overlap(self, other)
            tf = 0;
            if (other.left <= self.left && self.right <= other.right)||(self.left<=other.right && other.left<=self.right) ||(other.left<=self.right && self.left<= other.right)||(self.left<=other.left && other.right<=self.right) 
                tf = 1;
            end
        end
        
        function w = getWidth(self)
        % Return the width of the Interval
            w = self.right-self.left;
        end

        function scale(self, f)
        % Scale self by a factor f
            w=self.getWidth;
            self.right=self.left +w*f;
        end
        
        function shift(self, s)
        % Shift self by constant s
            self.left = self.left+s;
            self.right = self.right+s;
        end
        
        function tf = isIn(self, other)
        % tf is true (1) if self is in the other Interval
            tf = (self.left>=other.left) && (self.right<= other.right);
        end
        
        function Inter = add(self, other)
        % Inter is the new Interval formed by adding self and the the other Interval
            Inter.left = self.left + other.left;
            Inter.right = self.right + other.right;
        end
        
        function disp(self)
        % Display self, if not empty, in this format: (left,right)If empty, display 'Empty <classname>'
            if isempty(self)
                fprintf('Empty %s\n', class(self))
            else
                fprintf('(%f,%f)\n', self.left, self.right)
            end
        end    
    end %methods   
end %classdef