function [Hr_first,Hr_last,HourRange]= hourstuff(presTable)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%find first and last hour for first and last day
Hr_first = presTable(1,2); %get first hour from hour column
Hr_last = presTable(length(presTable),2); %get last hour

%make an array for a day that has all hours 0-23
HourRange = 0:1:23; %an array starting at 0, incrementing by 1, ending at 23
end
