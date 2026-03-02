function [station_timeseries] = interpolate_to_stations(data_grid, aohi_lat, aohi_lon, station_lat, station_lon)
% interpolate_to_stations.m
% Interpolates global grid data to specific station coordinates.
%
% Inputs:
%   data_grid    - 3D array (lat x lon x time) of global data
%   aohi_lat     - Vector of latitude coordinates for the grid
%   aohi_lon     - Vector of longitude coordinates for the grid
%   station_lat  - Station latitude (degrees, -90 to 90)
%   station_lon  - Station longitude (degrees, -180 to 180 or 0 to 360)
%
% Outputs:
%   station_timeseries - Vector of interpolated values at station position

    [n_lat, n_lon, n_time] = size(data_grid);
    station_timeseries = zeros(n_time, 1);
    
    % Convert station longitude to [0, 360] range if needed
    if station_lon < 0
        station_lon = station_lon + 360;
    end
    
    % Create meshgrid for interpolation
    [LON, LAT] = meshgrid(aohi_lon, aohi_lat);
    
    % Interpolate for each time step
    for i = 1:n_time
        % Extract 2D slice at this time
        data_slice = data_grid(:, :, i);
        
        % Interpolate to station position
        station_timeseries(i) = interp2(LON, LAT, data_slice, station_lon, station_lat, 'linear');
    end
end
