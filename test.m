%clc; clear all

data = table2array(readtable('Data/Exoskeleton_Data/Chest_lifting.csv'));
t = data(:,1);
emg = data(:,2);
fs = 1/(t(2)-t(1));

[B_highpass, A_highpass] = butter(4, 20/(0.5*fs), 'high'); % 4th order highpass filter @ 20Hz
data_filt = filtfilt(B_highpass, A_highpass, emg);
snrd = estimate_snr(data_filt, fs, true);

%[snrd, filtered_data] = process_raw_emg(emg, fs, true);

disp("SNR estimate:" + snrd);