%%Ultrafiltration Membrane
%https://www.wateranywhere.com/membranes/ultrafiltration-uf-membranes/polyethersulfone-uf-membranes/
%Microfiltration Membrane
%https://www.wateranywhere.com/membranes/microfiltration-mf-membranes/pvdf-microfiltration-membranes/
%{ 
Design Variables 
    dia_mem = Diameter of membrane [1.8" (1), 2.5" (2), 4" (3)]
    leng_mem = Length of membrane [12" (1), 21" (2), 40" (3)]
    num_mem = Number of membranes [1 (1), 2 (2), 3 (3), 4 (4), 5 (5), 6 (6)]
%} 
    

%system_life = 1 %number of years for simulation term

str = input('UF membrane (1) or MF membrane (2)?\n')
num_mem = input('number of membranes [1 (1), 2 (2), 3 (3), 4 (4), 5 (5), 6 (6)]\n')
dia_mem = input('choose diameter of membrane [1.8" (1), 2.5" (2), 4" (3)]\n')
leng_mem = input('choose length of membrane [12" (1), 21" (2), 40" (3)]\n') 

if (str ==1) 

    %{ 
        UF Membrane specifications: https://www.appliedmembranes.com/media/wysiwyg/pdf/membranes/ami_ultrafiltration_pes_membranes.pdf
            Maximum operating conditions: 150 psi @ 25 degrees celcius
            Maximum operating temperature: 60 degrees @ 100 psi
    %}
    
    if dia_mem ==1 %diameter is 1.8" 
   
     if leng_mem ==1 %diameter is 1.8" and length is 12"
            CCmemb =num_mem*44; %M-U1812PES
     end
    
    elseif dia_mem ==2 %diameter is 2.5"
        
        if leng_mem ==2 %diameter is 2.5" and length is 21"
            CCmemb =x(5)*256; %M-U2521PES
        elseif leng_mem ==3 %diameter is 2.5" and length is 40"
            CCmemb =x(5)*226; %M-U2540PES
        end
    
    elseif dia_mem ==3 %diameter is 4"
        
         if leng_mem ==3 %diamter is 4" and length is 40"
            CCmemb =num_mem*367; %M-U4040PES
        end
    end
    
elseif (str ==2)
    
    %{
        MF Membrane specifications: https://appliedmembranes.com/media/wysiwyg/pdf/membranes/ami_pvdf_uf_and_mf_membranes.pdf
            Maximum operating conditions: 200 psig @ 25 degrees celcius
    %}
    
   % dia_mem ==1 & leng_mem ==1 %diameter is 4" and length is 40"
        CCmemb =num_mem*397;
   
end

disp(CCmemb)

%membReplRate=365/(time to replace membrane);

    
    
    
        
        
        
