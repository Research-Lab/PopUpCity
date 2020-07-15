% 1Year power simulation for different locations and solar panels
%Last Modified July 2, 2020

%{
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
%}
%% Lookup Table    
    SP = [1 19.64 239 3112.36	375	39.8 9.43 144; 2 19.5	240	3097.15	390	40.21 9.7 72; 3 19.8 315	2655.2	340	34.5 9.86	60;...
        4 19.3 199	2611.81	325	33.65	9.6	120; 5 20.6 435	2677.2	355	36.4	9.76	60; 6 19.57 254	2615.79	330	36	9.18	60;...
       7 18.35 176	3112.36	368	39.2	9.39	144; 8 17.8 146.63	2998.73	345	37.38	9.23	72;9 17.3 138	3096.81	345	38.04	9.07	72];
    % Creates the array with all the key information about each solar panel
    
    SolarPanels = array2table (SP, 'VariableNames',{'Model','Efficiency (%)', 'Cost (USD)', 'Size (in^2)', 'Nominal Max Power (W)',...
        'Operating Voltage (V)', 'Operating Current (A)', 'Number of Cells'}); %Creates a Lookup Table 
    


%% IF statements for the GA
x(8)= randi(9); %for testing
x(7)= randi(50);

disp (x(8));
disp (x(7));

    if x(8)== 1
        solarPower=(((SP(1,2)/100).*SP(1,4).*PV_power.*SP(1,5))/1000)* x(7);
        solarCost= SP(1,3).* x(7);
    elseif x(8)==2
        solarPower=(((SP(2,2)/100).*SP(2,4).*PV_power.*SP(2,5))/1000)* x(7);
        solarCost= SP(2,3).* x(7);
    elseif x(8)==3
        solarPower=(((SP(3,2)/100).*SP(3,4).*PV_power.*SP(3,5))/1000)* x(7);
        solarCost= SP(3,3).* x(7);
    elseif x(8)==4
        solarPower=(((SP(4,2)/100).*SP(4,4).*PV_power.*SP(4,5))/1000)* x(7);
        solarCost= SP(4,3).* x(7);
    elseif x(8)==5
        solarPower=(((SP(5,2)/100).*SP(5,4).*PV_power.*SP(5,5))/1000)* x(7);
        solarCost= SP(5,3).* x(7);
    elseif x(8)==6
        solarPower=(((SP(6,2)/100).*SP(6,4).*PV_power.*SP(6,5))/1000)* x(7);
        solarCost= SP(6,3).* x(7);
    elseif x(8)==7
        solarPower=(((SP(7,2)/100).*SP(7,4).*PV_power.*SP(7,5))/1000)* x(7);
        solarCost= SP(7,3).* x(7);
    elseif x(8)==8
        solarPower=(((SP(8,2)/100).*SP(8,4).*PV_power.*SP(8,5))/1000)* x(7);
        solarCost= SP(8,3).* x(7);
    elseif x(8)==9
        solarPower=(((SP(9,2)/100).*SP(9,4).*PV_power.*SP(9,5))/1000)* x(7); 
        solarCost= SP(9,3).* x(7);
    end