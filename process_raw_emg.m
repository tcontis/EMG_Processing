function [snrd, filtered_data] = process_raw_emg(data, fs, show_plot)
    L = length(data);
    if nargin < 3
        show_plot = false;
    end
    
    %% Step 1: Filter out DC and low-frequency noise (20Hz)
    [B1, A1] = butter(4, 20/(0.5*fs), 'high'); % 4th order highpass filter @ 20Hz
    data_filt = filtfilt(B1, A1, data);
    
    %% Step 2: Filter out artifacts
    %{
    ff = fs/L*(0:L-1);
    plot(ff, (abs(fft(data_filt))));
    [pks,locs,~,p] = findpeaks((abs(fft(data_filt))), 'MinPeakProminence', 5e-4);
    disp(size(p));
    hold on
    plot(locs*fs/L, pks, 'o')
    %}
    
    %% Step 3: Rectify
    data_rect = abs(data_filt);
    
    %% Step 4: Find baseline magnitude to separate signal from noise
    [B3, A3] = butter(4, 1/(0.5*fs), 'low'); % 4th order lowpass filter @ 1Hz
    data_envelope = filtfilt(B3, A3, data_rect);
    
    baseline = rms(data_envelope);
    signal_indices = data_envelope > baseline;
    noise_indices = data_envelope < baseline;
    
    if show_plot
    
        figure;
        plot(data_rect, 'color', 'cyan')
        hold on
        plot(data_envelope, 'color', 'magenta')
        yline(baseline)
        legend(["Rectified Data","Data Envelope","Baseline"]);
    end
    snrd = rms(data_rect(signal_indices))^2/rms(data_rect(noise_indices))^2;
    filtered_data = data_rect;
end