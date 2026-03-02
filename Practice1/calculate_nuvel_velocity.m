function v_nuvel_enu = calculate_nuvel_velocity(nuvel_file, station_name, xyz0, llh0_deg)
% calculate_nuvel_velocity.m
% Computes the horizontal velocity from the NNR-NUVEL 1A model.

    % Define plate for each station
    switch station_name
        case {'NRIL', 'KIRU', 'MAR6', 'ONSA', 'MORP', 'HOFN', 'NYA1', 'TROM'}
            plate_name = 'Eurasia';
        case {'REYK', 'SCOR', 'ALRT', 'THU3', 'KELY', 'QAQ1', 'SCH2', 'CHUR', 'FLIN', 'RESO', 'HOLM', 'FAIR'}
            plate_name = 'North_America';
        otherwise
            error('Plate for station %s is not defined.', station_name);
    end
    
    % Read NUVEL data
    opts = detectImportOptions(nuvel_file, 'FileType', 'text');
    opts.DataLines = [2, inf]; % Skip header
    nuvel_data = readtable(nuvel_file, opts);
    nuvel_data.Properties.VariableNames = {'PlateName', 'Wx', 'Wy', 'Wz'};
    
    % Find the Euler vector for the specified plate
    plate_idx = find(strcmp(nuvel_data.PlateName, plate_name));
    if isempty(plate_idx)
        error('Plate %s not found in NUVEL file.', plate_name);
    end
    
    Omega_rad_Ma = [nuvel_data.Wx(plate_idx), nuvel_data.Wy(plate_idx), nuvel_data.Wz(plate_idx)]';
    
    % Convert units from rad/Ma to rad/year
    Omega_rad_yr = Omega_rad_Ma / 1e6;
    
    % Calculate velocity in geocentric coordinates (v = Omega x r)
    v_xyz_m_yr = cross(Omega_rad_yr, xyz0);
    
    % Transform velocity to local ENU system
    phi_rad = deg2rad(llh0_deg(1));
    lambda_rad = deg2rad(llh0_deg(2));
    
    R = [-sin(lambda_rad),              cos(lambda_rad),             0;
         -sin(phi_rad)*cos(lambda_rad), -sin(phi_rad)*sin(lambda_rad), cos(phi_rad);
          cos(phi_rad)*cos(lambda_rad),  cos(phi_rad)*sin(lambda_rad), sin(phi_rad)];
          
    v_nuvel_enu = R * v_xyz_m_yr; % [East; North; Up] in m/year
end