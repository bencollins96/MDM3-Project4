function [Costs,Paths] =baseline(lat1,lng1)

Range = 100000;
TotalRange = 4*10^6;

%Get Positions & distance matrix

distMatrix = squareform(pdist([lat1,lng1],@Haversine));

%Make adjacency Matrix
adjMatrix = ones(length(lat1));
adjMatrix(distMatrix > Range) = 0;

transHos = [125,409,263,676,211,595,456,471,145,66,759,519,425,592,131,27,267,538,666,397];
transHos = unique(transHos);



[Costs,Paths] = dijkstra(adjMatrix,distMatrix,transHos);

return

for i =1:size(Costs,1)
    for j = 1:size(Costs,2)
        if Costs(i,j)  > TotalRange
            Costs(i,j) = NaN;
            Paths{i,j} = NaN;
        end
    end
end

geoshow(lat1,lng1,'DisplayType','Point');
hold on

for i =1:size(Paths,1)
    for j =1:size(Paths,2)
        if isnan(Paths{i,j})
            continue;
        end

        plot_route(Paths{i,j},lat1,lng1);
    end
end

    function plot_route(route,lat,lng)

        latlng = [];
        for n=1:length(route)
            latlng = [latlng;[lat(route(n)),lng(route(n))]];
        end
        geoshow(latlng(:,1),latlng(:,2));
    end
    

end