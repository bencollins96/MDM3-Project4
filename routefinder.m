%RouteFinder

function [route_list,cost_list] = routefinder()

load 'distance_matrix.mat'
    %one of this iteration is around 456 seconds... not too good

    %indices of transplant hospitals
    transplant = [1,125,409,263,676,211,595,456,471,145,66,759,519,425,592,131,27,267,538,666,397];
 
    
    d_m(d_m> 50e3) = inf;
    route_list = cell(length(d_m),length(transplant));
    cost_list = zeros(length(d_m),length(transplant));

    for j=1:length(transplant)
    
        parfor i =2:length(d_m)
    
            [Cost, Route] = dijkstra(d_m  ,i,transplant(j));
            route_list{i,j} = Route;
            cost_list(i,j) = Cost;  
        end
    end
    

end



