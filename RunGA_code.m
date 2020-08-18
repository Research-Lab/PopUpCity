%% Run GA Code 

%% Design Variables

%  Design Variable 1 = Antiscalant [None (0), F135 (1), F260(2)]
%x(1)= randi(2); %for testing
%  Design Variable 2 = Rinsing [ NoRinse (0), Rinse (1) ]
%x(2)= randi(2); %for testing
%  Design Variable 3 = continuous variable, length of time before replacing membrane in days
%  Design Variable 4 = Number of Filtration Membranes [1 (1), 2 (2), 3 (3), 4 (4), 5 (5), 6 (6), 7 (7), 8 (8), 9 (9), 10 (10)]
%x(4)= randi(10); %for testing
%  Design Variable 5 = Membrane filtration unit chosen [1 (1), 2 (2), 3 (3), 4 (4)]
%x(5)= randi(4); %for testing
%  Design Variable 6 = Tank size selected
%x(6)= randi(75); %for testing
%  Design Variable 7 = Number of solar panels -->choose battery/energy storage (Continuous)
                      %  such that the beginning increase in power is met, e.g. storage = 0.1*PV_Watt_peak
% Design Variable 8 = Model of Solar Panel
% Design Variable 9 = Model of Wind Turbine [1 (1), 2 (2), 3 (3), 4 (4)]
%x(9)= randi(5); %for testing

%% Optimization

clear;clc;
numberofVariables=9; %# of design variables,

global Energy_sum;
global W;
global solarPower;
global PumpEnergy;
global Kw_init;
global A;
global p;
global p_osm;
global Qf;
global v_rinse;

%% Gather User info

prompt ='Please state geographical location \n';
    loc = input(prompt, 's');

promptcom = 'How many members are in the community? \n '; %Finds out how many members there are. Will be used to calculate water needed and extra power
    comnum = input(promptcom);
    
  promptc = 'Please enter the sodium level in the water in (mg/L) \n'; %User inputs salinity levels
    salinity = input(promptc);
      
    promptb = 'Please enter the amount of dissolved organic content in the water \n'; %User inputs DOC level
          DOC = input(promptb);

waterday = comnum*200; %Number of members in the community * 200L (pop up city) = amount of water needed to be collected per day (in Liters)
%extrapower = comnum*1.5; %Number of members in the community * 1.5kW (pop up city)


%% Read in Solar Data
    % User imput
fprintf ('Please select a solar data excel file \n');
[file,path,indx] = uigetfile('*.xlsx'); %Reads in a user selected excel sheet
if isequal(file,0)
   disp('User selected Cancel') %if user does not select a sheet this is displayed
else %If a user selects an excel sheet it will run through the solar simulation codes to find the hourly power produced in KW/h
  promptc = 'Please enter the column that has the hourly solar data \n';
    c = input(promptc);
    data = xlsread(fullfile(path, file));
    SolarIn = data(:,c);
end
PV_power = SolarIn;
    % Lookup Table for solar panels 
    SP = [1 19.64 239 2.00	375	39.8 9.43 144; 2 19.5	240	1.998	390	40.21 9.7 72; 3 19.8 315	1.713	340	34.5 9.86	60;...
        4 19.3 199	1.685	325	33.65	9.6	120; 5 20.6 435	1.727	355	36.4	9.76	60; 6 19.57 254	1.688	330	36	9.18	60;...
       7 18.35 176	2.00	368	39.2	9.39	144; 8 17.8 146.63	1.935	345	37.38	9.23	72;9 17.3 138	1.998	345	38.04	9.07	72];
    % Creates the array with all the key information about each solar panel
    
    SolarPanels = array2table (SP, 'VariableNames',{'Model','Efficiency (%)', 'Cost (USD)', 'Size (in^2)', 'Nominal Max Power (W)',...
        'Operating Voltage (V)', 'Operating Current (A)', 'Number of Cells'}); %Creates a Lookup Table 
    
    disp (SolarPanels);  %Displays the Lookup Table
   
