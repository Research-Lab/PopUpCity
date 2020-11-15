function PVRO_PenaltyCost=Simulation_Test(x,sim_life,LOWP_Global,Penalty_Glob, PV_power, wind_speed, waterday, MWCO)
%% Design Variables

%  Design Variable 1 = Antiscalant [None (0), F135 (1), F260(2)]
%x(1)= randi(2,1); %for testing
%  Design Variable 2 = Rinsing [ NoRinse (0), Rinse (1) ]
%x(2)= randi(2,1); %for testing
%  Design Variable 3 = continuous variable, length of time before replacing membrane in days
%  Design Variable 4 = Number of Filtration Membranes [1 (1), 2 (2), 3 (3), 4 (4), 5 (5), 6 (6), 7 (7), 8 (8), 9 (9), 10 (10)]
%x(4)= randi(10,1); %for testing
%  Design Variable 5 = Membrane filtration unit chosen [1 (1), 2 (2), 3 (3), 4 (4)]
%x(5)= randi(4,1); %for testing
%  Design Variable 6 = Tank size selected
%x(6)= randi(75,1); %for testing
%  Design Variable 7 = Number of solar panels -->choose battery/energy storage (Continuous)
%  such that the beginning increase in power is met, e.g. storage = 0.1*PV_Watt_peak
%x(7)= randi(50,1); %for testing
% Design Variable 8 = Model of Solar Panel
%x(8)= randi(9,1); %for testing
% Design Variable 9 = Model of Wind Turbine [1 (1), 2 (2), 3 (3), 4 (4), 5(0)]
%x(9)= randi(5,1); %for testing
%Design Variable 10 = Number of Wind Turbines [1-10]
%x(10) = randi(10,1); %for testing

%% Testing for Preset Variables
%{
x(1)=1;
x(2)=1;
x(3)=1763;
x(4)=44;
x(5)=3;
x(6)=67;
x(7)=51;
x(8)=8;
x(9)=2;
x(10)=5;
%}

%clear;clc;
numberofVariables=10; %# of design variables,
%% Gather User info
%{

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
%}

%load('Oittila_worksapce')
%% Constant Values for Simulation

system_life = 1;
simulation_day=365*system_life;%Number of days for the simulation time
%DailyVol=waterday;
sim_life=25;
Penalty_Glob=5;
LOWP_Global = 0.07;

%% Solar Panel Code

%{
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
%}

% Lookup Table for solar panels
SP = [1 19.64 239 2.00	375	39.8 9.43 144; 2 19.5	240	1.998	390	40.21 9.7 72; 3 19.8 315	1.713	340	34.5 9.86	60;...
    4 19.3 199	1.685	325	33.65	9.6	120; 5 20.6 435	1.727	355	36.4	9.76	60; 6 19.57 254	1.688	330	36	9.18	60;...
    7 18.35 176	2.00	368	39.2	9.39	144; 8 17.8 146.63	1.935	345	37.38	9.23	72; 9 0 0 0 0 0 0 0];
% Creates the array with all the key information about each solar panel

SolarPanels = array2table (SP, 'VariableNames',{'Model','Efficiency (%)', 'Cost (USD)', 'Size (in^2)', 'Nominal Max Power (W)',...
    'Operating Voltage (V)', 'Operating Current (A)', 'Number of Cells'}); %Creates a Lookup Table

% IF statements for the GA - Solar Panels
if x(8)== 1
    solarPower=((((SP(1,2)/100).*0.98*PV_power.*SP(1,4))/1000))* x(7);
    display(sum(solarPower), 'Total solar power obtained (KW)');
    solarCost= SP(1,3).* x(7);
elseif x(8)==2
    solarPower=((((SP(2,2)/100).*0.98*PV_power.*SP(2,4))/1000))* x(7);
    display(sum(solarPower), 'Total solar power obtained (KW)' );
    solarCost= SP(2,3).* x(7);
elseif x(8)==3
    solarPower=((((SP(3,2)/100).*0.98*PV_power.*SP(3,4))/1000))* x(7);
    display(sum(solarPower), 'Total solar power obtained (KW)');
    solarCost= SP(3,3).* x(7);
elseif x(8)==4
    solarPower=((((SP(4,2)/100).*0.98*PV_power.*SP(4,4))/1000))* x(7);
    display(sum(solarPower), 'Total solar power obtained (KW)' );
    solarCost= SP(4,3).* x(7);
elseif x(8)==5
    solarPower=((((SP(5,2)/100).*0.98*PV_power.*SP(5,4))/1000))* x(7);
    display(sum(solarPower), 'Total soalr power obtained (KW)' );
    solarCost= SP(5,3).* x(7);
elseif x(8)==6
    solarPower=((((SP(6,2)/100).*0.98*PV_power.*SP(6,4))/1000))* x(7);
    display(sum(solarPower), 'Total solar power obtained (KW)' );
    solarCost= SP(6,3).* x(7);
elseif x(8)==7
    solarPower=((((SP(7,2)/100).*0.98*PV_power.*SP(7,4))/1000))* x(7);
    display(sum(solarPower), 'Total solar power obtained (KW)' );
    solarCost= SP(7,3).* x(7);
elseif x(8)==8
    solarPower=((((SP(8,2)/100).*0.98*PV_power.*SP(8,4))/1000))* x(7);
    display(sum(solarPower), 'Total solar power obtained (KW)');
    solarCost= SP(8,3).* x(7);
elseif x(8)==9
    solarPower=((((SP(9,2)/100).*0.98*PV_power.*SP(9,4))/1000))* x(7);
    display(sum(solarPower), 'Total solar power obtained (KW)' );
    solarCost= SP(9,3).* x(7);
end

%% Wind code
%{
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
%}
% Lookup table for wind turbines
Windturbines = [1 350 12.5 3.5 200 50 12 3630; 0 1000 12 3 17 50 48 5390; 0 300 10 3 15 50 24 2545; 0 0 0 0 0 0 0 0];
WindArray = array2table(Windturbines, 'VariableNames', {'HAWT(1)/VAWT(0)', 'Rated Power (W)', 'Rated Wind Speed (m/s)', ...
    'Cut in speed (m/s)', 'cut out speed (m/s)', 'Survival Wind Speed (m/s)', 'Output Voltage (VDC)', 'Cost ($CAD)'});
 
