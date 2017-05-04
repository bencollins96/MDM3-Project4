function [x,fval,exitflag,output,population,score] = eaOptimFunc(sourceCoordinates,targetCoordinates,adjMatrix,impossibleIndex,nvars,lb,ub,InitialPopulationRange_Data,PopulationSize_Data,InitialPopulation)
%% This is an auto generated MATLAB file from Optimization Tool.

%% Start with the default options
options = optimoptions('ga');
%% Modify options setting
options = optimoptions(options,'InitialPopulationRange', InitialPopulationRange_Data);
%options = optimoptions(options,'MaxGenerations',20,'MaxStallGenerations', 100);
%options = optimoptions(options,'InitialPopulation', InitialPopulation');
%options = optimoptions(options, 'MutationFcn',{@mutationadaptfeasible});
options = optimoptions(options,'PopulationSize', PopulationSize_Data);
options = optimoptions(options,'HybridFcn', {  @fmincon [] });
options = optimoptions(options,'Display', 'off');
options = optimoptions(options,'PlotFcn', {  @gaplotbestf @gaplotdistance });
options = optimoptions(options,'UseVectorized', false);
options = optimoptions(options,'UseParallel', true);
[x,fval,exitflag,output,population,score] = ...
ga(@(x)eaOptim(x,sourceCoordinates,targetCoordinates,adjMatrix,impossibleIndex),nvars,[],[],[],[],lb,ub,[],[],options);
