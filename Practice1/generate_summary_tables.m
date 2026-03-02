function generate_summary_tables(Results, station_list)
% generate_summary_tables.m
% Prints summary tables of the analysis results to the command window.

    % --- Table 2: Kinematic Parameters ---
    fprintf('\n--- Table 2: Kinematic Parameters ---\n');
    fprintf('| %-8s | %-7s | %-20s | %-15s |\n', 'Station', 'Comp.', 'Trend (mm/year)', 'Amplitude (mm)');
    fprintf('|----------|---------|----------------------|-----------------|\n');
    for i = 1:length(station_list)
        s = station_list{i};
        fprintf('| %-8s | %-7s | %20.2f | %15.2f |\n', s, 'North', Results.(s).trend_mm_yr(2), Results.(s).amplitude_mm(2));
        fprintf('| %-8s | %-7s | %20.2f | %15.2f |\n', '', 'East', Results.(s).trend_mm_yr(1), Results.(s).amplitude_mm(1));
        fprintf('| %-8s | %-7s | %20.2f | %15.2f |\n', '', 'Up', Results.(s).trend_mm_yr(3), Results.(s).amplitude_mm(3));
        if i < length(station_list)
            fprintf('|----------|---------|----------------------|-----------------|\n');
        end
    end

    % --- Table 3: Horizontal Velocity Comparison ---
    fprintf('\n--- Table 3: GNSS vs NNR-NUVEL 1A (mm/year) ---\n');
    fprintf('| %-8s | %-14s | %-14s | %-14s | %-14s | %-14s | %-14s |\n', 'Station', 'Vn (GNSS)', 'Ve (GNSS)', 'Vn (NUVEL)', 'Ve (NUVEL)', 'Resid Vn', 'Resid Ve');
    fprintf('|----------|----------------|----------------|----------------|----------------|----------------|----------------|\n');
    for i = 1:length(station_list)
        s = station_list{i};
        vn_gnss = Results.(s).trend_mm_yr(2);
        ve_gnss = Results.(s).trend_mm_yr(1);
        vn_nuvel = Results.(s).nuvel_v_ne_mm_yr(1);
        ve_nuvel = Results.(s).nuvel_v_ne_mm_yr(2);
        res_vn = vn_gnss - vn_nuvel;
        res_ve = ve_gnss - ve_nuvel;
        fprintf('| %-8s | %14.2f | %14.2f | %14.2f | %14.2f | %14.2f | %14.2f |\n', s, vn_gnss, ve_gnss, vn_nuvel, ve_nuvel, res_vn, res_ve);
    end

    % --- Table 4: Vertical Velocity Comparison ---
    fprintf('\n--- Table 4: GNSS vs GIA Models (mm/year) ---\n');
    fprintf('| %-8s | %-12s | %-12s | %-12s | %-20s | %-20s |\n', 'Station', 'Vup (GNSS)', 'Vup (ICE-4G)', 'Vup (ICE-5G)', 'Resid (GNSS-ICE4G)', 'Resid (GNSS-ICE5G)');
    fprintf('|----------|--------------|--------------|--------------|----------------------|----------------------|\n');
    for i = 1:length(station_list)
        s = station_list{i};
        vup_gnss = Results.(s).trend_mm_yr(3);
        vup_ice4g = Results.(s).gia_v_up_mm_yr(1);
        vup_ice5g = Results.(s).gia_v_up_mm_yr(2);
        res_4g = vup_gnss - vup_ice4g;
        res_5g = vup_gnss - vup_ice5g;
        fprintf('| %-8s | %12.2f | %12.2f | %12.2f | %20.2f | %20.2f |\n', s, vup_gnss, vup_ice4g, vup_ice5g, res_4g, res_5g);
    end
    fprintf('\n');
end