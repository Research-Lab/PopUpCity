%Cost Model and Simulation for Water Filtration System
%Neeha Rahman + Hannah Yorke Gambhir + Melina Tahami
%Last Updated: June 19, 2020

%% Design Variables

%  Design Variable 1 = Antiscalant [None (0), F135 (1), F260(2)]
x(1)= randi(3); %for testing
%  Design Variable 2 = Rinsing [ NoRinse (0), Rinse (1) ]
x(2)= randi(2); %for testing
%  Design Variable 3 = continuous variable, length of time before replacing membrane in days
x(3)= randi(60); %for testing
%  Design Variable 4 = Number of Filtration Membranes [1 (1), 2 (2), 3 (3), 4 (4), 5 (5), 6 (6), 7 (7), 8 (8), 9 (9), 10 (10)]
x(4)= randi(10); %for testing
%  Design Variable 5 = Type of Membrane [1 (RO membrane), 2 (UF membrane), 3 (MF membrane), 4 (NF membrane)]
x(5)= randi(4); %for testing
%  Design Variable 6 = RO membrane filtration rate [1 (1), 2 (2), 3 (3), 4 (4), 5 (5), 6 (6), 7 (7), 8 (8), 9 (9), 10 (10), 11 (11), 12 (12)]
x(6)= randi(12); %for testing
%  Design Variable 7 = MF membrane filtration rate [1 (1), 2 (2)]
x(7)= randi(2); %for testing
%  Design Variable 8 = UF membrane filtration rate [1 (1), 2 (2), 3(3)]
x(8)= randi(3); %for testing
%  Design Variable 9 = NF membrane filtration rate [1 (1), 2 (2), 3 (3), 4 (4)]
x(9)= randi(4); %for testing
%  Design Variable 10 = Tank size selected
x(10)= randi(20); %for testing
%  Design Variable 11 = Number of solar panels -->choose battery/energy storage (Continuous)
                      %  such that the beginning increase in power is met, e.g. storage = 0.1*PV_Watt_peak
% Design Variable 12 = Model of Solar Panel
% Design Variable 13 = Model of Wind Turbine [1 (1), 2 (2), 3 (3), 4 (4)]
x(13)= randi(4); %for testing

%% Call in Cost Function 

run('Cost_Function');

function [mass_as_used,Water_NotMet,Qf_memb,Max_BattStor]=Combined_code(x,MCfit,system_life,PVpower)
DailyVol=10;

%% Constant Values for Simulation

simulation_day=365*system_life;%Number of days for the simulation time

%% Anti-Scalant Dosing
Dose_F135 = 3.9; % in mg/L Dose rate for anti-scalant based on Flocon calculator (Flodose)
density_F135=1.165e-3; % in mg/mL Flocon 135 density = 1.165±0.035 g/cm3
as_dose_f135 = Dose_F135 * 1000 * (1/density_F135); %converted to mL / m3 for ease of calculations

Dose_F260 = 3.9; % in mg/L Dose rate for anti-scalant based on Flocon calculator (Flodose)
density_F260=1.35e-3; % in mg/mL Flocon 260 density = 1.35±0.05 g/cm3
as_dose_f260 = Dose_F260 * 1000 * (1/density_F260); %converted to mL / m3 for ease of calculations

%System Conditions
p_psi = 300;
p = p_psi * 0.0689476;%pressure in bar
p_osm=1.9;
v_rinse=40/1000;% in m3  %40L per rinse
RR_sys=0.75; %recovery ratio is 75%

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
membrane=x(5); %Type of Membrane [1 (RO membrane), 2 (UF membrane), 3 (MF membrane), 4 (NF membrane)]

if x(5) == 1 %A RO membrane is selected
    x(6) = membraneRO(:,6);
    filtration_rate = x(6)*x(4)
   
elseif x(5) == 2 %A UF membrane is selected 
    
elseif x(5) == 3 %A MF membrane is selected

elseif x(5) == 4 %A NF membrane is selected 
    
end 
    

