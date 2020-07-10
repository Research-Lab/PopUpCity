% This function determines the cost of the Solar_ReverseOsmosis_PV-SmallBattery System
% Determine the System Cost with the replacement costs and anti-scalant
% costs to figure out which system is the best choice for a given community
%
% Last Modified: July 9, 2020
% Added Battery storage to enable 'steady-state' operation

function PVRO_PenaltyCost=FindCost_PenFun(x,sim_life,LOWP_Global,Penalty_Glob,solarPower)

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

%% Capital Costs


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
