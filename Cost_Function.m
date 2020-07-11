%Cost Function 
%Neeha Rahman + Hannah Yorke Gambhir + Melina Tahami
%Last Updated: July 9, 2020

function PVRO_PenaltyCost=Cost_Function(x,sim_life,LOWP_Global,Penalty_Glob,solarPower)

%% Design Variables
%  Design Variable 1 = Antiscalant [None (0), F135 (1), F260(2)]
x(1)= randi(2); %for testing
%  Design Variable 2 = Rinsing [ NoRinse (0), Rinse (1) ]
x(2)= randi(2); %for testing
%  Design Variable 3 = continuous variable, length of time before replacing membrane in days
%  Design Variable 4 = Number of Filtration Membranes [1 (1), 2 (2), 3 (3), 4 (4), 5 (5), 6 (6), 7 (7), 8 (8), 9 (9), 10 (10)]
x(4)= randi(10); %for testing
%  Design Variable 5 = Membrane filtration rate [1 (1), 2 (2), 3 (3), 4 (4)]
x(5)= randi(4); %for testing
%  Design Variable 6 = Tank size selected
x(6)= randi(75); %for testing

%% Gather User info

prompt ='Please state geographical location \n';
    loc = input(prompt, 's');

promptcom = 'How many members are in the community? \n '; %Finds out how many members there are. Will be used to calculate water needed and extra power
    comnum = input(promptcom);

water_demand = comnum*200*0.264; %Number of members in the community * 200L (pop up city) = amount of water needed to be collected per day (in Gallons)
%extrapower = comnum*1.5; %Number of members in the community * 1.5kW (pop up city)
    
%% Solar Panel Code

run('Solar_panels');

%% Wind code

run('V6');

%% Simulation
%sim_life=10; %Number of years for the simulation time
DailyVol=10;
%{
global PVpower;
global DailyVol;
global LOWP_Global;
global Penalty_Glob;


% Read in Solar Data
solarInsdata = load('MexSolarHourlyNSRDB.mat', 'SolarIns');
 PVpower = solarInsdata.SolarIns;
%}
%{
 y = a*exp(b/(c+x))
Case 1
      f(x) = a*exp(b/(x+c))
Coefficients (with 95% confidence bounds):
       a =      0.5371  (0.4472, 0.627)
       b =       3.752  (0.6963, 6.808)
       c =       6.024  (2.587, 9.46)

 d=-0.027385333

Case 2
Coefficients (with 95% confidence bounds):
       a =     0.06281  (-0.5655, 0.6911)
       b =        19.7  (-140.8, 180.2)
       c =       6.087  (-26.37, 38.54)

 d=-0.04183
 
Case 3
Coefficients (with 95% confidence bounds):
       a =    0.004807  (-0.5139, 0.5235)
       b =       46.23  (-2044, 2137)
       c =       7.668  (-209.6, 224.9)

 d= -0.042196
%} 
 
if (x(1)==1 && x(2)==1) || (x(1)==1 && x(2)==2)
    %for case 3 (AS=None & No Rinsing)
    fit=[0.004807,46.23,7.668,-0.042196];
    
elseif x(1)==2 && x(2)==1
    %for case 2 (AS=F135 & No Rinsing)
    fit=[0.06281,19.7,6.087,-0.04183];
    
elseif x(1)==2 && x(2)==2
    %for case 1 (AS=F135 & Rinsing)
    %fit=[0.4472,0.6963,2.587,-0.027385333];%low
    fit=[0.5371,3.752,6.024,-0.027385333];%med
    %fit=[0.627,6.808,9.46,-0.027385333];%high
end
    
[mass_as_used,Water_NotMetLOWP,Qf_sys,BattStor]=Combined_code(x,fit,sim_life,solarPower);

%% Energy System

%Balance of System Costs
% BOS_structural=(0.12*Wdc) %racking etc.
% BOS_electrical=0.27*Wdc % Wholesale prices for conductors, switches,
% combiners and transition boxes, as well as conduit, grounding equipment,
% monitoring system or production meters, fuses, and breakers
% 
% http://www.nrel.gov/docs/fy16osti/66532.pdf -- page 14

PV.BOS.CC=(0.12*(280)+0.27*280)*x(8);

