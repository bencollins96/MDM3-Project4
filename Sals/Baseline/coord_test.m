%coord_test


load 'lat_long_cropped.mat'
[x,y,z] = lla2ecef(lat1,lng1,0);
scatter(x,y);