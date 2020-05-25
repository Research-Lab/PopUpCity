%system_life = 1 %number of years for simulation term

str = input('Poly (1), Mono (2), Thin Film (3), LGMono (4)?\n')
num_panel = input('Number of Panels?\n')
 

if (str ==1) 

    %{ 
        Polycrystalline specifications: https://www.canadiansolar.com/wp-content/uploads/2019/12/Canadian_Solar-Datasheet-BiKu_CS3U-PB-AG_High-Efficiency_EN.pdf
        Price $100 *Will be updated
    %}
    
    Solar.CC = 100*num_panel
    %Balance of System Costs
% BOS_structural=(0.12*Wdc) %racking etc.
% BOS_electrical=0.27*Wdc % Wholesale prices for conductors, switches,
% combiners and transition boxes, as well as conduit, grounding equipment,
% monitoring system or production meters, fuses, and breakers
% 
% http://www.nrel.gov/docs/fy16osti/66532.pdf -- page 14

SA.BOS.CC=(0.12*(280)+0.27*280)*(num_panel);

Total.CC = Solar.CC+SA.BOS.CC
    
    
elseif (str ==2)
    
     %{ 
        Monocrystaline specifications: https://www.canadiansolar.com/wp-content/uploads/2019/12/Canadian_Solar-Datasheet-BiKu_CS3U-MB-AG_EN.pdf
        Price $150 *Will be updated
    %}
    
    Solar.CC = 150*num_panel
    %Balance of System Costs
% BOS_structural=(0.12*Wdc) %racking etc.
% BOS_electrical=0.27*Wdc % Wholesale prices for conductors, switches,
% combiners and transition boxes, as well as conduit, grounding equipment,
% monitoring system or production meters, fuses, and breakers
% 
% http://www.nrel.gov/docs/fy16osti/66532.pdf -- page 14

SA.BOS.CC=(0.12*(280)+0.27*280)*(num_panel);

Total.CC = Solar.CC+SA.BOS.CC

elseif (str ==3)
    
     %{ 
        Thin Film specifications: http://www.firstsolar.com/-/media/First-Solar/Technical-Documents/Series-6-Datasheets/Series-6-Datasheet.ashx
        Price $50 *Will be updated
    %}
    
    Solar.CC = 50*num_panel
    %Balance of System Costs
% BOS_structural=(0.12*Wdc) %racking etc.
% BOS_electrical=0.27*Wdc % Wholesale prices for conductors, switches,
% combiners and transition boxes, as well as conduit, grounding equipment,
% monitoring system or production meters, fuses, and breakers
% 
% http://www.nrel.gov/docs/fy16osti/66532.pdf -- page 14

SA.BOS.CC=(0.12*(280)+0.27*280)*(num_panel);

Total.CC = Solar.CC+SA.BOS.CC

elseif (str ==4)
    
     %{ 
        LG Monocrystalline specifications: https://d3g1qce46u5dao.cloudfront.net/data_sheet/lg4.pdf
        Price $200 *Will be updated
    %}
    
    Solar.CC = 200*num_panel
    %Balance of System Costs
% BOS_structural=(0.12*Wdc) %racking etc.
% BOS_electrical=0.27*Wdc % Wholesale prices for conductors, switches,
% combiners and transition boxes, as well as conduit, grounding equipment,
% monitoring system or production meters, fuses, and breakers
% 
% http://www.nrel.gov/docs/fy16osti/66532.pdf -- page 14

SA.BOS.CC=(0.12*(280)+0.27*280)*(num_panel);

Total.CC = Solar.CC+SA.BOS.CC
end

disp(Solar.CC)
disp(Total.CC)


    
    
    
        
        
        
