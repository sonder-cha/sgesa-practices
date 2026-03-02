function comparison_table = compare_with_lab1(station_results, lab1_results)
% compare_with_lab1.m
% Compares AOHI-derived values with GNSS and GIA from Lab 1.
%
% Inputs:
%   station_results - Structure with AOHI results for each station
%   lab1_results    - Structure with Lab 1 results (GNSS and GIA)
%
% Outputs:
%   comparison_table - Formatted table with comparisons

    station_list = fieldnames(station_results);
    n_stations = length(station_list);
    
    fprintf('\n========================================\n');
    fprintf('Comparison: AOHI vs GNSS and GIA (Lab 1)\n');
    fprintf('========================================\n\n');
    
    for i = 1:n_stations
        station_name = station_list{i};
        fprintf('--- Station: %s ---\n', station_name);
        
        % Get AOHI values
        v_aohi = station_results.(station_name).trend_def; % mm/yr
        a_aohi = station_results.(station_name).amplitude_def; % mm
        
        % Get Lab 1 values
        if isfield(lab1_results, station_name)
            % GNSS vertical trend and amplitude (Up component, index 3)
            v_gnss = lab1_results.(station_name).trend_mm_yr(3); % mm/yr
            a_gnss = lab1_results.(station_name).amplitude_mm(3); % mm
            
            % GIA vertical rates (two models)
            v_gia_ice4g = lab1_results.(station_name).gia_v_up_mm_yr(1); % mm/yr
            v_gia_ice5g = lab1_results.(station_name).gia_v_up_mm_yr(2); % mm/yr
            
            % Print vertical trend comparison
            fprintf('  Vertical Trend (mm/yr):\n');
            fprintf('    GNSS:         %8.3f\n', v_gnss);
            fprintf('    GIA (ICE-4G): %8.3f\n', v_gia_ice4g);
            fprintf('    GIA (ICE-5G): %8.3f\n', v_gia_ice5g);
            fprintf('    AOHI:         %8.3f\n', v_aohi);
            fprintf('    GIA+AOHI (4G):%8.3f\n', v_gia_ice4g + v_aohi);
            fprintf('    GIA+AOHI (5G):%8.3f\n', v_gia_ice5g + v_aohi);
            fprintf('    Residual (4G):%8.3f\n', v_gnss - (v_gia_ice4g + v_aohi));
            fprintf('    Residual (5G):%8.3f\n\n', v_gnss - (v_gia_ice5g + v_aohi));
            
            % Print annual amplitude comparison
            fprintf('  Annual Amplitude (mm):\n');
            fprintf('    GNSS:         %8.3f\n', a_gnss);
            fprintf('    AOHI:         %8.3f\n', a_aohi);
            fprintf('    Residual:     %8.3f\n\n', a_gnss - a_aohi);
        else
            fprintf('  WARNING: No Lab 1 data found for %s\n\n', station_name);
        end
    end
    
    fprintf('========================================\n\n');
    
    % Return a simple structure
    comparison_table = station_results;
end
