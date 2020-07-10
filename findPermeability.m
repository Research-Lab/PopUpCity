% Function to calculate the permeability as a function of time at a given
% hour for intermittent operation when rinsing/no rinsing, AS or no
% antiscalant etc is used
%
% Last Modified: September 21, 2017
% Changed the fit to follow the format of Abass and Al-Bastaki
% Added linear decay to the model


function [Kw_norm]=findPermeability(day,t,a,b,c,d)

%% Equations for the model
%Format: eqn (case3, 1:n)=[a,b,c,m]; 
%for the overall model for all days of the permeability decline f1(hours), 
% an exponential fit was performed on the normalized data
% f1(hours)= a*exp(-b*day_h)+c 
%where day_h is time in hours since the start of the membrane use, and the
%number of hours in each day is assumed to be 0-7 (8)

%for each individual day, the permeability decline was characterized using
%a linear model, where f2(hours)=m*t+q is the hourly decline
%where t is part of the set (0-7)

%% Variables of the fit 
% t is the time in the day (0-n hours)
% day_t is the day of the simulation to get 
% cn is the 'case number' to access the correct equation, e.g.eqn(cn,2) 

%% Calculating the permeability

Kw_norm=min(1,(a*exp(b/(c+day)))+d*(t-1));
