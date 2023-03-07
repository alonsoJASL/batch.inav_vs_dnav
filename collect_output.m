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
st.new_0d97 = zeros(length(cases), 1, 'double');
st.new_1d2 = zeros(length(cases), 1, 'double');
st.new_1d32 = zeros(length(cases), 1, 'double');
st.old_mean_bp = zeros(length(cases), 1, 'double');
st.old_std_bp = zeros(length(cases), 1, 'double');
st.old_0d97 = zeros(length(cases), 1, 'double');
st.old_1d2 = zeros(length(cases), 1, 'double');
st.old_1d32 = zeros(length(cases), 1, 'double');

for ix=1:length(cases)
    pth = fullfile(p2f, cases{ix}, sdirs);
    old_p = fullfile(pth, out_old);
    new_p = fullfile(pth, out_new); 

    if exist(old_p, "dir")
        fname = fullfile(old_p, th_fname);
        [mn, sd, ~, scores] = readParseProdStats(fname);
        st.old_mean_bp(ix) = mn;
        st.old_std_bp(ix) = sd;
        st.old_0d97(ix) = scores(1);
        st.old_1d2(ix) = scores(2);
        st.old_1d32(ix) = scores(3);
    end
    if exist(new_p, "dir")
        fname = fullfile(new_p, th_fname);
        [mn, sd, ~, scores] = readParseProdStats(fname);
        st.new_mean_bp(ix) = mn;
        st.new_std_bp(ix) = sd;
        st.new_0d97(ix) = scores(1);
        st.new_1d2(ix) = scores(2);
        st.new_1d32(ix) = scores(3);
    end
end

T = struct2table(st);
cemrg_info(sprintf('%sNav registration issue', X));
disp(T);

writetable(T, fullfile(p2f, strcat(X,'Nav_scores.xlsx')));

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
