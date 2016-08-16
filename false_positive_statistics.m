%to simulate this problem we need to look for false positives
%a very easy way to do this is to basically make two distributions
%that have the same parameters (same mean, and same standard deviation),
%then to sample from both until we have found significance (p < 0.05)

%to start, let's declare our 'blank' variables
dist1 = []; 
dist2 = [];
sample1 = [];
sample2 = [];
updated_p_value = [];

%while dist1 and dist2 may have different numbers, they're 
%chosen from the same underlying distribution

%arguments for normrnd are (mean, standard deviation, 1 row, 1000 columns)
dist1 = normrnd(0, 1, 1, 1000); 
dist2 = normrnd(0, 1, 1, 1000);

%so in this next part we will simulate 1000 experiments, this begins with
%us having two sets of samples (so two neurons under different conditions)
%and we will then do a 2 sample t test for significance
%because these are from the same distribution there is a 1/20 chance 
%we will find significance here

for experiment=1:1000
    sample1 = datasample(dist1, 10); %draw first set, 10 samples
    sample2 = datasample(dist2, 10); %draw second set, 10 samples
    [h, p] = ttest(sample1, sample2); %t-test
    
    %so now that we have our samples, add up to 40 additional samples 
    %measuring sigificance at each addition, if we hit p < 0.04 at any time
    %this will automatically count as a false positive as we know the
    %underlying distributions are actually the same
    
    for added_sample=1:40
        if p > 0.05 %tests for the 1/20 chance our first test is sig.
            %next two lines add a single sample
            %the +10 ensures we index properly into sample1 and 2 
            sample1(added_sample + 10) = datasample(dist1, 1);
            sample2(added_sample + 10) = datasample(dist2, 1);

            [h, p] = ttest(sample1, sample2);
    
            %updated_p_value monitors the p value over each experiment
            updated_p_value(experiment, added_sample) = p;
        end 
    end
end

false_positives = [];

%now we'll scan through each experiment and see if signifcance is
%incorrectly declared
for experiment=1:1000
    significance_found = updated_p_value(experiment, :);
    %logic gate to find significance, any sigificance found will equal 1
    %and then we sum this up to simulate the finding of significance before
    %50 samples to which we would have falsely delcared victory
    if sum(significance_found <= 0.05) > 0
        false_positives(experiment) = 1;
    end 
end 

%run this script a few times and see what numbers you get
disp('The false positive rate for this simulation is...')
disp(sum(false_positives)/length(false_positives))
        