function v_up = interpolate_gia_rate(gia_file, llh0_deg)
% interpolate_gia_rate.m
% Interpolates the vertical crustal deformation rate from a GIA model grid
% to a specific station location.

    % Load the GIA model data
    gia_data = load(gia_file);
    
    % Extract grid vectors and velocity matrix
    lat_grid = -89.5:1:89.5;
    lon_grid = 0.5:1:359.5;
    fields = fieldnames(gia_data); 
    v_crust = gia_data.(fields{1});
    
    % Station coordinates
    station_lat = llh0_deg(1);
    station_lon = llh0_deg(2);
    
    % Handle longitude wrapping (0 to 360 vs -180 to 180)
    if station_lon < 0
        station_lon = station_lon + 360;
    end
    
    % Perform 2D interpolation
    % interp2 requires grid vectors to be monotonic and plaid.
    % 'lat' is descending, so we flip it and the velocity matrix vertically.
    v_up = interp2(lon_grid, flipud(lat_grid), flipud(v_crust), station_lon, station_lat, 'linear');
end