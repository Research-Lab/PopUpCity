%Cost Function 
%Neeha Rahman + Hannah Yorke Gambhir + Melina Tahami
%Last Updated: July 9, 2020

function PVRO_PenaltyCost=Cost_Function(x,sim_life,LOWP_Global,Penalty_Glob, PV_power, wind_speed, waterday, salinity)

%% Design Variables
%  Design Variable 1 = Antiscalant [None (3), F135 (1), F260(2)]
%x(1)= randi(2); %for testing
%  Design Variable 2 = Rinsing [ NoRinse (0), Rinse (1) ]
%x(2)= randi(2); %for testing
%  Design Variable 3 = continuous variable, length of time before replacing membrane in days
%  Design Variable 4 = Number of Filtration Membranes [1 (1), 2 (2), 3 (3), 4 (4), 5 (5), 6 (6), 7 (7), 8 (8), 9 (9), 10 (10)]
%x(4)= randi(10); %for testing
%  Design Variable 5 = Membrane filtration rate [1 (1), 2 (2), 3 (3), 4 (4)]
%x(5)= randi(4); %for testing
%  Design Variable 6 = Tank size selected
%x(6)= randi(75); %for testing

%% Simulation
sim_life=10; %Number of years for the simulation time
%global tank_vol_options;

%DailyVol=10;
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


%[mass_as_used,Water_NotMet,Qf_memb,Max_BattStor, wind_speed, PV_power]=Combined_code(x,fit,sim_life,Energy_sum, W,solarPower);

%% Solar Panel Code

%run('Solar_panels');

    % Lookup Table for solar panels
    SP = [1 19.64 239 3112.36	375	39.8 9.43 144; 2 19.5	240	3097.15	390	40.21 9.7 72; 3 19.8 315	2655.2	340	34.5 9.86	60;...
        4 19.3 199	2611.81	325	33.65	9.6	120; 5 20.6 435	2677.2	355	36.4	9.76	60; 6 19.57 254	2615.79	330	36	9.18	60;...
       7 18.35 176	3112.36	368	39.2	9.39	144; 8 17.8 146.63	2998.73	345	37.38	9.23	72;9 17.3 138	3096.81	345	38.04	9.07	72; 10 0 0 0 0 0 0 0];
    % Creates the array with all the key information about each solar panel
    
    SolarPanels = array2table (SP, 'VariableNames',{'Model','Efficiency (%)', 'Cost (USD)', 'Size (in^2)', 'Nominal Max Power (W)',...
        'Operating Voltage (V)', 'Operating Current (A)', 'Number of Cells'}); %Creates a Lookup Table 
    


    % IF statements for the GA - Solar Panels 
%x(8)= randi(9); %for testing
%x(7)= randi(50);
    if x(8)== 1
        solarPower=(((SP(1,2)/100).*SP(1,4).*PV_power.*SP(1,5))/1000)* x(7);
        display(sum(solarPower), 'Total power obtained (KW)');
        solarCost= SP(1,3).* x(7);
    elseif x(8)==2
        solarPower=(((SP(2,2)/100).*SP(2,4).*PV_power.*SP(2,5))/1000)* x(7);
        display(sum(solarPower), 'Total power obtained (KW)' );
        solarCost= SP(2,3).* x(7);
    elseif x(8)==3
        solarPower=(((SP(3,2)/100).*SP(3,4).*PV_power.*SP(3,5))/1000)* x(7);
        display(sum(solarPower), 'Total power obtained (KW)');
        solarCost= SP(3,3).* x(7);
    elseif x(8)==4
        solarPower=(((SP(4,2)/100).*SP(4,4).*PV_power.*SP(4,5))/1000)* x(7);
        display(sum(solarPower), 'Total power obtained (KW)' );
        solarCost= SP(4,3).* x(7);
    elseif x(8)==5
        solarPower=(((SP(5,2)/100).*SP(5,4).*PV_power.*SP(5,5))/1000)* x(7);
        display(sum(solarPower), 'Total power obtained (KW)' );
        solarCost= SP(5,3).* x(7);
    elseif x(8)==6
        solarPower=(((SP(6,2)/100).*SP(6,4).*PV_power.*SP(6,5))/1000)* x(7);
        display(sum(solarPower), 'Total power obtained (KW)' );
        solarCost= SP(6,3).* x(7);
    elseif x(8)==7
        solarPower=(((SP(7,2)/100).*SP(7,4).*PV_power.*SP(7,5))/1000)* x(7);
        display(sum(solarPower), 'Total power obtained (KW)' );
        solarCost= SP(7,3).* x(7);
    elseif x(8)==8
        solarPower=(((SP(8,2)/100).*SP(8,4).*PV_power.*SP(8,5))/1000)* x(7);
        display(sum(solarPower), 'Total power obtained (KW)');
        solarCost= SP(8,3).* x(7);
    elseif x(8)==9
        solarPower=(((SP(9,2)/100).*SP(9,4).*PV_power.*SP(9,5))/1000)* x(7); 
        display(sum(solarPower), 'Total power obtained (KW)' );
        solarCost= SP(9,3).* x(7);
    elseif x(8)==10 %No Solar Selected
        solarPower=(((SP(10,2)/100).*SP(10,4).*PV_power.*SP(10,5))/1000)* x(7); 
        display(sum(solarPower), 'No Solar Panel was selected');
        solarCost= SP(9,3).* x(7);
    end
    
