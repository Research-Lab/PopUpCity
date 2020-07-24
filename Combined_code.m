%Cost Model and Simulation for Water Filtration System
%Neeha Rahman + Hannah Yorke Gambhir + Melina Tahami
%Last Updated: July 9, 2020

function [mass_as_used,Water_NotMet,Max_BattStor]=Combined_code(x,FFfit,system_life,W, solarPower, waterday, PumpEnergy,Kw_init,A,p,p_osm, Qf,v_rinse)

DailyVol=waterday;

%% Call in Cost Function 

%run('Cost_Function');

%% Design Variables

%  Design Variable 1 = Antiscalant [None (0), F135 (1), F260(2)]
%x(1)= randi(3); %for testing
%  Design Variable 2 = Rinsing [ NoRinse (0), Rinse (1) ]
%x(2)= randi(2); %for testing
%  Design Variable 3 = continuous variable, length of time before replacing membrane in days
%  Design Variable 4 = Number of Filtration Membranes [1 (1), 2 (2), 3 (3), 4 (4), 5 (5), 6 (6), 7 (7), 8 (8), 9 (9), 10 (10)]
%x(4)= randi(10); %for testing
%  Design Variable 5 = Membrane filtration rate [1 (1), 2 (2), 3 (3), 4 (4)]
%x(5)= randi(4); %for testing
%  Design Variable 6 = Tank size selected
%x(6)= randi(75); %for testing
%  Design Variable 7 = Number of solar panels -->choose battery/energy storage (Continuous)
                      %  such that the beginning increase in power is met, e.g. storage = 0.1*PV_Watt_peak
% Design Variable 8 = Model of Solar Panel
% Design Variable 9 = Model of Wind Turbine [1 (1), 2 (2), 3 (3), 4 (4)]
%x(9)= randi(4); %for testing


%% Constant Values for Simulation

system_life = 25; 
simulation_day=365*system_life;%Number of days for the simulation time


%% Anti-Scalant Dosing
Dose_F135 = 3.9; % in mg/L Dose rate for anti-scalant based on Flocon calculator (Flodose)
density_F135=1.165e-3; % in mg/mL Flocon 135 density = 1.165±0.035 g/cm3
as_dose_f135 = Dose_F135 * 1000 * (1/density_F135); %converted to mL / m3 for ease of calculations

Dose_F260 = 3.9; % in mg/L Dose rate for anti-scalant based on Flocon calculator (Flodose)
density_F260=1.35e-3; % in mg/mL Flocon 260 density = 1.35±0.05 g/cm3
as_dose_f260 = Dose_F260 * 1000 * (1/density_F260); %converted to mL / m3 for ease of calculations



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

tank_vol_options = wt(x(6),2); %tank volume options for the design variable
max_tank_vol = tank_vol_options;
CCTank = wt(x(6),1);

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
num_hrs=zeros(1,simulation_day);
Qp=zeros(simulation_day,24);
PV_E_dif=zeros(simulation_day,24);
Power_use=zeros(simulation_day,24);
water_demand=zeros(1,24);
mass_as=zeros(simulation_day,24);
Batt_SOC=zeros(simulation_day,24);
PV_Batt_RunningSum=zeros(simulation_day,24);
Batt_SOC_maximin=zeros(1,simulation_day);
BattStorageReqt_Max_Min=zeros(1,simulation_day);

%% Water and Energy Simulation

eff_syst=0.8;%the battery round trip efficiency

% power generated function for wind and solar 

%PumpEnergy=(27.78*p*Qf_memb/eff_hp)*deltat/1000; %kW is unit of PumpEnergy
rinsing=zeros(simulation_day,24);

%Water demand
    %make a consistent vector for the water demand, 9am-5pm 1m3/8hours
    water_demand_base = [0 0 0 0 0 0 0 0 0 0.125 0.125 0.125 0.125 0.125 0.125 0.125 0.125 0 0 0 0 0 0 0];
    water_demand=DailyVol*water_demand_base;