A=A_RO*num_membrane;%total active membrane area is the area of the RO module x number of RO modules
CF=1/(1-RR_sys);%concentration factor
p_osm_avg=p_osm*(exp(0.7*RR_spec))*CF;% average osmotic pressure considering concentration polarization 
Qp=Kw_init*(A)*(p-p_osm_avg);%m3/h
Qf=(1/RR_sys)*(Qp);
tank_vol_options = 'watertank'; %tank volume options for the design variable
max_tank_vol=tank_vol_options(x(10));
    
    
numPVpanel=x(11);% number of pv panels [1-50]
mod_pp = x(12); % model of the solar panel selected [1-9]
mod_wind = x(13); %Model of Wind Turbine [1 (1), 2 (2), 3 (3), 4 (4)]


%% Initialization of Values

hour=0;
deltat=1;
tank_full=1;
tank_vol=zeros(simulation_day,24);
tank_vol_prev=max_tank_vol*1;
days_nMem=0;
water_not_met_hourly=0;
num_modules_replaced=0;% counter for number of modules replaced
rinsing_flag=0;%rinsing flag to catch everytime a rinse has occured 
hour=0;
deltat=1;

PVEnergy_sum=zeros(simulation_day,24);
PVEnergy_hourly=zeros(simulation_day,24);
num_hrs_RO=zeros(1,simulation_day);
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

PumpEnergy=(27.78*p*Qf_memb/eff_hp)*deltat/1000; %kW is unit of PumpEnergy
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
    
  
   %Power Strategy - changing because also wind  
    
   Energy_prev=0;
    %foundsunset=0;
    
  
    %Power Strategy
    
    for s=1:24
        
        % PVPower uses PVpower in kW/m^2, and multiplies by the panel size (m^2),
        % number of panels and panel efficieny
        PVEnergy_sum(i,s)=solarPower(s)*deltat+Energy_prev;
        Energy_prev=PVEnergy_sum(i,s);
        PVEnergy_hourly(i,s)=solarPower(s)*deltat;
        
        if s>12 && (foundsunset==0 && solarPower(s)==0)
        sunset_hr=s;
        foundsunset=1;
        end
    end
    
    
    
    % Number hours run
    num_hrs_RO(i)=round(PVEnergy_sum(i,24)/PumpEnergy);
    Pump_EnergyReqt=PVEnergy_sum(i,24)/num_hrs_RO(i);
    enough_energy=0;
    num_hours_run=0;
    
    rinsing_flag=0;
    PV_Batt_RunningSum_Prev=0;
    Batt_SOC_Prev=0;
    
    
    turn_on=turn_off-num_hrs_RO(i)-1;
    
    for s=1:24
            
        if s>turn_on
            enough_energy=1;
        end
        
        
        % Rinsing
        
        if (rinsing_flag==0 && rinse==2)
            
            if num_hours_run==num_hrs_RO(i)
                rinsing_flag=1;
                rinsing(i,s)=v_rinse;
            elseif s==24 && num_hrs_RO(i)>=1
                rinsing_flag=1;
                rinsing(i,s)=v_rinse;
            end
        else
            rinsing(i,s)=0;
        end
        
        FF(i,s)=findPermeability(days_nMem,num_hours_run,MCfit(1),MCfit(2), MCfit(3),MCfit(4));
        
        if enough_energy==1 && num_hours_run<=num_hrs_RO(i)
            % Run system
            Qp(i,s)=max(0,(Kw_init*FF(i,s)*A*(p-p_osm))); 

            %Battery
            PV_E_dif(i,s)=PVEnergy_hourly(i,s)-Pump_EnergyReqt;
            Power_use(i,s)=-Pump_EnergyReqt;
            
            num_hours_run=num_hours_run+1;
        else
            Qp(i,s)=0;
            %Battery
            PV_E_dif(i,s)=PVEnergy_hourly(i,s);
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
        
        Batt_SOC(i,s)=PVEnergy_hourly(i,s)+Power_use(i,s)+Batt_SOC_Prev;
        Batt_SOC_Prev=Batt_SOC(i,s);
        PV_Batt_RunningSum(i,s)=PV_E_dif(i,s)+PV_Batt_RunningSum_Prev;
        PV_Batt_RunningSum_Prev=PV_Batt_RunningSum(i,s);
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
