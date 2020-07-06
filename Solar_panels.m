% 1Year power simulation for different locations and solar panels
%Last Modified July 2, 2020

%% User imput
fprintf ('Please select a solar data excel file \n');
[file,path,indx] = uigetfile('*.xlsx'); %Reads in a user selected excel sheet
if isequal(file,0)
   disp('User selected Cancel') %if user does not select a sheet this is displayed
else %If a user selects an excel sheet it will run through the solar simulation codes to find the hourly power produced in KW/h
  promptc = 'Please enter the column that has the hourly solar data \n';
    c = input(promptc);
    data = xlsread(fullfile(path, file));
    SolarIn = data(:,c);

%% Lookup Table    
    SP = [1 19.64 239 3112.36	375	39.8 9.43 144; 2 19.5	240	3097.15	390	40.21 9.7 72; 3 19.8 315	2655.2	340	34.5 9.86	60;...
        4 19.3 199	2611.81	325	33.65	9.6	120; 5 20.6 435	2677.2	355	36.4	9.76	60; 6 19.57 254	2615.79	330	36	9.18	60;...
       7 18.35 176	3112.36	368	39.2	9.39	144; 8 17.8 146.63	2998.73	345	37.38	9.23	72;9 17.3 138	3096.81	345	38.04	9.07	72];
    % Creates the array with all the key information about each solar panel
    
    SolarPanels = array2table (SP, 'VariableNames',{'Model','Efficiency (%)', 'Cost (USD)', 'Size (in^2)', 'Nominal Max Power (W)',...
        'Operating Voltage (V)', 'Operating Current (A)', 'Number of Cells'}); %Creates a Lookup Table 
    
    disp (SolarPanels);  %Displays the Lookup Table
%% Power in KW/h for 1 h so KW for each panel for a year
       pp1 =((SP(1,2)/100).*SP(1,4).*SolarIn.*SP(1,5))/1000; %Efficiency*Max Power*Hourly Solar Data*size KW https://www.solaris-shop.com/canadian-solar-biku-cs3u-375-mb-ag-375w-bifacial-mono-solar-panel/
       pp2 =((SP(2,2)/100).*SP(2,4).*SolarIn.*SP(2,5))/1000; %Efficiency*Max Power*Hourly Solar Data*size KW https://www.solaris-shop.com/ja-solar-jam72s09-390-pr-390w-mono-solar-panel/
       pp3 =((SP(3,2)/100).*SP(3,4).*SolarIn.*SP(2,5))/1000; %Efficiency*Max Power*Hourly Solar Data*size KW https://www.solaris-shop.com/lg-neon2-lg340n1c-v5-340w-mono-solar-panel/
       pp4 =((SP(4,2)/100).*SP(4,4).*SolarIn.*SP(2,5))/1000; %Efficiency*Max Power*Hourly Solar Data*size KW https://www.solaris-shop.com/hanwha-q-cells-q-peak-duo-g5-325-325w-mono-solar-panel/
       pp5 =((SP(5,2)/100).*SP(5,4).*SolarIn.*SP(2,5))/1000; %Efficiency*Max Power*Hourly Solar Data*size KW https://www.solaris-shop.com/lg-neon2-r-prime-lg355q1k-v5-355w-mono-solar-panel/
       pp6 =((SP(6,2)/100).*SP(6,4).*SolarIn.*SP(2,5))/1000; %Efficiency*Max Power*Hourly Solar Data*size KW https://www.solaris-shop.com/canadian-solar-hidm-black-cs1h-330ms-330w-mono-solar-panel/
       pp7 =((SP(7,2)/100).*SP(7,4).*SolarIn.*SP(2,5))/1000; %Efficiency*Max Power*Hourly Solar Data*size KW https://www.acosolar.com/canadian-solar-350-solar-panel-biku-cs3u-350-pb-ag-bifacial-poly-144cells-frame.html
       pp8 =((SP(8,2)/100).*SP(8,4).*SolarIn.*SP(2,5))/1000; %Efficiency*Max Power*Hourly Solar Data*size KW https://www.acosolar.com/astronergy-astrohalo-345w-solar-panel-chsm6612p-345wp-poly-silver-frame.html
       pp9 =((SP(9,2)/100).*SP(9,4).*SolarIn.*SP(2,5))/1000; %Efficiency*Max Power*Hourly Solar Data*size KW https://www.acosolar.com/ja-solar-345w-solar-panel-jap72s09-345-sc-72cells-poly-silver-frame.html          

%% IF statements for the GA
x(12)= randi(9); %for testing
x(11)= randi(50);

disp (x(12));
disp (x(11));

    if x(12)== 1
        solarPower=pp1* x(11);
    elseif x(12)==2
        solarPower=pp2* x(11);
    elseif x(12)==3
        solarPower=pp3* x(11);
    elseif x(12)==4
        solarPower=pp4* x(11);
    elseif x(12)==5
        solarPower=pp5* x(11);
    elseif x(12)==6
        solarPower=pp6* x(11);
    elseif x(12)==7
        solarPower=pp7* x(11);
    elseif x(12)==8
        solarPower=pp8* x(11);
    elseif x(12)==9
        solarPower=pp9* x(11);   
    end

end