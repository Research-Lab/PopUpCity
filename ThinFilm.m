% 1 month simulation for January using a thin film solar panel
% http://www.firstsolar.com/-/media/First-Solar/Technical-Documents/Series-6-Datasheets/Series-6-Datasheet.ashx
% Last Modified May 24, 2020

panelsize = 2.47; %m^2
npanel = 18.2/100; % FS-6450 FS-6450A
pmax = 450; %W 5

data = xlsread('Brandon');
SolarIn = data(:,6);

PowerProducedThinFilm = pmax*npanel*SolarIn*panelsize; %kW