%Battery Capital Costs
PV.Batt.CC=BattStor*80; %Advanced Lead Acid Battery Storage is about $80/kWh in 2015 http://www.sciencedirect.com.myaccess.library.utoronto.ca/science/article/pii/B9780444637000000210 

%Battery Replacement Costs
%Assumed every 5 yrs based on 40,000 cycles to failure
%conservative estimate some recent studies have shown they can last much
%longer... ref?
idisc=0.12;%discount rate
PV_repl_prev=0;
for i=5:5:20
   PV.Batt.ReplCost= PV.Batt.CC/((1+idisc)^i)+PV_repl_prev;
   PV_repl_prev=PV.Batt.ReplCost;
end

%% Water tank size and cost
%Water tanks purchased from: https://www.tank-depot.com/product.aspx?id=3242
%For larger communities - make the assumption that at least 50% of the water required for the whole community is on hand

 wt = [158.99	100.00; 230.99	160; 191.00	200; 247.00	250; 241.65	300; 356.00	350; 363.00	400; 377.99	450; 337.99	500; 369.23	550; 381.00	600; 386.78	650; 409.73	700; 517.99	750; 624.00	800;...
     629.78	850; 568.00	900; 567.00	1000; 707.99	1050; 557.99	1100; 772.20	1150; 535.28	1200; 849.00	1300; 755.00	1350; 822.25	1480; 708.99	1500; 682.00	1550; 707.99	1600; 844.00 1650;...
     863.00	1700; 979.84	1750; 1477.00	1900; 916.00	2000; 1397.99	2050; 878.99	2100; 1102.28	2200; 1297.99	2400; 904.00	2500; 908.00 2550; 978.89 2600; 1107.00	2700; 1157.14	2800; 1121.00	3000; 1400.70	3060; 1240.65	3100;...
     1417.50	3200; 1997.99	3400; 1897.43	4000; 2388.99	4100; 2997.99	4200; 2268.00	4500; 3388.99	4700; 1948.00	5000; 2292.99	5050; 2499.00	5100; 3579.00	6000; 3658.87	6250; 3939.99	6400; 3197.00	6500; 3180.99	6600;...
     4997.99	7000; 4498.99	7750; 5697.99	7800; 4971.99	8000; 6597.99	9150; 7597.99	9500; 5822.00	10000; 7158.00	10500; 6679.99	11000; 7549.99	12000; 9694.99	12500; 10882.00	12500; 12516.00	15000; 10468.99	15500; 19980.00	20000];

 watertank = array2table(wt,...
    'VariableNames',{'Cost (USD)', 'Capacity (Gallons)'}); %Lookup table for water tanks

%watertank_selected = watertank(x(7),2);
PresVes.CCTank = wt(x(7),1);


