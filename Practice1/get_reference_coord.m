function [xyz0, llh0_deg] = get_reference_coord(itrf_file, station_name)
% get_reference_coord.m
% Reads the ITRF2008_GNSS.SSC.txt file to find the reference coordinates
% for a given station at epoch 2005.0.

    xyz0 = [];
    fid = fopen(itrf_file, 'r');
    if fid == -1
        error('Cannot open ITRF file.');
    end
    
    % Find the latest entry for the station that is valid for epoch 2005.0
    % This is a simplified search logic. A robust parser would be more complex.
    tline = fgetl(fid);
    while ischar(tline)
        % Check if the line contains the station name and is a position line
        if contains(tline, [' ' station_name ' ']) && ~contains(tline, 'Vx')
            parts = strsplit(tline);
            % A simple check for a position line (has more than 8 parts)
            if length(parts) > 8
                try
                    x = str2double(parts{5});
                    y = str2double(parts{6});
                    z = str2double(parts{7});
                    % Store the latest valid entry
                    if ~isnan(x)
                        xyz0 = [x; y; z];
                    end
                catch
                    % Continue if line format is unexpected
                end
            end
        end
        tline = fgetl(fid);
    end
    fclose(fid);
    
    if isempty(xyz0)
        error('Reference coordinates for station %s not found.', station_name);
    end
    
    % Convert cartesian coordinates to geodetic coordinates (lat, lon, h)
    % WGS84 ellipsoid parameters
    a = 6378137.0; % semi-major axis
    f = 1/298.257223563; % flattening
    e2 = 2*f - f^2; % squared eccentricity
    
    p = sqrt(xyz0(1)^2 + xyz0(2)^2);
    lambda = atan2(xyz0(2), xyz0(1));
    
    % Iterative calculation for latitude
    phi = atan(xyz0(3) / (p * (1 - e2)));
    for i = 1:5 % a few iterations are sufficient
        N = a / sqrt(1 - e2 * sin(phi)^2);
        h = p / cos(phi) - N;
        phi = atan(xyz0(3) / (p * (1 - e2 * N / (N + h))));
    end
    N = a / sqrt(1 - e2 * sin(phi)^2);
    h = p / cos(phi) - N;
    
    llh0_deg = [rad2deg(phi); rad2deg(lambda); h];
end