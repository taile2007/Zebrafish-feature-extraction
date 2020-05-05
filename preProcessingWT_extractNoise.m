function [filtered_fishData] = preProcessingWT_extractNoise(fishData)
    dataForWT = cell(numel(fishData),1);
    for i = 1: numel(fishData)       
        dataForWT{i}(:,1) = 1: 2^(round(log2(length(fishData{i}(:,1)))) - 1);
        dataForWT{i}(:,2) = fishData{i}(1: 2^(round(log2(length(fishData{i}(:,1)))) - 1));    
        swa = cell(numel(fishData),1);
        swd = cell(numel(fishData),1);
        nswd = cell(numel(fishData),1);
        nswa = cell(numel(fishData),1);
        ThreshML = cell(numel(fishData),1);
        [swa{i}, swd{i}]= swt(dataForWT{i}(:,2), 10,'coif5');
        ThreshML{i} = wthrmngr('sw1ddenoLVL','sqrtbal_sn',swd{i},'mln');
        %bal_sn  sqrtbal_sn
        % sqtwolog: universal thereshold
        % thr = wthrmngr('sw1ddenoLVL','sqtwolog',swtdec,scale)
        % thr = wthrmngr('sw1ddenoLVL','rigrsure',swtdec,scale)
        % thr = wthrmngr('sw1ddenoLVL','heursure',swtdec,scale)
        % thr = wthrmngr('sw1ddenoLVL','minimaxi',swtdec,scale)
        % mln is scale: one, sln
        selectThrFunc = '1';
        for k = 1: 9
           nswd{i}(k,:) =  thrFunction(swd{i}(k,:), ThreshML{i}(k), selectThrFunc);
        end
        nswd{i}(10,:) = zeros(1, length(dataForWT{i}));
        nswa{i}(10,:) = zeros(1, length(dataForWT{i}));
        filtered_fishData{i} = iswt(nswa{i}, nswd{i},'coif5');
end
