function [time_mjd, xyz_coords] = load_station_data(filename)
    fid = fopen(filename);
    data = textscan(fid, '%s%s%s%n%n%n%n%n%n%n%n%n');
    fclose(fid);
    xyz_coords = [data{7}, data{8}, data{9}];
    time_mjd = data{5};
end