%% Wind code

%run('V6');
    % Lookup table for wind turbines
Windturbines = [1 350 12.5 3.5 0 50 12 3630; 0 1000 12 2.5 25 50 24 9000; 0 3000 12 2.5 25 50 48 10000; 0 5000 12 2.5 25 55 48 11000; 0 0 0 0 0 0 0 0];
WindArray = array2table(Windturbines, 'VariableNames', {'HAWT(1)/VAWT(0)', 'Rated Power (W)', 'Rated Wind Speed (m/s)', ...
    'Cut in speed (m/s)', 'cut out speed (m/s)', 'Survival Wind Speed (m/s)', 'Output Voltage (VDC)', 'Cost ($CAD)'});
    
% Power curves for different wind turbines
%x(9)= randi(4); %for testing
%x(10) = Model of WT [Superwind350(1), Mobisun 1kW(2),Mobisun 3kW(3), Mobisun 5kW(4)]
%need to introduce x(13) in the combined
if x(9) == 1 %WT1
    %wind_speed_weibull= 0:0.5:12.5;
    W = (0.1645)*wind_speed.^(3)+(0.2885)*wind_speed.^(2)-1.879*wind_speed+0.0572;
    %Total_power_output = sum(W1)/1000;
    display(sum(W)/1000, 'Total Power obtained using SuperWind350(kW)/year')
    wind_cost = Windturbines(x(9),8);
    wind_survival = Windturbines(x(9),6); 
    if wind_speed > wind_survival;
         W = 0*wind_speed;
        display(sum(W)/1000, 'Wind speed is above Wind Turbine threshold')   
        wind_cost = 0;
    end
   
elseif x(9) == 2 %WT2
    W = (0.011)*wind_speed.^(6)-(0.6033)*wind_speed.^(5)+(12.75)*wind_speed.^(4)-(131.99)*wind_speed.^(3)+(702.6)*wind_speed.^(2)-1740.3*wind_speed+1572.6;
    display(sum(W)/1000, 'Total Power obtained using Mobisun 1000kW(kW)/year')
    wind_cost = Windturbines(x(9),8);
    wind_survival = Windturbines(x(9),6); 
    if wind_speed > wind_survival;
       W = 0*wind_speed;
       display(sum(W)/1000, 'Wind speed is above Wind Turbine threshold')   
       wind_cost = 0;
    end
   

elseif x(9) == 3 %WT2
    W = -(0.069)*wind_speed.^(5)+(2.3178)*wind_speed.^(4)-(27.455)*wind_speed.^(3)+(153.8)*wind_speed.^(2)-231.99*wind_speed+37.767;
    display(sum(W)/1000, 'Total Power obtained using Mobisun 3000kW(kW)/year')   
    wind_cost = Windturbines(x(9),8);
    wind_survival = Windturbines(x(9),6); 
    if wind_speed > wind_survival;
         W = 0*wind_speed;
        display(sum(W)/1000, 'Wind speed is above Wind Turbine threshold')   
        wind_cost = 0;
    end