%% Water Filtration + Motor & Pump selection
    %RO membranes from: https://www.wateranywhere.com/membranes/filmtec-dow-ro-membranes/dow-filmtec-commercial-ro-membranes/?p=1
    %UF membranes from: https://www.wateranywhere.com/membranes/ultrafiltration-uf-membranes/polyethersulfone-uf-membranes/
    %MF membranes from: https://www.wateranywhere.com/membranes/microfiltration-mf-membranes/pvdf-microfiltration-membranes/
    %Membrane housing from: https://www.wateranywhere.com/catalogsearch/result/?q=membrane+housing
    %Pump from: https://www.hydra-cell.com/product/H25-hydracell-pump.html
    %Motor from: https://www.globalindustrial.ca/g/motors/ac-motors-definite-purpose/pump-motors/baldor-3-phase-pump-motors
    %UV Purifier from: https://www.freshwatersystems.com/collections/uv-water-purification?refinementList%5Bnamed_tags.System%20Class%5D%5B0%5D=Commercial%20Systems

    %% 
    promptc = 'Please enter the sodium level in the water in (mg/L) \n'; %User inputs salinity levels
    salinity = input(promptc);
    
   %% RO membrane selection
    
    if salinity >= 60 %If it is above 60mg/l then the system will choose an RO membrane from the RO lookup table
       
            membranetable = [1	2.5	40	182	600	45	850	28	0.15 1.4 67; 2	4	14	173	600	45	525	20	0.05 3.2 114; 3	4	21	194	600	45	900	36	0.08 3.2 137; 4	4	40	247	600	45	2625	78	0.15 3.2 130];

            membrane = array2table(membranetable,...
         'VariableNames',{'Option', 'Diameter (in)','Length (in)', 'Cost (USD)', 'Max Pressure (psi)', 'Max Temperature (C)', 'Filtration Rate (GPD)', 'Active Surface Area (Sq. Ft.)', 'Recovery Ratio', 'Feed Rate (m3/h)', 'Membrane Housing Cost (USD)'}); %Lookup table
            
            PresVes.CCmemb = membranetable(x(5),4).*x(4);
            PresVes.PresVes = membranetable(x(5),11).*x(4); 
            
      
    
     %Filter = membraneRO(cat(2,membraneRO{:,6}) > 'wateramountday',:) %The chosen filter is dependant on the filtration rate and amount of water needed for the community and extracts that row from the lookup table
        %RO_selected = RO(:,6);
        %RO_selected
        
        %% UV purification unit
        
        PresVes.CCuv = 94; %https://www.freshwatersystems.com/products/polaris-uva-2c-ultraviolet-disinfection-system-2-gpm
        uv_power = (14/1000); %KW
        
        %% Motor and Pump Selection for RO membrane
        % pm = [1 500 69 2737 230 35.4; 2	500	63	2737 230 35.4; 3	500	50	1835 230 12.5; 4	500	36	1695 230 9.6];

      %  pumpmotor_table = array2table(pm,...
        % 'VariableNames',{'Option','Pump Cost (USD)', 'Pump Capacity (L/min)', 'Motor Cost (USD)', 'Voltage', 'FL AMPS'}); %Lookup table for pump and motor
      
       PresVes.CCmotor = 1695; %https://www.globalindustrial.ca/p/motors/ac-motors-definite-purpose/pump-motors/baldor-motor-vejmm3311t-7-5-hp-1770-rpm
       PresVes.motorReplRate=0.1;% [93] Amy's thesis
       PumpEnergy = (7.5*0.7457)/0.917; %3-phase power calculation in KW: P = hp*(0.7457/FL efficiency) From: https://www.energy.gov/sites/prod/files/2014/04/f15/10097517.pdf
       PresVes.CCpump = 500; %Value not accurate
       PresVes.pumpReplRate=0.1;% [93] Amy's thesis
       
   
   %% UF, MF or NF membrane selection 
    elseif salinity < 60 %If it is below 60mg/l then the sysetm will choose either an UF or MF membrane
        
        
          promptb = 'Please enter the amount of dissolved organic content in the water \n'; %User inputs DOC level
          DOC = input(promptb);
        
          %DOC = xlsread(fullfile(path,file),DOC:DOC); %Matlab reads the Dissolved organic content value
       
           if DOC <= 50 %If it is below 50 then the system will chose a MF membrane from lookup table (this value is not accurate)
               
       
       
                 MF = [1 4	40	397	200	25; 2 4	40	420	200	25];

                    membrane = array2table(MF,...
                   'VariableNames',{'Option', 'Diameter (in)','Length (in)', 'Cost (USD)', 'Max Pressure (psi)', 'Max Temperature (C)', 'Filtration Rate (GPD)', 'Active Surface Area (Sq. Ft.)', 'Recovery Ratio'});

           elseif DOC > 50 %If it is above 50 then the system will chose a UF membrane from lookup table (this value is not accurate)
               
             
            
                 UF = [1 1.8	12	44	150	60; 2 1.8	21	256	150	60; 3 2.5	40	283	150	60];
        
                   membrane = array2table(UF,...
                 'VariableNames',{'Option', 'Diameter (in)','Length (in)', 'Cost (USD)', 'Max Pressure (psi)', 'Max Temperature (C)', 'Filtration Rate (GPD)', 'Active Surface Area (Sq. Ft.)', 'Recovery Ratio'});  
               
           end 
    end


%% Filter and Filter Cartridge
PresVes.CC_Filter=20+65.54;
%Filter: http://www.wateranywhere.com/product_info.php?products_id=10168
%($20 USD)
%Housing:
%https://www.aquatell.ca/products/standard-water-filter-housing-kit-20-blue
%($65.54 USD)
PresVes.FilterCost=20;
PresVes.FilterReplRate=1/12; %once every month

%% Anti-scalant Delivery System
if x(1)==1 %design variable 1, Anti-scalant selection = No Antiscalant
    PresVes.CC_anti_sc=0;
    
