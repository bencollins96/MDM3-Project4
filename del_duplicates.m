%Remove duplicates

Cell1  = {Names,num2cell(Lat),num2cell(Lng)};

num_el = length(Cell1{1});

for i=1:num_el
    
    lat_lng = [Cell1{2}{i}, Cell1{3}{i}];
    
    for j = 1:num_el
        
        new_lat_lng = [Cell1{2}{j},Cell1{3}{j}];
        pass1 = (lat_lng(1) == new_lat_lng(1));
        pass2 = (lat_lng(2) == new_lat_lng(2));
        
        
        
        
        if pass1 && pass2 && (j>i)
            
            Cell1{2}{j} = NaN;
            Cell1{3}{j} = NaN;
        end
    end
end

%Duplicates covnerted to NaNs, now time to delete.


lat1 = cell2mat(Cell1{2});
lng1 = cell2mat(Cell1{3});
Names1 = Cell1{1};

lng1(isnan(lat1)) = [];
Names1(isnan(lat1)) = [];
lat1(isnan(lat1)) = [];


          
    