elseif x(9) == 4 %WT2
    W = -(0.1141)*wind_speed.^(5)+(3.8867)*wind_speed.^(4)-(46.667)*wind_speed.^(3)+(263.39)*wind_speed.^(2)-402.08*wind_speed+67.197;
    display(sum(W)/1000, 'Total Power obtained using Mobisun 5000kW(kW)/year')   
    wind_cost = Windturbines(x(9),8);
    wind_survival = Windturbines(x(9),6); 
    if wind_speed > wind_survival;
         W = 0*wind_speed;
        display(sum(W)/1000, 'Wind speed is above Wind Turbine threshold')   
        wind_cost = 0;
    end

elseif x(9) == 5 %No turbine selected 
    W = 0*wind_speed;
    display(sum(W)/1000, 'No Wind Turbine was selected')   
    wind_cost = Windturbines(x(9),8);
end
%end

%[mass_as_used,Water_NotMet,Qf_memb,Max_BattStor, wind_speed, PV_power]=Combined_code(x,fit,sim_life, W,solarPower, waterday,PumpEnergy);


%% Water tank size and cost
%Water tanks purchased from: https://www.tank-depot.com/product.aspx?id=3242
%For larger communities - make the assumption that at least 50% of the water required for the whole community is on hand

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
tank_vol_options = wt(x(6),2);
CCTank = wt(x(6),1);



%% Water Filtration + Motor & Pump selection
    %RO membranes from: https://www.wateranywhere.com/membranes/filmtec-dow-ro-membranes/dow-filmtec-commercial-ro-membranes/?p=1
    %UF membranes from: https://www.wateranywhere.com/membranes/ultrafiltration-uf-membranes/polyethersulfone-uf-membranes/
    %MF membranes from: https://www.wateranywhere.com/membranes/microfiltration-mf-membranes/pvdf-microfiltration-membranes/
    %Membrane housing from: https://www.wateranywhere.com/catalogsearch/result/?q=membrane+housing
    %UV Purifier from: https://www.freshwatersystems.com/collections/uv-water-purification?refinementList%5Bnamed_tags.System%20Class%5D%5B0%5D=Commercial%20Systems

    
   %% RO membrane selection
    
if salinity > 60 %If it is above 60mg/l then the system will choose an RO membrane from the RO lookup table
       
            membranetable = [1	2.5	40	182	600	45	850	28	0.15 1.4 67; 2	4	14	173	600	45	525	20	0.05 3.2 114; 3	4	21	194	600	45	900	36	0.08 3.2 137; 4	4	40	247	600	45	2625	78	0.15 3.2 130];

            membrane = array2table(membranetable,...
         'VariableNames',{'Option', 'Diameter (in)','Length (in)', 'Cost (USD)', 'Max Pressure (psi)', 'Max Temperature (C)', 'Filtration Rate (GPD)', 'Active Surface Area (Sq. Ft.)', 'Recovery Ratio', 'Feed Rate (m3/h)', 'Membrane Housing Cost (USD)'}); %Lookup table
    
%System Conditions
        p_osm=1.9;
        v_rinse=40/1000;% in m3  %40L per rinse
        RR_sys=0.75; %recovery ratio is 75%
        membReplRate=365/x(3);

            CCmemb = membranetable(x(5),4).*x(4);
            PresVes = membranetable(x(5),11).*x(4); 
            membrane_selected = membranetable(x(5),6);
            filtration_rate = membrane_selected*x(4);
            Qf_memb = membranetable(x(5),10);
            RR_spec = membranetable(x(5),9);
            Kw_init = 0.004533031; 
            Qf_sys = membranetable(x(5),10);
            p_psi = membranetable(x(5),5);
            p = p_psi .* 0.0689476;%pressure in bar
            A_mem = membranetable(x(5),7) %active membrane area is the area of the module
            A=A_mem*x(4);%total active membrane area is the area of the module x number of modules
            CF=1/(1-RR_sys);%concentration factor
            p_osm_avg=p_osm*(exp(0.7*RR_spec))*CF;% average osmotic pressure considering concentration polarization 
            Qp=Kw_init*(A)*(p-p_osm_avg);%m3/h
            Qf=(1/RR_sys)*(Qp);
            
     %Filter = membraneRO(cat(2,membraneRO{:,6}) > 'wateramountday',:) %The chosen filter is dependant on the filtration rate and amount of water needed for the community and extracts that row from the lookup table
        %RO_selected = RO(:,6);
        %RO_selected
        