elseif x(1)==2 || x(1)==3 %design variable 1, Using Anti-scalant
    PresVes.CC_anti_sc=42.51+14.99; 
    % peristaltic pump cost (42.51 USD) & small anti-scalant tank (14.78)
    % http://www.williamson-shop.co.uk/100-series-with-dc-powered-motors-3586-p.asp
    % 20L container http://www.canadiantire.ca/en/pdp/reliance-rectangular-aqua-pak-water-container-0854035p.html#srp
end

PresVes.CC_components=PresVes.CCmemb+PresVes.PresVes+PresVes.CCpump+PresVes.CCmotor+PresVes.CC_Filter+PresVes.CC_anti_sc+PresVes.CCTank;

%Balance of System (piping, valves, filter housings)
PresVes.CCpipes=0.1*PresVes.CC_components; %assumed from Amy's thesis

PresVes.CCpostchems=0.03*PresVes.CC_components;% post-treatment water re-mineralizing costs [102] Amy's Thesis
PresVes.postchemsReplRate=0.1;%assumed pg.99 Amy's thesis

%%Anualized costs since easier to add them up after... pg. 97-99 

%% Operating Costs


% vol_w is in m3
% vol_as is in mL

%  $/mL of anti-scalant (Flocon 135  $1.60/lb, Flocon 260 $2.10/lb)
% Flocon 135 = $1.6/(1/2.20462262185*1000) = $0.00352739619496/g
% Flocon 135 density = 1.165±0.035 g/cm3 
% MSDS 1.13-1.2 g/cm3
% http://www.wateranywhere.com/product_info.php?products_id=9025

% Flocon 260 = $2.1/lb = $2.1/(1/2.20462262185*1000) = $ 0.004629708/g
% Flocon 260 density = 1.35±0.05 g/cm3 
% alibaba= http://www.chinaseniorsupplier.com/Chemicals/Water_Treatment/1619871336/Flocon260_BWA_antiscalant.html

% Rinsing is not assigned a cost b/c it is embedded in ‘cost/unit water’ 
% if you use water to rinse you will be producing less water overall

% Annualized cost of anti-scalant since will assume that the total
% mass_as_used over the simulation time of 25 years will be on average
% the cost per year
    
if x(1)==1 || x(1)==2 %if no antiscalant x(1)=0 then mass_as_used=0)
    PresVes.Cost_as= (mass_as_used  *1.165 * 0.00352739619496)/sim_life; %Cost of Flocon 135
    % Cost_as= mass_as_used * (1.165) * 0.00352739619496; %Cost of Flocon 135
    
else
    PresVes.Cost_as= (mass_as_used * 1.35 * 0.004629708)/sim_life; %Cost of Flocon 260
    % Cost_as= mass_as_used * 1.35 * 0.004629708; %Cost of Flocon 260
end

%% Annualized Replacement costs
disc_rate=0.12; % discount rate of 12% from http://heep.hks.harvard.edu/files/heep/files/dp35_meeks.pdf
system_life=25; %25 years
Equiv_Ann_cost_factor=(disc_rate*(1+disc_rate)^system_life)/(((1+disc_rate)^system_life)-1);
PresVes.AnnCostsRepl=PresVes.CCmemb*PresVes.membReplRate+PresVes.FilterCost*PresVes.FilterReplRate+PresVes.CCpump*PresVes.pumpReplRate+PresVes.CCmotor*PresVes.motorReplRate+PresVes.CCpostchems*PresVes.postchemsReplRate;

PV.AnnCost=(PV.Array.CC+PV.BOS.CC+PV.Batt.CC+PV.Batt.ReplCost)*Equiv_Ann_cost_factor;

PresVes.AnnCostCC=(PresVes.CCmemb+PresVes.PresVes+PresVes.CCpump+PresVes.CCmotor+PresVes.CC_Filter+PresVes.CC_anti_sc+PresVes.CCTank+PresVes.CCpipes)*Equiv_Ann_cost_factor;

PVRO.AnnTotal=PV.AnnCost+PresVes.AnnCostCC+PresVes.AnnCostsRepl+PresVes.Cost_as;

PVRO_PenaltyCost=(PVRO.AnnTotal)+(10^Penalty_Glob)*max(0,(Water_NotMetLOWP-LOWP_Global));



