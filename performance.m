function perf = performance(true_labels,pred_labels)

idx = (true_labels()==0);

p = length(true_labels(idx));
n = length(true_labels(~idx));
N = p+n;

if p < n
    idx = (true_labels()==1);
    p = length(true_labels(idx));
    n = length(true_labels(~idx));
end
tp = sum(true_labels(idx)==pred_labels(idx));
tn = sum(true_labels(~idx)==pred_labels(~idx));
fp = n-tn;
fn = p-tp;

tp_rate = tp/p;
tn_rate = tn/n;

precision = tp/(tp+fp);
if isnan(precision)
    precision = 0;
end
recall = tp_rate;
if isnan(recall)
    recall = 0;
end
f_measure = 2*((precision*recall)/(precision + recall));
if isnan(f_measure)
    f_measure = 0;
end

perf = f_measure;