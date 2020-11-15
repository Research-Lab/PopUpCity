%% Run GA Code 

%% Design Variables

%  Design Variable 1 = Antiscalant [None (0), F135 (1), F260(2)]
%x(1)= randi(2); %for testing
%  Design Variable 2 = Rinsing [NoRinse (1), Rinse (2)]
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
%Design Variable 10 = Number of Wind Turbines [1-10]
%x(10) = randi(10,1); %for testing
%% Optimization

clear;clc;
numberofVariables=10; %# of design variables,

global Energy_sum;
%global W;
%global solarPower;
%global PumpEnergy;
%global Kw_init;
%global A;
%global p;
%global p_osm;
%global Qf;
%global v_rinse;

%% Gather User info
%{
prompt ='Please state geographical location \n';
    loc = input(prompt, 's');

promptcom = 'How many members are in the community? \n '; %Finds out how many members there are. Will be used to calculate water needed and extra power
    comnum = input(promptcom);
    
  promptc = 'Please input the largest molecular weight of the element in the water: (Da) \n'; %User inputs salinity levels
    MWCO = input(promptc);
      
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
       7 18.35 176	2.00	368	39.2	9.39	144; 8 17.8 146.63	1.935	345	37.38	9.23	72;9 17.3 138	1.998	345	38.04	9.07	72; 10 0 0 0 0 0 0 0];
    % Creates the array with all the key information about each solar panel
    
    SolarPanels = array2table (SP, 'VariableNames',{'Model','Efficiency (%)', 'Cost (USD)', 'Size (in^2)', 'Nominal Max Power (W)',...
        'Operating Voltage (V)', 'Operating Current (A)', 'Number of Cells'}); %Creates a Lookup Table 
    
    %disp (SolarPanels);  %Displays the Lookup Table
   
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


Windturbines = [1 350 12.5 3.5 200 50 12 3630; 0 1000 12 2.5 18 50 48 5390; 0 300 10 3 16 50 24 2545; 0 0 0 0 0 0 0 0];
WindArray = array2table(Windturbines, 'VariableNames', {'HAWT(1)/VAWT(0)', 'Rated Power (W)', 'Rated Wind Speed (m/s)', ...
    'Cut in speed (m/s)', 'cut out speed (m/s)', 'Survival Wind Speed (m/s)', 'Output Voltage (VDC)', 'Cost ($CAD)'});
%}
%% Load Woskspace
%load('Australia_workspace')
%% Water tank size and cost lookup table
%Water tanks purchased from: https://www.tank-depot.com/product.aspx?id=3242

wt = [158.99	375.8; 230.99	605.6; 191.00	757; 247.00	946.25; 241.65	1135.5; 356.00	1324.75; 363.00	1514; 377.99	1703.25; 337.99	1892.5; 369.23	2081.75; 381.00	2271; 386.78	2460.25; 409.73	2649.5; 517.99	2838.75;...
        624.00	3028; 629.78	3217.25; 568.00	3406.5; 567.00	3785; 707.99	3974.25; 557.99	4163.5; 772.20	4352.75; 535.28	4542; 849.00	4920.5; 755.00	5109.75; 822.25	5601.8; 708.99	5677.5; 682.00	5866.75; 707.99	6056; 844.00	6245.25; 863.00	6434.5; 979.84	6623.75;...
        1477.00	7191.5; 916.00	7570; 1397.99	7759.25; 878.99	7948.5; 1102.28	8327; 1297.99	9084; 904.00	9462.5; 908.00	9651.75; 978.89	9841; 1107.00	10219.5; 1157.14	10598; 1121.00	11355; 1400.70	11582.1; 1240.65	11733.5; 1417.50	12112;...
        1997.99	12869; 1897.43	15140; 2388.99	15518.5; 2997.99	15897; 2268.00	17032.5; 3388.99	17789.5; 1948.00	18925; 2292.99	19114.25; 2499.00	19303.5; 3579.00	22710; 3658.87	23656.25; 3939.99	24224; 3197.00	24602.5; 3180.99	24981; 4997.99	26495;...
        4498.99	29333.75; 5697.99	29523; 4971.99	30280; 6597.99	34632.75; 7597.99	35957.5; 5822.00	37850; 7158.00	39742.5; 6679.99	41635; 7549.99	45420; 9694.99	47312.5; 10882.00	47312.5; 12516.00	56775; 10468.99	58667.5; 19980.00	75700];
    
 watertank = array2table(wt,...
    'VariableNames',{'Cost (USD)', 'Capacity (Kilo Liters)'}); %Lookup table for water tanks

%tank_vol_options = wt(x(6),2); %tank volume options for the design variable
%DailyVol=tank_vol_options;
% penalty function for tanks

%% Filtration Membrane look up tables
% RO membrane selection
    
