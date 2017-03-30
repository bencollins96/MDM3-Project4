%RouteFinder

tic()
d_m(d_m> 50e3) = inf;
route_list = cell(length(d_m));
cost_list = zeros(length(d_m));

for i =2:length(d_m)
    
    [Cost, Route] = dijkstra(d_m,i,1);
    route_list{i} = Route;
    cost_list(i) = Cost;  
end
toc()

    