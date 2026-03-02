function [trend_grid, amplitude_grid] = estimate_global_trend_annual(data_grid, time_years)
% estimate_global_trend_annual.m
% Estimates linear trend and annual signal amplitude for each grid cell
% using least squares adjustment.
%
% Inputs:
%   data_grid   - 3D array (lat x lon x time) of data values
%   time_years  - Vector of time in decimal years
%
% Outputs:
%   trend_grid  - 2D array (lat x lon) of linear trends
%   amplitude_grid - 2D array (lat x lon) of annual signal amplitudes

    [n_lat, n_lon, n_time] = size(data_grid);
    
    % Initialize output grids
    trend_grid = NaN(n_lat, n_lon);
    amplitude_grid = NaN(n_lat, n_lon);
    
    % Reference time (start of time series)
    t0 = time_years(1);
    t = time_years - t0;
    omega = 2 * pi; % Frequency for annual signal (time is in years)
    
    % Build design matrix (same for all grid points)
    A = [ones(n_time, 1), t, cos(omega * t), sin(omega * t)];
    
    % Pre-compute (A'*A)^-1 * A' for efficiency
    ATA_inv_AT = (A' * A) \ (A');
    
    % Loop through each grid point
    for i_lat = 1:n_lat
        for i_lon = 1:n_lon
            % Extract time series for this grid point
            l = squeeze(data_grid(i_lat, i_lon, :));
            
            % Skip if all NaN or contains too many NaN values
            if sum(isnan(l)) > 0.5 * n_time
                continue;
            end
            
            % Remove NaN values if present
            valid_idx = ~isnan(l);
            if sum(valid_idx) < n_time
                % Recalculate for this specific point
                A_valid = A(valid_idx, :);
                l_valid = l(valid_idx);
                x_hat = (A_valid' * A_valid) \ (A_valid' * l_valid);
            else
                % Use pre-computed matrix
                x_hat = ATA_inv_AT * l;
            end
            
            % Extract parameters
            % x_hat = [c0; c1; a; b]
            % c0 = offset, c1 = trend, a = cos amplitude, b = sin amplitude
            trend_grid(i_lat, i_lon) = x_hat(2);
            
            % Calculate total annual amplitude: A = sqrt(a^2 + b^2)
            amplitude_grid(i_lat, i_lon) = sqrt(x_hat(3)^2 + x_hat(4)^2);
        end
    end
end
