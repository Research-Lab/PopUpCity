%Wind Data and Wind Turbine Power output code
%Last Modified June 28, 2020

%clear, close all; clc

%
%% User Inputs the file
fprintf(' Please input the wind data excel file \n');
[file, path, indx] = uigetfile('*.csv');
if isequal(file, 0)
    disp('User selected Cancel')   
else 
    promptf = 'Please enter the column which contains the hourly wind data \n';
    f = input(promptf) - 1;
    data = xlsread(fullfile(path, file));
    wind_speed_kmhr = data(:, f);
%% weibull plot
wind_speed = wind_speed_kmhr.*(1000./3600); %meters per second %for 73 days
wind_speed_weibull = wind_speed(1:1750, 1); 
wb = fitdist(wind_speed_weibull, 'weibull');
disp(wb) 
%If wb.b > 1.8 && wb.b < 2.2
%    fprintf('The Wind data is stable, the code may proceed')
%else
%    fprintf('Exceeded the limit to fluctuation in data, please enter a new set of data')
%end
%figure
%probplot('Weibull',wind_speed_weibull)

%% calculating the power at each wind speed per unit area
rho_air = 1.225; %kg/m^3
Probability_Density_Function = wblpdf(wind_speed_weibull, wb.a, wb.b);
%multiplying the power output by density function representing the period
%of time in the year wind blowing at that speed
Power_per_wind_speed = 0.5.*rho_air.*Probability_Density_Function.*wind_speed_weibull.^3; 
Theoretical_total_power_output = sum(Power_per_wind_speed(:)); %watts/m^2
display(Theoretical_total_power_output/1000, 'Theoretical power output in 73 days (kwatts/m^2)');

%% Lookup table
Windturbines = [1 350 12.5 3.5 0 0 12 3630; 0 1000 12 2.5 25 50 24 9000; 0 3000 12 2.5 25 50 48 10000; 0 5000 12 2.5 25 55 48 11000];
WindArray = array2table(Windturbines, 'VariableNames', {'HAWT(1)/VAWT(0)', 'Rated Power (W)', 'Rated Wind Speed (m/s)', ...
    'Cut in speed (m/s)', 'cut out speed (m/s)', 'Survival Wind Speed (m/s)', 'Output Voltage (VDC)', 'Cost ($CAD)'});
display(WindArray)
%We can add more wind turbines in our array
%

%% Power curves for different wind turbines
x(9)= randi(4); %for testing
%x(10) = Model of WT [Superwind350(1), Mobisun 1kW(2),Mobisun 3kW(3), Mobisun 5kW(4)]
%need to introduce x(13) in the combined
if x(9) == 1 %WT1
    %wind_speed_weibull= 0:0.5:12.5;
    W = (0.1645)*wind_speed.^(3)+(0.2885)*wind_speed.^(2)-1.879*wind_speed+0.0572;
    %Total_power_output = sum(W1)/1000;
    display(sum(W)/1000, 'Total Power obtained using SuperWind350(kW)/year')
    wind_cost = Windturbines(x(9),8);
   
elseif x(9) == 2 %WT2
    W = (0.011)*wind_speed.^(6)-(0.6033)*wind_speed.^(5)+(12.75)*wind_speed.^(4)-(131.99)*wind_speed.^(3)+(702.6)*wind_speed.^(2)-1740.3*wind_speed+1572.6;
    display(sum(W)/1000, 'Total Power obtained using Mobisun 1000kW(kW)/year')
    wind_cost = Windturbines(x(9),8);

elseif x(9) == 3 %WT2
    W = -(0.069)*wind_speed.^(5)+(2.3178)*wind_speed.^(4)-(27.455)*wind_speed.^(3)+(153.8)*wind_speed.^(2)-231.99*wind_speed+37.767;
    display(sum(W)/1000, 'Total Power obtained using Mobisun 3000kW(kW)/year')   
    wind_cost = Windturbines(x(9),8);

elseif x(9) == 4 %WT2
    W = -(0.1141)*wind_speed.^(5)+(3.8867)*wind_speed.^(4)-(46.667)*wind_speed.^(3)+(263.39)*wind_speed.^(2)-402.08*wind_speed+67.197;
    display(sum(W)/1000, 'Total Power obtained using Mobisun 5000kW(kW)/year')   
    wind_cost = Windturbines(x(9),8);
end
%end