%% Read in Wind Data 
    % User Inputs the file
fprintf(' Please input the wind data excel file \n');
[file, path, indx] = uigetfile('*.xlsx');
if isequal(file, 0)
    disp('User selected Cancel')   
else 
    promptf = 'Please enter the column which contains the hourly wind data \n';
    prompth = 'If wind data is in km/h, enter 1, or if data is in m/s, enter 2 \n';
    f = input(promptf);
    h = input(prompth);
    data = xlsread(fullfile(path, file));
        if h == 1;
           wind_speed_kmhr = data(:, f); 
           wind_speed = wind_speed_kmhr.*(1000./3600); %meters per second %for 73 days
        elseif h == 2;
            wind_speed = data(:, f);
        end 

end
    % weibull plot
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

    % calculating the power at each wind speed per unit area
rho_air = 1.225; %kg/m^3
Probability_Density_Function = wblpdf(wind_speed_weibull, wb.a, wb.b);
%multiplying the power output by density function representing the period
%of time in the year wind blowing at that speed
Power_per_wind_speed = 0.5.*rho_air.*Probability_Density_Function.*wind_speed_weibull.^3; 
Theoretical_total_power_output = sum(Power_per_wind_speed(:)); %watts/m^2
display(Theoretical_total_power_output/1000, 'Theoretical power output in 73 days (kwatts/m^2)');

    % Lookup table for wind turbines
Windturbines = [1 350 12.5 3.5 0 50 12 3630; 0 1000 12 2.5 25 50 24 9000; 0 3000 12 2.5 25 50 48 10000; 0 5000 12 2.5 25 55 48 11000; 0 0 0 0 0 0 0 0];
WindArray = array2table(Windturbines, 'VariableNames', {'HAWT(1)/VAWT(0)', 'Rated Power (W)', 'Rated Wind Speed (m/s)', ...
    'Cut in speed (m/s)', 'cut out speed (m/s)', 'Survival Wind Speed (m/s)', 'Output Voltage (VDC)', 'Cost ($CAD)'});
%We can add more wind turbines in our array

%% Water tank size and cost lookup table
%Water tanks purchased from: https://www.tank-depot.com/product.aspx?id=3242

 wt = [158.99	0.3758; 230.99	0.6056; 191.00	0.757; 247.00	0.94625; 241.65	1.1355; 356.00	1.32475; 363.00	1.514; 377.99	1.70325; 337.99	1.8925; 369.23	2.08175; 381.00	2.271; 386.78	2.46025; 409.73	2.6495; 517.99	2.83875;...
     624.00	3.028; 629.78	3.21725; 568.00	3.4065; 567.00	3.785; 707.99	3.97425; 557.99	4.1635; 772.20	4.35275; 535.28	4.542; 849.00	4.9205; 755.00	5.10975; 822.25	5.6018; 708.99	5.6775; 682.00	5.86675; 707.99	6.056; 844.00	6.24525; 863.00	6.4345; 979.84	6.62375;...
     1477.00	7.1915; 916.00	7.57; 1397.99	7.75925; 878.99	7.9485; 1102.28	8.327; 1297.99	9.084; 904.00	9.4625; 908.00	9.65175; 978.89	9.841; 1107.00	10.2195; 1157.14	10.598; 1121.00	11.355; 1400.70	11.5821; 1240.65	11.7335; 1417.50	12.112;...
     1997.99	12.869; 1897.43	15.14; 2388.99	15.5185; 2997.99	15.897; 2268.00	17.0325; 3388.99	17.7895; 1948.00	18.925; 2292.99	19.11425; 2499.00	19.3035; 3579.00	22.71; 3658.87	23.65625; 3939.99	24.224; 3197.00	24.6025; 3180.99	24.981; 4997.99	26.495;...
     4498.99	29.33375; 5697.99	29.523; 4971.99	30.28; 6597.99	34.63275; 7597.99	35.9575; 5822.00	37.85; 7158.00	39.7425; 6679.99	41.635; 7549.99	45.42; 9694.99	47.3125; 10882.00	47.3125; 12516.00	56.775; 10468.99	58.6675; 19980.00	75.7];

 watertank = array2table(wt,...
    'VariableNames',{'Cost (USD)', 'Capacity (Kilo Liters)'}); %Lookup table for water tanks