% UV purification unit
        
        CCuv = 94; %https://www.freshwatersystems.com/products/polaris-uva-2c-ultraviolet-disinfection-system-2-gpm
        uv_power = (14/1000); %KW
        
% Motor and Pump Selection for RO membrane
    %Pump from: https://www.hydra-cell.com/product/H25-hydracell-pump.html
    %Motor from: https://www.globalindustrial.ca/g/motors/ac-motors-definite-purpose/pump-motors/baldor-3-phase-pump-motors
    
        % pm = [1 500 69 2737 230 35.4; 2	500	63	2737 230 35.4; 3	500	50	1835 230 12.5; 4	500	36	1695 230 9.6];

      %  pumpmotor_table = array2table(pm,...
        % 'VariableNames',{'Option','Pump Cost (USD)', 'Pump Capacity (L/min)', 'Motor Cost (USD)', 'Voltage', 'FL AMPS'}); %Lookup table for pump and motor
      
       CCmotor = 1695; %https://www.globalindustrial.ca/p/motors/ac-motors-definite-purpose/pump-motors/baldor-motor-vejmm3311t-7-5-hp-1770-rpm
       motorReplRate=0.1;% [93] Amy's thesis
       PumpEnergy = (7.5*0.7457)/0.917; %3-phase power calculation in KW: P = hp*(0.7457/FL efficiency) From: https://www.energy.gov/sites/prod/files/2014/04/f15/10097517.pdf
       CCpump = 8532; 
       pumpReplRate=0.1;% [93] Amy's thesis
       
   
   %% UF, MF or NF membrane selection 
elseif salinity < 60 %If it is below 60mg/l then the sysetm will choose either an UF or MF membrane
     
        
          %DOC = xlsread(fullfile(path,file),DOC:DOC); %Matlab reads the Dissolved organic content value
       
           if DOC < 50 %If it is below 50 then the system will chose a MF membrane from lookup table (this value is not accurate)
               
       
       
                 MF = [1 4	40	397	200	25; 2 4	40	420	200	25];

                    membrane = array2table(MF,...
                   'VariableNames',{'Option', 'Diameter (in)','Length (in)', 'Cost (USD)', 'Max Pressure (psi)', 'Max Temperature (C)', 'Filtration Rate (GPD)', 'Active Surface Area (Sq. Ft.)', 'Recovery Ratio'});
