% 1 month simulation for January using a monocrystalline solar panel
% https://d3g1qce46u5dao.cloudfront.net/data_sheet/lg4.pdf
% Last Modified May 24, 2020

panelsize = 1.7*1.016; %m^2
npanel = 21.4/100; % 
pmax = 370; %W 

data = xlsread('Brandon');
SolarIn = data(:,6);

PowerProducedMonoLG = pmax*npanel*SolarIn*panelsize; %kW