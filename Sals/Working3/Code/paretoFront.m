
%function eaOptimRunner(lat1,lng1)

% Find coordinates of source hospitals
lat = lat1(1:100);
lng = lng1(1:100);
sourceCoordinates = [lat,lng];

% Create fictitious target hospital
targetCoordinates = [lat1(456),lng1(456);lat1(471),lng1(471)];

%Set number of charging points
numChrg = 30;

% Create adjacency matrix: From hospitals to charging points only. 
numSource = size(sourceCoordinates,1);
numTarget = size(targetCoordinates,1);
adjMatrix = get_adjMatrix(numSource,numTarget,numChrg);

%Set lower and upper bound of charging point coordinates.
lb = [min(lat)*ones(numChrg,1);min(lng)*ones(numChrg,1)];
ub = [max(lat)*ones(numChrg,1);max(lng)*ones(numChrg,1)];

lbinit = [(mean(targetCoordinates(:,1))-range(lat)) * ones(numChrg,1); (mean(targetCoordinates(:,2))-range(lng)) * ones(numChrg,1)];
ubinit = [(mean(targetCoordinates(:,1))+range(lat)) * ones(numChrg,1);(mean(targetCoordinates(:,2))+ range(lng)) * ones(numChrg,1)];

%set intial population range
InitialPopulationRange_Data = [lbinit, ubinit]';

%Set Population Size -> more maybe better? our landscape is probably very
%uneven.
PopulationSize_Data = 100;

ranges = pdist2(targetCoordinates,sourceCoordinates,@Haversine);
[xind,yind] = ind2sub(size(ranges),find(ranges>2.4*10^5));
impossible = length(xind);
nvars = 2*numChrg;
[solutions,fval,exitflag,output,population,score] = pareto(sourceCoordinates,targetCoordinates,adjMatrix,impossible,xind,yind,nvars,lb,ub,InitialPopulationRange_Data,PopulationSize_Data)
% [solutions,fval,exitflag,output,population,scores] = gamultiobj(multiOptim,60,[],[],[],[],lb,ub,options)


possUnconnected = [];
possTooLong     = [];
possConnected   = [];
numberChgStns   = [];
meanHosp1       = [];
meanHosp2       = [];
for k=1:size(solutions,1)
    x = solutions(k,:);

    [costs,paths,lmean] = eaOptimView(x,sourceCoordinates,targetCoordinates,adjMatrix,xind,yind);
    chargingCoordinates = [x(1:numChrg)',x(numChrg+1:2*numChrg)'];

    clf
    usedStations = [];
    for target=1:numTarget

        for i=1:length(paths)
            path = paths{i};

            if isnan(path)
%                 disp('Path is not possible')
                continue
            end

            pathSeq = zeros(length(path),2);
            pathSeq(1,:) = sourceCoordinates(path(1),:);
            pathSeq(length(path),:) = targetCoordinates(target,:);

            for k=2:length(path)-1
                pathSeq(k,:) = chargingCoordinates(path(k)-(numSource+numTarget),:);
                usedStations = [usedStations, path(k)];
            end

%             plot(pathSeq(:,2),pathSeq(:,1),'g')
%             hold on
%             axis equal
        end
    end

    %Plot the source hospitals and the target hospitals
%     scatter(sourceCoordinates(:,2),sourceCoordinates(:,1),'r')
%     hold on 
%     scatter(targetCoordinates(:,2),targetCoordinates(:,1),'b')

    usedStations = unique(usedStations)-(size(sourceCoordinates,1)+size(targetCoordinates,1));

    %Plot charging stations (2nd only plots used charging stations)
    xChargingStations = chargingCoordinates(:,2);
    yChargingStations = chargingCoordinates(:,1);
%     scatter(chargingCoordinates(:,2),chargingCoordinates(:,1), 'k')
%     scatter(xChargingStations(usedStations),yChargingStations(usedStations),'k')

    unconnected = length(find(costs==Inf));
    tooLong = length(find(costs>2.4*10^5 & costs<10^12));
    possConnect = length(costs(costs<2.4*10^5));
    
%     disp(['Number of impossible journeys = ',num2str(impossible)])
%     disp(['Number of possible journeys that have not been connected = ',num2str(unconnected)])
%     disp(['Number of possible journeys that are too long = ',num2str(tooLong)])
%     disp(['Number of possible journeys that have been connected = ',num2str(possConnect)])
%     disp(['Number of charging stations needed = ', num2str(length(usedStations))])
%     for k=1:size(targetCoordinates,1)
%         disp(['Mean journey time to target hospital ', num2str(k),' =', num2str(lmean(k))])
%     end
    
    possUnconnected = [possUnconnected; unconnected];
    possTooLong     = [possTooLong; tooLong];
    possConnected   = [possConnected; possConnect];
    numberChgStns   = [numberChgStns; length(usedStations)];
    meanHosp1       = [meanHosp1; lmean(1)];
    meanHosp2       = [meanHosp2; lmean(2)];
    
end

    function [adjMatrix] = get_adjMatrix(numSource,numTarget,numChrg)
        n1 = numSource+numTarget+numChrg;
        n2 = numSource;
        graph1 = ones(n1,n1);
        diagonal = diag(ones(1,n1));
        adjMatrix = graph1 -diagonal;
        graph2sub = ones(n2,n2) - diag(ones(1,n2));
        graph2 = zeros(n1,n1);
        graph2(1:n2,1:n2)  = graph2sub;
        adjMatrix = adjMatrix - graph2;
        adjMatrix(n2 +1:n2+numTarget,:) =0; %No target -> elsewhere
        adjMatrix(n2 + 1: n2 + numTarget,n2 + 1: n2 + numTarget) = 0; %No target to target
        adjMatrix(n2+1:n2+ numTarget + numChrg,1:n2) = 0;
    end
