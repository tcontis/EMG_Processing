data = table2array(readtable('Data/Exoskeleton_Data/Back_lifting.csv'));
t = data(:,1);
emg = data(:,2);
fs = 1/(t(2)-t(1));
L = length(emg);
[snrd, filtered_data] = process_raw_emg(emg, fs, true);
disp("SNR estimate:" + snrd);