%tank_vol_options = wt(x(6),2); %tank volume options for the design variable
%DailyVol=tank_vol_options;
% penalty function for tanks

%% Filtration Membrane look up tables
  %% RO membrane selection
    
    if salinity > 60 %If it is above 60mg/l then the system will choose an RO membrane from the RO lookup table
       
            membranetable = [1	2.5	40	182	600	45	850	28	0.15 1.4 67; 2	4	14	173	600	45	525	20	0.05 3.2 114; 3	4	21	194	600	45	900	36	0.08 3.2 137; 4	4	40	247	600	45	2625	78	0.15 3.2 130];

            membrane = array2table(membranetable,...
         'VariableNames',{'Option', 'Diameter (in)','Length (in)', 'Cost (USD)', 'Max Pressure (psi)', 'Max Temperature (C)', 'Filtration Rate (GPD)', 'Active Surface Area (Sq. Ft.)', 'Recovery Ratio', 'Feed Rate (m3/h)', 'Membrane Housing Cost (USD)'}); %Lookup table
   
    elseif salinity < 60 %If it is below 60mg/l then the sysetm will choose either an UF or MF membrane
        
        
          promptb = 'Please enter the amount of dissolved organic content in the water \n'; %User inputs DOC level
          DOC = input(promptb);
        
          %DOC = xlsread(fullfile(path,file),DOC:DOC); %Matlab reads the Dissolved organic content value
       
           if DOC < 50 %If it is below 50 then the system will chose a MF membrane from lookup table (this value is not accurate)
               
       
       
                 MF = [1 4	40	397	200	25; 2 4	40	420	200	25];

                    membrane = array2table(MF,...
                   'VariableNames',{'Option', 'Diameter (in)','Length (in)', 'Cost (USD)', 'Max Pressure (psi)', 'Max Temperature (C)', 'Filtration Rate (GPD)', 'Active Surface Area (Sq. Ft.)', 'Recovery Ratio'});

           elseif DOC > 50 %If it is above 50 then the system will chose a UF membrane from lookup table (this value is not accurate)
               
             
            
                 UF = [1 1.8	12	44	150	60; 2 1.8	21	256	150	60; 3 2.5	40	283	150	60];
        
                   membrane = array2table(UF,...
                 'VariableNames',{'Option', 'Diameter (in)','Length (in)', 'Cost (USD)', 'Max Pressure (psi)', 'Max Temperature (C)', 'Filtration Rate (GPD)', 'Active Surface Area (Sq. Ft.)', 'Recovery Ratio'});  
               
           end 
    end

tic 
% global DailyVol;
% global LOWP_Global;

%solarInsdata = load('MexSolarHourlyNSRDB.mat', 'SolarIns');
%PVPower = solarInsdata.SolarIns;
%rng default % for reproducibility

iter=10;

system_life = 25; 
simulation_day=365*system_life;%Number of days for the simulation time
Energy_sum=zeros(simulation_day,24);
x_opt_cf=zeros(10,8);
cost=zeros(1,10);
exitcond=zeros(1,10);
mass_as=zeros(1,10);
LOWP=zeros(1,10);
Qf_mem=zeros(1,10);
BattStor=zeros(1,10);
Min_Cost_manual=zeros(1,iter);
memb_repl=zeros(1,iter);
%x_opt_cf=zeros(3,9,8);
%cost=zeros(3,9);
%exitcond=zeros(3,9);
Fract=0.1;
ps=200;
gen=200;
maxml=365*5;%max membrane life  
x0=[randi(2,ps,1), randi(2,ps,1), randi(maxml,ps,1), randi(10,ps,1), randi(4,ps,1), randi(75,ps,1), randi(50,ps,1), randi(9,ps,1), randi(5,ps,1)];

