X='i';

p2f=fullfile('~/syncdir/kcl_xnav_registration', strcat(X, 'NAV'));
cases = dir(p2f);
cases = {cases.name}';
cases(1:2) = [];

sdirs = fullfile('CEMRG', strcat(X, 'Nav'));

out_old = 'OUTPUT_OLD';
out_new = 'OUTPUT_NEW';

th_fname = 'IIR_MaxScar-repeated-voxels_prodStats.txt';

st.cases = cases;
st.new_mean_bp = zeros(length(cases), 1, 'double');
st.new_std_bp = zeros(length(cases), 1, 'double');
st.old_mean_bp = zeros(length(cases), 1, 'double');
st.old_std_bp = zeros(length(cases), 1, 'double');

for ix=1:length(cases)
    pth = fullfile(p2f, cases{ix}, sdirs);
    old_p = fullfile(pth, out_old);
    new_p = fullfile(pth, out_new); 

    if exist(old_p, "dir")
        fname = fullfile(old_p, th_fname);
        [mn, sd, thress, scores] = readParseProdStats(fname);
        st.old_mean_bp(ix) = mn;
        st.old_std_bp(ix) = sd;
        for jx=1:length(thress)
            st.(['OLD_' float2str(thress(jx))]) = scores(jx);
        end
    end

    if exist(new_p, "dir")
        fname = fullfile(new_p, th_fname);
        [mn, sd, thress, scores] = readParseProdStats(fname);
        st.new_mean_bp(ix) = mn;
        st.new_std_bp(ix) = sd;
        for jx=1:length(thress)
            st.(['NEW_' float2str(thress(jx))]) = scores(jx);
        end
    end
end

T = struct2table(st);
cemrg_info(sprintf('%sNav registration issue', X));
disp(T);

writetable(T, fullfile(p2f, strcat(X,'Nav_scores.xlsx')));
%% plot values 

figure(1)
subplot(131);
boxplot(get_values(T, '0d97'), get_groups({'Fixed', 'Original'}, size(T,1)));
title('Scores at IIR=0.97');

subplot(132);
boxplot(get_values(T, '1d2'), get_groups({'Fixed', 'Original'}, size(T,1)));
title('Scores at IIR=1.2');

subplot(133);
boxplot(get_values(T, '1d32'), get_groups({'Fixed', 'Original'}, size(T,1)));
title('Scores at IIR=1.32');

%% helper functions

function [mn, sd, thresholds, scores] = readParseProdStats(p2file)
fi = fopen(p2file, 'r');
fgetl(fi); % IIR_ line
mn_str=fgetl(fi); % BP mean
sd_str=fgetl(fi); % BP STDev
% line4=fgetl(fi); % MULTIPLE THRESHOLDS: (old version)

C=textscan(fi, 'V=%f, SCORE=%f');
carr = C{2};

mn = str2double(mn_str);
sd = str2double(sd_str);
thresholds = C{1};
scores = C{2};

fclose(fi);
end

function [values] = get_values(T, str)
values = [T.(strcat('new_', str)); T.(strcat('old_', str))]; 
end

function [ca] = get_groups(cell_arr, group_size)
cell_arr = cell_arr(:);
ca = reshape(repmat(cell_arr, 1, group_size)', length(cell_arr)*group_size, 1);
end

function [nstr] = float2str(fl)
nstr = strcat('TH_', strrep(num2str(fl), '.', 'd'));
end
