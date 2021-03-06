%-----------------------------------------------------------------------
% Alireza Tajadod
%-----------------------------------------------------------------------
clear
warning off;
if strfind(pwd,'volume')
    load('MySubjects.mat');
else
    load('MySubjects_Windows.mat');
    
end

fields = fieldnames(MySubjects);

for i=2
    
    
    
    SubjectDirecotry = MySubjects.(fields{i}).Folder;
    AllRuns  = MySubjects.(fields{i}).Runs.NameChanges;
    for j=8
        
        ImgFiles = MySubjects.(fields{i}).Runs.(AllRuns{j}).Images;
        AnatomyImg = MySubjects.(fields{i}).Anatomy.Image;
        Files{1} = ImgFiles;
        
    end
    
    
    

    numRun = 1
    %TimeSlicing
    
    matlabbatch{1}.spm.temporal.st.scans = Files;
    matlabbatch{1}.spm.temporal.st.nslices = 40;
    matlabbatch{1}.spm.temporal.st.tr = 2;
    matlabbatch{1}.spm.temporal.st.ta = 2-(2/40);
    matlabbatch{1}.spm.temporal.st.so = [2:2:40 1:2:40];
    matlabbatch{1}.spm.temporal.st.refslice = 2;
    matlabbatch{1}.spm.temporal.st.prefix = 'a';
    
    
    
    %betterto loop them for run = 1:10 (should we have 10
    %functional runs?)
    
    for run = 1:numRun
        matlabbatch{2}.spm.spatial.realign.estwrite.data{run}(1) = cfg_dep;
        matlabbatch{2}.spm.spatial.realign.estwrite.data{run}(1).tname = 'Session';
        matlabbatch{2}.spm.spatial.realign.estwrite.data{run}(1).tgt_spec{1}(1).name = 'filter';
        matlabbatch{2}.spm.spatial.realign.estwrite.data{run}(1).tgt_spec{1}(1).value = 'image';
        matlabbatch{2}.spm.spatial.realign.estwrite.data{run}(1).tgt_spec{1}(2).name = 'strtype';
        matlabbatch{2}.spm.spatial.realign.estwrite.data{run}(1).tgt_spec{1}(2).value = 'e';
        matlabbatch{2}.spm.spatial.realign.estwrite.data{run}(1).sname = ['Slice Timing: Slice Timing Corr. Images (Sess ' num2str(run) ')'];
        matlabbatch{2}.spm.spatial.realign.estwrite.data{run}(1).src_exbranch = substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1});
        matlabbatch{2}.spm.spatial.realign.estwrite.data{run}(1).src_output = substruct('()',{run}, '.','files');
    end
    
    
    matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.quality = 0.9;
    matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.sep = 4;
    matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.fwhm = 5;
    matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.rtm = 1;
    matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.interp = 2;
    matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.wrap = [0 0 0];
    matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.weight = '';
    matlabbatch{2}.spm.spatial.realign.estwrite.roptions.which = [2 1];
    matlabbatch{2}.spm.spatial.realign.estwrite.roptions.interp = 4;
    matlabbatch{2}.spm.spatial.realign.estwrite.roptions.wrap = [0 0 0];
    matlabbatch{2}.spm.spatial.realign.estwrite.roptions.mask = 1;
    matlabbatch{2}.spm.spatial.realign.estwrite.roptions.prefix = 'r';
    
    %Coregister
    matlabbatch{3}.spm.spatial.coreg.estimate.ref(1) = cfg_dep;
    matlabbatch{3}.spm.spatial.coreg.estimate.ref(1).tname = 'Reference Image';
    matlabbatch{3}.spm.spatial.coreg.estimate.ref(1).tgt_spec{1}(1).name = 'filter';
    matlabbatch{3}.spm.spatial.coreg.estimate.ref(1).tgt_spec{1}(1).value = 'image';
    matlabbatch{3}.spm.spatial.coreg.estimate.ref(1).tgt_spec{1}(2).name = 'strtype';
    matlabbatch{3}.spm.spatial.coreg.estimate.ref(1).tgt_spec{1}(2).value = 'e';
    matlabbatch{3}.spm.spatial.coreg.estimate.ref(1).sname = 'Realign: Estimate & Reslice: Mean Image';
    matlabbatch{3}.spm.spatial.coreg.estimate.ref(1).src_exbranch = substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1});
    matlabbatch{3}.spm.spatial.coreg.estimate.ref(1).src_output = substruct('.','rmean');
    
    matlabbatch{3}.spm.spatial.coreg.estimate.source = {AnatomyImg};
    matlabbatch{3}.spm.spatial.coreg.estimate.other = {''};
    matlabbatch{3}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
    matlabbatch{3}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
    matlabbatch{3}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
    matlabbatch{3}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];
    
    %Spatial Preprocess
    matlabbatch{4}.spm.spatial.preproc.data(1) = cfg_dep;
    matlabbatch{4}.spm.spatial.preproc.data(1).tname = 'Data';
    matlabbatch{4}.spm.spatial.preproc.data(1).tgt_spec{1}(1).name = 'filter';
    matlabbatch{4}.spm.spatial.preproc.data(1).tgt_spec{1}(1).value = 'image';
    matlabbatch{4}.spm.spatial.preproc.data(1).tgt_spec{1}(2).name = 'strtype';
    matlabbatch{4}.spm.spatial.preproc.data(1).tgt_spec{1}(2).value = 'e';
    matlabbatch{4}.spm.spatial.preproc.data(1).sname = 'Coregister: Estimate & Reslice: Coregistered Images';
    matlabbatch{4}.spm.spatial.preproc.data(1).src_exbranch = substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1});
    matlabbatch{4}.spm.spatial.preproc.data(1).src_output = substruct('.','cfiles');
    matlabbatch{4}.spm.spatial.preproc.output.GM = [0 0 1];
    matlabbatch{4}.spm.spatial.preproc.output.WM = [0 0 1];
    matlabbatch{4}.spm.spatial.preproc.output.CSF = [0 0 1];
    matlabbatch{4}.spm.spatial.preproc.output.biascor = 1;
    matlabbatch{4}.spm.spatial.preproc.output.cleanup = 0;
    

        matlabbatch{4}.spm.spatial.preproc.opts.tpm = {
            '/Volumes/Ryan3T1/myStudies/phdThesisData/Scripts/tpm/grey.nii'
            '/Volumes/Ryan3T1/myStudies/phdThesisData/Scripts/tpm/white.nii'
            '/Volumes/Ryan3T1/myStudies/phdThesisData/Scripts/tpm/csf.nii'
            };
        

    
    
    matlabbatch{4}.spm.spatial.preproc.opts.ngaus = [2
        2
        2
        4];
    matlabbatch{4}.spm.spatial.preproc.opts.regtype = 'mni';
    matlabbatch{4}.spm.spatial.preproc.opts.warpreg = 1;
    matlabbatch{4}.spm.spatial.preproc.opts.warpco = 25;
    matlabbatch{4}.spm.spatial.preproc.opts.biasreg = 0.0001;
    matlabbatch{4}.spm.spatial.preproc.opts.biasfwhm = 60;
    matlabbatch{4}.spm.spatial.preproc.opts.samp = 3;
    matlabbatch{4}.spm.spatial.preproc.opts.msk = {''};
    
    %Normalise
    matlabbatch{5}.spm.spatial.normalise.write.subj.matname(1) = cfg_dep;
    matlabbatch{5}.spm.spatial.normalise.write.subj.matname(1).tname = 'Parameter File';
    matlabbatch{5}.spm.spatial.normalise.write.subj.matname(1).tgt_spec{1}(1).name = 'filter';
    matlabbatch{5}.spm.spatial.normalise.write.subj.matname(1).tgt_spec{1}(1).value = 'mat';
    matlabbatch{5}.spm.spatial.normalise.write.subj.matname(1).tgt_spec{1}(2).name = 'strtype';
    matlabbatch{5}.spm.spatial.normalise.write.subj.matname(1).tgt_spec{1}(2).value = 'e';
    matlabbatch{5}.spm.spatial.normalise.write.subj.matname(1).sname = 'Segment: Norm Params Subj->MNI';
    matlabbatch{5}.spm.spatial.normalise.write.subj.matname(1).src_exbranch = substruct('.','val', '{}',{4}, '.','val', '{}',{1}, '.','val', '{}',{1});
    matlabbatch{5}.spm.spatial.normalise.write.subj.matname(1).src_output = substruct('()',{1}, '.','snfile', '()',{':'});
    
    
    matlabbatch{5}.spm.spatial.normalise.write.subj.resample(1) = cfg_dep;
    matlabbatch{5}.spm.spatial.normalise.write.subj.resample(1).tname = 'Images to Write';
    matlabbatch{5}.spm.spatial.normalise.write.subj.resample(1).tgt_spec{1}(1).name = 'filter';
    matlabbatch{5}.spm.spatial.normalise.write.subj.resample(1).tgt_spec{1}(1).value = 'image';
    matlabbatch{5}.spm.spatial.normalise.write.subj.resample(1).tgt_spec{1}(2).name = 'strtype';
    matlabbatch{5}.spm.spatial.normalise.write.subj.resample(1).tgt_spec{1}(2).value = 'e';
    matlabbatch{5}.spm.spatial.normalise.write.subj.resample(1).sname = 'Coregister: Estimate: Coregistered Images';
    matlabbatch{5}.spm.spatial.normalise.write.subj.resample(1).src_exbranch = substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1});
    matlabbatch{5}.spm.spatial.normalise.write.subj.resample(1).src_output = substruct('.','cfiles');
    matlabbatch{5}.spm.spatial.normalise.write.roptions.preserve = 0;
    matlabbatch{5}.spm.spatial.normalise.write.roptions.bb = [-78 -112 -50
        78 76 85];
    matlabbatch{5}.spm.spatial.normalise.write.roptions.vox = [1 1 1];
    matlabbatch{5}.spm.spatial.normalise.write.roptions.interp = 1;
    matlabbatch{5}.spm.spatial.normalise.write.roptions.wrap = [0 0 0];
    matlabbatch{5}.spm.spatial.normalise.write.roptions.prefix = 'w';
    
    %Normalize Functional
    matlabbatch{6}.spm.spatial.normalise.write.subj.matname(1) = cfg_dep;
    matlabbatch{6}.spm.spatial.normalise.write.subj.matname(1).tname = 'Parameter File';
    matlabbatch{6}.spm.spatial.normalise.write.subj.matname(1).tgt_spec{1}(1).name = 'filter';
    matlabbatch{6}.spm.spatial.normalise.write.subj.matname(1).tgt_spec{1}(1).value = 'mat';
    matlabbatch{6}.spm.spatial.normalise.write.subj.matname(1).tgt_spec{1}(2).name = 'strtype';
    matlabbatch{6}.spm.spatial.normalise.write.subj.matname(1).tgt_spec{1}(2).value = 'e';
    matlabbatch{6}.spm.spatial.normalise.write.subj.matname(1).sname = 'Segment: Norm Params Subj->MNI';
    matlabbatch{6}.spm.spatial.normalise.write.subj.matname(1).src_exbranch = substruct('.','val', '{}',{4}, '.','val', '{}',{1}, '.','val', '{}',{1});
    matlabbatch{6}.spm.spatial.normalise.write.subj.matname(1).src_output = substruct('()',{1}, '.','snfile', '()',{':'});
    
    
    %here we need normalize all 10 functional runs, better to loop
    for  run = 1: numRun
        matlabbatch{6}.spm.spatial.normalise.write.subj.resample(run) = cfg_dep;
        matlabbatch{6}.spm.spatial.normalise.write.subj.resample(run).tname = 'Images to Write';
        matlabbatch{6}.spm.spatial.normalise.write.subj.resample(run).tgt_spec{1}(1).name = 'filter';
        matlabbatch{6}.spm.spatial.normalise.write.subj.resample(run).tgt_spec{1}(1).value = 'image';
        matlabbatch{6}.spm.spatial.normalise.write.subj.resample(run).tgt_spec{1}(2).name = 'strtype';
        matlabbatch{6}.spm.spatial.normalise.write.subj.resample(run).tgt_spec{1}(2).value = 'e';
        matlabbatch{6}.spm.spatial.normalise.write.subj.resample(run).sname = ['Realign: Estimate & Reslice: Resliced Images (Sess' ,num2str(run),')'];cd
        matlabbatch{6}.spm.spatial.normalise.write.subj.resample(run).src_exbranch = substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1});
        matlabbatch{6}.spm.spatial.normalise.write.subj.resample(run).src_output = substruct('.','sess', '()',{run}, '.','rfiles');
    end
    
    %end loop
    
    matlabbatch{6}.spm.spatial.normalise.write.roptions.preserve = 0;
    matlabbatch{6}.spm.spatial.normalise.write.roptions.bb = [-78 -112 -50
        78 76 85];
    matlabbatch{6}.spm.spatial.normalise.write.roptions.vox = [2 2 2];
    matlabbatch{6}.spm.spatial.normalise.write.roptions.interp = 1;
    matlabbatch{6}.spm.spatial.normalise.write.roptions.wrap = [0 0 0];
    matlabbatch{6}.spm.spatial.normalise.write.roptions.prefix = 'w';
    
    %smoooooooooooth
    matlabbatch{7}.spm.spatial.smooth.data(1) = cfg_dep;
    matlabbatch{7}.spm.spatial.smooth.data(1).tname = 'Images to Smooth';
    matlabbatch{7}.spm.spatial.smooth.data(1).tgt_spec{1}(1).name = 'filter';
    matlabbatch{7}.spm.spatial.smooth.data(1).tgt_spec{1}(1).value = 'image';
    matlabbatch{7}.spm.spatial.smooth.data(1).tgt_spec{1}(2).name = 'strtype';
    matlabbatch{7}.spm.spatial.smooth.data(1).tgt_spec{1}(2).value = 'e';
    matlabbatch{7}.spm.spatial.smooth.data(1).sname = 'Normalise: Write: Normalised Images (Subj 1)';
    matlabbatch{7}.spm.spatial.smooth.data(1).src_exbranch = substruct('.','val', '{}',{6}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1});
    matlabbatch{7}.spm.spatial.smooth.data(1).src_output = substruct('()',{1}, '.','files');
    matlabbatch{7}.spm.spatial.smooth.fwhm = [4 4 4];
    matlabbatch{7}.spm.spatial.smooth.dtype = 0;
    matlabbatch{7}.spm.spatial.smooth.im = 0;
    matlabbatch{7}.spm.spatial.smooth.prefix = 's';
    
    
    %save(fullfile(SubjectDirecotry,'info.mat'),'ExportInfo')
    spm('defaults', 'FMRI');
    spm_jobman('run', matlabbatch);
    
end