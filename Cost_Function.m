%Cost Function 
%Neeha Rahman + Hannah Yorke Gambhir + Melina Tahami
%Last Updated: June 24, 2020

%% Gather User info

prompt ='Please state geographical location \n';
    loc = input(prompt, 's');

promptcom = 'How many members are in the community? \n '; %Finds out how many members there are. Will be used to calculate water needed and extra power
    comnum = input(promptcom);

water_demand = comnum*200*0.264; %Number of members in the community * 200L (pop up city) = amount of water needed to be collected per day (in Gallons)
%extrapower = comnum*1.5; %Number of members in the community * 1.5kW (pop up city)

promptenergy = 'Would you prefer to generate engery through wind power [1], solar power [2] or both [3]? \n';
    engery = input(promptenergy);
    
%% Solar Panel Code

run('Solar_panels');

%% Wind code


%% Water tank size and cost
%Water tanks purchased from: https://www.tank-depot.com/product.aspx?id=3242
%For larger communities - make the assumption that at least 50% of the water required for the whole community is on hand

 wt = [158.99	100.00; 167.99	105.00; 177.99	110.00; 176.00	120.00; 187.99	130; 207.99	135; 230.99	160; 189.00	165; 207.99	175; 207.99	180; 191.00	200; 225.99	205; 237.99	210; 197.00	220; 287.99	225;...
     297.99	230; 247.00	250; 241.65	300; 226.00	305; 377.99	310; 332.00	325; 307.99	330; 356.00	350; 363.00	400; 377.99	405; 397.99	420; 397.99	425; 867.99	430; 377.99	450; 337.99	500; 457.99	505; 397.99	525; 369.23	550;...
     381.00	600; 417.99	625; 386.78	650; 508.99	660; 409.73	700; 517.99	750; 624.00	800; 517.99	825; 629.78	850; 621.99	865; 648.90	870; 568.00	900; 567.00	1000; 617.99 1025; 707.99 1050; 549.00	1075; 557.99	1100; 772.20 1150;...
     535.28	1200; 849.00 1300; 765.99 1320; 755.00	1350; 822.25	1480; 708.99	1500; 660.00	1525; 682.00	1550; 707.99	1600; 844.00	1650; 889.92	1680; 863.00	1700; 930.71	1720; 979.84	1750; 1477.00	1900; 916.00	2000;...
     1397.99	2050; 878.99	2100; 1102.28	2200; 1297.99	2400; 904.00	2500; 908.00	2550; 978.89	2600; 1107.00	2700; 1129.09	2710; 1157.14	2800; 1375.99	2825; 1121.00	3000; 1400.70	3060; 1240.65	3100; 1417.50	3200;...
     1997.99	3400; 1897.43	4000; 2388.99	4100; 2997.99	4200; 2268.00	4500; 3388.99	4700; 2066.99	4995; 1948.00	5000; 2292.99	5050; 2499.00	5100; 4097.99	5150; 3579.00	6000; 3337.20	6011; 3658.87	6250; 3939.99	6400; 3197.00	6500;...
     3180.99	6600; 4997.99	7000; 4277.18	7011; 4498.99	7750; 5697.99	7800; 4971.99	8000; 6597.99	9150; 7597.99	9500; 5822.00	10000; 7158.00	10500; 6679.99	11000; 7549.99	12000; 9694.99	12500; 10882.00	12500; 12516.00	15000; 10468.99	15500; 19980.00	20000];

 watertank = array2table(wt,...
    'VariableNames',{'Cost (USD)', 'Capacity (Gallons)'}); %Lookup table for water tanks

watertank_selected = watertank(:,2);
watertank_cost = watertank(:,1);


