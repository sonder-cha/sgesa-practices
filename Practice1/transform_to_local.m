function enu_coords = transform_to_local(xyz, xyz0, llh0_deg)
% transform_to_local.m
% Transforms geocentric cartesian coordinates to a local horizontal system
% (East, North, Up).

    num_epochs = size(xyz, 1);
    enu_coords = zeros(num_epochs, 3);
    
    phi_rad = deg2rad(llh0_deg(1));
    lambda_rad = deg2rad(llh0_deg(2));
    
    % Rotation matrix from XYZ to ENU
    R = [-sin(lambda_rad),              cos(lambda_rad),             0;
         -sin(phi_rad)*cos(lambda_rad), -sin(phi_rad)*sin(lambda_rad), cos(phi_rad);
          cos(phi_rad)*cos(lambda_rad),  cos(phi_rad)*sin(lambda_rad), sin(phi_rad)];
      
    for i = 1:num_epochs
        % Difference vector
        d_xyz = xyz(i, :)' - xyz0;
        
        % Rotate
        enu = R * d_xyz;
        
        % Store as [East, North, Up]
        enu_coords(i, :) = enu';
    end
end