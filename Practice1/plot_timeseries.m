function plot_timeseries(time, data, station_name, jump_times)
% plot_timeseries.m
% Plots the East, North, and Up time series for a station.

    figure('Name', [station_name ' Time Series'], 'Color', 'w');
    
    components = {'East', 'North', 'Up'};
    
    for i = 1:3
        subplot(3, 1, i);
        hold on;
        plot(time, data(:, i), '.', 'MarkerSize', 4);
        
        % Plot discontinuities
        if ~isempty(jump_times)
            for j = 1:length(jump_times)
                xline(jump_times(j), '--r', 'LineWidth', 1.5);
            end
        end
        
        ylabel([components{i} ' (mm)']);
        grid on;
        
        if i == 1
            title([station_name ' Time Series']);
        end
        
        if i == 3
            xlabel('Year');
        end
        
        hold off;
    end
    
    saveas(gcf, ['./output/' station_name '_timeseries.png']);
end