if MWCO < 200 %the system will choose an RO membrane from the RO lookup table
       
            membranetable = [1	4	40	294	400	7.25	0.15 9.46 206; 2	2.5	40	216	600	2.6	0.15 3.79 149; 3	4	40	256	600	7.25	0.15 9.46 206; 4	4	40	250	600	0.15 8.33 206];

            RO = array2table(membranetable,...
         'VariableNames',{'Option', 'Diameter (in)','Length (in)', 'Cost (USD)', 'Max Pressure (psi)', 'Active Surface Area (m2)', 'Recovery Ratio', 'Feed Rate (m3/h)', 'Membrane Housing Cost (USD)'}); %Lookup table
       
   
 elseif (200 < MWCO) && (MWCO < 1000) %If it is below 60mg/l then the sysetm will choose either an NF, UF or MF membrane
     
%Nanofiltration
          
        %if DOC < 50 %If it is below 50 then the system will chose a UF membrane from lookup table (this value is not accurate)
            
            membranetable = [1	8	40	805	600	37 0.15	38	587; 2	4	21	177	600	3.34	0.15	3.79	137; 3	4	40	259	600	7.25	0.15	7.6	206; 4	4	40	262	600	7.25	0.15	9.46	206];
             NF = array2table(membranetable,...
                 'VariableNames',{'Option', 'Diameter (in)','Length (in)', 'Cost (USD)', 'Max Pressure (psi)', 'Active Surface Area (m2)', 'Recovery Ratio', 'Feed Rate (m3/h)', 'Membrane Housing Cost (USD)'});
%Ultrafiltration
elseif (1000 < MWCO) && (MWCO < 100000)  
            
            UF = [1 4	21	296	43.5 1.8 0.15 4.41	137; 2 4	21	209	43.5 2.5 0.15 6.14 137; 3 4	40 245 43.5 4 0.15 9.76 206; 4 4 40 249 43.5 6 14.7 206];
        
                   membranetable = array2table(UF,...
                 'VariableNames',{'Option', 'Diameter (in)','Length (in)', 'Cost (USD)', 'Max Pressure (psi)', 'Active Surface Area (m2)', 'Recovery Ratio', 'Feed Rate (m3/h)', 'Membrane Housing Cost (USD)'});
        
%Microfiltration

elseif MWCO > 100000 %If it is above 50 then the system will chose a MF membrane from lookup table (this value is not accurate)
       
                 MF = [1 6.5 85 950 45 50 0.15 6.8 0; 2 8	40	1097 116 35.2 0.15 15 578; 3 8	40	1097 116 35.2 0.15 15 578; 4 8	40	1097 116 35.2 0.15 15 578];

                    membranetable = array2table(MF,...
                   'VariableNames',{'Option', 'Diameter (in)','Length (in)', 'Cost (USD)', 'Max Pressure (psi)', 'Active Surface Area (m2)', 'Recovery Ratio', 'Feed Rate (m3/h)', 'Membrane Housing Cost (USD)'});      
                 
end 


tic 

iter=10;

system_life = 1; 
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
Fract=0.8;
ps=200;
gen=200;
LOWP_Global=0.07;

maxml=365*5;%max membrane life  
x0=[randi(2,ps,1), randi(2,ps,1), randi(maxml,ps,1), randi(300,ps,1), randi(4,ps,1), randi(75,ps,1), randi(100,ps,1), randi(9,ps,1), randi(4,ps,1), randi(10,ps,1)];


FFfit=[ 0.5371,3.752,6.024,-0.027385333];%mid% AC & Rinse
%FFfit=[0.4472,0.6963,2.587,-0.027385333];%low% AC & Rinse
%FFfit=[0.627,6.808,9.46,-0.027385333];%high AC & Rinse

    options = gaoptimset('PopulationSize', ps,'Generations', gen,'EliteCount', 1, ...
        'CrossoverFraction',Fract,...
        'TolFun', 1E-2,'TolCon', 1E-10,'Display','iter','PlotFcns',@gaplotbestf,...
        'InitialPopulation', x0,'PlotFcns',@gaplotbestindiv);

    
options_fmincon = optimset;
Penalty_Glob=5;

   sim_yrs=25;
    
[x_opt_cf,cost,exitcond] = ga(@(x) Simulation_Test(x,sim_yrs,LOWP_Global,Penalty_Glob,PV_power,wind_speed, waterday, MWCO),numberofVariables,[],[],[],[],[1; 1; 1; 1; 1; 1; 1; 1; 1; 1],[2; 2; maxml; 300; 4; 75; 100; 9; 4; 10],[],[1;2;3;4;5;6;7;8;9;10],options);     
%[x_opt_cf_ga(i,:),cost_ga(i),exitcond_ga(i)] = ga(@(x) FindCost_PenFun(x,DailyVol,LOWP_Global,Penalty_Glob,PVpower),numberofVariables,[],[],[],[],[1; 1; 1; 1; 1; 1; 1; 1],[2; 2; maxml; 6; 2; 3; 23; 50],[],[1;2;3;4;5;6;7;8],options);


%save the workspace
save('GA_Australia_LOWP0.07_Fract0.8_ps200_gen200.mat');
%end
toc


