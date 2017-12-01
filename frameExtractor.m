function [outputFld] = frameExtractor()
fileList = dir('images/**/*.avi');
for i = 1:length(fileList)
    obj = VideoReader(fullfile(fileList(i).folder,fileList(i).name));
    [outputFld{i},name,~] = fileparts(fullfile(fileList(i).folder,fileList(i).name));
    if ~isfolder(fullfile(outputFld{i},name))
        mkdir(fullfile(outputFld{i},name))
    end
    while hasFrame(obj)
        this_frame = readFrame(obj);
        saveloc = nextname(fullfile(outputFld{i},name,'frame.tiff'),'(001)');
        imwrite(this_frame,saveloc);
        
    end
end
end