% 1 month simulation for January using a monocrystalline solar panel
% https://www.canadiansolar.com/wp-content/uploads/2019/12/Canadian_Solar-Datasheet-BiKu_CS3U-MB-AG_EN.pdf
% Last Modified May 24, 2020

panelsize = 2.022*0.992; %m^2
npanel = 20.94/100; % 5% bifacial gain CS3U-365PB-AG
%Efficiency for 10% gain - 21.94%, 20% gain - 23.93%, 30% gain - 25.92%
pmax = 420; %W 5% bifacial gain CS3U-365PB-AG
%Nominal Max Power for 10% gain - 440W, 20% gain - 480W, 30% gain - 520W
data = xlsread('Brandon');
SolarIn = data(:,6);

PowerProducedMono = pmax*npanel*panelsize*SolarIn; %kW