%Power curves for each of the windturbines were found by plotting the given
%curve in excel and using the equation of the curve

    if x(9) == 1 %Superwind 350
        CIS=Windturbines(x(9),4);
        CIS_power = ((0.1037*CIS.^3 + 1.4604*CIS.^2 - 7.0995*CIS + 7.2877)/1000)*x(10);
        RS=Windturbines(x(9),3);
        RS_power = ((0.1037*RS.^3 + 1.4604*RS.^2 - 7.0995*RS + 7.2877)/1000)*x(10);
        %wind_speed_weibull= 0:0.5:12.5;
        W = ((0.1037*wind_speed.^3 + 1.4604*wind_speed.^2 - 7.0995*wind_speed + 7.2877)/1000)*x(10);
        %Total_power_output = sum(W1)/1000;
        display(sum(W), 'Total Power obtained using SuperWind350(kW)/year')
        wind_cost = Windturbines(x(9),8)*x(10);
        wind_survival = Windturbines(x(9),6);
        
        W(W>RS_power)=0;
        W(W<CIS_power)=0;
        
        if wind_speed > wind_survival
            W = 0*wind_speed;
            display(sum(W), 'Wind speed is above Wind Turbine threshold')
            wind_cost = 2000000000000;
        end
        
    elseif x(9) == 2 %P1000-AB
        CIS=Windturbines(x(9),4);
        CIS_power = ((0.0114*CIS.^6 - 0.4967*CIS.^5 + 8.7187*CIS.^4 - 77.911*CIS.^3 + 379.03*CIS.^2 - 917.3*CIS + 884.38)/1000)*x(10);
        RS=Windturbines(x(9),3);
        RS_power = ((0.0114*RS.^6 - 0.4967*RS.^5 + 8.7187*RS.^4 - 77.911*RS.^3 + 379.03*RS.^2 - 917.3*RS + 884.38)/1000)*x(10);
        W= ((0.0114*wind_speed.^6 - 0.4967*wind_speed.^5 + 8.7187*wind_speed.^4 - 77.911*wind_speed.^3 + 379.03*wind_speed.^2 - 917.3*wind_speed + 884.38)/1000)*x(10);
        display(sum(W), 'Total Power obtained using P1000-AB(kW)/year')
        wind_cost = Windturbines(x(9),8)*x(10);
        wind_survival = Windturbines(x(9),6);
        
        W(W>RS_power)=0;
        W(W<CIS_power)=0;
        
        if wind_speed > wind_survival
            W = 0*wind_speed;
            display(sum(W), 'Wind speed is above Wind Turbine threshold')
            wind_cost = 2000000000000;
        end
        
    elseif x(9) == 3 %P300-AB
        
        CIS=Windturbines(x(9),4);
        CIS_power = ((0.00005*CIS.^6 - 0.0062*CIS.^5 + 0.2909*CIS.^4 - 6.5269*CIS.^3 + 70.953*CIS.^2 - 311.42*CIS + 479.26)/1000)*x(10);
        RS=Windturbines(x(9),3);
        RS_power = ((0.00005*RS.^6 - 0.0062*RS.^5 + 0.2909*RS.^4 - 6.5269*RS.^3 + 70.953*RS.^2 - 311.42*RS + 479.26)/1000)*x(10);
        
        W = ((0.00005*wind_speed.^6 - 0.0062*wind_speed.^5 + 0.2909*wind_speed.^4 - 6.5269*wind_speed.^3 + 70.953*wind_speed.^2 - 311.42*wind_speed + 479.26)/1000)*x(10);
        
        W(W>RS_power)=0;
        W(W<CIS_power)=0;
       
        display(sum(W), 'Total Power obtained using P300-AB(kW)/year')
        wind_cost = Windturbines(x(9),8)*x(10);
        wind_survival = Windturbines(x(9),6);
        
        if wind_speed > wind_survival
            W = 0*wind_speed;
            display(sum(W), 'Wind speed is above Wind Turbine threshold')
            wind_cost = 2000000000000;
        end
        
    else %x(9) == 5 %No turbine selected
        W = 0*wind_speed*x(10);
        display(sum(W)/1000, 'No Wind Turbine was selected')
        wind_cost = Windturbines(x(9),8)*x(10);
        CIS=Windturbines(x(9),4);
        CIS_power = 0*CIS*x(10);
        RS=Windturbines(x(9),5);
        RS_power = 0*RS*x(10);
        
    end
     
    %% Water tank size and cost
    %Water tanks purchased from: https://www.tank-depot.com/product.aspx?id=3242
    %For larger communities - make the assumption that at least 50% of the water required for the whole community is on hand
    
    wt = [158.99	375.8; 230.99	605.6; 191.00	757; 247.00	946.25; 241.65	1135.5; 356.00	1324.75; 363.00	1514; 377.99	1703.25; 337.99	1892.5; 369.23	2081.75; 381.00	2271; 386.78	2460.25; 409.73	2649.5; 517.99	2838.75;...
        624.00	3028; 629.78	3217.25; 568.00	3406.5; 567.00	3785; 707.99	3974.25; 557.99	4163.5; 772.20	4352.75; 535.28	4542; 849.00	4920.5; 755.00	5109.75; 822.25	5601.8; 708.99	5677.5; 682.00	5866.75; 707.99	6056; 844.00	6245.25; 863.00	6434.5; 979.84	6623.75;...
        1477.00	7191.5; 916.00	7570; 1397.99	7759.25; 878.99	7948.5; 1102.28	8327; 1297.99	9084; 904.00	9462.5; 908.00	9651.75; 978.89	9841; 1107.00	10219.5; 1157.14	10598; 1121.00	11355; 1400.70	11582.1; 1240.65	11733.5; 1417.50	12112;...
        1997.99	12869; 1897.43	15140; 2388.99	15518.5; 2997.99	15897; 2268.00	17032.5; 3388.99	17789.5; 1948.00	18925; 2292.99	19114.25; 2499.00	19303.5; 3579.00	22710; 3658.87	23656.25; 3939.99	24224; 3197.00	24602.5; 3180.99	24981; 4997.99	26495;...
        4498.99	29333.75; 5697.99	29523; 4971.99	30280; 6597.99	34632.75; 7597.99	35957.5; 5822.00	37850; 7158.00	39742.5; 6679.99	41635; 7549.99	45420; 9694.99	47312.5; 10882.00	47312.5; 12516.00	56775; 10468.99	58667.5; 19980.00	75700];
    
    watertank = array2table(wt,...
        'VariableNames',{'Cost (USD)', 'Capacity (Liters)'}); %Lookup table for water tanks
    
    %tank_vol_options = wt(x(6),2); %tank volume options for the design variable
  
    tank_vol_options = wt(x(6),2);
    CCTank = wt(x(6),1);
    display(tank_vol_options);
    
    
    %% Water Filtration + Motor & Pump selection
    %RO membranes from: https://www.wateranywhere.com/membranes/filmtec-dow-ro-membranes/dow-filmtec-commercial-ro-membranes/?p=1
    %UF membranes from: https://www.wateranywhere.com/membranes/ultrafiltration-uf-membranes/polyethersulfone-uf-membranes/
    %MF membranes from: https://www.wateranywhere.com/membranes/microfiltration-mf-membranes/pvdf-microfiltration-membranes/
    %NF membranes from:
    %Membrane housing from: https://wateranywhere.com/membrane-housings/ss-membrane-housing-pressure-vessels/
    %UV Purifier from: https://www.freshwatersystems.com/collections/uv-water-purification?refinementList%5Bnamed_tags.System%20Class%5D%5B0%5D=Commercial%20Systems
    
    %% Membrane selection
    % Reverse Osmosis
    
    if MWCO < 200 %the system will choose an RO membrane
        
        %System Conditions
        p_osm=1.9;
        v_rinse=40/1000;% in m3  %40L per rinse
        RR_sys=0.75; %recovery ratio is 75%
        membReplRate=365/x(3);
        
        if x(5)==1
            Membrane_Selected = '200394';
            display(Membrane_Selected, 'Selected membrane is part number:');
            CCmemb = 294*x(4); %(USD) Membrane Cost
            PresVes = 206*x(4); %(USD) Pressure Vessel Cost - Membrane Housing
            filtration_rate = 2500; %GPD
            Qf_memb = 9.46; %(m3/h) Filter feed rate
            RR_spec = 0.15; %Recovery Ratio
            Kw_init = 0.004533031; %Initial Premeability
            p_psi = 400; %psi
            p = p_psi .* 0.0689476;%pressure in bar
            A_mem = 7.25; %(m^2) active membrane area is the area of the module
            A=A_mem*x(4);%total active membrane area is the area of the module x number of modules
            CF=1/(1-RR_sys);%concentration factor
            p_osm_avg=p_osm*(exp(0.7*RR_spec))*CF;% average osmotic pressure considering concentration polarization
            Qp=(RR_spec*Qf_memb)*(A)*(p-p_osm_avg);%m3/h
            Qf=(1/RR_sys)*(Qp);
            
        elseif x(5)==2
            Membrane_Selected = '200376';
            display(Membrane_Selected, 'Selected membrane is part number:');
            CCmemb = 216*x(4); %(USD) Membrane Cost
            PresVes = 149*x(4); %(USD) Pressure Vessel Cost - Membrane Housing
            filtration_rate = 1000; %GPD
            Qf_memb = 3.79; %(m3/h) Filter feed rate
            RR_spec = 0.15; %Recovery Ratio
            Kw_init = 0.004533031; %Initial Premeability
            p_psi = 600; %psi
            p = p_psi .* 0.0689476;%pressure in bar
            A_mem = 2.6; %(m^2) active membrane area is the area of the module
            A=A_mem*x(4);%total active membrane area is the area of the module x number of modules
            CF=1/(1-RR_sys);%concentration factor
            p_osm_avg=p_osm*(exp(0.7*RR_spec))*CF;% average osmotic pressure considering concentration polarization
            Qp=(RR_spec*Qf_memb)*(A)*(p-p_osm_avg);%m3/h
            Qf=(1/RR_sys)*(Qp);
            
        elseif x(5)==3
            Membrane_Selected = '200391';
            display(Membrane_Selected, 'Selected membrane is part number:');
            CCmemb = 256*x(4); %(USD) Membrane Cost
            PresVes = 206*x(4); %(USD) Pressure Vessel Cost - Membrane Housing
            filtration_rate = 2500; %GPD
            Qf_memb = 9.46; %(m3/h) Filter feed rate
            RR_spec = 0.15; %Recovery Ratio
            Kw_init = 0.004533031; %Initial Premeability
            p_psi = 600; %psi
            p = p_psi .* 0.0689476;%pressure in bar
            A_mem = 7.25; %(m^2) active membrane area is the area of the module
            A=A_mem*x(4);%total active membrane area is the area of the module x number of modules
            CF=1/(1-RR_sys);%concentration factor
            p_osm_avg=p_osm*(exp(0.7*RR_spec))*CF;% average osmotic pressure considering concentration polarization
            Qp=(RR_spec*Qf_memb)*(A)*(p-p_osm_avg);%m3/h
            Qf=(1/RR_sys)*(Qp);
            
        elseif x(5)==4
            Membrane_Selected = '200373';
            display(Membrane_Selected, 'Selected membrane is part number:');
            CCmemb = 250*x(4); %(USD) Membrane Cost
            PresVes = 206*x(4); %(USD) Pressure Vessel Cost - Membrane Housing
            filtration_rate = 2200; %GPD
            Qf_memb = 8.33; %(m3/h) Filter feed rate
            RR_spec = 0.15; %Recovery Ratio
            Kw_init = 0.004533031; %Initial Premeability
            p_psi = 600; %psi
            p = p_psi .* 0.0689476;%pressure in bar
            A_mem = 7.25; %(m^2) active membrane area is the area of the module
            A=A_mem*x(4);%total active membrane area is the area of the module x number of modules
            CF=1/(1-RR_sys);%concentration factor
            p_osm_avg=p_osm*(exp(0.7*RR_spec))*CF;% average osmotic pressure considering concentration polarization
            Qp=(RR_spec*Qf_memb)*(A)*(p-p_osm_avg);%m3/h
            Qf=(1/RR_sys)*(Qp);
            
        else %Membrane Penalty
            Membrane_Selected = 'None';
            display(Membrane_Selected, 'Selected membrane is part number:');
            CCmemb = 2000000*x(4); %(USD) Membrane Cost
            PresVes = 2000000; %(USD) Pressure Vessel Cost - Membrane Housing
            filtration_rate = 0; %GPD
            Qf_memb = 0; %(m3/h) Filter feed rate
            RR_spec = 0; %Recovery Ratio
            Kw_init = 0; %Initial Premeability
            p_psi = 0; %psi
            p = p_psi .* 0.0689476;%pressure in bar
            A_mem = 0; % (Sq.Ft.) active membrane area is the area of the module
            A=A_mem*x(4);%total active membrane area is the area of the module x number of modules
            CF=1/(1-RR_sys);%concentration factor
            p_osm_avg=p_osm*(exp(0.7*RR_spec))*CF;% average osmotic pressure considering concentration polarization
            Qp=(RR_spec*Qf_memb)*(A)*(p-p_osm_avg);%m3/h
            Qf=(1/RR_sys)*(Qp);
        end
        
        % UV purification unit
        
        CCuv = 94; %https://www.freshwatersystems.com/products/polaris-uva-2c-ultraviolet-disinfection-system-2-gpm
        uv_power = (14/1000); %KW
        
        CCmotor = 1695; %https://www.globalindustrial.ca/p/motors/ac-motors-definite-purpose/pump-motors/baldor-motor-vejmm3311t-7-5-hp-1770-rpm
        CCpump = 8532;
        motorReplRate=0.1;% [93] Amy's thesis
        %PumpEn = (7.5*0.7457)/0.917; %3-phase power calculation in KW: P = hp*(0.7457/FL efficiency) From: https://www.energy.gov/sites/prod/files/2014/04/f15/10097517.pdf
        eff_hp=0.924*0.9;%efficiency of the pump and motor
        PumpEn=(27.78*p*Qf_memb/eff_hp)/1000; %kW is unit of PumpEnergy
        pumpReplRate=0.1;% [93] Amy's thesis
        PumpEnergy = PumpEn + uv_power;
        
    %Nanofiltration 
    elseif (200 < MWCO)&& (MWCO < 1000) %the sysetm will choose an NF membrane

        %System Conditions
        p_osm=1.9;
        v_rinse=40/1000;% in m3  %40L per rinse
        RR_sys=0.75; %recovery ratio is 75%
        membReplRate=365/x(3);
        
        if x(5)==1
            Membrane_Selected = 'NF90-400';
            display(Membrane_Selected, 'Selected membrane is part number:');
            CCmemb = 805*x(4); %(USD) Membrane Cost
            PresVes = 587*x(4); %(USD) Pressure Vessel Cost - Membrane Housing (https://www.foreverpureplace.com/GA41368-p/ga41368.htm)
            filtration_rate = 10000; %GPD
            Qf_memb = 38; %(m3/h) Filter feed rate
            RR_spec = 0.15; %Recovery Ratio
            Kw_init = 0.004533031; %Initial Premeability
            p_psi = 600; %psi
            p = p_psi .* 0.0689476;%pressure in bar
            A_mem = 37; % (m^2) active membrane area is the area of the module
            A=A_mem*x(4);%total active membrane area is the area of the module x number of modules
            CF=1/(1-RR_sys);%concentration factor
            p_osm_avg=p_osm*(exp(0.7*RR_spec))*CF;% average osmotic pressure considering concentration polarization
            Qp=(RR_spec*Qf_memb)*(A)*(p-p_osm_avg);%m3/h
            Qf=(1/RR_sys)*(Qp);
            
        elseif x(5)==2
            Membrane_Selected = '200405';
            display(Membrane_Selected, 'Selected membrane is part number:');
            CCmemb = 177*x(4); %(USD) Membrane Cost
            PresVes = 137*x(4); %(USD) Pressure Vessel Cost - Membrane Housing
            filtration_rate = 1000; %GPD
            Qf_memb = 3.79; %(m3/h) Filter feed rate
            RR_spec = 0.15; %Recovery Ratio
            Kw_init = 0.004533031; %Initial Premeability
            p_psi = 600; %psi
            p = p_psi .* 0.0689476;%pressure in bar
            A_mem = 3.34; %(m^2) active membrane area is the area of the module
            A=A_mem*x(4);%total active membrane area is the area of the module x number of modules
            CF=1/(1-RR_sys);%concentration factor
            p_osm_avg=p_osm*(exp(0.7*RR_spec))*CF;% average osmotic pressure considering concentration polarization
            Qp=(RR_spec*Qf_memb)*(A)*(p-p_osm_avg);%m3/h
            Qf=(1/RR_sys)*(Qp);
            
        elseif x(5)==3
            Membrane_Selected = '200412';
            display(Membrane_Selected, 'Selected membrane is part number:');
            CCmemb = 259*x(4); %(USD) Membrane Cost
            PresVes = 206*x(4); %(USD) Pressure Vessel Cost - Membrane Housing
            filtration_rate = 2000; %GPD
            Qf_memb = 7.6; %(m3/h) Filter feed rate
            RR_spec = 0.15; %Recovery Ratio
            Kw_init = 0.004533031; %Initial Premeability
            p_psi = 600; %psi
            p = p_psi .* 0.0689476;%pressure in bar
            A_mem = 7.25; %(m^2) active membrane area is the area of the module
            A=A_mem*x(4);%total active membrane area is the area of the module x number of modules
            CF=1/(1-RR_sys);%concentration factor
            p_osm_avg=p_osm*(exp(0.7*RR_spec))*CF;% average osmotic pressure considering concentration polarization
            Qp=(RR_spec*Qf_memb)*(A)*(p-p_osm_avg);%m3/h
            Qf=(1/RR_sys)*(Qp);
            
        elseif x(5)==4
            Membrane_Selected = '200406';
            display(Membrane_Selected, 'Selected membrane is part number:');
            CCmemb = 262*x(4); %(USD) Membrane Cost
            PresVes = 206*x(4); %(USD) Pressure Vessel Cost - Membrane Housing
            filtration_rate = 2500; %GPD
            Qf_memb = 9.46; %(m3/h) Filter feed rate
            RR_spec = 0.15; %Recovery Ratio
            Kw_init = 0.004533031; %Initial Premeability
            p_psi = 600; %psi
            p = p_psi .* 0.0689476;%pressure in bar
            A_mem = 7.25; %(m^2) active membrane area is the area of the module
            A=A_mem*x(4);%total active membrane area is the area of the module x number of modules
            CF=1/(1-RR_sys);%concentration factor
            p_osm_avg=p_osm*(exp(0.7*RR_spec))*CF;% average osmotic pressure considering concentration polarization
            Qp=(RR_spec*Qf_memb)*(A)*(p-p_osm_avg);%m3/h
            Qf=(1/RR_sys)*(Qp);
            
        else
            Membrane_Selected = 'None';
            display(Membrane_Selected, 'Selected membrane is part number:');
            CCmemb = 2000000; %(USD) Membrane Cost
            PresVes = 2000000; %(USD) Pressure Vessel Cost - Membrane Housing
            filtration_rate = 0; %GPD
            Qf_memb = 0; %(m3/h) Filter feed rate
            RR_spec = 0; %Recovery Ratio
            Kw_init = 0; %Initial Premeability
            p_psi = 0; %psi
            p = p_psi .* 0.0689476;%pressure in bar
            A_mem = 0; % (Sq.Ft.) active membrane area is the area of the module
            A=A_mem*x(4);%total active membrane area is the area of the module x number of modules
            CF=1/(1-RR_sys);%concentration factor
            p_osm_avg=p_osm*(exp(0.7*RR_spec))*CF;% average osmotic pressure considering concentration polarization
            Qp=(RR_spec*Qf_memb)*(A)*(p-p_osm_avg);%m3/h
            Qf=(1/RR_sys)*(Qp);
        end
        
        % UV purification unit
        
        CCuv = 450; %(USD) https://www.freshwatersystems.com/products/mighty-pure-mp36c-12-gpm-ultraviolet-water-purifier
        uv_power = (44/1000); %KW
        
        % Motor and Pump Selection for NF membrane
        
        CCmotor = 266; %(350CAD->USD) https://www.canadiantire.ca/en/pdp/mastercraft-1-2-hp-jet-pump-0623525p.html#srp
        motorReplRate=0.1;% [93] Amy's thesis
        %PumpEn = (0.5*0.7457)/0.917; %3-phase power calculation in KW: P = hp*(0.7457/FL efficiency) From: https://www.energy.gov/sites/prod/files/2014/04/f15/10097517.pdf
        CCpump = 0; %Value not accurate
        eff_hp=0.924*0.9;%efficiency of the pump and motor
        PumpEn=(27.78*p*Qf_memb/eff_hp)*deltat/1000; %kW is unit of PumpEnergy
        pumpReplRate=0.1;% [93] Amy's thesis
        PumpEnergy = PumpEn + uv_power;
        
        
    %Ultrafiltration
        
    elseif (1000 < MWCO) && (MWCO < 100000)
        
        %System Conditions
        p_osm=1.9;
        v_rinse=40/1000;% in m3  %40L per rinse
        RR_sys=0.75; %recovery ratio is 75%
        membReplRate=365/x(3);
        
        if x(5)==1
            Membrane_Selected = 'M-U4021HF15';
            display(Membrane_Selected, 'Selected membrane is part number:');
            CCmemb = 296*x(4); %(USD) Membrane Cost
            PresVes = 137*x(4); %(USD) Pressure Vessel Cost - Membrane Housing (https://www.foreverpureplace.com/GA41368-p/ga41368.htm)
            filtration_rate = 1164; %GPD
            Qf_memb = 4.41; %(m3/h) Filter feed rate
            RR_spec = 0.15; %Recovery Ratio
            Kw_init = 0.004533031; %Initial Premeability
            p_psi = 43.5; %psi
            p = p_psi .* 0.0689476;%pressure in bar
            A_mem = 1.8; % (m^2) active membrane area is the area of the module
            A=A_mem*x(4);%total active membrane area is the area of the module x number of modules
            CF=1/(1-RR_sys);%concentration factor
            p_osm_avg=p_osm*(exp(0.7*RR_spec))*CF;% average osmotic pressure considering concentration polarization
            Qp=(RR_spec*Qf_memb)*(A)*(p-p_osm_avg);%m3/h
            Qf=(1/RR_sys)*(Qp);
            
        elseif x(5)==2
            Membrane_Selected = 'M-U4021HF09';
            display(Membrane_Selected, 'Selected membrane is part number:');
            CCmemb = 209*x(4); %(USD) Membrane Cost
            PresVes = 137*x(4); %(USD) Pressure Vessel Cost - Membrane Housing
            filtration_rate = 1620; %GPD
            Qf_memb = 6.14; %(m3/h) Filter feed rate
            RR_spec = 0.15; %Recovery Ratio
            Kw_init = 0.004533031; %Initial Premeability
            p_psi = 43.5; %psi
            p = p_psi .* 0.0689476;%pressure in bar
            A_mem = 2.5; %(m^2) active membrane area is the area of the module
            A=A_mem*x(4);%total active membrane area is the area of the module x number of modules
            CF=1/(1-RR_sys);%concentration factor
            p_osm_avg=p_osm*(exp(0.7*RR_spec))*CF;% average osmotic pressure considering concentration polarization
            Qp=(RR_spec*Qf_memb)*(A)*(p-p_osm_avg);%m3/h
            Qf=(1/RR_sys)*(Qp);
            
        elseif x(5)==3
            Membrane_Selected = 'M-U4040HF15';
            display(Membrane_Selected, 'Selected membrane is part number:');
            CCmemb = 245*x(4); %(USD) Membrane Cost
            PresVes = 206*x(4); %(USD) Pressure Vessel Cost - Membrane Housing
            filtration_rate = 2580; %GPD
            Qf_memb = 9.76; %(m3/h) Filter feed rate
            RR_spec = 0.15; %Recovery Ratio
            Kw_init = 0.004533031; %Initial Premeability
            p_psi = 43.5; %psi
            p = p_psi .* 0.0689476;%pressure in bar
            A_mem = 4; %(m^2) active membrane area is the area of the module
            A=A_mem*x(4);%total active membrane area is the area of the module x number of modules
            CF=1/(1-RR_sys);%concentration factor
            p_osm_avg=p_osm*(exp(0.7*RR_spec))*CF;% average osmotic pressure considering concentration polarization
            Qp=(RR_spec*Qf_memb)*(A)*(p-p_osm_avg);%m3/h
            Qf=(1/RR_sys)*(Qp);
            
        elseif x(5)==4
            Membrane_Selected = 'M-U4040HF09';
            display(Membrane_Selected, 'Selected membrane is part number:');
            CCmemb = 249*x(4); %(USD) Membrane Cost
            PresVes = 206*x(4); %(USD) Pressure Vessel Cost - Membrane Housing
            filtration_rate = 3900; %GPD
            Qf_memb = 14.7; %(m3/h) Filter feed rate
            RR_spec = 0.15; %Recovery Ratio
            Kw_init = 0.004533031; %Initial Premeability
            p_psi = 43.5; %psi
            p = p_psi .* 0.0689476;%pressure in bar
            A_mem = 6; %(m^2) active membrane area is the area of the module
            A=A_mem*x(4);%total active membrane area is the area of the module x number of modules
            CF=1/(1-RR_sys);%concentration factor
            p_osm_avg=p_osm*(exp(0.7*RR_spec))*CF;% average osmotic pressure considering concentration polarization
            Qp=(RR_spec*Qf_memb)*(A)*(p-p_osm_avg);%m3/h
            Qf=(1/RR_sys)*(Qp);
            
        else
            Membrane_Selected = 'None';
            display(Membrane_Selected, 'Selected membrane is part number:');
            CCmemb = 2000000; %(USD) Membrane Cost
            PresVes = 2000000; %(USD) Pressure Vessel Cost - Membrane Housing
            filtration_rate = 0; %GPD
            Qf_memb = 0; %(m3/h) Filter feed rate
            RR_spec = 0; %Recovery Ratio
            Kw_init = 0; %Initial Premeability
            p_psi = 0; %psi
            p = p_psi .* 0.0689476;%pressure in bar
            A_mem = 0; % (Sq.Ft.) active membrane area is the area of the module
            A=A_mem*x(4);%total active membrane area is the area of the module x number of modules
            CF=1/(1-RR_sys);%concentration factor
            p_osm_avg=p_osm*(exp(0.7*RR_spec))*CF;% average osmotic pressure considering concentration polarization
            Qp=(RR_spec*Qf_memb)*(A)*(p-p_osm_avg);%m3/h
            Qf=(1/RR_sys)*(Qp);
        end
        
        % UV purification unit
        
        CCuv = 450; %https://www.freshwatersystems.com/products/mighty-pure-mp36c-12-gpm-ultraviolet-water-purifier
        uv_power = (44/1000); %KW
        
        % Motor and Pump Selection for UF membrane
        
        CCmotor = 266; %(350CAD->USD) https://www.canadiantire.ca/en/pdp/mastercraft-1-2-hp-jet-pump-0623525p.html#srp
        motorReplRate=0.1;% [93] Amy's thesis
        PumpEn = (27.78*p*Qf_memb/eff_hp)/1000; %3-phase power calculation in KW: P = hp*(0.7457/FL efficiency) From: https://www.energy.gov/sites/prod/files/2014/04/f15/10097517.pdf
        CCpump = 0; %Value not accurate
        pumpReplRate=0.1;% [93] Amy's thesis
        PumpEnergy = PumpEn + uv_power;
        
        %}
                
    %Microfiltration
        
    elseif MWCO > 100000 %If it is above 100000 Da then the system will chose a MF membrane 
           
       %System Conditions
        p_osm=1.9;
        v_rinse=40/1000;% in m3  %40L per rinse
        RR_sys=0.75; %recovery ratio is 75%
        membReplRate=365/x(3);
        
        if x(5)==1
            Membrane_Selected = 'UNA-620A'; %https://www.watersurplus.com/surplus-assets-display.cfm?asset=MEM2830022
            display(Membrane_Selected, 'Selected membrane is part number:');
            CCmemb = 950*x(4); %(USD) Membrane Cost
            PresVes = 0*x(4); %(USD) Pressure Vessel Cost - Membrane Housing (https://www.foreverpureplace.com/GA41368-p/ga41368.htm)
            %filtration_rate = 1164; %GPD
            Qf_memb = 6.8; %(m3/h) Filter feed rate
            RR_spec = 0.15; %Recovery Ratio
            %Kw_init = 0.004533031; %Initial Premeability
            p_psi = 45; %psi
            p = p_psi .* 0.0689476;%pressure in bar
            A_mem = 50; % (m^2) active membrane area is the area of the module
            A=A_mem*x(4);%total active membrane area is the area of the module x number of modules
            CF=1/(1-RR_sys);%concentration factor
            p_osm_avg=p_osm*(exp(0.7*RR_spec))*CF;% average osmotic pressure considering concentration polarization
            Qp=(RR_spec*Qf_memb)*(A)*(p-p_osm_avg);%m3/h
            Qf=(1/RR_sys)*(Qp);
            
        elseif x(5)==2
            Membrane_Selected = 'FR - 8040-HF'; %Synder Filtration
            display(Membrane_Selected, 'Selected membrane is part number:');
            CCmemb = 1097*x(4); %(USD) Membrane Cost
            PresVes = 578*x(4); %(USD) Pressure Vessel Cost - Membrane Housing
            %filtration_rate = 299; %GPM
            Qf_memb = 15; %(m3/h) Filter feed rate
            RR_spec = 0.15; %Recovery Ratio
            %Kw_init = 0.004533031; %Initial Premeability
            p_psi = 116; %psi
            p = p_psi .* 0.0689476;%pressure in bar
            A_mem = 35.2; %(m^2) active membrane area is the area of the module
            A=A_mem*x(4);%total active membrane area is the area of the module x number of modules
            CF=1/(1-RR_sys);%concentration factor
            p_osm_avg=p_osm*(exp(0.7*RR_spec))*CF;% average osmotic pressure considering concentration polarization
            Qp=(RR_spec*Qf_memb)*(A)*(p-p_osm_avg);%m3/h
            Qf=(1/RR_sys)*(Qp);
            
        elseif x(5)==3
            Membrane_Selected = 'V0.1 - 8040-HF'; %Synder Filtration
            display(Membrane_Selected, 'Selected membrane is part number:');
            CCmemb = 1097*x(4); %(USD) Membrane Cost
            PresVes = 578*x(4); %(USD) Pressure Vessel Cost - Membrane Housing
            %filtration_rate = 299; %GPM
            Qf_memb = 15; %(m3/h) Filter feed rate
            RR_spec = 0.15; %Recovery Ratio
            %Kw_init = 0.004533031; %Initial Premeability
            p_psi = 116; %psi
            p = p_psi .* 0.0689476;%pressure in bar
            A_mem = 35.2; %(m^2) active membrane area is the area of the module
            A=A_mem*x(4);%total active membrane area is the area of the module x number of modules
            CF=1/(1-RR_sys);%concentration factor
            p_osm_avg=p_osm*(exp(0.7*RR_spec))*CF;% average osmotic pressure considering concentration polarization
            Qp=(RR_spec*Qf_memb)*(A)*(p-p_osm_avg);%m3/h
            Qf=(1/RR_sys)*(Qp);
            
        elseif x(5)==4
            Membrane_Selected = 'V0.2 - 8040-HF'; %Synder Filtration
            display(Membrane_Selected, 'Selected membrane is part number:');
            CCmemb = 1097*x(4); %(USD) Membrane Cost
            PresVes = 578*x(4); %(USD) Pressure Vessel Cost - Membrane Housing
            %filtration_rate = 299; %GPM
            Qf_memb = 15; %(m3/h) Filter feed rate
            RR_spec = 0.15; %Recovery Ratio
            %Kw_init = 0.004533031; %Initial Premeability
            p_psi = 116; %psi
            p = p_psi .* 0.0689476;%pressure in bar
            A_mem = 35.2; %(m^2) active membrane area is the area of the module
            A=A_mem*x(4);%total active membrane area is the area of the module x number of modules
            CF=1/(1-RR_sys);%concentration factor
            p_osm_avg=p_osm*(exp(0.7*RR_spec))*CF;% average osmotic pressure considering concentration polarization
            Qp=(RR_spec*Qf_memb)*(A)*(p-p_osm_avg);%m3/h
            Qf=(1/RR_sys)*(Qp);
            
        else
            Membrane_Selected = 'None';
            display(Membrane_Selected, 'Selected membrane is part number:');
            CCmemb = 2000000; %(USD) Membrane Cost
            PresVes = 2000000; %(USD) Pressure Vessel Cost - Membrane Housing
            filtration_rate = 0; %GPD
            Qf_memb = 0; %(m3/h) Filter feed rate
            RR_spec = 0; %Recovery Ratio
            Kw_init = 0; %Initial Premeability
            p_psi = 0; %psi
            p = p_psi .* 0.0689476;%pressure in bar
            A_mem = 0; % (Sq.Ft.) active membrane area is the area of the module
            A=A_mem*x(4);%total active membrane area is the area of the module x number of modules
            CF=1/(1-RR_sys);%concentration factor
            p_osm_avg=p_osm*(exp(0.7*RR_spec))*CF;% average osmotic pressure considering concentration polarization
            Qp=(RR_spec*Qf_memb)*(A)*(p-p_osm_avg);%m3/h
            Qf=(1/RR_sys)*(Qp);
        end
        
        % UV purification unit
        
        CCuv = 450; %https://www.freshwatersystems.com/products/mighty-pure-mp36c-12-gpm-ultraviolet-water-purifier
        uv_power = (44/1000); %KW
        
        % Motor and Pump Selection for UF membrane
        
        CCmotor = 266; %(350CAD->USD) https://www.canadiantire.ca/en/pdp/mastercraft-1-2-hp-jet-pump-0623525p.html#srp
        motorReplRate=0.1;% [93] Amy's thesis
        eff_hp=0.924*0.9;%efficiency of the pump and motor
        PumpEn = (27.78*p*Qf_memb/eff_hp)/1000; %3-phase power calculation in KW: P = hp*(0.7457/FL efficiency) From: https://www.energy.gov/sites/prod/files/2014/04/f15/10097517.pdf
        CCpump = 0; %Value not accurate
        pumpReplRate=0.1;% [93] Amy's thesis
        PumpEnergy = PumpEn + uv_power;
        
        %}
        
        % UV purification unit
        
        CCuv = 450; %https://www.freshwatersystems.com/products/mighty-pure-mp36c-12-gpm-ultraviolet-water-purifier
        uv_power = (44/1000); %KW
        
        % Motor and Pump Selection for MF membrane
        
        CCmotor = 266; %(350CAD->USD) https://www.canadiantire.ca/en/pdp/mastercraft-1-2-hp-jet-pump-0623525p.html#srp
        motorReplRate=0.1;% [93] Amy's thesis
        PumpEn = (27.78*p*Qf_memb/eff_hp)/1000; %3-phase power calculation in KW: P = hp*(0.7457/FL efficiency) From: https://www.energy.gov/sites/prod/files/2014/04/f15/10097517.pdf
        CCpump = 0; %Value not accurate
        pumpReplRate=0.1;% [93] Amy's thesis
        PumpEnergy = PumpEn + uv_power;
        
    end
    
    %% Anti-Scalant Dosing
    Dose_F135 = 3.9; % in mg/L Dose rate for anti-scalant based on Flocon calculator (Flodose)
    density_F135=1.165e-3; % in mg/mL Flocon 135 density = 1.165±0.035 g/cm3
    as_dose_f135 = Dose_F135 * 1000 * (1/density_F135); %converted to mL / m3 for ease of calculations
    
    Dose_F260 = 3.9; % in mg/L Dose rate for anti-scalant based on Flocon calculator (Flodose)
    density_F260=1.35e-3; % in mg/mL Flocon 260 density = 1.35±0.05 g/cm3
    as_dose_f260 = Dose_F260 * 1000 * (1/density_F260); %converted to mL / m3 for ease of calculations
    
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
    
    %% Design Variables
    if x(1)==1 %design variable 1, Anti-scalant selection = No Antiscalant
        as_dose=0;
        
    elseif x(1)==2  %design variable 1, Anti-scalant selection = F135
        as_dose=Dose_F135;
        
    elseif x(1)==3 %design variable 1, Anti-scalant selection = F260
        as_dose=Dose_F260;
    end
    
    
    rinse=x(2); % rinsing [ NoRinse (1), Rinse (2) ]
    time_to_replace=x(3); % time to replace membrane in days (continuous integer variable)
    num_membrane=x(4); % # of membranes [1 (1), 2 (2), 3 (3), 4 (4), 5 (5), 6 (6), 7(7), 8(8), 9(9), 10 (10)]
    
    num_panel=x(7);% number of pv panels [1-50]
    mod_pp = x(8); % model of the solar panel selected [1-10]
    mod_wind = x(9); %Model of Wind Turbine [1 (1), 2 (2), 3 (3), 4 (4), 5(0)]
    
    %% Initialization of Values
    
    hour=0;
    deltat=1;
    tank_full=1;
    tank_vol=zeros(simulation_day,24);
    tank_vol_prev=tank_vol_options*1;
    days_nMem=0;
    water_not_met_hourly=0;
    num_modules_replaced=0;% counter for number of modules replaced
    rinsing_flag=0;%rinsing flag to catch everytime a rinse has occured
    hour=0;
    deltat=1;
    
    Energy_sum=zeros(simulation_day,24);
    Energy_hourly=zeros(simulation_day,24); 
    Energy_hourly_wind=zeros(simulation_day,24); %Array for hourly wind power 
    Energy_hourly_solar=zeros(simulation_day,24); %Array for hourly solar power
    enough_energy_wind= zeros( simulation_day,24); %Array to indicate if there is enough wind power and the system can be turned on
    enough_energy_solar= zeros( simulation_day,24); %Array to indicate if there is enough solar power and the system can be turned on
    enough_energy= ones( simulation_day,24); %Array to indicate if there is enough combined power and the system can be turned on
    Energy_hourly_combined=zeros( simulation_day,24);
    
    
    num_hrs=zeros(1,simulation_day);
    num_hrs_wind=zeros(1,simulation_day);
    num_hrs_solar=zeros(1,simulation_day);
    
    
    Qp=zeros(simulation_day,24);
    PV_E_dif=zeros(simulation_day,24);
    Power_use=zeros(simulation_day,24);
    water_demand=zeros(1,24);
    mass_as=zeros(simulation_day,24);
    Batt_SOC=zeros(simulation_day,24);
  
    
    %Power Strategy
    Energy_prev=0;
    Energy_prev_wind=0;
    Energy_prev_solar=0;
    Energy_prev_hourly=0;
    
    overcharge=0;
    
    
    %% Water and Energy Simulation
    
    eff_syst=0.8;%the battery round trip efficiency
        
    rinsing=zeros(simulation_day,24);
    
    %Water demand
    %make a consistent vector for the water demand, 9am-5pm 1m3/8hours
    water_demand_base = [0 0 0 0 0 0 0 0 0 0.08 0.08 0.08 0.08 0.08 0.08 0.08 0.08 0 0 0 0 0 0 0];
    water_demand=waterday*water_demand_base; %L
    foundnowind=0;
    Batt_SOC_Prev=3*PumpEnergy;
    for i=1:simulation_day
        
        %Membrane Replacement Strategy
        if days_nMem<time_to_replace
            days_nMem=days_nMem+1;
        else
            days_nMem=1;
            num_modules_replaced=num_modules_replaced+1;
        end
        
        
        %Power Strategy
        
        for s=1:24
            
            Energy_sum_wind(i,s)=W((i-1)*24+s)*deltat+Energy_prev_wind;
            Energy_prev_wind=Energy_sum_wind(i,s);
            Energy_hourly_wind(i,s)=W((i-1)*24+s)*deltat; %Calculates the hourly wind amount of power
            
            if Energy_hourly_wind(i,s)>PumpEnergy %Checks to see if there is enough wind power that hour to turn the pump on
                num_hrs_wind(i)=num_hrs_wind(i)+1; %Increase number of hours by 1 - calculated everyday
                enough_energy_wind(i,s)=1; %Marks a 1 down in the array
            else
                enough_energy_wind(i,s)=0; %Marks a 0 down in the array
                
            end
            
            Energy_sum_solar(i,s)=solarPower((i-1)*24+s)*deltat+Energy_prev_solar;
            Energy_prev_solar=Energy_sum_solar(i,s);
            Energy_hourly_solar(i,s)=solarPower((i-1)*24+s)*deltat; %Calculates the hourly solar amount of power
           
            if Energy_hourly_solar(i,s)>PumpEnergy %Checks to see if there is enough solar power that hour to turn the pump on
                num_hrs_solar(i)=num_hrs_solar(i)+1; %Increase number of hours by 1 - calculated everyday
                enough_energy_solar(i,s)=1; %Marks a 1 down in the array
            else
                enough_energy_solar(i,s)=0; %Marks a 0 down in the array
                
            end
            
            Energy_sum (i,s) = Energy_sum_solar(i,s)+Energy_sum_wind(i,s)+Energy_prev;
            Energy_prev=Energy_sum(i,s);
            Energy_hourly (i,s) = Energy_hourly_solar(i,s)+Energy_hourly_wind(i,s); % Combined hourly power
            Energy_hourly_combined (i,s) = Energy_hourly_solar(i,s)+Energy_hourly_wind(i,s)+Energy_prev_hourly; %Combined power with the extra energy from the previous hour
            Energy_prev_hourly=Energy_hourly_combined(i,s);
            
            
            if Energy_hourly_combined(i,s)>PumpEnergy %Checks to see if there is enough combined power that hour to turn the pump on
                num_hrs(i)=num_hrs(i)+1; %Increase number of hours by 1 - calculated everyday
                Energy_prev_hourly=Energy_hourly_combined(i,s)-PumpEnergy; %If the pump is turned on the energy required is subtracted
            else
                enough_energy(i,s)=0;
                
            end
            
        end
        
        num_hours_run=0;
      
        rinsing_flag=0;
            
        for s=1:24
            
            if (rinsing_flag==0 && rinse==2)
                
                if num_hours_run==num_hrs(i) %Checks to see if the system has run the maximum number of hours possible
                    rinsing_flag=1;
                    rinsing(i,s)=v_rinse;
                    
                elseif s==24 && num_hrs(i)>=1
                    rinsing_flag=1;
                    rinsing(i,s)=v_rinse;
                end
                
            else
                rinsing(i,s)=0;
            end
            
            FFfit=[0.5371,3.752,6.024,-0.027385333];%mid% AC & Rinse
            %FFfit=[0.4472,0.6963,2.587,-0.027385333];%low% AC & Rinse
            %FFfit=[0.627,6.808,9.46,-0.027385333];%high AC & Rinse
            
            FF(i,s)=findPermeability(days_nMem,num_hours_run,FFfit(1),FFfit(2), FFfit(3),FFfit(4));
            
            Max_BattStor=3*PumpEnergy; %3h worth of battery storage
            
            Batt_SOC(i,s)=(Energy_hourly(i,s)+Power_use(i,s)+Batt_SOC_Prev);
            Batt_SOC_Prev=Batt_SOC(i,s);
            
            if Batt_SOC(i,s)>Max_BattStor
                overcharge = overcharge+1;
                Batt_SOC(i,s)=Max_BattStor;
                
                %battery storage
            elseif Batt_SOC(i,s)<0
                Batt_SOC(i,s)=0;
            end
            
            
            if enough_energy(i,s)==1 && num_hours_run<=num_hrs(i) && tank_full==0 %Checks to see if there is enough power and there are hours still to be run and the tank is not full
                % Run system
                Qp(i,s)=max(0,((RR_spec*Qf_memb)*FF(i,s)*A*(p-p_osm)));
                
                %Battery
                PV_E_dif(i,s)=Energy_hourly(i,s)-PumpEnergy;
                Power_use(i,s)=-PumpEnergy;
                
                num_hours_run=num_hours_run+1;
                
            else
                Qp(i,s)=0;
                %Battery
                PV_E_dif(i,s)=Energy_hourly(i,s);
                Power_use(i,s)=0;
            end
            
                
                %Tank Volume
                
                if tank_full ==1 % dont add the water Qp(i,s) to the tank
                    tank_vol(i,s)= tank_vol_options-water_demand(s)-rinsing(i,s);
                    if tank_vol(i,s)< tank_vol_options
                        tank_full=0;
                    else
                        tank_full=1;
                    end
                    
                else %  tank_full ==0 % tank is not full, add the Qp(i,s)*t to the tank
                    tank_vol(i,s)=min(tank_vol_prev+Qp(i,s)*deltat-water_demand(s)-rinsing(i,s),tank_vol_options);
                end
                %anti-scalant volume
                mass_as(i,s)=as_dose*((Qf*deltat)/1000);%determine the mass of anti-scalant based on the feed water volume in that time step
                
                
                % Loss of Water Probability
                if (tank_vol_prev+Qp(i,s)*deltat-rinsing(i,s))<water_demand(s)
                    water_not_met_hourly=water_not_met_hourly+1;
                end
                
                %Set the tank_vol_prev to the tank_vol for this loop iteration
                tank_vol_prev=tank_vol(i,s);
                
                % Ensure if tank is empty, the tank volume does not become negative
                if tank_vol(i,s)<=0
                    tank_vol(i,s)=0;
                    tank_vol_prev=0;
                    tank_full=0;
                elseif tank_vol(i,s)>= tank_vol_options
                    tank_vol(i,s)=tank_vol_options;
                    tank_vol_prev=tank_vol_options;
                    tank_full=1;
                    
                end
                            
            Batt_SOC(i,s)=(Energy_hourly(i,s)+Power_use(i,s)+Batt_SOC_Prev);
            Batt_SOC_Prev=Batt_SOC(i,s);
            
            if Batt_SOC(i,s)>Max_BattStor %Is there more power than the capacity of the battery
                overcharge = overcharge+1;
                Batt_SOC(i,s)=Max_BattStor;
          
            elseif Batt_SOC(i,s)<0
                Batt_SOC(i,s)=0;
            end
     
            
                
        end
            
        end
        mass_as_used = sum(sum(mass_as));
        Water_NotMet=water_not_met_hourly/(simulation_day*24);
        
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
        
        %% Annualized Replacement costs
        disc_rate=0.12; % discount rate of 12% from http://heep.hks.harvard.edu/files/heep/files/dp35_meeks.pdf
        system_life=25; %25 years
        Equiv_Ann_cost_factor=(disc_rate*(1+disc_rate)^system_life)/(((1+disc_rate)^system_life)-1);
        AnnCostsRepl=CCmemb*membReplRate+FilterCost*FilterReplRate+CCpump*pumpReplRate+CCmotor*motorReplRate+CCpostchems*postchemsReplRate;
        
        AnnCost=(solarCost+PV.BOS.CC+PV.Batt.CC+PV.Batt.ReplCost+wind_cost)*Equiv_Ann_cost_factor;
        
        AnnCostCC=(CCmemb+PresVes+CCpump+CCmotor+CC_Filter+CC_anti_sc+CCTank+CCpipes)*Equiv_Ann_cost_factor;
        
        PVRO.AnnTotal=AnnCost+AnnCostCC+AnnCostsRepl+Cost_as;
        
        PVRO_PenaltyCost=(PVRO.AnnTotal)+(10^Penalty_Glob)*max(0,(Water_NotMet-LOWP_Global));
%{        
        % Reshaping and Visualizing Data to test the simulation
        
    Qp_singlevector=reshape(Qp',simulation_day*24,1);
    tank_vol_singlevector=reshape(tank_vol',simulation_day*24,1);
    Energy_singlevector=reshape(Energy_sum',simulation_day*24,1);
    FF_singlevector=reshape(FF',simulation_day*24,1);
    rinsing_singlevector=reshape(rinsing',simulation_day*24,1);
       
        
figure, plot(Qp_singlevector)
xlabel('hour');
ylabel('Qp [m^{3}]');
figure, plot(tank_vol_singlevector)
xlabel('hour');
ylabel('Tank Volume [m^{3}]');
figure, plot(Energy_singlevector)
xlabel('hour');
ylabel('PV energy [kWh]');
figure, plot(solarPower)
xlabel('hour');
ylabel('PV Power [kW]');
figure, plot(rinsing_singlevector)
xlabel('hour');
ylabel('Rinsing [m^{3}]');
figure, plot(W);
xlabel ('hour');
ylabel ('Wind Power [kW]');
%}        
        %save the workspace
        save('SIM_Australia_LOWP0.07_Fract0.8_ps200_gen200_graphs.mat');
        %%
    end