%% Water Filtration + Motor & Pump selection
    %RO membranes from: https://www.wateranywhere.com/membranes/filmtec-dow-ro-membranes/dow-filmtec-commercial-ro-membranes/?p=1
    %UF membranes from: https://www.wateranywhere.com/membranes/ultrafiltration-uf-membranes/polyethersulfone-uf-membranes/
    %MF membranes from: https://www.wateranywhere.com/membranes/microfiltration-mf-membranes/pvdf-microfiltration-membranes/
    %Pump from: https://www.hydra-cell.com/product/H25-hydracell-pump.html
    %Motor from: https://www.globalindustrial.ca/g/motors/ac-motors-definite-purpose/pump-motors/baldor-3-phase-pump-motors
    %UV Purifier from: https://www.freshwatersystems.com/collections/uv-water-purification?refinementList%5Bnamed_tags.System%20Class%5D%5B0%5D=Commercial%20Systems

%{
fprintf ('Please attach water quality data \n');
[file,path,indx] = uigetfile('*.xlsx'); %Reads in a user selected excel sheet
if isequal(file,0)
   disp('User selected Cancel') %if user does not select a sheet this is displayed

else %If a user selects an excel sheet it will run through the following code
%}
  
    promptc = 'Please enter the salinity level in the water in (mg/L) \n'; %User inputs salinity levels
    salinity = input(promptc);
    
    
  % salinity = xlsread(fullfile(path,file),c:c); %Matlab reads the value in that cell
  
   %% RO membrane selection
    
    if salinity >= 60 %If it is above 60mg/l then the system will choose an RO membrane from the RO lookup table
       
            RO = [2.5	14	138	600	45	200; 2.5	21	192	600	45	325; 2.5 21	185	600	45	365; 2.5	40	182	600	45	850; 2.5	40	203	600	45	1000;...
                4	14	173	600	45	525; 4	21	194	600	45	900; 4	21	305	600	45	1025; 4	40	247	600	45	2625; 4	40	247	600	45	2500;...
                4	40	232	600	45	2400; 4	40	247	600	45	2900];

            membraneRO = array2table(RO,...
         'VariableNames',{'Diameter (in)','Length (in)', 'Cost (USD)', 'Max Pressure (psi)', 'Max Temperature (C)', 'Filtration Rate (GPD)'}); %Lookup table

      membrane_selected = membraneRO(:,6);
      membrane_cost = membraneRO(:,3);
     %Filter = membraneRO(cat(2,membraneRO{:,6}) > 'wateramountday',:) %The chosen filter is dependant on the filtration rate and amount of water needed for the community and extracts that row from the lookup table
        %RO_selected = RO(:,6);
        %RO_selected
        %% UV purification unit
        
        uv_cost = 94;
        
        %% Motor and Pump Selection for RO membrane
         pm = [1 500 69 2737 230 35.4; 2	500	63	2737 230 35.4; 3	500	50	1835 230 12.5; 4	500	36	1695 230 9.6];

        pumpmotor_table = array2table(pm,...
         'VariableNames',{'Option','Pump Cost (USD)', 'Pump Capacity (L/min)', 'Motor Cost (USD)', 'Voltage', 'FL AMPS'}); %Lookup table for pump and motor
       
   
   %% UF, MF or NF membrane selection 
    else salinity < 60 %If it is below 60mg/l then the sysetm will choose either an UF or MF membrane
        
          promptb = 'Please enter the amount of dissolved organic content in the water \n'; %User inputs DOC level
          DOC = input(promptb);
        
          %DOC = xlsread(fullfile(path,file),DOC:DOC); %Matlab reads the Dissolved organic content value
       
           if DOC <= 50 %If it is below 50 then the system will chose a MF membrane from lookup table (this value is not accurate)
       
                 MF = [4	40	397	200	25; 4	40	420	200	25];

                    membraneMF = array2table(MF,...
                   'VariableNames',{'Diameter','Length', 'Cost', 'Max Pressure', 'Max Temperature'});

           else DOC > 50 %If it is above 50 then the system will chose a UF membrane from lookup table (this value is not accurate)
            
                 UF = [1.8	12	44	150	60; 1.8	21	256	150	60; 2.5	40	283	150	60];
        
                   membraneUF = array2table(UF,...
                 'VariableNames',{'Diameter','Length', 'Cost', 'Max Pressure', 'Max Temperature'});  
           end 
   end

%% Battery Storage

%% Balance of System Costs

%BOC = 0.12*'CC'; 

%% Final Cost  

%final_cost = membrane_cost + watertank_cost + 