%x_opt_manual=zeros(iter,9);

FFfit=[ 0.5371,3.752,6.024,-0.027385333];%mid% AC & Rinse
%FFfit=[0.4472,0.6963,2.587,-0.027385333];%low% AC & Rinse
%FFfit=[0.627,6.808,9.46,-0.027385333];%high AC & Rinse

    options = gaoptimset('PopulationSize', ps,'Generations', gen,'EliteCount', 1, ...
        'CrossoverFraction',Fract,...
        'TolFun', 1E-2,'TolCon', 1E-10,'Display','iter','PlotFcns',@gaplotbestf,...
        'InitialPopulation', x0,'PlotFcns',@gaplotbestindiv);
% 'PlotFcns', @gaplotscores

%Oct25 - changed options gaoptimset 'TolFun',1, to 'TolFun',1E-2

    
options_fmincon = optimset;
Penalty_Glob=5;

%for i=1:iter
    
   %DailyVol=5;%m3/day
   sim_yrs=5;
   LOWP_Global=0.01;
    
%    DailyVol=i;
[x_opt_cf,cost,exitcond] = ga(@(x) Cost_Function(x,sim_yrs,LOWP_Global,Penalty_Glob,PV_power,wind_speed, waterday, salinity),numberofVariables,[],[],[],[],[1; 1; 1; 1; 1; 1; 1; 1; 1],[2; 2; maxml; 10; 4; 75; 50; 9; 5],[],[1;2;3;4;5;6;7;8;9],options);     
%[x_opt_cf_ga(i,:),cost_ga(i),exitcond_ga(i)] = ga(@(x) FindCost_PenFun(x,DailyVol,LOWP_Global,Penalty_Glob,PVpower),numberofVariables,[],[],[],[],[1; 1; 1; 1; 1; 1; 1; 1],[2; 2; maxml; 6; 2; 3; 23; 50],[],[1;2;3;4;5;6;7;8],options);
%     save('GA_Oct16_2m3perday_5yrMaxML_variablePop_SimLife10yr_iter.mat');

%   [x_opt_cf_hybrid(i),cost_hybrid(i),exitcond(i)]=fmincon(@(days) FindCost_PenFun_Hybrid(days,x_opt_cf_ga(i,:),DailyVol,LOWP_Global,Penalty_Glob,PVpower),x_opt_cf_ga(i,3),[],[],[],[],0,maxml,[],options_fmincon);
%    x_opt_cf(i,:)=x_opt_cf_ga(i,:);
%    x_opt_cf(i,3)=x_opt_cf_hybrid(i);

%length=maxml-x_opt_cf;
%Cost_manual=zeros(1,length);
%counter=0;
%x_opt_manual=x_opt_cf;

%for k=x_opt_cf:maxml
    
    %counter=counter+1;
    
    %x_opt_manual=k;
    Cost_manual=Cost_Function(x_opt_cf,sim_yrs,LOWP_Global,Penalty_Glob,PV_power,wind_speed, waterday, salinity);
    
%end
%{
Min_Cost_manual(i)=min(Cost_manual);
locate_min=find(Cost_manual==Min_Cost_manual(i));
memb_repl(i)=x_opt_cf(i,3)+locate_min-1;
x_opt_manual(i,3)=memb_repl(i);
%}
[mass_as_used,Water_NotMet,Max_BattStor]=Combined_code(x_opt_cf,FFfit,sim_yrs,W, solarPower, waterday, PumpEnergy,Kw_init,A,p,p_osm, Qf,v_rinse);

%save the workspace
save('GA_Regina_test.mat');



%create new starting vector for optimization
%x0=[randi(2,ps,1), randi(2,ps,1), randi(maxml,ps,1), randi(10,ps,1), randi(4,ps,1), randi(75,ps,1), randi(50,ps,1), randi(10,ps,1), randi(5,ps,1)];

%end
toc
