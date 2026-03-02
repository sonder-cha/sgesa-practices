function [params, residuals] = estimate_kinematics(time_year, enu_coords, discontinuity_file, station_name)
% estimate_kinematics.m
% Estimates kinematic parameters (offset, trend, annual signal) from a
% time series using least squares adjustment, now handling discontinuities.

    num_epochs = length(time_year);
    params = zeros(3, 4); % For E, N, U components; 4 params each [offset, trend, cos, sin]
    residuals = zeros(size(enu_coords));
    
    % --- Handle Discontinuities ---
    % Find jump times for the current station
    jump_times = find_discontinuities(discontinuity_file, station_name);
    num_jumps = length(jump_times);
    fprintf('Found %d discontinuities for station %s.\n', num_jumps, station_name);

    % --- Build the Design Matrix A ---
    t0 = time_year(1);
    t = time_year - t0;
    omega = 2 * pi; % Frequency for annual signal (time is in years)
    
    % Basic design matrix for offset, trend, and annual signal
    A = [ones(num_epochs, 1), t, cos(omega * t), sin(omega * t)];
    
    % Augment the design matrix with columns for each jump
    for j = 1:num_jumps
        jump_col = zeros(num_epochs, 1);
        % Set to 1 for all epochs after the jump
        jump_col(time_year >= jump_times(j)) = 1;
        A = [A, jump_col];
    end
    
    % --- Perform Least Squares for each component ---
    for i = 1:3 % Loop through E, N, U components
        l = enu_coords(:, i);
        
        % Least Squares Solution: x = (A'A)^-1 * A'l
        x_hat = (A' * A) \ (A' * l);
        
        % Store the first 4 parameters (offset, trend, annual)
        % The other parameters in x_hat are the jump offsets
        params(i, :) = x_hat(1:4)';
        
        % Calculate residuals: e = l - Ax (using the full parameter vector)
        residuals(:, i) = l - A * x_hat;
    end
end