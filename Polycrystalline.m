% 1 month simulation for January using a polycrystalline solar panel
% https://www.canadiansolar.com/wp-content/uploads/2019/12/Canadian_Solar-Datasheet-BiKu_CS3U-PB-AG_High-Efficiency_EN.pdf
% Last Modified May 24, 2020

panelsize = 2.022*0.992; %m^2
npanel = 19.09/100; % 5% bifacial gain CS3U-365PB-AG
%Efficiency for 10% gain - 20.04%, 20% gain - 21.84%, 30% gain - 23.68%
pmax = 383; %W 5% bifacial gain CS3U-365PB-AG
%Nominal Max Power for 10% gain - 402W, 20% gain - 438W, 30% gain - 475 W
data = xlsread(fullfile(path, file));
SolarIn = data(:,6);


PowerProducedPoly = pmax*npanel*panelsize*SolarIn; %kW

