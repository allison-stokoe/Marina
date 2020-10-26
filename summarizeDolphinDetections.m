%creates daily and hourly presence tables based off the Whistle and Moan
%detector from Pamguard sqlite3 database. Raw detection table is also
%exported

%user selects the sqlite3 database to use and code does the rest.

%output is saved to the place where the sqlite3 file is with the same name

%Annamaria DeAngelis
%3/10/2020
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%user selects database
[filename,pathname]= uigetfile('*.sqlite3','Select the PG database');
wmd= readWMD_SQLiteTable(pathname,filename);

Flow= wmd.lowFreq;
Fhigh= wmd.highFreq;

%[y,m,d]= ymd(datetime(wmd.UTC,'InputFormat','yyyy-MM-dd HH:mm:ss.SSS'));
%combine same days
dt= datetime(wmd.UTC,'InputFormat','yyyy-MM-dd HH:mm:ss.SSS');
t= timeofday(dt);
d= datenum(dt-t);

[M,I]= unique(d); %contains all the unique dates and their indices
uniqueDays= cellstr(datestr(M,'yyyy-mm-dd'));

%count the number of detections/day
ndetDaily= zeros(length(I),1)-999;
LFmed= zeros(length(I),1)-999;
HFmed= zeros(length(I),1)-999;

%hourly presence table
hourlyPres= zeros(1,5)-999; %going to append bc can't predict day/hr combination
presCounter= 1;
for i= 2:length(I)
    ndetDaily(i-1)= I(i)-I(i-1);
    rLowvals= Flow(I(i-1):I(i)-1);
    rHighvals= Fhigh(I(i-1):I(i)-1);
    %daily median frequencies
    LFmed(i-1)= median(rLowvals);
    HFmed(i-1)= median(rHighvals);
    
    %get the hours/day
    dtimes= t(I(i-1):I(i)-1);
    [h,~,~]= hms(dtimes);
    [unihours,hindex]= unique(h);
    ndet_hr= zeros(length(unihours),1)-999;
    medHrLow= zeros(length(unihours),1)-999;
    medHrHigh= zeros(length(unihours),1)-999;
    for u= 1:length(unihours)
       ndet_hr(u)= length(find(h==unihours(u))); %# det/hour
       [row,~,~]= find(h==unihours(u));
       medHrLow(u)= median(rLowvals(row));
       medHrHigh(u)= median(rHighvals(row));
    end
    
    %compile hourly into an array
    hourlyPres(presCounter:presCounter+u-1,1)= repmat(M(i-1),u,1);
    hourlyPres(presCounter:presCounter+u-1,2)= unihours;
    hourlyPres(presCounter:presCounter+u-1,3)= ndet_hr;
    hourlyPres(presCounter:presCounter+u-1,4)= medHrLow;
    hourlyPres(presCounter:presCounter+u-1,5)= medHrHigh;
    presCounter= presCounter+u;
end

%do the last chunk manually as loop finishes length(I)-1
ndetDaily(i)= length(wmd.UTC)-I(i)+1;
LFmed(i)= median(Flow(I(i):end));
HFmed(i)= median(Fhigh(I(i):end));

dtimes= t(I(i):end);
[h,~,~]= hms(dtimes);
[unihours,hindex]= unique(h);
ndet_hr= zeros(length(unihours),1)-999;
medHrLow= zeros(length(unihours),1)-999;
medHrHigh= zeros(length(unihours),1)-999;
rLowvals= Flow(I(i):end);
rHighvals= Fhigh(I(i):end);
for u= 1:length(unihours)
    ndet_hr(u)= length(find(h==unihours(u))); %# det/hour
    [row,~,~]= find(h==unihours(u));
    medHrLow(u)= median(rLowvals(row));
    medHrHigh(u)= median(rHighvals(row));
end

hourlyPres(presCounter:presCounter+u-1,1)= repmat(M(i),u,1);
hourlyPres(presCounter:presCounter+u-1,2)= unihours;
hourlyPres(presCounter:presCounter+u-1,3)= ndet_hr;
hourlyPres(presCounter:presCounter+u-1,4)= medHrLow;
hourlyPres(presCounter:presCounter+u-1,5)= medHrHigh;

%table of daily presence
dailyPres= table(uniqueDays,ndetDaily,LFmed,HFmed);
dailyPres.Properties.VariableNames= {'Dates','nDet','MedLowFreq','MedHighFreq'};

%table of hourly presence
dateS= cellstr(datestr(hourlyPres(:,1),'yyyy-mm-dd'));
hourlyPresT= table(dateS,hourlyPres(:,2),hourlyPres(:,3),hourlyPres(:,4),...
    hourlyPres(:,5));
hourlyPresT.Properties.VariableNames= {'Day','Hour','nDet','MedLowFreq','MedHighFreq'};

%print out data to excel file
projectname= strsplit(filename,'.');
writetable(wmd,[char(pathname),char(projectname{1}),'.xlsx'],'Sheet','RawData')
writetable(dailyPres,[char(pathname),char(projectname{1}),'.xlsx'],'Sheet','DailyPres')
writetable(hourlyPresT,[char(pathname),char(projectname{1}),'.xlsx'],'Sheet','HourlyPres')