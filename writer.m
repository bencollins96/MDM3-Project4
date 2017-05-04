fileID = fopen('Loc_names.csv','w');
formatSpec = '%s \n';
[nrows,ncols] = size(Names1);
for row = 1:nrows
    fprintf(fileID,formatSpec, strcat(Names1{row,:},','));
end
fclose(fileID);


