function [x,fval,exitflag,output,population,score] = eaOptimFunc(sourceCoordinates,targetCoordinates,adjMatrix,impossible,xind,yind,nvars,lb,ub,InitialPopulationRange_Data,PopulationSize_Data)
%% This is an auto generated MATLAB file from Optimization Tool.

%% Start with the default options
options = optimoptions('ga');
%% Modify options setting
options = optimoptions(options,'InitialPopulationRange', InitialPopulationRange_Data);
options = optimoptions(options,'PopulationSize', PopulationSize_Data);
options = optimoptions(options,'HybridFcn', {  @fmincon [] });
options = optimoptions(options,'Display', 'off');
options = optimoptions(options,'PlotFcn', {  @gaplotbestf @gaplotdistance });
options = optimoptions(options,'UseVectorized', false);
options = optimoptions(options,'UseParallel', true);
[x,fval,exitflag,output,population,score] = ...
ga(@(x)eaOptim(x,sourceCoordinates,targetCoordinates,adjMatrix,impossible,xind,yind),nvars,[],[],[],[],lb,ub,[],[],options);