for i=1:simulation_day
    
  %Membrane Replacement Strategy
    if days_nMem<time_to_replace
    days_nMem=days_nMem+1;
    else 
        days_nMem=1;
        num_modules_replaced=num_modules_replaced+1;
    end
    
  
   %Power Strategy 
    
   Energy_prev=0;
    foundsunset=0;
    
  
    %Power Strategy
    
    for s=1:24
        
        % PVPower uses PVpower in kW/m^2, and multiplies by the panel size (m^2),
        % number of panels and panel efficieny
        Energy_sum(i,s)=solarPower(s)*deltat+Energy_prev+W(s);
        Energy_prev=Energy_sum(i,s);
        Energy_hourly(i,s)=solarPower(s)*deltat+W(s);
        
        if s>12 && (foundsunset==0 && solarPower(s)==0)
        sunset_hr=s;
        foundsunset=1;
        end
    end
    
    
    
    % Number hours run
    num_hrs(i)=round(Energy_sum(i,24)/PumpEnergy);
    Pump_EnergyReqt=Energy_sum(i,24)/num_hrs(i);
    enough_energy=0;
    num_hours_run=0;
    
    rinsing_flag=0;
    Batt_RunningSum_Prev=0;
    Batt_SOC_Prev=0;
    
    turn_off = sunset_hr; 
    turn_on=turn_off-num_hrs(i)-1;
    
    for s=1:24
            
        if s>turn_on
            enough_energy=1;
        end
        
        
        % Rinsing
        
        if (rinsing_flag==0 && rinse==2)
            
            if num_hours_run==num_hrs(i)
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
        
        if enough_energy==1 && num_hours_run<=num_hrs(i)
            % Run system
            Qp(i,s)=max(0,(Kw_init*FF(i,s)*A*(p-p_osm))); 

            %Battery
            PV_E_dif(i,s)=Energy_hourly(i,s)-Pump_EnergyReqt;
            Power_use(i,s)=-Pump_EnergyReqt;
            %add in the uv power?
            
            num_hours_run=num_hours_run+1;
        else
            Qp(i,s)=0;
            %Battery
            PV_E_dif(i,s)=Energy_hourly(i,s);
            Power_use(i,s)=0;          
        end
    
    
        %Tank Volume
        
        if tank_full ==1 % dont add the water Qp(i,s) to the tank
            tank_vol(i,s)= max_tank_vol-water_demand(s)-rinsing(i,s);
            if tank_vol(i,s)< max_tank_vol
                tank_full=0;
            else
                tank_full=1;
            end
            
        else %  tank_full ==0 % tank is not full, add the Qp(i,s)*t to the tank
            tank_vol(i,s)=min(tank_vol_prev+Qp(i,s)*deltat-water_demand(s)-rinsing(i,s),max_tank_vol);
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
            
        end
        
        Batt_SOC(i,s)=Energy_hourly(i,s)+Power_use(i,s)+Batt_SOC_Prev;
        Batt_SOC_Prev=Batt_SOC(i,s);
        PV_Batt_RunningSum(i,s)=PV_E_dif(i,s)+Batt_RunningSum_Prev;
        Batt_RunningSum_Prev=PV_Batt_RunningSum(i,s);
    end
    
    %Battery Storage vector
    BattStorageReqt_Max_Min(i)=max(PV_Batt_RunningSum(i,:))-min(PV_Batt_RunningSum(i,:));
    Batt_SOC_maximin(i)=max(Batt_SOC(i,:))-min(Batt_SOC(i,:));
end
mass_as_used = sum(sum(mass_as));
Water_NotMet=water_not_met_hourly/(simulation_day*24);   

%Battery Storage Required
MaxBattery=max(Batt_SOC_maximin);

Max_BattStor=max(BattStorageReqt_Max_Min);
locate_max=find(BattStorageReqt_Max_Min==max(BattStorageReqt_Max_Min));

Min_BattStor=min(BattStorageReqt_Max_Min);
locate_min=find(BattStorageReqt_Max_Min==Min_BattStor);


% Reshaping and Visualizing Data to test the simulation
%{
Qp_singlevector=reshape(Qp',simulation_day*24,1);
tank_vol_singlevector=reshape(tank_vol',simulation_day*24,1);
PVEnergy_singlevector=reshape(PVEnergy',simulation_day*24,1);
FF_singlevector=reshape(FF',simulation_day*24,1);
rinsing_singlevector=reshape(rinsing',simulation_day*24,1);
 
figure, plot(Qp_singlevector)
xlabel('hour');
ylabel('Qp [m^{3}]');
figure, plot(tank_vol_singlevector)
xlabel('hour');
ylabel('Tank Volume [m^{3}]');
figure, plot(PVEnergy_singlevector)
xlabel('hour');
ylabel('PV energy [kWh]');
figure, plot(solarPower)
xlabel('hour');
ylabel('PV Power [kW]');
figure, plot(rinsing_singlevector)
xlabel('hour');
ylabel('Rinsing [m^{3}]');
%}
%%


end