%{
%System Conditions
        p_osm=1.9;
        v_rinse=40/1000;% in m3  %40L per rinse
        RR_sys=0.75; %recovery ratio is 75%
        membReplRate=365/x(3);

            CCmemb = membranetable(x(5),4).*x(4);
            PresVes = membranetable(x(5),11).*x(4); 
            membrane_selected = membranetable(x(5),6);
            filtration_rate = membrane_selected*x(4);
            Qf_memb = membranetable(x(5),10);
            RR_spec = membranetable(x(5),9);
            Kw_init = 0.004533031; 
            Qf_sys = membranetable(x(5),10);
            p_psi = membranetable(x(5),5);
            p = p_psi .* 0.0689476;%pressure in bar
            A_mem = membranetable(x(5),7) %active membrane area is the area of the module
            A=A_mem*x(4);%total active membrane area is the area of the module x number of modules
            CF=1/(1-RR_sys);%concentration factor
            p_osm_avg=p_osm*(exp(0.7*RR_spec))*CF;% average osmotic pressure considering concentration polarization 
            Qp=Kw_init*(A)*(p-p_osm_avg);%m3/h
            Qf=(1/RR_sys)*(Qp);
            
% UV purification unit
        
        CCuv = 94; %https://www.freshwatersystems.com/products/polaris-uva-2c-ultraviolet-disinfection-system-2-gpm
        uv_power = (14/1000); %KW
        
% Motor and Pump Selection for RO membrane
        % pm = [1 500 69 2737 230 35.4; 2	500	63	2737 230 35.4; 3	500	50	1835 230 12.5; 4	500	36	1695 230 9.6];

      %  pumpmotor_table = array2table(pm,...
        % 'VariableNames',{'Option','Pump Cost (USD)', 'Pump Capacity (L/min)', 'Motor Cost (USD)', 'Voltage', 'FL AMPS'}); %Lookup table for pump and motor
      
       CCmotor = 1695; %https://www.globalindustrial.ca/p/motors/ac-motors-definite-purpose/pump-motors/baldor-motor-vejmm3311t-7-5-hp-1770-rpm
       motorReplRate=0.1;% [93] Amy's thesis
       PumpEnergy = (7.5*0.7457)/0.917; %3-phase power calculation in KW: P = hp*(0.7457/FL efficiency) From: https://www.energy.gov/sites/prod/files/2014/04/f15/10097517.pdf
       CCpump = 8532; %Value not accurate
       pumpReplRate=0.1;% [93] Amy's thesis
           
%}

elseif DOC > 50 %If it is above 50 then the system will chose a UF membrane from lookup table (this value is not accurate)

             
            
                 UF = [1 1.8	12	44	150	60; 2 1.8	21	256	150	60; 3 2.5	40	283	150	60];
        
                   membrane = array2table(UF,...
                 'VariableNames',{'Option', 'Diameter (in)','Length (in)', 'Cost (USD)', 'Max Pressure (psi)', 'Max Temperature (C)', 'Filtration Rate (GPD)', 'Active Surface Area (Sq. Ft.)', 'Recovery Ratio'});  
%{
%System Conditions
        p_osm=1.9;
        v_rinse=40/1000;% in m3  %40L per rinse
        RR_sys=0.75; %recovery ratio is 75%
        membReplRate=365/x(3);

            CCmemb = membranetable(x(5),4).*x(4);
            PresVes = membranetable(x(5),11).*x(4); 
            membrane_selected = membranetable(x(5),6);
            filtration_rate = membrane_selected*x(4);
            Qf_memb = membranetable(x(5),10);
            RR_spec = membranetable(x(5),9);
            Kw_init = 0.004533031; 
            Qf_sys = membranetable(x(5),10);
            p_psi = membranetable(x(5),5);
            p = p_psi .* 0.0689476;%pressure in bar
            A_mem = membranetable(x(5),7) %active membrane area is the area of the module
            A=A_mem*x(4);%total active membrane area is the area of the module x number of modules
            CF=1/(1-RR_sys);%concentration factor
            p_osm_avg=p_osm*(exp(0.7*RR_spec))*CF;% average osmotic pressure considering concentration polarization 
            Qp=Kw_init*(A)*(p-p_osm_avg);%m3/h
            Qf=(1/RR_sys)*(Qp);
            
% UV purification unit
        
        CCuv = 94; %https://www.freshwatersystems.com/products/polaris-uva-2c-ultraviolet-disinfection-system-2-gpm
        uv_power = (14/1000); %KW
        
% Motor and Pump Selection for RO membrane
        % pm = [1 500 69 2737 230 35.4; 2	500	63	2737 230 35.4; 3	500	50	1835 230 12.5; 4	500	36	1695 230 9.6];

      %  pumpmotor_table = array2table(pm,...
        % 'VariableNames',{'Option','Pump Cost (USD)', 'Pump Capacity (L/min)', 'Motor Cost (USD)', 'Voltage', 'FL AMPS'}); %Lookup table for pump and motor
      
       CCmotor = 1695; %https://www.globalindustrial.ca/p/motors/ac-motors-definite-purpose/pump-motors/baldor-motor-vejmm3311t-7-5-hp-1770-rpm
       motorReplRate=0.1;% [93] Amy's thesis
       PumpEnergy = (7.5*0.7457)/0.917; %3-phase power calculation in KW: P = hp*(0.7457/FL efficiency) From: https://www.energy.gov/sites/prod/files/2014/04/f15/10097517.pdf
       CCpump = 8532; %Value not accurate
       pumpReplRate=0.1;% [93] Amy's thesis
           
%}
           end 
    end
   
[mass_as_used,Water_NotMetLOWP,Max_BattStor]=Combined_code(x,fit,sim_life, W,solarPower, waterday,PumpEnergy,Kw_init, A, p, p_osm, Qf,v_rinse);

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
PV.Batt.CC=Max_BattStor*80; %Advanced Lead Acid Battery Storage is about $80/kWh in 2015 http://www.sciencedirect.com.myaccess.library.utoronto.ca/science/article/pii/B9780444637000000210 
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

%% Filter and Filter Cartridge
CC_Filter=20+65.54;
%Filter: http://www.wateranywhere.com/product_info.php?products_id=10168
%($20 USD)
%Housing:
%https://www.aquatell.ca/products/standard-water-filter-housing-kit-20-blue
%($65.54 USD)
FilterCost=20;
FilterReplRate=1/12; %once every month

%% Anti-scalant Delivery System
if x(1)==1 %design variable 1, Anti-scalant selection = No Antiscalant
    CC_anti_sc=0;
    
elseif x(1)==2 || x(1)==3 %design variable 1, Using Anti-scalant
    CC_anti_sc=42.51+14.99; 
    % peristaltic pump cost (42.51 USD) & small anti-scalant tank (14.78)
    % http://www.williamson-shop.co.uk/100-series-with-dc-powered-motors-3586-p.asp
    % 20L container http://www.canadiantire.ca/en/pdp/reliance-rectangular-aqua-pak-water-container-0854035p.html#srp
end
CC_components=CCmemb+PresVes+CCpump+CCmotor+CC_Filter+CC_anti_sc+CCTank;

%Balance of System (piping, valves, filter housings)
CCpipes=0.1*CC_components; %assumed from Amy's thesis

CCpostchems=0.03*CC_components;% post-treatment water re-mineralizing costs [102] Amy's Thesis
postchemsReplRate=0.1;%assumed pg.99 Amy's thesis

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
    Cost_as= (mass_as_used  *1.165 * 0.00352739619496)/sim_life; %Cost of Flocon 135
    % Cost_as= mass_as_used * (1.165) * 0.00352739619496; %Cost of Flocon 135
    
else
    Cost_as= (mass_as_used * 1.35 * 0.004629708)/sim_life; %Cost of Flocon 260
    % Cost_as= mass_as_used * 1.35 * 0.004629708; %Cost of Flocon 260
end

%% Annualized Replacement costs
disc_rate=0.12; % discount rate of 12% from http://heep.hks.harvard.edu/files/heep/files/dp35_meeks.pdf
system_life=25; %25 years
Equiv_Ann_cost_factor=(disc_rate*(1+disc_rate)^system_life)/(((1+disc_rate)^system_life)-1);
AnnCostsRepl=CCmemb*membReplRate+FilterCost*FilterReplRate+CCpump*pumpReplRate+CCmotor*motorReplRate+CCpostchems*postchemsReplRate;

AnnCost=(solarCost+PV.BOS.CC+PV.Batt.CC+PV.Batt.ReplCost+wind_cost)*Equiv_Ann_cost_factor;

AnnCostCC=(CCmemb+PresVes+CCpump+CCmotor+CC_Filter+CC_anti_sc+CCTank+CCpipes)*Equiv_Ann_cost_factor;

PVRO.AnnTotal=AnnCost+AnnCostCC+AnnCostsRepl+Cost_as;

PVRO_PenaltyCost=(PVRO.AnnTotal)+(10^Penalty_Glob)*max(0,(Water_NotMetLOWP-LOWP_Global));



